import 'package:flutter/material.dart';
import 'package:mobile/res/theme.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../widgets/list_item.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';
import 'manageable_list_page.dart';

// TODO: #676 - Refactor to use a "static" ManageableListPage.

/// A generic picker page for selecting a single or multiple items from a list.
///
/// Note that a [Set] is used to determine which items are selected, and as
/// such, `T` must override `==`.
///
/// Note that this should only be used for static lists, not for picking from a
/// list of manageable entities, such as a list of [Bait] objects. In those
/// cases, a [ManageableListPage] should used with appropriate picker settings.
class PickerPage<T> extends StatefulWidget {
  /// See [AppBar.title].
  final Widget? title;

  /// An action widget that is rendered on the right side of the [AppBar].
  final Widget? action;

  /// A [Widget] to show at the top of the underlying [ListView]. This [Widget]
  /// will scroll with the [ListView].
  final Widget? listHeader;

  /// A [Set] of initially selected items.
  final Set<T> initialValues;

  /// This item works differently in that, no matter what, if it is selected
  /// nothing else can be selected at the same time. If another item is
  /// selected while this item is selected, this item is deselected.
  ///
  /// This is meant to be used as a "pick everything" or "pick nothing" option.
  /// For example, in a filter picker that allows selection of all of something,
  /// this value could be "Include All".
  final PickerPageItem<T>? allItem;

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
    required this.itemBuilder,
    required this.onFinishedPicking,
    this.initialValues = const {},
    this.multiSelect = true,
    this.title,
    this.listHeader,
    this.allItem,
    this.action,
  }) : assert(allItem == null || allItem.value != null);

  PickerPage.single({
    required List<PickerPageItem<T>> Function() itemBuilder,
    required void Function(BuildContext, T) onFinishedPicking,
    T? initialValue,
    Widget? title,
    Widget? listHeader,
    PickerPageItem<T>? allItem,
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
  PickerPageState<T> createState() => PickerPageState<T>();
}

class PickerPageState<T> extends State<PickerPage<T>> {
  late Set<T> _selectedValues;

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
            widget.action == null ? const Empty() : widget.action!,
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

    var items = (widget.allItem == null
        ? <PickerPageItem<T>>[]
        : [widget.allItem!, PickerPageItem<T>.divider()])
      ..addAll(widget.itemBuilder());

    return ListView(
      children: children
        ..addAll(items.map((item) {
          if (item._divider) {
            return const MinDivider();
          }

          if (item._heading) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: paddingDefault,
              ),
              child: HeadingDivider(item.title!),
            );
          }

          if (item._note) {
            return SafeArea(
              top: false,
              bottom: false,
              child: Padding(
                padding: insetsHorizontalDefaultBottomDefault,
                child: item.noteIcon == null
                    ? Text(item.title!, style: styleNote(context))
                    : IconLabel(
                        text: item.title!,
                        textArg: Icon(
                          item.noteIcon,
                          color: context.colorText,
                        ),
                      ),
              ),
            );
          }

          if (item.isMultiNone && widget.allItem != null) {
            return PickerListItem(
              title: Strings.of(context).none,
              isSelected: _selectedValues.isEmpty,
              isEnabled: widget.allItem!.enabled,
              onTap: () {
                _listItemTapped(null);
                Navigator.pop(context);
              },
            );
          }

          VoidCallback? onTap;
          if (item.enabled) {
            if (item.onTap != null) {
              onTap = item.onTap;
            } else if (item.isFinishedOnTap && !widget.multiSelect) {
              onTap = () => _listItemTapped(item);
            }
          }

          bool isSelected;
          if (widget.multiSelect) {
            isSelected = _selectedValues.contains(item.value);
          } else {
            isSelected = widget.initialValues.isNotEmpty &&
                widget.initialValues.first == item.value;
          }

          return PickerListItem(
            title: item.title!,
            subtitle: item.subtitle,
            isEnabled: item.enabled,
            isMulti: widget.multiSelect,
            isSelected: isSelected,
            onTap: onTap,
            onCheckboxChanged: (checked) {
              setState(() {
                _checkboxUpdated(item.value, items);
              });
            },
          );
        }).toList()),
    );
  }

  void _listItemTapped(PickerPageItem<T>? item) async {
    var selected = <T>{};
    if (item != null) {
      selected.add(item.value);
    }
    setState(() {
      _selectedValues = selected;
    });
    widget.onFinishedPicking(context, selected);
  }

  void _checkboxUpdated(T pickedItem, List<PickerPageItem<T>> items) {
    if (widget.allItem != null && widget.allItem!.value == pickedItem) {
      // If the "all" item was picked, select or deselect all items.
      if (_selectedValues.contains(pickedItem)) {
        _selectedValues.clear();
      } else {
        _selectedValues = items
            .where((item) => item.hasValue)
            .map((item) => item.value)
            .toSet();
      }
    } else {
      // Otherwise, toggle the picked item, and deselect the "all" item
      // if it exists.
      if (_selectedValues.contains(pickedItem)) {
        _selectedValues.remove(pickedItem);
      } else {
        _selectedValues.add(pickedItem);
      }

      if (widget.allItem != null) {
        _selectedValues.remove(widget.allItem!.value);
      }
    }
  }
}

/// A class for storing the properties of a single item in a [PickerPage].
class PickerPageItem<T> {
  final String? title;
  final String? subtitle;
  final bool enabled;

  /// True if the (single item) picker should invoke the finishing callback
  /// when this item is tapped. Defaults to true.
  final bool isFinishedOnTap;

  /// A custom on tapped event for the [PickerPageItem]. If this value is
  /// non-null, [isFinishedOnTap] is ignored.
  final VoidCallback? onTap;

  final IconData? noteIcon;

  /// A special type of item that shows a "None" row that will clear all
  /// selected items and pop the navigation stack when picking multiple items.
  final bool isMultiNone;

  final T? _value;
  final bool _divider;
  final bool _heading;
  final bool _note;

  PickerPageItem.divider()
      : title = null,
        subtitle = null,
        enabled = false,
        isFinishedOnTap = false,
        onTap = null,
        isMultiNone = false,
        noteIcon = null,
        _value = null,
        _divider = true,
        _heading = false,
        _note = false;

  PickerPageItem.heading(this.title)
      : subtitle = null,
        enabled = false,
        isFinishedOnTap = false,
        onTap = null,
        isMultiNone = false,
        noteIcon = null,
        _value = null,
        _divider = false,
        _heading = true,
        _note = false;

  /// When used, a [NoteLabel] widget is rendered. This is normally used after
  /// to give an explanation as to why there are no items to show beneath a
  /// [PickerPageItem.heading].
  PickerPageItem.note({
    required this.title,
    this.noteIcon,
  })  : subtitle = null,
        enabled = false,
        isFinishedOnTap = false,
        onTap = null,
        isMultiNone = false,
        _value = null,
        _divider = false,
        _heading = false,
        _note = true;

  PickerPageItem({
    required this.title,
    this.subtitle,
    required T value,
    this.enabled = true,
    this.isFinishedOnTap = true,
    this.onTap,
    this.isMultiNone = false,
  })  : noteIcon = null,
        _value = value,
        _divider = false,
        _heading = false,
        _note = false;

  bool get hasValue => _value != null;

  T get value {
    assert(_value != null);
    return _value!;
  }
}
