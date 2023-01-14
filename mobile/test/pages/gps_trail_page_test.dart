import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/gps_trail_page.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.userPreferenceManager.mapType)
        .thenReturn(MapType.normal.id);
    when(appManager.propertiesManager.mapboxApiKey).thenReturn("");
    when(appManager.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn(null);
    when(appManager.timeManager.currentTimestamp)
        .thenReturn(DateTime.now().millisecondsSinceEpoch);
    when(appManager.locationMonitor.currentLatLng).thenReturn(null);
  });

  testWidgets("Time is primary when body of water is empty", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => GpsTrailPage(GpsTrail(
        startTimestamp: Int64(DateTime(2022, 1, 1, 12).millisecondsSinceEpoch),
        timeZone: "America/Chicago",
      )),
      appManager: appManager,
    );
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(
      find.primaryText(context, text: "Jan 1, 2022 at 12:00 PM"),
      findsOneWidget,
    );
  });

  testWidgets("Time is subtitle when body of water is set", (tester) async {
    when(appManager.bodyOfWaterManager.displayNameFromId(any, any))
        .thenReturn("Lake Huron");

    var context = await pumpContext(
      tester,
      (_) => GpsTrailPage(GpsTrail(
        startTimestamp: Int64(DateTime(2022, 1, 1, 12).millisecondsSinceEpoch),
        timeZone: "America/Chicago",
      )),
      appManager: appManager,
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
      appManager: appManager,
    );
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.text("5s"), findsOneWidget);
  });

  testWidgets("End time as current time is shown", (tester) async {
    when(appManager.timeManager.currentTimestamp)
        .thenReturn(DateTime(2022, 1, 1, 13).millisecondsSinceEpoch);

    await pumpContext(
      tester,
      (_) => GpsTrailPage(GpsTrail(
        startTimestamp: Int64(DateTime(2022, 1, 1, 12).millisecondsSinceEpoch),
      )),
      appManager: appManager,
    );
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.text("1h"), findsOneWidget);
  });
}
