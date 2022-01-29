import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/add_anything_page.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../mocks/stubbed_map_controller.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late StubbedMapController mapController;

  setUp(() {
    appManager = StubbedAppManager();
    mapController = StubbedMapController();

    when(appManager.baitCategoryManager.listSortedByName(
      filter: anyNamed("filter"),
    )).thenReturn([]);

    when(appManager.catchManager.imageNamesSortedByTimestamp(any))
        .thenReturn([]);
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      dateRange: anyNamed("dateRange"),
      catchIds: anyNamed("catchIds"),
      speciesIds: anyNamed("speciesIds"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      baits: anyNamed("baits"),
    )).thenReturn([]);
    when(appManager.catchManager.hasEntities).thenReturn(false);

    when(appManager.reportManager.entityExists(any)).thenReturn(false);
    when(appManager.reportManager.defaultReport).thenReturn(Report());
    when(appManager.reportManager.displayName(any, any)).thenReturn("Test");

    when(appManager.fishingSpotManager.list()).thenReturn([]);
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    when(appManager.locationMonitor.currentLocation).thenReturn(null);

    when(appManager.propertiesManager.mapboxApiKey).thenReturn("");

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(true);

    when(appManager.timeManager.currentDateTime).thenReturn(DateTime.now());

    when(appManager.userPreferenceManager.selectedReportId).thenReturn(null);
    when(appManager.userPreferenceManager.setSelectedReportId(any))
        .thenAnswer((_) => Future.value());
    when(appManager.userPreferenceManager.mapType).thenReturn(null);
  });

  testWidgets("Tapping nav item opens page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await mapController.finishLoading(tester);

    // Starts on Catches page.
    expect(findFirst<IndexedStack>(tester).index, 1);

    await tapAndSettle(tester, find.text("Catches"));
    expect(findFirst<IndexedStack>(tester).index, 1);

    await tapAndSettle(tester, find.text("Map"));
    expect(findFirst<IndexedStack>(tester).index, 0);

    await tapAndSettle(tester, find.text("Stats"));
    expect(findFirst<IndexedStack>(tester).index, 3);

    await tapAndSettle(tester, find.byIcon(Icons.more_horiz));
    expect(findFirst<IndexedStack>(tester).index, 4);

    await tapAndSettle(tester, find.text("Add"));
    // Indexed stack should stay at the same index.
    expect(findFirst<IndexedStack>(tester).index, 4);
    expect(find.byType(AddAnythingPage), findsOneWidget);
  });

  testWidgets("Navigation state is persisted when switching tabs",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await mapController.finishLoading(tester);

    await tapAndSettle(tester, find.byIcon(Icons.more_horiz));
    await tapAndSettle(tester, find.text("Bait Categories"));

    expect(find.text("Bait Categories (0)"), findsOneWidget);

    await tapAndSettle(tester, find.text("Catches"));
    expect(find.text("Bait Categories (0)"), findsOneWidget);
  });

  testWidgets("Tapping current nav item again pops all pages on current stack",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await mapController.finishLoading(tester);

    await tapAndSettle(tester, find.byIcon(Icons.more_horiz));
    await tapAndSettle(tester, find.text("Bait Categories"));

    expect(find.text("Bait Categories (0)"), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.more_horiz));
    expect(find.text("Bait Categories (0)"), findsNothing);
  });

  testWidgets("Rate dialog shown when catches updated", (tester) async {
    when(appManager.baitManager.formatNameWithCategory(any)).thenReturn("");

    var species = Species()
      ..id = randomId()
      ..name = "Bass";
    when(appManager.speciesManager.entity(any)).thenReturn(species);

    var catchManager = CatchManager(appManager.app);
    when(appManager.app.catchManager).thenReturn(catchManager);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await mapController.finishLoading(tester);

    var quarterDuration = Duration.millisecondsPerDay * (365 / 4);
    when(appManager.timeManager.msSinceEpoch)
        .thenReturn((quarterDuration + 10).toInt());
    when(appManager.userPreferenceManager.didRateApp).thenReturn(false);
    when(appManager.userPreferenceManager.rateTimerStartedAt).thenReturn(0);
    when(appManager.imageManager.save(any, compress: anyNamed("compress")))
        .thenAnswer((_) => Future.value([]));
    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch)
      ..speciesId = species.id);

    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
