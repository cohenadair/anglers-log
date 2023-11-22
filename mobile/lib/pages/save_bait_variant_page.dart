import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../user_preference_manager.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/field.dart';
import '../widgets/input_controller.dart';
import '../widgets/multi_measurement_input.dart';
import '../widgets/text_input.dart';
import '../widgets/widget.dart';
import 'editable_form_page.dart';

class SaveBaitVariantPage extends StatefulWidget {
  final BaitVariant? oldBaitVariant;
  final void Function(BaitVariant)? onSave;

  const SaveBaitVariantPage({
    this.onSave,
  }) : oldBaitVariant = null;

  const SaveBaitVariantPage.edit(
    this.oldBaitVariant, {
    this.onSave,
  });

  @override
  SaveBaitVariantPageState createState() => SaveBaitVariantPageState();
}

class SaveBaitVariantPageState extends State<SaveBaitVariantPage> {
  // Unique IDs for each field. These are stored in the database and should not
  // be changed.
  static final _idColor = Id()..uuid = "8b803b47-f3e1-4233-bb4b-f25e3ea48694";
  static final _idModelNumber = Id()
    ..uuid = "749c62ee-2d91-47cc-8b59-d5fce1d4048a";
  static final _idSize = Id()..uuid = "69feaeb1-4cb3-4858-a652-22d7a9a6cb97";
  static final _idMinDiveDepth = Id()
    ..uuid = "69fbdc83-a6b5-4e54-8e76-8fbd024618b1";
  static final _idMaxDiveDepth = Id()
    ..uuid = "45e31486-af4b-48e4-8e3e-741a1df903ac";
  static final _idDescription = Id()
    ..uuid = "3115c29d-b919-41e5-b19f-ec877e134dbe";

  final _log = const Log("SaveBaitVariantPage");

  final Map<Id, Field> _fields = {};

  List<CustomEntityValue> _customEntityValues = [];

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  BaitVariant? get _oldBaitVariant => widget.oldBaitVariant;

  bool get _isEditing => _oldBaitVariant != null;

  TextInputController get _colorController =>
      _fields[_idColor]!.controller as TextInputController;

  TextInputController get _modelNumberController =>
      _fields[_idModelNumber]!.controller as TextInputController;

  TextInputController get _sizeController =>
      _fields[_idSize]!.controller as TextInputController;

  MultiMeasurementInputController get _minDiveDepthController =>
      _fields[_idMinDiveDepth]!.controller as MultiMeasurementInputController;

  MultiMeasurementInputController get _maxDiveDepthController =>
      _fields[_idMaxDiveDepth]!.controller as MultiMeasurementInputController;

  TextInputController get _descriptionController =>
      _fields[_idDescription]!.controller as TextInputController;

  @override
  void initState() {
    super.initState();

    _fields[_idColor] = Field(
      id: _idColor,
      name: (context) => Strings.of(context).inputColorLabel,
      controller: TextInputController(),
    );

    _fields[_idModelNumber] = Field(
      id: _idModelNumber,
      name: (context) => Strings.of(context).saveBaitVariantPageModelNumber,
      controller: TextInputController(),
    );

    _fields[_idSize] = Field(
      id: _idSize,
      name: (context) => Strings.of(context).saveBaitVariantPageSize,
      controller: TextInputController(),
    );

    _fields[_idMinDiveDepth] = Field(
      id: _idMinDiveDepth,
      name: (context) => Strings.of(context).saveBaitVariantPageMinDiveDepth,
      controller:
          MultiMeasurementInputSpec.waterDepth(context).newInputController(),
    );

    _fields[_idMaxDiveDepth] = Field(
      id: _idMaxDiveDepth,
      name: (context) => Strings.of(context).saveBaitVariantPageMaxDiveDepth,
      controller:
          MultiMeasurementInputSpec.waterDepth(context).newInputController(),
    );

    _fields[_idDescription] = Field(
      id: _idDescription,
      name: (context) => Strings.of(context).inputDescriptionLabel,
      controller: TextInputController(),
    );

    if (_isEditing) {
      _colorController.value =
          _oldBaitVariant!.hasColor() ? _oldBaitVariant!.color : null;
      _modelNumberController.value = _oldBaitVariant!.hasModelNumber()
          ? _oldBaitVariant!.modelNumber
          : null;
      _sizeController.value =
          _oldBaitVariant!.hasSize() ? _oldBaitVariant!.size : null;
      _minDiveDepthController.value = _oldBaitVariant!.hasMinDiveDepth()
          ? _oldBaitVariant!.minDiveDepth
          : null;
      _maxDiveDepthController.value = _oldBaitVariant!.hasMaxDiveDepth()
          ? _oldBaitVariant!.maxDiveDepth
          : null;
      _descriptionController.value = _oldBaitVariant!.hasDescription()
          ? _oldBaitVariant!.description
          : null;
      _customEntityValues = _oldBaitVariant!.customEntityValues;
    }
  }

  @override
  Widget build(BuildContext context) {
    return EditableFormPage(
      title: _isEditing
          ? Text(Strings.of(context).saveBaitVariantPageTitle)
          : Text(Strings.of(context).saveBaitVariantPageEditTitle),
      padding: insetsTopSmall,
      fields: _fields,
      trackedFieldIds: _userPreferenceManager.baitVariantFieldIds,
      customEntityValues: _customEntityValues,
      onCustomFieldChanged: (map) {
        _customEntityValues = entityValuesFromMap(map);
        _onFieldUpdated();
      },
      onBuildField: _buildField,
      onSave: _save,
      onAddFields: (ids) =>
          _userPreferenceManager.setBaitVariantFieldIds(ids.toList()),
      runSpacing: 0,
      isInputValid: _variantFromControllers() != null,
    );
  }

  Widget _buildField(Id id) {
    if (id == _idColor) {
      return _buildColor();
    } else if (id == _idModelNumber) {
      return _buildModelNumber();
    } else if (id == _idSize) {
      return _buildSize();
    } else if (id == _idMinDiveDepth) {
      return _buildMinDiveDepth();
    } else if (id == _idMaxDiveDepth) {
      return _buildMaxDiveDepth();
    } else if (id == _idDescription) {
      return _buildDescription();
    } else {
      _log.e(StackTrace.current, "Unknown input key: $id");
      return const Empty();
    }
  }

  Widget _buildColor() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: TextInput.name(
        context,
        label: Strings.of(context).inputColorLabel,
        controller: _colorController,
        onChanged: (_) => _onFieldUpdated(),
      ),
    );
  }

  Widget _buildModelNumber() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: TextInput.name(
        context,
        label: Strings.of(context).saveBaitVariantPageModelNumber,
        controller: _modelNumberController,
        onChanged: (_) => _onFieldUpdated(),
      ),
    );
  }

  Widget _buildSize() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: TextInput.name(
        context,
        label: Strings.of(context).saveBaitVariantPageSize,
        controller: _sizeController,
        onChanged: (_) => _onFieldUpdated(),
      ),
    );
  }

  Widget _buildMinDiveDepth() {
    return Padding(
      padding: const EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        // Need a little extra padding here to make up for the lack of max
        // length label.
        bottom: paddingLarge,
      ),
      child: MultiMeasurementInput(
        spec: MultiMeasurementInputSpec.waterDepth(
          context,
          title: Strings.of(context).saveBaitVariantPageMinDiveDepth,
        ),
        controller: _minDiveDepthController,
        onChanged: _onFieldUpdated,
      ),
    );
  }

  Widget _buildMaxDiveDepth() {
    return Padding(
      padding: const EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        // Need a little extra padding here to make up for the lack of max
        // length label.
        bottom: paddingLarge,
      ),
      child: MultiMeasurementInput(
        spec: MultiMeasurementInputSpec.waterDepth(
          context,
          title: Strings.of(context).saveBaitVariantPageMaxDiveDepth,
        ),
        controller: _maxDiveDepthController,
        onChanged: _onFieldUpdated,
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: TextInput.description(
        context,
        title: Strings.of(context).saveBaitVariantPageDescription,
        controller: _descriptionController,
        onChanged: (_) => _onFieldUpdated(),
      ),
    );
  }

  BaitVariant? _variantFromControllers() {
    // Note that baseId is set when the base Bait object is saved.
    var newVariant = BaitVariant()
      ..id = _oldBaitVariant?.id ?? randomId()
      ..customEntityValues.addAll(_customEntityValues);

    if (isNotEmpty(_colorController.value)) {
      newVariant.color = _colorController.value!;
    }

    if (isNotEmpty(_modelNumberController.value)) {
      newVariant.modelNumber = _modelNumberController.value!;
    }

    if (isNotEmpty(_sizeController.value)) {
      newVariant.size = _sizeController.value!;
    }

    if (_minDiveDepthController.isSet) {
      newVariant.minDiveDepth = _minDiveDepthController.value;
    }

    if (_maxDiveDepthController.isSet) {
      newVariant.maxDiveDepth = _maxDiveDepthController.value;
    }

    if (isNotEmpty(_descriptionController.value)) {
      newVariant.description = _descriptionController.value!;
    }

    if (newVariant.customEntityValues.isNotEmpty ||
        newVariant.hasColor() ||
        newVariant.hasModelNumber() ||
        newVariant.hasSize() ||
        newVariant.hasMinDiveDepth() ||
        newVariant.hasMaxDiveDepth() ||
        newVariant.hasDescription()) {
      return newVariant;
    } else {
      return null;
    }
  }

  FutureOr<bool> _save(Map<Id, dynamic> customFieldValueMap) {
    var newVariant = _variantFromControllers();
    if (newVariant != null) {
      widget.onSave?.call(newVariant);
    }

    return true;
  }

  void _onFieldUpdated() {
    setState(() {});
  }
}
