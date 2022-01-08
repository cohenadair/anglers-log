import 'package:flutter/material.dart';

import '../widgets/input_controller.dart';
import '../widgets/widget.dart';
import 'protobuf_utils.dart';

/// Keeps a Dart [List] in sync with an [AnimatedList] or [SliverAnimatedList].
///
/// The [AnimatedListModel.insert] and [AnimatedListModel.removeAt] methods
/// apply to both the internal list and the animated list that belongs to
/// [listKey].
///
/// Derived from
/// https://api.flutter.dev/flutter/widgets/SliverAnimatedList-class.html
/// sample project.
class AnimatedListModel<T, StateType extends State<StatefulWidget>> {
  final ListInputController<T>? controller;
  final Widget Function(BuildContext, T, Animation<double>) removedItemBuilder;
  final List<T> _items;

  GlobalKey<StateType> listKey;

  AnimatedListModel({
    required this.listKey,
    required this.removedItemBuilder,
    this.controller,
    List<T>? initialItems,
  }) : _items = initialItems == null ? [] : List.of(initialItems);

  // Note that in order for this class to work with both regular and sliver
  // lists, this needs to return a dynamic type; however, this class cannot be
  // instantiated with the incorrect StateType, so everything is safe.
  dynamic get _animatedList {
    dynamic state = listKey.currentState;
    assert(
      state == null ||
          state is AnimatedListState ||
          state is SliverAnimatedListState,
      "Must use either AnimatedListState or SliverAnimatedListState with "
      "AnimatedListModel",
    );
    return state;
  }

  List<T> get items => _items;

  int get length => _items.length;

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  void insert(int index, T item, [Duration duration = animDurationDefault]) {
    _items.insert(index, item);
    _animatedList?.insertItem(index, duration: duration);
    controller?.value = _items;
  }

  T? removeAt(int index, [Duration duration = animDurationDefault]) {
    // Don't attempt to remove an item if it isn't in the underlying data model.
    // This can happen in specialized situations, such as when a bait category
    // isn't shown in a bait list because there are no baits associated with
    // that category.
    if (index < 0 || index >= _items.length) {
      return null;
    }

    var removedItem = _items.removeAt(index);
    _animatedList?.removeItem(
      index,
      (context, animation) =>
          removedItemBuilder(context, removedItem, animation),
      duration: duration,
    );

    controller?.value = _items;
    return removedItem;
  }

  T? remove(T object) => removeAt(indexOf(object));

  int indexOf(T item) => _items.indexOf(item);

  void replace(int index, T item) {
    removeAt(index, Duration.zero);
    insert(index, item, Duration.zero);
  }

  T operator [](int index) => _items[index];

  /// Adds and removes all necessary items so that [_items] is in sync with
  /// [newItems]. Useful for inserting or removing multiple items.
  void resetItems(List<T> newItems) {
    // First, remove all existing items that aren't in the new item list.
    for (var i = _items.length - 1; i >= 0; i--) {
      if (!containsEntityIdOrOther(newItems, _items[i])) {
        removeAt(i);
      }
    }

    // At this point, _items is equal to newItems, minus any new items. Removing
    // items first allows for new items to be added in the correct indices of
    // _items.
    for (var i = 0; i < newItems.length; i++) {
      if (!containsEntityIdOrOther(_items, newItems[i])) {
        insert(i, newItems[i]);
      }
    }

    // Update the value of any items that weren't added or removed so
    // the list shows the most up to date data.
    for (var i = 0; i < _items.length; i++) {
      var indexInNewItems = indexOfEntityIdOrOther(newItems, _items[i]);
      if (indexInNewItems >= 0) {
        _items[i] = newItems[indexInNewItems];
      }
    }

    // Reset items to newItems so order is maintained. All work done prior
    // (inserting and deleting) was so changes are animated. Once this is done,
    // it's safe to replace the model value.
    _items.replaceRange(0, _items.length, newItems);

    controller?.value = _items;
  }
}
