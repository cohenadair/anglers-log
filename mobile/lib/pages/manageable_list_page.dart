import 'package:flutter/material.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/search_timer.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/no_results.dart';
import 'package:mobile/widgets/search_bar.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

/// A page that is able to manage a list of a given type, [T]. The page includes
/// an optional [SearchBar] and can be used a single or multi-item picker.
class ManageableListPage<T> extends StatefulWidget {
  /// See [ManageableListPageItemModel].
  final ManageableListPageItemModel Function(BuildContext, T) itemBuilder;

  /// See [ManageableListPageItemManager].
  final ManageableListPageItemManager<T> itemManager;

  /// See [SliverAppBar.title].
  final Widget Function(List<T>) titleBuilder;

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
  ///
  /// See [ManageableListPageSinglePickerSettings].
  /// See [ManageableListPageMultiPickerSettings].
  final ManageableListPagePickerSettings<T> pickerSettings;

  /// If non-null, the [ManageableListPage] includes a [SearchBar] in the
  /// [AppBar].
  ///
  /// See [ManageableListPageSearchDelegate].
  final ManageableListPageSearchDelegate searchDelegate;

  ManageableListPage({
    @required this.itemManager,
    @required this.itemBuilder,
    this.titleBuilder,
    this.itemsHaveThumbnail = false,
    this.forceCenterTitle = false,
    this.pickerSettings,
    this.searchDelegate,
  }) : assert(itemBuilder != null),
       assert(itemManager != null);

  @override
  _ManageableListPageState<T> createState() => _ManageableListPageState<T>();
}

class _ManageableListPageState<T> extends State<ManageableListPage<T>> {
  final double _appBarExpandedHeight = 100.0;

  /// Additional padding required to line up search text with [ListItem] text.
  final double _thumbSearchTextOffset = 24.0;

  SearchTimer _searchTimer;
  bool _editing = false;
  Set<T> _selectedValues = {};
  _ViewingState _viewingState = _ViewingState.viewing;
  String _searchText;

  bool get _viewing => _viewingState == _ViewingState.viewing;
  bool get _pickingMulti => _viewingState == _ViewingState.pickingMulti;
  bool get _pickingSingle => _viewingState == _ViewingState.pickingSingle;
  bool get _hasSearch => widget.searchDelegate != null;
  bool get _hasDetailPage => widget.itemManager.detailPageBuilder != null;
  bool get _editable => widget.itemManager.editPageBuilder != null;
  bool get _addable => widget.itemManager.addPageBuilder != null;

  @override
  void initState() {
    super.initState();

    if (widget.pickerSettings != null) {
      _viewingState = widget.pickerSettings.multi
          ? _ViewingState.pickingMulti : _ViewingState.pickingSingle;
      _selectedValues = Set.of(widget.pickerSettings.initialValues);
    }

    _searchTimer = SearchTimer(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _searchTimer.finish();
  }

  Widget build(BuildContext context) {
    if (widget.itemManager?.listenerManagers == null) {
      return _buildScaffold(widget.itemManager.loadItems(_searchText));
    }

    return EntityListenerBuilder(
      managers: widget.itemManager.listenerManagers,
      builder: (context) =>
          _buildScaffold(widget.itemManager.loadItems(_searchText)),
    );
  }

  Widget _buildScaffold(List<T> items) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            forceElevated: true,
            floating: true,
            pinned: false,
            snap: true,
            title: widget.titleBuilder?.call(items),
            actions: _buildActions(),
            expandedHeight: _hasSearch ? _appBarExpandedHeight : 0.0,
            flexibleSpace: _buildSearchBar(),
            centerTitle: widget.forceCenterTitle,
          ),
          SliverSafeArea(
            top: false,
            sliver: SliverVisibility(
              visible: items.isNotEmpty,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildItem(context, items[i]),
                  childCount: items.length,
                ),
              ),
              replacementSliver: SliverToBoxAdapter(
                child: widget.searchDelegate == null
                    ? Empty()
                    : NoResults(widget.searchDelegate.noResultsMessage),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    if (!_hasSearch) {
      return null;
    }

    return FlexibleSpaceBar(
      background: Padding(
        padding: EdgeInsets.only(
          left: paddingDefault,
          right: paddingDefault,
          bottom: paddingSmall,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SearchBar(
            text: _searchText,
            hint: widget.searchDelegate.hint,
            leadingPadding: widget.itemsHaveThumbnail
                ? _thumbSearchTextOffset : null,
            elevated: false,
            delegate: InputSearchBarDelegate((String text) {
              _searchText = text;
              _searchTimer.reset(_searchText);
            }),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    List<Widget> result = [];

    if (_pickingMulti && _editable) {
      result..add(ActionButton.done(
        condensed: true,
        onPressed: () {
          if (_editing) {
            setEditingUpdateState(false);
          } else {
            _finishPicking(_selectedValues);
          }
        },
      ));

      // If picking multiple items, use overflow menu for "Add" and "Edit"
      // options.
      var optionBuilder = (context) {
        List<PopupMenuItem<_OverflowOption>> overflowOptions = [];
        if (_addable) {
          overflowOptions.add(PopupMenuItem<_OverflowOption>(
            value: _OverflowOption.add,
            child: Text(Strings.of(context).add),
          ));
        }

        overflowOptions.add(PopupMenuItem<_OverflowOption>(
          value: _OverflowOption.edit,
          child: Text(Strings.of(context).edit),
          enabled: !_editing,
        ));

        return overflowOptions;
      };

      result..add(PopupMenuButton<_OverflowOption>(
        icon: Icon(Icons.more_vert),
        itemBuilder: optionBuilder,
        onSelected: (option) {
          switch (option) {
            case _OverflowOption.add:
              present(context, widget.itemManager.addPageBuilder());
              break;
            case _OverflowOption.edit:
              setEditingUpdateState(true);
              break;
          }
        },
      ));
    } else {
      if (_editing) {
        result.add(ActionButton.done(
          condensed: _addable,
          onPressed: () => setEditingUpdateState(false),
        ));
      } else if (_editable) {
        // Only include the edit button if the items can be modified.
        result.add(ActionButton.edit(
          condensed: _addable,
          onPressed: () => setEditingUpdateState(true),
        ));
      }

      // Only include the add button if new items can be added.
      if (_addable) {
        result.add(IconButton(
          icon: Icon(Icons.add),
          onPressed: () =>
              present(context, widget.itemManager.addPageBuilder()),
        ));
      }
    }

    return result;
  }

  Widget _buildItem(BuildContext context, T itemValue) {
    ManageableListPageItemModel item = widget.itemBuilder(context, itemValue);

    if (!item.editable && !item.selectable) {
      // If this item can't be edited or selected, return it; we don't want
      // to use a ManageableListItem.
      return item.child;
    }

    Widget trailing = RightChevronIcon();
    if (_pickingMulti) {
      trailing = PaddedCheckbox(
        checked: _selectedValues.contains(itemValue),
        onChanged: (checked) {
          setState(() {
            if (_selectedValues.contains(itemValue)) {
              _selectedValues.remove(itemValue);
            } else {
              _selectedValues.add(itemValue);
            }
          });
        },
      );
    } else if (_pickingSingle || widget.itemManager.detailPageBuilder == null) {
      // Don't show detail disclosure indicator if we're picking a single
      // value, or if there isn't any detail to show.
      trailing = _selectedValues.contains(itemValue)
          ? Icon(Icons.check) : Empty();
    }

    bool canEdit = _editing && item.editable;
    bool enabled = !_editing || canEdit;

    return ManageableListItem(
      child: item.child,
      editing: canEdit,
      enabled: enabled,
      deleteMessageBuilder: (context) =>
          widget.itemManager.deleteText(context, itemValue),
      onConfirmDelete: () => widget.itemManager.deleteItem(context, itemValue),
      onTap: !enabled || (_viewing && !_hasDetailPage && !canEdit) ? null : () {
        if (_pickingMulti && !canEdit) {
          // Taps are consumed by trailing checkbox in this case.
          return;
        }

        if (canEdit) {
          push(context, widget.itemManager.editPageBuilder(itemValue));
        } else if (_pickingSingle) {
          _finishPicking({itemValue});
        } else if (widget.itemManager.detailPageBuilder != null) {
          push(context, widget.itemManager.detailPageBuilder(itemValue));
        }
      },
      onTapDeleteButton: widget.itemManager.onTapDeleteButton == null
          ? null
          : () => widget.itemManager.onTapDeleteButton(itemValue),
      trailing: trailing,
    );
  }

  void setEditingUpdateState(bool editing) => setState(() {
    _editing = editing;
  });

  void _finishPicking(Set<T> pickedValues) {
    if (widget.pickerSettings.onPicked(context, pickedValues)) {
      Navigator.of(context).pop();
    }
  }
}

enum _ViewingState {
  pickingSingle, pickingMulti, viewing
}

class ManageableListPagePickerSettings<T> {
  final Set<T> initialValues;
  final bool multi;

  /// Invoked when picking has finished. Returning true will pop the picker
  /// from the current [Navigator]. [pickedItems] is guaranteed to have on
  /// and only one item if [multi] is true, otherwise includes all items that
  /// were picked.
  final bool Function(BuildContext context, Set<T> pickedItems) onPicked;

  ManageableListPagePickerSettings({
    @required this.onPicked,
    Set<T> initialValues,
    this.multi = false,
  }) : assert(onPicked != null),
       initialValues = initialValues ?? const {};
}

/// A convenience class for storing the properties of an option [SearchBar] in
/// the [AppBar] of a [ManageableListPage].
class ManageableListPageSearchDelegate {
  /// The search hint text.
  final String hint;

  /// The message to show when searching returns 0 results.
  final String noResultsMessage;

  ManageableListPageSearchDelegate({
    @required this.hint,
    @required this.noResultsMessage,
  }) : assert(isNotEmpty(hint)),
       assert(isNotEmpty(noResultsMessage));
}

/// A convenient class for storing properties for a single item in a
/// [ManageableListPage].
class ManageableListPageItemModel {
  /// True if this item can be edited; false otherwise. This may be false for
  /// section headers or dividers. Defaults to true.
  final bool editable;

  final bool selectable;

  /// The child of item. [Padding] is added automatically, as is a trailing
  /// [RightChevronIcon] or [CheckBox] depending on the situation. This
  /// is most commonly a [Text] widget.
  final Widget child;

  ManageableListPageItemModel({
    @required this.child,
    this.editable = true,
    this.selectable = true,
  }) : assert(child != null);
}

/// A convenience class to handle the adding, deleting, and editing of an item
/// in a [ManageableListPage].
///
/// [T] is the type of object being managed.
class ManageableListPageItemManager<T> {
  /// Invoked when the widget tree needs to be rebuilt. Required so data is
  /// almost the most up to date from the database. The passed in [String] is
  /// the text in the [SearchBar].
  final List<T> Function(String) loadItems;

  /// The [Widget] to display is a delete confirmation dialog. This should be
  /// some kind of [Text] widget.
  final Widget Function(BuildContext, T) deleteText;

  /// Invoked when the user confirms the delete operation. This method should
  /// actually delete the item [T] from the database.
  final void Function(BuildContext, T) deleteItem;

  /// See [ManageableListItem.onTapDeleteButton].
  final VoidCallback Function(T) onTapDeleteButton;

  /// Invoked when the "Add" button is pressed. The [Widget] returned by this
  /// function is presented in the current navigator.
  final Widget Function() addPageBuilder;

  /// If non-null, will rebuild the [ManageableListPage] when one
  /// of the [EntityManager] objects is notified of updates. In most cases,
  /// this [List] will only have one value.
  final List<EntityManager> listenerManagers;

  /// If non-null, is invoked when an item is tapped while not in "editing"
  /// mode. The [Widget] returned by this function is pushed to the current
  /// navigator, and should be a page that shows details of [T].
  final Widget Function(T) detailPageBuilder;

  /// If non-null, is invoked when an item is tapped while in "editing" mode.
  /// The [Widget] returned by this function is pushed to the current navigator,
  /// and should be a page that allows editing of [T].
  ///
  /// If null, editing is disabled for the [ManageableListPage].
  final Widget Function(T) editPageBuilder;

  ManageableListPageItemManager({
    @required this.loadItems,
    @required this.deleteText,
    @required this.deleteItem,
    this.addPageBuilder,
    this.listenerManagers,
    this.editPageBuilder,
    this.detailPageBuilder,
    this.onTapDeleteButton,
  }) : assert(loadItems != null),
       assert(deleteText != null),
       assert(deleteItem != null),
       assert(listenerManagers == null || listenerManagers.isNotEmpty);
}

enum _OverflowOption {
  add, edit
}