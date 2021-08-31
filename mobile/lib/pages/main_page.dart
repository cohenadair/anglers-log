import 'package:flutter/material.dart';

import '../catch_manager.dart';
import '../entity_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/catch_list_page.dart';
import '../pages/more_page.dart';
import '../pages/stats_page.dart';
import '../res/gen/custom_icons.dart';
import '../utils/dialog_utils.dart';
import '../utils/page_utils.dart';
import '../widgets/fishing_spot_map.dart';
import '../widgets/widget.dart';
import 'add_anything_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Need to stash a reference here so listeners can be removed when disposed.
  late CatchManager _catchManager;
  late EntityListener<Catch> _catchManagerListener;

  int _currentBarItem = 1; // Default to the "Catches" tab.
  late List<_BarItemData> _navItems;

  NavigatorState get _currentNavState {
    assert(_navItems[_currentBarItem].page?.navigatorKey.currentState != null);
    return _navItems[_currentBarItem].page!.navigatorKey.currentState!;
  }

  @override
  void initState() {
    super.initState();

    _navItems = [
      _BarItemData(
        page: _NavigatorPage(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context) => FishingSpotMap(),
        ),
        icon: Icons.map,
        titleBuilder: (context) => Strings.of(context).mapPageMenuLabel,
      ),
      _BarItemData(
        page: _NavigatorPage(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context) => CatchListPage(),
        ),
        icon: CustomIcons.catches,
        titleBuilder: (context) => Strings.of(context).catchListPageMenuLabel,
      ),
      _BarItemData(
        icon: Icons.add_box_rounded,
        titleBuilder: (context) => Strings.of(context).add,
        onTapOverride: () => fade(context, AddAnythingPage(), opaque: false),
      ),
      _BarItemData(
        page: _NavigatorPage(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context) => StatsPage(),
        ),
        icon: Icons.show_chart,
        titleBuilder: (context) => Strings.of(context).statsPageMenuTitle,
      ),
      _BarItemData(
        page: _NavigatorPage(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context) => MorePage(),
        ),
        icon: Icons.more_horiz,
        titleBuilder: (context) => Strings.of(context).morePageTitle,
      ),
    ];

    _catchManager = CatchManager.of(context);
    _catchManagerListener = SimpleEntityListener<Catch>(
      onAdd: (_) => showRateDialogIfNeeded(context),
    );
    _catchManager.addListener(_catchManagerListener);
  }

  @override
  void dispose() {
    super.dispose();
    _catchManager.removeListener(_catchManagerListener);
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      // Ensure clicking the Android physical back button closes a pushed page
      // rather than the entire app, if possible.
      onWillPop: () async => !await _currentNavState.maybePop(),
      child: Scaffold(
        // An IndexedStack is an easy way to persist state when switching
        // between pages.
        body: IndexedStack(
          index: _currentBarItem,
          children: _navItems.map((data) => data.page ?? Empty()).toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentBarItem,
          type: BottomNavigationBarType.fixed,
          items: _navItems
              .map(
                (data) => BottomNavigationBarItem(
                  icon: Icon(data.icon),
                  label: data.titleBuilder(context),
                ),
              )
              .toList(),
          onTap: (index) {
            if (_navItems[index].onTapOverride != null) {
              _navItems[index].onTapOverride!();
              return;
            }

            if (_currentBarItem == index) {
              // Reset navigation stack if already on the current item.
              _currentNavState.popUntil((r) => r.isFirst);
            } else {
              setState(() {
                _currentBarItem = index;
              });
            }
          },
        ),
      ),
    );
  }
}

class _BarItemData {
  final _NavigatorPage? page;
  final LocalizedString titleBuilder;
  final IconData icon;

  /// If set, overrides the default behaviour of showing the associated
  /// [Widget].
  final VoidCallback? onTapOverride;

  _BarItemData({
    this.page,
    required this.titleBuilder,
    required this.icon,
    this.onTapOverride,
  }) : assert(page != null || onTapOverride != null);
}

// TODO: Popping multiple pages had bad animation - https://github.com/flutter/flutter/issues/59990#issuecomment-697328406

/// A page with its own [Navigator]. Meant to be used in combination with a
/// [BottomNavigationBar] to persist back stack state when switching between
/// tabs.
class _NavigatorPage extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget Function(BuildContext) builder;

  _NavigatorPage({
    required this.navigatorKey,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) => MaterialPageRoute(
        settings: settings,
        builder: builder,
      ),
    );
  }
}
