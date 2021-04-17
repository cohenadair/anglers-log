import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/angler_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/channels/migration_channel.dart';
import 'package:mobile/database/legacy_importer.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/method_manager.dart';
import 'package:mobile/species_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;

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
  late CatchManager catchManager;
  late FishingSpotManager fishingSpotManager;
  late MethodManager methodManager;
  late SpeciesManager speciesManager;

  var tmpPath = "test/resources/legacy_importer/tmp";
  late Directory tmpDir;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.authManager.stream).thenAnswer((_) => Stream.empty());

    dataManager = appManager.localDatabaseManager;
    when(dataManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    imageManager = appManager.imageManager;
    when(imageManager.save(any)).thenAnswer((_) => Future.value());
    when(imageManager.save(any, compress: anyNamed("compress")))
        .thenAnswer((_) => Future.value([]));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    ioWrapper = appManager.ioWrapper;

    when(appManager.pathProviderWrapper.temporaryPath)
        .thenAnswer((_) => Future.value(tmpPath));

    anglerManager = AnglerManager(appManager.app);
    when(appManager.app.anglerManager).thenReturn(anglerManager);

    baitCategoryManager = BaitCategoryManager(appManager.app);
    when(appManager.app.baitCategoryManager).thenReturn(baitCategoryManager);

    baitManager = BaitManager(appManager.app);
    when(appManager.app.baitManager).thenReturn(baitManager);

    fishingSpotManager = FishingSpotManager(appManager.app);
    when(appManager.app.fishingSpotManager).thenReturn(fishingSpotManager);

    catchManager = CatchManager(appManager.app);
    when(appManager.app.catchManager).thenReturn(catchManager);

    methodManager = MethodManager(appManager.app);
    when(appManager.app.methodManager).thenReturn(methodManager);

    speciesManager = SpeciesManager(appManager.app);
    when(appManager.app.speciesManager).thenReturn(speciesManager);

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
    expect(catchManager.entityCount, 167);
    expect(fishingSpotManager.entityCount, 94);
    expect(methodManager.entityCount, 22);
    expect(speciesManager.entityCount, 28);

    verifyIds();
  });

  test("Import legacy Android", () async {
    var file = File("test/resources/backups/legacy_android_real.zip");

    await LegacyImporter(appManager.app, file).start();

    expect(anglerManager.entityCount, 4);
    expect(baitCategoryManager.entityCount, 3);
    expect(baitManager.entityCount, 72);
    expect(catchManager.entityCount, 133);
    expect(fishingSpotManager.entityCount, 75);
    expect(methodManager.entityCount, 19);
    expect(speciesManager.entityCount, 26);

    verifyIds();
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
    var catches = catchManager.catchesSortedByTimestamp(context);

    expect(catches, isNotNull);
    expect(catches.length, 4);

    expect(catches[0].timestamp.toInt(),
        DateTime(2019, 8, 13, 0, 44).millisecondsSinceEpoch);
    expect(catches[0].hasFishingSpotId(), true);
    expect(speciesManager.entity(catches[0].speciesId)!.name, "Carp - Common");
    expect(catches[0].hasBaitId(), true);
    expect(baitManager.entity(catches[0].baitId)!.name, "Corn");
    expect(catches[0].hasFishingSpotId(), true);
    expect(fishingSpotManager.entity(catches[0].fishingSpotId)!.name,
        "Tennessee River - Sequoyah Hills Park");
    expect(catches[0].methodIds.length, 2);
    expect(methodManager.entity(catches[0].methodIds[0])!.name, "Still");
    expect(methodManager.entity(catches[0].methodIds[1])!.name, "Bottom");

    expect(catches[1].timestamp.toInt(),
        DateTime(2019, 8, 12, 12, 44).millisecondsSinceEpoch);
    expect(catches[2].timestamp.toInt(),
        DateTime(2019, 8, 11, 8, 44).millisecondsSinceEpoch);
    expect(catches[3].timestamp.toInt(),
        DateTime(2019, 8, 10, 20, 44).millisecondsSinceEpoch);

    // Three methods exist within catches, but only two actually exist. Verify
    // nothing bad happens when a method is found that doesn't exist.
    expect(methodManager.entityCount, 2);
  });

  test("Import iOS locations", () async {
    var file = File("test/resources/backups/legacy_ios_entities.zip");
    await LegacyImporter(appManager.app, file).start();

    var fishingSpots = fishingSpotManager.list();
    expect(fishingSpots, isNotNull);
    expect(fishingSpots.length, 1);
    expect(fishingSpots.first.name, "Tennessee River - Sequoyah Hills Park");
    expect(fishingSpots.first.lat, 35.928575);
    expect(fishingSpots.first.lng, -83.974535);
  });

  test("Import iOS baits", () async {
    var file = File("test/resources/backups/legacy_ios_entities.zip");
    await LegacyImporter(appManager.app, file).start();

    var baits = baitManager.list();
    expect(baits, isNotNull);
    expect(baits.length, 1);
    expect(baits.first.name, "Corn");
    expect(baits.first.hasBaitCategoryId(), false);
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
    var catches = catchManager.catchesSortedByTimestamp(context);

    expect(catches, isNotNull);
    expect(catches.length, 2);
    expect(importedImages.length, 3);
  });

  test("Import Android catches", () async {
    var file = File("test/resources/backups/legacy_android_entities.zip");
    await LegacyImporter(appManager.app, file).start();

    var catches = catchManager.list();
    expect(catches, isNotNull);
    expect(catches.length, 1);

    expect(catches.first.timestamp.toInt(),
        DateTime(2017, 10, 11, 17, 19, 19, 420).millisecondsSinceEpoch);
    expect(catches.first.hasFishingSpotId(), true);
    expect(
        speciesManager.entity(catches[0].speciesId)!.name, "Trout - Rainbow");
    expect(catches.first.hasBaitId(), true);
    expect(baitManager.entity(catches[0].baitId)!.name,
        "Rapala F-7 - Brown Trout");
    expect(catches.first.hasFishingSpotId(), true);
    expect(fishingSpotManager.entity(catches[0].fishingSpotId)!.name,
        "Bow River - Sewer Run");
    expect(catches[0].methodIds.length, 3);
    expect(methodManager.entity(catches[0].methodIds[0])!.name, "Casting");
    expect(methodManager.entity(catches[0].methodIds[1])!.name, "Lure");
    expect(methodManager.entity(catches[0].methodIds[2])!.name, "Wade");
  });

  test("Import Android locations", () async {
    var file = File("test/resources/backups/legacy_android_entities.zip");
    await LegacyImporter(appManager.app, file).start();

    var fishingSpots = fishingSpotManager.list();
    expect(fishingSpots, isNotNull);
    expect(fishingSpots.length, 1);
    expect(fishingSpots.first.name, "Bow River - Sewer Run");
    expect(fishingSpots.first.lat, 50.943077);
    expect(fishingSpots.first.lng, -114.013481);
  });

  test("Import Android baits", () async {
    var file = File("test/resources/backups/legacy_android_entities.zip");
    await LegacyImporter(appManager.app, file).start();

    var baits = baitManager.listSortedByName();
    expect(baits, isNotNull);
    expect(baits.length, 2);

    expect(baits[0].name, "Rapala F-7 - Brown Trout");
    expect(baits[0].hasBaitCategoryId(), true);
    expect(baitCategoryManager.entity(baits[0].baitCategoryId)!.name, "Other");

    expect(baits[1].name, "Z-Man");
    expect(baits[1].hasBaitCategoryId(), false);
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
    var catches = catchManager.catchesSortedByTimestamp(context);

    expect(catches, isNotNull);
    expect(catches.length, 2);
    expect(importedImages.length, 3);
  });

  group("Migration", () {
    test("Error from platform channel", () async {
      var importer = LegacyImporter.migrate(
          appManager.app,
          LegacyJsonResult(
            errorCode: LegacyJsonErrorCode.missingData,
          ));
      await importer.start().catchError(expectAsync1((dynamic error) {
        expect(error, isNotNull);
        expect(error, equals(LegacyJsonErrorCode.missingData));
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

      var databaseDir = MockDirectory();
      when(ioWrapper.directory("test/database")).thenReturn(databaseDir);

      when(ioWrapper.file(any)).thenReturn(MockFile());

      var importer = LegacyImporter.migrate(
          appManager.app,
          LegacyJsonResult(
            databasePath: "test/database",
            imagesPath: "test/images",
            json: {},
          ));
      await importer.start().catchError(expectAsync1((dynamic error) {
        expect(error, equals(LegacyImporterError.missingJournal));
        verify(ioWrapper.file(any)).called(2);
        verifyNever(imagesDir.deleteSync());
        verifyNever(databaseDir.deleteSync(recursive: true));
      }));
    });

    test("Successful migration deletes old data", () async {
      var imagesDir = MockDirectory();
      when(imagesDir.deleteSync()).thenAnswer((_) {});
      when(imagesDir.listSync()).thenReturn([]);
      when(ioWrapper.directory("test/images")).thenReturn(imagesDir);

      var databaseDir = MockDirectory();
      when(databaseDir.deleteSync(recursive: true)).thenAnswer((_) {});
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
      verify(imagesDir.deleteSync()).called(1);
      verify(databaseDir.deleteSync(recursive: true)).called(1);
      expect(called, isTrue);
    });
  });
}
