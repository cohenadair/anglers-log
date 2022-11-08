import 'package:flutter/material.dart';
import 'package:mobile/gps_trail_manager.dart';
import 'package:mobile/poll_manager.dart';

import '../i18n/strings.dart';
import '../pages/catch_list_page.dart';
import '../pages/more_page.dart';
import '../pages/stats_page.dart';
import '../widgets/fishing_spot_map.dart';
import '../widgets/widget.dart';
import '../widgets/add_anything_bottom_sheet.dart';

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _currentBarItem = 1; // Default to the "Catches" tab.
  late List<_BarItemModel> _navItems;

  GpsTrailManager get _gpsTrailManager => GpsTrailManager.of(context);

  PollManager get _pollManager => PollManager.of(context);

  NavigatorState get _currentNavState {
    assert(_navItems[_currentBarItem].page?.navigatorKey.currentState != null);
    return _navItems[_currentBarItem].page!.navigatorKey.currentState!;
  }

  @override
  void initState() {
    super.initState();

    _navItems = [
      _BarItemModel(
        page: _NavigatorPage(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context) => FishingSpotMap(showGpsTrailButton: true),
        ),
        iconBuilder: _buildMapIcon,
        titleBuilder: (context) => Strings.of(context).mapPageMenuLabel,
      ),
      _BarItemModel(
        page: _NavigatorPage(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context) => const CatchListPage(),
        ),
        iconBuilder: () => const Icon(iconCatch),
        titleBuilder: (context) => Strings.of(context).entityNameCatches,
      ),
      _BarItemModel(
        iconBuilder: () => const Icon(iconBottomBarAdd),
        titleBuilder: (context) => Strings.of(context).add,
        onTapOverride: () => showAddAnythingBottomSheet(context)
            .then((spec) => spec?.presentSavePage(context)),
      ),
      _BarItemModel(
        page: _NavigatorPage(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context) => StatsPage(),
        ),
        iconBuilder: () => const Icon(Icons.show_chart),
        titleBuilder: (context) => Strings.of(context).statsPageMenuTitle,
      ),
      _BarItemModel(
        page: _NavigatorPage(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context) => const MorePage(),
        ),
        iconBuilder: _buildMoreIcon,
        titleBuilder: (context) => Strings.of(context).morePageTitle,
      ),
    ];
  }

  @override
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
          children:
              _navItems.map((data) => data.page ?? const Empty()).toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentBarItem,
          type: BottomNavigationBarType.fixed,
          items: _navItems
              .map(
                (data) => BottomNavigationBarItem(
                  icon: data.iconBuilder(),
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

  Widget _buildMoreIcon() {
    return StreamBuilder<void>(
      stream: _pollManager.stream,
      builder: (context, _) => BadgeContainer(
        child: const Icon(Icons.more_horiz),
        isBadgeVisible: _pollManager.canVote,
      ),
    );
  }

  Widget _buildMapIcon() {
    return StreamBuilder<void>(
      stream: _gpsTrailManager.stream,
      builder: (context, _) => BadgeContainer(
        child: const Icon(Icons.map),
        isBadgeVisible: _gpsTrailManager.hasActiveTrail,
      ),
    );
  }
}

class _BarItemModel {
  final _NavigatorPage? page;
  final LocalizedString titleBuilder;
  final Widget Function() iconBuilder;

  /// If set, overrides the default behaviour of showing the associated
  /// [Widget].
  final VoidCallback? onTapOverride;

  _BarItemModel({
    this.page,
    required this.titleBuilder,
    required this.iconBuilder,
    this.onTapOverride,
  }) : assert(page != null || onTapOverride != null);
}

// TODO: Popping multiple pages has bad animation - https://github.com/flutter/flutter/issues/59990#issuecomment-697328406

/// A page with its own [Navigator]. Meant to be used in combination with a
/// [BottomNavigationBar] to persist back stack state when switching between
/// tabs.
class _NavigatorPage extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget Function(BuildContext) builder;

  const _NavigatorPage({
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
