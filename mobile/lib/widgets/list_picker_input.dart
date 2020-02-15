import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

typedef OnListPickerChanged<T> = void Function(T);

/// A generic picker widget for selecting items from a list. This should be used
/// in place of a [DropdownButton] when there are a lot of options, or if
/// multi-select is desired.
///
/// Note that a [Set] is used to determine which items are selected, and as
/// such, `T` must override `==`.
///
/// Also note that the [ListPickerInput] title widget will not automatically
/// update. The [onChanged] method should set the state on the container
/// widget.
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
  /// in an [Activity] picker that allows selection of all activities, this
  /// value could be "All activities".
  final PickerInputItem<T> allItem;

  final List<PickerInputItem<T>> items;
  final OnListPickerChanged<Set<T>> onChanged;

  final bool allowsMultiSelect;

  /// If `true`, the selected value will render on the right side of the
  /// picker. This does not apply to multi-select pickers.
  final bool showsValueOnTrailing;

  /// Implement this property to create a custom title widget for displaying
  /// which items are selected. Default behaviour is to display a [Column] of
  /// all [PickerInputItem.title] properties.
  final Widget Function(Set<T>) titleBuilder;

  /// A [Widget] to show at the top of the underlying [ListView]. This [Widget]
  /// will scroll with the [ListView].
  final Widget listHeader;

  final bool enabled;

  ListPickerInput({
    this.pageTitle,
    Set<T> initialValues = const {},
    this.allItem,
    @required this.items,
    @required this.onChanged,
    this.allowsMultiSelect = false,
    this.titleBuilder,
    this.listHeader,
    this.showsValueOnTrailing = false,
    this.enabled = true,
  }) : assert(items != null),
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
    @required List<PickerInputItem<T>> items,
    @required OnListPickerChanged<T> onChanged,
    @required String labelText,
    EdgeInsets padding,
    bool enabled = true,
  }) : this(
    pageTitle: pageTitle,
    initialValues: initialValue == null ? {} : { initialValue },
    items: items,
    onChanged: (items) => onChanged(items.first),
    showsValueOnTrailing: true,
    titleBuilder: (_) => Text(labelText),
    enabled: enabled,
  );

  @override
  _ListPickerInputState<T> createState() => _ListPickerInputState<T>();

  PickerInputItem<T> _getListPickerItem(T item) {
    if (allItem != null && item == allItem.value) {
      return allItem;
    }
    return items.singleWhere((indexItem) => indexItem.value == item);
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
          push(context, _PickerInputPage<T>(
            pageTitle: widget.pageTitle,
            listHeader: widget.listHeader,
            allowsMultiSelect: widget.allowsMultiSelect,
            selectedValues: _values,
            allItem: widget.allItem,
            items: widget.items,
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
class PickerInputItem<T> {
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

  PickerInputItem.divider()
    : value = null,
      title = null,
      subtitle = null,
      isDivider = true,
      popsListOnPicked = false,
      onTap = null;

  PickerInputItem({
    @required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.popsListOnPicked = true,
  }) : assert(value != null || (value == null && onTap != null)),
       assert(title != null),
       isDivider = false;
}

/// A helper page for [ListPickerInput] that renders a list of options.
class _PickerInputPage<T> extends StatefulWidget {
  final String pageTitle;
  final Widget listHeader;
  final Set<T> selectedValues;

  final PickerInputItem<T> allItem;
  final List<PickerInputItem<T>> items;

  final Function(T) onItemPicked;
  final Function(Set<T>) onDonePressed;

  final bool allowsMultiSelect;

  _PickerInputPage({
    this.pageTitle,
    this.listHeader,
    this.allowsMultiSelect = false,
    @required this.selectedValues,
    this.allItem,
    @required this.items,
    @required this.onItemPicked,
    this.onDonePressed,
  }) : assert(selectedValues != null),
       assert(items != null),
       assert(onItemPicked != null);

  @override
  _PickerInputPageState<T> createState() => _PickerInputPageState();
}

class _PickerInputPageState<T> extends State<_PickerInputPage<T>> {
  Set<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = Set.of(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    List<PickerInputItem<T>> items =
        (widget.allItem == null ? [] : [widget.allItem])..addAll(widget.items);

    return Page(
      appBarStyle: PageAppBarStyle(
        title: widget.pageTitle,
        actions: widget.allowsMultiSelect ? [
          ActionButton.done(onPressed: () {
            widget.onDonePressed(_selectedValues);
          }),
        ] : [],
      ),
      child: ListView(
        children: [
          widget.listHeader == null ? Empty() : Padding(
            padding: insetsDefault,
            child: widget.listHeader,
          ),
        ]..addAll(items.map((PickerInputItem<T> item) {
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
      ),
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