import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../custom_entity_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/form_page.dart';
import '../res/dimen.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/input_data.dart';
import '../widgets/input_type.dart';
import '../widgets/widget.dart';

class EditableFormPage extends StatefulWidget {
  final Widget title;

  /// A unique ID to [Field] map of all valid fields for the form.
  final Map<Id, Field> fields;

  /// A list of all [CustomEntity] objects associated with this form. These will
  /// each have their own input widget, and their initial values are determined
  /// by [customEntityValues].
  final List<Id> customEntityIds;

  /// A list of [CustomEntityValue] objects associated with custom fields.
  final List<CustomEntityValue> customEntityValues;

  /// Called when an input field needs to be built. The ID of the input field
  /// is passed into the function.
  final Widget Function(Id) onBuildField;

  /// See [FormPage.onAddFields].
  final void Function(Set<Id> ids) onAddFields;

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

  /// See [FormPage.popupMenuKey].
  final GlobalKey<PopupMenuButtonState> popupMenuKey;

  EditableFormPage({
    this.popupMenuKey,
    this.title,
    this.fields = const {},
    this.customEntityIds = const [],
    this.customEntityValues = const [],
    this.onBuildField,
    this.onAddFields,
    this.onSave,
    this.padding = insetsHorizontalDefault,
    this.isInputValid = true,
    this.runSpacing,
  })  : assert(fields != null),
        assert(customEntityIds != null),
        assert(customEntityValues != null),
        assert(isInputValid != null),
        assert(padding != null);

  @override
  _EditableFormPageState createState() => _EditableFormPageState();
}

class _EditableFormPageState extends State<EditableFormPage> {
  /// Options that are shown in the form, but not necessarily filled out.
  final Map<Id, Field> _fields = {};

  CustomEntityManager get _customEntityManager =>
      CustomEntityManager.of(context);

  Map<Id, Field> get _allInputFields => widget.fields;

  @override
  void initState() {
    super.initState();
    _fields.addAll(_allInputFields);

    // Add fake InputData for custom fields separator.
    var fakeInput = Field.fake();
    _fields[fakeInput.id] = fakeInput;

    // Add custom fields.
    for (var id in widget.customEntityIds) {
      _fields[id] = Field.fromCustomEntity(_customEntityManager.entity(id));
    }

    // Set custom fields' initial values.
    for (var value in widget.customEntityValues) {
      var entity = _customEntityManager.entity(value.customEntityId);
      if (entity == null) {
        continue;
      }

      // If a CustomEntityValue doesn't exist in widget.customEntityIds, it
      // means the field was removed from the form at some point by the user.
      // In these cases, add the related custom field so the user can edit all
      // values of the form.
      if (!_fields.containsKey(entity.id)) {
        _fields[entity.id] = Field.fromCustomEntity(entity);
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
      popupMenuKey: widget.popupMenuKey,
      title: widget.title,
      runSpacing: widget.runSpacing,
      padding: widget.padding,
      fieldBuilder: (context) {
        return Map.fromIterable(
          _fields.keys,
          key: (item) => item,
          value: (item) => _inputWidget(item),
        );
      },
      onSave: (_) {
        var customFieldValues = <Id, dynamic>{};
        for (var id in _fields.keys) {
          if (_customEntityManager.entity(id) != null &&
              _fields[id].showing &&
              !_fields[id].fake) {
            customFieldValues[id] = _fields[id].controller.value;
          }
        }

        return widget.onSave(customFieldValues);
      },
      addFieldOptions: _fields.keys
          .where((id) => !_fields[id].fake)
          .map(
            (id) {
              var description = _fields[id].description?.call(context);
              if (isEmpty(description) && !_fields[id].removable) {
                description = Strings.of(context).inputGenericRequired;
              }

              return FormPageFieldOption(
                id: id,
                name: _fields[id].name(context),
                description: description,
                used: _fields[id].showing,
                removable: _fields[id].removable,
              );
            },
          )
          .toList(),
      onAddFields: _addInputWidgets,
      isInputValid: widget.isInputValid,
    );
  }

  Widget _inputWidget(Id id) {
    // For now, always show "fake" fields.
    if (_fields[id].fake) {
      var hasCustomFields = _fields.keys.firstWhere(
              (id) => _customEntityManager.entity(id) != null,
              orElse: () => null) !=
          null;

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

    var customField = _customEntityManager.entity(id);
    if (customField != null) {
      return Padding(
        padding: insetsHorizontalDefault,
        child: inputTypeWidget(
          context,
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
    for (var id in ids) {
      var customField = _customEntityManager.entity(id);
      if (customField != null) {
        _fields.putIfAbsent(
          id,
          () => Field(
            id: id,
            controller: inputTypeController(customField.type),
            name: (_) => customField.name,
            showing: true,
          ),
        );
      }
    }

    widget.onAddFields?.call(ids);

    setState(() {
      for (var field in _fields.values) {
        field.showing = ids.contains(field.id);
      }
    });
  }
}
