import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:mobile/widgets/pro_overlay.dart';

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

  /// A list of field IDs being tracked by the user. Used to hide/show fields
  /// accordingly. This value should include custom entity IDs.
  final Iterable<Id> trackedFieldIds;

  /// A list of [CustomEntityValue] objects associated with custom fields.
  final Iterable<CustomEntityValue> customEntityValues;

  /// When true, users can add custom entities to the form. When false,
  /// [customEntityValues] are ignored. Defaults to true.
  final bool allowCustomEntities;

  /// When true, adds [VerticalSpace] above the custom field header widget.
  /// This is used to show separation between custom fields and regular fields.
  /// This should only be set to false when the last field doesn't already
  /// include padding.
  ///
  /// Defaults to true.
  final bool showTopCustomFieldPadding;

  /// Called when a custom field changes.
  ///
  /// A map of [CustomEntity] ID to value objects included in the form is passed
  /// into the callback.
  final void Function(Map<Id, dynamic>)? onCustomFieldChanged;

  /// See [FormPage.onRefresh].
  final Future<void> Function()? onRefresh;

  /// See [FormPage.refreshIndicatorKey].
  final Key? refreshIndicatorKey;

  /// Called when an input field needs to be built. The ID of the input field
  /// is passed into the function.
  final Widget Function(Id)? onBuildField;

  /// See [FormPage.onAddFields].
  final void Function(Set<Id> ids)? onAddFields;

  /// Called when the "Save" button is pressed and form validation passes
  /// (indicated by [isInputValid]). A map of [CustomEntity] ID to value objects
  /// included in the form is passed into the callback.
  ///
  /// See [FormPage.onSave].
  final FutureOr<bool> Function(Map<Id, dynamic>)? onSave;

  /// See [FormPage.isInputValid].
  final bool isInputValid;

  /// See [FormPage.isEditable]. This is useful for conditionally making the
  /// form editable on subsequent builds. Defaults to true.
  final bool isEditable;

  /// See [FormPage.showSaveButton].
  final bool showSaveButton;

  /// See [FormPage.runSpacing].
  final double? runSpacing;

  final EdgeInsets padding;

  /// See [FormPage.popupMenuKey].
  final GlobalKey<PopupMenuButtonState>? popupMenuKey;

  /// See [FormPage.overflowOptions].
  final List<FormPageOverflowOption> overflowOptions;

  const EditableFormPage({
    this.popupMenuKey,
    this.title,
    this.header,
    this.fields = const {},
    this.trackedFieldIds = const [],
    this.customEntityValues = const [],
    this.allowCustomEntities = true,
    this.showTopCustomFieldPadding = true,
    this.onCustomFieldChanged,
    this.onBuildField,
    this.onAddFields,
    this.onSave,
    this.padding = insetsHorizontalDefault,
    this.isInputValid = true,
    this.isEditable = true,
    this.showSaveButton = true,
    this.runSpacing,
    this.onRefresh,
    this.refreshIndicatorKey,
    this.overflowOptions = const [],
  });

  @override
  EditableFormPageState createState() => EditableFormPageState();
}

class EditableFormPageState extends State<EditableFormPage> {
  /// All possible fields of the form. These fields may or may not be showing.
  final Map<Id, Field> _fields = {};

  CustomEntityManager get _customEntityManager =>
      CustomEntityManager.of(context);

  @override
  void initState() {
    super.initState();
    _fields.addAll(widget.fields);

    if (widget.allowCustomEntities) {
      // Add a fake Field for custom fields separator.
      var customField = Field.fake(builder: _buildCustomFieldsSection);
      _fields[customField.id] = customField;

      // Add custom fields.
      for (var id in widget.trackedFieldIds) {
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

    // Only include fields being tracked by the user. Honor the existing
    // isShowing value in case it was set by the parent widget.
    for (var field in _fields.values) {
      field.isShowing = field.isShowing &&
          (widget.trackedFieldIds.isEmpty ||
              widget.trackedFieldIds.contains(field.id));
    }
  }

  @override
  void dispose() {
    for (var value in _fields.values) {
      value.controller.dispose();
    }
    super.dispose();
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
      onSave: () {
        if (widget.onSave == null) {
          return false;
        } else {
          return widget.onSave!.call(_customFieldValues());
        }
      },
      editableFields: List.of(_fields.values)
        ..removeWhere((field) => _fields[field.id]!.isFake),
      onAddFields: _addInputWidgets,
      isInputValid: widget.isInputValid,
      isEditable: widget.isEditable,
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

    // Add custom field section.
    if (field.isFake) {
      return field.fakeBuilder!(context);
    }

    // If the field isn't showing, or is a custom field, skip it. Custom fields
    // are created separately.
    if (!field.isShowing || _customEntityManager.entityExists(id)) {
      return const Empty();
    }

    return widget.onBuildField?.call(id) ?? const Empty();
  }

  Widget _buildCustomFieldsSection(BuildContext context) {
    Widget header;
    if (widget.isEditable) {
      var hasVisibleField = _fields.values.containsWhere((field) =>
          _customEntityManager.entityExists(field.id) && field.isShowing);

      header = HeadingNoteDivider(
        hideNote: hasVisibleField,
        title: Strings.of(context).entityNameCustomFields,
        note: Strings.of(context).formPageManageFieldsNote,
        noteIcon: FormPage.moreMenuIcon,
      );
    } else if (_hasCustomField()) {
      header = HeadingDivider(Strings.of(context).entityNameCustomFields);
    } else {
      // The form is not editable and there are no custom fields; there's
      // nothing to show.
      return const Empty();
    }

    header = Padding(
      padding: EdgeInsets.only(
        top: widget.showTopCustomFieldPadding ? paddingDefault : 0.0,
        bottom: paddingSmall,
      ),
      child: header,
    );

    var children = <Widget>[];

    for (var field in _fields.values) {
      var customField = _customEntityManager.entity(field.id);
      if (customField == null || !field.isShowing) {
        continue;
      }

      children.add(Padding(
        // Boolean fields use a CheckboxInput, which uses ListItem, which always
        // has padding included.
        padding: customField.type == CustomEntity_Type.boolean
            ? insetsZero
            : insetsHorizontalDefault,
        child: inputTypeWidget(
          context,
          type: customField.type,
          label: customField.name,
          controller: field.controller,
          onCheckboxChanged: (newValue) {
            field.controller.value = newValue;
            _onCustomFieldChanged();
          },
          onTextFieldChanged: (newValue) => _onCustomFieldChanged(),
        ),
      ));
    }

    Widget blur = const Empty();
    if (children.isNotEmpty) {
      blur = ProOverlay(
        description: Strings.of(context).formPageManageFieldsProDescription,
        proWidget: Column(
          children: children,
        ),
      );
    }

    return Column(children: [header, blur]);
  }

  void _onCustomFieldChanged() {
    widget.onCustomFieldChanged?.call(_customFieldValues());
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
            isShowing: true,
          ),
        );
      }
    }

    widget.onAddFields?.call(ids);

    setState(() {
      for (var field in _fields.values) {
        field.isShowing = ids.contains(field.id);
      }
    });
  }

  /// Returns true if the form has a custom field showing.
  bool _hasCustomField() => _fields.values
      .containsWhere((e) => _customEntityManager.entityExists(e.id));

  Map<Id, dynamic> _customFieldValues() {
    var customFieldValues = <Id, dynamic>{};

    if (widget.allowCustomEntities) {
      for (var id in _fields.keys) {
        var field = _fields[id]!;
        if (_customEntityManager.entity(id) != null &&
            field.isShowing &&
            !field.isFake) {
          customFieldValues[id] = field.controller.value;
        }
      }
    }

    return customFieldValues;
  }
}
