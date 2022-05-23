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
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'channels/migration_channel.dart';
import 'i18n/strings.dart';
import 'log.dart';
import 'pages/landing_page.dart';
import 'pages/main_page.dart';
import 'pages/onboarding/onboarding_journey.dart';
import 'user_preference_manager.dart';
import 'wrappers/services_wrapper.dart';

void main() {
  const log = Log("main");

  void killReleaseApp() {
    if (kReleaseMode) {
      exit(1);
    }
  }

  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Ads.
    await MobileAds.instance.initialize();

    // Firebase.
    await Firebase.initializeApp();

    // Analytics.
    await FirebaseAnalytics.instance
        .setAnalyticsCollectionEnabled(kReleaseMode);

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
    var size = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size;
    if (min(size.width, size.height) < 740) {
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);
    }

    runApp(AnglersLog(AppManager()));
  }, (error, stack) {
    // Catch zoned errors (i.e. calls to platform channels).
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    log.d("Zoned error: $stack");
    killReleaseApp();
  });
}

class AnglersLog extends StatefulWidget {
  final AppManager appManager;

  const AnglersLog(this.appManager);

  @override
  AnglersLogState createState() => AnglersLogState();
}

class AnglersLogState extends State<AnglersLog> {
  static const _minTextScale = 1.0;
  static const _maxTextScale = 1.35;

  late Future<bool> _appInitializedFuture;
  LegacyJsonResult? _legacyJsonResult;

  AppManager get _appManager => widget.appManager;

  ServicesWrapper get _servicesWrapper => _appManager.servicesWrapper;

  UserPreferenceManager get _userPreferencesManager =>
      _appManager.userPreferenceManager;

  @override
  void initState() {
    super.initState();

    // Wait for all app initializations before showing the app as "ready".
    _appInitializedFuture = _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AppManager>.value(
      value: _appManager,
      child: MaterialApp(
        onGenerateTitle: (context) => Strings.of(context).appName,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          buttonTheme: ButtonThemeData(
            disabledColor: Colors.lightBlue.shade500,
          ),
          iconTheme: const IconThemeData(
            color: Colors.lightBlue,
          ),
          errorColor: Colors.red,
        ),
        home: FutureBuilder<bool>(
          future: _appInitializedFuture,
          builder: (context, snapshot) {
            Widget child;

            if (snapshot.hasError || !snapshot.hasData) {
              child = LandingPage();
            } else if (_userPreferencesManager.didOnboard) {
              child = MainPage();
            } else {
              child = OnboardingJourney(
                legacyJsonResult: _legacyJsonResult,
                onFinished: () => _userPreferencesManager
                    .setDidOnboard(true)
                    .then((value) => setState(() {})),
              );
            }

            return MediaQuery(
              // Don't allow font sizes too large. After 1.35, the app starts to
              // look very bad.
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: MediaQuery.of(context)
                    .textScaleFactor
                    .clamp(_minTextScale, _maxTextScale),
              ),
              child: child,
            );
          },
        ),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          StringsDelegate(),
          DefaultMaterialLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: Strings.supportedLocales,
      ),
    );
  }

  Future<bool> _initialize() async {
    await _appManager.initialize();

    // If the user hasn't yet onboarded, see if there is any legacy data to
    // migrate. We do this here to allow for a smoother transition between the
    // login page and onboarding journey.
    if (!_userPreferencesManager.didOnboard) {
      _legacyJsonResult = await legacyJson(_servicesWrapper);
    }

    return true;
  }
}
