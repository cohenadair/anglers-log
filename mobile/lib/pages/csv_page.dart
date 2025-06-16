import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile/angler_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/gear_manager.dart';
import 'package:mobile/method_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/atmosphere_utils.dart';
import 'package:mobile/utils/bool_utils.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/entity_utils.dart';
import 'package:mobile/utils/io_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/share_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/utils/widget_utils.dart';
import 'package:mobile/water_clarity_manager.dart';
import 'package:mobile/widgets/async_feedback.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/warning_container.dart';
import 'package:mobile/wrappers/csv_wrapper.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import 'package:mobile/wrappers/path_provider_wrapper.dart';
import 'package:mobile/wrappers/share_plus_wrapper.dart';
import 'package:quiver/strings.dart';
import 'package:share_plus/share_plus.dart';

import '../entity_manager.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../utils/trip_utils.dart';
import '../widgets/field.dart';
import '../widgets/widget.dart';
import 'scroll_page.dart';

class CsvPage extends StatefulWidget {
  @override
  State<CsvPage> createState() => _CsvPageState();
}

class _CsvPageState extends State<CsvPage> {
  static const _catchesFileName = "anglers-log-catches.csv";
  static const _tripsFileName = "anglers-log-trips.csv";

  final _log = const Log("CsvPage");
  final _exportButtonKey = GlobalKey();

  var _progressState = AsyncFeedbackState.none;
  String? _progressDescription;

  var _includeCatches = true;
  var _includeTrips = true;

  AnglerManager get _anglerManager => AnglerManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  CatchManager get _catchManager => CatchManager.of(context);

  CsvWrapper get _csvWrapper => CsvWrapper.of(context);

  CustomEntityManager get _customEntityManager =>
      CustomEntityManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  GearManager get _gearManager => GearManager.of(context);

  MethodManager get _methodManager => MethodManager.of(context);

  PathProviderWrapper get _pathProviderWrapper =>
      PathProviderWrapper.of(context);

  SharePlusWrapper get _shareWrapper => SharePlusWrapper.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  TimeManager get _timeManager => TimeManager.of(context);

  TripManager get _tripManager => TripManager.of(context);

  WaterClarityManager get _waterClarityManager =>
      WaterClarityManager.of(context);

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      appBar: TransparentAppBar(
        context,
        leading: CloseButton(
          color: context.colorDefault,
        ),
      ),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: WatermarkLogo(
            icon: shareIconData(context),
            title: Strings.of(context).csvPageTitle,
          ),
        ),
        const VerticalSpace(paddingLarge),
        Padding(
          padding: insetsHorizontalDefault,
          child: Text(
            Strings.of(context).csvPageDescription,
            style: stylePrimary(context),
          ),
        ),
        const VerticalSpace(paddingDefault),
        CheckboxInput(
          padding: insetsHorizontalDefault,
          label: catchesEntitySpec.pluralName(context),
          value: _includeCatches,
          onChanged: (value) => _includeCatches = value,
        ),
        const VerticalSpace(paddingDefault),
        CheckboxInput(
          padding: insetsHorizontalDefault,
          label: tripsEntitySpec.pluralName(context),
          value: _includeTrips,
          onChanged: (value) => _includeTrips = value,
        ),
        const VerticalSpace(paddingDefault),
        Padding(
          padding: insetsHorizontalDefault,
          child: Text(
            Strings.of(context).csvPageImportWarning,
            style: stylePrimary(context),
          ),
        ),
        const VerticalSpace(paddingDefault),
        Padding(
          padding: insetsHorizontalDefault,
          child: WarningContainer(
            children: [
              Text(Strings.of(context).csvPageBackupWarning),
            ],
          ),
        ),
        const VerticalSpace(paddingDefault),
        Center(
          child: AsyncFeedback(
            state: _progressState,
            description: _progressDescription,
            actionKey: _exportButtonKey,
            actionText: Strings.of(context).csvPageAction,
            action: _export,
            actionRequiresPro: true,
          ),
        ),
        const VerticalSpace(paddingDefault),
      ],
    );
  }

  Future<void> _export() async {
    setState(() {
      _progressState = AsyncFeedbackState.loading;
      _progressDescription = null;
    });

    var files = <XFile>[];

    var catches = await _exportCatches();
    if (catches != null) {
      files.add(catches);
    }
    var trips = await _exportTrips();
    if (trips != null) {
      files.add(trips);
    }

    if (files.isEmpty) {
      setState(() {
        _progressState = AsyncFeedbackState.error;
        _progressDescription = Strings.of(context).csvPageMustSelect;
      });
      return;
    } else {
      setState(() {
        _progressState = AsyncFeedbackState.success;
        _progressDescription = Strings.of(context).csvPageSuccess;
      });
    }

    await _shareWrapper.shareFiles(files, _exportButtonKey.globalPosition());

    // Cleanup.
    await safeDeleteFileSystemEntity(await _catchesFile());
    await safeDeleteFileSystemEntity(await _tripsFile());
  }

  Future<XFile?> _exportCatches() async {
    if (!_includeCatches) {
      return null;
    }

    var nowTs = _timeManager.currentTimestamp;

    // Notes about CSV output:
    //   - Timestamp is split into separate date and time columns.
    //   - Images are excluded.
    //   - There are 3 columns for fishing spots: name, lat, and lon.
    //   - Each atmosphere field has its own column.

    var catchFields = allCatchFields(context)
      ..removeWhere((field) =>
          field.id == catchFieldIdTimestamp ||
          field.id == catchFieldIdImages ||
          field.id == catchFieldIdAtmosphere ||
          (UserPreferenceManager.get.catchFieldIds.isNotEmpty &&
              !UserPreferenceManager.get.catchFieldIds.contains(field.id)));
    var catchCustomEntityIds = UserPreferenceManager.get.catchFieldIds
        .where((e) => _customEntityManager.entityExists(e));
    var atmosphereFields = UserPreferenceManager.get.catchFieldIds.isEmpty ||
            UserPreferenceManager.get.catchFieldIds
                .contains(catchFieldIdAtmosphere)
        ? _atmosphereFields()
        : <Field>[];

    // Add lat and lon columns.
    var catchColumns = catchFields.map((e) => e.name!(context)).toList();
    var fishingSpotIndex =
        catchFields.indexWhere((e) => e.id == catchFieldIdFishingSpot);
    if (fishingSpotIndex != -1) {
      catchColumns
        ..insert(fishingSpotIndex + 1, Strings.of(context).latitude)
        ..insert(fishingSpotIndex + 2, Strings.of(context).longitude);
    }

    var csv = <List<String>>[];

    // Header.
    csv.add([
      Strings.of(context).catchFieldDate,
      Strings.of(context).catchFieldTime,
      ...catchColumns,
      ...catchCustomEntityIds.map((e) => _customEntityManager.entity(e)!.name),
      ...atmosphereFields.map((e) => e.name!(context)),
    ]);

    var catches = _catchManager.catches(context);

    // Rows.
    for (var cat in catches) {
      var row = <String>[];

      var dateTime = cat.dateTime(context);
      row.add(
        DateFormats.localized(
          context,
          Strings.of(context).dateFormatMonthDayYear,
        ).format(dateTime),
      );
      row.add(formatTimeOfDay(context, TimeOfDay.fromDateTime(dateTime)));

      for (var field in catchFields) {
        if (field.id == catchFieldIdAngler) {
          row.add(
              _anglerManager.displayNameFromId(context, cat.anglerId) ?? "");
        } else if (field.id == catchFieldIdBait) {
          row.add(formatList(
              _baitManager.attachmentsDisplayValues(context, cat.baits)));
        } else if (field.id == catchFieldIdGear) {
          row.add(formatList(
              _gearManager.displayNamesFromIds(context, cat.gearIds)));
        } else if (field.id == catchFieldIdPeriod) {
          row.add(cat.hasPeriod() ? cat.period.displayName(context) : "");
        } else if (field.id == catchFieldIdFishingSpot) {
          row.add(
            _fishingSpotManager.displayNameFromId(
                  context,
                  cat.fishingSpotId,
                  includeBodyOfWater: true,
                  useLatLngFallback: false,
                ) ??
                "",
          );
          var fishingSpot = _fishingSpotManager.entity(cat.fishingSpotId);
          row.add(fishingSpot == null ? "" : formatCoordinate(fishingSpot.lat));
          row.add(fishingSpot == null ? "" : formatCoordinate(fishingSpot.lng));
        } else if (field.id == catchFieldIdMethods) {
          row.add(formatList(
              _methodManager.displayNamesFromIds(context, cat.methodIds)));
        } else if (field.id == catchFieldIdSpecies) {
          row.add(
              _speciesManager.displayNameFromId(context, cat.speciesId) ?? "");
        } else if (field.id == catchFieldIdTimeZone) {
          row.add(cat.hasTimeZone()
              ? TimeZoneLocation.fromName(cat.timeZone).displayName
              : "");
        } else if (field.id == catchFieldIdFavorite) {
          row.add(
              cat.hasIsFavorite() ? cat.isFavorite.displayValue(context) : "");
        } else if (field.id == catchFieldIdCatchAndRelease) {
          row.add(cat.hasWasCatchAndRelease()
              ? cat.wasCatchAndRelease.displayValue(context)
              : "");
        } else if (field.id == catchFieldIdSeason) {
          row.add(cat.hasSeason() ? cat.season.displayName(context) : "");
        } else if (field.id == catchFieldIdWaterClarity) {
          row.add(
            _waterClarityManager.displayNameFromId(
                    context, cat.waterClarityId) ??
                "",
          );
        } else if (field.id == catchFieldIdWaterDepth) {
          row.add(
              cat.hasWaterDepth() ? cat.waterDepth.displayValue(context) : "");
        } else if (field.id == catchFieldIdWaterTemperature) {
          row.add(cat.hasWaterTemperature()
              ? cat.waterTemperature.displayValue(context)
              : "");
        } else if (field.id == catchFieldIdLength) {
          row.add(cat.hasLength() ? cat.length.displayValue(context) : "");
        } else if (field.id == catchFieldIdWeight) {
          row.add(cat.hasWeight() ? cat.weight.displayValue(context) : "");
        } else if (field.id == catchFieldIdQuantity) {
          row.add(cat.hasQuantity() ? cat.quantity.toString() : "");
        } else if (field.id == catchFieldIdNotes) {
          row.add(cat.notes);
        } else if (field.id == catchFieldIdTide) {
          row.add(cat.hasTide() ? cat.tide.currentDisplayValue(context) : "");
        } else {
          _log.d("Unknown catch field ID: ${field.id}");
          row.add("");
        }
      }

      // Add custom entity values.
      _addCustomEntityValuesToRow(
          row, catchCustomEntityIds, cat.customEntityValues);

      // Add atmosphere after all catch fields are done.
      _addAtmosphereFieldsToRow(row, atmosphereFields, cat.atmosphere);

      csv.add(row);
    }

    _log.d("Finished catches (${_timeManager.currentTimestamp - nowTs}ms)");

    return XFile(
      (await _writeCsvToFile(csv, await _catchesFile())).path,
      mimeType: "text/csv",
    );
  }

  Future<XFile?> _exportTrips() async {
    if (!_includeTrips) {
      return null;
    }

    var nowTs = _timeManager.currentTimestamp;

    // Notes about CSV output:
    //   - Start and end timestamps are split into separate date and time
    //     columns.
    //   - Images are excluded.
    //   - GPS trails are excluded.
    //   - Each atmosphere field has its own column.

    var tripFields = allTripFields(context)
      ..removeWhere((field) =>
          field.id == tripFieldIdStartTimestamp ||
          field.id == tripFieldIdEndTimestamp ||
          field.id == tripFieldIdGpsTrails ||
          field.id == tripFieldIdImages ||
          field.id == tripFieldIdAtmosphere ||
          (UserPreferenceManager.get.tripFieldIds.isNotEmpty &&
              !UserPreferenceManager.get.tripFieldIds.contains(field.id)));
    var tripCustomEntityIds = UserPreferenceManager.get.tripFieldIds
        .where((e) => _customEntityManager.entityExists(e));
    var atmosphereFields = UserPreferenceManager.get.tripFieldIds.isEmpty ||
            UserPreferenceManager.get.tripFieldIds
                .contains(tripFieldIdAtmosphere)
        ? _atmosphereFields()
        : <Field>[];

    var csv = <List<String>>[];

    // Header.
    csv.add([
      Strings.of(context).tripFieldStartDate,
      Strings.of(context).tripFieldStartTime,
      Strings.of(context).tripFieldEndDate,
      Strings.of(context).tripFieldEndTime,
      ...tripFields.map((e) => e.name!(context)),
      ...tripCustomEntityIds.map((e) => _customEntityManager.entity(e)!.name),
      ...atmosphereFields.map((e) => e.name!(context)),
    ]);

    var trips = _tripManager.list();

    // Rows.
    for (var trip in trips) {
      var row = <String>[];

      var startDateTime = trip.startDateTime(context);
      row.add(DateFormats.localized(
        context,
        Strings.of(context).dateFormatMonthDayYear,
      ).format(startDateTime));
      row.add(formatTimeOfDay(context, TimeOfDay.fromDateTime(startDateTime)));

      var endDateTime = trip.endDateTime(context);
      row.add(DateFormats.localized(
        context,
        Strings.of(context).dateFormatMonthDayYear,
      ).format(endDateTime));
      row.add(formatTimeOfDay(context, TimeOfDay.fromDateTime(endDateTime)));

      for (var field in tripFields) {
        if (field.id == tripFieldIdTimeZone) {
          row.add(trip.hasTimeZone()
              ? TimeZoneLocation.fromName(trip.timeZone).displayName
              : "");
        } else if (field.id == tripFieldIdName) {
          row.add(trip.name);
        } else if (field.id == tripFieldIdCatches) {
          row.add(formatList(
              _catchManager.displayNamesFromIds(context, trip.catchIds)));
        } else if (field.id == tripFieldIdBodiesOfWater) {
          row.add(formatList(_bodyOfWaterManager.displayNamesFromIds(
              context, trip.bodyOfWaterIds)));
        } else if (field.id == tripFieldIdCatchesPerFishingSpot) {
          _addCatchesPerEntityToRow(
              row, trip.catchesPerFishingSpot, _fishingSpotManager);
        } else if (field.id == tripFieldIdCatchesPerAngler) {
          _addCatchesPerEntityToRow(row, trip.catchesPerAngler, _anglerManager);
        } else if (field.id == tripFieldIdCatchesPerSpecies) {
          _addCatchesPerEntityToRow(
              row, trip.catchesPerSpecies, _speciesManager);
        } else if (field.id == tripFieldIdCatchesPerBait) {
          _addCatchesPerBaitToRow(row, trip.catchesPerBait);
        } else if (field.id == tripFieldIdNotes) {
          row.add(trip.notes);
        } else if (field.id == tripFieldIdWaterClarity) {
          row.add(
            _waterClarityManager.displayNameFromId(
                    context, trip.waterClarityId) ??
                "",
          );
        } else if (field.id == tripFieldIdWaterDepth) {
          row.add(trip.hasWaterDepth()
              ? trip.waterDepth.displayValue(context)
              : "");
        } else if (field.id == tripFieldIdWaterTemperature) {
          row.add(trip.hasWaterTemperature()
              ? trip.waterTemperature.displayValue(context)
              : "");
        } else {
          _log.d("Unknown trip field ID: ${field.id}");
          row.add("");
        }
      }

      // Add custom entity values.
      _addCustomEntityValuesToRow(
          row, tripCustomEntityIds, trip.customEntityValues);

      // Add atmosphere after all trip fields are done.
      _addAtmosphereFieldsToRow(row, atmosphereFields, trip.atmosphere);

      csv.add(row);
    }

    _log.d("Finished trips (${_timeManager.currentTimestamp - nowTs}ms)");

    return XFile(
      (await _writeCsvToFile(csv, await _tripsFile())).path,
      mimeType: "text/csv",
    );
  }

  Future<File> _writeCsvToFile(List<List<String>> csv, File file) async {
    return await file.writeAsString(
      _csvWrapper.convert(csv),
      flush: true,
    );
  }

  Future<File> _catchesFile() async => IoWrapper.get
      .file("${await _pathProviderWrapper.temporaryPath}/$_catchesFileName");

  Future<File> _tripsFile() async => IoWrapper.get
      .file("${await _pathProviderWrapper.temporaryPath}/$_tripsFileName");

  List<Field> _atmosphereFields() {
    var all = allAtmosphereFields(context);
    var preference = UserPreferenceManager.get.atmosphereFieldIds;
    if (preference.isEmpty) {
      return all;
    }
    return all
      ..removeWhere(
          (field) => preference.isNotEmpty && !preference.contains(field.id));
  }

  void _addCustomEntityValuesToRow(
    List<String> row,
    Iterable<Id> ids,
    Iterable<CustomEntityValue> customEntityValues,
  ) {
    for (var id in ids) {
      var value =
          customEntityValues.firstWhereOrNull((e) => e.customEntityId == id);
      row.add(value == null ? "" : value.value);
    }
  }

  void _addAtmosphereFieldsToRow(
    List<String> row,
    List<Field> fields,
    Atmosphere atmosphere,
  ) {
    for (var field in fields) {
      if (field.id == atmosphereFieldIdTemperature) {
        row.add(atmosphere.hasTemperature()
            ? atmosphere.temperature.displayValue(context)
            : "");
      } else if (field.id == atmosphereFieldIdSkyCondition) {
        row.add(SkyConditions.displayNameForList(
            context, atmosphere.skyConditions));
      } else if (field.id == atmosphereFieldIdWindDirection) {
        row.add(atmosphere.hasWindDirection()
            ? atmosphere.windDirection.displayName(context)
            : "");
      } else if (field.id == atmosphereFieldIdWindSpeed) {
        row.add(atmosphere.hasWindSpeed()
            ? atmosphere.windSpeed.displayValue(context)
            : "");
      } else if (field.id == atmosphereFieldIdPressure) {
        row.add(atmosphere.hasPressure()
            ? atmosphere.pressure.displayValue(context)
            : "");
      } else if (field.id == atmosphereFieldIdVisibility) {
        row.add(atmosphere.hasVisibility()
            ? atmosphere.visibility.displayValue(context)
            : "");
      } else if (field.id == atmosphereFieldIdHumidity) {
        row.add(atmosphere.hasHumidity()
            ? atmosphere.humidity.displayValue(context)
            : "");
      } else if (field.id == atmosphereFieldIdMoonPhase) {
        row.add(atmosphere.hasMoonPhase()
            ? atmosphere.moonPhase.displayName(context)
            : "");
      } else if (field.id == atmosphereFieldIdSunriseTimestamp) {
        row.add(atmosphere.hasSunriseTimestamp()
            ? atmosphere.displaySunriseTimestamp(context)
            : "");
      } else if (field.id == atmosphereFieldIdSunsetTimestamp) {
        row.add(atmosphere.hasSunsetTimestamp()
            ? atmosphere.displaySunsetTimestamp(context)
            : "");
      } else {
        _log.d("Unknown atmosphere field ID: ${field.id}");
        row.add("");
      }
    }
  }

  void _addCatchesPerEntityToRow(
    List<String> row,
    List<Trip_CatchesPerEntity> perEntities,
    EntityManager entityManager,
  ) {
    var result = <String>[];
    for (var perEntity in perEntities) {
      _addPerEntityTo(
        result,
        entityManager.displayNameFromId(context, perEntity.entityId),
        perEntity.value,
      );
    }
    row.add(formatList(result));
  }

  void _addCatchesPerBaitToRow(
    List<String> row,
    List<Trip_CatchesPerBait> perBaits,
  ) {
    var result = <String>[];
    for (var perBait in perBaits) {
      _addPerEntityTo(
        result,
        _baitManager.attachmentDisplayValue(context, perBait.attachment),
        perBait.value,
      );
    }
    row.add(formatList(result));
  }

  void _addPerEntityTo(List<String> result, String? name, int value) {
    if (isEmpty(name)) {
      return;
    }
    result.add("$name: $value");
  }
}
