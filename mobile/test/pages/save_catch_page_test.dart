import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/gen/google/protobuf/timestamp.pb.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/pages/save_catch_page.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/image_input.dart';
import 'package:mobile/widgets/static_fishing_spot.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockBaitCategoryManager: true,
      mockBaitManager: true,
      mockCatchManager: true,
      mockCustomEntityManager: true,
      mockFishingSpotManager: true,
      mockImageManager: true,
      mockPreferencesManager: true,
      mockSpeciesManager: true,
      mockTimeManager: true,
    );

    when(appManager.mockPreferencesManager.catchCustomEntityIds).thenReturn([]);
    appManager.stubCurrentTime(DateTime(2020, 2, 1, 10, 30));
  });

  group("From journey", () {
    testWidgets("Images with date sets Catch date", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage(
          images: [
            PickedImage(
              originalFile: File("test/resources/flutter_logo.png"),
              dateTime: DateTime(2020, 1, 1, 15, 30),
            ),
          ],
          species: Species()
            ..id = randomId()
            ..name = "Steelhead",
          fishingSpot: FishingSpot()
            ..id = randomId()
            ..lat = 0.123456
            ..lng = 1.12356,
        ),
        appManager: appManager,
      ));

      expect(find.text("Jan 1, 2020"), findsOneWidget);
      expect(find.text("3:30 PM"), findsOneWidget);
    });

    testWidgets("Images without date sets default date", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage(
          images: [
            PickedImage(
              originalFile: File("test/resources/flutter_logo.png"),
            ),
          ],
          species: Species()
            ..id = randomId()
            ..name = "Steelhead",
          fishingSpot: FishingSpot()
            ..id = randomId()
            ..lat = 0.123456
            ..lng = 1.12356,
        ),
        appManager: appManager,
      ));

      expect(find.text("Feb 1, 2020"), findsOneWidget);
      expect(find.text("10:30 AM"), findsOneWidget);
    });

    testWidgets("All journey fields set correctly", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage(
          images: [
            PickedImage(
              originalFile: File("test/resources/flutter_logo.png"),
              dateTime: DateTime(2020, 1, 1, 15, 30),
            ),
          ],
          species: Species()
            ..id = randomId()
            ..name = "Steelhead",
          fishingSpot: FishingSpot()
            ..id = randomId()
            ..name = "Spot A",
        ),
        appManager: appManager,
      ));

      // Add small delay so images future can finish.
      await tester.pumpAndSettle(Duration(milliseconds: 100));

      expect(find.text("Jan 1, 2020"), findsOneWidget);
      expect(find.text("3:30 PM"), findsOneWidget);
      expect(find.text("Bait"), findsOneWidget);
      expect(find.text("Not Selected"), findsOneWidget);
      expect(find.byType(StaticFishingSpot), findsOneWidget);
      expect(find.text("Species"), findsOneWidget);
      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets("popOverride is invoked", (tester) async {
      var invoked = false;
      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage(
          images: [
            PickedImage(
              originalFile: File("test/resources/flutter_logo.png"),
              dateTime: DateTime(2020, 1, 1, 15, 30),
            ),
          ],
          species: Species()
            ..id = randomId()
            ..name = "Steelhead",
          fishingSpot: FishingSpot()
            ..id = randomId()
            ..name = "Spot A",
          popOverride: () => invoked = true,
        ),
        appManager: appManager,
      ));

      await tapAndSettle(tester, find.text("SAVE"));
      expect(invoked, isTrue);
    });
  });

  group("Editing", () {
    testWidgets("All fields set correctly", (tester) async {
      var customEntity = CustomEntity()
        ..id = randomId()
        ..name = "Color"
        ..type = CustomEntity_Type.TEXT;
      when(appManager.mockCustomEntityManager.entity(customEntity.id))
          .thenReturn(customEntity);
      when(appManager.mockPreferencesManager.catchCustomEntityIds)
          .thenReturn([customEntity.id]);

      var bait = Bait()
        ..id = randomId()
        ..name = "Rapala";
      when(appManager.mockBaitManager.entity(any)).thenReturn(bait);
      when(appManager.mockBaitManager.formatNameWithCategory(any))
          .thenReturn("Rapala");

      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..name = "Spot A";
      when(appManager.mockFishingSpotManager.entity(any))
          .thenReturn(fishingSpot);

      var species = Species()
        ..id = randomId()
        ..name = "Steelhead";
      when(appManager.mockSpeciesManager.entity(any)).thenReturn(species);

      var cat = Catch()
        ..id = randomId()
        ..timestamp = Timestamp.fromDateTime(DateTime(2020, 1, 1, 15, 30))
        ..baitId = bait.id
        ..fishingSpotId = fishingSpot.id
        ..speciesId = species.id
        ..customEntityValues.add(CustomEntityValue()
          ..customEntityId = customEntity.id
          ..value = "Minnow")
        ..imageNames.add("flutter_logo.png");

      when(appManager.mockImageManager.images(
        any,
        imageNames: anyNamed("imageNames"),
        size: anyNamed("size"),
      )).thenAnswer(
        (_) => Future.value(
            [File("test/resources/flutter_logo.png").readAsBytesSync()]),
      );

      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage.edit(cat),
        appManager: appManager,
      ));

      // Add small delay so images future can finish.
      await tester.pumpAndSettle(Duration(milliseconds: 100));

      expect(find.text("Jan 1, 2020"), findsOneWidget);
      expect(find.text("3:30 PM"), findsOneWidget);
      expect(find.text("Bait"), findsOneWidget);
      expect(find.text("Rapala"), findsOneWidget);
      expect(find.byType(StaticFishingSpot), findsOneWidget);
      expect(find.text("Species"), findsOneWidget);
      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.text("Color"), findsOneWidget);
      expect(find.text("Minnow"), findsOneWidget);
    });

    testWidgets("Minimum fields set correctly", (tester) async {
      var species = Species()
        ..id = randomId()
        ..name = "Steelhead";
      when(appManager.mockSpeciesManager.entity(any)).thenReturn(species);

      var cat = Catch()
        ..id = randomId()
        ..timestamp = Timestamp.fromDateTime(DateTime(2020, 1, 1, 15, 30))
        ..speciesId = species.id;

      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage.edit(cat),
        appManager: appManager,
      ));

      expect(find.text("Jan 1, 2020"), findsOneWidget);
      expect(find.text("3:30 PM"), findsOneWidget);
      expect(find.text("Species"), findsOneWidget);
      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.text("Bait"), findsOneWidget);
      expect(find.text("Not Selected"), findsOneWidget);
      expect(find.text("Fishing Spot"), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(find.byType(StaticFishingSpot), findsNothing);
    });

    testWidgets("Saving", (tester) async {
      var customEntity = CustomEntity()
        ..id = randomId()
        ..name = "Color"
        ..type = CustomEntity_Type.TEXT;
      when(appManager.mockCustomEntityManager.entity(customEntity.id))
          .thenReturn(customEntity);
      when(appManager.mockPreferencesManager.catchCustomEntityIds)
          .thenReturn([customEntity.id]);

      var bait = Bait()
        ..id = randomId()
        ..name = "Rapala";
      when(appManager.mockBaitManager.entity(any)).thenReturn(bait);
      when(appManager.mockBaitManager.formatNameWithCategory(any))
          .thenReturn("Rapala");

      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..name = "Spot A";
      when(appManager.mockFishingSpotManager.entity(any))
          .thenReturn(fishingSpot);

      var species = Species()
        ..id = randomId()
        ..name = "Steelhead";
      when(appManager.mockSpeciesManager.entity(any)).thenReturn(species);

      var cat = Catch()
        ..id = randomId()
        ..timestamp = Timestamp.fromDateTime(DateTime(2020, 1, 1, 15, 30))
        ..baitId = bait.id
        ..fishingSpotId = fishingSpot.id
        ..speciesId = species.id
        ..customEntityValues.add(CustomEntityValue()
          ..customEntityId = customEntity.id
          ..value = "Minnow")
        ..imageNames.add("flutter_logo.png");

      when(appManager.mockImageManager.images(
        any,
        imageNames: anyNamed("imageNames"),
        size: anyNamed("size"),
      )).thenAnswer(
        (_) => Future.value(
            [File("test/resources/flutter_logo.png").readAsBytesSync()]),
      );

      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage.edit(cat),
        appManager: appManager,
      ));

      // Add small delay so images future can finish.
      await tester.pumpAndSettle(Duration(milliseconds: 100));

      when(appManager.mockCatchManager.addOrUpdate(
        captureAny,
        fishingSpot: anyNamed("fishingSpot"),
        imageFiles: anyNamed("imageFiles"),
      )).thenAnswer((invocation) {
        // Assume image is saved correctly.
        invocation.positionalArguments.first.imageNames.add("flutter_logo.png");
        return Future.value(true);
      });
      await tapAndSettle(tester, find.text("SAVE"));

      var result = verify(
        appManager.mockCatchManager.addOrUpdate(
          captureAny,
          fishingSpot: anyNamed("fishingSpot"),
          imageFiles: anyNamed("imageFiles"),
        ),
      );
      result.called(1);
      expect(result.captured.first, cat);
    });
  });

  group("New", () {
    testWidgets("All fields default correctly", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage(
          species: Species()
            ..id = randomId()
            ..name = "Steelhead",
          fishingSpot: FishingSpot()
            ..id = randomId()
            ..lat = 0.123456
            ..lng = 1.12356,
        ),
        appManager: appManager,
      ));

      expect(find.text("Feb 1, 2020"), findsOneWidget);
      expect(find.text("10:30 AM"), findsOneWidget);
      expect(find.text("Species"), findsOneWidget);
      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.text("Bait"), findsOneWidget);
      expect(find.text("Not Selected"), findsOneWidget);
      expect(find.byType(StaticFishingSpot), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets("Saving", (tester) async {
      var speciesId = randomId();
      var fishingSpotId = randomId();
      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage(
          species: Species()
            ..id = speciesId
            ..name = "Steelhead",
          fishingSpot: FishingSpot()
            ..id = fishingSpotId
            ..lat = 0.123456
            ..lng = 1.12356,
        ),
        appManager: appManager,
      ));

      await tapAndSettle(tester, find.text("SAVE"));

      var result = verify(
        appManager.mockCatchManager.addOrUpdate(
          captureAny,
          fishingSpot: anyNamed("fishingSpot"),
          imageFiles: anyNamed("imageFiles"),
        ),
      );
      result.called(1);

      Catch cat = result.captured.first;
      expect(cat, isNotNull);
      expect(
          cat.timestamp, Timestamp.fromDateTime(DateTime(2020, 2, 1, 10, 30)));
      expect(cat.speciesId, speciesId);
      expect(cat.fishingSpotId, fishingSpotId);
      expect(cat.hasBaitId(), false);
      expect(cat.imageNames, isEmpty);
      expect(cat.customEntityValues, isEmpty);
    });
  });

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveCatchPage(
        species: Species()
          ..id = randomId()
          ..name = "Steelhead",
        fishingSpot: FishingSpot()
          ..id = randomId()
          ..lat = 0.123456
          ..lng = 1.12356,
      ),
      appManager: appManager,
    ));

    expect(find.text("New Catch"), findsOneWidget);
  });

  testWidgets("Edit title", (tester) async {
    var cat = Catch()
      ..id = randomId()
      ..timestamp = Timestamp.fromDateTime(DateTime(2020, 1, 1, 15, 30))
      ..speciesId = randomId();

    await tester.pumpWidget(Testable(
      (_) => SaveCatchPage.edit(cat),
      appManager: appManager,
    ));

    expect(find.text("Edit Catch"), findsOneWidget);
  });

  testWidgets("Only show fields saved in preferences", (tester) async {
    when(appManager.mockPreferencesManager.catchFieldIds).thenReturn([
      catchFieldIdTimestamp(),
      catchFieldIdSpecies(),
      catchFieldIdBait(),
    ]);

    await tester.pumpWidget(Testable(
      (_) => SaveCatchPage(
        species: Species()
          ..id = randomId()
          ..name = "Steelhead",
        fishingSpot: FishingSpot()
          ..id = randomId()
          ..lat = 0.123456
          ..lng = 1.12356,
      ),
      appManager: appManager,
    ));

    expect(find.text("Date"), findsOneWidget);
    expect(find.text("Time"), findsOneWidget);
    expect(find.text("Species"), findsOneWidget);
    expect(find.byType(StaticFishingSpot), findsNothing);
    expect(find.byType(ImageInput), findsNothing);
  });
}
