import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:fixnum/fixnum.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:quiver/strings.dart';

import '../angler_manager.dart';
import '../app_manager.dart';
import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../catch_manager.dart';
import '../channels/migration_channel.dart';
import '../fishing_spot_manager.dart';
import '../log.dart';
import '../method_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../species_manager.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../wrappers/io_wrapper.dart';
import '../wrappers/path_provider_wrapper.dart';

enum LegacyImporterError {
  invalidZipFile,
  missingJournal,
  missingUserDefines,
}

/// Imports data from pre-Anglers' Log 2.0 backups.
class LegacyImporter {
  static const _fileExtensionJson = ".json";

  static const _keyAnglers = "anglers";
  static const _keyBaitCategories = "baitCategories";
  static const _keyBaitCategory = "baitCategory";
  static const _keyBaits = "baits";
  static const _keyBaitUsed = "baitUsed";
  static const _keyCoordinates = "coordinates";
  static const _keyDate = "date";
  static const _keyEntries = "entries";
  static const _keyFishingSpot = "fishingSpot";
  static const _keyFishingSpots = "fishingSpots";
  static const _keyFishResult = "fishResult";
  static const _keyFishSpecies = "fishSpecies";
  static const _keyIsFavorite = "isFavorite";
  static const _keyMethods = "fishingMethods";
  static const _keyMethodNames = "fishingMethodNames";
  static const _keyId = "id";
  static const _keyImagePath = "imagePath";
  static const _keyImages = "images";
  static const _keyJournal = "journal";
  static const _keyLatitude = "latitude";
  static const _keyLocation = "location";
  static const _keyLocations = "locations";
  static const _keyLongitude = "longitude";
  static const _keyName = "name";
  static const _keySpecies = "species";
  static const _keyUserDefines = "userDefines";

  /// Format of how fishing spot names are imported. The first argument is the
  /// location name, the second argument is the fishing spot name.
  static final _nameFormatFishingSpot = "%s - %s";

  final _log = Log("LegacyImporter");

  final AppManager _appManager;
  final File? _zipFile;
  final Map<String, File> _images = {};
  final LegacyJsonResult? _legacyJsonResult;
  final VoidCallback? _onFinish;
  Map<String, dynamic> _json = {};

  IoWrapper get _ioWrapper => _appManager.ioWrapper;

  LegacyImporter(AppManager appManager, File? zipFile)
      : _appManager = appManager,
        _zipFile = zipFile,
        _legacyJsonResult = null,
        _onFinish = null;

  LegacyImporter.migrate(
    AppManager appManager,
    LegacyJsonResult result, [
    this._onFinish,
  ])  : _appManager = appManager,
        _zipFile = null,
        _legacyJsonResult = result;

  AnglerManager get _anglerManager => _appManager.anglerManager;

  BaitCategoryManager get _baitCategoryManager =>
      _appManager.baitCategoryManager;

  BaitManager get _baitManager => _appManager.baitManager;

  CatchManager get _catchManager => _appManager.catchManager;

  FishingSpotManager get _fishingSpotManager => _appManager.fishingSpotManager;

  MethodManager get _methodManager => _appManager.methodManager;

  SpeciesManager get _speciesManager => _appManager.speciesManager;

  PathProviderWrapper get _pathProviderWrapper =>
      _appManager.pathProviderWrapper;

  String get _jsonString => jsonEncode(_json);

  Future<void> start() async {
    if (_legacyJsonResult == null) {
      await _startArchive();
    } else {
      await _startMigration();
    }
    _onFinish?.call();
  }

  Future<void> _startMigration() async {
    // If there was an error in the platform channel, end the future
    // immediately.
    if (_legacyJsonResult!.errorCode != null) {
      return Future.error(
          _legacyJsonResult!.errorCode!,
          StackTrace.fromString(
              _legacyJsonResult!.errorDescription ?? "Unknown"));
    }

    _json = _legacyJsonResult!.json ?? {};

    // Copy all image references into memory.
    var imagesDir = _ioWrapper.directory(_legacyJsonResult!.imagesPath!);
    for (var image in imagesDir.listSync()) {
      var name = basename(image.path);
      _images[name] = _ioWrapper.file("${imagesDir.path}/$name");
    }

    await _import();

    // Cleanup old files.
    imagesDir.deleteSync();
    _ioWrapper
        .directory(_legacyJsonResult!.databasePath!)
        .deleteSync(recursive: true);
  }

  Future<void> _startArchive() async {
    if (_zipFile == null) {
      return Future.error(LegacyImporterError.invalidZipFile);
    }

    var tmpDir = Directory(await _pathProviderWrapper.temporaryPath);

    var archive = ZipDecoder().decodeBytes(_zipFile!.readAsBytesSync());
    for (var archiveFile in archive) {
      var content = Uint8List.fromList(archiveFile.content);

      if (extension(archiveFile.name) == _fileExtensionJson) {
        _json = jsonDecode(Utf8Decoder().convert(content)) ?? {};
      } else {
        // Copy all images to a temporary directory.
        var tmpFile = File("${tmpDir.path}/${archiveFile.name}")
          ..writeAsBytesSync(content, flush: true);
        _images[archiveFile.name] = tmpFile;
      }
    }

    return _import();
  }

  Future<void> _import() async {
    if (_json[_keyJournal] == null) {
      return Future.error(LegacyImporterError.missingJournal,
          StackTrace.fromString(_jsonString));
    }

    var userDefinesJson = _json[_keyJournal][_keyUserDefines];
    if (userDefinesJson == null || !(userDefinesJson is List)) {
      return Future.error(LegacyImporterError.missingUserDefines,
          StackTrace.fromString(_jsonString));
    }

    List<dynamic>? anglers;
    List<dynamic>? baitCategories;
    List<dynamic>? baits;
    List<dynamic>? locations;
    List<dynamic>? methods;
    List<dynamic>? species;

    for (var map in userDefinesJson) {
      if (!(map is Map<String, dynamic>)) {
        _log.w("Corrupt user define (should be json map): $map");
        continue;
      }

      switch (map[_keyName]) {
        case "Anglers":
          anglers = map[_keyAnglers];
          break;
        case "Baits":
          baits = map[_keyBaits];
          break;
        case "Bait Categories":
          baitCategories = map[_keyBaitCategories];
          break;
        case "Locations":
          locations = map[_keyLocations];
          break;
        case "Fishing Methods":
          methods = map[_keyMethods];
          break;
        case "Species":
          species = map[_keySpecies];
          break;
        default:
          _log.w("Entity (${map[_keyName]}) not yet implemented");
          break;
      }
    }

    // Categories need to be imported before baits.
    await _importAnglers(anglers);
    await _importBaitCategories(baitCategories);
    await _importBaits(baits);
    await _importLocations(locations);
    await _importMethods(methods);
    await _importSpecies(species);

    // Catches are always imported last since they reference most other
    // entities.
    await _importCatches(_json[_keyJournal][_keyEntries]);

    // Cleanup old images.
    for (var tmpImg in _images.values) {
      tmpImg.deleteSync();
    }

    return Future.value();
  }

  Future<void> _importBaits(List<dynamic>? baits) async {
    if (baits == null || baits.isEmpty) {
      return;
    }

    for (var item in baits) {
      var map = item as Map<String, dynamic>;
      var bait = Bait()
        ..id = randomId()
        ..name = map[_keyName];

      if (isNotEmpty(map[_keyBaitCategory])) {
        // See if JSON is using the name as the ID.
        var baitCategoryId =
            _baitCategoryManager.named(map[_keyBaitCategory]!)?.id;

        if (baitCategoryId == null) {
          baitCategoryId = _baitCategoryManager
              .entity(_parseJsonId(map[_keyBaitCategory]))
              ?.id;
        }

        if (baitCategoryId != null) {
          bait.baitCategoryId = baitCategoryId;
        }
      }

      await _baitManager.addOrUpdate(bait);
    }
  }

  Future<void> _importAnglers(List<dynamic>? anglers) async {
    await _importNamedEntity(
      anglers,
      (name, id) async => await _anglerManager.addOrUpdate(Angler()
        ..id = id
        ..name = name),
    );
  }

  Future<void> _importBaitCategories(List<dynamic>? categories) async {
    await _importNamedEntity(
      categories,
      (name, id) async => await _baitCategoryManager.addOrUpdate(BaitCategory()
        ..id = id
        ..name = name),
    );
  }

  Future<void> _importLocations(List<dynamic>? locations) async {
    if (locations == null || locations.isEmpty) {
      return;
    }

    for (var location in locations) {
      var locationMap = location as Map<String, dynamic>;
      var locationName = locationMap[_keyName];

      for (var fishingSpot in locationMap[_keyFishingSpots]) {
        var fishingSpotMap = fishingSpot as Map<String, dynamic>;
        var fishingSpotName = format(
          _nameFormatFishingSpot,
          [locationName, fishingSpotMap[_keyName]],
        );

        var coordinatesMap =
            fishingSpotMap[_keyCoordinates] as Map<String, dynamic>;

        // iOS backed up coordinates as strings, while Android was doubles.
        double? lat;
        double? lng;
        if (coordinatesMap[_keyLongitude] is double) {
          lng = coordinatesMap[_keyLongitude];
        } else {
          lng = double.tryParse(coordinatesMap[_keyLongitude]);
        }
        if (coordinatesMap[_keyLatitude] is double) {
          lat = coordinatesMap[_keyLatitude];
        } else {
          lat = double.tryParse(coordinatesMap[_keyLatitude]);
        }

        if (lat == null || lng == null) {
          _log.w("Invalid coordinates: ${coordinatesMap[_keyLongitude]}, "
              "${coordinatesMap[_keyLatitude]}");
          continue;
        }

        var newFishingSpot = FishingSpot()
          ..id = randomId()
          ..lat = lat
          ..lng = lng;

        if (isNotEmpty(fishingSpotName)) {
          newFishingSpot.name = fishingSpotName;
        }

        await _fishingSpotManager.addOrUpdate(newFishingSpot);
      }
    }
  }

  Future<void> _importMethods(List<dynamic>? methods) async {
    await _importNamedEntity(
      methods,
      (name, id) async => await _methodManager.addOrUpdate(Method()
        ..id = id
        ..name = name),
    );
  }

  Future<void> _importSpecies(List<dynamic>? species) async {
    await _importNamedEntity(
      species,
      (name, id) async => await _speciesManager.addOrUpdate(Species()
        ..id = id
        ..name = name),
    );
  }

  Future<void> _importNamedEntity(List<dynamic>? entities,
      Future<bool> Function(String name, Id id) addEntity) async {
    if (entities == null || entities.isEmpty) {
      return;
    }

    for (var item in entities) {
      var map = item as Map<String, dynamic>;
      var name = map[_keyName];
      if (isNotEmpty(name)) {
        await addEntity(map[_keyName]!, _parseJsonId(map[_keyId]));
      }
    }
  }

  Future<void> _importCatches(List<dynamic>? catches) async {
    if (catches == null || catches.isEmpty) {
      return;
    }

    for (var item in catches) {
      var map = item as Map<String, dynamic>;

      // iOS and Android backed up dates differently.
      String dateString = map[_keyDate];
      String dateFormat;
      if (dateString.contains(".")) {
        dateFormat = "M-d-y_h-m_a_s.S";
      } else {
        dateFormat = "M-d-y_h-m_a";
      }
      var dateTime = DateFormat(dateFormat).parse(map[_keyDate]);

      var bait = _baitManager.named(map[_keyBaitUsed]);
      if (bait == null && isNotEmpty(map[_keyBaitUsed])) {
        _log.w("Bait (${map[_keyBaitUsed]}) not found");
      }

      var fishingSpot = _fishingSpotManager.named(format(
          _nameFormatFishingSpot, [map[_keyLocation], map[_keyFishingSpot]]));
      if (fishingSpot == null && isNotEmpty(map[_keyFishingSpot])) {
        _log.w("Fishing spot (${map[_keyFishingSpot]}) not found");
      }

      var methods = <Method>[];
      var methodNames = map[_keyMethodNames];
      for (var methodName in methodNames) {
        var method = _methodManager.named(methodName);
        if (method == null) {
          _log.w("Method ($methodName) not found");
        } else {
          methods.add(method);
        }
      }

      var species = _speciesManager.named(map[_keyFishSpecies]);
      if (species == null && isNotEmpty(map[_keyFishSpecies])) {
        _log.w("Species (${map[_keyFishSpecies]}) not found");
      }

      var images = <File>[];
      for (var imageMap in map[_keyImages]) {
        if (!(imageMap is Map<String, dynamic>)) {
          _log.w("Corrupt image data (should be json map): $map");
          continue;
        }

        var fileName = basename(imageMap[_keyImagePath]);
        if (_images.containsKey(fileName)) {
          images.add(_images[fileName]!);
        } else {
          _log.w("Image $fileName not found in legacy data");
        }
      }

      var cat = Catch()
        ..id = randomId()
        ..timestamp = Int64(dateTime.millisecondsSinceEpoch);

      if (bait != null) {
        cat.baitId = bait.id;
      }

      if (fishingSpot != null) {
        cat.fishingSpotId = fishingSpot.id;
      }

      if (methods.isNotEmpty) {
        cat.methodIds.addAll(methods.map((m) => m.id));
      }

      if (species != null) {
        cat.speciesId = species.id;
      }

      bool? isFavorite = map[_keyIsFavorite];
      if (isFavorite != null && isFavorite) {
        cat.isFavorite = true;
      }

      int? result = map[_keyFishResult];
      if (result != null && result == 0) {
        cat.wasCatchAndRelease = true;
      }

      await _catchManager.addOrUpdate(
        cat,
        imageFiles: images,
        // Images were already compressed by legacy Anglers' Log versions.
        compressImages: false,
      );
    }
  }

  Id _parseJsonId(String? jsonId) {
    if (isEmpty(jsonId)) {
      return randomId();
    }

    var result = safeParseId(jsonId!);
    if (result == null) {
      _log.w("Invalid UUID string: $jsonId");
      return randomId();
    }

    return result;
  }
}
