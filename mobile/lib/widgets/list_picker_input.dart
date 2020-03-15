import 'package:flutter/material.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/future_stream_builder.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

typedef OnListPickerChanged<T> = void Function(T);

/// A generic picker widget for selecting items from a list. This should be used
/// in place of a [DropdownButton] when there are a lot of options, or if
/// multi-select is desired.
///
/// This widget shows a [PickerPage] for selecting items.
class ListPickerInput<T> extends StatefulWidget {
  /// See [PickerPage.pageTitle].
  final String pageTitle;

  /// See [PickerPage.initialValues].
  final Set<T> initialValues;

  /// See [PickerPage.allItem].
  final PickerPageItem<T> allItem;

  /// See [PickerPage.itemBuilder].
  final List<PickerPageItem<T>> Function() itemBuilder;

  /// See [PickerPage.onFinishedPicking].
  final OnListPickerChanged<Set<T>> onChanged;

  /// See [PickerPage.multiSelect].
  final bool allowsMultiSelect;

  /// See [PickerPage.listHeader].
  final Widget listHeader;

  /// See [PickerPage.itemManager].
  final PickerPageItemManager itemManager;

  /// See [PickerPage.futureStreamHolder].
  final FutureStreamHolder futureStreamHolder;

  /// If `true`, the selected value will render on the right side of the
  /// picker. This does not apply to multi-select pickers.
  final bool showsValueOnTrailing;

  /// Implement this property to create a custom title widget for displaying
  /// which items are selected. Default behaviour is to display a [Column] of
  /// all [PickerPageItem.title] properties.
  final Widget Function(Set<T>) titleBuilder;

  /// If `false`, picker is disabled and cannot be tapped.
  final bool enabled;

  /// Invoked when the underlying data model has updated, and the value
  /// of the [ListPickerInput] needs to be updated. Returns true if the
  /// new [PickerPageItem] is equal to the old value [T].
  final bool Function(PickerPageItem<T>, T) itemEqualsOldValue;

  ListPickerInput({
    @required this.pageTitle,
    Set<T> initialValues = const {},
    this.allItem,
    @required this.itemBuilder,
    @required this.onChanged,
    this.allowsMultiSelect = true,
    this.titleBuilder,
    this.listHeader,
    this.showsValueOnTrailing = false,
    this.enabled = true,
    this.itemManager,
    this.futureStreamHolder,
    this.itemEqualsOldValue,
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
    @required String pageTitle,
    T initialValue,
    @required List<PickerPageItem<T>> Function() itemBuilder,
    @required OnListPickerChanged<T> onChanged,
    @required String labelText,
    EdgeInsets padding,
    bool enabled = true,
    PickerPageItemManager addItemHelper,
    FutureStreamHolder futureStreamHolder,
    bool Function(PickerPageItem<T>, T) itemEqualsOldValue,
  }) : this(
    pageTitle: pageTitle,
    initialValues: initialValue == null ? {} : { initialValue },
    itemBuilder: itemBuilder,
    onChanged: (items) => onChanged(items.first),
    showsValueOnTrailing: true,
    titleBuilder: (_) => Text(labelText),
    enabled: enabled,
    itemManager: addItemHelper,
    allowsMultiSelect: false,
    futureStreamHolder: futureStreamHolder,
    itemEqualsOldValue: itemEqualsOldValue,
  );

  @override
  _ListPickerInputState<T> createState() => _ListPickerInputState<T>();

  PickerPageItem<T> _getListPickerItem(T item) {
    if (allItem != null && item == allItem.value) {
      return allItem;
    }
    return itemBuilder().singleWhere((indexItem) => indexItem.value == item,
        orElse: () => null);
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
          push(context, PickerPage<T>(
            futureStreamHolder: widget.futureStreamHolder,
            itemManager: widget.itemManager,
            pageTitle: widget.pageTitle,
            listHeader: widget.listHeader,
            multiSelect: widget.allowsMultiSelect,
            initialValues: _values,
            allItem: widget.allItem,
            itemBuilder: widget.itemBuilder,
            onFinishedPicking: (pickedItems) {
              _popPickerPage(context, pickedItems);
            },
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
      return FutureStreamBuilder(
        holder: widget.futureStreamHolder,
        builder: (context) {
          // Retrieve the title from the most up to date items.
          String title;
          if (widget.itemEqualsOldValue != null) {
            for (var item in widget.itemBuilder()) {
              if (widget.itemEqualsOldValue(item, _values.first)) {
                title = item.title;
                break;
              }
            }
          }

          return isEmpty(title) ? Empty() : Padding(
            padding: insetsRightWidgetSmall,
            child: SecondaryLabelText(title),
          );
        },
      );
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