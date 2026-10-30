/// Anglers' Log's app-side capture entrypoint. `screenshots/capture` runs it
/// on each simulator/emulator with `flutter run`, then takes the actual
/// (native, full-resolution) screenshots. See README.md.
library;

import 'dart:convert';
import 'dart:io';

import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/utils/firebase_setup.dart';
import 'package:adair_flutter_lib/widgets/app_bar_dropdown.dart';
import 'package:adair_flutter_lib/wrappers/path_provider_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/database/sqlite_open_helper.dart';
import 'package:mobile/firebase_options.dart';
import 'package:mobile/main.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/calendar_page.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/pages/catch_page.dart';
import 'package:mobile/pages/gps_trail_page.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/pages/more_page.dart';
import 'package:mobile/pages/species_counter_page.dart';
import 'package:mobile/pages/stats_page.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/report_utils.dart';
import 'package:mobile/widgets/fishing_spot_map.dart';
import 'package:screenshots_capture/screenshots_capture.dart';

import 'seed_ids.dart';

void main() => runCaptures(_AnglersLogCapture());

class _AnglersLogCapture implements CaptureApp {
  // MainPage's bottom navigation bar indexes.
  static const _tabMap = 0;
  static const _tabCatches = 1;
  static const _tabStats = 3;
  static const _tabMore = 4;

  // Where the app keeps images, relative to its documents and temporary
  // directories. These mirror ImageManager's private constants.
  static const _imagesDir = "2.0/images";
  static const _thumbsDir = "2.0/thumbs";

  /// Time for the main page's first frames (map tiles, report charts) after
  /// launch.
  static const _launchDelay = Duration(seconds: 3);

  /// Space for the map tab's search bar, so it doesn't cover the fit area.
  static const _mapFitTopPadding = 80.0;
  static const _mapFitPadding = 16.0;

  static final _reportIds = {
    "personal_bests": reportIdPersonalBests,
    "catch_summary": reportIdCatchSummary,
  };

  /// Replaces the database and images with those in the bundle written by
  /// `build_seed.dart`. Uses the app's own [openDb] so the schema always
  /// matches the app's.
  @override
  Future<void> seed(Directory bundle) async {
    var json =
        jsonDecode(File("${bundle.path}/seed.json").readAsStringSync())
            as Map<String, dynamic>;

    await deleteDb();
    var db = await openDb();
    var batch = db.batch();
    (json["tables"] as Map<String, dynamic>).forEach((table, rows) {
      for (var row in (rows as List).cast<Map>()) {
        batch.insert(table, {
          "id": Id(uuid: row["id"] as String).uint8List,
          "bytes": base64Decode(row["bytes"] as String),
        });
      }
    });
    (json["preferences"] as Map<String, dynamic>).forEach((key, value) {
      batch.insert("user_preference", {"id": key, "value": jsonEncode(value)});
    });
    await batch.commit(noResult: true);
    await db.close();

    var images = Directory(
      "${await PathProviderWrapper.get.appDocumentsPath}/$_imagesDir",
    );
    if (images.existsSync()) {
      images.deleteSync(recursive: true);
    }
    images.createSync(recursive: true);
    for (var name in (json["images"] as List).cast<String>()) {
      File("${bundle.path}/images/$name").copySync("${images.path}/$name");
    }

    var thumbs = Directory(
      "${await PathProviderWrapper.get.temporaryPath}/$_thumbsDir",
    );
    if (thumbs.existsSync()) {
      thumbs.deleteSync(recursive: true);
    }
  }

  @override
  Future<void> launch(WidgetTester tester, String locale) async {
    // Same as main(), with collection disabled for debug builds. This
    // entrypoint is test code (run by flutter_test), so it can use the app's
    // @visibleForTesting members.
    await setupFirebase(
      options: DefaultFirebaseOptions.currentPlatform,
      // ignore: invalid_use_of_visible_for_testing_member
      ignoreMatcher: isIgnorableMapboxError,
      // ignore: invalid_use_of_visible_for_testing_member
      nonFatalMatcher: isNonFatalMapboxError,
    );
    // ignore: invalid_use_of_visible_for_testing_member
    SubscriptionManager.set(_ProSubscriptionManager());

    await tester.pumpWidget(AnglersLog(locale: parseLocale(locale)));
    await waitFor(tester, find.byType(MainPage));
    await wait(_launchDelay);
  }

  @override
  Future<void> show(WidgetTester tester, Map<String, dynamic> capture) async {
    await resetNavigation(tester);
    await UserPreferenceManager.get.setThemeMode(
      capture["theme"] == "light" ? ThemeMode.light : ThemeMode.dark,
    );

    var screen = capture["screen"] as String;
    switch (screen) {
      case "catch_list":
        await selectTab(tester, _tabCatches);
      case "catch_details":
        await selectTab(tester, _tabCatches);
        await pushPage(
          tester,
          find.byType(CatchListPage),
          CatchPage(CatchManager.get.entity(_seedId(capture["catch"]))!),
        );
      case "fishing_spot_map":
        await selectTab(tester, _tabMap);
        await _fitMap(tester, (capture["bounds"] as List).cast<List>());
      case "report":
        await selectTab(tester, _tabStats);
        await _selectReport(tester, _reportIds[capture["report"]]!);
      case "calendar":
        await selectTab(tester, _tabMore);
        await pushPage(tester, find.byType(MorePage), CalendarPage());
      case "gps_trail":
        await selectTab(tester, _tabMore);
        await pushPage(
          tester,
          find.byType(MorePage),
          GpsTrailPage(
            AppManager.get.gpsTrailManager.entity(
              _seedId(capture["gpsTrail"]),
            )!,
          ),
        );
      case "species_counter":
        await selectTab(tester, _tabMore);
        await pushPage(tester, find.byType(MorePage), SpeciesCounterPage());
      default:
        throw ArgumentError("Unknown screen: $screen");
    }
  }

  Id _seedId(Object? key) => Id(uuid: anglersLogSeedUuid(key as String));

  /// Moves the map tab's camera to fit [bounds] (`[[south, west], [north,
  /// east]]`), so the same area fills the screen on every device.
  ///
  /// This repeats MapboxMapController.moveToBounds with different padding:
  /// the app doesn't expose the map tab's controller, so this uses the
  /// Mapbox widget's state instead.
  Future<void> _fitMap(WidgetTester tester, List<List> bounds) async {
    var mapWidget = find.descendant(
      of: find.byType(FishingSpotMap),
      matching: find.byType(MapWidget),
    );
    await waitFor(tester, mapWidget);

    // The Mapbox map is only set once its platform view has been created.
    MapboxMap? map() => (tester.state(mapWidget) as dynamic).mapboxMap;
    await waitUntil(tester, () => map() != null, description: "Mapbox map");

    await map()!.setCamera(
      await map()!.cameraForCoordinateBounds(
        CoordinateBounds(
          southwest: Point(coordinates: Position(bounds[0][1], bounds[0][0])),
          northeast: Point(coordinates: Position(bounds[1][1], bounds[1][0])),
          infiniteBounds: true,
        ),
        MbxEdgeInsets(
          top: _mapFitTopPadding,
          left: _mapFitPadding,
          bottom: _mapFitPadding,
          right: _mapFitPadding,
        ),
        null,
        null,
        null,
        null,
      ),
    );
    await settle(tester);
  }

  /// Picks [reportId] from the stats page's report dropdown, as a user would.
  Future<void> _selectReport(WidgetTester tester, Id reportId) async {
    var reportManager = AppManager.get.reportManager;
    // Read before opening the dropdown, which shows the same names.
    var name = reportManager.displayName(
      tester.element(find.byType(StatsPage)),
      reportManager.entity(reportId)!,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(StatsPage),
        matching: find.byType(AppBarDropdown),
      ),
    );
    await settle(tester);
    await tester.tap(find.text(name).last);
    await settle(tester);
  }
}

/// Shows the app as Pro, so no upgrade prompts or locked features appear.
/// SubscriptionManager's constructor is private, so this implements it;
/// anything else a screen calls fails loudly via [noSuchMethod].
class _ProSubscriptionManager implements SubscriptionManager {
  @override
  Future<void> init() => Future.value();

  @override
  bool get isPro => true;

  @override
  bool get isFree => false;

  @override
  Stream<void> get stream => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
