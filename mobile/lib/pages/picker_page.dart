import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

/// A generic picker page for selecting a single or multiple items from a list.
/// Includes the
///
/// Note that a [Set] is used to determine which items are selected, and as
/// such, `T` must override `==`.
class PickerPage<T> extends StatefulWidget {
  /// See [AppBar.title].
  final Widget title;

  /// An action widget that is rendered on the right side of the [AppBar].
  final Widget action;

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
  final void Function(BuildContext, Set<T>) onFinishedPicking;

  /// 'true' allows multi-select; `false` otherwise. When multi-select is
  /// enabled, the picker is dismissed via "Done" button in the app bar,
  /// otherwise the picker is dismissed when an item is selected.
  final bool multiSelect;

  PickerPage({
    @required this.itemBuilder,
    @required this.onFinishedPicking,
    this.initialValues = const {},
    this.multiSelect = true,
    this.title,
    this.listHeader,
    this.allItem,
    this.action,
  }) : assert(initialValues != null),
       assert(itemBuilder != null);

  PickerPage.single({
    @required List<PickerPageItem<T>> Function() itemBuilder,
    @required void Function(BuildContext, T) onFinishedPicking,
    T initialValue,
    Widget title,
    Widget listHeader,
    PickerPageItem<T> allItem,
  }) : this(
    itemBuilder: itemBuilder,
    onFinishedPicking: (context, items) =>
        onFinishedPicking(context, items.first),
    initialValues: initialValue == null ? {} : { initialValue },
    multiSelect: false,
    title: title,
    listHeader: listHeader,
    allItem: allItem,
  );

  @override
  _PickerPageState<T> createState() => _PickerPageState();
}

class _PickerPageState<T> extends State<PickerPage<T>> {
  Set<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = Set.of(widget.initialValues);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
        actions: [
          widget.multiSelect ? ActionButton.done(
            condensed: widget.action != null,
            onPressed: () {
              widget.onFinishedPicking(context, _selectedValues);
            },
          ) : Empty(),
          widget.action == null ? Empty() : widget.action,
        ],
      ),
      body: _buildListView(context),
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

        VoidCallback onTap;
        if (item.enabled && !widget.multiSelect) {
          onTap = () => _listItemTapped(item);
        }

        return EnabledOpacity(
          enabled: item.enabled,
          child: ListItem(
            title: PrimaryLabel(item.title),
            enabled: item.enabled,
            onTap: onTap,
            trailing: widget.multiSelect ? _buildListItemCheckbox(item) : null,
          ),
        );
      }).toList()),
    );
  }

  Widget _buildListItemCheckbox(PickerPageItem<T> item) {
    return PaddedCheckbox(
      enabled: item.enabled,
      checked: _selectedValues.contains(item.value),
      onChanged: (value) {
        setState(() {
          _checkboxUpdated(item.value);
        });
      },
    );
  }

  void _listItemTapped(PickerPageItem<T> item) async {
    setState(() {
      _selectedValues = Set.of([item.value]);
    });
    widget.onFinishedPicking(context, { item.value });
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
}

/// A class for storing the properties of a single item in a [PickerPage].
class PickerPageItem<T> {
  final String title;
  final String subtitle;
  final bool enabled;
  final T value;

  final bool _divider;

  PickerPageItem.divider()
      : value = null,
        title = null,
        subtitle = null,
        enabled = false,
        _divider = true;

  PickerPageItem({
    @required this.title,
    this.subtitle,
    @required this.value,
    this.enabled = true,
  }) : assert(value != null),
       assert(title != null),
       _divider = false;
}