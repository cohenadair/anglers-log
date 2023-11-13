import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mobile/angler_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/channels/migration_channel.dart';
import 'package:mobile/database/legacy_importer.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/method_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/utils/number_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/water_clarity_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;
import 'package:timezone/timezone.dart';

import '../mocks/mocks.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late MockLocalDatabaseManager dataManager;
  late MockImageManager imageManager;

  late MockIoWrapper ioWrapper;

  late AnglerManager anglerManager;
  late BaitCategoryManager baitCategoryManager;
  late BaitManager baitManager;
  late BodyOfWaterManager bodyOfWaterManager;
  late CatchManager catchManager;
  late FishingSpotManager fishingSpotManager;
  late MethodManager methodManager;
  late SpeciesManager speciesManager;
  late TripManager tripManager;
  late WaterClarityManager waterClarityManager;

  var tmpPath = "test/resources/legacy_importer/tmp";
  late Directory tmpDir;

  setUp(() {
    appManager = StubbedAppManager();

    dataManager = appManager.localDatabaseManager;
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    imageManager = appManager.imageManager;
    when(imageManager.save(any)).thenAnswer((_) => Future.value([]));
    when(imageManager.save(any, compress: anyNamed("compress")))
        .thenAnswer((_) => Future.value([]));

    when(appManager.localDatabaseManager.resetDatabase())
        .thenAnswer((_) => Future.value());

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    ioWrapper = appManager.ioWrapper;

    when(appManager.pathProviderWrapper.temporaryPath)
        .thenAnswer((_) => Future.value(tmpPath));

    when(appManager.userPreferenceManager.airTemperatureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airPressureSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.airVisibilitySystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.windSpeedSystem)
        .thenReturn(MeasurementSystem.metric);

    anglerManager = AnglerManager(appManager.app);
    when(appManager.app.anglerManager).thenReturn(anglerManager);

    baitCategoryManager = BaitCategoryManager(appManager.app);
    when(appManager.app.baitCategoryManager).thenReturn(baitCategoryManager);

    baitManager = BaitManager(appManager.app);
    when(appManager.app.baitManager).thenReturn(baitManager);

    bodyOfWaterManager = BodyOfWaterManager(appManager.app);
    when(appManager.app.bodyOfWaterManager).thenReturn(bodyOfWaterManager);

    fishingSpotManager = FishingSpotManager(appManager.app);
    when(appManager.app.fishingSpotManager).thenReturn(fishingSpotManager);

    catchManager = CatchManager(appManager.app);
    when(appManager.app.catchManager).thenReturn(catchManager);

    methodManager = MethodManager(appManager.app);
    when(appManager.app.methodManager).thenReturn(methodManager);

    speciesManager = SpeciesManager(appManager.app);
    when(appManager.app.speciesManager).thenReturn(speciesManager);

    tripManager = TripManager(appManager.app);
    when(appManager.app.tripManager).thenReturn(tripManager);

    waterClarityManager = WaterClarityManager(appManager.app);
    when(appManager.app.waterClarityManager).thenReturn(waterClarityManager);

    // Create a temporary directory for images.
    tmpDir = Directory(tmpPath);
    tmpDir.createSync(recursive: true);
  });

  tearDown(() {
    tmpDir.deleteSync(recursive: true);
  });

  void verifyIds() {
    // Legacy iOS files don't use UUIDs, so verify IDs are present and valid.
    for (var angler in anglerManager.list()) {
      expect(angler.id, isNotNull);
      expect(angler.id.uuid, isNotEmpty);
    }

    for (var baitCategory in baitCategoryManager.list()) {
      expect(baitCategory.id, isNotNull);
      expect(baitCategory.id.uuid, isNotEmpty);
    }

    for (var bait in baitManager.list()) {
      expect(bait.id, isNotNull);
      expect(bait.id.uuid, isNotEmpty);
    }

    for (var cat in catchManager.list()) {
      expect(cat.id, isNotNull);
      expect(cat.id.uuid, isNotEmpty);
    }

    for (var fishingSpot in fishingSpotManager.list()) {
      expect(fishingSpot.id, isNotNull);
      expect(fishingSpot.id.uuid, isNotEmpty);
    }

    for (var method in methodManager.list()) {
      expect(method.id, isNotNull);
      expect(method.id.uuid, isNotEmpty);
    }

    for (var species in speciesManager.list()) {
      expect(species.id, isNotNull);
      expect(species.id.uuid, isNotEmpty);
    }

    for (var bodyOfWater in bodyOfWaterManager.list()) {
      expect(bodyOfWater.id, isNotNull);
      expect(bodyOfWater.id.uuid, isNotEmpty);
    }
  }

  group("Error cases", () {
    test("Bad input", () async {
      await LegacyImporter(appManager.app, null)
          .start()
          .catchError(expectAsync1((dynamic error) {
        expect(error, equals(LegacyImporterError.invalidZipFile));
      }));
    });

    test("Missing journal key", () async {
      var file = File("test/resources/backups/no_journal.zip");
      await LegacyImporter(appManager.app, file)
          .start()
          .catchError(expectAsync1((dynamic error) {
        expect(error, equals(LegacyImporterError.missingJournal));
      }));
    });

    test("Missing userDefines key", () async {
      var file = File("test/resources/backups/no_user_defines.zip");
      await LegacyImporter(appManager.app, file)
          .start()
          .catchError(expectAsync1((dynamic error) {
        expect(error, equals(LegacyImporterError.missingUserDefines));
      }));
    });
  });

  test("Import legacy iOS", () async {
    var file = File("test/resources/backups/legacy_ios_real.zip");
    await LegacyImporter(appManager.app, file).start();

    // Bait categories were never added to Anglers' Log iOS, so none should
    // be added here.
    expect(baitCategoryManager.entityCount, 0);
    expect(baitManager.entityCount, 87);
    expect(bodyOfWaterManager.entityCount, 30);
    expect(catchManager.entityCount, 167);
    expect(fishingSpotManager.entityCount, 94);
    expect(methodManager.entityCount, 22);
    expect(speciesManager.entityCount, 28);
    expect(waterClarityManager.entityCount, 9);

    verify(appManager.userPreferenceManager
            .setWaterDepthSystem(MeasurementSystem.imperial_whole))
        .called(1);
    verify(appManager.userPreferenceManager
            .setWaterTemperatureSystem(MeasurementSystem.imperial_whole))
        .called(1);
    verify(appManager.userPreferenceManager
            .setCatchLengthSystem(MeasurementSystem.imperial_whole))
        .called(1);
    verify(appManager.userPreferenceManager
            .setCatchWeightSystem(MeasurementSystem.imperial_whole))
        .called(1);
    verify(appManager.userPreferenceManager
            .setAirTemperatureSystem(MeasurementSystem.imperial_whole))
        .called(1);
    verify(appManager.userPreferenceManager
            .setAirPressureSystem(MeasurementSystem.imperial_whole))
        .called(1);
    verify(appManager.userPreferenceManager
            .setAirVisibilitySystem(MeasurementSystem.imperial_whole))
        .called(1);
    verify(appManager.userPreferenceManager
            .setWindSpeedSystem(MeasurementSystem.imperial_whole))
        .called(1);

    var waterDepthCatch = catchManager
        .list()
        .firstWhere((cat) => cat.waterDepth.mainValue.value == 14);
    expect(waterDepthCatch.waterDepth.system, MeasurementSystem.imperial_whole);
    expect(waterDepthCatch.waterDepth.mainValue.value, 14);
    expect(waterDepthCatch.waterDepth.mainValue.unit, Unit.feet);
    expect(waterDepthCatch.waterDepth.hasFractionValue(), isFalse);

    // No water temperature catches in real backup.

    var weightCatch = catchManager
        .list()
        .firstWhere((cat) => cat.weight.mainValue.value == 22);
    expect(weightCatch.weight.system, MeasurementSystem.imperial_whole);
    expect(weightCatch.weight.mainValue.value, 22);
    expect(weightCatch.weight.mainValue.unit, Unit.pounds);
    expect(weightCatch.weight.hasFractionValue(), isFalse);

    var lengthCatch = catchManager
        .list()
        .firstWhere((cat) => cat.length.mainValue.value == 32);
    expect(lengthCatch.length.system, MeasurementSystem.imperial_whole);
    expect(lengthCatch.length.mainValue.value, 32);
    expect(lengthCatch.length.mainValue.unit, Unit.inches);
    expect(lengthCatch.length.hasFractionValue(), isFalse);

    var quantityCatch =
        catchManager.list().firstWhere((cat) => cat.quantity == 6);
    expect(quantityCatch.quantity, 6);

    var notesCatch =
        catchManager.list().firstWhere((cat) => cat.notes == "Caught by Tim.");
    expect(notesCatch.notes, "Caught by Tim.");

    // Weather.
    expect(
      catchManager.list().firstWhere((cat) =>
          cat.hasAtmosphere() &&
          cat.atmosphere.temperature.mainValue.value == 25 &&
          cat.atmosphere.temperature.mainValue.unit == Unit.fahrenheit &&
          cat.atmosphere.windSpeed.mainValue.value == 8 &&
          cat.atmosphere.windSpeed.mainValue.unit == Unit.miles_per_hour &&
          cat.atmosphere.skyConditions.first == SkyCondition.cloudy),
      isNotNull,
    );
    expect(catchManager.list().where((cat) => cat.hasAtmosphere()).length, 53);

    verifyIds();

    // Verify baits are imported correctly.

    // Artificial, color.
    var bigBlue = baitManager.list().firstWhere((e) => e.name == "Big Blue");
    expect(bigBlue.type, Bait_Type.artificial);
    expect(bigBlue.variants.length, 1);
    expect(bigBlue.variants.first.color, "Blue And Silver");

    // Real, size.
    var blueRoe = baitManager.list().firstWhere((e) => e.name == "Blue");
    expect(blueRoe.type, Bait_Type.real);
    expect(blueRoe.variants.length, 1);
    expect(blueRoe.variants.first.size, "Medium");

    // Live, description.
    var crayfish = baitManager.list().firstWhere((e) => e.name == "Crayfish");
    expect(crayfish.type, Bait_Type.live);
    expect(crayfish.variants.length, 1);
    expect(crayfish.variants.first.description,
        "Hooked through the end of the tail.");

    // No variants.
    var leech = baitManager.list().firstWhere((e) => e.name == "Leech");
    expect(leech.variants, isEmpty);
  });

  test("Import legacy Android", () async {
    var file = File("test/resources/backups/legacy_android_real.zip");

    await LegacyImporter(appManager.app, file).start();

    expect(anglerManager.entityCount, 4);
    expect(baitCategoryManager.entityCount, 3);
    expect(baitManager.entityCount, 72);
    expect(bodyOfWaterManager.entityCount, 25);
    expect(catchManager.entityCount, 133);
    expect(fishingSpotManager.entityCount, 75);
    expect(methodManager.entityCount, 19);
    expect(speciesManager.entityCount, 26);
    expect(waterClarityManager.entityCount, 9);

    verify(appManager.userPreferenceManager
            .setWaterDepthSystem(MeasurementSystem.imperial_whole))
        .called(1);
    verify(appManager.userPreferenceManager
            .setWaterTemperatureSystem(MeasurementSystem.imperial_whole))
        .called(1);
    verify(appManager.userPreferenceManager
            .setCatchLengthSystem(MeasurementSystem.imperial_whole))
        .called(1);
    verify(appManager.userPreferenceManager
            .setCatchWeightSystem(MeasurementSystem.imperial_whole))
        .called(1);
    verify(appManager.userPreferenceManager
            .setAirTemperatureSystem(MeasurementSystem.imperial_whole))
        .called(1);
    verify(appManager.userPreferenceManager
            .setAirPressureSystem(MeasurementSystem.imperial_whole))
        .called(1);
    verify(appManager.userPreferenceManager
            .setAirVisibilitySystem(MeasurementSystem.imperial_whole))
        .called(1);
    verify(appManager.userPreferenceManager
            .setWindSpeedSystem(MeasurementSystem.imperial_whole))
        .called(1);

    var waterDepthCatch = catchManager
        .list()
        .firstWhere((cat) => cat.waterDepth.mainValue.value == 14);
    expect(waterDepthCatch.waterDepth.system, MeasurementSystem.imperial_whole);
    expect(waterDepthCatch.waterDepth.mainValue.value, 14);
    expect(waterDepthCatch.waterDepth.mainValue.unit, Unit.feet);
    expect(waterDepthCatch.waterDepth.hasFractionValue(), isFalse);

    // No water temperature catches in real backup.

    var weightCatch = catchManager
        .list()
        .firstWhere((cat) => cat.weight.mainValue.value == 3.25);
    expect(weightCatch.weight.system, MeasurementSystem.imperial_decimal);
    expect(weightCatch.weight.mainValue.value, 3.25);
    expect(weightCatch.weight.mainValue.unit, Unit.pounds);
    expect(weightCatch.weight.hasFractionValue(), isFalse);

    var lengthCatch = catchManager
        .list()
        .firstWhere((cat) => cat.length.mainValue.value == 11);
    expect(lengthCatch.length.system, MeasurementSystem.imperial_whole);
    expect(lengthCatch.length.mainValue.value, 11);
    expect(lengthCatch.length.mainValue.unit, Unit.inches);
    expect(lengthCatch.length.hasFractionValue(), isFalse);

    var quantityCatch =
        catchManager.list().firstWhere((cat) => cat.quantity == 16);
    expect(quantityCatch.quantity, 16);

    // 1 quantity catch should not set quantity property.
    // Fixes: https://github.com/cohenadair/anglers-log/issues/537
    var timestamp = DateFormat("M-d-y_h-m_a_s.S")
        .parse("09-30-2017_11-50_AM_14.442")
        .millisecondsSinceEpoch;
    var singleQuantity =
        catchManager.list().firstWhere((cat) => cat.timestamp == timestamp);
    expect(singleQuantity.hasQuantity(), isFalse);

    var notesCatch = catchManager.list().firstWhere((cat) =>
        cat.notes == "Casting downstream close to shore in very slow water.");
    expect(notesCatch.notes,
        "Casting downstream close to shore in very slow water.");

    // Weather.
    expect(
      catchManager.list().firstWhere((cat) =>
          cat.hasAtmosphere() &&
          cat.atmosphere.temperature.mainValue.value == 68 &&
          cat.atmosphere.temperature.mainValue.unit == Unit.fahrenheit &&
          cat.atmosphere.windSpeed.mainValue.value == 4 &&
          cat.atmosphere.windSpeed.mainValue.unit == Unit.miles_per_hour &&
          cat.atmosphere.skyConditions.first == SkyCondition.clear),
      isNotNull,
    );
    expect(catchManager.list().where((cat) => cat.hasAtmosphere()).length, 36);

    verifyIds();

    // Verify baits are imported correctly.

    // Artificial, color.
    var bigBlue = baitManager.list().firstWhere((e) => e.name == "Big Blue");
    expect(bigBlue.type, Bait_Type.artificial);
    expect(bigBlue.variants.length, 1);
    expect(bigBlue.variants.first.color, "Blue And Silver");

    // Real, size.
    var blueRoe = baitManager.list().firstWhere((e) => e.name == "Blue");
    expect(blueRoe.type, Bait_Type.real);
    expect(blueRoe.variants.length, 1);
    expect(blueRoe.variants.first.size, "Medium");

    // Live, description.
    var crayfish = baitManager.list().firstWhere((e) => e.name == "Crayfish");
    expect(crayfish.type, Bait_Type.live);
    expect(crayfish.variants.length, 1);
    expect(crayfish.variants.first.description,
        "Hooked through the end of the tail.");

    // No variants.
    var leech = baitManager.list().firstWhere((e) => e.name == "Leech");
    expect(leech.variants, isEmpty);
  });

  test("Empty user defines", () async {
    var file = File("test/resources/backups/legacy_empty_entities.zip");
    await LegacyImporter(appManager.app, file).start();
    expect(baitCategoryManager.entityCount, 0);
    expect(baitManager.entityCount, 0);
    expect(catchManager.entityCount, 0);
    expect(fishingSpotManager.entityCount, 0);
    expect(speciesManager.entityCount, 0);
  });

  testWidgets("Import iOS catches", (tester) async {
    var file = File("test/resources/backups/legacy_ios_entities.zip");
    await LegacyImporter(appManager.app, file).start();

    var context = await buildContext(tester);
    var catches = catchManager.catches(context);

    expect(catches, isNotNull);
    expect(catches.length, 4);

    expect(catches[0].timestamp.toInt(),
        DateTime(2019, 8, 13, 0, 44).millisecondsSinceEpoch);
    expect(catches[0].hasTimeZone(), isTrue);
    expect(catches[0].hasFishingSpotId(), isTrue);
    expect(speciesManager.entity(catches[0].speciesId)!.name, "Carp - Common");
    expect(catches[0].baits, isNotEmpty);
    expect(baitManager.entity(catches[0].baits.first.baitId)!.name, "Corn");
    expect(catches[0].baits.first.hasVariantId(), isTrue);
    expect(catches[0].hasFishingSpotId(), isTrue);
    expect(fishingSpotManager.entity(catches[0].fishingSpotId)!.name,
        "Sequoyah Hills Park");
    expect(catches[0].methodIds.length, 2);
    expect(catches[0].wasCatchAndRelease, isTrue);
    expect(catches[0].hasIsFavorite(), isFalse);
    expect(methodManager.entity(catches[0].methodIds[0])!.name, "Still");
    expect(methodManager.entity(catches[0].methodIds[1])!.name, "Bottom");

    var measuredCatch =
        catches.firstWhere((cat) => cat.length.mainValue.value == 15.75);
    expect(measuredCatch.hasWaterDepth(), isFalse);
    expect(measuredCatch.hasWaterTemperature(), isFalse);
    expect(measuredCatch.hasQuantity(), isFalse);
    expect(measuredCatch.hasNotes(), isFalse);
    expect(measuredCatch.length.system, MeasurementSystem.imperial_decimal);
    expect(measuredCatch.length.mainValue.value, 15.75);
    expect(measuredCatch.length.mainValue.unit, Unit.inches);
    expect(measuredCatch.length.hasFractionValue(), isFalse);
    expect(measuredCatch.weight.system, MeasurementSystem.imperial_whole);
    expect(measuredCatch.weight.mainValue.value, 7);
    expect(measuredCatch.weight.mainValue.unit, Unit.pounds);
    expect(measuredCatch.weight.fractionValue.value, 4);
    expect(measuredCatch.weight.fractionValue.unit, Unit.ounces);

    expect(catches[1].timestamp.toInt(),
        DateTime(2019, 8, 12, 12, 44).millisecondsSinceEpoch);
    expect(catches[1].hasTimeZone(), isTrue);
    expect(catches[1].hasWasCatchAndRelease(), isFalse);

    expect(catches[2].timestamp.toInt(),
        DateTime(2019, 8, 11, 8, 44).millisecondsSinceEpoch);
    expect(catches[2].hasTimeZone(), isTrue);
    expect(catches[2].hasWasCatchAndRelease(), isFalse);

    expect(catches[3].timestamp.toInt(),
        DateTime(2019, 8, 10, 20, 44).millisecondsSinceEpoch);
    expect(catches[3].hasTimeZone(), isTrue);
    expect(catches[3].wasCatchAndRelease, isTrue);
    expect(catches[3].hasWaterClarityId(), isFalse);

    // Three methods are set on catches, but only two actually exist. Verify
    // nothing bad happens when a method is found that doesn't exist.
    expect(methodManager.entityCount, 2);
  });

  testWidgets("Import iOS catches with lowercase 'AM' time", (tester) async {
    var file = File("test/resources/backups/legacy_ios_lowercase_am.zip");
    await LegacyImporter(appManager.app, file).start();

    var context = await buildContext(tester);
    var catches = catchManager.catches(context);

    expect(catches, isNotNull);
    expect(catches.length, 1);

    expect(catches[0].timestamp.toInt(),
        DateTime(2021, 10, 2, 6, 10).millisecondsSinceEpoch);
  });

  test("Import iOS locations", () async {
    var file = File("test/resources/backups/legacy_ios_entities.zip");
    await LegacyImporter(appManager.app, file).start();

    var fishingSpots = fishingSpotManager.list();
    expect(fishingSpots, isNotNull);
    expect(fishingSpots.length, 1);
    expect(fishingSpots.first.name, "Sequoyah Hills Park");
    expect(fishingSpots.first.lat, 35.928575);
    expect(fishingSpots.first.lng, -83.974535);
    expect(fishingSpots.first.hasBodyOfWaterId(), isTrue);

    var bodiesOfWater = bodyOfWaterManager.list();
    expect(bodiesOfWater.length, 1);
    expect(bodiesOfWater.first.name, "Tennessee River");
  });

  test("Import iOS baits", () async {
    var file = File("test/resources/backups/legacy_ios_entities.zip");
    await LegacyImporter(appManager.app, file).start();

    // Note that imageName is tested in the tests that import photos. In this
    // test, photos are not included in the test .zip file.

    var baits = baitManager.list();
    expect(baits, isNotNull);
    expect(baits.length, 1);
    expect(baits.first.name, "Corn");
    expect(baits.first.hasBaitCategoryId(), false);
    expect(baits.first.type, Bait_Type.real);
    expect(baits.first.variants.length, 1);
    expect(baits.first.variants.first.hasId(), isTrue);
    expect(baits.first.variants.first.hasBaseId(), isTrue);
    expect(baits.first.variants.first.description, "4-5 on line, 2-3 on hook.");
    expect(baits.first.variants.first.hasSize(), isFalse);
    expect(baits.first.variants.first.hasColor(), isFalse);
  });

  test("Import iOS species", () async {
    var file = File("test/resources/backups/legacy_ios_entities.zip");
    await LegacyImporter(appManager.app, file).start();

    var species = speciesManager.list();
    expect(species, isNotNull);
    expect(species.length, 1);
    expect(species.first.name, "Carp - Common");
  });

  test("Import iOS fishing methods", () async {
    var file = File("test/resources/backups/legacy_ios_entities.zip");
    await LegacyImporter(appManager.app, file).start();

    var methods = methodManager.list();
    expect(methods, isNotNull);
    expect(methods.length, 2);
    expect(methods.first.name, "Still");
    expect(methods.last.name, "Bottom");
  });

  test("Import iOS water clarities", () async {
    var file = File("test/resources/backups/legacy_ios_real.zip");
    await LegacyImporter(appManager.app, file).start();

    var clarities = waterClarityManager.list();
    expect(clarities, isNotNull);
    expect(clarities.length, 9);
    expect(clarities.first.name, "3 Feet");
    expect(clarities.last.name, "Tea Stained");
  });

  testWidgets("Import iOS 24h time", (tester) async {
    var file = File("test/resources/backups/legacy_ios_24h.zip");
    var context = await buildContext(tester);
    await LegacyImporter(appManager.app, file).start();

    expect(catchManager.entityCount, greaterThan(0));
    expect(
      catchManager.catches(context).first.dateTime(context),
      TZDateTime(getLocation(defaultTimeZone), 2022, 5, 10, 18, 7),
    );
  });

  testWidgets("Import iOS dotted AM", (tester) async {
    var file = File("test/resources/backups/legacy_ios_dotted_am.zip");
    var context = await buildContext(tester);
    await LegacyImporter(appManager.app, file).start();

    expect(catchManager.entityCount, greaterThan(0));
    expect(
      catchManager.catches(context).first.dateTime(context),
      TZDateTime(getLocation(defaultTimeZone), 2020, 8, 18, 9, 39),
    );
  });

  testWidgets("Import iOS images", (tester) async {
    var zip = File("test/resources/backups/legacy_ios_photos.zip");

    var importedImages = <File>[];
    when(imageManager.save(any, compress: anyNamed("compress")))
        .thenAnswer((invocation) {
      importedImages.addAll(invocation.positionalArguments[0]);
      return Future.value(
          importedImages.map((f) => path.basename(f.path)).toList());
    });

    await LegacyImporter(appManager.app, zip).start();

    var context = await buildContext(tester);

    var catches = catchManager.catches(context);
    expect(catches, isNotNull);
    expect(catches.length, 2);

    var baits = baitManager.list();
    expect(baits, isNotNull);
    expect(baits.length, 2);

    expect(importedImages.length, 5);
  });

  test("Import Android catches", () async {
    var file = File("test/resources/backups/legacy_android_entities.zip");
    await LegacyImporter(appManager.app, file).start();

    var catches = catchManager.list();
    expect(catches, isNotNull);
    expect(catches.length, 1);

    expect(catches[0].timestamp.toInt(),
        DateTime(2017, 10, 11, 17, 19, 19, 420).millisecondsSinceEpoch);
    expect(catches[0].hasTimeZone(), isTrue);
    expect(catches[0].hasFishingSpotId(), isTrue);
    expect(
        speciesManager.entity(catches[0].speciesId)!.name, "Trout - Rainbow");
    expect(catches[0].baits, isNotEmpty);
    expect(baitManager.entity(catches[0].baits.first.baitId)!.name,
        "Rapala F-7 - Brown Trout");
    expect(catches[0].baits.first.hasVariantId(), isTrue);
    expect(catches[0].hasFishingSpotId(), isTrue);
    expect(
        fishingSpotManager.entity(catches[0].fishingSpotId)!.name, "Sewer Run");
    expect(catches[0].methodIds.length, 3);
    expect(catches[0].hasWasCatchAndRelease(), isFalse);
    expect(catches[0].hasIsFavorite(), isFalse);
    expect(catches[0].hasWaterClarityId(), isFalse);
    expect(methodManager.entity(catches[0].methodIds[0])!.name, "Casting");
    expect(methodManager.entity(catches[0].methodIds[1])!.name, "Lure");
    expect(methodManager.entity(catches[0].methodIds[2])!.name, "Wade");

    var measuredCatch =
        catches.firstWhere((cat) => cat.length.mainValue.value == 22);
    expect(measuredCatch.waterDepth.system, MeasurementSystem.imperial_whole);
    expect(measuredCatch.waterDepth.mainValue.value, 3);
    expect(measuredCatch.waterDepth.mainValue.unit, Unit.feet);
    expect(measuredCatch.waterDepth.hasFractionValue(), isFalse);
    expect(measuredCatch.waterTemperature.system,
        MeasurementSystem.imperial_whole);
    expect(measuredCatch.waterTemperature.mainValue.value, 61);
    expect(measuredCatch.waterTemperature.mainValue.unit, Unit.fahrenheit);
    expect(measuredCatch.waterTemperature.hasFractionValue(), isFalse);
    expect(measuredCatch.length.system, MeasurementSystem.imperial_whole);
    expect(measuredCatch.length.mainValue.value, 22);
    expect(measuredCatch.length.mainValue.unit, Unit.inches);
    expect(measuredCatch.length.hasFractionValue(), isFalse);
    expect(measuredCatch.weight.system, MeasurementSystem.imperial_decimal);
    expect(measuredCatch.weight.mainValue.value, 3.5);
    expect(measuredCatch.weight.mainValue.unit, Unit.pounds);
    expect(measuredCatch.weight.hasFractionValue(), isFalse);
    expect(measuredCatch.quantity, 5);
    expect(measuredCatch.hasNotes(), isFalse);
  });

  test("Import Android locations", () async {
    var file = File("test/resources/backups/legacy_android_entities.zip");
    await LegacyImporter(appManager.app, file).start();

    var fishingSpots = fishingSpotManager.list();
    expect(fishingSpots, isNotNull);
    expect(fishingSpots.length, 1);
    expect(fishingSpots.first.name, "Sewer Run");
    expect(fishingSpots.first.lat, 50.943077);
    expect(fishingSpots.first.lng, -114.013481);
    expect(fishingSpots.first.hasBodyOfWaterId(), isTrue);

    var bodiesOfWater = bodyOfWaterManager.list();
    expect(bodiesOfWater.length, 1);
    expect(bodiesOfWater.first.name, "Bow River");
  });

  testWidgets("Import Android baits", (tester) async {
    var file = File("test/resources/backups/legacy_android_entities.zip");
    await LegacyImporter(appManager.app, file).start();

    // Note that imageName is tested in the tests that import photos. In this
    // test, photos are not included in the test .zip file.

    var baits = baitManager.listSortedByDisplayName(await buildContext(tester));
    expect(baits, isNotNull);
    expect(baits.length, 2);

    expect(baits[0].name, "Rapala F-7 - Brown Trout");
    expect(baits[0].hasBaitCategoryId(), true);
    expect(baitCategoryManager.entity(baits[0].baitCategoryId)!.name, "Other");
    expect(baits[0].type, Bait_Type.artificial);
    expect(baits[0].variants.length, 1);
    expect(baits[0].variants.first.hasId(), isTrue);
    expect(baits[0].variants.first.hasBaseId(), isTrue);
    expect(baits[0].variants.first.description, "Depth 3-5'.");
    expect(baits[0].variants.first.size, "F-7");
    expect(baits[0].variants.first.color, "Brown Trout");

    expect(baits[1].name, "Z-Man");
    expect(baits[1].hasBaitCategoryId(), false);
    expect(baits[1].type, Bait_Type.artificial);
    expect(baits[1].variants.length, 1);
    expect(baits[1].variants.first.hasId(), isTrue);
    expect(baits[1].variants.first.hasBaseId(), isTrue);
    expect(baits[1].variants.first.description, "Depth 3-5'.");
    expect(baits[1].variants.first.size, "F-7");
    expect(baits[1].variants.first.color, "Brown Trout");
  });

  test("Import Android species", () async {
    var file = File("test/resources/backups/legacy_android_entities.zip");
    await LegacyImporter(appManager.app, file).start();

    var species = speciesManager.list();
    expect(species, isNotNull);
    expect(species.length, 1);
    expect(species.first.name, "Trout - Rainbow");
  });

  test("Import Android bait categories", () async {
    var file = File("test/resources/backups/legacy_android_entities.zip");
    await LegacyImporter(appManager.app, file).start();

    var categories = baitCategoryManager.list();
    expect(categories, isNotNull);
    expect(categories.length, 1);
    expect(categories.first.id.uuid, "b860cddd-dc47-48a2-8d02-c8112a2ed5eb");
    expect(categories.first.name, "Other");
  });

  test("Import Android anglers", () async {
    var file = File("test/resources/backups/legacy_android_entities.zip");
    await LegacyImporter(appManager.app, file).start();

    var categories = anglerManager.list();
    expect(categories, isNotNull);
    expect(categories.length, 4);
    expect(categories.first.id.uuid, "a0bf8683-675d-4759-8da8-34f81545ad69");
    expect(categories.first.name, "Cohen");
  });

  test("Import Android fishing methods", () async {
    var file = File("test/resources/backups/legacy_android_entities.zip");
    await LegacyImporter(appManager.app, file).start();

    var methods = methodManager.list();
    expect(methods, isNotNull);
    expect(methods.length, 19);
    expect(methods.first.id.uuid, "6d071b7d-c575-4142-a48a-e984a71e86b8");
    expect(methods.first.name, "Baitcaster");
  });

  test("Import Android water clarities", () async {
    var file = File("test/resources/backups/legacy_android_real.zip");
    await LegacyImporter(appManager.app, file).start();

    var clarities = waterClarityManager.list();
    expect(clarities, isNotNull);
    expect(clarities.length, 9);
    expect(clarities.first.name, "3 Feet");
    expect(clarities.last.name, "Tea Stained");
  });

  test("Import Android Rick (0 lat/lng values)", () async {
    var file = File("test/resources/backups/rick.zip");
    await LegacyImporter(appManager.app, file).start();

    var fishingSpots = fishingSpotManager.list();
    expect(fishingSpots.where((spot) => spot.lat == 0), isNotEmpty);
    expect(fishingSpots.where((spot) => spot.lng == 0), isNotEmpty);
    expect(fishingSpots.where((spot) => !spot.lat.isWhole), isNotEmpty);
    expect(fishingSpots.where((spot) => !spot.lng.isWhole), isNotEmpty);
  });

  test("Import Android weather measurement system defaults to global system",
      () async {
    var file = File("test/resources/backups/no_weather_system.zip");
    await LegacyImporter(appManager.app, file).start();

    var result = verify(
        appManager.userPreferenceManager.setAirPressureSystem(captureAny));
    result.called(1);
    expect(result.captured.first, MeasurementSystem.metric);

    result = verify(
        appManager.userPreferenceManager.setAirTemperatureSystem(captureAny));
    result.called(1);
    expect(result.captured.first, MeasurementSystem.metric);

    result = verify(
        appManager.userPreferenceManager.setAirVisibilitySystem(captureAny));
    result.called(1);
    expect(result.captured.first, MeasurementSystem.metric);

    result =
        verify(appManager.userPreferenceManager.setWindSpeedSystem(captureAny));
    result.called(1);
    expect(result.captured.first, MeasurementSystem.metric);
  });

  test("Import Android weather measurement system metric", () async {
    var file = File("test/resources/backups/weather_system.zip");
    await LegacyImporter(appManager.app, file).start();

    var result = verify(
        appManager.userPreferenceManager.setWaterDepthSystem(captureAny));
    result.called(1);
    expect(result.captured.first, MeasurementSystem.imperial_whole);

    result = verify(
        appManager.userPreferenceManager.setWaterTemperatureSystem(captureAny));
    result.called(1);
    expect(result.captured.first, MeasurementSystem.imperial_whole);

    result = verify(
        appManager.userPreferenceManager.setCatchLengthSystem(captureAny));
    result.called(1);
    expect(result.captured.first, MeasurementSystem.imperial_whole);

    result = verify(
        appManager.userPreferenceManager.setCatchWeightSystem(captureAny));
    result.called(1);
    expect(result.captured.first, MeasurementSystem.imperial_whole);

    result = verify(
        appManager.userPreferenceManager.setAirPressureSystem(captureAny));
    result.called(1);
    expect(result.captured.first, MeasurementSystem.metric);

    result = verify(
        appManager.userPreferenceManager.setAirTemperatureSystem(captureAny));
    result.called(1);
    expect(result.captured.first, MeasurementSystem.metric);

    result = verify(
        appManager.userPreferenceManager.setAirVisibilitySystem(captureAny));
    result.called(1);
    expect(result.captured.first, MeasurementSystem.metric);

    result =
        verify(appManager.userPreferenceManager.setWindSpeedSystem(captureAny));
    result.called(1);
    expect(result.captured.first, MeasurementSystem.metric);
  });

  testWidgets("Import Android favorite catches", (tester) async {
    var file = File("test/resources/backups/legacy_android_real.zip");
    await LegacyImporter(appManager.app, file).start();

    var catches = catchManager.catches(
      await buildContext(tester),
      opt: CatchFilterOptions(
        isFavoritesOnly: true,
      ),
    );
    expect(catches.length, 3);

    var hasIsFavoriteCount = 0;
    for (var cat in catchManager.list()) {
      hasIsFavoriteCount += cat.hasIsFavorite() ? 1 : 0;
    }
    expect(hasIsFavoriteCount, 3);
  });

  testWidgets("Import Android images", (tester) async {
    var zip = File("test/resources/backups/legacy_android_photos.zip");

    var importedImages = <File>[];
    when(imageManager.save(any, compress: anyNamed("compress")))
        .thenAnswer((invocation) {
      importedImages.addAll(invocation.positionalArguments[0]);
      return Future.value(
          importedImages.map((f) => path.basename(f.path)).toList());
    });

    await LegacyImporter(appManager.app, zip).start();

    var context = await buildContext(tester);

    var catches = catchManager.catches(context);
    expect(catches, isNotNull);
    expect(catches.length, 2);

    var baits = baitManager.list();
    expect(baits, isNotNull);
    expect(baits.length, 2);

    expect(importedImages.length, 5);
  });

  test("Import metric units", () async {
    var file = File("test/resources/backups/metric.zip");
    await LegacyImporter(appManager.app, file).start();

    verify(appManager.userPreferenceManager
            .setWaterDepthSystem(MeasurementSystem.metric))
        .called(1);
    verify(appManager.userPreferenceManager
            .setWaterTemperatureSystem(MeasurementSystem.metric))
        .called(1);
    verify(appManager.userPreferenceManager
            .setCatchLengthSystem(MeasurementSystem.metric))
        .called(1);
    verify(appManager.userPreferenceManager
            .setCatchWeightSystem(MeasurementSystem.metric))
        .called(1);
    verify(appManager.userPreferenceManager
            .setAirTemperatureSystem(MeasurementSystem.metric))
        .called(1);
    verify(appManager.userPreferenceManager
            .setAirPressureSystem(MeasurementSystem.metric))
        .called(1);
    verify(appManager.userPreferenceManager
            .setAirVisibilitySystem(MeasurementSystem.metric))
        .called(1);
    verify(appManager.userPreferenceManager
            .setWindSpeedSystem(MeasurementSystem.metric))
        .called(1);

    var cat = catchManager.list().first;
    expect(
      cat.hasAtmosphere() &&
          cat.atmosphere.temperature.mainValue.value == 81 &&
          cat.atmosphere.temperature.mainValue.unit == Unit.celsius &&
          cat.atmosphere.windSpeed.mainValue.value == 0.47 &&
          cat.atmosphere.windSpeed.mainValue.unit == Unit.kilometers_per_hour &&
          cat.atmosphere.skyConditions.first == SkyCondition.clear,
      isTrue,
    );
  });

  group("Migration", () {
    test("Error from platform channel throws assertion", () async {
      var importer = LegacyImporter.migrate(
        appManager.app,
        LegacyJsonResult(
          errorCode: LegacyJsonErrorCode.missingData,
        ),
      );

      await importer.start().catchError(expectAsync1((dynamic error) {
        expect(error, isNotNull);
        expect(error is AssertionError, isTrue);
      }));
    });

    test("Error in migration doesn't delete old data", () async {
      var img0 = MockFileSystemEntity();
      when(img0.path).thenReturn("img0.png");

      var img1 = MockFileSystemEntity();
      when(img1.path).thenReturn("img1.png");

      var imagesDir = MockDirectory();
      when(imagesDir.path).thenReturn("test/images");
      when(imagesDir.listSync()).thenReturn([img0, img1]);
      when(ioWrapper.directory("test/images")).thenReturn(imagesDir);
      when(ioWrapper.isFileSync(any)).thenReturn(true);

      var databaseDir = MockDirectory();
      when(ioWrapper.directory("test/database")).thenReturn(databaseDir);

      when(ioWrapper.file(any)).thenReturn(MockFile());

      var importer = LegacyImporter.migrate(
        appManager.app,
        LegacyJsonResult(
          databasePath: "test/database",
          imagesPath: "test/images",
          json: {},
        ),
      );
      await importer.start().catchError(expectAsync1((dynamic error) {
        expect(error, equals(LegacyImporterError.missingJournal));
        verify(ioWrapper.file(any)).called(2);
        verifyNever(imagesDir.deleteSync());
        verifyNever(databaseDir.deleteSync(recursive: true));
      }));
    });

    test("Only File types are accepted as valid images", () async {
      var imagesDir = MockDirectory();
      when(imagesDir.path).thenReturn("Images");
      when(imagesDir.listSync()).thenReturn([
        File("img1.jpg"),
        Directory("AnglersLog'"),
        File("img2.jpg"),
        File("img3.jpg"),
        Directory("AnglersLog'2"),
      ]);
      when(ioWrapper.directory("test/images")).thenReturn(imagesDir);
      when(ioWrapper.file(any)).thenReturn(MockFile());
      when(ioWrapper.isFileSync(any)).thenAnswer((invocation) =>
          (invocation.positionalArguments.first as String).endsWith(".jpg"));
      var importer = LegacyImporter.migrate(
        appManager.app,
        LegacyJsonResult(
          databasePath: "test/database",
          imagesPath: "test/images",
          json: {},
        ),
      );

      await importer.start().catchError((e) {});
      verifyNever(ioWrapper.file("AnglersLog'"));
      verifyNever(ioWrapper.file("AnglersLog'2"));
      verify(ioWrapper.file(any)).called(3);
    });

    test("Error in image cleanup continues on to the next image", () async {
      var mockFile1 = MockFile();
      when(mockFile1.path).thenReturn("img1.jpg");
      when(mockFile1.existsSync()).thenReturn(true);
      when(mockFile1.deleteSync(recursive: true)).thenAnswer((_) => mockFile1);

      var mockFile2 = MockFile();
      when(mockFile2.path).thenReturn("img2.jpg");
      when(mockFile2.existsSync()).thenReturn(true);
      when(mockFile2.deleteSync(recursive: true)).thenAnswer((_) => mockFile2);

      var mockFile3 = MockFile();
      when(mockFile3.path).thenReturn("img3.jpg");
      when(mockFile3.existsSync()).thenReturn(true);
      when(mockFile3.deleteSync(recursive: true)).thenAnswer((_) => mockFile3);

      var mockDir = MockDirectory();
      when(mockDir.path).thenReturn("test/images/images");

      var imagesDir = MockDirectory();
      when(imagesDir.path).thenReturn("test/images");
      when(imagesDir.existsSync()).thenReturn(true);
      when(imagesDir.deleteSync(recursive: true)).thenAnswer((_) => imagesDir);
      when(imagesDir.listSync()).thenReturn([
        mockFile1,
        mockDir,
        mockFile2,
        mockFile3,
      ]);
      when(ioWrapper.directory("test/images")).thenReturn(imagesDir);
      when(ioWrapper.file(any)).thenAnswer((invocation) {
        var path = invocation.positionalArguments.first as String;
        if (path == "test/images/img1.jpg") {
          return mockFile1;
        } else if (path == "test/images/img2.jpg") {
          return mockFile2;
        } else if (path == "test/images/img3.jpg") {
          return mockFile3;
        } else {
          var file = MockFile();
          when(file.path).thenReturn("test/images/images");
          when(file.deleteSync(recursive: true)).thenThrow(Exception());
          when(file.existsSync()).thenReturn(true);
          return file;
        }
      });
      when(ioWrapper.isFileSync(any)).thenReturn(true);

      var databaseDir = MockDirectory();
      when(databaseDir.deleteSync(recursive: true))
          .thenAnswer((_) => databaseDir);
      when(databaseDir.existsSync()).thenReturn(true);
      when(ioWrapper.directory("test/database")).thenReturn(databaseDir);

      var importer = LegacyImporter.migrate(
        appManager.app,
        LegacyJsonResult(
          databasePath: "test/database",
          imagesPath: "test/images",
          json: {
            "journal": {
              "userDefines": [],
            },
          },
        ),
      );

      await importer.start();
      verify(mockFile1.deleteSync(recursive: true)).called(1);
      verify(mockFile2.deleteSync(recursive: true)).called(1);
      verify(mockFile3.deleteSync(recursive: true)).called(1);
    });

    test("Successful migration deletes old data", () async {
      var imagesDir = MockDirectory();
      when(imagesDir.deleteSync(recursive: true))
          .thenAnswer((_) => Future.value(imagesDir));
      when(imagesDir.existsSync()).thenReturn(true);
      when(imagesDir.listSync()).thenReturn([]);
      when(ioWrapper.directory("test/images")).thenReturn(imagesDir);

      var databaseDir = MockDirectory();
      when(databaseDir.deleteSync(recursive: true))
          .thenAnswer((_) => Future.value(databaseDir));
      when(databaseDir.existsSync()).thenReturn(true);
      when(ioWrapper.directory("test/database")).thenReturn(databaseDir);

      var called = false;
      var importer = LegacyImporter.migrate(
        appManager.app,
        LegacyJsonResult(
          databasePath: "test/database",
          imagesPath: "test/images",
          json: {
            "journal": {
              "userDefines": [],
            },
          },
        ),
        () => called = true,
      );
      await importer.start();
      verify(imagesDir.deleteSync(recursive: true)).called(1);
      verify(databaseDir.deleteSync(recursive: true)).called(1);
      expect(called, isTrue);
    });
  });

  group("Importing Android trips", () {
    test("Empty", () async {
      var file = File("test/resources/backups/legacy_android_entities.zip");
      await LegacyImporter(appManager.app, file).start();
      expect(tripManager.entityCount, 0);
    });

    test("Null", () async {
      var file = File("test/resources/backups/legacy_android_null_trips.zip");
      await LegacyImporter(appManager.app, file).start();
      expect(tripManager.entityCount, 0);
    });

    test("Bad catch ID", () async {
      var file = File("test/resources/backups/legacy_android_bad_catch_id.zip");
      await LegacyImporter(appManager.app, file).start();

      var trips = tripManager.list();
      expect(trips.length, 1);

      expect(trips[0].catchIds, isEmpty);
    });

    test("Fishing spot not found", () async {
      var mockFishingSpotManager = MockFishingSpotManager();
      when(mockFishingSpotManager.addOrUpdate(any))
          .thenAnswer((_) => Future.value(true));
      when(mockFishingSpotManager.namedWithBodyOfWater(any, any))
          .thenReturn(null);
      when(mockFishingSpotManager.entity(any)).thenReturn(null);

      when(appManager.app.fishingSpotManager)
          .thenReturn(mockFishingSpotManager);

      var file = File("test/resources/backups/legacy_android_trips.zip");
      await LegacyImporter(appManager.app, file).start();

      expect(tripManager.entityCount, 6);
      for (var trip in tripManager.list()) {
        expect(trip.catchesPerFishingSpot, isEmpty);
      }
    });

    test("Angler not found", () async {
      var mockAnglerManager = MockAnglerManager();
      when(mockAnglerManager.addOrUpdate(any))
          .thenAnswer((_) => Future.value(true));
      when(mockAnglerManager.named(any)).thenReturn(null);
      when(mockAnglerManager.entity(any)).thenReturn(null);

      when(appManager.app.anglerManager).thenReturn(mockAnglerManager);

      var file = File("test/resources/backups/legacy_android_trips.zip");
      await LegacyImporter(appManager.app, file).start();

      expect(tripManager.entityCount, 6);
      for (var trip in tripManager.list()) {
        expect(trip.catchesPerAngler, isEmpty);
      }
    });

    test("Body of water not found", () async {
      var mockBodyOfWaterManager = MockBodyOfWaterManager();
      when(mockBodyOfWaterManager.addOrUpdate(any))
          .thenAnswer((_) => Future.value(true));
      when(mockBodyOfWaterManager.named(any)).thenReturn(null);
      when(mockBodyOfWaterManager.entity(any)).thenReturn(null);

      when(appManager.app.bodyOfWaterManager)
          .thenReturn(mockBodyOfWaterManager);

      var file = File("test/resources/backups/legacy_android_trips.zip");
      await LegacyImporter(appManager.app, file).start();

      expect(tripManager.entityCount, 6);
      for (var trip in tripManager.list()) {
        expect(trip.bodyOfWaterIds, isEmpty);
      }
    });

    test("Real archive", () async {
      var file = File("test/resources/backups/legacy_android_trips.zip");
      await LegacyImporter(appManager.app, file).start();

      var trips = tripManager.list();
      expect(trips.length, 6);

      expect(trips[0].hasName(), isFalse);
      expect(trips[0].id.uuid, "b780e09b-4f49-4234-8b72-eb6f5af7950c");
      expect(trips[0].startTimestamp.toInt(), 1634994545263);
      expect(trips[0].endTimestamp.toInt(), 1634994545263);
      expect(trips[0].hasTimeZone(), isTrue);
      expect(trips[0].notes, "Test notes");
      expect(trips[0].catchIds, isEmpty);
      expect(trips[0].bodyOfWaterIds, isEmpty);
      expect(trips[0].catchesPerFishingSpot, isEmpty);
      expect(trips[0].catchesPerSpecies, isEmpty);
      expect(trips[0].catchesPerAngler, isEmpty);
      expect(trips[0].catchesPerBait, isEmpty);

      expect(trips[1].hasName(), isFalse);
      expect(trips[1].id.uuid, "2745b7bc-6dc9-4374-97f6-c1a658e58cbc");
      expect(trips[1].startTimestamp.toInt(), 1634994539341);
      expect(trips[1].endTimestamp.toInt(), 1634994539341);
      expect(trips[1].hasTimeZone(), isTrue);
      expect(trips[1].hasNotes(), isFalse);
      expect(trips[1].catchIds, isEmpty);
      expect(trips[1].bodyOfWaterIds, isEmpty);
      expect(trips[1].catchesPerFishingSpot, isEmpty);
      expect(trips[1].catchesPerSpecies, isEmpty);
      expect(trips[1].catchesPerAngler.length, 1);
      expect(trips[1].catchesPerBait, isEmpty);

      expect(trips[2].hasName(), isFalse);
      expect(trips[2].id.uuid, "9f946bb9-9cf6-4f92-ac13-459f7258a481");
      expect(trips[2].startTimestamp.toInt(), 1634994531574);
      expect(trips[2].endTimestamp.toInt(), 1634994531574);
      expect(trips[2].hasTimeZone(), isTrue);
      expect(trips[2].hasNotes(), isFalse);
      expect(trips[2].catchIds, isEmpty);
      expect(trips[2].bodyOfWaterIds.length, 1);
      expect(trips[2].catchesPerFishingSpot, isEmpty);
      expect(trips[2].catchesPerSpecies, isEmpty);
      expect(trips[2].catchesPerAngler, isEmpty);
      expect(trips[2].catchesPerBait, isEmpty);

      expect(trips[3].hasName(), isFalse);
      expect(trips[3].id.uuid, "9202107d-f70d-4eb6-9e39-cf92a06fb9e8");
      expect(trips[3].startTimestamp.toInt(), 1634994521794);
      expect(trips[3].endTimestamp.toInt(), 1634994521794);
      expect(trips[3].hasTimeZone(), isTrue);
      expect(trips[3].hasNotes(), isFalse);
      expect(trips[3].catchIds.length, 1);
      expect(trips[3].bodyOfWaterIds, isEmpty);
      expect(trips[3].catchesPerFishingSpot.length, 1);
      expect(trips[3].catchesPerSpecies.length, 1);
      expect(trips[3].catchesPerAngler, isEmpty);
      expect(trips[3].catchesPerBait.length, 1);

      expect(trips[4].hasName(), isFalse);
      expect(trips[4].id.uuid, "c2b35154-4cd1-46a4-a8ca-acf8ad61dcaa");
      expect(trips[4].startTimestamp.toInt(), 1634994510186);
      expect(trips[4].endTimestamp.toInt(), 1634994510186);
      expect(trips[4].hasTimeZone(), isTrue);
      expect(trips[4].hasNotes(), isFalse);
      expect(trips[4].catchIds, isEmpty);
      expect(trips[4].bodyOfWaterIds, isEmpty);
      expect(trips[4].catchesPerFishingSpot, isEmpty);
      expect(trips[4].catchesPerSpecies, isEmpty);
      expect(trips[4].catchesPerAngler, isEmpty);
      expect(trips[4].catchesPerBait, isEmpty);

      expect(trips[5].name, "Test Trip");
      expect(trips[5].id.uuid, "6d63c1f3-e529-4f70-ad74-4246af54d4a8");
      expect(trips[5].startTimestamp.toInt(), 1618233553796);
      expect(trips[5].endTimestamp.toInt(), 1618492747306);
      expect(trips[5].hasTimeZone(), isTrue);
      expect(trips[5].notes, "A test note");
      expect(trips[5].catchIds.length, 3);
      expect(trips[5].bodyOfWaterIds.length, 2);
      expect(trips[5].catchesPerFishingSpot.length, 3);
      expect(trips[5].catchesPerSpecies.length, 2);
      expect(trips[5].catchesPerSpecies[0].value, 2);
      expect(trips[5].catchesPerSpecies[1].value, 1);
      expect(trips[5].catchesPerAngler.length, 2);
      expect(trips[5].catchesPerBait.length, 2);
      expect(trips[5].catchesPerBait[0].value, 2);
      expect(trips[5].catchesPerBait[1].value, 1);
    });
  });
}
