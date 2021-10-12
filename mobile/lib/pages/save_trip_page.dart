import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/widgets/date_time_picker.dart';
import 'package:mobile/widgets/field.dart';
import 'package:mobile/widgets/image_input.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/input_controller.dart';
import '../widgets/text_input.dart';

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

    _fields[_idImages] = Field(
      id: _idImages,
      name: (context) => Strings.of(context).inputPhotosLabel,
      controller: ImagesInputController(),
    );

    if (_isEditing) {
      _startTimestampController.value = _oldTrip!.startTimestamp.toInt();
      _endTimestampController.value = _oldTrip!.endTimestamp.toInt();
      _nameController.value = _oldTrip!.hasName() ? _oldTrip!.name : null;
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
    } else {
      _log.e("Unknown input key: $id");
      return Empty();
    }
  }

  Widget _buildStartTime() {
    return Padding(
      padding: insetsVerticalWidgetSmall,
      child: DateTimePicker(
        datePicker: DatePicker(
          context,
          controller: _startTimestampController,
          label: Strings.of(context).saveTripPageStartDate,
        ),
        timePicker: TimePicker(
          context,
          controller: _startTimestampController,
          label: Strings.of(context).saveTripPageStartDate,
        ),
      ),
    );
  }

  Widget _buildEndTime() {
    return Padding(
      padding: insetsVerticalWidgetSmall,
      child: DateTimePicker(
        datePicker: DatePicker(
          context,
          controller: _endTimestampController,
          label: Strings.of(context).saveTripPageEndDate,
        ),
        timePicker: TimePicker(
          context,
          controller: _endTimestampController,
          label: Strings.of(context).saveTripPageEndDate,
        ),
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

  FutureOr<bool> _save(Map<Id, dynamic> customFieldValueMap) {
    _userPreferenceManager
        .setTripCustomEntityIds(customFieldValueMap.keys.toList());

    // imageNames is set in _tripManager.addOrUpdate.
    var newTrip = Trip(
      id: _oldTrip?.id ?? randomId(),
      startTimestamp: Int64(_startTimestampController.value),
      endTimestamp: Int64(_endTimestampController.value),
      customEntityValues: entityValuesFromMap(customFieldValueMap),
    );

    if (isNotEmpty(_nameController.value)) {
      newTrip.name = _nameController.value!;
    }

    _tripManager.addOrUpdate(
      newTrip,
      imageFiles: _imagesController.originalFiles,
    );

    return true;
  }
}
