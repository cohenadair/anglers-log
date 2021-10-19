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
  static final _idFishingSpotCatches =
      Id(uuid: "70d19321-1cc7-4842-b7e4-252ce79f18d0");
  static final _idAnglerCatches =
      Id(uuid: "20288727-76f3-49fc-a975-0d740931e3a4");
  static final _idSpeciesCatches =
      Id(uuid: "d7864201-af18-464a-8815-571aa6f82f8c");
  static final _idBaitCatches =
      Id(uuid: "ad35c21c-13cb-486b-812d-6315d0bf5004");
  static final _idNotes = Id(uuid: "3d3bc3c9-e316-49fe-8427-ae344dffe38e");
  static final _idWasSkunked = Id(uuid: "f976b2b5-e5e8-441e-9c72-e66ca234d744");
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

  BoolInputController get _wasSkunkedController =>
      _fields[_idWasSkunked]!.controller as BoolInputController;

  SetInputController<Trip_EntityCatches> get _speciesCatchesController =>
      _fields[_idSpeciesCatches]!.controller
          as SetInputController<Trip_EntityCatches>;

  SetInputController<Trip_EntityCatches> get _anglerCatchesController =>
      _fields[_idAnglerCatches]!.controller
          as SetInputController<Trip_EntityCatches>;

  SetInputController<Trip_EntityCatches> get _fishingSpotCatchesController =>
      _fields[_idFishingSpotCatches]!.controller
          as SetInputController<Trip_EntityCatches>;

  SetInputController<Trip_BaitCatches> get _baitCatchesController =>
      _fields[_idBaitCatches]!.controller
          as SetInputController<Trip_BaitCatches>;

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

    _fields[_idWasSkunked] = Field(
      id: _idWasSkunked,
      name: (context) => Strings.of(context).saveTripPageSkunked,
      controller: BoolInputController(),
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

    _fields[_idAnglerCatches] = Field(
      id: _idAnglerCatches,
      name: (context) => Strings.of(context).saveTripPageAnglerCatches,
      controller: SetInputController<Trip_EntityCatches>(),
    );

    _fields[_idBaitCatches] = Field(
      id: _idBaitCatches,
      name: (context) => Strings.of(context).saveTripPageBaitCatches,
      controller: SetInputController<Trip_BaitCatches>(),
    );

    _fields[_idFishingSpotCatches] = Field(
      id: _idFishingSpotCatches,
      name: (context) => Strings.of(context).saveTripPageFishingSpotCatches,
      controller: SetInputController<Trip_EntityCatches>(),
    );

    _fields[_idSpeciesCatches] = Field(
      id: _idSpeciesCatches,
      name: (context) => Strings.of(context).saveTripPageSpeciesCatches,
      controller: SetInputController<Trip_EntityCatches>(),
    );

    _fields[_idCatches] = Field(
      id: _idCatches,
      name: (context) => Strings.of(context).saveTripPageCatches,
      description: (context) => Strings.of(context).saveTripPageCatchesDesc,
      controller: SetInputController<Id>(),
    );

    _fields[_idBodiesOfWater] = Field(
      id: _idBodiesOfWater,
      name: (context) => Strings.of(context).saveTripPageBodiesOfWater,
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
      _wasSkunkedController.value = _oldTrip!.wasSkunked;
      _notesController.value = _oldTrip!.hasNotes() ? _oldTrip!.notes : null;
      _speciesCatchesController.value = _oldTrip!.speciesCatches.toSet();
      _anglerCatchesController.value = _oldTrip!.anglerCatches.toSet();
      _fishingSpotCatchesController.value =
          _oldTrip!.fishingSpotCatches.toSet();
      _baitCatchesController.value = _oldTrip!.baitCatches.toSet();
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
      customEntityIds: _userPreferenceManager.tripCustomEntityIds,
      customEntityValues: _customEntityValues,
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
    } else if (id == _idFishingSpotCatches) {
      return _buildFishingSpotCatches();
    } else if (id == _idAnglerCatches) {
      return _buildAnglerCatches();
    } else if (id == _idBaitCatches) {
      return _buildBaitCatches();
    } else if (id == _idSpeciesCatches) {
      return _buildSpeciesCatches();
    } else if (id == _idNotes) {
      return _buildNotes();
    } else if (id == _idCatches) {
      return _buildCatches();
    } else if (id == _idBodiesOfWater) {
      return _buildBodiesOfWater();
    } else if (id == _idWasSkunked) {
      return _buildSkunked();
    } else if (id == _idAtmosphere) {
      return _buildAtmosphere();
    } else {
      _log.e("Unknown input key: $id");
      return Empty();
    }
  }

  Widget _buildStartTime() {
    return Padding(
      padding: insetsVerticalWidgetSmall,
      child: _DateTimeAllDayPicker(
        controller: _startTimestampController,
        dateLabel: Strings.of(context).saveTripPageStartDate,
        timeLabel: Strings.of(context).saveTripPageStartDate,
      ),
    );
  }

  Widget _buildEndTime() {
    return Padding(
      padding: insetsVerticalWidgetSmall,
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

  Widget _buildFishingSpotCatches() {
    return QuantityPickerInput<FishingSpot, Trip_EntityCatches>(
      title: Strings.of(context).saveTripPageFishingSpotCatches,
      pickerTitle: Strings.of(context).pickerTitleFishingSpots,
      delegate: FishingSpotQuantityPickerInputDelegate(
        manager: _fishingSpotManager,
        controller: _fishingSpotCatchesController,
      ),
    );
  }

  Widget _buildAnglerCatches() {
    return QuantityPickerInput<Angler, Trip_EntityCatches>(
      title: Strings.of(context).saveTripPageAnglerCatches,
      pickerTitle: Strings.of(context).pickerTitleAnglers,
      delegate: EntityQuantityPickerInputDelegate<Angler>(
        manager: _anglerManager,
        controller: _anglerCatchesController,
        listPageBuilder: (settings) => AnglerListPage(pickerSettings: settings),
      ),
    );
  }

  Widget _buildBaitCatches() {
    return QuantityPickerInput(
      title: Strings.of(context).saveTripPageBaitCatches,
      delegate: BaitQuantityPickerInputDelegate(
        baitManager: _baitManager,
        controller: _baitCatchesController,
      ),
    );
  }

  Widget _buildSpeciesCatches() {
    return QuantityPickerInput<Species, Trip_EntityCatches>(
      title: Strings.of(context).saveTripPageSpeciesCatches,
      pickerTitle: Strings.of(context).pickerTitleSpecies,
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
      padding: insetsHorizontalDefaultBottomWidget,
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
      onPicked: (ids) => setState(() => _catchesController.value = ids),
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

  Widget _buildSkunked() {
    return CheckboxInput(
      label: Strings.of(context).saveTripPageSkunked,
      value: _wasSkunkedController.value,
      onChanged: (checked) => _wasSkunkedController.value = checked,
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
    _userPreferenceManager
        .setTripCustomEntityIds(customFieldValueMap.keys.toList());

    // imageNames is set in _tripManager.addOrUpdate.
    var newTrip = Trip(
      id: _oldTrip?.id ?? randomId(),
      startTimestamp: Int64(_startTimestampController.value),
      endTimestamp: Int64(_endTimestampController.value),
      speciesCatches: _speciesCatchesController.value,
      anglerCatches: _anglerCatchesController.value,
      fishingSpotCatches: _fishingSpotCatchesController.value,
      baitCatches: _baitCatchesController.value,
      customEntityValues: entityValuesFromMap(customFieldValueMap),
    );

    if (isNotEmpty(_nameController.value)) {
      newTrip.name = _nameController.value!;
    }

    if (_catchesController.value.isNotEmpty) {
      newTrip.catchIds.addAll(_catchesController.value);
    } else {
      newTrip.catchIds.clear();
    }

    if (_bodiesOfWaterController.value.isNotEmpty) {
      newTrip.bodyOfWaterIds.addAll(_bodiesOfWaterController.value);
    } else {
      newTrip.bodyOfWaterIds.clear();
    }

    if (_atmosphereController.hasValue) {
      newTrip.atmosphere = _atmosphereController.value!;
    }

    _tripManager.addOrUpdate(
      newTrip,
      imageFiles: _imagesController.originalFiles,
    );

    if (isNotEmpty(_notesController.value)) {
      newTrip.notes = _notesController.value!;
    }

    // If the user cares about (i.e. the field is showing) whether or not they
    // were skunked, always set it.
    if (_fields[_idWasSkunked] != null && _fields[_idWasSkunked]!.isShowing) {
      newTrip.wasSkunked = _wasSkunkedController.value;
    }

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
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DateTimePicker(
            datePicker: DatePicker(
              context,
              controller: widget.controller,
              label: Strings.of(context).saveTripPageStartDate,
            ),
            timePicker: TimePicker(
              context,
              controller: widget.controller,
              label: Strings.of(context).saveTripPageStartDate,
              enabled: !_isAllDay,
            ),
          ),
        ),
        Row(
          children: [
            Text(Strings.of(context).saveTripPageAllDay),
            const HorizontalSpace(paddingWidgetSmall),
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
