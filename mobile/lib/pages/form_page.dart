import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

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

  FormPageFieldOption({
    this.id,
    this.userFacingName,
    this.used = false,
  });
}

/// A customizable user input page that supports user-manageable input fields.
/// If desired, users can add and remove input fields.
///
/// Widgets using the [FormPage] widget are responsible for tracking field input
/// values, as well as form validation outside the normal [FormState]
/// validation. The [FormState] validate method is called prior to the
/// [FormPage.onSave], but before the page is dismissed.
class FormPage extends StatefulWidget {
  /// The title of the page.
  final String title;

  /// A function responsible for building all input widgets.
  ///
  /// @param BuildContext
  /// @param bool `true` if the form is in "removing fields mode"
  ///
  /// @return The returned map key [String] represents the identifier in the
  /// underlying model object, such as "angler", "baitId", etc. The returned
  /// map value [InputField] is the widget that is displayed.
  ///
  /// Note that the returned map key is used keeping track of [InputFields]
  /// that are selected for deletion.
  final Map<String, InputField> Function(BuildContext, bool) fieldBuilder;

  /// Called when a user confirms the deletion of fields. The implementation of
  /// this method is responsible for deleting the correct fields from the
  /// underlying data model.
  ///
  /// @param A [List] of field IDs to be deleted.
  final Function(List<String>) onConfirmRemoveFields;

  /// A [List] of fields that can be added to the form, if the user desires.
  final List<FormPageFieldOption> addFieldOptions;

  /// Called when a field is added to the form.
  /// @param id The ID of the field that was selected.
  final Function(String id) onAddField;

  final VoidCallback onSave;

  FormPage({
    Key key,
    this.title,
    @required this.fieldBuilder,
    this.onSave,
    this.onConfirmRemoveFields,
    this.addFieldOptions,
    this.onAddField,
  }) : assert(fieldBuilder != null), super(key: key);

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _key = GlobalKey<FormState>();

  bool _isRemovingFields = false;
  List<String> _fieldsToRemove = [];

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
        onPressed: _onPressedSave,
        condensed: true,
      );
    }

    return Page(
      appBarStyle: PageAppBarStyle(
        title: widget.title,
        actions: [
          actionButton,
          PopupMenuButton<_OverflowOption>(
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
          ),
        ],
      ),
      padding: insetsHorizontalDefault,
      child: Form(
        key: _key,
        child: SingleChildScrollView(
          padding: insetsBottomDefault,
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
              Padding(
                padding: insetsTopSmall,
                child: Button(
                  text: Strings.of(context).formPageAddFieldText,
                  onPressed: _isRemovingFields ? null : () {
                    push(
                      context,
                      _addFieldSelectionPage(),
                      fullscreenDialog: true,
                    );
                  },
                ),
              ),
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
    );
  }

  Widget _inputField(String key, InputField field) => Input(
    child: Expanded(child: field),
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

  Widget _addFieldSelectionPage() => _SelectionPage(
    options: widget.addFieldOptions,
    onSelectItem: (String selectedId) {
      widget.onAddField(selectedId);
    },
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

class _SelectionPage extends StatelessWidget {
  final List<FormPageFieldOption> options;
  final Function(String) onSelectItem;

  _SelectionPage({
    @required this.options,
    this.onSelectItem,
  }) : assert(options != null);

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: Strings.of(context).formPageSelectFieldTitle,
      ),
      child: ListView.builder(
        itemCount: options.length,
        itemBuilder: (BuildContext context, int i) {
          return ListItem(
            title: Text(options[i].userFacingName),
            enabled: !options[i].used,
            onTap: () {
              onSelectItem?.call(options[i].id);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}