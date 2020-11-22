import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../res/dimen.dart';
import '../widgets/checkbox_input.dart';
import '../widgets/list_item.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';

/// A generic picker page for selecting a single or multiple items from a list.
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
  /// using [PickerPageItem.divider]. Headings can be added between items by
  /// using [PickerPageItem.heading]. This function will be invoked whenever
  /// the picker list needs to be rebuilt, such as when an item is
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
    Set<T> initialValues,
    this.multiSelect = true,
    this.title,
    this.listHeader,
    this.allItem,
    this.action,
  })  : assert(itemBuilder != null),
        initialValues = initialValues ?? const {};

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
          initialValues: initialValue == null ? {} : {initialValue},
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
    return WillPopScope(
      onWillPop: () {
        if (widget.multiSelect) {
          widget.onFinishedPicking(context, _selectedValues);
        }
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: widget.title,
          actions: [
            widget.action == null ? Empty() : widget.action,
          ],
        ),
        body: _buildListView(context),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    var children = <Widget>[];
    if (widget.listHeader != null) {
      children.add(Padding(
        padding: insetsDefault,
        child: widget.listHeader,
      ));
    }

    var items = (widget.allItem == null ? [] : [widget.allItem])
      ..addAll(widget.itemBuilder());

    return ListView(
      children: children
        ..addAll(items.map((item) {
          if (item._divider) {
            return Divider();
          }

          if (item._heading) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: paddingWidget,
              ),
              child: HeadingDivider(item.title),
            );
          }

          if (item._note) {
            return SafeArea(
              top: false,
              bottom: false,
              child: Padding(
                padding: insetsHorizontalDefault,
                child: item.noteIcon == null
                    ? NoteLabel(item.title)
                    : IconNoteLabel(
                        text: item.title,
                        icon: Icon(
                          item.noteIcon,
                          color: Colors.black,
                        ),
                      ),
              ),
            );
          }

          VoidCallback onTap;
          if (item.enabled) {
            if (item.onTap != null) {
              onTap = item.onTap;
            } else if (item.popsOnPicked && !widget.multiSelect) {
              onTap = () => _listItemTapped(item);
            }
          }

          return EnabledOpacity(
            enabled: item.enabled,
            child: ListItem(
              title: PrimaryLabel(item.title),
              subtitle: isNotEmpty(item.subtitle)
                  ? SubtitleLabel(item.subtitle)
                  : null,
              enabled: item.enabled,
              onTap: onTap,
              trailing: _buildListItemTrailing(item),
            ),
          );
        }).toList()),
    );
  }

  Widget _buildListItemTrailing(PickerPageItem<T> item) {
    if (widget.multiSelect) {
      // Checkboxes for multi-select pickers.
      return PaddedCheckbox(
        enabled: item.enabled,
        checked: _selectedValues.contains(item.value),
        onChanged: (value) {
          setState(() {
            _checkboxUpdated(item.value);
          });
        },
      );
    } else if (widget.initialValues.isNotEmpty &&
        widget.initialValues.first == item.value) {
      // A simple check mark icon for initial value for single item pickers.
      return Icon(
        Icons.check,
        color: Theme.of(context).primaryColor,
      );
    }

    return null;
  }

  void _listItemTapped(PickerPageItem<T> item) async {
    setState(() {
      _selectedValues = {item.value};
    });
    widget.onFinishedPicking(context, {item.value});
  }

  void _checkboxUpdated(T pickedItem) {
    if (widget.allItem != null && widget.allItem.value == pickedItem) {
      // If the "all" item was picked, deselect all other items.
      _selectedValues = {widget.allItem.value};
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

  /// True if the (single item) picker should be popped off the navigation stack
  /// when this item is tapped. Defaults to true.
  final bool popsOnPicked;

  /// A custom on tapped event for the [PickerPageItem]. If this value is
  /// non-null, [popsOnPicked] is ignored.
  final VoidCallback onTap;

  final T value;
  final IconData noteIcon;

  final bool _divider;
  final bool _heading;
  final bool _note;

  PickerPageItem.divider()
      : value = null,
        title = null,
        subtitle = null,
        enabled = false,
        popsOnPicked = false,
        onTap = null,
        noteIcon = null,
        _divider = true,
        _heading = false,
        _note = false;

  PickerPageItem.heading(this.title)
      : assert(isNotEmpty(title)),
        value = null,
        subtitle = null,
        enabled = false,
        popsOnPicked = false,
        onTap = null,
        noteIcon = null,
        _divider = false,
        _heading = true,
        _note = false;

  /// When used, a [NoteLabel] widget is rendered. This is normally used after
  /// to give an explanation as to why there are no items to show beneath a
  /// [PickerPageItem.heading].
  PickerPageItem.note(
    this.title, {
    this.noteIcon,
  })  : assert(isNotEmpty(title)),
        value = null,
        subtitle = null,
        enabled = false,
        popsOnPicked = false,
        onTap = null,
        _divider = false,
        _heading = false,
        _note = true;

  PickerPageItem({
    @required this.title,
    this.subtitle,
    @required this.value,
    this.enabled = true,
    this.popsOnPicked = true,
    this.onTap,
  })  : assert(value != null),
        assert(title != null),
        noteIcon = null,
        _divider = false,
        _heading = false,
        _note = false;
}
