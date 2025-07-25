import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/angler_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/method_manager.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/pages/save_catch_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/water_clarity_manager.dart';
import 'package:mobile/widgets/atmosphere_input.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/date_time_picker.dart';
import 'package:mobile/widgets/fishing_spot_details.dart';
import 'package:mobile/widgets/image_input.dart';
import 'package:mobile/widgets/image_picker.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/our_search_bar.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mobile/widgets/tide_input.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart';
import 'package:timezone/timezone.dart';

import '../../../../adair-flutter-lib/test/mocks/mocks.mocks.dart';
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';
import '../mocks/stubbed_map_controller.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;
  late StubbedMapController mapController;

  setUp(() async {
    managers = await StubbedManagers.create();
    mapController = StubbedMapController();

    when(managers.anglerManager.entityExists(any)).thenReturn(false);
    when(
      managers.anglerManager.displayName(any, any),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(
      managers.baitManager.attachmentsDisplayValues(any, any),
    ).thenReturn([]);

    when(
      managers.baitCategoryManager.listSortedByDisplayName(any),
    ).thenReturn([]);
    when(managers.baitCategoryManager.entityExists(any)).thenReturn(false);
    when(
      managers.baitCategoryManager.listen(any),
    ).thenAnswer((_) => MockStreamSubscription());

    when(managers.bodyOfWaterManager.entityExists(any)).thenReturn(false);

    when(
      managers.catchManager.addOrUpdate(
        any,
        imageFiles: anyNamed("imageFiles"),
      ),
    ).thenAnswer((_) => Future.value(false));
    when(managers.catchManager.list(any)).thenReturn([]);

    when(managers.customEntityManager.list()).thenReturn([]);
    when(managers.customEntityManager.entityExists(any)).thenReturn(false);

    when(
      managers.gpsTrailManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.gpsTrailManager.hasActiveTrail).thenReturn(false);
    when(managers.gpsTrailManager.activeTrial).thenReturn(null);

    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);

    when(
      managers.fishingSpotManager.entityExists(any),
    ).thenAnswer((invocation) => invocation.positionalArguments[0] != null);
    when(
      managers.fishingSpotManager.displayName(
        any,
        any,
        includeLatLngLabels: anyNamed("includeLatLngLabels"),
        includeBodyOfWater: anyNamed("includeBodyOfWater"),
      ),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);
    when(managers.fishingSpotManager.numberOfCatches(any)).thenReturn(0);

    when(
      managers.localDatabaseManager.insertOrReplace(any, any),
    ).thenAnswer((_) => Future.value(true));

    when(managers.locationMonitor.currentLatLng).thenReturn(null);

    when(managers.methodManager.entityExists(any)).thenReturn(false);
    when(
      managers.methodManager.displayName(any, any),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(managers.propertiesManager.visualCrossingApiKey).thenReturn("");
    when(managers.propertiesManager.mapboxApiKey).thenReturn("");
    when(managers.propertiesManager.worldTidesApiKey).thenReturn("");

    when(managers.userPreferenceManager.atmosphereFieldIds).thenReturn([]);
    when(managers.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(managers.userPreferenceManager.catchFieldIds).thenReturn([]);
    when(
      managers.userPreferenceManager.waterDepthSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(
      managers.userPreferenceManager.waterTemperatureSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(
      managers.userPreferenceManager.catchLengthSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(
      managers.userPreferenceManager.catchWeightSystem,
    ).thenReturn(MeasurementSystem.imperial_whole);
    when(managers.userPreferenceManager.autoFetchAtmosphere).thenReturn(false);
    when(managers.userPreferenceManager.autoFetchTide).thenReturn(false);
    when(
      managers.userPreferenceManager.airTemperatureSystem,
    ).thenReturn(MeasurementSystem.imperial_decimal);
    when(
      managers.userPreferenceManager.airVisibilitySystem,
    ).thenReturn(MeasurementSystem.imperial_decimal);
    when(
      managers.userPreferenceManager.airPressureSystem,
    ).thenReturn(MeasurementSystem.metric);
    when(
      managers.userPreferenceManager.airPressureImperialUnit,
    ).thenReturn(Unit.inch_of_mercury);
    when(
      managers.userPreferenceManager.windSpeedSystem,
    ).thenReturn(MeasurementSystem.imperial_decimal);
    when(
      managers.userPreferenceManager.windSpeedMetricUnit,
    ).thenReturn(Unit.kilometers_per_hour);
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.userPreferenceManager.mapType).thenReturn(null);

    when(managers.speciesManager.entityExists(any)).thenReturn(false);
    when(
      managers.speciesManager.displayName(any, any),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(
      managers.lib.subscriptionManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);

    when(managers.waterClarityManager.entityExists(any)).thenReturn(false);
    when(
      managers.waterClarityManager.displayName(any, any),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(
      managers.gearManager.displayName(any, any),
    ).thenAnswer((invocation) => invocation.positionalArguments[1].name);

    when(
      managers.permissionHandlerWrapper.isLocationGranted,
    ).thenAnswer((_) => Future.value(true));

    when(
      mapController.value.cameraPosition,
    ).thenReturn(const CameraPosition(target: LatLng(0, 0)));

    managers.lib.stubCurrentTime(dateTime(2020, 2, 1, 10, 30));

    var timeZoneLocation = MockTimeZoneLocation();
    when(timeZoneLocation.displayNameUtc).thenReturn("America/New York");
    when(timeZoneLocation.name).thenReturn("America/New_York");
    when(
      managers.lib.timeManager.filteredLocations(
        any,
        exclude: anyNamed("exclude"),
      ),
    ).thenReturn([timeZoneLocation]);
  });

  group("From journey", () {
    testWidgets("Images with date sets Catch date", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => SaveCatchPage(
            speciesId: randomId(),
            images: [
              PickedImage(
                originalFile: File("test/resources/flutter_logo.png"),
                dateTime: dateTime(2020, 1, 1, 15, 30),
              ),
            ],
          ),
        ),
      );

      expect(find.text("Jan 1, 2020"), findsOneWidget);
      expect(find.text("3:30 PM"), findsOneWidget);
      expect(find.text("America/New York"), findsOneWidget);
    });

    testWidgets("Images without date sets default date", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => SaveCatchPage(
            speciesId: randomId(),
            images: [
              PickedImage(
                originalFile: File("test/resources/flutter_logo.png"),
              ),
            ],
          ),
        ),
      );

      expect(find.text("Feb 1, 2020"), findsOneWidget);
      expect(find.text("10:30 AM"), findsOneWidget);
      expect(find.text("America/New York"), findsOneWidget);
    });

    testWidgets("All journey fields set correctly", (tester) async {
      var species = Species()
        ..id = randomId()
        ..name = "Steelhead";
      when(managers.speciesManager.entity(species.id)).thenReturn(species);
      when(managers.speciesManager.entityExists(any)).thenReturn(true);

      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..name = "Spot A"
        ..lat = 13
        ..lng = 45;
      when(
        managers.fishingSpotManager.entity(fishingSpot.id),
      ).thenReturn(fishingSpot);

      await tester.pumpWidget(
        Testable(
          (_) => SaveCatchPage(
            images: [
              PickedImage(
                originalFile: File("test/resources/flutter_logo.png"),
                dateTime: dateTime(2020, 1, 1, 15, 30),
              ),
            ],
            speciesId: species.id,
            fishingSpot: fishingSpot,
          ),
        ),
      );

      // Wait for images and map futures to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle(const Duration(milliseconds: 150));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.text("Jan 1, 2020"), findsOneWidget);
      expect(find.text("3:30 PM"), findsOneWidget);
      expect(find.text("America/New York"), findsOneWidget);
      expect(find.text("Winter"), findsOneWidget);
      expect(find.text("No baits"), findsOneWidget);

      // Angler, time of day, and water clarity.
      expect(find.text("Not Selected"), findsNWidgets(3));

      expect(find.byType(FishingSpotDetails), findsOneWidget);
      expect(find.text("Species"), findsOneWidget);
      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets("popOverride is invoked", (tester) async {
      var invoked = false;
      await tester.pumpWidget(
        Testable(
          (_) => SaveCatchPage(
            images: [
              PickedImage(
                originalFile: File("test/resources/flutter_logo.png"),
                dateTime: dateTime(2020, 1, 1, 15, 30),
              ),
            ],
            speciesId: randomId(),
            fishingSpot: FishingSpot(id: randomId()),
            popOverride: () => invoked = true,
          ),
        ),
      );

      await tapAndSettle(tester, find.text("SAVE"));
      expect(invoked, isTrue);
    });
  });

  group("Editing", () {
    testWidgets("All fields set correctly", (tester) async {
      when(managers.lib.subscriptionManager.isFree).thenReturn(false);

      var customEntity = CustomEntity()
        ..id = randomId()
        ..name = "Colour"
        ..type = CustomEntity_Type.text;
      when(
        managers.customEntityManager.entity(customEntity.id),
      ).thenReturn(customEntity);

      var fieldIds = allCatchFields(
        await buildContext(tester),
      ).map((e) => e.id);
      when(
        managers.userPreferenceManager.catchFieldIds,
      ).thenReturn([customEntity.id, ...fieldIds]);

      var bait = Bait()
        ..id = randomId()
        ..name = "Rapala";
      when(managers.baitManager.list(any)).thenReturn([bait]);
      when(
        managers.baitManager.attachmentsDisplayValues(any, any),
      ).thenReturn(["Rapala"]);

      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..name = "Spot A";
      when(managers.fishingSpotManager.entity(any)).thenReturn(fishingSpot);

      var species = Species()
        ..id = randomId()
        ..name = "Steelhead";
      when(managers.speciesManager.entity(any)).thenReturn(species);
      when(managers.speciesManager.entityExists(any)).thenReturn(true);

      var angler = Angler()
        ..id = randomId()
        ..name = "Cohen";
      when(managers.anglerManager.entity(any)).thenReturn(angler);
      when(managers.anglerManager.entityExists(any)).thenReturn(true);

      var clarity = WaterClarity()
        ..id = randomId()
        ..name = "Clear";
      when(managers.waterClarityManager.entity(any)).thenReturn(clarity);
      when(managers.waterClarityManager.entityExists(any)).thenReturn(true);

      var method0 = Method()
        ..id = randomId()
        ..name = "Casting";
      var method1 = Method()
        ..id = randomId()
        ..name = "Kayak";
      when(managers.methodManager.list(any)).thenReturn([method0, method1]);

      var gear0 = Gear(id: randomId(), name: "Bass Rod");
      var gear1 = Gear(id: randomId(), name: "Pike Rod");
      when(managers.gearManager.list(any)).thenReturn([gear0, gear1]);

      var cat = Catch()
        ..id = randomId()
        ..timestamp = Int64(
          TZDateTime(
            getLocation("America/Chicago"),
            2020,
            1,
            1,
            15,
            30,
          ).millisecondsSinceEpoch,
        )
        ..timeZone = "America/Chicago"
        ..baits.add(BaitAttachment(baitId: bait.id))
        ..fishingSpotId = fishingSpot.id
        ..speciesId = species.id
        ..anglerId = angler.id
        ..waterClarityId = clarity.id
        ..methodIds.addAll([method0.id, method1.id])
        ..gearIds.addAll([gear0.id, gear1.id])
        ..customEntityValues.add(
          CustomEntityValue()
            ..customEntityId = customEntity.id
            ..value = "Minnow",
        )
        ..imageNames.add("flutter_logo.png")
        ..period = Period.dawn
        ..season = Season.summer
        ..isFavorite = true
        ..wasCatchAndRelease = true
        ..waterDepth = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(unit: Unit.feet, value: 20),
        )
        ..waterTemperature = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(unit: Unit.fahrenheit, value: 75),
        )
        ..length = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(unit: Unit.inches, value: 15),
          fractionValue: Measurement(value: 0.25),
        )
        ..weight = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(unit: Unit.pounds, value: 10),
        )
        ..quantity = 3
        ..notes = "Some test notes."
        ..atmosphere = Atmosphere(
          temperature: MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(unit: Unit.fahrenheit, value: 58),
          ),
          skyConditions: [SkyCondition.cloudy],
          windSpeed: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(unit: Unit.kilometers_per_hour, value: 6.5),
          ),
          windDirection: Direction.north,
          pressure: MultiMeasurement(
            system: MeasurementSystem.imperial_decimal,
            mainValue: Measurement(
              unit: Unit.pounds_per_square_inch,
              value: 1000,
            ),
          ),
          humidity: MultiMeasurement(
            mainValue: Measurement(unit: Unit.percent, value: 50),
          ),
          visibility: MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(unit: Unit.miles, value: 10),
          ),
          moonPhase: MoonPhase.full,
          sunriseTimestamp: Int64(10000),
          sunsetTimestamp: Int64(15000),
        )
        ..tide = Tide(type: TideType.outgoing);

      when(
        managers.imageManager.images(
          imageNames: anyNamed("imageNames"),
          size: anyNamed("size"),
          devicePixelRatio: anyNamed("devicePixelRatio"),
        ),
      ).thenAnswer((_) {
        var file = File("test/resources/flutter_logo.png");
        return Future.value({file: file.readAsBytesSync()});
      });

      await tester.pumpWidget(Testable((_) => SaveCatchPage.edit(cat)));

      // Wait for images and map futures to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle(const Duration(milliseconds: 150));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.text("Jan 1, 2020"), findsOneWidget);
      expect(find.text("3:30 PM"), findsOneWidget);
      expect(find.text("America/Chicago"), findsOneWidget);
      expect(find.text("Dawn"), findsOneWidget);
      expect(find.text("Summer"), findsOneWidget);
      expect(find.text("Casting"), findsOneWidget);
      expect(find.text("Kayak"), findsOneWidget);
      expect(find.text("Rapala"), findsOneWidget);
      expect(find.byType(FishingSpotDetails), findsOneWidget);
      expect(find.text("Species"), findsOneWidget);
      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.text("Angler"), findsOneWidget);
      expect(find.text("Cohen"), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.text("Colour"), findsOneWidget);
      expect(find.text("Minnow"), findsOneWidget);
      expect(findCheckbox(tester, "Favourite")!.checked, isTrue);
      expect(findCheckbox(tester, "Catch and Release")!.checked, isTrue);
      expect(find.text("Clear"), findsOneWidget);
      expect(find.text("20"), findsOneWidget);
      expect(find.text("75"), findsOneWidget);
      expect(find.text("15"), findsOneWidget);
      expect(find.text("10"), findsOneWidget);
      expect(find.text("3"), findsOneWidget);
      expect(find.text("Cloudy"), findsOneWidget);
      expect(find.text("58\u00B0F"), findsOneWidget);
      expect(find.text("7 km/h"), findsOneWidget);
      expect(find.text("N"), findsOneWidget);
      expect(find.text("1000 psi"), findsOneWidget);
      expect(find.text("10 mi"), findsOneWidget);
      expect(find.text("50%"), findsOneWidget);
      expect(find.text("Sunrise"), findsOneWidget);
      expect(find.text("Sunset"), findsOneWidget);
      expect(find.text("Full"), findsOneWidget);
      expect(find.text("Moon"), findsOneWidget);
      expect(find.text("Outgoing"), findsOneWidget);
      expect(find.text("Bass Rod"), findsOneWidget);
      expect(find.text("Pike Rod"), findsOneWidget);
    });

    testWidgets("Minimum fields set correctly", (tester) async {
      var species = Species()
        ..id = randomId()
        ..name = "Steelhead";
      when(managers.speciesManager.entity(any)).thenReturn(species);
      when(managers.speciesManager.entityExists(any)).thenReturn(true);

      var cat = Catch()
        ..id = randomId()
        ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
        ..speciesId = species.id;

      await tester.pumpWidget(Testable((_) => SaveCatchPage.edit(cat)));

      expect(find.text("Jan 1, 2020"), findsOneWidget);
      expect(find.text("3:30 PM"), findsOneWidget);
      expect(find.text("America/New York"), findsOneWidget);
      expect(find.text("Species"), findsOneWidget);
      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.text("No baits"), findsOneWidget);

      // Angler, time of day, season, and water clarity.
      expect(find.text("Not Selected"), findsNWidgets(4));

      // Fishing methods.
      expect(find.text("No fishing methods"), findsOneWidget);

      expect(find.text("Fishing Spot"), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(find.byType(FishingSpotDetails), findsNothing);
      expect(findCheckbox(tester, "Favourite")!.checked, isFalse);
      expect(findCheckbox(tester, "Catch and Release")!.checked, isFalse);
      expect(find.text("Atmosphere and Weather"), findsOneWidget);

      expect(
        findFirstWithText<TextInput>(tester, "Water Depth").controller?.value,
        isNull,
      );
      expect(
        findFirstWithText<TextInput>(
          tester,
          "Water Temperature",
        ).controller?.value,
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
        ..name = "Colour"
        ..type = CustomEntity_Type.text;
      when(
        managers.customEntityManager.entity(customEntity.id),
      ).thenReturn(customEntity);
      when(
        managers.customEntityManager.entityExists(customEntity.id),
      ).thenReturn(true);

      var fieldIds = allCatchFields(
        await buildContext(tester),
      ).map((e) => e.id);
      when(
        managers.userPreferenceManager.catchFieldIds,
      ).thenReturn([customEntity.id, ...fieldIds]);

      var bait = Bait()
        ..id = randomId()
        ..name = "Rapala";
      when(managers.baitManager.entity(any)).thenReturn(bait);
      when(
        managers.baitManager.formatNameWithCategory(any),
      ).thenReturn("Rapala");

      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..name = "Spot A";
      when(managers.fishingSpotManager.entity(any)).thenReturn(fishingSpot);

      var species = Species()
        ..id = randomId()
        ..name = "Steelhead";
      when(managers.speciesManager.entity(any)).thenReturn(species);
      when(managers.speciesManager.entityExists(any)).thenReturn(true);

      var angler = Angler()
        ..id = randomId()
        ..name = "Cohen";
      when(managers.anglerManager.entity(any)).thenReturn(angler);
      when(managers.anglerManager.entityExists(any)).thenReturn(true);

      var clarity = WaterClarity()
        ..id = randomId()
        ..name = "Clear";
      when(managers.waterClarityManager.entity(any)).thenReturn(clarity);
      when(managers.waterClarityManager.entityExists(any)).thenReturn(true);

      var method0 = Method()
        ..id = randomId()
        ..name = "Casting";
      var method1 = Method()
        ..id = randomId()
        ..name = "Kayak";
      when(managers.methodManager.list(any)).thenReturn([method0, method1]);

      var gear0 = Gear(id: randomId(), name: "Bass Rod");
      var gear1 = Gear(id: randomId(), name: "Pike Rod");
      when(managers.gearManager.list(any)).thenReturn([gear0, gear1]);

      var cat = Catch()
        ..id = randomId()
        ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
        ..timeZone = defaultTimeZone
        ..baits.add(BaitAttachment(baitId: bait.id))
        ..fishingSpotId = fishingSpot.id
        ..speciesId = species.id
        ..anglerId = angler.id
        ..waterClarityId = clarity.id
        ..methodIds.addAll([method0.id, method1.id])
        ..gearIds.addAll([gear0.id, gear1.id])
        ..customEntityValues.add(
          CustomEntityValue()
            ..customEntityId = customEntity.id
            ..value = "Minnow",
        )
        ..imageNames.add("flutter_logo.png")
        ..period = Period.afternoon
        ..season = Season.summer
        ..isFavorite = true
        ..wasCatchAndRelease = true
        ..waterDepth = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(unit: Unit.feet, value: 20),
        )
        ..waterTemperature = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(unit: Unit.fahrenheit, value: 75),
        )
        ..length = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(unit: Unit.inches, value: 15),
          fractionValue: Measurement(value: 0.25),
        )
        ..weight = MultiMeasurement(
          system: MeasurementSystem.imperial_whole,
          mainValue: Measurement(unit: Unit.pounds, value: 10),
        )
        ..quantity = 3
        ..notes = "Some test notes."
        ..atmosphere = Atmosphere(
          temperature: MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(unit: Unit.fahrenheit, value: 58),
          ),
          skyConditions: [SkyCondition.cloudy],
          windSpeed: MultiMeasurement(
            system: MeasurementSystem.metric,
            mainValue: Measurement(unit: Unit.kilometers_per_hour, value: 6.5),
          ),
          windDirection: Direction.north,
          pressure: MultiMeasurement(
            system: MeasurementSystem.imperial_decimal,
            mainValue: Measurement(
              unit: Unit.pounds_per_square_inch,
              value: 1000,
            ),
          ),
          humidity: MultiMeasurement(
            mainValue: Measurement(unit: Unit.percent, value: 50),
          ),
          visibility: MultiMeasurement(
            system: MeasurementSystem.imperial_whole,
            mainValue: Measurement(unit: Unit.miles, value: 10),
          ),
          moonPhase: MoonPhase.full,
          sunriseTimestamp: Int64(10000),
          sunsetTimestamp: Int64(15000),
        )
        ..tide = Tide(type: TideType.outgoing);

      when(
        managers.imageManager.images(
          imageNames: anyNamed("imageNames"),
          size: anyNamed("size"),
          devicePixelRatio: anyNamed("devicePixelRatio"),
        ),
      ).thenAnswer((_) {
        var file = File("test/resources/flutter_logo.png");
        return Future.value({file: file.readAsBytesSync()});
      });

      await tester.pumpWidget(Testable((_) => SaveCatchPage.edit(cat)));

      // Add small delay so images future can finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      when(
        managers.catchManager.addOrUpdate(
          captureAny,
          imageFiles: anyNamed("imageFiles"),
        ),
      ).thenAnswer((invocation) {
        // Assume image is saved correctly.
        invocation.positionalArguments.first.imageNames.add("flutter_logo.png");
        return Future.value(true);
      });
      await tapAndSettle(tester, find.text("SAVE"));

      var result = verify(
        managers.catchManager.addOrUpdate(
          captureAny,
          imageFiles: anyNamed("imageFiles"),
        ),
      );
      result.called(1);
      expect(result.captured.first, cat);
    });

    /// https://github.com/cohenadair/anglers-log/issues/517
    testWidgets("Image is kept while editing", (tester) async {
      when(
        managers.imageManager.images(
          imageNames: anyNamed("imageNames"),
          size: anyNamed("size"),
          devicePixelRatio: anyNamed("devicePixelRatio"),
        ),
      ).thenAnswer((_) {
        var file = File("test/resources/flutter_logo.png");
        return Future.value({file: file.readAsBytesSync()});
      });

      var species = Species()
        ..id = randomId()
        ..name = "Steelhead";
      when(managers.speciesManager.entity(any)).thenReturn(species);
      when(managers.speciesManager.entityExists(any)).thenReturn(true);

      var cat = Catch()
        ..id = randomId()
        ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
        ..speciesId = species.id
        ..imageNames.add("flutter_logo.png");

      await tester.pumpWidget(Testable((_) => SaveCatchPage.edit(cat)));

      // Wait for image future to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 50));
      expect(find.byType(Image), findsOneWidget);

      await tapAndSettle(tester, find.text("SAVE"));

      var result = verify(
        managers.catchManager.addOrUpdate(
          any,
          imageFiles: captureAnyNamed("imageFiles"),
        ),
      );
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
      when(managers.speciesManager.entity(species.id)).thenReturn(species);
      when(managers.speciesManager.entityExists(any)).thenReturn(true);

      var fishingSpot = FishingSpot()
        ..id = randomId()
        ..name = "Spot A"
        ..lat = 13
        ..lng = 45;
      when(
        managers.fishingSpotManager.entity(fishingSpot.id),
      ).thenReturn(fishingSpot);

      await tester.pumpWidget(
        Testable(
          (_) => SaveCatchPage(speciesId: species.id, fishingSpot: fishingSpot),
        ),
      );

      // Wait for images and map futures to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.pumpAndSettle(const Duration(milliseconds: 150));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.text("Feb 1, 2020"), findsOneWidget);
      expect(find.text("10:30 AM"), findsOneWidget);
      expect(find.text("America/New York"), findsOneWidget);
      expect(find.text("Species"), findsOneWidget);
      expect(find.text("Steelhead"), findsOneWidget);
      expect(find.text("No baits"), findsOneWidget);
      expect(find.text("No gear"), findsOneWidget);
      expect(find.text("Winter"), findsOneWidget);

      // Angler, time of day, and water clarity.
      expect(find.text("Not Selected"), findsNWidgets(3));

      // Fishing methods.
      expect(find.text("No fishing methods"), findsOneWidget);

      expect(find.byType(FishingSpotDetails), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(findCheckbox(tester, "Favourite")!.checked, isFalse);
      expect(findCheckbox(tester, "Catch and Release")!.checked, isFalse);
      expect(find.text("Atmosphere and Weather"), findsOneWidget);

      expect(
        findFirstWithText<TextInput>(tester, "Water Depth").controller?.value,
        isNull,
      );
      expect(
        findFirstWithText<TextInput>(
          tester,
          "Water Temperature",
        ).controller?.value,
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
      await tester.pumpWidget(
        Testable(
          (_) => SaveCatchPage(
            speciesId: speciesId,
            fishingSpot: FishingSpot(id: fishingSpotId),
          ),
        ),
      );

      await tapAndSettle(tester, find.text("SAVE"));

      var result = verify(
        managers.catchManager.addOrUpdate(
          captureAny,
          imageFiles: anyNamed("imageFiles"),
        ),
      );
      result.called(1);

      Catch cat = result.captured.first;
      expect(cat, isNotNull);
      expect(
        cat.timestamp.toInt(),
        dateTime(2020, 2, 1, 10, 30).millisecondsSinceEpoch,
      );
      expect(cat.timeZone, "America/New_York");
      expect(cat.speciesId, speciesId);
      expect(cat.fishingSpotId, fishingSpotId);
      expect(cat.baits, isEmpty);
      expect(cat.hasAnglerId(), isFalse);
      expect(cat.hasWaterClarityId(), isFalse);
      expect(cat.methodIds, isEmpty);
      expect(cat.gearIds, isEmpty);
      expect(cat.imageNames, isEmpty);
      expect(cat.customEntityValues, isEmpty);
      expect(cat.hasPeriod(), isFalse);
      expect(cat.hasSeason(), isTrue); // Automatically calculated.
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
      var angler = Angler()
        ..id = randomId()
        ..name = "Cohen";
      when(
        managers.anglerManager.listSortedByDisplayName(
          any,
          filter: anyNamed("filter"),
        ),
      ).thenReturn([angler]);
      when(managers.anglerManager.entityExists(any)).thenReturn(true);
      when(managers.anglerManager.entity(any)).thenReturn(angler);
      when(managers.anglerManager.id(any)).thenReturn(angler.id);

      var bait = Bait()
        ..id = randomId()
        ..name = "Rapala";
      when(
        managers.baitManager.attachmentList(),
      ).thenReturn([BaitAttachment(baitId: bait.id)]);
      when(managers.baitManager.filteredList(any, any)).thenReturn([bait]);
      when(
        managers.baitManager.attachmentsDisplayValues(any, any),
      ).thenReturn([]);
      when(
        managers.baitManager.variantFromAttachment(any),
      ).thenReturn(BaitVariant(id: randomId(), baseId: bait.id));
      when(managers.baitManager.numberOfCatches(any)).thenReturn(0);
      when(managers.baitManager.numberOfCatchQuantities(any)).thenReturn(0);

      var waterClarity = WaterClarity()
        ..id = randomId()
        ..name = "Clear";
      when(
        managers.waterClarityManager.listSortedByDisplayName(
          any,
          filter: anyNamed("filter"),
        ),
      ).thenReturn([waterClarity]);
      when(managers.waterClarityManager.entityExists(any)).thenReturn(true);
      when(managers.waterClarityManager.entity(any)).thenReturn(waterClarity);
      when(managers.waterClarityManager.id(any)).thenReturn(waterClarity.id);

      var methods = [
        Method()
          ..id = randomId()
          ..name = "Casting",
        Method()
          ..id = randomId()
          ..name = "Kayak",
      ];
      when(
        managers.methodManager.listSortedByDisplayName(
          any,
          filter: anyNamed("filter"),
        ),
      ).thenReturn(methods);
      when(managers.methodManager.list(any)).thenReturn(methods);
      when(
        managers.methodManager.id(any),
      ).thenAnswer((invocation) => invocation.positionalArguments.first.id);

      var gear = [
        Gear(id: randomId(), name: "Bass Rod"),
        Gear(id: randomId(), name: "Pike Rod"),
      ];
      when(
        managers.gearManager.listSortedByDisplayName(
          any,
          filter: anyNamed("filter"),
        ),
      ).thenReturn(gear);
      when(managers.gearManager.list(any)).thenReturn(gear);
      when(
        managers.gearManager.id(any),
      ).thenAnswer((invocation) => invocation.positionalArguments.first.id);
      when(managers.gearManager.numberOfCatchQuantities(any)).thenReturn(0);

      var speciesId = randomId();
      var fishingSpotId = randomId();
      await tester.pumpWidget(
        Testable(
          (_) => SaveCatchPage(
            speciesId: speciesId,
            fishingSpot: FishingSpot(id: fishingSpotId),
          ),
        ),
      );

      // Select time zone.
      await tapAndSettle(tester, find.text("Time Zone"));
      await tapAndSettle(tester, find.text("America/New York"));

      // Select period.
      await tapAndSettle(tester, find.text("Time of Day"));
      await tapAndSettle(tester, find.text("Afternoon"));

      // Select season.
      await tapAndSettle(tester, find.text("Season"));
      await tapAndSettle(tester, find.text("Summer"));

      // Select bait.
      await tapAndSettle(tester, find.text("No baits"));
      await tapAndSettle(
        tester,
        findManageableListItemCheckbox(tester, "Rapala"),
      );
      await tapAndSettle(tester, find.byType(BackButton));

      // Select gear.
      await tapAndSettle(tester, find.text("No gear"));
      await tapAndSettle(
        tester,
        findManageableListItemCheckbox(tester, "Bass Rod"),
      );
      await tapAndSettle(
        tester,
        findManageableListItemCheckbox(tester, "Pike Rod"),
      );
      await tapAndSettle(tester, find.byType(BackButton));

      // Select angler.
      await tester.ensureVisible(find.text("Angler"));
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
        tester,
        findManageableListItemCheckbox(tester, "Casting"),
      );
      await tapAndSettle(
        tester,
        findManageableListItemCheckbox(tester, "Kayak"),
      );
      await tapAndSettle(tester, find.byType(BackButton));

      // Set favourite.
      await tester.ensureVisible(find.text("Favourite"));
      await tapAndSettle(tester, findListItemCheckbox(tester, "Favourite"));

      // Set catch and release.
      await tester.ensureVisible(find.text("Catch and Release"));
      await tapAndSettle(
        tester,
        findListItemCheckbox(tester, "Catch and Release"),
      );

      // Set atmosphere.
      await tester.ensureVisible(find.text("Atmosphere and Weather"));
      await tapAndSettle(tester, find.text("Atmosphere and Weather"));
      await enterTextAndSettle(
        tester,
        find.widgetWithText(TextField, "Air Temperature"),
        "58",
      );
      await tapAndSettle(tester, find.byType(BackButtonIcon));

      // Tide.
      await tester.ensureVisible(find.text("Tide"));
      await tapAndSettle(tester, find.text("Tide"));
      await tapAndSettle(tester, find.text("Outgoing"));
      await tapAndSettle(tester, find.byType(BackButtonIcon));

      await tapAndSettle(tester, find.text("SAVE"));

      var result = verify(
        managers.catchManager.addOrUpdate(
          captureAny,
          imageFiles: anyNamed("imageFiles"),
        ),
      );
      result.called(1);

      Catch cat = result.captured.first;
      expect(cat, isNotNull);
      expect(
        cat.timestamp.toInt(),
        dateTime(2020, 2, 1, 10, 30).millisecondsSinceEpoch,
      );
      expect(cat.timeZone, "America/New_York");
      expect(cat.speciesId, speciesId);
      expect(cat.fishingSpotId, fishingSpotId);
      expect(cat.imageNames, isEmpty);
      expect(cat.customEntityValues, isEmpty);
      expect(cat.baits, isNotEmpty);
      expect(cat.hasAnglerId(), isTrue);
      expect(cat.hasWaterClarityId(), isTrue);
      expect(cat.methodIds.length, 2);
      expect(cat.gearIds.length, 2);
      expect(cat.hasPeriod(), isTrue);
      expect(cat.period, Period.afternoon);
      expect(cat.hasSeason(), isTrue);
      expect(cat.season, Season.summer);
      expect(cat.isFavorite, isTrue);
      expect(cat.wasCatchAndRelease, isTrue);
      expect(cat.hasAtmosphere(), isTrue);
      expect(cat.atmosphere.hasTimeZone(), isTrue);
      expect(cat.atmosphere.temperature.mainValue.value, 58);
      expect(cat.hasTide(), isTrue);
      expect(cat.tide.type, TideType.outgoing);
      expect(cat.tide.hasTimeZone(), isTrue);
    });
  });

  testWidgets("New title", (tester) async {
    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );

    expect(find.text("New Catch"), findsOneWidget);
  });

  testWidgets("Edit title", (tester) async {
    var cat = Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
      ..speciesId = randomId();

    await tester.pumpWidget(Testable((_) => SaveCatchPage.edit(cat)));

    expect(find.text("Edit Catch"), findsOneWidget);
  });

  testWidgets("Copy title", (tester) async {
    await tester.pumpWidget(Testable((_) => SaveCatchPage.copied(Catch())));

    expect(find.text("New Catch"), findsOneWidget);
  });

  testWidgets("Only show fields saved in preferences", (tester) async {
    when(managers.userPreferenceManager.catchFieldIds).thenReturn([
      catchFieldIdTimestamp,
      catchFieldIdSpecies,
      catchFieldIdBait,
    ]);
    var species = Species()
      ..id = randomId()
      ..name = "Steelhead";
    when(managers.speciesManager.entity(species.id)).thenReturn(species);
    when(managers.speciesManager.entityExists(any)).thenReturn(true);

    var fishingSpot = FishingSpot()
      ..id = randomId()
      ..name = "Spot A";
    when(
      managers.fishingSpotManager.entity(fishingSpot.id),
    ).thenReturn(fishingSpot);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage(speciesId: species.id, fishingSpot: fishingSpot),
      ),
    );

    expect(find.text("Date"), findsOneWidget);
    expect(find.text("Time"), findsOneWidget);
    expect(find.text("Species"), findsOneWidget);
    expect(find.byType(FishingSpotDetails), findsNothing);
    expect(find.byType(ImagePicker), findsNothing);
  });

  testWidgets("Atmosphere shown if preferences is empty", (tester) async {
    when(managers.userPreferenceManager.catchFieldIds).thenReturn([]);

    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );

    expect(find.byType(AtmosphereInput), findsOneWidget);
  });

  testWidgets("Atmosphere shown if in preferences", (tester) async {
    when(
      managers.userPreferenceManager.catchFieldIds,
    ).thenReturn([catchFieldIdAtmosphere]);

    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );

    expect(find.byType(AtmosphereInput), findsOneWidget);
  });

  testWidgets("Atmosphere hidden", (tester) async {
    when(
      managers.userPreferenceManager.catchFieldIds,
    ).thenReturn([catchFieldIdSpecies]);

    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );

    expect(find.byType(AtmosphereInput), findsNothing);
  });

  /// https://github.com/cohenadair/anglers-log/issues/462
  testWidgets("Updates to selected species updates state", (tester) async {
    var species = Species()
      ..id = randomId()
      ..name = "Bass";

    // Use real SpeciesManager to test listener notifications.
    var speciesManager = SpeciesManager(managers.app);
    speciesManager.addOrUpdate(species);
    when(managers.app.speciesManager).thenReturn(speciesManager);

    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: species.id)),
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
    var baitManager = BaitManager(managers.app);
    baitManager.addOrUpdate(bait);
    when(managers.app.baitManager).thenReturn(baitManager);

    when(managers.catchManager.list()).thenReturn([]);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage.edit(
          Catch()
            ..id = randomId()
            ..speciesId = randomId()
            ..baits.add(BaitAttachment(baitId: bait.id)),
        ),
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
    when(
      managers.bodyOfWaterManager.displayNameFromId(any, any),
    ).thenReturn(null);

    var fishingSpot = FishingSpot()
      ..id = randomId()
      ..name = "A";

    // Use real FishingSpotManager to test listener notifications.
    var fishingSpotManager = FishingSpotManager(managers.app);
    fishingSpotManager.addOrUpdate(fishingSpot);
    when(managers.app.fishingSpotManager).thenReturn(fishingSpotManager);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage.edit(
          Catch()
            ..id = randomId()
            ..fishingSpotId = fishingSpot.id,
        ),
      ),
    );

    expect(find.text("A"), findsOneWidget);

    // Edit the selected fishing spot.
    await tapAndSettle(tester, find.text("A"));

    // Finish loading the map.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await mapController.finishLoading(tester);

    await tapAndSettle(tester, find.text("Edit"));
    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextInput, "Name"),
      "B",
    );
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
    var anglerManager = AnglerManager(managers.app);
    anglerManager.addOrUpdate(angler);
    when(managers.app.anglerManager).thenReturn(anglerManager);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage.edit(
          Catch()
            ..id = randomId()
            ..anglerId = angler.id,
        ),
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
  testWidgets("Updates to selected water clarity updates state", (
    tester,
  ) async {
    var clarity = WaterClarity()
      ..id = randomId()
      ..name = "Clear";

    // Use real AnglerManager to test listener notifications.
    var clarityManager = WaterClarityManager(managers.app);
    clarityManager.addOrUpdate(clarity);
    when(managers.app.waterClarityManager).thenReturn(clarityManager);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage.edit(
          Catch()
            ..id = randomId()
            ..waterClarityId = clarity.id,
        ),
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
  testWidgets("Updates to selected fishing methods updates state", (
    tester,
  ) async {
    var method = Method()
      ..id = randomId()
      ..name = "Casting";

    // Use real AnglerManager to test listener notifications.
    var methodManager = MethodManager(managers.app);
    methodManager.addOrUpdate(method);
    when(managers.app.methodManager).thenReturn(methodManager);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage.edit(
          Catch()
            ..id = randomId()
            ..methodIds.add(method.id),
        ),
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
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(
      managers.catchManager.addOrUpdate(
        captureAny,
        imageFiles: anyNamed("imageFiles"),
      ),
    );
    result.called(1);

    var cat = result.captured.first as Catch;
    expect(cat.hasFishingSpotId(), isFalse);
  });

  testWidgets("Save catch with a non-existing fishing spot", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(
      managers.fishingSpotManager.addOrUpdate(any),
    ).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage(
          speciesId: randomId(),
          fishingSpot: FishingSpot(id: randomId(), lat: 1.23456, lng: 2.34567),
        ),
      ),
    );
    await tapAndSettle(tester, find.text("SAVE"));

    verify(managers.fishingSpotManager.addOrUpdate(any)).called(1);

    var result = verify(
      managers.catchManager.addOrUpdate(
        captureAny,
        imageFiles: anyNamed("imageFiles"),
      ),
    );
    result.called(1);

    var cat = result.captured.first as Catch;
    expect(cat.hasFishingSpotId(), isTrue);
  });

  testWidgets("Save catch with an existing fishing spot", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage(
          speciesId: randomId(),
          fishingSpot: FishingSpot(id: randomId(), lat: 1.23456, lng: 2.34567),
        ),
      ),
    );
    await tapAndSettle(tester, find.text("SAVE"));

    verify(managers.fishingSpotManager.entityExists(any)).called(1);

    var result = verify(
      managers.catchManager.addOrUpdate(
        captureAny,
        imageFiles: anyNamed("imageFiles"),
      ),
    );
    result.called(1);

    var cat = result.captured.first as Catch;
    expect(cat.hasFishingSpotId(), isTrue);
  });

  testWidgets("Hidden catch and release doesn't set property", (tester) async {
    await tester.pumpWidget(
      Testable((context) {
        var ids = allCatchFields(context).map<Id>((e) => e.id).toList()
          ..removeWhere((id) => id == catchFieldIdCatchAndRelease);
        when(managers.userPreferenceManager.catchFieldIds).thenReturn(ids);

        return SaveCatchPage(speciesId: randomId());
      }),
    );
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(
      managers.catchManager.addOrUpdate(
        captureAny,
        imageFiles: anyNamed("imageFiles"),
      ),
    );
    result.called(1);

    var cat = result.captured.first as Catch;
    expect(cat.hasWasCatchAndRelease(), isFalse);
  });

  testWidgets("Season updates when date changes", (tester) async {
    var species = Species()
      ..id = randomId()
      ..name = "Steelhead";
    when(managers.speciesManager.entity(species.id)).thenReturn(species);
    when(managers.speciesManager.entityExists(any)).thenReturn(true);

    var fishingSpot = FishingSpot()
      ..id = randomId()
      ..name = "Spot A"
      ..lat = 13
      ..lng = 45;
    when(
      managers.fishingSpotManager.entity(fishingSpot.id),
    ).thenReturn(fishingSpot);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage(speciesId: species.id, fishingSpot: fishingSpot),
      ),
    );

    expect(find.text("Feb 1, 2020"), findsOneWidget);
    expect(find.text("Winter"), findsOneWidget);

    expect(find.text("Date"), findsOneWidget);
    await tapAndSettle(tester, find.text("Date"));
    await tapAndSettle(tester, find.byIcon(Icons.edit));
    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextField, "Enter Date"),
      "3/1/2020",
    );
    await tapAndSettle(tester, find.text("OK"));

    expect(find.text("Spring"), findsOneWidget);
  });

  testWidgets("Season updates when fishing spot changes", (tester) async {
    var species = Species()
      ..id = randomId()
      ..name = "Steelhead";
    when(managers.speciesManager.entity(species.id)).thenReturn(species);
    when(managers.speciesManager.entityExists(any)).thenReturn(true);

    var fishingSpot1 = FishingSpot()
      ..id = randomId()
      ..name = "Spot A"
      ..lat = 13
      ..lng = 45;
    when(
      managers.fishingSpotManager.entity(fishingSpot1.id),
    ).thenReturn(fishingSpot1);

    var fishingSpot2 = FishingSpot()
      ..id = randomId()
      ..name = "Spot B"
      ..lat = -13
      ..lng = 45;
    when(
      managers.fishingSpotManager.entity(fishingSpot2.id),
    ).thenReturn(fishingSpot2);
    when(
      managers.fishingSpotManager.list(),
    ).thenReturn([fishingSpot1, fishingSpot2]);
    when(
      managers.fishingSpotManager.filteredList(any, any),
    ).thenReturn([fishingSpot1, fishingSpot2]);
    when(
      managers.fishingSpotManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn([fishingSpot1, fishingSpot2]);
    when(
      managers.fishingSpotManager.addOrUpdate(any),
    ).thenAnswer((_) => Future.value(true));

    when(
      managers.bodyOfWaterManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn([]);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage(speciesId: species.id, fishingSpot: fishingSpot1),
      ),
    );

    expect(find.text("Feb 1, 2020"), findsOneWidget);
    expect(find.text("Winter"), findsOneWidget);

    await tapAndSettle(tester, find.text("Lat: 13.000000, Lng: 45.000000"));

    // Finish loading the map.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await mapController.finishLoading(tester);

    await tapAndSettle(tester, find.byType(OurSearchBar));
    await tapAndSettle(tester, find.text("Spot B"));
    await tapAndSettle(tester, find.byType(BackButton));

    expect(find.text("Summer"), findsOneWidget);
  });

  testWidgets("Season not updates automatically if picked by user", (
    tester,
  ) async {
    var species = Species()
      ..id = randomId()
      ..name = "Steelhead";
    when(managers.speciesManager.entity(species.id)).thenReturn(species);
    when(managers.speciesManager.entityExists(any)).thenReturn(true);

    var fishingSpot = FishingSpot()
      ..id = randomId()
      ..name = "Spot A"
      ..lat = 13
      ..lng = 45;
    when(
      managers.fishingSpotManager.entity(fishingSpot.id),
    ).thenReturn(fishingSpot);

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage(speciesId: species.id, fishingSpot: fishingSpot),
      ),
    );

    expect(find.text("Feb 1, 2020"), findsOneWidget);
    expect(find.text("Winter"), findsOneWidget);

    // Manually pick a season.
    await tapAndSettle(tester, find.text("Winter"));
    await tapAndSettle(tester, find.text("Summer"));
    expect(find.text("Winter"), findsNothing);
    expect(find.text("Summer"), findsOneWidget);

    // Change the date.
    await tapAndSettle(tester, find.text("Date"));
    await tapAndSettle(tester, find.byIcon(Icons.edit));
    await enterTextAndSettle(
      tester,
      find.widgetWithText(TextField, "Enter Date"),
      "3/1/2020",
    );
    await tapAndSettle(tester, find.text("OK"));

    // Verify that the season wasn't recalculated.
    expect(find.text("Spring"), findsNothing);
    expect(find.text("Summer"), findsOneWidget);
  });

  testWidgets("Season is not calculated if not tracking", (tester) async {
    when(managers.userPreferenceManager.catchFieldIds).thenReturn([
      catchFieldIdTimestamp,
      catchFieldIdSpecies,
      catchFieldIdFishingSpot,
    ]);

    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );

    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(
      managers.catchManager.addOrUpdate(
        captureAny,
        imageFiles: anyNamed("imageFiles"),
      ),
    );
    result.called(1);

    // If the season on the catch isn't set, it means it was never calculated.
    expect((result.captured.first as Catch).hasSeason(), isFalse);
  });

  testWidgets("Atmosphere automatically fetched for new catches", (
    tester,
  ) async {
    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.autoFetchAtmosphere).thenReturn(true);
    when(managers.locationMonitor.currentLatLng).thenReturn(const LatLng(0, 0));
    when(
      managers.httpWrapper.get(any),
    ).thenAnswer((_) => Future.value(Response("", HttpStatus.ok)));

    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );

    verify(managers.httpWrapper.get(any)).called(1);
  });

  testWidgets("Atmosphere automatically fetched after changing date and time", (
    tester,
  ) async {
    when(
      managers.lib.timeManager.currentDateTime,
    ).thenReturn(dateTime(2020, 1, 1, 15, 30));
    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.autoFetchAtmosphere).thenReturn(true);
    when(managers.locationMonitor.currentLatLng).thenReturn(const LatLng(0, 0));
    when(
      managers.httpWrapper.get(any),
    ).thenAnswer((_) => Future.value(Response("", HttpStatus.ok)));

    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );

    // Check AtmosphereInput data.
    await ensureVisibleAndSettle(tester, find.byType(AtmosphereInput));
    await tapAndSettle(tester, find.byType(AtmosphereInput));
    expect(find.text("Today at 3:30 PM"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Select a different date.
    await ensureVisibleAndSettle(tester, find.byType(DatePicker));
    await tapAndSettle(tester, find.byType(DatePicker));
    await tapAndSettle(tester, find.text("2"));
    await tapAndSettle(tester, find.text("OK"));

    // Select a different time.
    await tapAndSettle(tester, find.byType(TimePicker));
    var center = tester.getCenter(
      find.byKey(const ValueKey<String>('time-picker-dial')),
    );
    await tester.tapAt(Offset(center.dx - 10, center.dy));
    await tapAndSettle(tester, find.text("OK"));

    // Once on load, once when the date is changed, once when the time is
    // changed.
    verify(managers.httpWrapper.get(any)).called(3);

    // Check AtmosphereInput data.
    await ensureVisibleAndSettle(tester, find.byType(AtmosphereInput));
    await tapAndSettle(tester, find.byType(AtmosphereInput));
    expect(find.text("Thursday at 9:30 PM"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));
  });

  testWidgets("Atmosphere not fetched for free users", (tester) async {
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    when(managers.userPreferenceManager.autoFetchAtmosphere).thenReturn(true);
    when(managers.locationMonitor.currentLatLng).thenReturn(const LatLng(0, 0));
    when(
      managers.httpWrapper.get(any),
    ).thenAnswer((_) => Future.value(Response("", HttpStatus.ok)));

    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );

    verifyNever(managers.httpWrapper.get(any));
  });

  testWidgets("Atmosphere not fetched if not tracking", (tester) async {
    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.autoFetchAtmosphere).thenReturn(true);
    when(managers.locationMonitor.currentLatLng).thenReturn(const LatLng(0, 0));
    when(
      managers.httpWrapper.get(any),
    ).thenAnswer((_) => Future.value(Response("", HttpStatus.ok)));

    await tester.pumpWidget(
      Testable((context) {
        when(managers.userPreferenceManager.catchFieldIds).thenReturn(
          allCatchFields(context).map((e) => e.id).toList()
            ..remove(catchFieldIdAtmosphere),
        );

        return SaveCatchPage(speciesId: randomId());
      }),
    );

    verifyNever(managers.httpWrapper.get(any));
  });

  testWidgets("Atmosphere not fetched if not in preferences", (tester) async {
    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.autoFetchAtmosphere).thenReturn(false);
    when(managers.locationMonitor.currentLatLng).thenReturn(const LatLng(0, 0));
    when(
      managers.httpWrapper.get(any),
    ).thenAnswer((_) => Future.value(Response("", HttpStatus.ok)));

    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );

    verifyNever(managers.httpWrapper.get(any));
  });

  testWidgets("Tide automatically fetched for new catches", (tester) async {
    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.autoFetchTide).thenReturn(true);
    when(managers.locationMonitor.currentLatLng).thenReturn(const LatLng(0, 0));
    when(
      managers.httpWrapper.get(any),
    ).thenAnswer((_) => Future.value(Response("", HttpStatus.ok)));

    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );

    verify(managers.httpWrapper.get(any)).called(1);
  });

  testWidgets("Tide automatically fetched after changing date and time", (
    tester,
  ) async {
    when(
      managers.lib.timeManager.currentDateTime,
    ).thenReturn(dateTime(2020, 1, 1, 15, 30));
    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.autoFetchTide).thenReturn(true);
    when(managers.locationMonitor.currentLatLng).thenReturn(const LatLng(0, 0));
    when(
      managers.httpWrapper.get(any),
    ).thenAnswer((_) => Future.value(Response("", HttpStatus.ok)));

    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );

    // Check TideInput data.
    await ensureVisibleAndSettle(tester, find.byType(TideInput));
    await tapAndSettle(tester, find.byType(TideInput));
    expect(find.text("Today at 3:30 PM"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Select a different date.
    await ensureVisibleAndSettle(tester, find.byType(DatePicker));
    await tapAndSettle(tester, find.byType(DatePicker));
    await tapAndSettle(tester, find.text("2"));
    await tapAndSettle(tester, find.text("OK"));

    // Select a different time.
    await tapAndSettle(tester, find.byType(TimePicker));
    var center = tester.getCenter(
      find.byKey(const ValueKey<String>('time-picker-dial')),
    );
    await tester.tapAt(Offset(center.dx - 10, center.dy));
    await tapAndSettle(tester, find.text("OK"));

    // Once on load, once when the date is changed, once when the time is
    // changed.
    verify(managers.httpWrapper.get(any)).called(3);

    // Check TideInput data.
    await ensureVisibleAndSettle(tester, find.byType(TideInput));
    await tapAndSettle(tester, find.byType(TideInput));
    expect(find.text("Thursday at 9:30 PM"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));
  });

  testWidgets("Tide automatically fetched after changing fishing spot", (
    tester,
  ) async {
    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.autoFetchTide).thenReturn(true);
    when(managers.locationMonitor.currentLatLng).thenReturn(const LatLng(0, 0));
    when(
      managers.httpWrapper.get(any),
    ).thenAnswer((_) => Future.value(Response("", HttpStatus.ok)));

    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );
    verify(managers.httpWrapper.get(any)).called(1);

    // Check TideInput data.
    await ensureVisibleAndSettle(tester, find.byType(TideInput));
    await tapAndSettle(tester, find.byType(TideInput));
    expect(find.text("Current Location"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Select a different fishing spot.
    var fishingSpot = FishingSpot(
      id: randomId(),
      name: "Name",
      lat: 1.23456,
      lng: 6.54321,
    );

    when(managers.fishingSpotManager.entity(any)).thenReturn(fishingSpot);
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(managers.fishingSpotManager.list()).thenReturn([fishingSpot]);
    when(
      managers.fishingSpotManager.filteredList(any, any),
    ).thenReturn([fishingSpot]);
    when(
      managers.fishingSpotManager.withinPreferenceRadius(any),
    ).thenReturn(null);
    when(
      managers.bodyOfWaterManager.listSortedByDisplayName(any),
    ).thenReturn([]);

    // Pick a fishing spot.
    await ensureVisibleAndSettle(tester, find.text("Fishing Spot"));
    await tapAndSettle(tester, find.text("Fishing Spot"));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await mapController.finishLoading(tester);
    await tapAndSettle(tester, find.text("Search fishing spots"));
    await tapAndSettle(tester, find.text("Name"));
    await tapAndSettle(tester, find.byType(BackButton));

    // Once when picker is set to current location, and once when a new spot is
    // picked.
    verify(managers.httpWrapper.get(any)).called(2);

    // Check TideInput data.
    await ensureVisibleAndSettle(tester, find.byType(TideInput));
    await tapAndSettle(tester, find.byType(TideInput));
    expect(find.text("Name"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));
  });

  testWidgets("Tide not fetched for free users", (tester) async {
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    when(managers.userPreferenceManager.autoFetchTide).thenReturn(true);
    when(managers.locationMonitor.currentLatLng).thenReturn(const LatLng(0, 0));
    when(
      managers.httpWrapper.get(any),
    ).thenAnswer((_) => Future.value(Response("", HttpStatus.ok)));

    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );

    verifyNever(managers.httpWrapper.get(any));
  });

  testWidgets("Tide not fetched if not tracking", (tester) async {
    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.autoFetchTide).thenReturn(true);
    when(managers.locationMonitor.currentLatLng).thenReturn(const LatLng(0, 0));
    when(
      managers.httpWrapper.get(any),
    ).thenAnswer((_) => Future.value(Response("", HttpStatus.ok)));

    await tester.pumpWidget(
      Testable((context) {
        when(managers.userPreferenceManager.catchFieldIds).thenReturn(
          allCatchFields(context).map((e) => e.id).toList()
            ..remove(catchFieldIdTide),
        );

        return SaveCatchPage(speciesId: randomId());
      }),
    );

    verifyNever(managers.httpWrapper.get(any));
  });

  testWidgets("Tide not fetched if not in preferences", (tester) async {
    when(managers.lib.subscriptionManager.isFree).thenReturn(false);
    when(managers.userPreferenceManager.autoFetchTide).thenReturn(false);
    when(managers.locationMonitor.currentLatLng).thenReturn(const LatLng(0, 0));
    when(
      managers.httpWrapper.get(any),
    ).thenAnswer((_) => Future.value(Response("", HttpStatus.ok)));

    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );

    verifyNever(managers.httpWrapper.get(any));
  });

  testWidgets("Updating units updates widgets", (tester) async {
    when(
      managers.localDatabaseManager.fetchAll(any),
    ).thenAnswer((_) => Future.value([]));

    UserPreferenceManager.reset();
    await UserPreferenceManager.get.init();

    await UserPreferenceManager.get.setWaterDepthSystem(
      MeasurementSystem.metric,
    );
    await UserPreferenceManager.get.setWaterTemperatureSystem(
      MeasurementSystem.metric,
    );
    await UserPreferenceManager.get.setCatchLengthSystem(
      MeasurementSystem.metric,
    );
    await UserPreferenceManager.get.setCatchWeightSystem(
      MeasurementSystem.metric,
    );

    await tester.pumpWidget(
      Testable(
        (_) => SaveCatchPage(
          speciesId: randomId(),
          fishingSpot: FishingSpot(id: randomId()),
        ),
      ),
    );

    expect(find.text("m"), findsOneWidget);
    expect(find.text("\u00B0C"), findsOneWidget);
    expect(find.text("cm"), findsOneWidget);
    expect(find.text("kg"), findsOneWidget);

    await UserPreferenceManager.get.setWaterDepthSystem(
      MeasurementSystem.imperial_decimal,
    );
    await UserPreferenceManager.get.setWaterTemperatureSystem(
      MeasurementSystem.imperial_decimal,
    );
    await UserPreferenceManager.get.setCatchLengthSystem(
      MeasurementSystem.imperial_decimal,
    );
    await UserPreferenceManager.get.setCatchWeightSystem(
      MeasurementSystem.imperial_decimal,
    );
    await tester.pumpAndSettle();

    expect(find.text("ft"), findsOneWidget);
    expect(find.text("\u00B0F"), findsOneWidget);
    expect(find.text("in"), findsOneWidget);
    expect(find.text("lbs"), findsOneWidget);
  });

  testWidgets("Picking fishing spot that doesn't exist", (tester) async {
    when(managers.fishingSpotManager.entity(any)).thenReturn(null);
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(managers.fishingSpotManager.list()).thenReturn([]);
    when(
      managers.fishingSpotManager.withinPreferenceRadius(any),
    ).thenReturn(null);
    when(
      managers.fishingSpotManager.addOrUpdate(any),
    ).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );

    expect(find.widgetWithText(ListItem, "Fishing Spot"), findsOneWidget);

    // Pick a fishing spot.
    await tapAndSettle(tester, find.text("Fishing Spot"));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await mapController.finishLoading(tester);
    await tapAndSettle(tester, find.byType(BackButton));

    expect(find.widgetWithText(ListItem, "Fishing Spot"), findsNothing);
    expect(find.byType(FishingSpotDetails), findsOneWidget);

    // Save and verify.
    await tapAndSettle(tester, find.text("SAVE"));
    verify(managers.fishingSpotManager.addOrUpdate(any)).called(1);
  });

  testWidgets("Picking fishing spot that exists", (tester) async {
    var fishingSpot = FishingSpot(
      id: randomId(),
      name: "Name",
      lat: 1.23456,
      lng: 6.54321,
    );

    when(managers.fishingSpotManager.entity(any)).thenReturn(fishingSpot);
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(managers.fishingSpotManager.list()).thenReturn([fishingSpot]);
    when(
      managers.fishingSpotManager.withinPreferenceRadius(any),
    ).thenReturn(null);

    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );

    expect(find.byType(FishingSpotDetails), findsOneWidget);

    // Pick a fishing spot.
    await tapAndSettle(tester, find.text("Name"));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await mapController.finishLoading(tester);
    await tapAndSettle(tester, find.byType(BackButton));

    // Save and verify.
    await tapAndSettle(tester, find.text("SAVE"));
    verifyNever(managers.fishingSpotManager.addOrUpdate(any));
  });

  testWidgets("Picking fishing spot updates atmosphere input", (tester) async {
    var fishingSpot = FishingSpot(
      id: randomId(),
      name: "Name",
      lat: 1.23456,
      lng: 6.54321,
    );

    when(managers.fishingSpotManager.entity(any)).thenReturn(fishingSpot);
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(managers.fishingSpotManager.list()).thenReturn([fishingSpot]);
    when(
      managers.fishingSpotManager.withinPreferenceRadius(any),
    ).thenReturn(null);

    await tester.pumpWidget(
      Testable((_) => SaveCatchPage(speciesId: randomId())),
    );

    expect(find.byType(FishingSpotDetails), findsOneWidget);

    // Check AtmosphereInput data.
    await ensureVisibleAndSettle(tester, find.byType(AtmosphereInput));
    await tapAndSettle(tester, find.byType(AtmosphereInput));
    expect(find.text("Current Location"), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    // Pick a fishing spot.
    await ensureVisibleAndSettle(tester, find.text("Name"));
    await tapAndSettle(tester, find.text("Name"));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await mapController.finishLoading(tester);
    await tapAndSettle(tester, find.byType(BackButton));

    // Re-check AtmosphereInput data.
    when(
      managers.fishingSpotManager.displayName(
        any,
        any,
        useLatLngFallback: anyNamed("useLatLngFallback"),
        includeLatLngLabels: anyNamed("includeLatLngLabels"),
        includeBodyOfWater: anyNamed("includeBodyOfWater"),
      ),
    ).thenReturn("Lat: 1.234560, Lng: 6.543210");
    await ensureVisibleAndSettle(tester, find.byType(AtmosphereInput));
    await tapAndSettle(tester, find.byType(AtmosphereInput));
    expect(find.text("Lat: 1.234560, Lng: 6.543210"), findsOneWidget);

    // Dispose of AtmosphereInput.
    await tapAndSettle(tester, find.byType(BackButton));
  });

  testWidgets("Deselecting gear clears on edit", (tester) async {
    var species = Species()
      ..id = randomId()
      ..name = "Steelhead";
    when(managers.speciesManager.entity(any)).thenReturn(species);
    when(managers.speciesManager.entityExists(any)).thenReturn(true);

    var gear = [
      Gear(id: randomId(), name: "Bass Rod"),
      Gear(id: randomId(), name: "Pike Rod"),
    ];
    when(
      managers.gearManager.listSortedByDisplayName(
        any,
        filter: anyNamed("filter"),
      ),
    ).thenReturn(gear);
    when(managers.gearManager.list(any)).thenReturn(gear);
    when(
      managers.gearManager.id(any),
    ).thenAnswer((invocation) => invocation.positionalArguments.first.id);
    when(managers.gearManager.numberOfCatchQuantities(any)).thenReturn(0);

    var cat = Catch()
      ..id = randomId()
      ..timestamp = Int64(
        TZDateTime(
          getLocation("America/Chicago"),
          2020,
          1,
          1,
          15,
          30,
        ).millisecondsSinceEpoch,
      )
      ..timeZone = "America/Chicago"
      ..speciesId = species.id
      ..gearIds.addAll([gear[0].id, gear[1].id]);

    await tester.pumpWidget(Testable((_) => SaveCatchPage.edit(cat)));

    expect(find.text("Bass Rod"), findsOneWidget);
    expect(find.text("Pike Rod"), findsOneWidget);

    // Deselect gear.
    await tapAndSettle(tester, find.text("Bass Rod"));
    await tapAndSettle(tester, findManageableListItemCheckbox(tester, "All"));
    await tapAndSettle(tester, find.byType(BackButton));

    // Save.
    await tapAndSettle(tester, find.text("SAVE"));

    var result = verify(
      managers.catchManager.addOrUpdate(
        captureAny,
        imageFiles: anyNamed("imageFiles"),
      ),
    );
    result.called(1);
    expect(result.captured.first.gearIds.isEmpty, isTrue);
  });
}
