import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/save_fishing_spot_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    var bodyOfWater = BodyOfWater(id: randomId(), name: "Lake Huron");
    when(
      managers.bodyOfWaterManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn([bodyOfWater]);
    when(managers.bodyOfWaterManager.entity(any)).thenReturn(bodyOfWater);
    when(managers.bodyOfWaterManager.entityExists(any)).thenReturn(true);
    when(
      managers.bodyOfWaterManager.displayName(any, any),
    ).thenReturn("Lake Huron");
    when(
      managers.bodyOfWaterManager.id(any),
    ).thenAnswer((invocation) => invocation.positionalArguments.first.id);

    when(
      managers.fishingSpotManager.addOrUpdate(
        any,
        imageFile: anyNamed("imageFile"),
      ),
    ).thenAnswer((_) => Future.value(true));
  });

  testWidgets("Editing with all optional values set", (tester) async {
    when(
      managers.bodyOfWaterManager.entity(any),
    ).thenReturn(BodyOfWater(id: randomId(), name: "Lake Huron"));

    await stubImage(managers, tester, "flutter_logo.png");

    await tester.pumpWidget(
      Testable(
        (_) => SaveFishingSpotPage.edit(
          FishingSpot(
            id: randomId(),
            bodyOfWaterId: randomId(),
            name: "Test Spot",
            notes: "Some test notes",
            imageName: "flutter_logo.png",
            lat: 1.000000,
            lng: 2.000000,
          ),
        ),
      ),
    );
    // Wait for image future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("Test Spot"), findsOneWidget);
    expect(find.text("1.000000, 2.000000"), findsOneWidget);
    expect(find.text("Some test notes"), findsOneWidget);
    expect(find.text("Lake Huron"), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets("Editing with no optional values set", (tester) async {
    when(managers.bodyOfWaterManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(
      Testable((_) => SaveFishingSpotPage.edit(FishingSpot())),
    );

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
