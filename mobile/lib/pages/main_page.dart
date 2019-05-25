import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/home_page.dart';
import 'package:mobile/pages/settings_page.dart';

class MainPage extends StatefulWidget {
  final AppManager app;

  MainPage(this.app);

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
  ];

  List<_BarItemData> get _navItems => [
    _BarItemData(
      page: _NavigatorPage(
        navigatorKey: _navStates[0],
        builder: (BuildContext context) => HomePage(),
      ),
      barItem: BottomNavigationBarItem(
        icon: Icon(Icons.home),
        title: Text("Home"),
      ),
    ),

    _BarItemData(
      page: _NavigatorPage(
        navigatorKey: _navStates[1],
        builder: (BuildContext context) => SettingsPage(widget.app),
      ),
      barItem: BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        title: Text(Strings.of(context).settingsPageTitle),
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
    );
  }
}