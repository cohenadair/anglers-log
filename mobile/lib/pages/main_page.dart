import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/gps_trail_manager.dart';
import 'package:mobile/poll_manager.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/trip_manager.dart';

import '../entity_manager.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/catch_list_page.dart';
import '../pages/more_page.dart';
import '../pages/stats_page.dart';
import '../subscription_manager.dart';
import '../time_manager.dart';
import '../user_preference_manager.dart';
import '../utils/date_time_utils.dart';
import '../utils/page_utils.dart';
import '../widgets/fishing_spot_map.dart';
import '../widgets/widget.dart';
import '../widgets/add_anything_bottom_sheet.dart';
import '../wrappers/in_app_review_wrapper.dart';
import 'pro_page.dart';

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  static const _log = Log("MainPage");

  // Only show the rate dialog if the user has created more than this number of
  // trigger-able entities.
  static const _rateDialogEntityThreshold = 3;

  int _currentBarItem = 1; // Default to the "Catches" tab.
  late List<_BarItemModel> _navItems;

  late final StreamSubscription<EntityEvent<Catch>> _catchManagerSub;
  late final StreamSubscription<EntityEvent<Trip>> _tripManagerSub;

  CatchManager get _catchManager => CatchManager.of(context);

  GpsTrailManager get _gpsTrailManager => GpsTrailManager.of(context);

  InAppReviewWrapper get _inAppReviewWrapper => InAppReviewWrapper.of(context);

  PollManager get _pollManager => PollManager.of(context);

  SubscriptionManager get _subscriptionManager =>
      SubscriptionManager.of(context);

  TimeManager get _timeManager => TimeManager.of(context);

  TripManager get _tripManager => TripManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

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

    _catchManagerSub = _catchManager.listen(EntityListener<Catch>(
      onAdd: (_) {
        if (_catchManager.entityCount >= _rateDialogEntityThreshold) {
          _showFeedbackDialogIfNeeded();
        }
      },
    ));
    _tripManagerSub = _tripManager.listen(EntityListener<Trip>(onAdd: (_) {
      if (_tripManager.entityCount >= _rateDialogEntityThreshold) {
        _showFeedbackDialogIfNeeded();
      }
    }));
  }

  @override
  void dispose() {
    _catchManagerSub.cancel();
    _tripManagerSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Ensure clicking the Android physical back button closes a pushed
      // page rather than the entire app, if possible.
      onWillPop: () async => !await _currentNavState.maybePop(),
      child: Scaffold(
        // An IndexedStack is an easy way to persist state when switching
        // between pages.
        body: IndexedStack(
          index: _currentBarItem,
          children:
              _navItems.map((data) => data.page ?? const Empty()).toList(),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: boxShadowDefault(context),
          ),
          child: BottomNavigationBar(
            selectedItemColor: context.colorDefault,
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
                setState(() => _currentBarItem = index);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMoreIcon() {
    return StreamBuilder<void>(
      stream: _pollManager.stream,
      builder: (context, _) => BadgeContainer(
        isBadgeVisible: _pollManager.canVote,
        child: const Icon(Icons.more_horiz),
      ),
    );
  }

  Widget _buildMapIcon() {
    return StreamBuilder<void>(
      stream: _gpsTrailManager.stream,
      builder: (context, _) => BadgeContainer(
        isBadgeVisible: _gpsTrailManager.hasActiveTrail,
        child: const Icon(Icons.map),
      ),
    );
  }

  void _showFeedbackDialogIfNeeded() {
    // Check if ProPage should be shown.
    if (_subscriptionManager.isFree &&
        isFrequencyTimerReady(
          timeManager: _timeManager,
          timerStartedAt: _userPreferenceManager.proTimerStartedAt,
          setTimer: _userPreferenceManager.setProTimerStartedAt,
          frequency: Duration.millisecondsPerDay * 7,
        )) {
      _userPreferenceManager
          .setProTimerStartedAt(_timeManager.currentTimestamp);
      present(context, const ProPage());
      return;
    }

    // Maybe show system's in-app review dialog.
    _inAppReviewWrapper.isAvailable().then((isAvailable) {
      if (isAvailable) {
        _inAppReviewWrapper.requestReview();
        _log.d("Requested review");
      }
    });
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
