import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/pages/map_page.dart';
import 'package:mobile/pages/more_page.dart';
import 'package:mobile/pages/photos_page.dart';
import 'package:mobile/pages/stats_page.dart';
import 'package:mobile/res/gen/custom_icons.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentBarItem = 0;

  // Keep reference to states so navigation stack is persisted when switching
  // tabs.
  List<GlobalKey<NavigatorState>> _navStates = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  List<_BarItemData> get _navItems => [
    _BarItemData(
      page: _NavigatorPage(
        navigatorKey: _navStates[0],
        builder: (BuildContext context) => PhotosPage(),
      ),
      barItem: BottomNavigationBarItem(
        icon: Icon(Icons.photo_library),
        title: Text(Strings.of(context).photosPageMenuLabel),
      ),
    ),

    _BarItemData(
      page: _NavigatorPage(
        navigatorKey: _navStates[1],
        builder: (BuildContext context) => CatchListPage(),
      ),
      barItem: BottomNavigationBarItem(
        icon: Icon(CustomIcons.catches),
        title: Text(Strings.of(context).catchListPageMenuLabel),
      ),
    ),

    _BarItemData(
      page: _NavigatorPage(
        navigatorKey: _navStates[2],
        builder: (BuildContext context) => MapPage(),
      ),
      barItem: BottomNavigationBarItem(
        icon: Icon(Icons.map),
        title: Text(Strings.of(context).mapPageMenuLabel),
      ),
    ),

    _BarItemData(
      page: _NavigatorPage(
        navigatorKey: _navStates[3],
        builder: (BuildContext context) => StatsPage(),
      ),
      barItem: BottomNavigationBarItem(
        icon: Icon(Icons.show_chart),
        title: Text(Strings.of(context).statsPageTitle),
      ),
    ),

    _BarItemData(
      page: _NavigatorPage(
        navigatorKey: _navStates[4],
        builder: (BuildContext context) => MorePage(),
      ),
      barItem: BottomNavigationBarItem(
        icon: Icon(Icons.more_horiz),
        title: Text(Strings.of(context).morePageTitle),
      ),
    ),
  ];

  Widget build(BuildContext context) {
    final navItems = _navItems;

    return WillPopScope(
      // Ensure clicking the Android physical back button closes a pushed page
      // rather than the entire app, if possible.
      onWillPop: () async =>
          !await _navStates[_currentBarItem].currentState.maybePop(),
      child: Scaffold(
        // An IndexedStack is an easy way to persist state when switching
        // between pages.
        body: IndexedStack(
          index: _currentBarItem,
          children: navItems.map((_BarItemData data) => data.page).toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentBarItem,
          type: BottomNavigationBarType.fixed,
          items: navItems.map((_BarItemData data) => data.barItem).toList(),
          onTap: (index) {
            if (_currentBarItem == index) {
              // Reset navigation stack if already on the current item.
              _navStates[_currentBarItem].currentState
                  .popUntil((r) => r.isFirst);
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
  final _NavigatorPage page;
  final BottomNavigationBarItem barItem;

  _BarItemData({
    @required this.page,
    @required this.barItem,
  });
}

/// A page with its own [Navigator]. Meant to be used in combination with a
/// [BottomNavigationBar] to persist back stack state when switching between
/// tabs.
class _NavigatorPage extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget Function(BuildContext) builder;

  _NavigatorPage({
    this.navigatorKey,
    @required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
        settings: settings,
        builder: builder,
      ),
      observers: [
        HeroController(),
      ],
    );
  }
}