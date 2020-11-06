import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/pages/save_custom_entity_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/core.dart';

/// A function responsible for building all input widgets.
///
/// @return The returned map key [Id] corresponds to the identifier in the
/// underlying model object, such as "angler" or "bait_id". The returned
/// map value [Widget] is the widget that is displayed.
///
/// Note that the returned map key is used in keeping track of [InputFields]
/// that are selected for deletion.
typedef FieldBuilder = Map<Id, Widget> Function(BuildContext);

enum _OverflowOption {
  manageFields,
}

/// A small data structure that stores information on fields that can be added
/// to the form by a user.
class FormPageFieldOption {
  /// The unique ID of the field. Used for identification purposes.
  final Id id;

  /// The name of the field, as seen and selected by the user.
  final String userFacingName;

  /// Whether or not the option is already part of the form.
  final bool used;

  /// Whether or not the field can be removed from the form. Defaults to `true`.
  final bool removable;

  FormPageFieldOption({
    this.id,
    this.userFacingName,
    this.used = false,
    this.removable = true,
  });

  @override
  bool operator ==(other) => other is FormPageFieldOption
      && id == other.id
      && userFacingName == other.userFacingName
      && used == other.used
      && removable == other.removable;

  @override
  int get hashCode => hash4(id, userFacingName, used, removable);
}

/// A customizable user input page that supports user-manageable input fields.
/// If desired, users can add and remove input fields.
///
/// Widgets using the [FormPage] widget are responsible for tracking field input
/// values and input validation.
class FormPage extends StatefulWidget {
  static const IconData moreMenuIcon = Icons.more_vert;

  /// See [AppBar.title].
  final Widget title;

  final FieldBuilder fieldBuilder;

  /// A [List] of fields that can be added to the form, if the user desires.
  final List<FormPageFieldOption> addFieldOptions;

  /// Called when a field is added to the form.
  final void Function(Set<Id> ids) onAddFields;

  /// Used when state is set. Common form components need to be updated
  /// based on whether or not the form has valid input. For example, the "Save"
  /// button is disabled when the input is not valid.
  final bool isInputValid;

  /// Whether this form's components can be added or removed.
  final bool editable;

  /// Called when the save button is pressed. Returning true will dismiss
  /// the form page; false will leave it open.
  ///
  /// A unique [BuildContext] is passed into the function if the current
  /// [Scaffold] needs to be accessed. For example, to show a [SnackBar].
  final FutureOr<bool> Function(BuildContext) onSave;

  /// Space between form input widgets.
  final double runSpacing;

  /// The text for the "save" button. Defaults to "Save".
  final String saveButtonText;

  final EdgeInsets padding;

  FormPage({
    Key key,
    this.title,
    @required this.fieldBuilder,
    this.onSave,
    this.addFieldOptions = const [],
    this.onAddFields,
    this.editable = true,
    this.padding = insetsHorizontalDefault,
    this.runSpacing,
    this.saveButtonText,
    @required this.isInputValid,
  }) : assert(fieldBuilder != null),
       assert(isInputValid != null),
       super(key: key);

  FormPage.immutable({
    Key key,
    Widget title,
    FieldBuilder fieldBuilder,
    FutureOr<bool> Function(BuildContext) onSave,
    EdgeInsets padding = insetsHorizontalDefault,
    double runSpacing,
    @required bool isInputValid,
    String saveButtonText,
  }) : this(
    key: key,
    title: title,
    fieldBuilder: fieldBuilder,
    onSave: onSave,
    addFieldOptions: null,
    onAddFields: null,
    editable: false,
    padding: padding,
    runSpacing: runSpacing,
    isInputValid: isInputValid,
    saveButtonText: saveButtonText,
  );

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _key = GlobalKey<FormState>();

  bool get canAddFields =>
      widget.addFieldOptions != null && widget.addFieldOptions.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
        actions: [
          Builder(builder: (context) => ActionButton(
            text: widget.saveButtonText ?? Strings.of(context).save,
            onPressed: widget.isInputValid
                ? () => _onPressedSave(context) : null,
            condensed: widget.editable,
          )),
          widget.editable ? PopupMenuButton<_OverflowOption>(
            icon: Icon(FormPage.moreMenuIcon),
            itemBuilder: (context) => [
              PopupMenuItem<_OverflowOption>(
                value: _OverflowOption.manageFields,
                child: Text(Strings.of(context).formPageManageFieldText),
              ),
            ],
            onSelected: (option) {
              if (option == _OverflowOption.manageFields) {
                present(context, _addFieldSelectionPage());
              }
            },
          ) : Empty(),
        ],
      ),
      body: Padding(
        padding: widget.padding,
        child: Form(
          key: _key,
          child: SingleChildScrollView(
            padding: insetsBottomDefault,
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Wrap(
          runSpacing: widget.runSpacing ?? paddingSmall,
          children: widget.fieldBuilder(context).values.toList(),
        ),
      ],
    );
  }

  Widget _addFieldSelectionPage() => _SelectionPage(
    options: widget.addFieldOptions,
    onSelectItems: (selectedIds) => widget.onAddFields(selectedIds),
  );

  void _onPressedSave(BuildContext saveContext) async {
    if (!_key.currentState.validate()) {
      return;
    }

    _key.currentState.save();

    if (widget.onSave == null || await widget.onSave(saveContext)) {
      Navigator.pop(context);
    }
  }
}

class _SelectionPage extends StatefulWidget {
  final List<FormPageFieldOption> options;
  final Function(Set<Id>) onSelectItems;

  _SelectionPage({
    @required this.options,
    this.onSelectItems,
  }) : assert(options != null);

  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<_SelectionPage> {
  CustomEntityManager get customEntityManager =>
      CustomEntityManager.of(context);

  IconData get _addItemIconData => Icons.add;

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder(
      managers: [customEntityManager],
      builder: (context) {
        List<PickerPageItem> items = pickerItems;
        Set<FormPageFieldOption> used = items
            .where((item) => item.value is FormPageFieldOption
                && item.value.used)
            .map((item) => item.value as FormPageFieldOption)
            .toSet();

        return PickerPage(
          title: Text(Strings.of(context).formPageSelectFieldsTitle),
          initialValues: used,
          itemBuilder: () => items,
          onFinishedPicking: (context, items) {
            widget.onSelectItems(items.map((item) =>
                (item as FormPageFieldOption).id).toSet());
            Navigator.pop(context);
          },
          action: IconButton(
            icon: Icon(_addItemIconData),
            onPressed: () => present(context, SaveCustomEntityPage()),
          ),
        );
      },
    );
  }

  List<PickerPageItem> get pickerItems {
    List<PickerPageItem> result = [];

    // Split custom fields and normal fields that are already included in the
    // form.
    List<FormPageFieldOption> customFields = [];
    List<FormPageFieldOption> normalFields = [];
    for (var option in widget.options) {
      if (customEntityManager.entity(option.id) == null) {
        normalFields.add(option);
      } else {
        customFields.add(option);
      }
    }

    // Add included field options.
    result.addAll(normalFields.map((o) => PickerPageItem<FormPageFieldOption>(
      title: o.userFacingName,
      value: o,
      enabled: o.removable,
    )));

    // Add custom field separator/title.
    result..add(PickerPageItem.heading(Strings.of(context).customFields));

    // Add customs fields that aren't already part of the form.
    for (var entity in customEntityManager.list()) {
      if (customFields.firstWhere((field) => field.id == entity.id,
          orElse: () => null) == null)
      {
        customFields.add(FormPageFieldOption(
          id: entity.id,
          userFacingName: entity.name,
        ));
      }
    }

    // Ensure alphabetical order.
    customFields.sort((a, b) => a.userFacingName.compareTo(b.userFacingName));

    // If there are no custom fields, show a note on how to add them.
    if (customFields.isEmpty) {
      result.add(PickerPageItem.note(
        Strings.of(context).formPageItemAddCustomFieldNote,
        noteIcon: _addItemIconData,
      ));
    }

    result.addAll(customFields.map((field) =>
        PickerPageItem<FormPageFieldOption>(
          title: field.userFacingName,
          value: field,
        )));

    return result;
  }
}