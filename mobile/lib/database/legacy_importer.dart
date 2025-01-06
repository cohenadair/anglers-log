import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:fixnum/fixnum.dart';
import 'package:intl/intl.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/local_database_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/io_utils.dart';
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
import '../time_manager.dart';
import '../user_preference_manager.dart';
import '../utils/number_utils.dart';
import '../utils/protobuf_utils.dart';
import '../water_clarity_manager.dart';
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
  static const _keyBaitDescription = "baitDescription";
  static const _keyBaits = "baits";
  static const _keyBaitType = "baitType";
  static const _keyBaitUsed = "baitUsed";
  static const _keyCatches = "catches";
  static const _keyColor = "color";
  static const _keyCoordinates = "coordinates";
  static const _keyDate = "date";
  static const _keyEndDate = "endDate";
  static const _keyEntries = "entries";
  static const _keyFishingSpot = "fishingSpot";
  static const _keyFishingSpots = "fishingSpots";
  static const _keyFishLength = "fishLength";
  static const _keyFishOunces = "fishOunces";
  static const _keyFishQuantity = "fishQuantity";
  static const _keyFishResult = "fishResult";
  static const _keyFishSpecies = "fishSpecies";
  static const _keyFishWeight = "fishWeight";
  static const _keyIsFavorite = "isFavorite";
  static const _keyMethods = "fishingMethods";
  static const _keyMethodNames = "fishingMethodNames";
  static const _keyId = "id";
  static const _keyImagePath = "imagePath";
  static const _keyImage = "image";
  static const _keyImages = "images";
  static const _keyJournal = "journal";
  static const _keyLatitude = "latitude";
  static const _keyLocation = "location";
  static const _keyLocations = "locations";
  static const _keyLongitude = "longitude";
  static const _keyMeasurementSystem = "measurementSystem";
  static const _keyName = "name";
  static const _keyNotes = "notes";
  static const _keySkyConditions = "skyConditions";
  static const _keySize = "size";
  static const _keySpecies = "species";
  static const _keyStartDate = "startDate";
  static const _keyTemperature = "temperature";
  static const _keyTrips = "trips";
  static const _keyUserDefines = "userDefines";
  static const _keyWaterClarities = "waterClarities";
  static const _keyWaterClarity = "waterClarity";
  static const _keyWaterDepth = "waterDepth";
  static const _keyWaterTemperature = "waterTemperature";
  static const _keyWeatherData = "weatherData";
  static const _keyWeatherSystem = "weatherMeasurementSystem";
  static const _keyWindSpeed = "windSpeed";

  final _log = const Log("LegacyImporter");

  final AppManager _appManager;
  final File? _zipFile;
  final Map<String, File> _images = {};
  final LegacyJsonResult? _legacyJsonResult;
  final VoidCallback? _onFinish;

  late MeasurementSystem _measurementSystem;
  late MeasurementSystem _weatherSystem;
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

  BodyOfWaterManager get _bodyOfWaterManager => _appManager.bodyOfWaterManager;

  CatchManager get _catchManager => _appManager.catchManager;

  FishingSpotManager get _fishingSpotManager => _appManager.fishingSpotManager;

  LocalDatabaseManager get _localDatabaseManager =>
      _appManager.localDatabaseManager;

  MethodManager get _methodManager => _appManager.methodManager;

  SpeciesManager get _speciesManager => _appManager.speciesManager;

  TimeManager get _timeManager => _appManager.timeManager;

  TripManager get _tripManager => _appManager.tripManager;

  UserPreferenceManager get _userPreferenceManager =>
      _appManager.userPreferenceManager;

  WaterClarityManager get _waterClarityManager =>
      _appManager.waterClarityManager;

  PathProviderWrapper get _pathProviderWrapper =>
      _appManager.pathProviderWrapper;

  String get _jsonString => jsonEncode(_json);

  LegacyJsonResult? get legacyJsonResult => _legacyJsonResult;

  Future<void> start() async {
    if (_legacyJsonResult == null) {
      await _startArchive();
    } else {
      await _startMigration();
    }
    _onFinish?.call();
  }

  Future<void> _startMigration() async {
    // Don't allow migration to start if the legacy result has an error.
    assert(!_legacyJsonResult!.hasError);

    _json = _legacyJsonResult!.json ?? {};

    // Copy all image references into memory.
    var imagesDir = _ioWrapper.directory(_legacyJsonResult.imagesPath!);
    for (var image in imagesDir.listSync()) {
      var name = basename(image.path);
      var path = "${imagesDir.path}/$name";

      // Be safe, and ignore anything that isn't a File (#744).
      if (_ioWrapper.isFileSync(path)) {
        _images[name] = _ioWrapper.file(path);
      } else {
        _log.w(
            "Expected File, got ${FileSystemEntity.typeSync(path)} at $path");
      }
    }

    // Reset the 2.0 database and start fresh. If for some reason, the migration
    // was interrupted (for example, a crash), we don't want to create duplicate
    // data.
    await _localDatabaseManager.resetDatabase();
    await _import();

    // Cleanup old directory and database.
    await safeDeleteFileSystemEntity(imagesDir);
    await safeDeleteFileSystemEntity(
        _ioWrapper.directory(_legacyJsonResult.databasePath!));
  }

  Future<void> _startArchive() async {
    if (_zipFile == null) {
      return Future.error(LegacyImporterError.invalidZipFile);
    }

    var tmpDir = Directory(await _pathProviderWrapper.temporaryPath);

    var archive = ZipDecoder().decodeBytes(_zipFile.readAsBytesSync());
    for (var archiveFile in archive) {
      var content = Uint8List.fromList(archiveFile.content);

      if (extension(archiveFile.name) == _fileExtensionJson) {
        _json = jsonDecode(const Utf8Decoder().convert(content)) ?? {};
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

    int? measurementSystem = _json[_keyJournal][_keyMeasurementSystem];
    _measurementSystem = measurementSystem == 1
        ? MeasurementSystem.metric
        : MeasurementSystem.imperial_whole;
    _userPreferenceManager.setWaterDepthSystem(_measurementSystem);
    _userPreferenceManager.setWaterTemperatureSystem(_measurementSystem);
    _userPreferenceManager.setCatchLengthSystem(_measurementSystem);
    _userPreferenceManager.setCatchWeightSystem(_measurementSystem);

    int? weatherSystem = _json[_keyJournal][_keyWeatherSystem];
    if (weatherSystem == null) {
      _weatherSystem = _measurementSystem;
    } else {
      _weatherSystem = weatherSystem == 1
          ? MeasurementSystem.metric
          : MeasurementSystem.imperial_whole;
    }
    _userPreferenceManager.setAirTemperatureSystem(_weatherSystem);
    _userPreferenceManager.setAirPressureSystem(_weatherSystem);
    _userPreferenceManager.setAirVisibilitySystem(_weatherSystem);
    _userPreferenceManager.setWindSpeedSystem(_weatherSystem);

    var userDefinesJson = _json[_keyJournal][_keyUserDefines];
    if (userDefinesJson == null || userDefinesJson is! List) {
      return Future.error(LegacyImporterError.missingUserDefines,
          StackTrace.fromString(_jsonString));
    }

    List<dynamic>? anglers;
    List<dynamic>? baitCategories;
    List<dynamic>? baits;
    List<dynamic>? locations;
    List<dynamic>? methods;
    List<dynamic>? species;
    List<dynamic>? waterClarities;

    for (var map in userDefinesJson) {
      if (map is! Map<String, dynamic>) {
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
        case "Water Clarities":
          waterClarities = map[_keyWaterClarities];
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
    await _importWaterClarities(waterClarities);

    // Catches and trips are always imported last since they reference most
    // other entities.
    await _importCatches(_json[_keyJournal][_keyEntries]);
    await _importTrips(_json[_keyJournal][_keyTrips]);

    // Cleanup old images.
    for (var tmpImg in _images.values) {
      await safeDeleteFileSystemEntity(tmpImg);
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

        baitCategoryId ??= _baitCategoryManager
            .entity(_parseJsonId(map[_keyBaitCategory]))
            ?.id;

        if (baitCategoryId != null) {
          bait.baitCategoryId = baitCategoryId;
        }
      }

      int? type = map[_keyBaitType];
      if (type != null) {
        if (type == 0) {
          bait.type = Bait_Type.artificial;
        } else if (type == 1) {
          bait.type = Bait_Type.live;
        } else if (type == 2) {
          bait.type = Bait_Type.real;
        } else {
          _log.w("Bait type $type not supported");
        }
      }

      var variant = BaitVariant(
        id: randomId(),
        baseId: bait.id,
      );
      var isVariantSet = false;

      var color = map[_keyColor];
      if (isNotEmpty(color)) {
        variant.color = color;
        isVariantSet = true;
      }

      var size = map[_keySize];
      if (isNotEmpty(size)) {
        variant.size = size;
        isVariantSet = true;
      }

      var description = map[_keyBaitDescription];
      if (isNotEmpty(description)) {
        variant.description = description;
        isVariantSet = true;
      }

      if (isVariantSet) {
        bait.variants.add(variant);
      }

      File? image;
      var imageMap = map[_keyImage];
      if ((imageMap is Map<String, dynamic>)) {
        var imagePath = imageMap[_keyImagePath];
        if (isNotEmpty(imagePath)) {
          var fileName = basename(imagePath);
          if (_images.containsKey(fileName)) {
            image = _images[fileName]!;
          } else {
            _log.w("Image $fileName not found in legacy data");
          }
        }
      } else {
        _log.w("Corrupt image data (should be json map): $map");
      }

      await _baitManager.addOrUpdate(
        bait,
        imageFile: image,
        // Images were already compressed by legacy Anglers' Log.
        compressImages: false,
      );
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

      BodyOfWater? bodyOfWater;
      if (isNotEmpty(locationName)) {
        bodyOfWater = BodyOfWater(
          id: _parseJsonId(locationMap[_keyId]),
          name: locationName,
        );
        _bodyOfWaterManager.addOrUpdate(bodyOfWater);
      }

      for (var fishingSpot in locationMap[_keyFishingSpots]) {
        var fishingSpotMap = fishingSpot as Map<String, dynamic>;
        var fishingSpotName = fishingSpotMap[_keyName];

        var coordinatesMap =
            fishingSpotMap[_keyCoordinates] as Map<String, dynamic>;

        // iOS backed up coordinates as strings, while Android was doubles or
        // ints. Convert everything to a string and try to parse it to cover
        // all cases.
        double? lat = double.tryParse(coordinatesMap[_keyLatitude].toString());
        double? lng = double.tryParse(coordinatesMap[_keyLongitude].toString());

        if (lat == null || lng == null) {
          _log.w("Invalid coordinates: ${coordinatesMap[_keyLongitude]}, "
              "${coordinatesMap[_keyLatitude]}");
          continue;
        }

        var newFishingSpot = FishingSpot()
          ..id = _parseJsonId(fishingSpotMap[_keyId])
          ..lat = lat
          ..lng = lng;

        if (bodyOfWater != null) {
          newFishingSpot.bodyOfWaterId = bodyOfWater.id;
        }

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

  Future<void> _importWaterClarities(List<dynamic>? clarities) async {
    await _importNamedEntity(
      clarities,
      (name, id) async => await _waterClarityManager.addOrUpdate(WaterClarity()
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

      // DateFormat requires AM/PM, am/pm throws an exception.
      var dateString = (map[_keyDate] as String).toUpperCase();

      // iOS has been known to format AM as A.M., which breaks the date
      // formatter. Remove the periods if there are exactly 2; Android
      // legitimately uses 1 to separate milliseconds.
      if (".".allMatches(dateString).length == 2) {
        dateString = dateString.replaceAll(".", "");
      }

      // iOS and Android backed up dates differently.
      String dateFormat;
      if (dateString.contains(".")) {
        dateFormat = "M-d-y_h-m_a_s.S";
      } else if (dateString.endsWith("_")) {
        // iOS 24h times are translated in 24h time, and don't include the "_a"
        // required by the normal formatter.
        dateFormat = "M-d-y_h-m";
      } else {
        dateFormat = "M-d-y_h-m_a";
      }
      var dateTime = DateFormat(dateFormat).parse(dateString);

      var bait = _baitManager.named(map[_keyBaitUsed]);
      if (bait == null && isNotEmpty(map[_keyBaitUsed])) {
        _log.w("Bait (${map[_keyBaitUsed]}) not found");
      }

      var bodyOfWater = _bodyOfWaterManager.named(map[_keyLocation]);
      var fishingSpot = _fishingSpotManager.namedWithBodyOfWater(
          map[_keyFishingSpot], bodyOfWater?.id);
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

      var waterClarity = _waterClarityManager.named(map[_keyWaterClarity]);
      if (waterClarity == null && isNotEmpty(map[_keyWaterClarity])) {
        _log.w("Water clarity (${map[_keyWaterClarity]}) not found");
      }

      var images = <File>[];
      for (var imageMap in map[_keyImages]) {
        if (imageMap is! Map<String, dynamic>) {
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
        ..id = _parseJsonId(map[_keyId])
        ..timestamp = Int64(dateTime.millisecondsSinceEpoch);

      if (bait != null) {
        // A maximum of 1 variant can be created when importing baits. If this
        // catch's bait has a variant, use it.
        cat.baits.add(bait.variants.isNotEmpty
            ? bait.variants.first.toAttachment()
            : bait.toAttachment());
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

      if (waterClarity != null) {
        cat.waterClarityId = waterClarity.id;
      }

      bool? isFavorite = map[_keyIsFavorite];
      if (isFavorite != null && isFavorite) {
        cat.isFavorite = true;
      }

      int? result = map[_keyFishResult];
      if (result != null && result == 0) {
        cat.wasCatchAndRelease = true;
      }

      double? waterDepth = map[_keyWaterDepth]?.toDouble();
      if (waterDepth != null && waterDepth > 0) {
        cat.waterDepth =
            _createMultiMeasurement(waterDepth, Unit.meters, Unit.feet);
      }

      double? waterTemperature = map[_keyWaterTemperature]?.toDouble();
      if (waterTemperature != null && waterTemperature > 0) {
        cat.waterTemperature = _createMultiMeasurement(
            waterTemperature, Unit.celsius, Unit.fahrenheit);
      }

      double? length = map[_keyFishLength]?.toDouble();
      if (length != null && length > 0) {
        cat.length =
            _createMultiMeasurement(length, Unit.centimeters, Unit.inches);
      }

      double? weight = map[_keyFishWeight]?.toDouble();
      if (weight != null && weight > 0) {
        var measurement =
            _createMultiMeasurement(weight, Unit.kilograms, Unit.pounds);

        // If ounces are present, override values to preserve units.
        double? ounces = map[_keyFishOunces]?.toDouble();
        if (ounces != null && ounces > 0) {
          measurement
            ..system = MeasurementSystem.imperial_whole
            ..mainValue.unit = Unit.pounds
            ..mainValue.value.round()
            ..fractionValue = Measurement(
              unit: Unit.ounces,
              value: ounces,
            );
        }

        cat.weight = measurement;
      }

      int? quantity = map[_keyFishQuantity];
      if (quantity != null && quantity > 1) {
        cat.quantity = quantity;
      }

      String? notes = map[_keyNotes];
      if (isNotEmpty(notes)) {
        cat.notes = notes!;
      }

      Map<String, dynamic>? weather = map[_keyWeatherData];
      if (weather != null && weather.isNotEmpty) {
        cat.atmosphere = _parseWeatherData(weather);
      }

      // Set default properties not tracked in the legacy app.
      cat.timeZone = _timeManager.currentTimeZone;

      await _catchManager.addOrUpdate(
        cat,
        imageFiles: images,
        // Images were already compressed by legacy Anglers' Log versions.
        compressImages: false,
      );
    }
  }

  Future<void> _importTrips(List<dynamic>? trips) async {
    if (trips == null || trips.isEmpty) {
      return;
    }

    for (var item in trips) {
      var map = item as Map<String, dynamic>;
      var trip = Trip(id: _parseJsonId(map[_keyId]));

      String? name = map[_keyName];
      if (isNotEmpty(name)) {
        trip.name = name!;
      }

      var now = _timeManager.currentDateTime;

      int? startMs = map[_keyStartDate];
      trip.startTimestamp = Int64(startMs ?? now.millisecondsSinceEpoch);

      int? endMs = map[_keyEndDate];
      trip.endTimestamp = Int64(endMs ?? now.millisecondsSinceEpoch);

      String? notes = map[_keyNotes];
      if (isNotEmpty(notes)) {
        trip.notes = notes!;
      }

      var catchIds = map[_keyCatches];
      for (var idString in catchIds) {
        var id = safeParseId(idString);
        if (id == null) {
          continue;
        }
        trip.catchIds.add(id);
      }

      // Fetch all catches for this trip so we can fill in the new "catches per
      // entity" fields.
      var catches = <Catch>[];
      if (trip.catchIds.isNotEmpty) {
        catches = _catchManager.list(trip.catchIds);
      }

      for (var cat in catches) {
        Trips.incCatchesPerBait(trip.catchesPerBait, cat);
        trip.incCatchesPerSpecies(cat);
        trip.incCatchesPerFishingSpot(cat);
      }

      var bodyOfWaterIds = map[_keyLocations];
      for (var idString in bodyOfWaterIds) {
        var bodyOfWater = _bodyOfWaterManager.entity(_parseJsonId(idString));
        if (bodyOfWater == null) {
          _log.w("Body of water not found: $idString");
          continue;
        }
        trip.bodyOfWaterIds.add(bodyOfWater.id);
      }

      var anglerIds = map[_keyAnglers];
      for (var idString in anglerIds) {
        var angler = _anglerManager.entity(safeParseId(idString));
        if (angler == null) {
          _log.w("Angler not found: $idString");
          continue;
        }

        // Angler cannot be attached to a catch in the legacy app, so don't
        // bother iterating catches here.
        trip.catchesPerAngler.add(Trip_CatchesPerEntity(
          entityId: angler.id,
          value: 0,
        ));
      }

      // Set default properties not tracked in the legacy app.
      trip.timeZone = now.locationName;

      await _tripManager.addOrUpdate(trip);
    }
  }

  Atmosphere _parseWeatherData(Map<String, dynamic> weatherData) {
    var atmosphere = Atmosphere();

    var temperature = doubleFromDynamic(weatherData[_keyTemperature]);
    if (temperature != null) {
      atmosphere.temperature = MultiMeasurement(
        system: _weatherSystem,
        mainValue: Measurement(
          unit: _weatherSystem.isMetric ? Unit.celsius : Unit.fahrenheit,
          value: temperature,
        ),
      );
    }

    var windSpeed = doubleFromDynamic(weatherData[_keyWindSpeed]);
    if (windSpeed != null) {
      atmosphere.windSpeed = MultiMeasurement(
        system: _weatherSystem,
        mainValue: Measurement(
          unit: _weatherSystem.isMetric
              ? Unit.kilometers_per_hour
              : Unit.miles_per_hour,
          value: windSpeed.toDouble(),
        ),
      );
    }

    var skyConditions = weatherData[_keySkyConditions];
    if (isNotEmpty(skyConditions)) {
      atmosphere.skyConditions
          .addAll(_skyConditionsFromOpenWeatherMap(skyConditions));
    }

    return atmosphere;
  }

  /// Converts sky conditions from https://openweathermap.org/weather-conditions
  /// to a list of [SkyCondition]s. OpenWeatherMap was used in the legacy
  /// version of Anglers' Log.
  List<SkyCondition> _skyConditionsFromOpenWeatherMap(String skyConditions) {
    switch (skyConditions.toLowerCase()) {
      case "thunderstorm":
        return [SkyCondition.storm];
      case "drizzle":
        return [SkyCondition.drizzle];
      case "rain":
        return [SkyCondition.rain];
      case "snow":
      case "squall":
        return [SkyCondition.snow];
      case "mist":
        return [SkyCondition.mist];
      case "smoke":
      case "ash":
      case "haze":
        return [SkyCondition.smoke];
      case "dust":
      case "sand":
        return [SkyCondition.dust];
      case "fog":
        return [SkyCondition.fog];
      case "tornado":
        return [SkyCondition.tornado];
      case "clear":
        return [SkyCondition.clear];
      case "clouds":
      case "cloudy": // Not in OpenWeather doc, but appears in legacy JSON.
        return [SkyCondition.cloudy];
      case "overcast": // Not in OpenWeather doc, but appears in legacy JSON.
        return [SkyCondition.overcast];
    }
    return [];
  }

  MultiMeasurement _createMultiMeasurement(
      double value, Unit metricUnit, Unit imperialUnit) {
    var imperialSystem = value.isWhole
        ? MeasurementSystem.imperial_whole
        : MeasurementSystem.imperial_decimal;

    var measurementSystem =
        _measurementSystem.isMetric ? _measurementSystem : imperialSystem;

    return MultiMeasurement(
      system: measurementSystem,
      mainValue: Measurement(
        unit: measurementSystem.isMetric ? metricUnit : imperialUnit,
        value: value,
      ),
    );
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
