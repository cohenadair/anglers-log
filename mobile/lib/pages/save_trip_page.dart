import 'dart:async';

import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/widgets/empty.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:mobile/angler_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/gps_trail_manager.dart';
import 'package:mobile/pages/body_of_water_list_page.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/pages/gps_trail_list_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/widgets/atmosphere_input.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/date_time_picker.dart';
import 'package:mobile/widgets/entity_picker_input.dart';
import 'package:mobile/widgets/field.dart';
import 'package:mobile/widgets/image_input.dart';
import 'package:mobile/widgets/quantity_picker_input.dart';
import 'package:quiver/strings.dart';

import '../atmosphere_fetcher.dart';
import '../model/gen/anglers_log.pb.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../utils/trip_utils.dart';
import '../widgets/input_controller.dart';
import '../widgets/multi_measurement_input.dart';
import '../widgets/text_input.dart';
import '../widgets/time_zone_input.dart';
import '../widgets/water_clarity_input.dart';
import 'angler_list_page.dart';
import 'species_list_page.dart';

class SaveTripPage extends StatefulWidget {
  final Trip? oldTrip;

  const SaveTripPage() : oldTrip = null;

  const SaveTripPage.edit(this.oldTrip);

  @override
  SaveTripPageState createState() => SaveTripPageState();
}

class SaveTripPageState extends State<SaveTripPage> {
  static final _idStartTimestamp = tripFieldIdStartTimestamp;
  static final _idEndTimestamp = tripFieldIdEndTimestamp;
  static final _idTimeZone = tripFieldIdTimeZone;
  static final _idName = tripFieldIdName;
  static final _idImages = tripFieldIdImages;
  static final _idCatches = tripFieldIdCatches;
  static final _idBodiesOfWater = tripFieldIdBodiesOfWater;
  static final _idCatchesPerFishingSpot = tripFieldIdCatchesPerFishingSpot;
  static final _idCatchesPerAngler = tripFieldIdCatchesPerAngler;
  static final _idCatchesPerSpecies = tripFieldIdCatchesPerSpecies;
  static final _idCatchesPerBait = tripFieldIdCatchesPerBait;
  static final _idNotes = tripFieldIdNotes;
  static final _idAtmosphere = tripFieldIdAtmosphere;
  static final _idGpsTrails = tripFieldIdGpsTrails;
  static final _idWaterClarity = tripFieldIdWaterClarity;
  static final _idWaterDepth = tripFieldIdWaterDepth;
  static final _idWaterTemperature = tripFieldIdWaterTemperature;

  final _log = const Log("SaveTripPage");
  final Map<Id, Field> _fields = {};
  final Set<String> _catchImages = {};

  List<CustomEntityValue> _customEntityValues = [];

  Trip? get _oldTrip => widget.oldTrip;

  bool get _isEditing => _oldTrip != null;

  AnglerManager get _anglerManager => AnglerManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  CatchManager get _catchManager => CatchManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  GpsTrailManager get _gpsTrailManager => GpsTrailManager.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  TripManager get _tripManager => TripManager.of(context);

  CurrentDateTimeInputController get _startTimestampController =>
      _fields[_idStartTimestamp]!.controller as CurrentDateTimeInputController;

  CurrentDateTimeInputController get _endTimestampController =>
      _fields[_idEndTimestamp]!.controller as CurrentDateTimeInputController;

  TimeZoneInputController get _timeZoneController =>
      _fields[_idTimeZone]!.controller as TimeZoneInputController;

  TextInputController get _nameController =>
      _fields[_idName]!.controller as TextInputController;

  ImagesInputController get _imagesController =>
      _fields[_idImages]!.controller as ImagesInputController;

  SetInputController<Id> get _catchesController =>
      _fields[_idCatches]!.controller as SetInputController<Id>;

  SetInputController<Id> get _bodiesOfWaterController =>
      _fields[_idBodiesOfWater]!.controller as SetInputController<Id>;

  InputController<Atmosphere> get _atmosphereController =>
      _fields[_idAtmosphere]!.controller as InputController<Atmosphere>;

  TextInputController get _notesController =>
      _fields[_idNotes]!.controller as TextInputController;

  SetInputController<Trip_CatchesPerEntity> get _speciesCatchesController =>
      _fields[_idCatchesPerSpecies]!.controller
          as SetInputController<Trip_CatchesPerEntity>;

  SetInputController<Trip_CatchesPerEntity> get _anglerCatchesController =>
      _fields[_idCatchesPerAngler]!.controller
          as SetInputController<Trip_CatchesPerEntity>;

  SetInputController<Trip_CatchesPerEntity> get _fishingSpotCatchesController =>
      _fields[_idCatchesPerFishingSpot]!.controller
          as SetInputController<Trip_CatchesPerEntity>;

  SetInputController<Trip_CatchesPerBait> get _baitCatchesController =>
      _fields[_idCatchesPerBait]!.controller
          as SetInputController<Trip_CatchesPerBait>;

  SetInputController<Id> get _gpsTrailsController =>
      _fields[_idGpsTrails]!.controller as SetInputController<Id>;

  IdInputController get _waterClarityController =>
      _fields[_idWaterClarity]!.controller as IdInputController;

  MultiMeasurementInputController get _waterDepthController =>
      _fields[_idWaterDepth]!.controller as MultiMeasurementInputController;

  MultiMeasurementInputController get _waterTemperatureController =>
      _fields[_idWaterTemperature]!.controller
          as MultiMeasurementInputController;

  @override
  void initState() {
    super.initState();

    for (var field in allTripFields(context)) {
      _fields[field.id] = field;
    }

    if (_isEditing) {
      if (_oldTrip!.hasStartTimestamp()) {
        _startTimestampController.value = _oldTrip!.startDateTime(context);
      }

      if (_oldTrip!.hasEndTimestamp()) {
        _endTimestampController.value = _oldTrip!.endDateTime(context);
      }

      _timeZoneController.value = _oldTrip!.timeZone;
      _nameController.value = _oldTrip!.hasName() ? _oldTrip!.name : null;
      _catchesController.value = _oldTrip!.catchIds.toSet();
      _bodiesOfWaterController.value = _oldTrip!.bodyOfWaterIds.toSet();
      _atmosphereController.value = _oldTrip!.hasAtmosphere()
          ? _oldTrip!.atmosphere
          : null;
      _notesController.value = _oldTrip!.hasNotes() ? _oldTrip!.notes : null;
      _speciesCatchesController.value = _oldTrip!.catchesPerSpecies.toSet();
      _anglerCatchesController.value = _oldTrip!.catchesPerAngler.toSet();
      _fishingSpotCatchesController.value = _oldTrip!.catchesPerFishingSpot
          .toSet();
      _baitCatchesController.value = _oldTrip!.catchesPerBait.toSet();
      _customEntityValues = _oldTrip!.customEntityValues;
      _gpsTrailsController.value = _oldTrip!.gpsTrailIds.toSet();
      _waterClarityController.value = _oldTrip!.waterClarityId;
      _waterDepthController.value = _oldTrip!.hasWaterDepth()
          ? _oldTrip!.waterDepth
          : null;
      _waterTemperatureController.value = _oldTrip!.hasWaterTemperature()
          ? _oldTrip!.waterTemperature
          : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return EditableFormPage(
      title: Text(
        _isEditing && _tripManager.entityExists(_oldTrip?.id)
            ? Strings.of(context).saveTripPageEditTitle
            : Strings.of(context).saveTripPageNewTitle,
      ),
      header: _buildAutoPopulateFieldsHeader(),
      padding: insetsZero,
      runSpacing: 0,
      fields: _fields,
      trackedFieldIds: UserPreferenceManager.get.tripFieldIds.toSet(),
      customEntityValues: _customEntityValues,
      showTopCustomFieldPadding: false,
      onBuildField: _buildField,
      onAddFields: (ids) =>
          UserPreferenceManager.get.setTripFieldIds(ids.toList()),
      onSave: _save,
    );
  }

  Widget _buildAutoPopulateFieldsHeader() {
    return CheckboxInput(
      label: Strings.of(context).saveTripPageAutoSetTitle,
      description: Strings.of(context).saveTripPageAutoSetDescription,
      value: UserPreferenceManager.get.autoSetTripFields,
      onChanged: (value) =>
          UserPreferenceManager.get.setAutoSetTripFields(value),
    );
  }

  Widget _buildField(Id id) {
    if (id == _idStartTimestamp) {
      return _buildStartTime();
    } else if (id == _idEndTimestamp) {
      return _buildEndTime();
    } else if (id == _idTimeZone) {
      return _buildTimeZone();
    } else if (id == _idName) {
      return _buildName();
    } else if (id == _idImages) {
      return _buildImages();
    } else if (id == _idCatchesPerFishingSpot) {
      return _buildCatchesPerFishingSpot();
    } else if (id == _idCatchesPerAngler) {
      return _buildCatchesPerAngler();
    } else if (id == _idCatchesPerBait) {
      return _buildCatchesPerBait();
    } else if (id == _idCatchesPerSpecies) {
      return _buildCatchesPerSpecies();
    } else if (id == _idNotes) {
      return _buildNotes();
    } else if (id == _idCatches) {
      return _buildCatches();
    } else if (id == _idBodiesOfWater) {
      return _buildBodiesOfWater();
    } else if (id == _idAtmosphere) {
      return _buildAtmosphere();
    } else if (id == _idGpsTrails) {
      return _buildGpsTrails();
    } else if (id == _idWaterClarity) {
      return _buildWaterClarity();
    } else if (id == _idWaterDepth) {
      return _buildWaterDepth();
    } else if (id == _idWaterTemperature) {
      return _buildWaterTemperature();
    } else {
      _log.e("Unknown input key: $id");
      return const Empty();
    }
  }

  Widget _buildStartTime() {
    return Padding(
      padding: insetsVerticalSmall,
      child: _DateTimeAllDayPicker(
        controller: _startTimestampController,
        dateLabel: Strings.of(context).saveTripPageStartDate,
        timeLabel: Strings.of(context).saveTripPageStartTime,
        onChange: () => setState(() {}),
      ),
    );
  }

  Widget _buildEndTime() {
    return Padding(
      padding: insetsVerticalSmall,
      child: _DateTimeAllDayPicker(
        controller: _endTimestampController,
        dateLabel: Strings.of(context).saveTripPageEndDate,
        timeLabel: Strings.of(context).saveTripPageEndTime,
        onChange: () => setState(() {}),
      ),
    );
  }

  Widget _buildTimeZone() {
    return TimeZoneInput(
      controller: _timeZoneController,
      onPicked: () {
        _startTimestampController.timeZone = _timeZoneController.value;
        _endTimestampController.timeZone = _timeZoneController.value;
      },
    );
  }

  Widget _buildName() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: TextInput.name(context, controller: _nameController),
    );
  }

  Widget _buildImages() {
    // Convert to and from a Set to ensure all duplicates are removed.
    var images = Set<String>.of(_oldTrip?.imageNames ?? [])
      ..addAll(_catchImages);

    return ImageInput(
      initialImageNames: images.toList(),
      controller: _imagesController,
    );
  }

  Widget _buildCatchesPerFishingSpot() {
    return QuantityPickerInput<FishingSpot, Trip_CatchesPerEntity>(
      title: Strings.of(context).tripCatchesPerFishingSpot,
      delegate: FishingSpotQuantityPickerInputDelegate(
        manager: _fishingSpotManager,
        controller: _fishingSpotCatchesController,
      ),
    );
  }

  Widget _buildCatchesPerAngler() {
    return QuantityPickerInput<Angler, Trip_CatchesPerEntity>(
      title: Strings.of(context).tripCatchesPerAngler,
      delegate: EntityQuantityPickerInputDelegate<Angler>(
        manager: _anglerManager,
        controller: _anglerCatchesController,
        listPageBuilder: (settings) => AnglerListPage(pickerSettings: settings),
      ),
    );
  }

  Widget _buildCatchesPerBait() {
    return QuantityPickerInput(
      title: Strings.of(context).tripCatchesPerBait,
      delegate: BaitQuantityPickerInputDelegate(
        baitManager: _baitManager,
        controller: _baitCatchesController,
      ),
    );
  }

  Widget _buildCatchesPerSpecies() {
    return QuantityPickerInput<Species, Trip_CatchesPerEntity>(
      title: Strings.of(context).tripCatchesPerSpecies,
      delegate: EntityQuantityPickerInputDelegate<Species>(
        manager: _speciesManager,
        controller: _speciesCatchesController,
        listPageBuilder: (settings) =>
            SpeciesListPage(pickerSettings: settings),
      ),
    );
  }

  Widget _buildNotes() {
    return Padding(
      padding: insetsHorizontalDefaultBottomDefault,
      child: TextInput.description(
        context,
        title: Strings.of(context).inputNotesLabel,
        controller: _notesController,
      ),
    );
  }

  Widget _buildWaterClarity() {
    return WaterClarityInput(_waterClarityController);
  }

  Widget _buildWaterDepth() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(_waterDepthController),
    );
  }

  Widget _buildWaterTemperature() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(_waterTemperatureController),
    );
  }

  Widget _buildCatches() {
    return EntityPickerInput<Catch>.multi(
      manager: _catchManager,
      controller: _catchesController,
      emptyValue: Strings.of(context).saveTripPageNoCatches,
      isHidden: !_fields[_idCatches]!.isShowing,
      listPage: (pickerSettings) =>
          CatchListPage(pickerSettings: pickerSettings),
      onPicked: (ids) => setState(() {
        _catchesController.value = ids;

        if (ids.isNotEmpty) {
          var catches = _catchManager.catches(
            context,
            opt: CatchFilterOptions(
              order: CatchFilterOptions_Order.newest_to_oldest,
              catchIds: ids,
            ),
          );

          _updateTimestampControllersIfNeeded(catches);
          _updateCatchesPerEntityControllersIfNeeded(catches);
          _updateBodiesOfWaterController(catches);
          _updateCatchImages(catches);
          _updateAtmosphereIfNeeded();
        }
      }),
    );
  }

  Widget _buildBodiesOfWater() {
    return EntityPickerInput<BodyOfWater>.multi(
      manager: _bodyOfWaterManager,
      controller: _bodiesOfWaterController,
      emptyValue: Strings.of(context).saveTripPageNoBodiesOfWater,
      isHidden: !_fields[_idBodiesOfWater]!.isShowing,
      listPage: (pickerSettings) =>
          BodyOfWaterListPage(pickerSettings: pickerSettings),
      onPicked: (ids) => setState(() => _bodiesOfWaterController.value = ids),
    );
  }

  Widget _buildAtmosphere() {
    return AtmosphereInput(
      fetcher: _newAtmosphereFetcher(),
      controller: _atmosphereController,
      fishingSpot: _firstKnownFishingSpot(),
    );
  }

  Widget _buildGpsTrails() {
    return EntityPickerInput<GpsTrail>.multi(
      manager: _gpsTrailManager,
      controller: _gpsTrailsController,
      emptyValue: Strings.of(context).saveTripPageNoGpsTrails,
      isHidden: !_fields[_idGpsTrails]!.isShowing,
      listPage: (pickerSettings) =>
          GpsTrailListPage(pickerSettings: pickerSettings),
      onPicked: (ids) => setState(() => _gpsTrailsController.value = ids),
    );
  }

  AtmosphereFetcher _newAtmosphereFetcher() {
    // Use the timestamp in the middle of the start and end times.
    var startMs = _startTimestampController.timestamp;
    var endMs = _endTimestampController.timestamp;
    var time = ((endMs + startMs) / 2).round();

    return AtmosphereFetcher(
      TimeManager.get.dateTime(time, _timeZoneController.value),
      // Use the first location we know about.
      _firstKnownFishingSpot()?.latLng,
    );
  }

  FishingSpot? _firstKnownFishingSpot() {
    FishingSpot? fishingSpot;
    for (var id in _catchesController.value) {
      var cat = _catchManager.entity(id);
      if (cat == null || !cat.hasFishingSpotId()) {
        continue;
      }

      fishingSpot = _fishingSpotManager.entity(cat.fishingSpotId);
      if (fishingSpot != null) {
        break;
      }
    }

    return fishingSpot;
  }

  /// Update date and time values based on picked catches. This will not update
  /// the time if "All day" checkboxes are checked. This will _not_ overwrite any
  /// changes the user made to the time.
  void _updateTimestampControllersIfNeeded(List<Catch> catches) {
    if (!UserPreferenceManager.get.autoSetTripFields) {
      return;
    }

    var startDateTime = catches.last.dateTime(context);
    if (_startTimestampController.isMidnight) {
      _startTimestampController.date = startDateTime;
    } else {
      _startTimestampController.value = startDateTime;
    }

    var endDateTime = catches.first.dateTime(context);
    if (_endTimestampController.isMidnight) {
      _endTimestampController.date = endDateTime;
    } else {
      _endTimestampController.value = endDateTime;
    }
  }

  /// Updates "Catches Per Entity" values based on the given catches.
  /// This will _not_ overwrite any changes the user made to the catches per
  /// entity values.
  void _updateCatchesPerEntityControllersIfNeeded(List<Catch> catches) {
    if (!UserPreferenceManager.get.autoSetTripFields) {
      return;
    }

    var catchesPerAngler = <Trip_CatchesPerEntity>[];
    var catchesPerBait = <Trip_CatchesPerBait>[];
    var catchesPerFishingSpot = <Trip_CatchesPerEntity>[];
    var catchesPerSpecies = <Trip_CatchesPerEntity>[];

    for (var cat in catches) {
      if (_fields[_idCatchesPerAngler]!.isShowing) {
        Trips.incCatchesPerEntity(catchesPerAngler, cat.anglerId, cat);
      }

      if (_fields[_idCatchesPerFishingSpot]!.isShowing) {
        Trips.incCatchesPerEntity(
          catchesPerFishingSpot,
          cat.fishingSpotId,
          cat,
        );
      }

      if (_fields[_idCatchesPerSpecies]!.isShowing) {
        Trips.incCatchesPerEntity(catchesPerSpecies, cat.speciesId, cat);
      }

      if (_fields[_idCatchesPerBait]!.isShowing) {
        Trips.incCatchesPerBait(catchesPerBait, cat);
      }
    }

    _anglerCatchesController.value = catchesPerAngler.toSet();
    _baitCatchesController.value = catchesPerBait.toSet();
    _fishingSpotCatchesController.value = catchesPerFishingSpot.toSet();
    _speciesCatchesController.value = catchesPerSpecies.toSet();
  }

  /// Adds body of water values based on the given catches. This will add to
  /// the body of water values already selected by the user, if any.
  void _updateBodiesOfWaterController(List<Catch> catches) {
    if (!_fields[_idBodiesOfWater]!.isShowing) {
      return;
    }

    var bowIds = <Id>{};

    for (var cat in catches) {
      var bowId = _fishingSpotManager.entity(cat.fishingSpotId)?.bodyOfWaterId;
      if (Ids.isValid(bowId)) {
        bowIds.add(bowId!);
      }
    }

    _bodiesOfWaterController.addAll(bowIds);
  }

  void _updateAtmosphereIfNeeded() {
    if (SubscriptionManager.get.isFree ||
        !_fields[_idAtmosphere]!.isShowing ||
        !UserPreferenceManager.get.autoFetchAtmosphere ||
        !UserPreferenceManager.get.autoSetTripFields) {
      return;
    }

    _newAtmosphereFetcher()
        .fetch(context)
        .then((result) => _atmosphereController.value = result.data);
  }

  /// Adds images based on the given catches. This will add photos to any
  /// existing photos already attached by the user.
  void _updateCatchImages(List<Catch> catches) {
    if (!_fields[_idImages]!.isShowing) {
      return;
    }

    _catchImages.addAll(
      catches.fold<List<String>>(
        <String>[],
        (prev, cat) => prev..addAll(cat.imageNames),
      ),
    );
  }

  FutureOr<bool> _save(Map<Id, dynamic> customFieldValueMap) {
    // imageNames is set in _tripManager.addOrUpdate.
    var newTrip = Trip(
      id: _oldTrip?.id ?? randomId(),
      startTimestamp: Int64(_startTimestampController.timestamp),
      endTimestamp: Int64(_endTimestampController.timestamp),
      timeZone: _timeZoneController.value,
      catchIds: _catchesController.value,
      bodyOfWaterIds: _bodiesOfWaterController.value,
      catchesPerSpecies: _speciesCatchesController.value,
      catchesPerAngler: _anglerCatchesController.value,
      catchesPerFishingSpot: _fishingSpotCatchesController.value,
      catchesPerBait: _baitCatchesController.value,
      customEntityValues: entityValuesFromMap(customFieldValueMap),
      gpsTrailIds: _gpsTrailsController.value,
    );

    if (isNotEmpty(_nameController.value)) {
      newTrip.name = _nameController.value!;
    }

    if (_atmosphereController.hasValue) {
      newTrip.atmosphere = _atmosphereController.value!;
      newTrip.atmosphere.timeZone = newTrip.timeZone;
    }

    if (isNotEmpty(_notesController.value)) {
      newTrip.notes = _notesController.value!;
    }

    if (_waterClarityController.hasValue) {
      newTrip.waterClarityId = _waterClarityController.value!;
    }

    if (_waterDepthController.isSet) {
      newTrip.waterDepth = _waterDepthController.value;
    }

    if (_waterTemperatureController.isSet) {
      newTrip.waterTemperature = _waterTemperatureController.value;
    }

    _tripManager.addOrUpdate(
      newTrip,
      imageFiles: _imagesController.originalFiles,
    );

    return true;
  }
}

class _DateTimeAllDayPicker extends StatefulWidget {
  final DateTimeInputController controller;
  final String dateLabel;
  final String timeLabel;
  final VoidCallback? onChange;

  const _DateTimeAllDayPicker({
    required this.controller,
    required this.dateLabel,
    required this.timeLabel,
    this.onChange,
  });

  @override
  State<_DateTimeAllDayPicker> createState() => _DateTimeAllDayPickerState();
}

class _DateTimeAllDayPickerState extends State<_DateTimeAllDayPicker> {
  bool _isAllDay = false;

  @override
  void initState() {
    super.initState();
    _isAllDay = widget.controller.isMidnight;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DateTimePicker(
            datePicker: DatePicker(
              context,
              controller: widget.controller,
              label: widget.dateLabel,
              onChange: (_) => widget.onChange?.call(),
            ),
            timePicker: TimePicker(
              context,
              controller: widget.controller,
              label: widget.timeLabel,
              enabled: !_isAllDay,
              onChange: (_) => widget.onChange?.call(),
            ),
          ),
        ),
        Row(
          children: [
            Text(Strings.of(context).saveTripPageAllDay),
            Container(width: paddingSmall),
            PaddedCheckbox(
              checked: _isAllDay,
              onChanged: (checked) => setState(() {
                _isAllDay = checked;
                widget.controller.time = const TimeOfDay(hour: 0, minute: 0);
              }),
            ),
            Container(width: paddingDefault),
          ],
        ),
      ],
    );
  }
}
