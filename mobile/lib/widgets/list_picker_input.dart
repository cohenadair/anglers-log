import 'package:flutter/material.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/listener_manager.dart';
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
  final Widget pageTitle;

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

  /// See [PickerPage.listenerManager].
  final ListenerManager<EntityListener> listenerManager;

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

  /// Invoked when building the value widget and not enough information is
  /// provided to create said widget, such as when using
  /// [ListPickerInput.customTap] constructor.
  final String Function() valueBuilder;

  /// Invoked when the [ListPickerInput] widget is tapped. This is only
  /// applicable when using the [ListPickerInput.customTap] constructor.
  final VoidCallback onTap;

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
    this.listenerManager,
    this.itemEqualsOldValue,
    this.valueBuilder,
    this.onTap,
  }) : assert(itemBuilder != null),
       assert(onChanged != null),
       initialValues = initialValues ?? {};

  ListPickerInput.single({
    @required Widget pageTitle,
    T initialValue,
    @required List<PickerPageItem<T>> Function() itemBuilder,
    @required OnListPickerChanged<T> onChanged,
    @required String labelText,
    EdgeInsets padding,
    bool enabled = true,
    PickerPageItemManager itemManager,
    ListenerManager<EntityListener> listenerManager,
    bool Function(PickerPageItem<T>, T) itemEqualsOldValue,
  }) : this(
    pageTitle: pageTitle,
    initialValues: initialValue == null ? {} : { initialValue },
    itemBuilder: itemBuilder,
    onChanged: (items) => onChanged(items.first),
    showsValueOnTrailing: true,
    titleBuilder: (_) => Text(labelText),
    enabled: enabled,
    itemManager: itemManager,
    allowsMultiSelect: false,
    listenerManager: listenerManager,
    itemEqualsOldValue: itemEqualsOldValue,
  );

  /// A [ListPickerInput] with a custom [onTap] handler. This should be used
  /// anywhere a custom picker is required, such as when picking a bait, catch
  /// or a more complex object.
  ListPickerInput.customTap({
    String label,
    @required String Function() valueBuilder,
    ListenerManager<EntityListener> listenerManager,
    @required VoidCallback onTap,
  }) : this(
    pageTitle: Text(""),
    itemBuilder: () => [],
    onChanged: (_) {},
    titleBuilder: (_) => Text(label),
    allowsMultiSelect: false,
    showsValueOnTrailing: true,
    listenerManager: listenerManager,
    valueBuilder: valueBuilder,
    onTap: onTap,
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
    var onTap;
    if (widget.enabled) {
      if (widget.onTap == null) {
        onTap = () {
          push(context, PickerPage<T>(
            listenerManager: widget.listenerManager,
            itemManager: widget.itemManager,
            title: widget.pageTitle,
            listHeader: widget.listHeader,
            multiSelect: widget.allowsMultiSelect,
            initialValues: _values,
            allItem: widget.allItem,
            itemBuilder: widget.itemBuilder,
            onFinishedPicking: (context, pickedItems) {
              _popPickerPage(context, pickedItems);
            },
          ));
        };
      } else {
        onTap = widget.onTap;
      }
    }

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
        onTap: onTap,
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
    if (!widget.allowsMultiSelect && widget.showsValueOnTrailing) {
      return EntityListenerBuilder<T>(
        manager: widget.listenerManager,
        builder: (context) {
          // Retrieve the title from the most up to date items.
          String title;

          if (_values.isNotEmpty && widget.itemEqualsOldValue != null) {
            for (var item in widget.itemBuilder()) {
              if (widget.itemEqualsOldValue(item, _values.first)) {
                title = item.title;
                break;
              }
            }
          } else if (widget.valueBuilder != null) {
            title = widget.valueBuilder();
          }

          return Padding(
            padding: insetsRightWidgetSmall,
            child: SecondaryLabelText(isEmpty(title)
                ? Strings.of(context).inputNotSelected : title),
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