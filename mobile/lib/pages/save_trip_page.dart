import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:mobile/angler_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/pages/body_of_water_list_page.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/widgets/atmosphere_input.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/date_time_picker.dart';
import 'package:mobile/widgets/entity_picker_input.dart';
import 'package:mobile/widgets/field.dart';
import 'package:mobile/widgets/image_input.dart';
import 'package:mobile/widgets/quantity_picker_input.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

import '../app_manager.dart';
import '../atmosphere_fetcher.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/input_controller.dart';
import '../widgets/text_input.dart';
import 'angler_list_page.dart';
import 'species_list_page.dart';

class SaveTripPage extends StatefulWidget {
  final Trip? oldTrip;

  const SaveTripPage() : oldTrip = null;

  const SaveTripPage.edit(this.oldTrip);

  @override
  _SaveTripPageState createState() => _SaveTripPageState();
}

class _SaveTripPageState extends State<SaveTripPage> {
  // Unique IDs for each field. These are stored in the database and should not
  // be changed.
  static final _idStartTimestamp =
      Id(uuid: "0f012ca1-aae3-4aec-86e2-d85479eb6d66");
  static final _idEndTimestamp =
      Id(uuid: "c6afa4ff-add6-4a01-b69a-ba6f9b456c85");
  static final _idName = Id(uuid: "d9a83fa6-926d-474d-8ddf-8d0e044d2ea4");
  static final _idImages = Id(uuid: "8c593cbb-4782-49c7-b540-0c22d8175b3f");
  static final _idCatches = Id(uuid: "0806fcc4-5d77-44b4-85e2-ebc066f37e12");
  static final _idBodiesOfWater =
      Id(uuid: "45c91a90-62d1-47fe-b360-c5494a265ef6");
  static final _idCatchesPerFishingSpot =
      Id(uuid: "70d19321-1cc7-4842-b7e4-252ce79f18d0");
  static final _idCatchesPerAngler =
      Id(uuid: "20288727-76f3-49fc-a975-0d740931e3a4");
  static final _idCatchesPerSpecies =
      Id(uuid: "d7864201-af18-464a-8815-571aa6f82f8c");
  static final _idCatchesPerBait =
      Id(uuid: "ad35c21c-13cb-486b-812d-6315d0bf5004");
  static final _idNotes = Id(uuid: "3d3bc3c9-e316-49fe-8427-ae344dffe38e");
  static final _idAtmosphere = Id(uuid: "b7f6ad7f-e1b8-4e15-b29c-688429787dd9");

  final _log = const Log("SaveTripPage");
  final Map<Id, Field> _fields = {};

  List<CustomEntityValue> _customEntityValues = [];

  Trip? get _oldTrip => widget.oldTrip;

  bool get _isEditing => _oldTrip != null;

  AnglerManager get _anglerManager => AnglerManager.of(context);

  AppManager get _appManager => AppManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  CatchManager get _catchManager => CatchManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  TimeManager get _timeManager => TimeManager.of(context);

  TripManager get _tripManager => TripManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  TimestampInputController get _startTimestampController =>
      _fields[_idStartTimestamp]!.controller as TimestampInputController;

  TimestampInputController get _endTimestampController =>
      _fields[_idEndTimestamp]!.controller as TimestampInputController;

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

  @override
  void initState() {
    super.initState();

    _fields[_idStartTimestamp] = Field(
      id: _idStartTimestamp,
      isRemovable: false,
      name: (context) => Strings.of(context).saveTripPageStartDateTime,
      controller: TimestampInputController(_timeManager),
    );

    _fields[_idEndTimestamp] = Field(
      id: _idEndTimestamp,
      isRemovable: false,
      name: (context) => Strings.of(context).saveTripPageEndDateTime,
      controller: TimestampInputController(_timeManager),
    );

    _fields[_idName] = Field(
      id: _idName,
      name: (context) => Strings.of(context).inputNameLabel,
      controller: TextInputController(),
    );

    _fields[_idNotes] = Field(
      id: _idNotes,
      name: (context) => Strings.of(context).inputNotesLabel,
      controller: TextInputController(),
    );

    _fields[_idImages] = Field(
      id: _idImages,
      name: (context) => Strings.of(context).inputPhotosLabel,
      controller: ImagesInputController(),
    );

    _fields[_idAtmosphere] = Field(
      id: _idAtmosphere,
      name: (context) => Strings.of(context).inputAtmosphere,
      controller: InputController<Atmosphere>(),
    );

    _fields[_idCatchesPerAngler] = Field(
      id: _idCatchesPerAngler,
      name: (context) => Strings.of(context).tripCatchesPerAngler,
      controller: SetInputController<Trip_CatchesPerEntity>(),
    );

    _fields[_idCatchesPerBait] = Field(
      id: _idCatchesPerBait,
      name: (context) => Strings.of(context).tripCatchesPerBait,
      controller: SetInputController<Trip_CatchesPerBait>(),
    );

    _fields[_idCatchesPerFishingSpot] = Field(
      id: _idCatchesPerFishingSpot,
      name: (context) => Strings.of(context).tripCatchesPerFishingSpot,
      controller: SetInputController<Trip_CatchesPerEntity>(),
    );

    _fields[_idCatchesPerSpecies] = Field(
      id: _idCatchesPerSpecies,
      name: (context) => Strings.of(context).tripCatchesPerSpecies,
      controller: SetInputController<Trip_CatchesPerEntity>(),
    );

    _fields[_idCatches] = Field(
      id: _idCatches,
      name: (context) => Strings.of(context).entityNameCatches,
      description: (context) => Strings.of(context).saveTripPageCatchesDesc,
      controller: SetInputController<Id>(),
    );

    _fields[_idBodiesOfWater] = Field(
      id: _idBodiesOfWater,
      name: (context) => Strings.of(context).entityNameBodiesOfWater,
      controller: SetInputController<Id>(),
    );

    if (_isEditing) {
      _startTimestampController.value = _oldTrip!.startTimestamp.toInt();
      _endTimestampController.value = _oldTrip!.endTimestamp.toInt();
      _nameController.value = _oldTrip!.hasName() ? _oldTrip!.name : null;
      _catchesController.value = _oldTrip!.catchIds.toSet();
      _bodiesOfWaterController.value = _oldTrip!.bodyOfWaterIds.toSet();
      _atmosphereController.value =
          _oldTrip!.hasAtmosphere() ? _oldTrip!.atmosphere : null;
      _notesController.value = _oldTrip!.hasNotes() ? _oldTrip!.notes : null;
      _speciesCatchesController.value = _oldTrip!.catchesPerSpecies.toSet();
      _anglerCatchesController.value = _oldTrip!.catchesPerAngler.toSet();
      _fishingSpotCatchesController.value =
          _oldTrip!.catchesPerFishingSpot.toSet();
      _baitCatchesController.value = _oldTrip!.catchesPerBait.toSet();
      _customEntityValues = _oldTrip!.customEntityValues;
    }
  }

  @override
  Widget build(BuildContext context) {
    return EditableFormPage(
      title: Text(_isEditing
          ? Strings.of(context).saveTripPageEditTitle
          : Strings.of(context).saveTripPageNewTitle),
      padding: insetsZero,
      runSpacing: 0,
      fields: _fields,
      trackedFieldIds: _userPreferenceManager.tripFieldIds,
      customEntityValues: _customEntityValues,
      showTopCustomFieldPadding: false,
      onBuildField: _buildField,
      onAddFields: (ids) =>
          _userPreferenceManager.setTripFieldIds(ids.toList()),
      onSave: _save,
    );
  }

  Widget _buildField(Id id) {
    if (id == _idStartTimestamp) {
      return _buildStartTime();
    } else if (id == _idEndTimestamp) {
      return _buildEndTime();
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
        timeLabel: Strings.of(context).saveTripPageStartDate,
      ),
    );
  }

  Widget _buildEndTime() {
    return Padding(
      padding: insetsVerticalSmall,
      child: _DateTimeAllDayPicker(
        controller: _endTimestampController,
        dateLabel: Strings.of(context).saveTripPageEndDate,
        timeLabel: Strings.of(context).saveTripPageEndDate,
      ),
    );
  }

  Widget _buildName() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: TextInput.name(
        context,
        controller: _nameController,
      ),
    );
  }

  Widget _buildImages() {
    return ImageInput(
      initialImageNames: _oldTrip?.imageNames ?? [],
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
            sortOrder: CatchSortOrder.newestToOldest,
            catchIds: ids,
          );

          // Automatically update trip start and end time based on picked
          // catches.
          _startTimestampController.value = catches.last.timestamp.toInt();
          _endTimestampController.value = catches.first.timestamp.toInt();
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
    // Use the first location we know about.
    var latLng = _locationMonitor.currentLocation;
    for (var id in _catchesController.value) {
      var cat = _catchManager.entity(id);
      if (cat == null || !cat.hasFishingSpotId()) {
        continue;
      }

      var fishingSpot = _fishingSpotManager.entity(cat.fishingSpotId);
      if (fishingSpot != null) {
        latLng = fishingSpot.latLng;
        break;
      }
    }

    // Use the timestamp in the middle of the start and end times.
    var time =
        ((_endTimestampController.value + _startTimestampController.value) / 2)
            .round();
    var fetcher = AtmosphereFetcher(_appManager, time, latLng);

    return AtmosphereInput(
      fetcher: fetcher,
      controller: _atmosphereController,
    );
  }

  FutureOr<bool> _save(Map<Id, dynamic> customFieldValueMap) {
    // imageNames is set in _tripManager.addOrUpdate.
    var newTrip = Trip(
      id: _oldTrip?.id ?? randomId(),
      startTimestamp: Int64(_startTimestampController.value),
      endTimestamp: Int64(_endTimestampController.value),
      catchIds: _catchesController.value,
      bodyOfWaterIds: _bodiesOfWaterController.value,
      catchesPerSpecies: _speciesCatchesController.value,
      catchesPerAngler: _anglerCatchesController.value,
      catchesPerFishingSpot: _fishingSpotCatchesController.value,
      catchesPerBait: _baitCatchesController.value,
      customEntityValues: entityValuesFromMap(customFieldValueMap),
    );

    if (isNotEmpty(_nameController.value)) {
      newTrip.name = _nameController.value!;
    }

    if (_atmosphereController.hasValue) {
      newTrip.atmosphere = _atmosphereController.value!;
    }

    if (isNotEmpty(_notesController.value)) {
      newTrip.notes = _notesController.value!;
    }

    _tripManager.addOrUpdate(
      newTrip,
      imageFiles: _imagesController.originalFiles,
    );

    return true;
  }
}

class _DateTimeAllDayPicker extends StatefulWidget {
  final TimestampInputController controller;
  final String dateLabel;
  final String timeLabel;

  const _DateTimeAllDayPicker({
    required this.controller,
    required this.dateLabel,
    required this.timeLabel,
  });

  @override
  State<_DateTimeAllDayPicker> createState() => _DateTimeAllDayPickerState();
}

class _DateTimeAllDayPickerState extends State<_DateTimeAllDayPicker> {
  bool _isAllDay = false;

  @override
  void initState() {
    super.initState();
    _isAllDay = widget.controller.timeInMillis == 0;
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
            ),
            timePicker: TimePicker(
              context,
              controller: widget.controller,
              label: widget.timeLabel,
              enabled: !_isAllDay,
            ),
          ),
        ),
        Row(
          children: [
            Text(Strings.of(context).saveTripPageAllDay),
            const HorizontalSpace(paddingSmall),
            PaddedCheckbox(
              checked: _isAllDay,
              onChanged: (checked) => setState(() {
                _isAllDay = checked;
                widget.controller.time = const TimeOfDay(hour: 0, minute: 0);
              }),
            ),
            const HorizontalSpace(paddingDefault),
          ],
        ),
      ],
    );
  }
}
