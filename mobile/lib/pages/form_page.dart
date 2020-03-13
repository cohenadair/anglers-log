import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/custom_entity.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/input.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/core.dart';

import 'add_custom_field_page.dart';

/// A function responsible for building all input widgets.
///
/// @param BuildContext
/// @param bool `true` if the form is in "removing fields mode"
///
/// @return The returned map key [String] represents the identifier in the
/// underlying model object, such as "angler", "bait_id", etc. The returned
/// map value [Widget] is the widget that is displayed.
///
/// Note that the returned map key is used in keeping track of [InputFields]
/// that are selected for deletion.
typedef FieldBuilder = Map<String, Widget> Function(BuildContext, bool);

enum _OverflowOption {
  removeFields,
}

/// A small data structure that stores information on fields that can be added
/// to the form by a user.
class FormPageFieldOption {
  /// The unique ID of the field. Used for identification purposes.
  final String id;

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
  /// The title of the page.
  final String title;

  final FieldBuilder fieldBuilder;

  /// Called when a user confirms the deletion of fields. The implementation of
  /// this method is responsible for deleting the correct fields from the
  /// underlying data model.
  ///
  /// @param A [List] of field IDs to be deleted.
  final Function(List<String>) onConfirmRemoveFields;

  /// A [List] of fields that can be added to the form, if the user desires.
  final List<FormPageFieldOption> addFieldOptions;

  /// Called when a field is added to the form.
  final void Function(Set<String> ids) onAddFields;

  /// Used when state is set. Common form components need to be updated
  /// based on whether or not the form has valid input. For example, the "Save"
  /// button is disabled when the input is not valid.
  final bool isInputValid;

  /// Whether this form's components can be added or removed.
  final bool editable;

  final VoidCallback onSave;
  final EdgeInsets padding;

  FormPage({
    Key key,
    this.title,
    @required this.fieldBuilder,
    this.onSave,
    this.onConfirmRemoveFields,
    this.addFieldOptions,
    this.onAddFields,
    this.editable = true,
    this.padding = insetsHorizontalDefault,
    @required this.isInputValid,
  }) : assert(fieldBuilder != null),
       assert(isInputValid != null),
       super(key: key);

  FormPage.immutable({
    Key key,
    String title,
    FieldBuilder fieldBuilder,
    VoidCallback onSave,
    EdgeInsets padding = insetsHorizontalDefault,
    @required bool isInputValid,
  }) : this(
    key: key,
    title: title,
    fieldBuilder: fieldBuilder,
    onSave: onSave,
    onConfirmRemoveFields: null,
    addFieldOptions: null,
    onAddFields: null,
    editable: false,
    padding: padding,
    isInputValid: isInputValid,
  );

  @override
  _FormPageState createState() => _FormPageState();

  FormPageFieldOption fieldOption(String id) {
    if (addFieldOptions == null) {
      return null;
    } else {
      return addFieldOptions.firstWhere((option) => option.id == id,
          orElse: () => null);
    }
  }
}

class _FormPageState extends State<FormPage> {
  final _key = GlobalKey<FormState>();

  bool _isRemovingFields = false;
  List<String> _fieldsToRemove = [];

  bool get canAddFields =>
      widget.addFieldOptions != null && widget.addFieldOptions.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    Widget actionButton;
    if (_isRemovingFields) {
      actionButton = ActionButton.cancel(
        onPressed: _stopRemovingFields,
        condensed: true,
      );
    } else {
      actionButton = ActionButton.save(
        onPressed: widget.isInputValid ? _onPressedSave : null,
        condensed: widget.editable,
      );
    }

    // If we're editing and the form's padding has been set to zero, we need
    // to add some padding for the checkboxes.
    var padding = widget.padding;
    if (_isRemovingFields && padding == insetsZero) {
      padding = insetsRightDefault;
    }

    return Page(
      appBarStyle: PageAppBarStyle(
        title: widget.title,
        actions: [
          actionButton,
          widget.editable ? PopupMenuButton<_OverflowOption>(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem<_OverflowOption>(
                value: _OverflowOption.removeFields,
                child: Text(Strings.of(context).formPageRemoveFieldsText),
                enabled: !_isRemovingFields,
              ),
            ],
            onSelected: (option) {
              if (option == _OverflowOption.removeFields) {
                setState(() {
                  _isRemovingFields = true;
                });
              }
            },
          ) : Empty(),
        ],
      ),
      padding: padding,
      child: Form(
        key: _key,
        child: SingleChildScrollView(
          padding: insetsBottomDefault,
          child: SafeArea(
            left: true,
            right: true,
            top: true,
            bottom: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Wrap(
                  runSpacing: paddingSmall,
                  children: widget.fieldBuilder(context, _isRemovingFields)
                      .map((key, inputField) =>
                          MapEntry<String, Widget>(
                            key,
                            _inputField(key, inputField),
                          )).values.toList(),
                ),
                canAddFields ? Padding(
                  padding: EdgeInsets.only(
                    top: paddingSmall,
                    // Include right edge padding on the button, even if the
                    // parent widget is handling padding.
                    right: insetsZero == padding ? paddingDefault : 0,
                  ),
                  child: Button(
                    text: Strings.of(context).formPageManageFieldText,
                    onPressed: _isRemovingFields ? null : () {
                      present(context, _addFieldSelectionPage());
                    },
                  ),
                ) : Empty(),
                _fieldsToRemove.length <= 0 ? Empty() : Button(
                  text: _fieldsToRemove.length == 1
                      ? Strings.of(context).formPageConfirmRemoveField
                      : format(Strings.of(context).formPageConfirmRemoveFields,
                          [_fieldsToRemove.length]),
                  onPressed: _onConfirmRemoveFields,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String key, Widget field) {
    FormPageFieldOption option = widget.fieldOption(key);

    return Input(
      child: Expanded(child: field),
      editable: option == null ? true : option.removable,
      editing: _isRemovingFields,
      selected: _fieldsToRemove.contains(key),
      onEditingSelectionChanged: (bool selected) {
        setState(() {
          if (selected) {
            _fieldsToRemove.add(key);
          } else {
            _fieldsToRemove.remove(key);
          }
        });
      },
    );
  }

  Widget _addFieldSelectionPage() => _SelectionPage(
    options: widget.addFieldOptions,
    onSelectItems: (selectedIds) => widget.onAddFields(selectedIds),
  );

  void _onPressedSave() {
    if (!_key.currentState.validate()) {
      return;
    }

    _key.currentState.save();
    widget.onSave?.call();

    Navigator.pop(context);
  }

  void _onConfirmRemoveFields() {
    widget.onConfirmRemoveFields?.call(_fieldsToRemove);
    _stopRemovingFields();
  }

  void _stopRemovingFields() {
    setState(() {
      _isRemovingFields = false;
      _fieldsToRemove.clear();
    });
  }
}

class _SelectionPage extends StatefulWidget {
  final List<FormPageFieldOption> options;
  final Function(Set<String>) onSelectItems;

  _SelectionPage({
    @required this.options,
    this.onSelectItems,
  }) : assert(options != null);

  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<_SelectionPage> {
  List<CustomEntity> _addedCustomFields = [];

  @override
  Widget build(BuildContext context) {
    List<FormPageFieldOption> options = allOptions;
    Set<FormPageFieldOption> used = options.where((e) => e.used).toSet();

    return PickerPage<FormPageFieldOption>(
      pageTitle: Strings.of(context).formPageSelectFieldsTitle,
      initialValues: used,
      itemBuilder: () => options.map((o) =>
          PickerPageItem<FormPageFieldOption>(
            title: o.userFacingName,
            value: o,
            enabled: o.removable,
          )).toList(),
      onFinishedPicking: (options) {
        widget.onSelectItems(options.map((o) => o.id).toSet());
        Navigator.pop(context);
      },
      saveItemHelper: PickerPageAddCustomHelper(
        onAddPressed: () => present(context, AddCustomFieldPage(
          onSave: (customField) {
            setState(() {
              _addedCustomFields.add(customField);
            });
          },
        ),
      )),
    );
  }

  List<FormPageFieldOption> get allOptions {
    return []..addAll(widget.options)
      ..addAll(_addedCustomFields.map((CustomEntity field) {
        return FormPageFieldOption(
          id: field.id,
          userFacingName: field.name,
        );
      }));
  }
}