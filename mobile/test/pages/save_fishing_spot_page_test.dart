import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/save_fishing_spot_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    var bodyOfWater = BodyOfWater(
      id: randomId(),
      name: "Lake Huron",
    );
    when(appManager.bodyOfWaterManager.listSortedByDisplayName(
      any,
      filter: anyNamed("filter"),
    )).thenReturn([bodyOfWater]);
    when(appManager.bodyOfWaterManager.entity(any)).thenReturn(bodyOfWater);
    when(appManager.bodyOfWaterManager.entityExists(any)).thenReturn(true);
    when(appManager.bodyOfWaterManager.displayName(any, any))
        .thenReturn("Lake Huron");
    when(appManager.bodyOfWaterManager.id(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first.id);

    when(appManager.fishingSpotManager.addOrUpdate(
      any,
      imageFile: anyNamed("imageFile"),
    )).thenAnswer((_) => Future.value(true));
  });

  testWidgets("Editing with all optional values set", (tester) async {
    when(appManager.bodyOfWaterManager.entity(any)).thenReturn(BodyOfWater(
      id: randomId(),
      name: "Lake Huron",
    ));

    await stubImage(appManager, tester, "flutter_logo.png");

    await tester.pumpWidget(Testable(
      (_) => SaveFishingSpotPage.edit(FishingSpot(
        id: randomId(),
        bodyOfWaterId: randomId(),
        name: "Test Spot",
        notes: "Some test notes",
        imageName: "flutter_logo.png",
        lat: 1.000000,
        lng: 2.000000,
      )),
      appManager: appManager,
    ));
    // Wait for image future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("Test Spot"), findsOneWidget);
    expect(find.text("1.000000, 2.000000"), findsOneWidget);
    expect(find.text("Some test notes"), findsOneWidget);
    expect(find.text("Lake Huron"), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets("Editing with no optional values set", (tester) async {
    when(appManager.bodyOfWaterManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => SaveFishingSpotPage.edit(FishingSpot()),
      appManager: appManager,
    ));

    expect(find.text("Not Selected"), findsOneWidget); // Body of water
    expect(find.text("0.000000, 0.000000"), findsOneWidget);
    expect(
      findFirstWithText<TextInput>(tester, "Name").controller?.value,
      isNull,
    );
    expect(find.byType(Image), findsNothing);
    expect(
      findFirstWithText<TextInput>(tester, "Notes").controller?.value,
      isNull,
    );
  });
}
