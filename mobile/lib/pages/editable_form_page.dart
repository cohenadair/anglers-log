import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/form_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/input_data.dart';
import 'package:mobile/widgets/input_type.dart';
import 'package:mobile/widgets/widget.dart';

class EditableFormPage extends StatefulWidget {
  final Widget title;

  /// A unique ID to [InputData] map of all valid fields for the form.
  final Map<Id, InputData> fields;

  /// A list of all [CustomEntity] objects associated with this form. These will
  /// each have their own input widget, and their initial values are determined
  /// by [customEntityValues].
  final List<Id> customEntityIds;

  /// A list of [CustomEntityValue] objects associated with custom fields.
  final List<CustomEntityValue> customEntityValues;

  /// Called when an input field needs to be built. The ID of the input field
  /// is passed into the function.
  final Function(Id) onBuildField;

  /// Called when the "Save" button is pressed and form validation passes.
  /// A map of [CustomEntity] ID to value objects included in the form is passed
  /// into the callback.
  ///
  /// See [FormPage.onSave].
  final FutureOr<bool> Function(Map<Id, dynamic>) onSave;

  /// See [FormPage.isInputValid].
  final bool isInputValid;

  /// See [FormPage.runSpacing].
  final double runSpacing;

  final EdgeInsets padding;

  EditableFormPage({
    this.title,
    this.fields = const {},
    this.customEntityIds = const [],
    this.customEntityValues = const [],
    this.onBuildField,
    this.onSave,
    this.padding = insetsHorizontalDefault,
    this.isInputValid = true,
    this.runSpacing,
  }) : assert(
    customEntityValues.length <= customEntityIds.length,
    "Cannot have more custom entity values than available input widgets",
  );

  @override
  _EditableFormPageState createState() => _EditableFormPageState();
}

class _EditableFormPageState extends State<EditableFormPage> {
  /// Options that are shown in the form, but not necessarily filled out.
  Map<Id, InputData> _fields = {};

  CustomEntityManager get _customEntityManager =>
      CustomEntityManager.of(context);

  Map<Id, InputData> get _allInputFields => widget.fields;

  @override
  void initState() {
    super.initState();
    _fields.addAll(_allInputFields);

    // Add fake InputData for custom fields separator.
    var fakeInput = InputData.fake();
    _fields[fakeInput.id] = fakeInput;

    // Add custom fields.
    for (Id id in widget.customEntityIds) {
      _fields[id] = InputData.fromCustomEntity(_customEntityManager.entity(id));
    }

    // Set custom fields' initial values.
    for (CustomEntityValue value in widget.customEntityValues) {
      CustomEntity entity =
          _customEntityManager.entity(value.customEntityId);
      if (entity == null) {
        continue;
      }
      _fields[entity.id].controller.value =
          valueForCustomEntityType(entity.type, value);
    }
  }

  @override
  void dispose() {
    super.dispose();

    for (var value in _fields.values) {
      value.controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: widget.title,
      runSpacing: widget.runSpacing,
      padding: widget.padding,
      fieldBuilder: (BuildContext context) {
        return Map.fromIterable(_fields.keys,
          key: (item) => item,
          value: (item) => _inputWidget(item),
        );
      },
      onSave: (_) {
        Map<Id, dynamic> customFieldValues = {};
        for (Id id in _fields.keys) {
          if (_customEntityManager.entity(id) != null
              && _fields[id].showing
              && !_fields[id].fake)
          {
            customFieldValues[id] = _fields[id].controller.value;
          }
        }

        return widget.onSave(customFieldValues);
      },
      addFieldOptions: _fields.keys
          .where((id) => !_fields[id].fake)
          .map((Id id) => FormPageFieldOption(
            id: id,
            userFacingName: _fields[id].label(context),
            used: _fields[id].showing,
            removable: _fields[id].removable,
          )).toList(),
      onAddFields: _addInputWidgets,
      isInputValid: widget.isInputValid,
    );
  }

  Widget _inputWidget(Id id) {
    // For now, always show "fake" fields.
    if (_fields[id].fake) {
      bool hasCustomFields = _fields.keys.firstWhere(
          (id) => _customEntityManager.entity(id) != null,
          orElse: () => null) != null;

      return HeadingNoteDivider(
        hideNote: hasCustomFields,
        title: Strings.of(context).customFields,
        note: Strings.of(context).formPageManageFieldsNote,
        noteIcon: FormPage.moreMenuIcon,
        padding: insetsVerticalWidgetSmall,
      );
    }

    if (!_fields[id].showing) {
      return Empty();
    }

    CustomEntity customField = _customEntityManager.entity(id);
    if (customField != null) {
      return Padding(
        padding: insetsHorizontalDefault,
        child: inputTypeWidget(context,
          type: customField.type,
          label: customField.name,
          controller: _fields[id].controller,
          onCheckboxChanged: (newValue) =>
              _fields[id].controller.value = newValue,
        ),
      );
    }

    return widget.onBuildField?.call(id);
  }

  void _addInputWidgets(Set<Id> ids) {
    // Handle the case of a new custom field being added.
    for (Id id in ids) {
      CustomEntity customField = _customEntityManager.entity(id);
      if (customField != null) {
        _fields.putIfAbsent(id, () => InputData(
          id: id,
          controller: inputTypeController(customField.type),
          label: (_) => customField.name,
          showing: true,
        ));
      }
    }

    setState(() {
      for (var field in _fields.values) {
        field.showing = ids.contains(field.id);
      }
    });
  }
}