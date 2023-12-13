import 'package:flutter/material.dart';
import 'package:mobile/gear_manager.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../utils/gear_utils.dart';
import '../utils/validator.dart';
import '../widgets/field.dart';
import '../widgets/image_input.dart';
import '../widgets/input_controller.dart';
import '../widgets/list_picker_input.dart';
import '../widgets/multi_measurement_input.dart';
import '../widgets/text_input.dart';
import '../widgets/widget.dart';
import 'form_page.dart';
import 'image_picker_page.dart';

class SaveGearPage extends StatefulWidget {
  final Gear? oldGear;

  const SaveGearPage() : oldGear = null;

  const SaveGearPage.edit(this.oldGear);

  @override
  State<SaveGearPage> createState() => _SaveGearPageState();
}

class _SaveGearPageState extends State<SaveGearPage> {
  static final _idName = gearFieldIdName;
  static final _idImage = gearFieldIdImage;
  static final _idRodMakeModel = gearFieldIdRodMakeModel;
  static final _idRodSerialNumber = gearFieldIdRodSerialNumber;
  static final _idRodLength = gearFieldIdRodLength;
  static final _idRodAction = gearFieldIdRodAction;
  static final _idRodPower = gearFieldIdRodPower;
  static final _idReelMakeModel = gearFieldIdReelMakeModel;
  static final _idReelSerialNumber = gearFieldIdReelSerialNumber;
  static final _idReelSize = gearFieldIdReelSize;
  static final _idLineMakeModel = gearFieldIdLineMakeModel;
  static final _idLineRating = gearFieldIdLineRating;
  static final _idLineColor = gearFieldIdLineColor;
  static final _idLeaderLength = gearFieldIdLeaderLength;
  static final _idLeaderRating = gearFieldIdLeaderRating;
  static final _idTippetLength = gearFieldIdTippetLength;
  static final _idTippetRating = gearFieldIdTippetRating;
  static final _idHookMakeModel = gearFieldIdHookMakeModel;
  static final _idHookSize = gearFieldIdHookSize;

  final _log = const Log("SaveGearPage");
  final _fields = <Id, Field>{};

  List<CustomEntityValue> _customEntityValues = [];

  GearManager get _gearManager => GearManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  TextInputController get _nameController =>
      _fields[_idName]!.controller as TextInputController;

  InputController<PickedImage> get _imageController =>
      _fields[_idImage]!.controller as InputController<PickedImage>;

  TextInputController get _rodMakeModelController =>
      _fields[_idRodMakeModel]!.controller as TextInputController;

  TextInputController get _rodSerialNumberController =>
      _fields[_idRodSerialNumber]!.controller as TextInputController;

  MultiMeasurementInputController get _rodLengthController =>
      _fields[_idRodLength]!.controller as MultiMeasurementInputController;

  InputController<RodAction> get _rodActionController =>
      _fields[_idRodAction]!.controller as InputController<RodAction>;

  InputController<RodPower> get _rodPowerController =>
      _fields[_idRodPower]!.controller as InputController<RodPower>;

  TextInputController get _reelMakeModelController =>
      _fields[_idReelMakeModel]!.controller as TextInputController;

  TextInputController get _reelSerialNumberController =>
      _fields[_idReelSerialNumber]!.controller as TextInputController;

  TextInputController get _reelSizeController =>
      _fields[_idReelSize]!.controller as TextInputController;

  TextInputController get _lineMakeModelController =>
      _fields[_idLineMakeModel]!.controller as TextInputController;

  MultiMeasurementInputController get _lineRatingController =>
      _fields[_idLineRating]!.controller as MultiMeasurementInputController;

  TextInputController get _lineColorController =>
      _fields[_idLineColor]!.controller as TextInputController;

  MultiMeasurementInputController get _leaderLengthController =>
      _fields[_idLeaderLength]!.controller as MultiMeasurementInputController;

  MultiMeasurementInputController get _leaderRatingController =>
      _fields[_idLeaderRating]!.controller as MultiMeasurementInputController;

  MultiMeasurementInputController get _tippetLengthController =>
      _fields[_idTippetLength]!.controller as MultiMeasurementInputController;

  MultiMeasurementInputController get _tippetRatingController =>
      _fields[_idTippetRating]!.controller as MultiMeasurementInputController;

  TextInputController get _hookMakeModelController =>
      _fields[_idHookMakeModel]!.controller as TextInputController;

  MultiMeasurementInputController get _hookSizeController =>
      _fields[_idHookSize]!.controller as MultiMeasurementInputController;

  Gear? get _oldGear => widget.oldGear;

  bool get _isEditing => _oldGear != null;

  @override
  void initState() {
    super.initState();

    for (var field in allGearFields(context)) {
      _fields[field.id] = field;
    }

    // Override the name validator so editing doesn't trigger a duplicate name
    // error message.
    _nameController.validator = NameValidator(
      nameExists: (name) =>
          !_isEditing && GearManager.of(context).nameExists(name),
      nameExistsMessage: (context) =>
          Strings.of(context).saveGearPageNameExists,
    );

    if (_isEditing) {
      _nameController.value = _oldGear!.name;
      _rodMakeModelController.value = _oldGear!.rodMakeModel;
      _rodSerialNumberController.value = _oldGear!.rodSerialNumber;
      _rodLengthController.value =
          _oldGear!.hasRodLength() ? _oldGear!.rodLength : null;
      _rodActionController.value =
          _oldGear!.hasRodAction() ? _oldGear!.rodAction : null;
      _rodPowerController.value =
          _oldGear!.hasRodPower() ? _oldGear!.rodPower : null;
      _reelMakeModelController.value = _oldGear!.reelMakeModel;
      _reelSerialNumberController.value = _oldGear!.reelSerialNumber;
      _reelSizeController.value = _oldGear!.reelSize;
      _lineMakeModelController.value = _oldGear!.lineMakeModel;
      _lineRatingController.value =
          _oldGear!.hasLineRating() ? _oldGear!.lineRating : null;
      _lineColorController.value = _oldGear!.lineColor;
      _leaderLengthController.value =
          _oldGear!.hasLeaderLength() ? _oldGear!.leaderLength : null;
      _leaderRatingController.value =
          _oldGear!.hasLeaderRating() ? _oldGear!.leaderRating : null;
      _tippetLengthController.value =
          _oldGear!.hasTippetLength() ? _oldGear!.tippetLength : null;
      _tippetRatingController.value =
          _oldGear!.hasTippetRating() ? _oldGear!.tippetRating : null;
      _hookMakeModelController.value = _oldGear!.hookMakeModel;
      _hookSizeController.value =
          _oldGear!.hasHookSize() ? _oldGear!.hookSize : null;
      _customEntityValues = _oldGear!.customEntityValues;
    }
  }

  @override
  Widget build(BuildContext context) {
    return EditableFormPage(
      title: Text(_isEditing
          ? Strings.of(context).saveGearPageEditTitle
          : Strings.of(context).saveGearPageNewTitle),
      runSpacing: 0,
      padding: insetsZero,
      fields: _fields,
      trackedFieldIds: _userPreferenceManager.gearFieldIds,
      customEntityValues: _customEntityValues,
      onBuildField: _buildField,
      onAddFields: (ids) =>
          _userPreferenceManager.setGearFieldIds(ids.toList()),
      onSave: _save,
      isInputValid: _isInputValid(),
      overflowOptions: [FormPageOverflowOption.manageUnits(context)],
    );
  }

  Widget _buildField(Id id) {
    if (id == _idName) {
      return _buildName();
    } else if (id == _idImage) {
      return _buildImage();
    } else if (id == _idRodMakeModel) {
      return _buildRodMakeModel();
    } else if (id == _idRodSerialNumber) {
      return _buildRodSerialNumber();
    } else if (id == _idRodLength) {
      return _buildRodLength();
    } else if (id == _idRodAction) {
      return _buildRodAction();
    } else if (id == _idRodPower) {
      return _buildRodPower();
    } else if (id == _idReelMakeModel) {
      return _buildReelMakeModel();
    } else if (id == _idReelSerialNumber) {
      return _buildReelSerialNumber();
    } else if (id == _idReelSize) {
      return _buildReelSize();
    } else if (id == _idLineMakeModel) {
      return _buildLineMakeModel();
    } else if (id == _idLineRating) {
      return _buildLineRating();
    } else if (id == _idLineColor) {
      return _buildLineColor();
    } else if (id == _idLeaderLength) {
      return _buildLeaderLength();
    } else if (id == _idLeaderRating) {
      return _buildLeaderRating();
    } else if (id == _idTippetLength) {
      return _buildTippetLength();
    } else if (id == _idTippetRating) {
      return _buildTippetRating();
    } else if (id == _idHookMakeModel) {
      return _buildHookMakeModel();
    } else if (id == _idHookSize) {
      return _buildHookSize();
    } else {
      _log.e(StackTrace.current, "Unknown input key: $id");
      return const Empty();
    }
  }

  Widget _buildName() {
    return Padding(
      padding: _fields[_idImage]!.isShowing
          ? insetsHorizontalDefaultBottomSmall
          : insetsHorizontalDefaultVerticalSmall,
      child: TextInput.name(
        context,
        label: Strings.of(context).inputNameLabel,
        controller: _nameController,
        autofocus: true,
        // Trigger "Save" button state refresh.
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildImage() {
    return SingleImageInput(
      initialImageName: _oldGear?.imageName,
      controller: _imageController,
    );
  }

  Widget _buildRodMakeModel() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: TextInput.name(
        context,
        label: Strings.of(context).gearFieldRodMakeModel,
        controller: _rodMakeModelController,
      ),
    );
  }

  Widget _buildRodSerialNumber() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: TextInput.name(
        context,
        label: Strings.of(context).gearFieldRodSerialNumber,
        controller: _rodSerialNumberController,
      ),
    );
  }

  Widget _buildRodLength() {
    var padding = insetsHorizontalDefault;
    if (!_fields[_idRodAction]!.isShowing && !_fields[_idRodPower]!.isShowing) {
      padding = insetsHorizontalDefaultBottomDefault;
    }
    return Padding(
      padding: padding,
      child: MultiMeasurementInput(
        spec: _rodLengthController.spec,
        controller: _rodLengthController,
      ),
    );
  }

  Widget _buildRodAction() {
    return Padding(
      padding: _isAnyRodTextFieldShowing() ? insetsTopDefault : insetsZero,
      child: ListPickerInput.withSinglePickerPage<RodAction>(
        context: context,
        controller: _rodActionController,
        title: Strings.of(context).gearFieldRodAction,
        pickerTitle: Strings.of(context).pickerTitleRodAction,
        valueDisplayName: _rodActionController.value?.displayName(context),
        noneItem: RodAction.rod_action_none,
        itemBuilder: RodActions.pickerItems,
        onPicked: (value) => setState(() => _rodActionController.value = value),
      ),
    );
  }

  Widget _buildRodPower() {
    return Padding(
      padding: !_fields[_idRodAction]!.isShowing && _isAnyRodTextFieldShowing()
          ? insetsTopDefault
          : insetsZero,
      child: ListPickerInput.withSinglePickerPage<RodPower>(
        context: context,
        controller: _rodPowerController,
        title: Strings.of(context).gearFieldRodPower,
        pickerTitle: Strings.of(context).pickerTitleRodPower,
        valueDisplayName: _rodPowerController.value?.displayName(context),
        noneItem: RodPower.rod_power_none,
        itemBuilder: RodPowers.pickerItems,
        onPicked: (value) => setState(() => _rodPowerController.value = value),
      ),
    );
  }

  Widget _buildReelMakeModel() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: TextInput.name(
        context,
        label: Strings.of(context).gearFieldReelMakeModel,
        controller: _reelMakeModelController,
      ),
    );
  }

  Widget _buildReelSerialNumber() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: TextInput.name(
        context,
        label: Strings.of(context).gearFieldReelSerialNumber,
        controller: _reelSerialNumberController,
      ),
    );
  }

  Widget _buildReelSize() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: TextInput.name(
        context,
        label: Strings.of(context).gearFieldReelSize,
        controller: _reelSizeController,
      ),
    );
  }

  Widget _buildLineMakeModel() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: TextInput.name(
        context,
        label: Strings.of(context).gearFieldLineMakeModel,
        controller: _lineMakeModelController,
      ),
    );
  }

  Widget _buildLineRating() {
    return Padding(
      padding: insetsHorizontalDefaultBottomDefault,
      child: MultiMeasurementInput(
        spec: _lineRatingController.spec,
        controller: _lineRatingController,
      ),
    );
  }

  Widget _buildLineColor() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: TextInput.name(
        context,
        label: Strings.of(context).gearFieldLineColor,
        controller: _lineColorController,
      ),
    );
  }

  Widget _buildLeaderLength() {
    return Padding(
      padding: insetsHorizontalDefaultBottomDefault,
      child: MultiMeasurementInput(
        spec: _leaderLengthController.spec,
        controller: _leaderLengthController,
      ),
    );
  }

  Widget _buildLeaderRating() {
    return Padding(
      padding: insetsHorizontalDefaultBottomDefault,
      child: MultiMeasurementInput(
        spec: _leaderRatingController.spec,
        controller: _leaderRatingController,
      ),
    );
  }

  Widget _buildTippetLength() {
    return Padding(
      padding: insetsHorizontalDefaultBottomDefault,
      child: MultiMeasurementInput(
        spec: _tippetLengthController.spec,
        controller: _tippetLengthController,
      ),
    );
  }

  Widget _buildTippetRating() {
    return Padding(
      padding: insetsHorizontalDefaultBottomDefault,
      child: MultiMeasurementInput(
        spec: _tippetRatingController.spec,
        controller: _tippetRatingController,
      ),
    );
  }

  Widget _buildHookMakeModel() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: TextInput.name(
        context,
        label: Strings.of(context).gearFieldHookMakeModel,
        controller: _hookMakeModelController,
      ),
    );
  }

  Widget _buildHookSize() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: MultiMeasurementInput(
        spec: _hookSizeController.spec,
        controller: _hookSizeController,
      ),
    );
  }

  bool _save(Map<Id, dynamic> customFieldValueMap) {
    // imageNames is set in _gearManager.addOrUpdate
    var gear = Gear(
      id: _oldGear?.id ?? randomId(),
      name: _nameController.value,
      customEntityValues: entityValuesFromMap(customFieldValueMap),
    );

    if (isNotEmpty(_rodMakeModelController.value)) {
      gear.rodMakeModel = _rodMakeModelController.value!;
    }

    if (isNotEmpty(_rodSerialNumberController.value)) {
      gear.rodSerialNumber = _rodSerialNumberController.value!;
    }

    if (_rodLengthController.isSet) {
      gear.rodLength = _rodLengthController.value;
    }

    if (_rodActionController.hasValue) {
      gear.rodAction = _rodActionController.value!;
    }

    if (_rodPowerController.hasValue) {
      gear.rodPower = _rodPowerController.value!;
    }

    if (isNotEmpty(_reelMakeModelController.value)) {
      gear.reelMakeModel = _reelMakeModelController.value!;
    }

    if (isNotEmpty(_reelSerialNumberController.value)) {
      gear.reelSerialNumber = _reelSerialNumberController.value!;
    }

    if (isNotEmpty(_reelSizeController.value)) {
      gear.reelSize = _reelSizeController.value!;
    }

    if (isNotEmpty(_lineMakeModelController.value)) {
      gear.lineMakeModel = _lineMakeModelController.value!;
    }

    if (_lineRatingController.isSet) {
      gear.lineRating = _lineRatingController.value;
    }

    if (isNotEmpty(_lineColorController.value)) {
      gear.lineColor = _lineColorController.value!;
    }

    if (_leaderLengthController.isSet) {
      gear.leaderLength = _leaderLengthController.value;
    }

    if (_leaderRatingController.isSet) {
      gear.leaderRating = _leaderRatingController.value;
    }

    if (_tippetLengthController.isSet) {
      gear.tippetLength = _tippetLengthController.value;
    }

    if (_tippetRatingController.isSet) {
      gear.tippetRating = _tippetRatingController.value;
    }

    if (isNotEmpty(_hookMakeModelController.value)) {
      gear.hookMakeModel = _hookMakeModelController.value!;
    }

    if (_hookSizeController.isSet) {
      gear.hookSize = _hookSizeController.value;
    }

    _gearManager.addOrUpdate(
      gear,
      imageFile: _imageController.value?.originalFile,
    );

    return true;
  }

  bool _isInputValid() => _nameController.isValid(context);

  bool _isAnyRodTextFieldShowing() =>
      _fields[_idRodMakeModel]!.isShowing ||
      _fields[_idRodSerialNumber]!.isShowing ||
      _fields[_idRodLength]!.isShowing;
}
