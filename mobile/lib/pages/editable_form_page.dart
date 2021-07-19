import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../custom_entity_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/form_page.dart';
import '../res/dimen.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/field.dart';
import '../widgets/input_type.dart';
import '../widgets/widget.dart';

class EditableFormPage extends StatefulWidget {
  final Widget? title;

  /// See [FormPage.header].
  final Widget? header;

  /// A unique ID to [Field] map of all valid fields for the form.
  final Map<Id, Field> fields;

  /// A list of all [CustomEntity] objects associated with this form. These will
  /// each have their own input widget, and their initial values are determined
  /// by [customEntityValues].
  final List<Id> customEntityIds;

  /// A list of [CustomEntityValue] objects associated with custom fields.
  final List<CustomEntityValue> customEntityValues;

  /// When true, users can add custom entities to the form. When false,
  /// [customEntityIds] and [customEntityValues] are ignored. Defaults to
  /// true.
  final bool allowCustomEntities;

  /// See [FormPage.onRefresh].
  final Future<void> Function()? onRefresh;

  /// See [FormPage.refreshIndicatorKey].
  final Key? refreshIndicatorKey;

  /// Called when an input field needs to be built. The ID of the input field
  /// is passed into the function.
  final Widget Function(Id)? onBuildField;

  /// See [FormPage.onAddFields].
  final void Function(Set<Id> ids)? onAddFields;

  /// Called when the "Save" button is pressed and form validation passes.
  /// A map of [CustomEntity] ID to value objects included in the form is passed
  /// into the callback.
  ///
  /// See [FormPage.onSave].
  final FutureOr<bool> Function(Map<Id, dynamic>)? onSave;

  /// See [FormPage.isInputValid].
  final bool isInputValid;

  /// See [FormPage.showSaveButton].
  final bool showSaveButton;

  /// See [FormPage.runSpacing].
  final double? runSpacing;

  final EdgeInsets padding;

  /// See [FormPage.popupMenuKey].
  final GlobalKey<PopupMenuButtonState>? popupMenuKey;

  /// See [FormPage.overflowOptions].
  final List<FormPageOverflowOption> overflowOptions;

  EditableFormPage({
    this.popupMenuKey,
    this.title,
    this.header,
    this.fields = const {},
    this.customEntityIds = const [],
    this.customEntityValues = const [],
    this.allowCustomEntities = true,
    this.onBuildField,
    this.onAddFields,
    this.onSave,
    this.padding = insetsHorizontalDefault,
    this.isInputValid = true,
    this.showSaveButton = true,
    this.runSpacing,
    this.onRefresh,
    this.refreshIndicatorKey,
    this.overflowOptions = const [],
  });

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

    if (widget.allowCustomEntities) {
      // Add fake InputData for custom fields separator.
      var fakeInput = Field.fake();
      _fields[fakeInput.id] = fakeInput;

      // Add custom fields.
      for (var id in widget.customEntityIds) {
        var customEntity = _customEntityManager.entity(id);
        if (customEntity != null) {
          _fields[id] = Field.fromCustomEntity(customEntity);
        }
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

        _fields[entity.id]!.controller.value =
            valueForCustomEntityType(entity.type, value);
      }
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
      header: widget.header,
      runSpacing: widget.runSpacing,
      padding: widget.padding,
      fieldBuilder: (context) =>
          <Id, Widget>{for (var id in _fields.keys) id: _inputWidget(id)},
      onSave: (_) {
        var customFieldValues = <Id, dynamic>{};

        if (widget.allowCustomEntities) {
          for (var id in _fields.keys) {
            var field = _fields[id]!;
            if (_customEntityManager.entity(id) != null &&
                field.showing &&
                !field.fake) {
              customFieldValues[id] = field.controller.value;
            }
          }
        }

        if (widget.onSave == null) {
          return false;
        } else {
          return widget.onSave!.call(customFieldValues);
        }
      },
      addFieldOptions: _fields.keys.where((id) => !_fields[id]!.fake).map((id) {
        var field = _fields[id]!;

        assert(field.name != null);
        var fieldName = field.name!(context);

        var description = field.description?.call(context);
        if (isEmpty(description) && !field.removable) {
          description = Strings.of(context).inputGenericRequired;
        }

        return FormPageFieldOption(
          id: id,
          name: fieldName,
          description: description,
          used: field.showing,
          removable: field.removable,
        );
      }).toList(),
      onAddFields: _addInputWidgets,
      isInputValid: widget.isInputValid,
      showSaveButton: widget.showSaveButton,
      allowCustomEntities: widget.allowCustomEntities,
      onRefresh: widget.onRefresh,
      refreshIndicatorKey: widget.refreshIndicatorKey,
      overflowOptions: widget.overflowOptions,
    );
  }

  Widget _inputWidget(Id id) {
    assert(_fields.containsKey(id));
    var field = _fields[id]!;

    // Add custom fields divider.
    if (field.fake) {
      var hasCustomFields = _fields.keys.firstWhereOrNull(
              (id) => _customEntityManager.entity(id) != null) !=
          null;

      return HeadingNoteDivider(
        hideNote: hasCustomFields,
        title: Strings.of(context).customFields,
        note: Strings.of(context).formPageManageFieldsNote,
        noteIcon: FormPage.moreMenuIcon,
        padding: insetsVerticalWidgetSmall,
      );
    }

    if (!field.showing) {
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
          controller: field.controller,
          onCheckboxChanged: (newValue) => field.controller.value = newValue,
        ),
      );
    }

    return widget.onBuildField?.call(id) ?? Empty();
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
