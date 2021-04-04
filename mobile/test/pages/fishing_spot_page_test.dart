import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/fishing_spot_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.fishingSpotManager.entity(any)).thenReturn(FishingSpot()
      ..id = randomId()
      ..name = "Test Fishing Spot"
      ..lat = 1.234567
      ..lng = 7.654321);

    when(appManager.locationMonitor.currentLocation).thenReturn(null);
  });

  testWidgets("Back button color updates on may type changes", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPage(FishingSpot()),
      appManager: appManager,
    ));
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    await tapAndSettle(tester, find.byIcon(Icons.layers));
    await tapAndSettle(tester, find.text("Normal"));
    expect(findFirst<BackButton>(tester).color, Colors.black);

    await tapAndSettle(tester, find.byIcon(Icons.layers));
    await tapAndSettle(tester, find.text("Terrain"));
    expect(findFirst<BackButton>(tester).color, Colors.black);

    await tapAndSettle(tester, find.byIcon(Icons.layers));
    await tapAndSettle(tester, find.text("Satellite"));
    expect(findFirst<BackButton>(tester).color, Colors.white);

    await tapAndSettle(tester, find.byIcon(Icons.layers));
    await tapAndSettle(tester, find.text("Hybrid"));
    expect(findFirst<BackButton>(tester).color, Colors.white);
  });
}
