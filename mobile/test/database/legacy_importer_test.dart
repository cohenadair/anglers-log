import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/custom_entity_value_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/database/legacy_importer.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/species_manager.dart';
import 'package:mockito/mockito.dart';

import '../test_utils.dart';

class MockAppManager extends Mock implements AppManager {}
class MockCustomEntityValueManager extends Mock
    implements CustomEntityValueManager {}
class MockDataManager extends Mock implements DataManager {}
class MockImageManager extends Mock implements ImageManager {}

void main() {
  MockAppManager appManager;
  MockCustomEntityValueManager entityValueManager;
  MockDataManager dataManager;
  MockImageManager imageManager;

  BaitCategoryManager baitCategoryManager;
  BaitManager baitManager;
  CatchManager catchManager;
  FishingSpotManager fishingSpotManager;
  SpeciesManager speciesManager;

  Directory tmpDir;

  setUp(() {
    appManager = MockAppManager();

    entityValueManager = MockCustomEntityValueManager();
    when(appManager.customEntityValueManager).thenReturn(entityValueManager);
    when(entityValueManager.setValues(any, any)).thenAnswer((_) =>
        Future.value());

    dataManager = MockDataManager();
    when(dataManager.insertOrUpdateEntity(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.dataManager).thenReturn(dataManager);

    imageManager = MockImageManager();
    when(imageManager.save(any, any)).thenAnswer((_) => Future.value());
    when(appManager.imageManager).thenReturn(imageManager);

    baitCategoryManager = BaitCategoryManager(appManager);
    when(appManager.baitCategoryManager).thenReturn(baitCategoryManager);

    baitManager = BaitManager(appManager);
    when(appManager.baitManager).thenReturn(baitManager);

    fishingSpotManager = FishingSpotManager(appManager);
    when(appManager.fishingSpotManager).thenReturn(fishingSpotManager);

    catchManager = CatchManager(appManager);
    when(appManager.catchManager).thenReturn(catchManager);

    speciesManager = SpeciesManager(appManager);
    when(appManager.speciesManager).thenReturn(speciesManager);

    // Create a temporary directory for images.
    tmpDir = Directory("test/resources/tmp");
    tmpDir.createSync();
  });

  tearDown(() {
    tmpDir.deleteSync(recursive: true);
  });

  group("Error cases", () {
    test("Bad input", () async {
      await LegacyImporter(appManager, null).start()
          .catchError(expectAsync1((error) {
            expect(error, equals(LegacyImporterError.invalidZipFile));
          }));
    });

    test("Missing journal key", () async {
      File file = File("test/resources/backups/no_journal.zip");
      await LegacyImporter(appManager, file, tmpDir).start()
          .catchError(expectAsync1((error) {
            expect(error, equals(LegacyImporterError.missingJournal));
          }));
    });

    test("Missing userDefines key", () async {
      File file = File("test/resources/backups/no_user_defines.zip");
      await LegacyImporter(appManager, file, tmpDir).start()
          .catchError(expectAsync1((error) {
            expect(error, equals(LegacyImporterError.missingUserDefines));
          }));
    });
  });

  test("Import legacy iOS", () async {
    File file = File("test/resources/backups/legacy_ios_real.zip");
    await LegacyImporter(appManager, file, tmpDir).start();

    // Bait categories were never added to Anglers' Log iOS, so none should
    // be added here.
    expect(baitCategoryManager.entityCount, 0);
    expect(baitManager.entityCount, 87);
    expect(catchManager.entityCount, 167);
    expect(fishingSpotManager.entityCount, 94);
    expect(speciesManager.entityCount, 28);
  });

  test("Import legacy Android", () async {
    File file = File("test/resources/backups/legacy_android_real.zip");

    await LegacyImporter(appManager, file, tmpDir).start();

    expect(baitCategoryManager.entityCount, 3);
    expect(baitManager.entityCount, 72);
    expect(catchManager.entityCount, 133);
    expect(fishingSpotManager.entityCount, 75);
    expect(speciesManager.entityCount, 26);
  });

  test("Empty user defines", () async {
    File file = File("test/resources/backups/legacy_empty_entities.zip");
    await LegacyImporter(appManager, file, tmpDir).start();
    expect(baitCategoryManager.entityCount, 0);
    expect(baitManager.entityCount, 0);
    expect(catchManager.entityCount, 0);
    expect(fishingSpotManager.entityCount, 0);
    expect(speciesManager.entityCount, 0);
  });

  testWidgets("Import iOS catches", (WidgetTester tester) async {
    File file = File("test/resources/backups/legacy_ios_entities.zip");
    await LegacyImporter(appManager, file, tmpDir).start();

    BuildContext context = await buildContext(tester);
    List<Catch> catches = catchManager.catchesSortedByTimestamp(context);

    expect(catches, isNotNull);
    expect(catches.length, 4);

    expect(catches[0].dateTime, DateTime(2019, 8, 13, 0, 44));
    expect(catches[0].speciesId, isNotEmpty);
    expect(speciesManager.entity(id: catches[0].speciesId).name,
        "Carp - Common");
    expect(catches[0].baitId, isNotEmpty);
    expect(baitManager.entity(id: catches[0].baitId).name, "Corn");
    expect(catches[0].fishingSpotId, isNotEmpty);
    expect(fishingSpotManager.entity(id: catches[0].fishingSpotId).name,
        "Tennessee River - Sequoyah Hills Park");

    expect(catches[1].dateTime, DateTime(2019, 8, 12, 12, 44));
    expect(catches[2].dateTime, DateTime(2019, 8, 11, 8, 44));
    expect(catches[3].dateTime, DateTime(2019, 8, 10, 20, 44));
  });

  test("Import iOS locations", () async {
    File file = File("test/resources/backups/legacy_ios_entities.zip");
    await LegacyImporter(appManager, file, tmpDir).start();

    List<FishingSpot> fishingSpots = fishingSpotManager.entityList;
    expect(fishingSpots, isNotNull);
    expect(fishingSpots.length, 1);
    expect(fishingSpots.first.name, "Tennessee River - Sequoyah Hills Park");
    expect(fishingSpots.first.lat, 35.928575);
    expect(fishingSpots.first.lng, -83.974535);
  });

  test("Import iOS baits", () async {
    File file = File("test/resources/backups/legacy_ios_entities.zip");
    await LegacyImporter(appManager, file, tmpDir).start();

    List<Bait> baits = baitManager.entityList;
    expect(baits, isNotNull);
    expect(baits.length, 1);
    expect(baits.first.name, "Corn");
    expect(baits.first.hasCategory, false);
  });

  test("Import iOS species", () async {
    File file = File("test/resources/backups/legacy_ios_entities.zip");
    await LegacyImporter(appManager, file, tmpDir).start();

    List<Species> species = speciesManager.entityList;
    expect(species, isNotNull);
    expect(species.length, 1);
    expect(species.first.name, "Carp - Common");
  });

  testWidgets("Import iOS images", (WidgetTester tester) async {
    File zip = File("test/resources/backups/legacy_ios_photos.zip");

    Map<String, List<File>> importedImages = {};
    when(imageManager.save(any, any, compress: anyNamed("compress")))
        .thenAnswer((invocation) {
          importedImages[invocation.positionalArguments[0]] =
              invocation.positionalArguments[1];
          return Future.value();
        });

    await LegacyImporter(appManager, zip, tmpDir).start();

    BuildContext context = await buildContext(tester);
    List<Catch> catches = catchManager.catchesSortedByTimestamp(context);

    expect(catches, isNotNull);
    expect(catches.length, 2);
    expect(importedImages[catches[0].id], isNotNull);
    expect(importedImages[catches[0].id].length, 1);
    expect(importedImages[catches[1].id], isNotNull);
    expect(importedImages[catches[1].id].length, 2);
  });

  test("Import Android catches", () async {
    File file = File("test/resources/backups/legacy_android_entities.zip");
    await LegacyImporter(appManager, file, tmpDir).start();

    List<Catch> catches = catchManager.entityList;
    expect(catches, isNotNull);
    expect(catches.length, 1);

    expect(catches.first.dateTime, DateTime(2017, 10, 11, 17, 19, 19, 420));
    expect(catches.first.speciesId, isNotEmpty);
    expect(speciesManager.entity(id: catches[0].speciesId).name,
        "Trout - Rainbow");
    expect(catches.first.baitId, isNotEmpty);
    expect(baitManager.entity(id: catches[0].baitId).name,
        "Rapala F-7 - Brown Trout");
    expect(catches.first.fishingSpotId, isNotEmpty);
    expect(fishingSpotManager.entity(id: catches[0].fishingSpotId).name,
        "Bow River - Sewer Run");
  });

  test("Import Android locations", () async {
    File file = File("test/resources/backups/legacy_android_entities.zip");
    await LegacyImporter(appManager, file, tmpDir).start();

    List<FishingSpot> fishingSpots = fishingSpotManager.entityList;
    expect(fishingSpots, isNotNull);
    expect(fishingSpots.length, 1);
    expect(fishingSpots.first.name, "Bow River - Sewer Run");
    expect(fishingSpots.first.lat, 50.943077);
    expect(fishingSpots.first.lng, -114.013481);
  });

  test("Import Android baits", () async {
    File file = File("test/resources/backups/legacy_android_entities.zip");
    await LegacyImporter(appManager, file, tmpDir).start();

    List<Bait> baits = baitManager.entityListSortedByName();
    expect(baits, isNotNull);
    expect(baits.length, 2);

    expect(baits[0].name, "Rapala F-7 - Brown Trout");
    expect(baits[0].hasCategory, true);
    expect(baitCategoryManager.entity(id: baits[0].categoryId).name,
        "Other");

    expect(baits[1].name, "Z-Man");
    expect(baits[1].hasCategory, false);
  });

  test("Import Android species", () async {
    File file = File("test/resources/backups/legacy_android_entities.zip");
    await LegacyImporter(appManager, file, tmpDir).start();

    List<Species> species = speciesManager.entityList;
    expect(species, isNotNull);
    expect(species.length, 1);
    expect(species.first.name, "Trout - Rainbow");
  });

  test("Import Android bait categories", () async {
    File file = File("test/resources/backups/legacy_android_entities.zip");
    await LegacyImporter(appManager, file, tmpDir).start();

    List<BaitCategory> categories = baitCategoryManager.entityList;
    expect(categories, isNotNull);
    expect(categories.length, 1);
    expect(categories.first.id, "b860cddd-dc47-48a2-8d02-c8112a2ed5eb");
    expect(categories.first.name, "Other");
  });

  testWidgets("Import iOS images", (WidgetTester tester) async {
    File zip = File("test/resources/backups/legacy_android_photos.zip");

    Map<String, List<File>> importedImages = {};
    when(imageManager.save(any, any, compress: anyNamed("compress")))
        .thenAnswer((invocation) {
          importedImages[invocation.positionalArguments[0]] =
              invocation.positionalArguments[1];
          return Future.value();
        });

    await LegacyImporter(appManager, zip, tmpDir).start();

    BuildContext context = await buildContext(tester);
    List<Catch> catches = catchManager.catchesSortedByTimestamp(context);

    expect(catches, isNotNull);
    expect(catches.length, 2);
    expect(importedImages[catches[0].id], isNotNull);
    expect(importedImages[catches[0].id].length, 1);
    expect(importedImages[catches[1].id], isNotNull);
    expect(importedImages[catches[1].id].length, 2);
  });
}