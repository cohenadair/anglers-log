import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/pages/onboarding/change_log_page.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/wrappers/package_info_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:version/version.dart';

import 'app_manager.dart';
import 'channels/migration_channel.dart';
import 'i18n/sf_localizations_override.dart';
import 'i18n/strings.dart';
import 'log.dart';
import 'pages/landing_page.dart';
import 'pages/main_page.dart';
import 'pages/onboarding/onboarding_journey.dart';
import 'user_preference_manager.dart';
import 'utils/map_utils.dart';
import 'utils/trip_utils.dart';
import 'wrappers/services_wrapper.dart';

void main() async {
  const log = Log("main");

  void killReleaseApp() {
    if (kReleaseMode) {
      exit(1);
    }
  }

  WidgetsFlutterBinding.ensureInitialized();

  // Firebase.
  await Firebase.initializeApp();

  // Analytics.
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(kReleaseMode);

  // Crashlytics. See https://firebase.flutter.dev/docs/crashlytics/usage for
  // error handling guidelines.
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(kReleaseMode);

  // Catch Flutter errors.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    FirebaseCrashlytics.instance.recordFlutterError(details);
    log.d("Flutter error: $details");
    killReleaseApp();
  };

  // Catch non-Flutter errors.
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    await FirebaseCrashlytics.instance
        .recordError(pair.first, pair.last, fatal: true);
    log.d("Isolate error: ${pair.last}");
    killReleaseApp();
  }).sendPort);

  // Restrict orientation to portrait for devices with a small width. A width
  // of 740 is less than the smallest iPad, and most Android tablets.
  var view = WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
  if (view != null) {
    var size = MediaQueryData.fromView(view).size;
    if (min(size.width, size.height) < 740) {
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);
    }
  }

  runApp(AnglersLog(AppManager()));
}

class AnglersLog extends StatefulWidget {
  final AppManager appManager;

  const AnglersLog(this.appManager);

  @override
  AnglersLogState createState() => AnglersLogState();
}

class AnglersLogState extends State<AnglersLog> {
  late Future<bool> _appInitializedFuture;
  late _State _state;
  late StreamSubscription<String> _userPreferenceSub;
  LegacyJsonResult? _legacyJsonResult;

  AppManager get _appManager => widget.appManager;

  PackageInfoWrapper get _packageInfoWrapper => _appManager.packageInfoWrapper;

  ServicesWrapper get _servicesWrapper => _appManager.servicesWrapper;

  UserPreferenceManager get _userPreferenceManager =>
      _appManager.userPreferenceManager;

  @override
  void initState() {
    super.initState();

    // Wait for all app initializations before showing the app as "ready".
    _appInitializedFuture = _initialize();

    _userPreferenceSub = _userPreferenceManager.stream.listen((event) {
      if (event == UserPreferenceManager.keyThemeMode) {
        setState(() {});
        context.rebuildAllChildren();
      }
    });
  }

  @override
  void dispose() {
    _userPreferenceSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _appInitializedFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildMaterialApp(LandingPage(), null);
        }
        return _buildMaterialApp(
            _buildStartPage(), _userPreferenceManager.themeMode);
      },
    );
  }

  Widget _buildMaterialApp(Widget home, ThemeMode? themeMode) {
    return Provider<AppManager>.value(
      value: _appManager,
      child: MaterialApp(
        onGenerateTitle: (context) => Strings.of(context).appName,
        theme: themeLight(),
        darkTheme: themeDark(context),
        themeMode: themeMode,
        home: Builder(
          builder: (context) {
            return MediaQuery(
              // Don't allow font sizes too large. After the max, the app starts
              // to look very bad.
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(MediaQuery.of(context)
                    .textScaleFactor
                    .clamp(minTextScale, maxTextScale)),
              ),
              child: home,
            );
          },
        ),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          StringsDelegate(),
          const SfLocalizationsOverrideDelegate(),
          DefaultMaterialLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: Strings.supportedLocales,
      ),
    );
  }

  Widget _buildStartPage() {
    switch (_state) {
      case _State.mainPage:
        return MainPage();
      case _State.onboarding:
        return OnboardingJourney(
          legacyJsonResult: _legacyJsonResult,
          onFinished: () async {
            await _userPreferenceManager.setDidOnboard(true);
            await _userPreferenceManager.updateAppVersion();
            setState(() => _state = _State.mainPage);
          },
        );
      case _State.changeLog:
        return ChangeLogPage(
            onTapContinue: () => setState(() => _state = _State.mainPage));
    }
  }

  Future<bool> _initialize() async {
    await _appManager.initialize();

    if (await _shouldShowChangeLog()) {
      _state = _State.changeLog;
    } else if (_userPreferenceManager.didOnboard) {
      _state = _State.mainPage;
    } else {
      // If the user hasn't yet onboarded, see if there is any legacy data to
      // migrate. We do this here to allow for a smoother transition between the
      // login page and onboarding journey.
      _legacyJsonResult = await legacyJson(_servicesWrapper);
      _state = _State.onboarding;
    }

    return true;
  }

  Future<bool> _shouldShowChangeLog() async {
    // Never show a change log for brand new users.
    if (!_userPreferenceManager.didOnboard) {
      return false;
    }

    var oldVersion = _userPreferenceManager.appVersion;
    var newVersion = (await _packageInfoWrapper.fromPlatform()).version;
    var didUpdate = isEmpty(oldVersion) ||
        Version.parse(oldVersion!) < Version.parse(newVersion);

    // Sometimes we need to setup defaults values after the app is updated.
    // Do it here.
    if (didUpdate) {
      // TODO #800: Remove addition of GPS trails IDs when there are no more
      //  2.2.0 users.
      if (oldVersion == "2.2.0") {
        var currentIds = _userPreferenceManager.tripFieldIds;
        if (currentIds.isNotEmpty) {
          _userPreferenceManager
              .setTripFieldIds(currentIds..add(tripFieldIdGpsTrails));
        }
      }

      // TODO: Remove when there are no more 2.3.5 users.
      if (newVersion == "2.3.5") {
        // If the user hasn't specifically set their map type to satellite,
        // reset their selection so the correct dark/light map is used.
        var mapType = MapType.fromId(_userPreferenceManager.mapType);
        if (mapType != null && mapType != MapType.satellite) {
          _userPreferenceManager.setMapType(null);
        }
      }
    }

    return didUpdate;
  }
}

enum _State {
  mainPage,
  onboarding,
  changeLog,
}
