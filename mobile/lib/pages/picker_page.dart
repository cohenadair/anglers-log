import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/log.dart';
import 'package:mobile/pages/save_name_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/future_stream_builder.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

/// A generic picker page for selecting items from a list. Includes the
/// following functionality:
/// - Select one or more items
/// - Add items
/// - Edit items
/// - Delete items
///
/// Note that a [Set] is used to determine which items are selected, and as
/// such, `T` must override `==`.
class PickerPage<T> extends StatefulWidget {
  /// A title for the [AppBar].
  final String pageTitle;

  /// A [Widget] to show at the top of the underlying [ListView]. This [Widget]
  /// will scroll with the [ListView].
  final Widget listHeader;

  /// A [Set] of initially selected items.
  final Set<T> initialValues;

  /// This item works differently in that, no matter what, if it is selected
  /// nothing else can be selected at the same time. If another item is
  /// selected while this item is selected, this item is deselected.
  ///
  /// This is meant to be used as a "pick everything" option. For example,
  /// in a filter picker that allows selection of all of something, this
  /// value could be "Include All".
  final PickerPageItem<T> allItem;

  /// All items that can be selected. Dividers can be added between items by
  /// using [PickerPageItem.divider]. This function will be invoked
  /// whenever the picker list needs to be rebuilt, such as when an item is
  /// added to the list.
  final List<PickerPageItem<T>> Function() itemBuilder;

  /// Invoked when an item is picked, or when the "Done" button is pressed
  /// for multi-select pickers.
  final void Function(Set<T>) onFinishedPicking;

  /// If non-null, "Add" and "Edit" buttons will be present in the [AppBar].
  /// The add button behaviour is determined by this value.
  final PickerPageSaveHelper saveItemHelper;

  /// If non-null, will update the picker when changes to the underlying stream
  /// are made.
  final FutureStreamHolder futureStreamHolder;

  /// 'true' allows multi-select; `false` otherwise. When multi-select is
  /// enabled, the picker is dismissed via "Done" button in the app bar,
  /// otherwise the picker is dismissed when an item is selected.
  final bool multiSelect;

  PickerPage({
    @required this.itemBuilder,
    @required this.onFinishedPicking,
    this.initialValues = const {},
    this.multiSelect = true,
    this.pageTitle,
    this.listHeader,
    this.allItem,
    this.saveItemHelper,
    this.futureStreamHolder,
  }) : assert(initialValues != null),
       assert(itemBuilder != null);

  PickerPage.single({
    @required List<PickerPageItem<T>> Function() itemBuilder,
    @required void Function(T) onFinishedPicking,
    T initialValue,
    String pageTitle,
    Widget listHeader,
    PickerPageItem<T> allItem,
    PickerPageSaveHelper addItemHelper,
    FutureStreamHolder futureStreamHolder,
  }) : this(
    itemBuilder: itemBuilder,
    onFinishedPicking: (items) => onFinishedPicking(items.first),
    initialValues: initialValue == null ? {} : { initialValue },
    multiSelect: false,
    pageTitle: pageTitle,
    listHeader: listHeader,
    allItem: allItem,
    saveItemHelper: addItemHelper,
    futureStreamHolder: futureStreamHolder,
  );

  @override
  _PickerPageState<T> createState() => _PickerPageState();
}

class _PickerPageState<T> extends State<PickerPage<T>> {
  final _log = Log("PickerPage");

  Set<T> _selectedValues;
  bool _editing = false;

  bool get allowsSaving => widget.saveItemHelper != null;

  @override
  void initState() {
    super.initState();
    _selectedValues = Set.of(widget.initialValues);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.futureStreamHolder == null) {
      child = _buildListView(context);
    } else {
      child = FutureStreamBuilder(
        holder: widget.futureStreamHolder,
        builder: (context) => _buildListView(context),
      );
    }

    Widget editDoneButton = Empty();
    if (widget.saveItemHelper.editable) {
      if (_editing) {
        editDoneButton = ActionButton.done(
          onPressed: _onDoneEditingPressed,
          condensed: true,
        );
      } else {
        editDoneButton = ActionButton.edit(
          onPressed: _onEditPressed,
          condensed: true,
        );
      }
    }

    return Page(
      appBarStyle: PageAppBarStyle(
        title: widget.pageTitle,
        actions: [
          widget.multiSelect ? ActionButton.done(
            condensed: allowsSaving,
            onPressed: () {
              widget.onFinishedPicking(_selectedValues);
            },
          ) : Empty(),
          editDoneButton,
          allowsSaving ? IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              widget.saveItemHelper.presentAddItem(context);
            },
          ) : Empty(),
        ],
      ),
      child: child,
    );
  }

  Widget _buildListView(BuildContext context) {
    List<PickerPageItem<T>> items =
        (widget.allItem == null ? [] : [widget.allItem])
            ..addAll(widget.itemBuilder());

    return ListView(
      children: [
        widget.listHeader == null ? Empty() : Padding(
          padding: insetsDefault,
          child: widget.listHeader,
        ),
      ]..addAll(items.map((item) {
        if (item._divider) {
          return Divider();
        }

        return ListItem(
          enabled: item.enabled,
          title: Text(item.title),
          subtitle: item.subtitle == null ? null : Text(item.subtitle),
          leading: _editing ? MinimumIconButton(
            icon: Icons.delete,
            color: Colors.red,
            onTap: () {
            },
          ) : null,
          trailing: _buildListItemTrailing(item),
          onTap: widget.multiSelect ? null : () {
            _listItemTapped(item);
          },
        );
      }).toList()),
    );
  }

  Widget _buildListItemTrailing(PickerPageItem<T> item) {
    Widget trailing;

    if (_editing) {
      trailing = RightChevronIcon();
    } else if (widget.multiSelect) {
      trailing = EnabledOpacity(
        enabled: item.enabled,
        child: PaddedCheckbox(
          value: _selectedValues.contains(item.value),
          onChanged: (value) {
            setState(() {
              _checkboxUpdated(item.value);
            });
          },
        ),
      );
    }

    return trailing;
  }

  void _listItemTapped(PickerPageItem<T> item) async {
    T pickedItem;
    if (item.onTap == null) {
      pickedItem = item.value;
    } else {
      pickedItem = await item.onTap();
    }

    if (pickedItem == null) {
      _log.w("Picked item is null");
      return;
    }

    if (_editing) {
      widget.saveItemHelper.showEditItem(context, pickedItem);
    } else {
      setState(() {
        _selectedValues = Set.of([pickedItem]);
      });
      widget.onFinishedPicking({ pickedItem });
    }
  }

  void _checkboxUpdated(T pickedItem) {
    if (widget.allItem != null && widget.allItem.value == pickedItem) {
      // If the "all" item was picked, deselect all other items.
      _selectedValues = Set.of([widget.allItem.value]);
    } else {
      // Otherwise, toggle the picked item, and deselect the "all" item
      // if it exists.
      if (_selectedValues.contains(pickedItem)) {
        _selectedValues.remove(pickedItem);
      } else {
        _selectedValues.add(pickedItem);
      }

      if (widget.allItem != null) {
        _selectedValues.remove(widget.allItem.value);
      }
    }
  }

  void _onEditPressed() {
    setState(() {
      _editing = true;
    });
  }

  void _onDoneEditingPressed() {
    setState(() {
      _editing = false;
    });
  }
}

/// A class for storing the properties of a single item in a [PickerPage].
class PickerPageItem<T> {
  final String title;
  final String subtitle;
  final bool enabled;
  final T value;

  /// Allows custom behaviour of individual items. Returns a non-null object
  /// of type T that was picked.
  ///
  /// Implemented as a [Future] because presumably, setting this method is
  /// for custom picker behaviour and will need to wait for that behaviour to
  /// finish (for example, a database call).
  final Future<T> Function() onTap;

  final bool _divider;

  PickerPageItem.divider()
      : value = null,
        title = null,
        subtitle = null,
        onTap = null,
        enabled = false,
        _divider = true;

  PickerPageItem({
    @required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.enabled = true,
  }) : assert(value != null || (value == null && onTap != null)),
       assert(title != null),
       _divider = false;
}

/// A convenience class used to add items to the list picker.
abstract class PickerPageSaveHelper<T> {
  /// True items are editable. If `true`, an "Edit" button is rendered in the
  /// `AppBar`.
  bool get editable;

  void presentAddItem(BuildContext context);
  void showEditItem(BuildContext context, T itemToEdit) {}
}

/// Use when the only input when adding an item is a name.
///
/// Shows a full screen [FormPage] with a single [TextInput].
class PickerPageSaveNameHelper<T> extends PickerPageSaveHelper<T> {
  final String addTitle;
  final String editTitle;

  /// See [SaveNamePage.validate]. [String] is the input to validate, and [T]
  /// is the old value or `null` if creating a new item.
  final FutureOr<String> Function(String, T) validate;

  /// Invoked when an item has been saved. [String] is the new input, and [T]
  /// is the old value or `null` if creating a new item.
  final void Function(String, T) onSave;

  /// Invoked when editing an item. Returns the name value of [T]. This value
  /// will be set as the initial value of the [TextInputField].
  final String Function(T) oldNameCallback;

  bool get editable => true;

  PickerPageSaveNameHelper({
    @required this.addTitle,
    @required this.editTitle,
    this.validate,
    this.onSave,
    this.oldNameCallback,
  });

  @override
  void presentAddItem(BuildContext context) {
    present(context, SaveNamePage(
      title: addTitle,
      onSave: (newName) {
        onSave(newName, null);
      },
      validate: (potentialName) => validate(potentialName, null),
    ));
  }

  @override
  void showEditItem(BuildContext context, T itemToEdit) {
    push(context, SaveNamePage(
      title: editTitle,
      oldName: oldNameCallback?.call(itemToEdit),
      onSave: (newName) {
        onSave(newName, itemToEdit);
      },
      validate: (potentialName) => validate(potentialName, itemToEdit),
    ));
  }
}

/// Use to customize what happens when the "Add" button is pressed in a
/// [ListPickerInputPage].
class PickerPageAddCustomHelper extends PickerPageSaveHelper {
  final VoidCallback onAddPressed;

  bool get editable => false;

  PickerPageAddCustomHelper({
    @required this.onAddPressed
  }) : assert(onAddPressed != null);

  @override
  void presentAddItem(BuildContext context) {
    onAddPressed();
  }
}