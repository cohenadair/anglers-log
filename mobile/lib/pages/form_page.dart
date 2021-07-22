import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:quiver/core.dart';

import '../custom_entity_manager.dart';
import '../entity_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/picker_page.dart';
import '../pages/save_custom_entity_page.dart';
import '../res/dimen.dart';
import '../utils/page_utils.dart';
import '../widgets/button.dart';
import '../widgets/widget.dart';
import 'scroll_page.dart';
import 'units_page.dart';

/// A function responsible for building all input widgets.
///
/// The returned map key [Id] corresponds to the identifier in the
/// underlying model object, such as "angler" or "bait_id". The returned
/// map value [Widget] is the widget that is displayed.
///
/// Note that the returned map key is used in keeping track of [InputFields]
/// that are selected for deletion.
typedef FieldBuilder = Map<Id, Widget> Function(BuildContext);

/// A customizable user input page that supports user-manageable input fields.
/// If desired, users can add and remove input fields.
///
/// Widgets using the [FormPage] widget are responsible for tracking field input
/// values and input validation.
class FormPage extends StatefulWidget {
  static const IconData moreMenuIcon = Icons.more_vert;

  /// See [AppBar.title].
  final Widget? title;

  /// A widget rendered at the top of the list that scrolls with the input form.
  /// This widget does not appear in the "manage fields" page for editable
  /// forms.
  final Widget? header;

  final FieldBuilder fieldBuilder;

  /// A [List] of fields that can be added to the form, if the user desires.
  final List<FormPageFieldOption> addFieldOptions;

  /// Called when a field is added to the form.
  final void Function(Set<Id> ids)? onAddFields;

  /// Used when state is set. Common form components need to be updated
  /// based on whether or not the form has valid input. For example, the "Save"
  /// button is disabled when the input is not valid.
  final bool isInputValid;

  /// Whether this form's components can be added or removed.
  final bool editable;

  /// When true, and when [editable] is true, custom fields can be added to
  /// this form. Defaults to true.
  final bool allowCustomEntities;

  /// Called when the save button is pressed. Returning true will dismiss
  /// the form page; false will leave it open.
  ///
  /// A unique [BuildContext] is passed into the function if the current
  /// [Scaffold] needs to be accessed. For example, to show a [SnackBar].
  final FutureOr<bool> Function(BuildContext)? onSave;

  /// Space between form input widgets.
  final double? runSpacing;

  /// The text for the "save" button. Defaults to "Save".
  final String? saveButtonText;

  final bool showSaveButton;

  /// When true, shows a [Loading] widget instead of the "Save" button.
  final bool showLoadingOverSave;

  final EdgeInsets padding;

  /// A [GlobalKey] for accessing the [PopupMenuButton] of the form. Useful for
  /// programmatically showing the popup menu.
  final GlobalKey<PopupMenuButtonState>? popupMenuKey;

  /// See [ScrollPage.onRefresh].
  final Future<void> Function()? onRefresh;

  /// See [ScrollPage.refreshIndicatorKey].
  final Key? refreshIndicatorKey;

  /// A list of items to show in the page's overflow menu, indicated by a
  /// vertical dots icon on the right side of the [AppBar].
  final List<FormPageOverflowOption> overflowOptions;

  FormPage({
    Key? key,
    this.popupMenuKey,
    this.title,
    this.header,
    required this.fieldBuilder,
    this.onSave,
    this.addFieldOptions = const [],
    this.onAddFields,
    this.editable = true,
    this.allowCustomEntities = true,
    this.padding = insetsHorizontalDefault,
    this.runSpacing,
    this.saveButtonText,
    this.showSaveButton = true,
    this.showLoadingOverSave = false,
    this.isInputValid = true,
    this.onRefresh,
    this.refreshIndicatorKey,
    this.overflowOptions = const [],
  }) : super(key: key);

  FormPage.immutable({
    Key? key,
    Widget? title,
    Widget? header,
    required FieldBuilder fieldBuilder,
    FutureOr<bool> Function(BuildContext)? onSave,
    EdgeInsets padding = insetsHorizontalDefault,
    double? runSpacing,
    bool isInputValid = true,
    String? saveButtonText,
    bool showSaveButton = true,
    bool showLoadingOverSave = false,
    List<FormPageOverflowOption> overflowOptions = const [],
  }) : this(
          key: key,
          title: title,
          fieldBuilder: fieldBuilder,
          header: header,
          onSave: onSave,
          addFieldOptions: const [],
          onAddFields: null,
          editable: false,
          allowCustomEntities: false,
          padding: padding,
          runSpacing: runSpacing,
          isInputValid: isInputValid,
          saveButtonText: saveButtonText,
          showSaveButton: showSaveButton,
          showLoadingOverSave: showLoadingOverSave,
          overflowOptions: overflowOptions,
        );

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _key = GlobalKey<FormState>();

  FormState get _formState {
    assert(_key.currentState != null);
    return _key.currentState!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
        actions: [
          Builder(
            builder: (context) {
              if (!widget.showSaveButton) {
                return Empty();
              }

              // An AnimatedSwitcher is not used here because the different
              // alignments of the Loading widget and ActionButton cause the
              // animation to appear "jarring" where as a complete replace of
              // the widget looks nicer.
              if (widget.showLoadingOverSave) {
                return Loading(
                  padding: EdgeInsets.only(
                    right: paddingDefault,
                    top: paddingDefault,
                  ),
                  isCentered: true,
                  color: Colors.black,
                );
              }

              return ActionButton(
                text: widget.saveButtonText ?? Strings.of(context).save,
                onPressed:
                    widget.isInputValid ? () => _onPressedSave(context) : null,
                condensed: widget.editable,
              );
            },
          ),
          _buildOverflowMenu(),
        ],
      ),
      body: Padding(
        padding: widget.padding,
        child: Form(
          key: _key,
          child: ScrollPage(
            padding: insetsBottomDefault,
            enableHorizontalSafeArea: false,
            onRefresh: widget.onRefresh,
            refreshIndicatorKey: widget.refreshIndicatorKey,
            children: [
              Wrap(
                runSpacing: widget.runSpacing ?? paddingSmall,
                children: _buildChildren(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverflowMenu() {
    if (!widget.editable && widget.overflowOptions.isEmpty) {
      return Empty();
    }

    var options = <FormPageOverflowOption>[];
    if (widget.editable) {
      options.add(FormPageOverflowOption(
          Strings.of(context).formPageManageFieldText,
          () => present(context, _addFieldSelectionPage())));
    }
    options..addAll(widget.overflowOptions);

    return PopupMenuButton<FormPageOverflowOption>(
      key: widget.popupMenuKey,
      icon: Icon(FormPage.moreMenuIcon),
      itemBuilder: (context) =>
          options.map((e) => e.toPopupMenuItem()).toList(),
      onSelected: (option) => option.action(),
    );
  }

  List<Widget> _buildChildren() {
    var children = <Widget>[];

    if (widget.header != null) {
      children.add(widget.header!);
    }
    children.addAll(widget.fieldBuilder(context).values);

    return children;
  }

  Widget _addFieldSelectionPage() {
    return _SelectionPage(
      allowCustomFields: widget.allowCustomEntities,
      options: widget.addFieldOptions,
      onSelectItems: (selectedIds) => widget.onAddFields?.call(selectedIds),
    );
  }

  void _onPressedSave(BuildContext saveContext) async {
    if (!_formState.validate()) {
      return;
    }

    _formState.save();

    if (widget.onSave == null || await widget.onSave!(saveContext)) {
      Navigator.pop(context);
    }
  }
}

/// A small data structure that stores information on fields that can be added
/// to the form by a user.
// TODO: Probably can be refactored to use Field class.
@immutable
class FormPageFieldOption {
  /// The unique ID of the field. Used for identification purposes.
  final Id id;

  /// A required name of the field, as seen and selected by the user.
  final String name;

  /// An optional description of the field, as seen by the user.
  final String? description;

  /// Whether or not the option is already part of the form.
  final bool used;

  /// Whether or not the field can be removed from the form. Defaults to `true`.
  final bool removable;

  FormPageFieldOption({
    required this.id,
    required this.name,
    this.description,
    this.used = false,
    this.removable = true,
  });

  @override
  bool operator ==(Object other) =>
      other is FormPageFieldOption &&
      id == other.id &&
      name == other.name &&
      description == other.description &&
      used == other.used &&
      removable == other.removable;

  @override
  int get hashCode => hash4(id, name, used, removable);
}

/// A convenience class for defining options for a [FormPage] overflow menu,
/// rendered in the [AppBar].
@immutable
class FormPageOverflowOption {
  static FormPageOverflowOption manageUnits(BuildContext context) {
    return FormPageOverflowOption(Strings.of(context).formPageManageUnits,
        () => present(context, UnitsPage()));
  }

  final String name;
  final VoidCallback action;

  FormPageOverflowOption(this.name, this.action);

  PopupMenuItem<FormPageOverflowOption> toPopupMenuItem() {
    return PopupMenuItem<FormPageOverflowOption>(
      value: this,
      child: Text(name),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FormPageOverflowOption && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class _SelectionPage extends StatefulWidget {
  final bool allowCustomFields;
  final List<FormPageFieldOption> options;
  final void Function(Set<Id>) onSelectItems;

  _SelectionPage({
    this.allowCustomFields = true,
    required this.options,
    required this.onSelectItems,
  });

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
        var items = pickerItems;
        var used = items
            .where((item) =>
                item.hasValue &&
                item.value is FormPageFieldOption &&
                item.value.used)
            .map((item) => item.value! as FormPageFieldOption)
            .toSet();

        return PickerPage(
          title: Text(Strings.of(context).pickerTitleFields),
          initialValues: used,
          itemBuilder: () => items,
          onFinishedPicking: (context, items) {
            widget.onSelectItems(
                items.map((item) => (item as FormPageFieldOption).id).toSet());
            Navigator.pop(context);
          },
          action: _buildAction(),
        );
      },
    );
  }

  Widget? _buildAction() {
    if (!widget.allowCustomFields) {
      return null;
    }

    return IconButton(
      icon: Icon(_addItemIconData),
      onPressed: () => present(context, SaveCustomEntityPage()),
    );
  }

  List<PickerPageItem> get pickerItems {
    var result = <PickerPageItem>[];

    // Split custom fields and normal fields that are already included in the
    // form.
    var customFields = <FormPageFieldOption>[];
    var normalFields = <FormPageFieldOption>[];
    for (var option in widget.options) {
      if (customEntityManager.entity(option.id) == null) {
        normalFields.add(option);
      } else {
        customFields.add(option);
      }
    }

    // Add included field options.
    result.addAll(
      normalFields.map(
        (item) => PickerPageItem<FormPageFieldOption>(
          title: item.name,
          subtitle: item.description,
          value: item,
          enabled: item.removable,
        ),
      ),
    );

    if (widget.allowCustomFields) {
      // Add custom field separator/title.
      result..add(PickerPageItem.heading(Strings.of(context).customFields));

      // Add customs fields that aren't already part of the form.
      for (var entity in customEntityManager.list()) {
        var option = customFields.firstWhereOrNull(
          (field) => field.id == entity.id,
        );

        if (option == null) {
          customFields.add(FormPageFieldOption(
            id: entity.id,
            name: entity.name,
            description: entity.description,
          ));
        }
      }

      // Ensure alphabetical order.
      customFields.sort((a, b) => a.name.compareTo(b.name));

      // If there are no custom fields, show a note on how to add them.
      if (customFields.isEmpty) {
        result.add(PickerPageItem.note(
          title: Strings.of(context).formPageItemAddCustomFieldNote,
          noteIcon: _addItemIconData,
        ));
      }

      result.addAll(
        customFields.map(
          (field) => PickerPageItem<FormPageFieldOption>(
            title: field.name,
            subtitle: field.description,
            value: field,
          ),
        ),
      );
    }

    return result;
  }
}
