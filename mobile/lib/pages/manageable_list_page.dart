import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../entity_manager.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../res/dimen.dart';
import '../utils/animated_list_model.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/search_timer.dart';
import '../widgets/animated_list_transition.dart';
import '../widgets/button.dart';
import '../widgets/checkbox_input.dart';
import '../widgets/empty_list_placeholder.dart';
import '../widgets/list_item.dart';
import '../widgets/our_search_bar.dart';
import '../widgets/widget.dart';

/// A page that is able to manage a list of a given type, [T]. The page includes
/// an optional [SearchBar] and can be used a single or multi-item picker.
///
/// For a simpler picker, see [PickerPage].
///
/// Note that [T] should override == for the most efficient list reconciliation,
/// but it is not a requirement.
class ManageableListPage<T> extends StatefulWidget {
  /// See [ManageableListPageItemModel].
  final ManageableListPageItemModel Function(BuildContext, T) itemBuilder;

  /// See [ManageableListPageItemManager].
  final ManageableListPageItemManager<T> itemManager;

  /// See [SliverAppBar.title].
  final Widget Function(List<T>)? titleBuilder;

  /// A custom widget to show as the leading widget in a [SliverAppBar].
  final Widget? appBarLeading;

  /// If true, adds additional padding between search icon and search text so
  /// the search text is horizontally aligned with an item's main text.
  /// Defaults to false. If an item has a thumbnail, the [Photo.listThumbnail]
  /// constructor should be used.
  final bool itemsHaveThumbnail;

  /// If true, forces the [AppBar] title to the center of the screen. Defaults
  /// to false.
  ///
  /// See [SliverAppBar.centerTitle].
  final bool forceCenterTitle;

  /// If non-null, the [ManageableListPage] acts like a picker.
  final ManageableListPagePickerSettings<T>? pickerSettings;

  /// If non-null, the [ManageableListPage] includes a [SearchBar] in the
  /// [AppBar].
  ///
  /// See [ManageableListPageSearchDelegate].
  final ManageableListPageSearchDelegate? searchDelegate;

  const ManageableListPage({
    required this.itemManager,
    required this.itemBuilder,
    this.titleBuilder,
    this.appBarLeading,
    this.itemsHaveThumbnail = false,
    this.forceCenterTitle = false,
    this.pickerSettings,
    this.searchDelegate,
  });

  @override
  ManageableListPageState<T> createState() => ManageableListPageState<T>();
}

class ManageableListPageState<T> extends State<ManageableListPage<T>> {
  static const IconData _iconAdd = Icons.add;

  static const _appBarExpandedHeight = 100.0;

  /// Additional padding required to line up search text with [ListItem] text.
  static const _thumbSearchTextOffset = 24.0;

  /// Additional padding required to line up title text with search hint text.
  static const _thumbTitleTextOffset = 8.0;

  final _log = Log("ManageableListPage<$T>");

  final _animatedListKey = GlobalKey<SliverAnimatedListState>();
  late AnimatedListModel<T, SliverAnimatedListState> _animatedList;

  late SearchTimer _searchTimer;
  bool _isEditing = false;
  Set<T> _selectedValues = {};
  _ViewingState _viewingState = _ViewingState.viewing;
  String? _searchText;

  bool get _isPickingMulti => _viewingState == _ViewingState.pickingMulti;

  bool get _isPickingSingle => _viewingState == _ViewingState.pickingSingle;

  bool get _isPicking => _isPickingMulti || _isPickingSingle;

  bool get _hasSearch => widget.searchDelegate != null;

  bool get _hasDetailPage => widget.itemManager.detailPageBuilder != null;

  bool get _isEditable => widget.itemManager.editPageBuilder != null;

  bool get _isAddable =>
      widget.itemManager.addPageBuilder != null ||
      widget.itemManager.onAddButtonPressed != null;

  /// If picking an option isn't required, show a "None" option.
  bool get _showClearOption =>
      _isPicking &&
      !widget.pickerSettings!.isRequired &&
      _animatedList.isNotEmpty;

  @override
  void initState() {
    super.initState();

    if (widget.pickerSettings != null) {
      _viewingState = widget.pickerSettings!.isMulti
          ? _ViewingState.pickingMulti
          : _ViewingState.pickingSingle;
      _selectedValues = Set.of(widget.pickerSettings!.initialValues);
    }

    _searchTimer = SearchTimer(() => setState(_syncAnimatedList));

    _animatedList = AnimatedListModel<T, SliverAnimatedListState>(
      listKey: _animatedListKey,
      initialItems: widget.itemManager.loadItems(_searchText),
      removedItemBuilder: _buildItem,
    );
  }

  @override
  void dispose() {
    _searchTimer.finish();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemManager.listenerManagers.isEmpty) {
      return _buildScaffold(context);
    }

    return EntityListenerBuilder(
      managers: widget.itemManager.listenerManagers,
      builder: _buildScaffold,
      onAdd: _onEntityAdded,
      onDelete: _onEntityDeleted,
      onUpdate: _onEntityUpdated,
      onReset: _syncAnimatedList,
    );
  }

  Widget _buildScaffold(BuildContext context) {
    // Disable editing if there are no items in the list.
    if (_animatedList.isEmpty) {
      _isEditing = false;
    }

    Widget emptyWidget = const Empty();
    var settings = widget.itemManager.emptyItemsSettings;
    if (settings != null &&
        (widget.searchDelegate == null ||
            (isEmpty(_searchText) && _animatedList.isEmpty))) {
      emptyWidget = EmptyListPlaceholder.static(
        title: settings.title,
        description: settings.description,
        descriptionIcon:
            settings.descriptionIcon ?? (_isAddable ? _iconAdd : null),
        icon: settings.icon,
      );
    } else if (isNotEmpty(_searchText)) {
      emptyWidget = EmptyListPlaceholder.noSearchResults(
        context,
        scrollable: false,
      );
    }

    return WillPopScope(
      onWillPop: () {
        if (_isPickingMulti) {
          _finishPicking(_selectedValues);
        }
        return Future.value(true);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverAppBar(
              forceElevated: true,
              floating: true,
              pinned: false,
              title: _buildTitle(),
              actions: _buildActions(_animatedList.items),
              expandedHeight: _hasSearch ? _appBarExpandedHeight : 0.0,
              flexibleSpace: _buildSearchBar(),
              centerTitle: widget.forceCenterTitle,
              leading: widget.appBarLeading,
            ),
            SliverVisibility(
              visible: _showClearOption,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Column(
                    children: [
                      _buildNoneItem(context, _animatedList.items),
                      const MinDivider(),
                    ],
                  ),
                ]),
              ),
            ),
            // TODO: Use animated switcher - https://github.com/flutter/flutter/issues/64069
            SliverVisibility(
              visible: _animatedList.isNotEmpty,
              sliver: SliverSafeArea(
                top: false,
                sliver: SliverAnimatedList(
                  key: _animatedListKey,
                  initialItemCount: _animatedList.length,
                  itemBuilder: (context, i, animation) =>
                      _buildItem(context, _animatedList[i], animation),
                ),
              ),
              replacementSliver: SliverFillRemaining(
                fillOverscroll: true,
                hasScrollBody: false,
                child: Center(
                  child: emptyWidget,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildTitle() {
    Widget? title;
    if (_isPicking) {
      title = _isPickingMulti
          ? widget.pickerSettings?.multiTitle
          : widget.pickerSettings?.title;
    } else {
      title = widget.titleBuilder?.call(_animatedList.items);
    }

    // For lists that include thumbnails, add additional padding to left
    // aligned titles so the title, search hint, and list item titles all
    // horizontally align.
    if (title != null &&
        title is Text &&
        !widget.forceCenterTitle &&
        widget.itemsHaveThumbnail) {
      return Padding(
        padding: const EdgeInsets.only(left: _thumbTitleTextOffset),
        child: title,
      );
    }

    return title;
  }

  Widget? _buildSearchBar() {
    if (!_hasSearch) {
      return null;
    }

    return FlexibleSpaceBar(
      background: Padding(
        padding: const EdgeInsets.only(
          left: paddingDefault,
          right: paddingDefault,
          bottom: paddingSmall,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: OurSearchBar(
            text: _searchText,
            hint: widget.searchDelegate!.hint,
            leadingPadding:
                widget.itemsHaveThumbnail ? _thumbSearchTextOffset : null,
            elevated: false,
            delegate: InputSearchBarDelegate((text) {
              _searchText = text;
              _searchTimer.reset(_searchText);
            }),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions(List<T> items) {
    var result = <Widget>[];

    if (items.isNotEmpty) {
      if (_isEditing) {
        result.add(ActionButton.done(
          condensed: _isAddable,
          onPressed: () => _setEditingUpdateState(false),
        ));
      } else if (_isEditable) {
        // Only include the edit button if the items can be modified.
        result.add(ActionButton.edit(
          condensed: _isAddable,
          onPressed: () => _setEditingUpdateState(true),
        ));
      }
    }

    // Only include the add button if new items can be added.
    if (_isAddable) {
      result.add(IconButton(
        icon: const Icon(_iconAdd),
        onPressed: widget.itemManager.onAddButtonPressed ??
            () => present(context, widget.itemManager.addPageBuilder!()),
      ));
    }

    return result;
  }

  Widget _buildNoneItem(BuildContext context, List<T> items) {
    var label = Strings.of(context).none;
    Widget? trailing;
    VoidCallback? onTap;
    if (_isPickingSingle) {
      trailing = _selectedValues.isEmpty ? const ItemSelectedIcon() : null;
      onTap = () => _finishPicking({});
    } else if (_isPickingMulti) {
      label = Strings.of(context).all;
      trailing = PaddedCheckbox(
        checked: widget.pickerSettings!.containsAll?.call(_selectedValues) ??
            _selectedValues.containsAll(items),
        onChanged: (isChecked) => setState(() {
          if (isChecked) {
            _selectedValues = items.toSet();
          } else {
            _selectedValues.clear();
          }
          widget.pickerSettings!.onPickedAll?.call(isChecked);
        }),
      );
      onTap = null;
    }

    return ManageableListItem(
      editing: false,
      onTapDeleteButton: () => false,
      onTap: onTap,
      trailing: trailing,
      child: Text(label),
    );
  }

  Widget _buildItem(
      BuildContext context, T itemValue, Animation<double> animation) {
    var item = widget.itemBuilder(context, itemValue);

    if (!item.isEditable && !item.isSelectable) {
      // If this item can't be edited or selected, return it; we don't want
      // to use a ManageableListItem.
      return item.child;
    }

    Widget? trailing = RightChevronIcon();
    if (_isPickingMulti) {
      trailing = PaddedCheckbox(
        checked: _isItemSelected(itemValue),
        onChanged: (checked) {
          setState(() {
            if (_isItemSelected(itemValue)) {
              _selectedValues.remove(itemValue);
            } else {
              _selectedValues.add(itemValue);
            }
          });
        },
      );
    } else if (_isPickingSingle ||
        widget.itemManager.detailPageBuilder == null) {
      // Don't show detail disclosure indicator if we're picking a single
      // value, or if there isn't any detail to show.
      trailing = _isItemSelected(itemValue) ? const ItemSelectedIcon() : null;
    }

    // For now, only allow selecting items with a grandchild in a single picker.
    // This allows users to select the entire item (including grandchildren),
    // such as in BaitListPage.
    if (_isPicking && item.grandchild != null && _isPickingMulti) {
      trailing = const Empty();
    }

    var canEdit = _isEditing && item.isEditable;
    var enabled = !_isEditing || canEdit;

    VoidCallback? onTap;
    if (enabled) {
      if (canEdit) {
        onTap = () =>
            present(context, widget.itemManager.editPageBuilder!(itemValue));
      } else if (_isPickingSingle) {
        onTap = () => _finishPicking({itemValue});
      } else if (_hasDetailPage && !_isPickingMulti) {
        onTap = () =>
            push(context, widget.itemManager.detailPageBuilder!(itemValue));
      }
    }

    var canDelete = widget.itemManager.deleteWidget != null &&
        widget.itemManager.deleteItem != null;

    var listItem = ManageableListItem(
      editing: canEdit,
      enabled: enabled,
      deleteMessageBuilder: canDelete
          ? (context) => widget.itemManager.deleteWidget!(context, itemValue)
          : null,
      onConfirmDelete: canDelete
          ? () => widget.itemManager.deleteItem!(context, itemValue)
          : null,
      onTap: onTap,
      onTapDeleteButton: widget.itemManager.onTapDeleteButton == null
          ? null
          : () => widget.itemManager.onTapDeleteButton!(itemValue),
      trailing: trailing,
      grandchild: item.grandchild,
      child: item.child,
    );

    return AnimatedListTransition(
      animation: animation,
      child: listItem,
    );
  }

  void _setEditingUpdateState(bool isEditing) {
    setState(() {
      _isEditing = isEditing;
    });
  }

  void _finishPicking(Set<T> pickedValues) {
    if (widget.pickerSettings!.onPicked(context, pickedValues)) {
      Navigator.of(context).pop();
    }
  }

  bool _isItemSelected(T item) {
    return containsEntityIdOrOther(_selectedValues, item);
  }

  /// Sync's the animated list model with the database list.
  void _syncAnimatedList() {
    _animatedList.resetItems(widget.itemManager.loadItems(_searchText));
  }

  void _onEntityAdded(dynamic entity) {
    _onEntityAddedOrDeleted((newItems) {
      // Don't animate any entity additions if it isn't an entity associated
      // with this ManageableListPage.
      if (entity is! T) {
        return;
      }

      // If the index is < 0, it means entity isn't in the underlying data. This
      // can happen when multiple entity types are shown in the same list, such
      // as a list of baits that also shows bait categories, but categories that
      // aren't associated with any baits are hidden.
      var index = newItems.indexOf(entity);
      if (index >= 0) {
        _animatedList.insert(min(_animatedList.length, index), entity);
      }
    });
  }

  void _onEntityDeleted(dynamic entity) {
    _onEntityAddedOrDeleted((newItems) {
      if (entity is T) {
        _animatedList.removeAt(_animatedList.indexOf(entity));
      }
    });
  }

  void _onEntityAddedOrDeleted(void Function(List<T> newItems) animate) {
    // Get an updated item list. This includes the item added or deleted, and
    // any updates to dependency objects of T. Note that this should always be
    // done when something is added or removed so the animated list model is
    // always up to date.
    var newItems = widget.itemManager.loadItems(_searchText);

    if ((newItems.length - _animatedList.length).abs() > 1) {
      // There was more than 1 item added/deleted. This can happen in dynamic
      // type lists, like a bait list, when the last bait for a bait category
      // is removed or an entity that isn't type T is added (#492).
      _log.d("Multiple changes were made, reconciling items...");
      _animatedList.resetItems(newItems);
    } else {
      animate(newItems);
    }
  }

  void _onEntityUpdated(dynamic entity) {
    _syncAnimatedList();
  }
}

typedef OnPickedCallback<T> = bool Function(
    BuildContext context, Set<T> pickedItems);
typedef PickerContainsAllCallback<T> = bool Function(Set<T> selectedItems);

/// A convenience class for storing the properties related to when a
/// [ManageableListPage] is being used to pick items from a list.
///
/// Note that [T] must be of the same type as the associated
/// [ManageableListPage].
class ManageableListPagePickerSettings<T> {
  /// The title of the picker page when picking a single item.
  final Widget? title;

  /// The title of the picker page when picking a multiple items.
  final Widget? multiTitle;

  /// Invoked when picking has finished. Returning true will pop the picker
  /// from the current [Navigator]. [pickedItems] is guaranteed to have one
  /// and only one item if [isMulti] is false, otherwise includes all items that
  /// were picked. If [isRequired] is false, and "None" is selected,
  /// [pickedItems] is an empty [Set].
  final OnPickedCallback<T> onPicked;

  final Set<T> initialValues;
  final bool isMulti;

  /// When false (default), a "None" option is displayed at the top of the
  /// picker for single pickers, allowing users to "clear" the active selection,
  /// if there is one. If [isMulti] is true, a "Select all" or "Deselect all"
  /// checkbox option is displayed.
  final bool isRequired;

  /// A function that returns true if the given [selectedItems] contains all
  /// of the available options. If null, [Set.containsAll] is used. Note that
  /// this should only be used when [T] is [dynamic].
  ///
  /// This property only applies when [isMulti] is true.
  final PickerContainsAllCallback<T>? containsAll;

  final void Function(bool)? onPickedAll;

  ManageableListPagePickerSettings({
    required this.onPicked,
    this.title,
    this.multiTitle,
    this.initialValues = const {},
    this.isMulti = true,
    this.isRequired = false,
    this.containsAll,
    this.onPickedAll,
  });

  ManageableListPagePickerSettings.single({
    required bool Function(BuildContext, T?) onPicked,
    Widget? title,
    T? initialValue,
    bool isRequired = false,
  }) : this(
          onPicked: (context, items) =>
              onPicked(context, items.isEmpty ? null : items.first),
          initialValues: initialValue == null ? const {} : {initialValue},
          isMulti: false,
          isRequired: isRequired,
          containsAll: null,
          title: title,
        );

  ManageableListPagePickerSettings<T> copyWith({
    OnPickedCallback<T>? onPicked,
    Set<T>? initialValues,
    bool? isMulti,
    bool? isRequired,
    PickerContainsAllCallback<T>? containsAll,
    Widget? title,
    Widget? multiTitle,
    void Function(bool)? onPickedAll,
  }) {
    return ManageableListPagePickerSettings<T>(
      onPicked: onPicked ?? this.onPicked,
      initialValues: initialValues ?? this.initialValues,
      isMulti: isMulti ?? this.isMulti,
      isRequired: isRequired ?? this.isRequired,
      containsAll: containsAll ?? this.containsAll,
      title: title ?? this.title,
      multiTitle: multiTitle ?? this.multiTitle,
      onPickedAll: onPickedAll ?? this.onPickedAll,
    );
  }
}

/// A convenience class for storing the properties of an optional [SearchBar] in
/// the [AppBar] of a [ManageableListPage].
class ManageableListPageSearchDelegate {
  /// The search hint text.
  final String hint;

  ManageableListPageSearchDelegate({
    required this.hint,
  });
}

/// A convenient class for storing properties for a single item in a
/// [ManageableListPage].
@immutable
class ManageableListPageItemModel {
  /// True if this item can be edited; false otherwise. This may be false for
  /// section headers or dividers. Defaults to true.
  final bool isEditable;

  final bool isSelectable;

  /// The child of item. [Padding] is added automatically, as is a trailing
  /// [RightChevronIcon] or [CheckBox] depending on the situation. This
  /// is most commonly a [Text] widget.
  final Widget child;

  final Widget? grandchild;

  const ManageableListPageItemModel({
    required this.child,
    this.grandchild,
    this.isEditable = true,
    this.isSelectable = true,
  });
}

/// A convenient class for storing properties for related to a widget to show
/// when a [ManageableListPage] has an empty model list.
class ManageableListPageEmptyListSettings {
  final String title;
  final String description;
  final IconData icon;
  final IconData? descriptionIcon;

  ManageableListPageEmptyListSettings({
    required this.title,
    required this.description,
    required this.icon,
    this.descriptionIcon,
  });
}

/// A convenience class for storing properties related to adding, deleting, and
/// editing of items in a [ManageableListPage].
///
/// [T] is the type of object being managed, and must be the same type used
/// when instantiating [ManageableListPage].
class ManageableListPageItemManager<T> {
  /// Invoked when the widget tree needs to be rebuilt. Required so data is
  /// always the most up to date from the database. The passed in [String] is
  /// the text in the [SearchBar].
  ///
  /// Depending on context, it's possible non-model items are returned from this
  /// function, such as in [ReportListPage]. It's important to note that these
  /// non-model objects cannot be of type [Widget], otherwise they will not get
  /// rebuilt on entity changes. Instead, use a unique identifier, and return
  /// the widget in [ManageableListPage.itemBuilder].
  final List<T> Function(String?) loadItems;

  /// Settings used to populate a widget when [loadItems] returns an empty list.
  final ManageableListPageEmptyListSettings? emptyItemsSettings;

  /// The [Widget] to display is a delete confirmation dialog. This should be
  /// some kind of [Text] widget.
  ///
  /// If null, items cannot be deleted.
  final Widget Function(BuildContext, T)? deleteWidget;

  /// Invoked when the user confirms the delete operation. This method should
  /// actually delete the item [T] from the database.
  ///
  /// If null, items cannot be deleted.
  final void Function(BuildContext, T)? deleteItem;

  /// See [ManageableListItem.onTapDeleteButton].
  final bool Function(T)? onTapDeleteButton;

  /// Invoked when the "Add" button is pressed. The [Widget] returned by this
  /// function is presented in the current navigator.
  final Widget Function()? addPageBuilder;

  /// Invoked when the "Add" button is pressed. When non-null, [addPageBuilder]
  /// is ignored. Used to override the default behaviour of presenting the
  /// widget returned by [addPageBuilder].
  final VoidCallback? onAddButtonPressed;

  /// If non-null, will rebuild the [ManageableListPage] when one
  /// of the [EntityManager] objects is notified of updates. In most cases,
  /// this [List] will only have one value.
  final List<EntityManager> listenerManagers;

  /// If non-null, is invoked when an item is tapped while not in "editing"
  /// mode. The [Widget] returned by this function is pushed to the current
  /// navigator, and should be a page that shows details of [T].
  final Widget Function(T)? detailPageBuilder;

  /// If non-null, is invoked when an item is tapped while in "editing" mode.
  /// The [Widget] returned by this function is pushed to the current navigator,
  /// and should be a page that allows editing of [T].
  ///
  /// If null, editing is disabled for the [ManageableListPage].
  final Widget Function(T)? editPageBuilder;

  ManageableListPageItemManager({
    required this.loadItems,
    this.deleteWidget,
    this.deleteItem,
    this.emptyItemsSettings,
    this.addPageBuilder,
    this.onAddButtonPressed,
    this.listenerManagers = const [],
    this.editPageBuilder,
    this.detailPageBuilder,
    this.onTapDeleteButton,
  });
}

enum _ViewingState {
  pickingSingle,
  pickingMulti,
  viewing,
}
