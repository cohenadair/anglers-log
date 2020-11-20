import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/fishing_spot_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockFishingSpotManager: true,
    );

    when(appManager.mockFishingSpotManager.entity(any)).thenReturn(FishingSpot()
      ..id = randomId()
      ..name = "Test Fishing Spot"
      ..lat = 1.234567
      ..lng = 7.654321);
  });

  testWidgets("Back button color updates on may type changes",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotPage(randomId()),
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
