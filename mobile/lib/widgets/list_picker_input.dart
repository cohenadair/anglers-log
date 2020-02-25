import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/future_stream_builder.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

// TODO: Add deleting
// TODO: Add editing
// TODO: Increase space between trailing value and right chevron
// TODO: Fix add dialog button alignment

typedef OnListPickerChanged<T> = void Function(T);

/// A generic picker widget for selecting items from a list. This should be used
/// in place of a [DropdownButton] when there are a lot of options, or if
/// multi-select is desired.
///
/// Note that a [Set] is used to determine which items are selected, and as
/// such, `T` must override `==`.
class ListPickerInput<T> extends StatefulWidget {
  /// A title for the [AppBar].
  final String pageTitle;

  /// A [Set] of initially selected options.
  final Set<T> initialValues;

  /// This option works differently in that, no matter what, if it is selected
  /// nothing else can be selected at the same time. If another item is
  /// selected while this item is selected, this item is deselected.
  ///
  /// This is meant to be used as a "pick everything" option. For example,
  /// in filter picker that allows selection of all of something, this
  /// value could be "Include All".
  final ListPickerInputItem<T> allItem;

  /// All items that can be selected. Dividers can be added between items by
  /// using [ListPickerInputItem.divider]. This function will be invoked
  /// whenever the picker list needs to be rebuilt, such as when an item is
  /// added to the list.
  final List<ListPickerInputItem<T>> Function() itemBuilder;

  /// Invoked when a new item is picked, or when the "Done" button is pressed
  /// for multi-select pickers.
  final OnListPickerChanged<Set<T>> onChanged;

  /// 'true' allows multi-select; `false` otherwise. When multi-select is
  /// enabled, the picker is dismissed via "Done" button in the app bar,
  /// otherwise the picker is dismissed when an item is selected.
  final bool allowsMultiSelect;

  /// If `true`, the selected value will render on the right side of the
  /// picker. This does not apply to multi-select pickers.
  final bool showsValueOnTrailing;

  /// Implement this property to create a custom title widget for displaying
  /// which items are selected. Default behaviour is to display a [Column] of
  /// all [ListPickerInputItem.title] properties.
  final Widget Function(Set<T>) titleBuilder;

  /// A [Widget] to show at the top of the underlying [ListView]. This [Widget]
  /// will scroll with the [ListView].
  final Widget listHeader;

  /// If non-null, an "Add" button will be present in the [AppBar] that allows
  /// users to input a name. This name is passed to the [addItemHelper]
  /// property of this object.
  final ListPickerInputAddHelper addItemHelper;

  /// If non-null, will update the picker when changes to the underlying stream
  /// are made.
  final FutureStreamHolder futureStreamHolder;

  /// If `false`, picker is disabled and cannot be tapped.
  final bool enabled;

  ListPickerInput({
    this.pageTitle,
    Set<T> initialValues = const {},
    this.allItem,
    @required this.itemBuilder,
    @required this.onChanged,
    this.allowsMultiSelect = true,
    this.titleBuilder,
    this.listHeader,
    this.showsValueOnTrailing = false,
    this.enabled = true,
    this.addItemHelper,
    this.futureStreamHolder,
  }) : assert(itemBuilder != null),
       assert(onChanged != null),
       initialValues = initialValues ?? {}
  {
    // Assert that all initial values exist in the given items, and that there
    // are no duplicates.
    initialValues.forEach((T value) {
      try {
        assert(_getListPickerItem(value) != null);
      } on StateError catch(_) {
        assert(false, "Initial value must appear 1 time in items");
      }
    });
  }

  ListPickerInput.single({
    String pageTitle,
    T initialValue,
    @required List<ListPickerInputItem<T>> Function() itemBuilder,
    @required OnListPickerChanged<T> onChanged,
    @required String labelText,
    EdgeInsets padding,
    bool enabled = true,
    ListPickerInputAddHelper addItemHelper,
    FutureStreamHolder futureStreamHolder,
  }) : this(
    pageTitle: pageTitle,
    initialValues: initialValue == null ? {} : { initialValue },
    itemBuilder: itemBuilder,
    onChanged: (items) => onChanged(items.first),
    showsValueOnTrailing: true,
    titleBuilder: (_) => Text(labelText),
    enabled: enabled,
    addItemHelper: addItemHelper,
    allowsMultiSelect: false,
    futureStreamHolder: futureStreamHolder,
  );

  @override
  _ListPickerInputState<T> createState() => _ListPickerInputState<T>();

  ListPickerInputItem<T> _getListPickerItem(T item) {
    if (allItem != null && item == allItem.value) {
      return allItem;
    }
    return itemBuilder().singleWhere((indexItem) => indexItem.value == item);
  }
}

class _ListPickerInputState<T> extends State<ListPickerInput<T>> {
  Set<T> _values;

  @override
  void initState() {
    super.initState();
    _values = widget.initialValues;
  }

  @override
  Widget build(BuildContext context) {
    return EnabledOpacity(
      enabled: widget.enabled,
      child: ListItem(
        contentPadding: widget.enabled ? null : insetsLeftDefault,
        title: widget.titleBuilder == null
            ? _buildTitle() : widget.titleBuilder(_values),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildSingleDetail(),
            Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          push(context, _ListPickerInputPage<T>(
            futureStreamHolder: widget.futureStreamHolder,
            addItemHelper: widget.addItemHelper,
            pageTitle: widget.pageTitle,
            listHeader: widget.listHeader,
            allowsMultiSelect: widget.allowsMultiSelect,
            selectedValues: _values,
            allItem: widget.allItem,
            itemBuilder: widget.itemBuilder,
            onItemPicked: (T pickedItem) {
              if (!widget.allowsMultiSelect) {
                _popPickerPage(context, Set.of([pickedItem]));
              }
            },
            onDonePressed: widget.allowsMultiSelect ? (Set<T> pickedItems) {
              _popPickerPage(context, pickedItems);
            } : null,
          ));
        },
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _values.map((item) {
        return Text(widget._getListPickerItem(item).title);
      }).toList(),
    );
  }

  Widget _buildSingleDetail() {
    if (_values.length == 1 && !widget.allowsMultiSelect
        && widget.showsValueOnTrailing)
    {
      String title = widget._getListPickerItem(_values.first).title;
      return isEmpty(title) ? Empty() : SecondaryLabelText(title);
    }
    return Empty();
  }

  void _popPickerPage(BuildContext context, Set<T> pickedItems) {
    setState(() {
      _values = pickedItems;
    });
    widget.onChanged(pickedItems);
    Navigator.pop(context);
  }
}

/// A class to be used with [ListPickerInput].
class ListPickerInputItem<T> {
  final String title;
  final String subtitle;
  final T value;

  /// Allows custom behaviour of individual items. Returns a non-null object
  /// of type T that was picked to invoke [ListPickerInput.onChanged]; `null`
  /// otherwise.
  ///
  /// Implemented as a [Future] because presumably, setting this method is
  /// for custom picker behaviour and will need to wait for that behaviour to
  /// finish.
  final Future<T> Function() onTap;

  final bool isDivider;

  /// Whether or not to dismiss the list picker when this item is picked.
  /// Defaults to `true`.
  final bool popsListOnPicked;

  ListPickerInputItem.divider()
    : value = null,
      title = null,
      subtitle = null,
      isDivider = true,
      popsListOnPicked = false,
      onTap = null;

  ListPickerInputItem({
    @required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.popsListOnPicked = true,
  }) : assert(value != null || (value == null && onTap != null)),
       assert(title != null),
       isDivider = false;
}

/// A convenience class for properties pertaining to adding new items to the
/// picker list.
class ListPickerInputAddHelper {
  /// The title for the input dialog.
  final String title;

  /// The label for the [TextField].
  final String labelText;

  /// Invoked on [TextField.onChange]. Return error message, or `nil` if there
  /// is none.
  final FutureOr<String> Function(String) validate;

  /// Invoked when an item has been added.
  final void Function(String) onAdd;

  ListPickerInputAddHelper({
    this.title,
    this.labelText,
    this.validate,
    this.onAdd,
  });
}

/// A helper page for [ListPickerInput] that renders a list of options.
class _ListPickerInputPage<T> extends StatefulWidget {
  final String pageTitle;
  final Widget listHeader;
  final Set<T> selectedValues;

  final ListPickerInputItem<T> allItem;
  final List<ListPickerInputItem<T>> Function() itemBuilder;

  final void Function(T) onItemPicked;
  final void Function(Set<T>) onDonePressed;
  final ListPickerInputAddHelper addItemHelper;
  final FutureStreamHolder futureStreamHolder;

  final bool allowsMultiSelect;

  _ListPickerInputPage({
    this.pageTitle,
    this.listHeader,
    this.allowsMultiSelect = false,
    @required this.selectedValues,
    this.allItem,
    @required this.itemBuilder,
    @required this.onItemPicked,
    this.onDonePressed,
    this.addItemHelper,
    this.futureStreamHolder,
  }) : assert(selectedValues != null),
       assert(itemBuilder != null),
       assert(onItemPicked != null);

  @override
  _ListPickerInputPageState<T> createState() => _ListPickerInputPageState();
}

class _ListPickerInputPageState<T> extends State<_ListPickerInputPage<T>> {
  Set<T> _selectedValues;

  bool get allowsAdding => widget.addItemHelper != null;

  @override
  void initState() {
    super.initState();
    _selectedValues = Set.of(widget.selectedValues);
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

    return Page(
      appBarStyle: PageAppBarStyle(
        title: widget.pageTitle,
        actions: [
          widget.allowsMultiSelect ? ActionButton.done(
            condensed: allowsAdding,
            onPressed: () {
              widget.onDonePressed(_selectedValues);
            },
          ) : Empty(),
          allowsAdding ? IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showTextFieldAddDialog(
                context: context,
                title: widget.addItemHelper.title,
                labelText: widget.addItemHelper.labelText,
                validate: widget.addItemHelper.validate,
                onAdd: widget.addItemHelper.onAdd,
              );
            },
          ) : Empty(),
        ],
      ),
      child: child,
    );
  }

  Widget _buildListView(BuildContext context) {
    List<ListPickerInputItem<T>> items =
        (widget.allItem == null ? [] : [widget.allItem])
            ..addAll(widget.itemBuilder());

    return ListView(
      children: [
        widget.listHeader == null ? Empty() : Padding(
          padding: insetsDefault,
          child: widget.listHeader,
        ),
      ]..addAll(items.map((ListPickerInputItem<T> item) {
        if (item.isDivider) {
          return Divider();
        }

        return ListItem(
          title: Text(item.title),
          subtitle: item.subtitle == null ? null : Text(item.subtitle),
          trailing: _selectedValues.contains(item.value) ? Icon(
            Icons.check,
            color: Theme.of(context).primaryColor,
          ) : null,
          onTap: () async {
            if (item.onTap == null) {
              // Do not trigger the callback for an item that was selected,
              // but not picked -- multi select picker items aren't
              // technically picked until "Done" is pressed.
              if (!widget.allowsMultiSelect) {
                widget.onItemPicked(item.value);
              }
              _updateState(item.value);
            } else {
              T pickedItem = await item.onTap();
              if (pickedItem != null) {
                widget.onItemPicked(pickedItem);
                _updateState(pickedItem);
              }
            }
          },
        );
      }).toList()),
    );
  }

  void _updateState(T pickedItem) {
    setState(() {
      if (widget.allowsMultiSelect) {
        if (widget.allItem != null && widget.allItem.value == pickedItem) {
          // If the "all" item was picked, deselect all other items.
          _selectedValues = Set.of([widget.allItem.value]);
        } else {
          // Otherwise, toggle the picked item, and deselect the "all" item
          // if it exists.
          _toggleItemSelected(pickedItem);

          if (widget.allItem != null) {
            _selectedValues.remove(widget.allItem.value);
          }
        }
      } else {
        // For single selection pickers, always have only one item selected.
        _selectedValues = Set.of([pickedItem]);
      }
    });
  }

  void _toggleItemSelected(T item) {
    if (_selectedValues.contains(item)) {
      _selectedValues.remove(item);
    } else {
      _selectedValues.add(item);
    }
  }
}