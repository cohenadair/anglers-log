import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/data_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiver/strings.dart';

enum LegacyImporterError {
  invalidZipFile,
  missingJournal,
  missingUserDefines,
}

/// Imports data from pre-Anglers' Log 2.0 backups.
class LegacyImporter {
  final String _jsonFileExtension = ".json";

  final String _baitCategoriesKey = "baitCategories";
  final String _baitCategoryKey = "baitCategory";
  final String _baitsKey = "baits";
  final String _baitUsedKey = "baitUsed";
  final String _coordinatesKey = "coordinates";
  final String _dateKey = "date";
  final String _entriesKey = "entries";
  final String _fishingSpotKey = "fishingSpot";
  final String _fishingSpotsKey = "fishingSpots";
  final String _fishSpeciesKey = "fishSpecies";
  final String _idKey = "id";
  final String _imagePathKey = "imagePath";
  final String _imagesKey = "images";
  final String _journalKey = "journal";
  final String _latitudeKey = "latitude";
  final String _locationKey = "location";
  final String _locationsKey = "locations";
  final String _longitudeKey = "longitude";
  final String _nameKey = "name";
  final String _speciesKey = "species";
  final String _userDefinesKey = "userDefines";

  /// Format of how fishing spot names are imported. The first argument is the
  /// location name, the second argument is the fishing spot name.
  final String _fishingSpotNameFormat = "%s - %s";

  final Log _log = Log("LegacyImporter");

  final AppManager _appManager;
  final File _zipFile;
  Directory _temporaryFileDirectory;

  Map<String, dynamic> _json = {};
  Map<String, File> _images = {};

  LegacyImporter(AppManager appManager, File zipFile, [
    Directory temporaryFileDirectory,
  ]) : _appManager = appManager,
       _zipFile = zipFile,
       _temporaryFileDirectory = temporaryFileDirectory;

  BaitCategoryManager get _baitCategoryManager =>
      _appManager.baitCategoryManager;
  BaitManager get _baitManager => _appManager.baitManager;
  CatchManager get _catchManager => _appManager.catchManager;
  DataManager get _dataManager => _appManager.dataManager;
  FishingSpotManager get _fishingSpotManager => _appManager.fishingSpotManager;
  SpeciesManager get _speciesManager => _appManager.speciesManager;

  String get jsonString => jsonEncode(_json);

  Future<void> start() async {
    if (_zipFile == null) {
      return Future.error(LegacyImporterError.invalidZipFile);
    }

    await _dataManager.reset();
    Directory tmpDir = _temporaryFileDirectory ?? await getTemporaryDirectory();

    Archive archive = ZipDecoder().decodeBytes(_zipFile.readAsBytesSync());
    for (var archiveFile in archive) {
      Uint8List content = Uint8List.fromList(archiveFile.content);

      if (extension(archiveFile.name) == _jsonFileExtension) {
        _json = jsonDecode(Utf8Decoder().convert(content));
      } else {
        // Copy all images to a temporary directory.
        var tmpFile = File("${tmpDir.path}/${archiveFile.name}")
          ..writeAsBytesSync(content, flush: true);
        _images[archiveFile.name] = tmpFile;
      }
    }

    if (_json[_journalKey] == null) {
      return Future.error(LegacyImporterError.missingJournal);
    } else {
      return _import();
    }
  }

  Future<void> _import() async {
    var userDefines = _json[_journalKey][_userDefinesKey];
    if (userDefines == null || !(userDefines is List)) {
      return Future.error(LegacyImporterError.missingUserDefines);
    }

    List<dynamic> baitCategories;
    List<dynamic> baits;
    List<dynamic> locations;
    List<dynamic> species;

    for (Map<String, dynamic> map in userDefines) {
      switch (map[_nameKey]) {
        case "Baits":
          baits = map[_baitsKey];
          break;
        case "Bait Categories":
          baitCategories = map[_baitCategoriesKey];
          break;
        case "Locations":
          locations = map[_locationsKey];
          break;
        case "Species":
          species = map[_speciesKey];
          break;
        default:
          _log.w("Entity (${map[_nameKey]}) not yet implemented");
          break;
      }
    }

    // Categories need to be imported before baits.
    await _importBaitCategories(baitCategories);
    await _importBaits(baits);
    await _importLocations(locations);
    await _importSpecies(species);

    // Catches are always imported last since they reference most other
    // entities.
    await _importCatches(_json[_journalKey][_entriesKey]);

    // Cleanup temporary images.
    for (File tmpImg in _images.values) {
      tmpImg.deleteSync();
    }

    // Notify CatchManager of updates. CatchManager is done after to increase
    // efficiency when dealing with images.
    _appManager.catchManager.notifyOnAddOrUpdate();

    return Future.value();
  }

  Future<void> _importBaits(List<dynamic> baits) async {
    if (baits == null || baits.isEmpty) {
      return;
    }

    for (var item in baits) {
      Map<String, dynamic> map = item as Map<String, dynamic>;
      await _baitManager.addOrUpdate(Bait(
        name: map[_nameKey],
        categoryId: _baitCategoryManager.entityNamed(map[_baitCategoryKey])?.id
            ?? _baitCategoryManager.entity(id: map[_baitCategoryKey])?.id,
      ));
    }
  }

  Future<void> _importBaitCategories(List<dynamic> categories) async {
    await _importNamedEntity(categories, (name, id) async =>
        await _baitCategoryManager.addOrUpdate(BaitCategory(
            name: name, id: id)));
  }

  Future<void> _importLocations(List<dynamic> locations) async  {
    if (locations == null || locations.isEmpty) {
      return;
    }

    for (var location in locations) {
      var locationMap = location as Map<String, dynamic>;
      var locationName = locationMap[_nameKey];

      for (var fishingSpot in locationMap[_fishingSpotsKey]) {
        var fishingSpotMap = fishingSpot as Map<String, dynamic>;
        var fishingSpotName = format(_fishingSpotNameFormat,
            [locationName, fishingSpotMap[_nameKey]]);

        var coordinatesMap =
            fishingSpotMap[_coordinatesKey] as Map<String, dynamic>;

        // iOS backed up coordinates as strings, while Android was doubles.
        double lat;
        double lng;
        if (coordinatesMap[_longitudeKey] is double) {
          lng = coordinatesMap[_longitudeKey];
        } else {
          lng = double.parse(coordinatesMap[_longitudeKey]);
        }
        if (coordinatesMap[_latitudeKey] is double) {
          lat = coordinatesMap[_latitudeKey];
        } else {
          lat = double.parse(coordinatesMap[_latitudeKey]);
        }

        await _fishingSpotManager.addOrUpdate(FishingSpot(
          name: isNotEmpty(fishingSpotName) ? fishingSpotName : null,
          lat: lat,
          lng: lng,
        ));
      }
    }
  }

  Future<void> _importSpecies(List<dynamic> species) async {
    await _importNamedEntity(species, (name, id) async =>
        await _speciesManager.addOrUpdate(Species(name: name, id: id)));
  }

  Future<void> _importNamedEntity(List<dynamic> entities,
      Future<bool> Function(String name, String id) addEntity) async
  {
    if (entities == null || entities.isEmpty) {
      return;
    }

    for (var item in entities) {
      Map<String, dynamic> map = item as Map<String, dynamic>;
      await addEntity(map[_nameKey], map[_idKey]);
    }
  }

  Future<void> _importCatches(List<dynamic> catches) async {
    if (catches == null || catches.isEmpty) {
      return;
    }

    for (var item in catches) {
      Map<String, dynamic> map = item as Map<String, dynamic>;

      // iOS and Android backed up dates differently.
      String dateString = map[_dateKey];
      String dateFormat;
      if (dateString.contains(".")) {
        dateFormat = "M-d-y_h-m_a_s.S";
      } else {
        dateFormat = "M-d-y_h-m_a";
      }
      DateTime dateTime = DateFormat(dateFormat).parse(map[_dateKey]);

      Bait bait = _baitManager.entityNamed(map[_baitUsedKey]);
      if (bait == null && isNotEmpty(map[_baitUsedKey])) {
        _log.w("Bait (${map[_baitUsedKey]}) not found");
      }

      FishingSpot fishingSpot = _fishingSpotManager.entityNamed(format(
          _fishingSpotNameFormat, [map[_locationKey], map[_fishingSpotKey]]));
      if (fishingSpot == null && isNotEmpty(map[_fishingSpotKey])) {
        _log.w("Fishing spot (${map[_fishingSpotKey]}) not found");
      }

      Species species = _speciesManager.entityNamed(map[_fishSpeciesKey]);
      if (species == null && isNotEmpty(map[_fishSpeciesKey])) {
        _log.w("Species (${map[_fishSpeciesKey]}) not found");
      }

      List<File> images = [];
      List<dynamic> imagesJson = map[_imagesKey];
      for (Map<String, dynamic> imageMap in imagesJson) {
        var fileName = basename(imageMap[_imagePathKey]);
        if (_images.containsKey(fileName)) {
          images.add(_images[fileName]);
        } else {
          _log.w("Image $fileName not found in archive");
        }
      }

      await _catchManager.addOrUpdate(
        Catch(
          timestamp: dateTime.millisecondsSinceEpoch,
          speciesId: species.id,
          baitId: bait?.id,
          fishingSpotId: fishingSpot?.id,
        ),
        imageFiles: images,
        // Images were already compressed by legacy Anglers' Log versions.
        compressImages: false,
        // Suppress listener updates until all image manipulation has finished.
        notify: false,
      );
    }
  }
}
