import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:mobile/angler_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/method_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/pages/save_catch_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/water_clarity_manager.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/date_time_picker.dart';
import 'package:mobile/widgets/image_input.dart';
import 'package:mobile/widgets/image_picker.dart';
import 'package:mobile/widgets/search_bar.dart';
import 'package:mobile/widgets/static_fishing_spot.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.authManager.stream).thenAnswer((_) => Stream.empty());

    when(appManager.baitManager.attachmentsDisplayValues(any, any))
        .thenReturn([]);

    when(appManager.baitCategoryManager.listSortedByName()).thenReturn([]);

    when(appManager.catchManager.addOrUpdate(
      any,
      imageFiles: anyNamed("imageFiles"),
    )).thenAnswer((_) => Future.value(false));

    when(appManager.customEntityManager.list()).thenReturn([]);
    when(appManager.customEntityManager.entityExists(any)).thenReturn(false);

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.locationMonitor.currentLocation).thenReturn(null);

    when(appManager.propertiesManager.visualCrossingApiKey).thenReturn("");

    when(appManager.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.baitVariantCustomIds).thenReturn([]);
    when(appManager.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.catchCustomEntityIds).thenReturn([]);
    when(appManager.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.userPreferenceManager.waterTemperatureSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.userPreferenceManager.catchLengthSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.userPreferenceManager.catchWeightSystem)
        .thenReturn(MeasurementSystem.imperial_whole);
    when(appManager.userPreferenceManager.autoFetchAtmosphere)
        .thenReturn(false);
    when(appManager.userPreferenceManager.airTemperatureSystem)
        .thenReturn(MeasurementSystem.imperial_decimal);
    when(appManager.userPreferenceManager.airVisibilitySystem)
        .thenReturn(MeasurementSystem.imperial_decimal);
    when(appManager.userPreferenceManager.airPressureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.windSpeedSystem)
        .thenReturn(MeasurementSystem.imperial_decimal);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => Stream.empty());

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);
    when(appManager.subscriptionManager.isFree).thenReturn(true);

    appManager.stubCurrentTime(DateTime(2020, 2, 1, 10, 30));
  });

  group("From journey", () {
    testWidgets("Images with date sets Catch date", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage(
          speciesId: randomId(),
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
          speciesId: randomId(),
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
      when(appManager.speciesManager.entity(species.id)).thenReturn(species);

      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..name = "Spot A"
        ..lat = 13
        ..lng = 45;
      when(appManager.fishingSpotManager.entity(fishingSpot.id))
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

      // Wait for images and map futures to finish.
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      await tester.pumpAndSettle(Duration(milliseconds: 150));
      await tester.pumpAndSettle(Duration(milliseconds: 50));

      expect(find.text("Jan 1, 2020"), findsOneWidget);
      expect(find.text("3:30 PM"), findsOneWidget);
      expect(find.text("Winter"), findsOneWidget);
      expect(find.text("No baits"), findsOneWidget);

      // Angler, time of day, tide, and water clarity.
      expect(find.text("Not Selected"), findsNWidgets(4));

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
        ..type = CustomEntity_Type.text;
      when(appManager.customEntityManager.entity(customEntity.id))
          .thenReturn(customEntity);
      when(appManager.userPreferenceManager.catchCustomEntityIds)
          .thenReturn([customEntity.id]);

      var bait = Bait()
        ..id = randomId()
        ..name = "Rapala";
      when(appManager.baitManager.list(any)).thenReturn([bait]);
      when(appManager.baitManager.attachmentsDisplayValues(any, any))
          .thenReturn(["Rapala"]);

      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..name = "Spot A";
      when(appManager.fishingSpotManager.entity(any)).thenReturn(fishingSpot);

      var species = Species()
        ..id = randomId()
        ..name = "Steelhead";
      when(appManager.speciesManager.entity(any)).thenReturn(species);

      var angler = Angler()
        ..id = randomId()
        ..name = "Cohen";
      when(appManager.anglerManager.entity(any)).thenReturn(angler);

      var clarity = WaterClarity()
        ..id = randomId()
        ..name = "Clear";
      when(appManager.waterClarityManager.entity(any)).thenReturn(clarity);

      var method0 = Method()
        ..id = randomId()
        ..name = "Casting";
      var method1 = Method()
        ..id = randomId()
        ..name = "Kayak";
      when(appManager.methodManager.list(any)).thenReturn([method0, method1]);

      var cat = Catch()
        ..id = randomId()
        ..timestamp = Int64(DateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
        ..baits.add(BaitAttachment(baitId: bait.id))
        ..fishingSpotId = fishingSpot.id
        ..speciesId = species.id
        ..anglerId = angler.id
        ..waterClarityId = clarity.id
        ..methodIds.addAll([method0.id, method1.id])
        ..customEntityValues.add(CustomEntityValue()
          ..customEntityId = customEntity.id
          ..value = "Minnow")
        ..imageNames.add("flutter_logo.png")
        ..period = Period.dawn
        ..season = Season.summer
        ..isFavorite = true
        ..wasCatchAndRelease = true
        ..waterDepth = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.feet,
            value: 20,
          ),
        )
        ..waterTemperature = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.fahrenheit,
            value: 75,
          ),
        )
        ..length = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.inches,
            value: 15,
          ),
          fractionValue: Measurement(
            value: 0.25,
          ),
        )
        ..weight = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.pounds,
            value: 10,
          ),
        )
        ..quantity = 3
        ..notes = "Some test notes."
        ..atmosphere = Atmosphere(
          temperature: Measurement(
            unit: Unit.fahrenheit,
            value: 58,
          ),
          skyConditions: [SkyCondition.cloudy],
          windSpeed: Measurement(
            unit: Unit.kilometers_per_hour,
            value: 6.5,
          ),
          windDirection: Direction.north,
          pressure: Measurement(
            unit: Unit.pounds_per_square_inch,
            value: 1000,
          ),
          humidity: Measurement(
            unit: Unit.percent,
            value: 50,
          ),
          visibility: Measurement(
            unit: Unit.miles,
            value: 10,
          ),
          moonPhase: MoonPhase.full,
          sunriseTimestamp: Int64(10000),
          sunsetTimestamp: Int64(15000),
        )
        ..tide = Tide(type: TideType.outgoing);

      when(appManager.imageManager.images(
        any,
        imageNames: anyNamed("imageNames"),
        size: anyNamed("size"),
      )).thenAnswer((_) {
        var file = File("test/resources/flutter_logo.png");
        return Future.value({file: file.readAsBytesSync()});
      });

      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage.edit(cat),
        appManager: appManager,
      ));

      // Wait for images and map futures to finish.
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      await tester.pumpAndSettle(Duration(milliseconds: 150));
      await tester.pumpAndSettle(Duration(milliseconds: 50));

      expect(find.text("Jan 1, 2020"), findsOneWidget);
      expect(find.text("3:30 PM"), findsOneWidget);
      expect(find.text("Dawn"), findsOneWidget);
      expect(find.text("Summer"), findsOneWidget);
      expect(find.text("Casting"), findsOneWidget);
      expect(find.text("Kayak"), findsOneWidget);
      expect(find.text("Rapala"), findsOneWidget);
      expect(find.byType(StaticFishingSpot), findsOneWidget);
      expect(find.text("Species"), findsOneWidget);
      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.text("Angler"), findsOneWidget);
      expect(find.text("Cohen"), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.text("Color"), findsOneWidget);
      expect(find.text("Minnow"), findsOneWidget);
      expect(findCheckbox(tester, "Favorite")!.checked, isTrue);
      expect(findCheckbox(tester, "Catch and Release")!.checked, isTrue);
      expect(find.text("Clear"), findsOneWidget);
      expect(find.text("20"), findsOneWidget);
      expect(find.text("75"), findsOneWidget);
      expect(find.text("15"), findsOneWidget);
      expect(find.text("10"), findsOneWidget);
      expect(find.text("3"), findsOneWidget);
      expect(find.text("Cloudy"), findsOneWidget);
      expect(find.text("58\u00B0F"), findsOneWidget);
      expect(find.text("6.5 km/h"), findsOneWidget);
      expect(find.text("N"), findsOneWidget);
      expect(find.text("1000 psi"), findsOneWidget);
      expect(find.text("10 mi"), findsOneWidget);
      expect(find.text("50%"), findsOneWidget);
      expect(find.text("Sunrise"), findsOneWidget);
      expect(find.text("Sunset"), findsOneWidget);
      expect(find.text("Full"), findsOneWidget);
      expect(find.text("Moon"), findsOneWidget);
      expect(find.text("Outgoing"), findsOneWidget);
    });

    testWidgets("Minimum fields set correctly", (tester) async {
      var species = Species()
        ..id = randomId()
        ..name = "Steelhead";
      when(appManager.speciesManager.entity(any)).thenReturn(species);

      var cat = Catch()
        ..id = randomId()
        ..timestamp = Int64(DateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
        ..speciesId = species.id;

      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage.edit(cat),
        appManager: appManager,
      ));

      expect(find.text("Jan 1, 2020"), findsOneWidget);
      expect(find.text("3:30 PM"), findsOneWidget);
      expect(find.text("Species"), findsOneWidget);
      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.text("No baits"), findsOneWidget);

      // Angler, time of day, season, tide, and water clarity.
      expect(find.text("Not Selected"), findsNWidgets(5));

      // Fishing methods.
      expect(find.text("No fishing methods"), findsOneWidget);

      expect(find.text("Fishing Spot"), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(find.byType(StaticFishingSpot), findsNothing);
      expect(findCheckbox(tester, "Favorite")!.checked, isFalse);
      expect(findCheckbox(tester, "Catch and Release")!.checked, isFalse);
      expect(find.text("Atmosphere & Weather"), findsOneWidget);

      expect(
        findFirstWithText<TextInput>(tester, "Water Depth").controller?.value,
        isNull,
      );
      expect(
        findFirstWithText<TextInput>(tester, "Water Temperature")
            .controller
            ?.value,
        isNull,
      );
      expect(
        findFirstWithText<TextInput>(tester, "Length").controller?.value,
        isNull,
      );
      expect(
        findFirstWithText<TextInput>(tester, "Weight").controller?.value,
        isNull,
      );
      expect(
        findFirstWithText<TextInput>(tester, "Quantity").controller?.value,
        isNull,
      );
      expect(
        findFirstWithText<TextInput>(tester, "Notes").controller?.value,
        isNull,
      );

      var image = tester.widget<ImageInput>(find.byType(ImageInput));
      expect(image.initialImageNames, isEmpty);
    });

    testWidgets("Saving", (tester) async {
      var customEntity = CustomEntity()
        ..id = randomId()
        ..name = "Color"
        ..type = CustomEntity_Type.text;
      when(appManager.customEntityManager.entity(customEntity.id))
          .thenReturn(customEntity);
      when(appManager.userPreferenceManager.catchCustomEntityIds)
          .thenReturn([customEntity.id]);

      var bait = Bait()
        ..id = randomId()
        ..name = "Rapala";
      when(appManager.baitManager.entity(any)).thenReturn(bait);
      when(appManager.baitManager.formatNameWithCategory(any))
          .thenReturn("Rapala");

      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..name = "Spot A";
      when(appManager.fishingSpotManager.entity(any)).thenReturn(fishingSpot);

      var species = Species()
        ..id = randomId()
        ..name = "Steelhead";
      when(appManager.speciesManager.entity(any)).thenReturn(species);

      var angler = Angler()
        ..id = randomId()
        ..name = "Cohen";
      when(appManager.anglerManager.entity(any)).thenReturn(angler);

      var clarity = WaterClarity()
        ..id = randomId()
        ..name = "Clear";
      when(appManager.waterClarityManager.entity(any)).thenReturn(clarity);

      var method0 = Method()
        ..id = randomId()
        ..name = "Casting";
      var method1 = Method()
        ..id = randomId()
        ..name = "Kayak";
      when(appManager.methodManager.list(any)).thenReturn([method0, method1]);

      var cat = Catch()
        ..id = randomId()
        ..timestamp = Int64(DateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
        ..baits.add(BaitAttachment(baitId: bait.id))
        ..fishingSpotId = fishingSpot.id
        ..speciesId = species.id
        ..anglerId = angler.id
        ..waterClarityId = clarity.id
        ..methodIds.addAll([method0.id, method1.id])
        ..customEntityValues.add(CustomEntityValue()
          ..customEntityId = customEntity.id
          ..value = "Minnow")
        ..imageNames.add("flutter_logo.png")
        ..period = Period.afternoon
        ..season = Season.summer
        ..isFavorite = true
        ..wasCatchAndRelease = true
        ..waterDepth = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.feet,
            value: 20,
          ),
        )
        ..waterTemperature = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.fahrenheit,
            value: 75,
          ),
        )
        ..length = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.inches,
            value: 15,
          ),
          fractionValue: Measurement(
            value: 0.25,
          ),
        )
        ..weight = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(
            unit: Unit.pounds,
            value: 10,
          ),
        )
        ..quantity = 3
        ..notes = "Some test notes."
        ..atmosphere = Atmosphere(
          temperature: Measurement(
            unit: Unit.fahrenheit,
            value: 58,
          ),
          skyConditions: [SkyCondition.cloudy],
          windSpeed: Measurement(
            unit: Unit.kilometers_per_hour,
            value: 6.5,
          ),
          windDirection: Direction.north,
          pressure: Measurement(
            unit: Unit.pounds_per_square_inch,
            value: 1000,
          ),
          humidity: Measurement(
            unit: Unit.percent,
            value: 50,
          ),
          visibility: Measurement(
            unit: Unit.miles,
            value: 10,
          ),
          moonPhase: MoonPhase.full,
          sunriseTimestamp: Int64(10000),
          sunsetTimestamp: Int64(15000),
        )
        ..tide = Tide(type: TideType.outgoing);

      when(appManager.imageManager.images(
        any,
        imageNames: anyNamed("imageNames"),
        size: anyNamed("size"),
      )).thenAnswer((_) {
        var file = File("test/resources/flutter_logo.png");
        return Future.value({file: file.readAsBytesSync()});
      });

      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage.edit(cat),
        appManager: appManager,
      ));

      // Add small delay so images future can finish.
      await tester.pumpAndSettle(Duration(milliseconds: 100));

      when(appManager.catchManager.addOrUpdate(
        captureAny,
        imageFiles: anyNamed("imageFiles"),
      )).thenAnswer((invocation) {
        // Assume image is saved correctly.
        invocation.positionalArguments.first.imageNames.add("flutter_logo.png");
        return Future.value(true);
      });
      await tapAndSettle(tester, find.text("SAVE"));

      var result = verify(
        appManager.catchManager.addOrUpdate(
          captureAny,
          imageFiles: anyNamed("imageFiles"),
        ),
      );
      result.called(1);
      expect(result.captured.first, cat);
    });

    /// https://github.com/cohenadair/anglers-log/issues/517
    testWidgets("Image is kept while editing", (tester) async {
      when(appManager.imageManager.images(
        any,
        imageNames: anyNamed("imageNames"),
        size: anyNamed("size"),
      )).thenAnswer((_) {
        var file = File("test/resources/flutter_logo.png");
        return Future.value({file: file.readAsBytesSync()});
      });

      var species = Species()
        ..id = randomId()
        ..name = "Steelhead";
      when(appManager.speciesManager.entity(any)).thenReturn(species);

      var cat = Catch()
        ..id = randomId()
        ..timestamp = Int64(DateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
        ..speciesId = species.id
        ..imageNames.add("flutter_logo.png");

      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage.edit(cat),
        appManager: appManager,
      ));

      // Wait for image future to finish.
      await tester.pumpAndSettle(Duration(milliseconds: 50));
      expect(find.byType(Image), findsOneWidget);

      await tapAndSettle(tester, find.text("SAVE"));

      var result = verify(appManager.catchManager
          .addOrUpdate(any, imageFiles: captureAnyNamed("imageFiles")));
      result.called(1);

      // Verify the old image is still passed into the addOrUpdate method.
      expect(result.captured.first.length, 1);
      expect(basename(result.captured.first.first.path), "flutter_logo.png");
    });
  });

  group("New", () {
    testWidgets("All fields default correctly", (tester) async {
      var species = Species()
        ..id = randomId()
        ..name = "Steelhead";
      when(appManager.speciesManager.entity(species.id)).thenReturn(species);

      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..name = "Spot A"
        ..lat = 13
        ..lng = 45;
      when(appManager.fishingSpotManager.entity(fishingSpot.id))
          .thenReturn(fishingSpot);

      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage(
          speciesId: species.id,
          fishingSpotId: fishingSpot.id,
        ),
        appManager: appManager,
      ));

      // Wait for images and map futures to finish.
      await tester.pumpAndSettle(Duration(milliseconds: 100));
      await tester.pumpAndSettle(Duration(milliseconds: 150));
      await tester.pumpAndSettle(Duration(milliseconds: 50));

      expect(find.text("Feb 1, 2020"), findsOneWidget);
      expect(find.text("10:30 AM"), findsOneWidget);
      expect(find.text("Species"), findsOneWidget);
      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.text("No baits"), findsOneWidget);
      expect(find.text("Winter"), findsOneWidget);

      // Angler, time of day, tide, and water clarity.
      expect(find.text("Not Selected"), findsNWidgets(4));

      // Fishing methods.
      expect(find.text("No fishing methods"), findsOneWidget);

      expect(find.byType(StaticFishingSpot), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(findCheckbox(tester, "Favorite")!.checked, isFalse);
      expect(findCheckbox(tester, "Catch and Release")!.checked, isFalse);
      expect(find.text("Atmosphere & Weather"), findsOneWidget);

      expect(
        findFirstWithText<TextInput>(tester, "Water Depth").controller?.value,
        isNull,
      );
      expect(
        findFirstWithText<TextInput>(tester, "Water Temperature")
            .controller
            ?.value,
        isNull,
      );
      expect(
        findFirstWithText<TextInput>(tester, "Length").controller?.value,
        isNull,
      );
      expect(
        findFirstWithText<TextInput>(tester, "Weight").controller?.value,
        isNull,
      );
      expect(
        findFirstWithText<TextInput>(tester, "Quantity").controller?.value,
        isNull,
      );
      expect(
        findFirstWithText<TextInput>(tester, "Notes").controller?.value,
        isNull,
      );
    });

    testWidgets("Saving when selecting no optional fields", (tester) async {
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
        appManager.catchManager.addOrUpdate(
          captureAny,
          imageFiles: anyNamed("imageFiles"),
        ),
      );
      result.called(1);

      Catch cat = result.captured.first;
      expect(cat, isNotNull);
      expect(cat.timestamp.toInt(),
          DateTime(2020, 2, 1, 10, 30).millisecondsSinceEpoch);
      expect(cat.speciesId, speciesId);
      expect(cat.fishingSpotId, fishingSpotId);
      expect(cat.baits, isEmpty);
      expect(cat.hasAnglerId(), isFalse);
      expect(cat.hasWaterClarityId(), isFalse);
      expect(cat.methodIds, isEmpty);
      expect(cat.imageNames, isEmpty);
      expect(cat.customEntityValues, isEmpty);
      expect(cat.hasPeriod(), isFalse);
      expect(cat.hasSeason(), isFalse);
      expect(cat.hasIsFavorite(), isFalse);
      expect(cat.hasWasCatchAndRelease(), isTrue);
      expect(cat.wasCatchAndRelease, isFalse);
      expect(cat.hasWaterDepth(), isFalse);
      expect(cat.hasWaterTemperature(), isFalse);
      expect(cat.hasLength(), isFalse);
      expect(cat.hasWeight(), isFalse);
      expect(cat.hasQuantity(), isFalse);
      expect(cat.hasNotes(), isFalse);
      expect(cat.hasAtmosphere(), isFalse);
      expect(cat.hasTide(), isFalse);
    });

    testWidgets("Saving after selecting all optional fields", (tester) async {
      when(appManager.anglerManager
              .listSortedByName(filter: anyNamed("filter")))
          .thenReturn([
        Angler()
          ..id = randomId()
          ..name = "Cohen",
      ]);

      var bait = Bait()
        ..id = randomId()
        ..name = "Rapala";
      when(appManager.baitManager.attachmentList()).thenReturn([
        BaitAttachment(baitId: bait.id),
      ]);
      when(appManager.baitManager.filteredList(any)).thenReturn([bait]);
      when(appManager.baitManager.attachmentsDisplayValues(any, any))
          .thenReturn([]);
      when(appManager.baitManager.variantFromAttachment(any))
          .thenReturn(BaitVariant(id: randomId(), baseId: bait.id));
      when(appManager.baitManager.numberOfCatches(any)).thenReturn(0);

      when(appManager.waterClarityManager
              .listSortedByName(filter: anyNamed("filter")))
          .thenReturn([
        WaterClarity()
          ..id = randomId()
          ..name = "Clear",
      ]);

      var methods = [
        Method()
          ..id = randomId()
          ..name = "Casting",
        Method()
          ..id = randomId()
          ..name = "Kayak",
      ];
      when(appManager.methodManager
              .listSortedByName(filter: anyNamed("filter")))
          .thenReturn(methods);
      when(appManager.methodManager.list(any)).thenReturn(methods);

      var speciesId = randomId();
      var fishingSpotId = randomId();
      await tester.pumpWidget(Testable(
        (_) => SaveCatchPage(
          speciesId: speciesId,
          fishingSpotId: fishingSpotId,
        ),
        appManager: appManager,
      ));

      // Select period.
      await tapAndSettle(tester, find.text("Time Of Day"));
      await tapAndSettle(tester, find.text("Afternoon"));

      // Select season.
      await tapAndSettle(tester, find.text("Season"));
      await tapAndSettle(tester, find.text("Summer"));

      // Select bait.
      await tapAndSettle(tester, find.text("No baits"));
      await tapAndSettle(
          tester, findManageableListItemCheckbox(tester, "Rapala"));
      await tapAndSettle(tester, find.byType(BackButton));

      // Select angler.
      await tapAndSettle(tester, find.text("Angler"));
      await tapAndSettle(tester, find.text("Cohen"));

      // Select water clarity.
      await tester.ensureVisible(find.text("Water Clarity"));
      await tapAndSettle(tester, find.text("Water Clarity"));
      await tapAndSettle(tester, find.text("Clear"));

      // Select fishing methods.
      await tester.ensureVisible(find.text("No fishing methods"));
      await tapAndSettle(tester, find.text("No fishing methods"));
      await tapAndSettle(
          tester, findManageableListItemCheckbox(tester, "Casting"));
      await tapAndSettle(
          tester, findManageableListItemCheckbox(tester, "Kayak"));
      await tapAndSettle(tester, find.byType(BackButton));

      // Set favorite.
      await tester.ensureVisible(find.text("Favorite"));
      await tapAndSettle(tester, findListItemCheckbox(tester, "Favorite"));

      // Set catch and release.
      await tester.ensureVisible(find.text("Catch and Release"));
      await tapAndSettle(
          tester, findListItemCheckbox(tester, "Catch and Release"));

      // Set atmosphere.
      await tester.ensureVisible(find.text("Atmosphere & Weather"));
      await tapAndSettle(tester, find.text("Atmosphere & Weather"));
      await enterTextAndSettle(
          tester, find.widgetWithText(TextField, "Air Temperature"), "58");
      await tapAndSettle(tester, find.byType(BackButtonIcon));

      // Tide.
      await tester.ensureVisible(find.text("Tide"));
      await tapAndSettle(tester, find.text("Tide"));
      await tapAndSettle(tester, find.text("Outgoing"));
      await tapAndSettle(tester, find.byType(BackButtonIcon));

      await tapAndSettle(tester, find.text("SAVE"));

      var result = verify(
        appManager.catchManager.addOrUpdate(
          captureAny,
          imageFiles: anyNamed("imageFiles"),
        ),
      );
      result.called(1);

      Catch cat = result.captured.first;
      expect(cat, isNotNull);
      expect(cat.timestamp.toInt(),
          DateTime(2020, 2, 1, 10, 30).millisecondsSinceEpoch);
      expect(cat.speciesId, speciesId);
      expect(cat.fishingSpotId, fishingSpotId);
      expect(cat.imageNames, isEmpty);
      expect(cat.customEntityValues, isEmpty);
      expect(cat.baits, isNotEmpty);
      expect(cat.hasAnglerId(), isTrue);
      expect(cat.hasWaterClarityId(), isTrue);
      expect(cat.methodIds.length, 2);
      expect(cat.hasPeriod(), isTrue);
      expect(cat.period, Period.afternoon);
      expect(cat.hasSeason(), isTrue);
      expect(cat.season, Season.summer);
      expect(cat.isFavorite, isTrue);
      expect(cat.wasCatchAndRelease, isTrue);
      expect(cat.hasAtmosphere(), isTrue);
      expect(cat.atmosphere.temperature.value, 58);
      expect(cat.hasTide(), isTrue);
      expect(cat.tide.type, TideType.outgoing);
    });
  });

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => SaveCatchPage(
        speciesId: randomId(),
      ),
      appManager: appManager,
    ));

    expect(find.text("New Catch"), findsOneWidget);
  });

  testWidgets("Edit title", (tester) async {
    var cat = Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
      ..speciesId = randomId();

    await tester.pumpWidget(Testable(
      (_) => SaveCatchPage.edit(cat),
      appManager: appManager,
    ));

    expect(find.text("Edit Catch"), findsOneWidget);
  });

  testWidgets("Only show fields saved in preferences", (tester) async {
    when(appManager.userPreferenceManager.catchFieldIds).thenReturn([
      catchFieldIdTimestamp,
      catchFieldIdSpecies,
      catchFieldIdBait,
    ]);
    var species = Species()
      ..id = randomId()
      ..name = "Steelhead";
    when(appManager.speciesManager.entity(species.id)).thenReturn(species);
    var fishingSpot = FishingSpot()
      ..id = randomId()
      ..name = "Spot A";
    when(appManager.fishingSpotManager.entity(fishingSpot.id))
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
    expect(find.byType(ImagePicker), findsNothing);
  });

  /// https://github.com/cohenadair/anglers-log/issues/462
  testWidgets("Updates to selected species updates state", (tester) async {
    var species = Species()
      ..id = randomId()
      ..name = "Bass";

    // Use real SpeciesManager to test listener notifications.
    var speciesManager = SpeciesManager(appManager.app);
    speciesManager.addOrUpdate(species);
    when(appManager.app.speciesManager).thenReturn(speciesManager);

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
    await tapAndSettle(tester, find.widgetWithText(ActionButton, "EDIT"));
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
    var baitManager = BaitManager(appManager.app);
    baitManager.addOrUpdate(bait);
    when(appManager.app.baitManager).thenReturn(baitManager);

    when(appManager.catchManager.list()).thenReturn([]);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage.edit(Catch()
          ..id = randomId()
          ..speciesId = randomId()
          ..baits.add(BaitAttachment(baitId: bait.id))),
        appManager: appManager,
      ),
    );

    expect(find.text("Minnow"), findsOneWidget);

    // Edit the selected bait.
    await tapAndSettle(tester, find.text("Minnow"));
    await tapAndSettle(tester, find.widgetWithText(ActionButton, "EDIT"));
    await tapAndSettle(tester, find.text("Minnow"));
    await enterTextAndSettle(tester, find.byType(TextInput), "Minnow 2");
    await tapAndSettle(tester, find.text("SAVE"));
    await tapAndSettle(tester, find.byType(BackButtonIcon));

    // Verify new name is shown.
    expect(find.text("Minnow 2"), findsOneWidget);
  });

  /// https://github.com/cohenadair/anglers-log/issues/467
  testWidgets("Updates to selected fishing spot updates state", (tester) async {
    var fishingSpot = FishingSpot()
      ..id = randomId()
      ..name = "A";

    // Use real FishingSpotManager to test listener notifications.
    var fishingSpotManager = FishingSpotManager(appManager.app);
    fishingSpotManager.addOrUpdate(fishingSpot);
    when(appManager.app.fishingSpotManager).thenReturn(fishingSpotManager);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage.edit(Catch()
          ..id = randomId()
          ..fishingSpotId = fishingSpot.id),
        appManager: appManager,
      ),
    );

    expect(find.text("A"), findsOneWidget);

    // Edit the selected fishing spot.
    await tapAndSettle(tester, find.text("A"));
    await tapAndSettle(tester, find.widgetWithText(ActionButton, "EDIT"));
    await enterTextAndSettle(tester, find.byType(TextInput), "B");
    await tapAndSettle(tester, find.text("SAVE"));
    await tapAndSettle(tester, find.byType(BackButtonIcon));

    // Verify new name is shown.
    expect(find.text("B"), findsOneWidget);
  });

  /// https://github.com/cohenadair/anglers-log/issues/467
  testWidgets("Updates to selected angler updates state", (tester) async {
    var angler = Angler()
      ..id = randomId()
      ..name = "Cohen";

    // Use real AnglerManager to test listener notifications.
    var anglerManager = AnglerManager(appManager.app);
    anglerManager.addOrUpdate(angler);
    when(appManager.app.anglerManager).thenReturn(anglerManager);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage.edit(Catch()
          ..id = randomId()
          ..anglerId = angler.id),
        appManager: appManager,
      ),
    );

    expect(find.text("Cohen"), findsOneWidget);

    // Edit the selected angler.
    await tapAndSettle(tester, find.text("Cohen"));
    await tapAndSettle(tester, find.widgetWithText(ActionButton, "EDIT"));
    await tapAndSettle(tester, find.text("Cohen"));
    await enterTextAndSettle(tester, find.byType(TextInput), "Someone");
    await tapAndSettle(tester, find.text("SAVE"));
    await tapAndSettle(tester, find.byType(BackButtonIcon));

    // Verify new name is shown.
    expect(find.text("Someone"), findsOneWidget);
  });

  /// https://github.com/cohenadair/anglers-log/issues/467
  testWidgets("Updates to selected water clarity updates state",
      (tester) async {
    var clarity = WaterClarity()
      ..id = randomId()
      ..name = "Clear";

    // Use real AnglerManager to test listener notifications.
    var clarityManager = WaterClarityManager(appManager.app);
    clarityManager.addOrUpdate(clarity);
    when(appManager.app.waterClarityManager).thenReturn(clarityManager);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage.edit(Catch()
          ..id = randomId()
          ..waterClarityId = clarity.id),
        appManager: appManager,
      ),
    );

    expect(find.text("Clear"), findsOneWidget);

    // Edit the selected water clarity.
    await tester.ensureVisible(find.text("Clear"));
    await tapAndSettle(tester, find.text("Clear"));
    await tapAndSettle(tester, find.widgetWithText(ActionButton, "EDIT"));
    await tapAndSettle(tester, find.text("Clear"));
    await enterTextAndSettle(tester, find.byType(TextInput), "Stained");
    await tapAndSettle(tester, find.text("SAVE"));
    await tapAndSettle(tester, find.byType(BackButtonIcon));

    // Verify new name is shown.
    expect(find.text("Stained"), findsOneWidget);
  });

  /// https://github.com/cohenadair/anglers-log/issues/467
  testWidgets("Updates to selected fishing methods updates state",
      (tester) async {
    var method = Method()
      ..id = randomId()
      ..name = "Casting";

    // Use real AnglerManager to test listener notifications.
    var methodManager = MethodManager(appManager.app);
    methodManager.addOrUpdate(method);
    when(appManager.app.methodManager).thenReturn(methodManager);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage.edit(Catch()
          ..id = randomId()
          ..methodIds.add(method.id)),
        appManager: appManager,
      ),
    );

    expect(find.text("Casting"), findsOneWidget);

    // Edit the selected angler.
    await tester.ensureVisible(find.text("Casting"));
    await tapAndSettle(tester, find.text("Casting"));
    await tapAndSettle(tester, find.widgetWithText(ActionButton, "EDIT"));
    await tapAndSettle(tester, find.text("Casting"));
    await enterTextAndSettle(tester, find.byType(TextInput), "Casting 2");
    await tapAndSettle(tester, find.text("SAVE"));
    await tapAndSettle(tester, find.byType(BackButtonIcon));

    // Verify new name is shown.
    expect(find.text("Casting 2"), findsOneWidget);
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

    var result = verify(appManager.catchManager
        .addOrUpdate(captureAny, imageFiles: anyNamed("imageFiles")));
    result.called(1);

    var cat = result.captured.first as Catch;
    expect(cat.hasFishingSpotId(), isFalse);
  });

  testWidgets("Hidden catch and release doesn't set property", (tester) async {
    await tester.pumpWidget(
      Testable(
        (context) {
          var ids = allCatchFields(context).map<Id>((e) => e.id).toList()
            ..removeWhere((id) => id == catchFieldIdCatchAndRelease);
          when(appManager.userPreferenceManager.catchFieldIds).thenReturn(ids);

          return SaveCatchPage(
            speciesId: randomId(),
          );
        },
        appManager: appManager,
      ),
    );
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(appManager.catchManager
        .addOrUpdate(captureAny, imageFiles: anyNamed("imageFiles")));
    result.called(1);

    var cat = result.captured.first as Catch;
    expect(cat.hasWasCatchAndRelease(), isFalse);
  });

  testWidgets("Season updates when date changes", (tester) async {
    var species = Species()
      ..id = randomId()
      ..name = "Steelhead";
    when(appManager.speciesManager.entity(species.id)).thenReturn(species);

    var fishingSpot = FishingSpot()
      ..id = randomId()
      ..name = "Spot A"
      ..lat = 13
      ..lng = 45;
    when(appManager.fishingSpotManager.entity(fishingSpot.id))
        .thenReturn(fishingSpot);

    await tester.pumpWidget(Testable(
      (_) => SaveCatchPage(
        speciesId: species.id,
        fishingSpotId: fishingSpot.id,
      ),
      appManager: appManager,
    ));

    expect(find.text("Feb 1, 2020"), findsOneWidget);
    expect(find.text("Winter"), findsOneWidget);

    await tapAndSettle(tester, find.text("Date"));
    await tapAndSettle(tester, find.byIcon(Icons.edit));
    await enterTextAndSettle(
        tester, find.widgetWithText(TextField, "02/01/2020"), "03/01/2020");
    await tapAndSettle(tester, find.text("OK"));

    expect(find.text("Spring"), findsOneWidget);
  });

  testWidgets("Season updates when fishing spot changes", (tester) async {
    var species = Species()
      ..id = randomId()
      ..name = "Steelhead";
    when(appManager.speciesManager.entity(species.id)).thenReturn(species);

    var fishingSpot1 = FishingSpot()
      ..id = randomId()
      ..name = "Spot A"
      ..lat = 13
      ..lng = 45;
    when(appManager.fishingSpotManager.entity(fishingSpot1.id))
        .thenReturn(fishingSpot1);

    var fishingSpot2 = FishingSpot()
      ..id = randomId()
      ..name = "Spot B"
      ..lat = -13
      ..lng = 45;
    when(appManager.fishingSpotManager.entity(fishingSpot2.id))
        .thenReturn(fishingSpot2);
    when(appManager.fishingSpotManager.list())
        .thenReturn([fishingSpot1, fishingSpot2]);
    when(appManager.fishingSpotManager.listSortedByName())
        .thenReturn([fishingSpot1, fishingSpot2]);
    when(appManager.fishingSpotManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(Testable(
      (_) => SaveCatchPage(
        speciesId: species.id,
        fishingSpotId: fishingSpot1.id,
      ),
      appManager: appManager,
    ));

    expect(find.text("Feb 1, 2020"), findsOneWidget);
    expect(find.text("Winter"), findsOneWidget);

    await tapAndSettle(
      tester,
      find.text("Lat: 13.000000, Lng: 45.000000"),
    );
    await tapAndSettle(tester, find.byType(SearchBar));
    await tapAndSettle(tester, find.text("Spot B"));
    await tapAndSettle(tester, find.byType(BackButton));

    expect(find.text("Summer"), findsOneWidget);
  });

  testWidgets("Atmosphere automatically fetched for new catches",
      (tester) async {
    when(appManager.subscriptionManager.isFree).thenReturn(false);
    when(appManager.userPreferenceManager.autoFetchAtmosphere).thenReturn(true);
    when(appManager.locationMonitor.currentLocation).thenReturn(LatLng(0, 0));
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(Response("", HttpStatus.ok)));

    await tester.pumpWidget(Testable(
      (_) => SaveCatchPage(
        speciesId: randomId(),
      ),
      appManager: appManager,
    ));

    verify(appManager.httpWrapper.get(any)).called(1);
  });

  testWidgets("Atmosphere automatically fetched after changing date and time",
      (tester) async {
    when(appManager.timeManager.currentDateTime)
        .thenReturn(DateTime(2020, 1, 1, 15, 30));
    when(appManager.subscriptionManager.isFree).thenReturn(false);
    when(appManager.userPreferenceManager.autoFetchAtmosphere).thenReturn(true);
    when(appManager.locationMonitor.currentLocation).thenReturn(LatLng(0, 0));
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(Response("", HttpStatus.ok)));

    await tester.pumpWidget(Testable(
      (_) => SaveCatchPage(
        speciesId: randomId(),
      ),
      appManager: appManager,
    ));

    // Select a different date.
    await tapAndSettle(tester, find.byType(DatePicker));
    await tapAndSettle(tester, find.text("2"));
    await tapAndSettle(tester, find.text("OK"));

    // Select a different time.
    await tapAndSettle(tester, find.byType(TimePicker));
    var center = tester
        .getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
    await tester.tapAt(Offset(center.dx - 10, center.dy));
    await tapAndSettle(tester, find.text("OK"));

    // Once on load, once when the date is changed, once when the time is
    // changed.
    verify(appManager.httpWrapper.get(any)).called(3);
  });

  testWidgets("Atmosphere not fetched for free users", (tester) async {
    when(appManager.subscriptionManager.isFree).thenReturn(true);
    when(appManager.userPreferenceManager.autoFetchAtmosphere).thenReturn(true);
    when(appManager.locationMonitor.currentLocation).thenReturn(LatLng(0, 0));
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(Response("", HttpStatus.ok)));

    await tester.pumpWidget(Testable(
      (_) => SaveCatchPage(
        speciesId: randomId(),
      ),
      appManager: appManager,
    ));

    verifyNever(appManager.httpWrapper.get(any));
  });

  testWidgets("Atmosphere not fetched if not tracking", (tester) async {
    when(appManager.subscriptionManager.isFree).thenReturn(false);
    when(appManager.userPreferenceManager.autoFetchAtmosphere).thenReturn(true);
    when(appManager.locationMonitor.currentLocation).thenReturn(LatLng(0, 0));
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(Response("", HttpStatus.ok)));

    await tester.pumpWidget(Testable(
      (context) {
        when(appManager.userPreferenceManager.catchFieldIds).thenReturn(
            allCatchFields(context).map((e) => e.id).toList()
              ..remove(catchFieldIdAtmosphere));

        return SaveCatchPage(
          speciesId: randomId(),
        );
      },
      appManager: appManager,
    ));

    verifyNever(appManager.httpWrapper.get(any));
  });

  testWidgets("Atmosphere not fetched if not in preferences", (tester) async {
    when(appManager.subscriptionManager.isFree).thenReturn(false);
    when(appManager.userPreferenceManager.autoFetchAtmosphere)
        .thenReturn(false);
    when(appManager.locationMonitor.currentLocation).thenReturn(LatLng(0, 0));
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(Response("", HttpStatus.ok)));

    await tester.pumpWidget(Testable(
      (_) => SaveCatchPage(
        speciesId: randomId(),
      ),
      appManager: appManager,
    ));

    verifyNever(appManager.httpWrapper.get(any));
  });

  testWidgets("Updating units updates widgets", (tester) async {
    when(appManager.localDatabaseManager.fetchAll(any))
        .thenAnswer((_) => Future.value([]));

    var preferenceManager = NoFirestoreUserPreferenceManager(appManager.app);
    await preferenceManager.initialize();

    await preferenceManager.setWaterDepthSystem(MeasurementSystem.metric);
    await preferenceManager.setWaterTemperatureSystem(MeasurementSystem.metric);
    await preferenceManager.setCatchLengthSystem(MeasurementSystem.metric);
    await preferenceManager.setCatchWeightSystem(MeasurementSystem.metric);

    when(appManager.app.userPreferenceManager).thenReturn(preferenceManager);

    await tester.pumpWidget(Testable(
      (_) => SaveCatchPage(
        speciesId: randomId(),
        fishingSpotId: randomId(),
      ),
      appManager: appManager,
    ));

    expect(find.text("m"), findsOneWidget);
    expect(find.text("\u00B0C"), findsOneWidget);
    expect(find.text("cm"), findsOneWidget);
    expect(find.text("kg"), findsOneWidget);

    await preferenceManager
        .setWaterDepthSystem(MeasurementSystem.imperial_decimal);
    await preferenceManager
        .setWaterTemperatureSystem(MeasurementSystem.imperial_decimal);
    await preferenceManager
        .setCatchLengthSystem(MeasurementSystem.imperial_decimal);
    await preferenceManager
        .setCatchWeightSystem(MeasurementSystem.imperial_decimal);
    await tester.pumpAndSettle();

    expect(find.text("ft"), findsOneWidget);
    expect(find.text("\u00B0F"), findsOneWidget);
    expect(find.text("in"), findsOneWidget);
    expect(find.text("lbs"), findsOneWidget);
  });
}
