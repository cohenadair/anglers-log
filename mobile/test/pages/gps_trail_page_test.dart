import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/catch_page.dart';
import 'package:mobile/pages/gps_trail_page.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/default_mapbox_map.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/timezone.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';
import '../mocks/stubbed_map_controller.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.userPreferenceManager.mapType).thenReturn(MapType.light.id);
    when(managers.propertiesManager.mapboxApiKey).thenReturn("");
    when(
      managers.bodyOfWaterManager.displayNameFromId(any, any),
    ).thenReturn(null);
    when(
      managers.lib.timeManager.currentTimestamp,
    ).thenReturn(DateTime.now().millisecondsSinceEpoch);
    when(managers.locationMonitor.currentLatLng).thenReturn(null);
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);
  });

  GpsTrail trailWithPoints() => GpsTrail(
    startTimestamp: Int64(DateTime(2022, 1, 1, 12).millisecondsSinceEpoch),
    points: [GpsTrailPoint(lat: 1, lng: 2), GpsTrailPoint(lat: 3, lng: 4)],
  );

  StubbedMapController stubTrailMap() {
    final mapController = StubbedMapController(managers);
    when(
      mapController.map.value.cameraForCoordinateBounds(
        any,
        any,
        any,
        any,
        any,
        any,
      ),
    ).thenAnswer((_) => Future.value(CameraOptions()));
    when(
      mapController.map.value.flyTo(any, any),
    ).thenAnswer((_) => Future.value());
    when(managers.catchManager.catchesForGpsTrail(any)).thenReturn([]);
    return mapController;
  }

  /// Mapbox callbacks aren't called in widget tests, so the first render is
  /// simulated by calling the idle callback.
  Future<void> renderMap(WidgetTester tester) async {
    findFirst<DefaultMapboxMap>(tester).onMapIdle!(
      MapIdleEventData.fromJson({"timestamp": 0}),
    );
    await tester.pumpAndSettle();
  }

  testWidgets("Time is primary when body of water is empty", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => GpsTrailPage(
        GpsTrail(
          startTimestamp: Int64(
            TZDateTime(
              getLocation("America/Chicago"),
              2022,
              1,
              1,
              12,
            ).millisecondsSinceEpoch,
          ),
          timeZone: "America/Chicago",
        ),
      ),
    );
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(
      find.primaryText(context, text: "Jan 1, 2022 at 12:00 PM"),
      findsOneWidget,
    );
  });

  testWidgets("Time is subtitle when body of water is set", (tester) async {
    when(
      managers.bodyOfWaterManager.displayNameFromId(any, any),
    ).thenReturn("Lake Huron");

    var context = await pumpContext(
      tester,
      (_) => GpsTrailPage(
        GpsTrail(
          startTimestamp: Int64(
            TZDateTime(
              getLocation("America/Chicago"),
              2022,
              1,
              1,
              12,
            ).millisecondsSinceEpoch,
          ),
          timeZone: "America/Chicago",
        ),
      ),
    );
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(
      find.subtitleText(context, text: "Jan 1, 2022 at 12:00 PM"),
      findsOneWidget,
    );
    expect(find.primaryText(context, text: "Lake Huron"), findsOneWidget);
  });

  testWidgets("End time of trail is used for duration", (tester) async {
    await pumpContext(
      tester,
      (_) => GpsTrailPage(
        GpsTrail(startTimestamp: Int64(1000), endTimestamp: Int64(6000)),
      ),
    );
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.text("5s"), findsOneWidget);
  });

  testWidgets("End time as current time is shown", (tester) async {
    when(
      managers.lib.timeManager.currentTimestamp,
    ).thenReturn(DateTime(2022, 1, 1, 13).millisecondsSinceEpoch);

    await pumpContext(
      tester,
      (_) => GpsTrailPage(
        GpsTrail(
          startTimestamp: Int64(
            DateTime(2022, 1, 1, 12).millisecondsSinceEpoch,
          ),
        ),
      ),
    );
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.text("1h"), findsOneWidget);
  });

  testWidgets("Trail isn't fit before the map renders", (tester) async {
    final mapController = stubTrailMap();
    await pumpMap(tester, mapController, GpsTrailPage(trailWithPoints()));
    verifyNever(mapController.map.value.flyTo(any, any));
  });

  testWidgets("Trail is fit after the map renders", (tester) async {
    final mapController = stubTrailMap();
    await pumpMap(tester, mapController, GpsTrailPage(trailWithPoints()));
    await renderMap(tester);
    verify(mapController.map.value.flyTo(any, any)).called(1);
  });

  testWidgets("Trail is only fit the first time the map renders", (
    tester,
  ) async {
    final mapController = stubTrailMap();
    await pumpMap(tester, mapController, GpsTrailPage(trailWithPoints()));
    await renderMap(tester);
    await renderMap(tester);
    verify(mapController.map.value.flyTo(any, any)).called(1);
  });

  testWidgets("Trail is fit when the map renders before it's created", (
    tester,
  ) async {
    final mapController = stubTrailMap();
    await tester.pumpWidget(Testable((_) => GpsTrailPage(trailWithPoints())));
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await renderMap(tester);
    verifyNever(mapController.map.value.flyTo(any, any));

    await mapController.finishLoading(tester);
    verify(mapController.map.value.flyTo(any, any)).called(1);
  });

  testWidgets("Tapping catch symbol opens catch details", (tester) async {
    final mapController = StubbedMapController(managers);

    await pumpMap(
      tester,
      mapController,
      GpsTrailPage(
        GpsTrail(
          startTimestamp: Int64(
            DateTime(2022, 1, 1, 12).millisecondsSinceEpoch,
          ),
        ),
      ),
    );

    when(
      managers.catchManager.entity(any),
    ).thenReturn(Catch(speciesIds: [randomId()]));
    when(managers.catchManager.deleteMessage(any, any)).thenReturn("Delete");
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);
    stubFormatDisplayNamesFromIds(managers.speciesManager, (_) => ["Rainbow"]);

    expect(mapController.value.onSymbolTappedCallbacks.isEmpty, isFalse);
    mapController.value.onSymbolTappedCallbacks.first(
      Symbol(metadata: SymbolMetadata(catchId: randomId())),
    );

    await tester.pumpAndSettle();
    expect(find.byType(CatchPage), findsOneWidget);
  });

  testWidgets("Tapping catch symbol for catch that doesn't exist", (
    tester,
  ) async {
    final mapController = StubbedMapController(managers);

    await pumpMap(
      tester,
      mapController,
      GpsTrailPage(
        GpsTrail(
          startTimestamp: Int64(
            DateTime(2022, 1, 1, 12).millisecondsSinceEpoch,
          ),
        ),
      ),
    );

    when(managers.catchManager.entity(any)).thenReturn(null);

    expect(mapController.value.onSymbolTappedCallbacks.isEmpty, isFalse);
    mapController.value.onSymbolTappedCallbacks.first(
      Symbol(metadata: SymbolMetadata(catchId: randomId())),
    );

    await tester.pumpAndSettle();
    expect(find.byType(CatchPage), findsNothing);
    verify(managers.catchManager.entity(any)).called(1);
  });
}
