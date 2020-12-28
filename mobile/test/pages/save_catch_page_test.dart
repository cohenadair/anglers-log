import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/gen/google/protobuf/timestamp.pb.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/pages/save_catch_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/image_input.dart';
import 'package:mobile/widgets/static_fishing_spot.dart';
import 'package:mobile/widgets/text_input.dart';
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
      mockDataManager: true,
      mockFishingSpotManager: true,
      mockImageManager: true,
      mockLocationMonitor: true,
      mockPreferencesManager: true,
      mockSpeciesManager: true,
      mockTimeManager: true,
    );

    when(appManager.mockBaitCategoryManager.listSortedByName()).thenReturn([]);

    when(appManager.mockDataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.mockPreferencesManager.baitCustomEntityIds).thenReturn([]);
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
        ),
        appManager: appManager,
      ));

      expect(find.text("Feb 1, 2020"), findsOneWidget);
      expect(find.text("10:30 AM"), findsOneWidget);
    });

    testWidgets("All journey fields set correctly", (tester) async {
      var species = Species()
        ..id = randomId()
        ..name = "Steelhead";
      when(appManager.mockSpeciesManager.entity(species.id))
          .thenReturn(species);

      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..name = "Spot A";
      when(appManager.mockFishingSpotManager.entity(fishingSpot.id))
          .thenReturn(fishingSpot);

      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage(
          images: [
            PickedImage(
              originalFile: File("test/resources/flutter_logo.png"),
              dateTime: DateTime(2020, 1, 1, 15, 30),
            ),
          ],
          speciesId: species.id,
          fishingSpotId: fishingSpot.id,
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
          speciesId: randomId(),
          fishingSpotId: randomId(),
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
          imageFiles: anyNamed("imageFiles"),
        ),
      );
      result.called(1);
      expect(result.captured.first, cat);
    });
  });

  group("New", () {
    testWidgets("All fields default correctly", (tester) async {
      var species = Species()
        ..id = randomId()
        ..name = "Steelhead";
      when(appManager.mockSpeciesManager.entity(species.id))
          .thenReturn(species);

      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..name = "Spot A";
      when(appManager.mockFishingSpotManager.entity(fishingSpot.id))
          .thenReturn(fishingSpot);

      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage(
          speciesId: species.id,
          fishingSpotId: fishingSpot.id,
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
          speciesId: speciesId,
          fishingSpotId: fishingSpotId,
        ),
        appManager: appManager,
      ));

      await tapAndSettle(tester, find.text("SAVE"));

      var result = verify(
        appManager.mockCatchManager.addOrUpdate(
          captureAny,
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
      (_) => SaveCatchPage(),
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
    var species = Species()
      ..id = randomId()
      ..name = "Steelhead";
    when(appManager.mockSpeciesManager.entity(species.id)).thenReturn(species);
    var fishingSpot = FishingSpot()
      ..id = randomId()
      ..name = "Spot A";
    when(appManager.mockFishingSpotManager.entity(fishingSpot.id))
        .thenReturn(fishingSpot);

    await tester.pumpWidget(Testable(
      (_) => SaveCatchPage(
        speciesId: species.id,
        fishingSpotId: fishingSpot.id,
      ),
      appManager: appManager,
    ));

    expect(find.text("Date"), findsOneWidget);
    expect(find.text("Time"), findsOneWidget);
    expect(find.text("Species"), findsOneWidget);
    expect(find.byType(StaticFishingSpot), findsNothing);
    expect(find.byType(ImageInput), findsNothing);
  });

  /// https://github.com/cohenadair/anglers-log/issues/462
  testWidgets("Updates to selected species updates state", (tester) async {
    var species = Species()
      ..id = randomId()
      ..name = "Bass";

    // Use real SpeciesManager to test listener notifications.
    var speciesManager = SpeciesManager(appManager);
    speciesManager.addOrUpdate(species);
    when(appManager.speciesManager).thenReturn(speciesManager);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage(
          speciesId: species.id,
        ),
        appManager: appManager,
      ),
    );

    expect(find.text("Bass"), findsOneWidget);

    // Edit the selected species.
    await tapAndSettle(tester, find.text("Bass"));
    await tapAndSettle(tester, find.text("EDIT"));
    await tapAndSettle(tester, find.text("Bass"));
    await enterTextAndSettle(tester, find.byType(TextInput), "Bass 2");
    await tapAndSettle(tester, find.text("SAVE"));
    await tapAndSettle(tester, find.byType(BackButtonIcon));

    // Verify new species name is shown.
    expect(find.text("Bass 2"), findsOneWidget);
  });

  /// https://github.com/cohenadair/anglers-log/issues/462
  testWidgets("Updates to selected bait updates state", (tester) async {
    var bait = Bait()
      ..id = randomId()
      ..name = "Minnow";

    // Use real BaitManager to test listener notifications.
    var baitManager = BaitManager(appManager);
    baitManager.addOrUpdate(bait);
    when(appManager.baitManager).thenReturn(baitManager);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage.edit(Catch()
          ..id = randomId()
          ..speciesId = randomId()
          ..baitId = bait.id),
        appManager: appManager,
      ),
    );

    expect(find.text("Minnow"), findsOneWidget);

    // Edit the selected species.
    await tapAndSettle(tester, find.text("Minnow"));
    await tapAndSettle(tester, find.text("EDIT"));
    await tapAndSettle(tester, find.text("Minnow"));
    await enterTextAndSettle(tester, find.byType(TextInput), "Minnow 2");
    await tapAndSettle(tester, find.text("SAVE"));
    await tapAndSettle(tester, find.byType(BackButtonIcon));

    // Verify new species name is shown.
    expect(find.text("Minnow 2"), findsOneWidget);
  });

  /// https://github.com/cohenadair/anglers-log/issues/467
  testWidgets("Updates to selected fishing spot updates state", (tester) async {
    var fishingSpot = FishingSpot()
      ..id = randomId()
      ..name = "A";

    // Use real FishingSpotManager to test listener notifications.
    var fishingSpotManager = FishingSpotManager(appManager);
    fishingSpotManager.addOrUpdate(fishingSpot);
    when(appManager.fishingSpotManager).thenReturn(fishingSpotManager);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage.edit(Catch()
          ..id = randomId()
          ..fishingSpotId = fishingSpot.id),
        appManager: appManager,
      ),
    );

    expect(find.text("A"), findsOneWidget);

    // Edit the selected species.
    await tapAndSettle(tester, find.text("A"));
    await tapAndSettle(tester, find.text("EDIT"));
    await enterTextAndSettle(tester, find.byType(TextInput), "B");
    await tapAndSettle(tester, find.text("SAVE"));
    await tapAndSettle(tester, find.byType(BackButtonIcon));

    // Verify new species name is shown.
    expect(find.text("B"), findsOneWidget);
  });

  testWidgets("Save catch without a fishing spot", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage(
          speciesId: randomId(),
        ),
        appManager: appManager,
      ),
    );
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.mockCatchManager
        .addOrUpdate(captureAny, imageFiles: anyNamed("imageFiles")));
    result.called(1);

    var cat = result.captured.first as Catch;
    expect(cat.hasFishingSpotId(), isFalse);
  });
}
