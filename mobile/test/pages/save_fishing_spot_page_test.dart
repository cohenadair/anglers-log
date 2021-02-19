import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/save_fishing_spot_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockFishingSpotManager: true,
      mockLocationMonitor: true,
    );
  });

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveFishingSpotPage(
        latLng: LatLng(1.000000, 2.000000),
      ),
      appManager: appManager,
    ));
    expect(find.text("New Fishing Spot"), findsOneWidget);
  });

  testWidgets("Edit title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveFishingSpotPage.edit(FishingSpot()..id = randomId()),
      appManager: appManager,
    ));
    expect(find.text("Edit Fishing Spot"), findsOneWidget);
  });

  testWidgets("New fishing spot", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveFishingSpotPage(
        latLng: LatLng(1.000000, 2.000000),
      ),
      appManager: appManager,
    ));

    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Name"), "Spot A");
    await tapAndSettle(tester, find.text("SAVE"));

    var result =
        verify(appManager.mockFishingSpotManager.addOrUpdate(captureAny));
    result.called(1);

    FishingSpot spot = result.captured.first;
    expect(spot.name, "Spot A");
    expect(spot.lat, 1.000000);
    expect(spot.lng, 2.000000);
  });

  testWidgets("Save fishing spot without a name", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveFishingSpotPage(
        latLng: LatLng(1.000000, 2.000000),
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("SAVE"));

    var result =
        verify(appManager.mockFishingSpotManager.addOrUpdate(captureAny));
    result.called(1);

    FishingSpot spot = result.captured.first;
    expect(spot.hasName(), isFalse);
    expect(spot.lat, 1.000000);
    expect(spot.lng, 2.000000);
  });

  testWidgets("onSave is invoked", (tester) async {
    var invoked = false;
    await tester.pumpWidget(Testable(
      (_) => SaveFishingSpotPage(
        latLng: LatLng(1.000000, 2.000000),
        onSave: (_) => invoked = true,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("SAVE"));
    expect(invoked, isTrue);
  });
}
