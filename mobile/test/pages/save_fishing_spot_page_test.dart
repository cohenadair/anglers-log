import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/pages/save_fishing_spot_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/image_input.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.dart';
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

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveFishingSpotPage(
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

  testWidgets("New fishing spot with app properties set", (tester) async {
    when(appManager.imageManager.save(any, compress: anyNamed("compress")))
        .thenAnswer((_) => Future.value(["image_name.png"]));

    await tester.pumpWidget(Testable(
      (_) => const SaveFishingSpotPage(
        latLng: LatLng(1.000000, 2.000000),
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Body Of Water"));
    await tapAndSettle(tester, find.text("Lake Huron"));

    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Name"), "Spot A");
    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "Notes"), "Some notes");

    // Emulate picking an image by setting the controller's value directly.
    var imageController = tester
        .widget<SingleImageInput>(find.byType(SingleImageInput))
        .controller;
    imageController.value = PickedImage(
      originalFile: MockFile(),
    );

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.fishingSpotManager.addOrUpdate(
      captureAny,
      imageFile: captureAnyNamed("imageFile"),
    ));
    result.called(1);

    // Verify all properties are set correctly.
    FishingSpot spot = result.captured.first;
    expect(spot.name, "Spot A");
    expect(spot.notes, "Some notes");
    expect(spot.hasBodyOfWaterId(), isTrue);
    expect(spot.lat, 1.000000);
    expect(spot.lng, 2.000000);

    // Verify image is passed to FishingSpotManager.
    expect(result.captured[1], isNotNull);
  });

  testWidgets("Save fishing spot no optional properties set", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const SaveFishingSpotPage(
        latLng: LatLng(1.000000, 2.000000),
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.fishingSpotManager.addOrUpdate(captureAny));
    result.called(1);

    FishingSpot spot = result.captured.first;
    expect(spot.hasName(), isFalse);
    expect(spot.hasNotes(), isFalse);
    expect(spot.hasBodyOfWaterId(), isFalse);
    expect(spot.lat, 1.000000);
    expect(spot.lng, 2.000000);
  });

  testWidgets("onSave is invoked", (tester) async {
    var invoked = false;
    await tester.pumpWidget(Testable(
      (_) => SaveFishingSpotPage(
        latLng: const LatLng(1.000000, 2.000000),
        onSave: (_) => invoked = true,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("SAVE"));
    expect(invoked, isTrue);
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

    expect(find.text("Test Spot"), findsNothing);
    expect(find.text("Some test notes"), findsNothing);
    expect(find.text("Lake Huron"), findsNothing);
    expect(find.byType(Image), findsNothing);
  });
}
