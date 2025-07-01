import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/catch_page.dart';
import 'package:mobile/pages/gps_trail_page.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/default_mapbox_map.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/timezone.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.userPreferenceManager.mapType).thenReturn(MapType.light.id);
    when(managers.propertiesManager.mapboxApiKey).thenReturn("");
    when(managers.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn(null);
    when(managers.timeManager.currentTimestamp)
        .thenReturn(DateTime.now().millisecondsSinceEpoch);
    when(managers.locationMonitor.currentLatLng).thenReturn(null);
    when(managers.ioWrapper.isAndroid).thenReturn(false);
  });

  testWidgets("Time is primary when body of water is empty", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => GpsTrailPage(GpsTrail(
        startTimestamp: Int64(
            TZDateTime(getLocation("America/Chicago"), 2022, 1, 1, 12)
                .millisecondsSinceEpoch),
        timeZone: "America/Chicago",
      )),
    );
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(
      find.primaryText(context, text: "Jan 1, 2022 at 12:00 PM"),
      findsOneWidget,
    );
  });

  testWidgets("Time is subtitle when body of water is set", (tester) async {
    when(managers.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn("Lake Huron");

    var context = await pumpContext(
      tester,
      (_) => GpsTrailPage(GpsTrail(
        startTimestamp: Int64(
            TZDateTime(getLocation("America/Chicago"), 2022, 1, 1, 12)
                .millisecondsSinceEpoch),
        timeZone: "America/Chicago",
      )),
    );
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(
      find.subtitleText(context, text: "Jan 1, 2022 at 12:00 PM"),
      findsOneWidget,
    );
    expect(
      find.primaryText(context, text: "Lake Huron"),
      findsOneWidget,
    );
  });

  testWidgets("End time of trail is used for duration", (tester) async {
    await pumpContext(
      tester,
      (_) => GpsTrailPage(GpsTrail(
        startTimestamp: Int64(1000),
        endTimestamp: Int64(6000),
      )),
    );
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.text("5s"), findsOneWidget);
  });

  testWidgets("End time as current time is shown", (tester) async {
    when(managers.timeManager.currentTimestamp)
        .thenReturn(DateTime(2022, 1, 1, 13).millisecondsSinceEpoch);

    await pumpContext(
      tester,
      (_) => GpsTrailPage(GpsTrail(
        startTimestamp: Int64(DateTime(2022, 1, 1, 12).millisecondsSinceEpoch),
      )),
    );
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.text("1h"), findsOneWidget);
  });

  testWidgets("Tapping catch symbol opens catch details", (tester) async {
    await pumpContext(
      tester,
      (_) => GpsTrailPage(GpsTrail(
        startTimestamp: Int64(DateTime(2022, 1, 1, 12).millisecondsSinceEpoch),
      )),
    );
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    var controller = MockMapboxMapController();
    when(controller.onSymbolTapped).thenReturn(ArgumentCallbacks<Symbol>());

    var map = findFirst<DefaultMapboxMap>(tester);
    map.onMapCreated?.call(controller);

    when(managers.catchManager.entity(any)).thenReturn(Catch(
      speciesId: randomId(),
    ));
    when(managers.catchManager.deleteMessage(any, any)).thenReturn("Delete");
    when(managers.ioWrapper.isAndroid).thenReturn(false);

    var symbol = MockSymbol();
    when(symbol.data).thenReturn({"catch_id": "some-id"});
    controller.onSymbolTapped.call(symbol);

    await tester.pumpAndSettle();
    expect(find.byType(CatchPage), findsOneWidget);
  });

  testWidgets("Tapping catch symbol for catch that doesn't exist",
      (tester) async {
    await pumpContext(
      tester,
      (_) => GpsTrailPage(GpsTrail(
        startTimestamp: Int64(DateTime(2022, 1, 1, 12).millisecondsSinceEpoch),
      )),
    );
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    var controller = MockMapboxMapController();
    when(controller.onSymbolTapped).thenReturn(ArgumentCallbacks<Symbol>());

    var map = findFirst<DefaultMapboxMap>(tester);
    map.onMapCreated?.call(controller);

    when(managers.catchManager.entity(any)).thenReturn(null);

    var symbol = MockSymbol();
    when(symbol.data).thenReturn({"catch_id": "some-id"});
    controller.onSymbolTapped.call(symbol);

    await tester.pumpAndSettle();
    expect(find.byType(CatchPage), findsNothing);
    verify(managers.catchManager.entity(any)).called(1);
  });
}
