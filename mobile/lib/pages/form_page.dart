import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/widget_utils.dart';

import '../custom_entity_manager.dart';
import '../entity_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/picker_page.dart';
import '../pages/save_custom_entity_page.dart';
import '../res/dimen.dart';
import '../subscription_manager.dart';
import '../utils/page_utils.dart';
import '../widgets/button.dart';
import '../widgets/field.dart';
import '../widgets/widget.dart';
import 'pro_page.dart';
import 'scroll_page.dart';
import 'settings_page.dart';
import 'units_page.dart';

/// A function responsible for building all input widgets.
///
/// The returned map key [Id] corresponds to the identifier in the
/// underlying model object, such as "angler" or "bait_id". The returned
/// map value [Widget] is the widget that is displayed.
///
/// Note that the returned map key is used in keeping track of [Fields]
/// that are selected for deletion.
typedef FieldMapBuilder = Map<Id, Widget> Function(BuildContext);

/// A function responsible for building all input widgets when [Form.immutable]
/// is used.
typedef FieldListBuilder = List<Widget> Function(BuildContext);

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

  /// A [List] of fields that can be added to or removed from the form by the
  /// user. This field does not apply when using [FormPage.immutable].
  final List<Field> editableFields;

  /// Called when a field is added to the form.
  final void Function(Set<Id> ids)? onAddFields;

  /// Used when state is set. Common form components need to be updated
  /// based on whether or not the form has valid input. For example, the "Save"
  /// button is disabled when the input is not valid.
  final bool isInputValid;

  /// Whether this form's components can be added or removed.
  final bool isEditable;

  /// When true, and when [isEditable] is true, custom fields can be added to
  /// this form. Defaults to true.
  final bool allowCustomEntities;

  /// Called when the save button is pressed. Returning true will dismiss
  /// the form page; false will leave it open.
  final FutureOr<bool> Function()? onSave;

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

  final FieldMapBuilder? _fieldMapBuilder;
  final FieldListBuilder? _fieldListBuilder;

  const FormPage({
    Key? key,
    this.popupMenuKey,
    this.title,
    this.header,
    required FieldMapBuilder fieldBuilder,
    this.onSave,
    this.editableFields = const [],
    this.onAddFields,
    this.isEditable = true,
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
  })  : _fieldMapBuilder = fieldBuilder,
        _fieldListBuilder = null,
        super(key: key);

  const FormPage.immutable({
    Key? key,
    Widget? title,
    Widget? header,
    required FieldListBuilder fieldBuilder,
    FutureOr<bool> Function()? onSave,
    EdgeInsets padding = insetsHorizontalDefault,
    double? runSpacing,
    bool isInputValid = true,
    String? saveButtonText,
    bool showSaveButton = true,
    bool showLoadingOverSave = false,
    List<FormPageOverflowOption> overflowOptions = const [],
  }) : this._(
          key: key,
          title: title,
          header: header,
          onSave: onSave,
          editableFields: const [],
          onAddFields: null,
          isEditable: false,
          allowCustomEntities: false,
          padding: padding,
          runSpacing: runSpacing,
          isInputValid: isInputValid,
          saveButtonText: saveButtonText,
          showSaveButton: showSaveButton,
          showLoadingOverSave: showLoadingOverSave,
          overflowOptions: overflowOptions,
          fieldListBuilder: fieldBuilder,
        );

  const FormPage._({
    Key? key,
    this.popupMenuKey,
    this.title,
    this.header,
    FieldMapBuilder? fieldMapBuilder,
    FieldListBuilder? fieldListBuilder,
    this.onSave,
    this.editableFields = const [],
    this.onAddFields,
    this.isEditable = true,
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
  })  : _fieldMapBuilder = fieldMapBuilder,
        _fieldListBuilder = fieldListBuilder,
        super(key: key);

  @override
  FormPageState createState() => FormPageState();
}

class FormPageState extends State<FormPage> {
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
                return const Empty();
              }

              // An AnimatedSwitcher is not used here because the different
              // alignments of the Loading widget and ActionButton cause the
              // animation to appear "jarring" where as a complete replace of
              // the widget looks nicer.
              if (widget.showLoadingOverSave) {
                return const Loading.appBar();
              }

              return ActionButton(
                text: widget.saveButtonText ?? Strings.of(context).save,
                onPressed: widget.isInputValid ? () => _onPressedSave() : null,
                condensed: widget.isEditable,
              );
            },
          ),
          _buildOverflowMenu(),
        ],
      ),
      body: WillPopScope(
        // Note that this isn't called when using a nested Navigator. For
        // example, in AddCatchJourney.
        onWillPop: () async {
          if (widget.showSaveButton) {
            showDiscardChangesDialog(context);
            return false;
          } else {
            return true;
          }
        },
        child: Padding(
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
      ),
    );
  }

  Widget _buildOverflowMenu() {
    if (!widget.isEditable && widget.overflowOptions.isEmpty) {
      return const Empty();
    }

    var options = <FormPageOverflowOption>[];
    if (widget.isEditable) {
      options.add(FormPageOverflowOption(
          Strings.of(context).formPageManageFieldText,
          () => present(context, _addFieldSelectionPage())));
    }
    options.addAll(widget.overflowOptions);

    return PopupMenuButton<FormPageOverflowOption>(
      key: widget.popupMenuKey,
      icon: const Icon(FormPage.moreMenuIcon),
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
    children
      ..addAll(widget._fieldMapBuilder?.call(context).values ?? [])
      ..addAll(widget._fieldListBuilder?.call(context) ?? []);

    return children;
  }

  Widget _addFieldSelectionPage() {
    return _SelectionPage(
      allowCustomFields: widget.allowCustomEntities,
      fields: widget.editableFields,
      onSelectItems: (selectedIds) => widget.onAddFields?.call(selectedIds),
    );
  }

  Future<void> _onPressedSave() async {
    if (!_formState.validate()) {
      return;
    }

    _formState.save();

    if (widget.onSave == null || await widget.onSave!()) {
      safeUseContext(this, () => Navigator.pop(context));
    }
  }
}

/// A convenience class for defining options for a [FormPage] overflow menu,
/// rendered in the [AppBar].
@immutable
class FormPageOverflowOption {
  static FormPageOverflowOption manageUnits(BuildContext context) {
    return FormPageOverflowOption(Strings.of(context).formPageManageUnits,
        () => present(context, UnitsPage()));
  }

  static FormPageOverflowOption autoFetch(BuildContext context) {
    return FormPageOverflowOption(Strings.of(context).inputAutoFetch,
        () => present(context, SettingsPage()));
  }

  final String name;
  final VoidCallback action;

  const FormPageOverflowOption(this.name, this.action);

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
  final List<Field> fields;
  final void Function(Set<Id>) onSelectItems;

  const _SelectionPage({
    this.allowCustomFields = true,
    required this.fields,
    required this.onSelectItems,
  });

  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<_SelectionPage> {
  CustomEntityManager get customEntityManager =>
      CustomEntityManager.of(context);

  SubscriptionManager get _subscriptionManager =>
      SubscriptionManager.of(context);

  IconData get _addItemIconData => Icons.add;

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder(
      managers: [customEntityManager],
      builder: (context) {
        var items = pickerItems;
        var initialValues = initialPickerItems(items);

        return PickerPage(
          title: Text(Strings.of(context).pickerTitleFields),
          initialValues: initialValues,
          itemBuilder: () => items,
          onFinishedPicking: (context, items) {
            widget.onSelectItems(items.map((item) => item as Id).toSet());
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
      onPressed: () {
        if (_subscriptionManager.isPro) {
          present(context, const SaveCustomEntityPage());
        } else {
          present(context, const ProPage());
        }
      },
    );
  }

  List<PickerPageItem> get pickerItems {
    var result = <PickerPageItem>[];

    // Split custom fields and normal fields that are already included in the
    // form.
    var customFields = <Field>[];
    var normalFields = <Field>[];
    for (var field in widget.fields) {
      if (customEntityManager.entity(field.id) == null) {
        normalFields.add(field);
      } else {
        customFields.add(field);
      }
    }

    // Add included field options.
    result.addAll(
      normalFields.map(
        (item) {
          assert(
              item.name != null, "Fields in an editable form must have a name");

          return PickerPageItem<Id>(
            title: item.name?.call(context),
            subtitle: item.description?.call(context),
            value: item.id,
            enabled: item.isRemovable,
          );
        },
      ),
    );

    if (widget.allowCustomFields) {
      // Add custom field separator/title.
      result.add(
          PickerPageItem.heading(Strings.of(context).entityNameCustomFields));

      // Add customs fields that aren't already part of the form.
      for (var entity in customEntityManager.list()) {
        if (!customFields.containsWhere((field) => field.id == entity.id)) {
          customFields.add(Field.fromCustomEntity(entity));
        }
      }

      // Ensure alphabetical order.
      customFields.sort((a, b) {
        assert(a.name != null && b.name != null,
            "Custom field in an editable form must have a name");
        return a.name!(context).compareTo(b.name!(context));
      });

      // If there are no custom fields, show a note on how to add them.
      if (customFields.isEmpty) {
        result.add(PickerPageItem.note(
          title: Strings.of(context).formPageItemAddCustomFieldNote,
          noteIcon: _addItemIconData,
        ));
      }

      result.addAll(
        customFields.map(
          (field) => PickerPageItem<Id>(
            title: field.name?.call(context),
            subtitle: field.description?.call(context),
            value: field.id,
          ),
        ),
      );
    }

    return result;
  }

  Set<Id> initialPickerItems(List<PickerPageItem<dynamic>> allItems) {
    return allItems
        .where((item) {
          if (!item.hasValue || item.value is! Id) {
            return false;
          }

          var isShowing = widget.fields
              .firstWhereOrNull((e) => e.id == item.value)
              ?.isShowing;
          return isShowing ?? false;
        })
        .map<Id>((item) => item.value!)
        .toSet();
  }
}
