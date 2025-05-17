import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/onboarding/change_log_page.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/utils/trip_utils.dart';
import 'package:mobile/utils/widget_utils.dart';
import 'package:mobile/wrappers/crashlytics_wrapper.dart';
import 'package:mobile/wrappers/package_info_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:version/version.dart';

import 'app_manager.dart';
import 'channels/migration_channel.dart';
import 'i18n/sf_localizations_override.dart';
import 'i18n/strings.dart';
import 'pages/landing_page.dart';
import 'pages/main_page.dart';
import 'pages/onboarding/onboarding_journey.dart';
import 'pages/save_bait_variant_page.dart';
import 'user_preference_manager.dart';
import 'wrappers/services_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase.
  await Firebase.initializeApp();

  // Analytics.
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(kReleaseMode);

  // Crashlytics.
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(kReleaseMode);
  await FirebaseCrashlytics.instance
      .setCustomKey("Locale", PlatformDispatcher.instance.locale.toString());

  // Catch Flutter errors.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Catch platform errors.
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Catch non-Flutter errors.
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    await FirebaseCrashlytics.instance
        .recordError(pair.first, pair.last, fatal: true);
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

  runApp(const AnglersLog());
}

class AnglersLog extends StatefulWidget {
  const AnglersLog();

  @override
  AnglersLogState createState() => AnglersLogState();
}

class AnglersLogState extends State<AnglersLog> {
  late final Future<bool> _appInitializedFuture = _initialize();
  late _State _state;
  late StreamSubscription<String> _userPreferenceSub;
  LegacyJsonResult? _legacyJsonResult;

  CatchManager get _catchManager => AppManager.get.catchManager;

  PackageInfoWrapper get _packageInfoWrapper =>
      AppManager.get.packageInfoWrapper;

  ServicesWrapper get _servicesWrapper => AppManager.get.servicesWrapper;

  TripManager get _tripManager => AppManager.get.tripManager;

  @override
  void initState() {
    super.initState();

    _userPreferenceSub = UserPreferenceManager.get.stream.listen((event) {
      if (event == UserPreferenceManager.keyThemeMode) {
        setState(() {});
        safeUseContext(this, () => context.rebuildAllChildren());
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => Strings.of(context).appName,
      theme: themeLight(),
      darkTheme: themeDark(context),
      themeMode: UserPreferenceManager.get.themeMode,
      localizationsDelegates: [
        StringsDelegate(),
        const SfLocalizationsOverrideDelegate(),
        DefaultMaterialLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: Strings.supportedLocales,
      home: Provider<AppManager>.value(
        value: AppManager.get,
        child: FutureBuilder(
          future: _appInitializedFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // Something went wrong, log to Firebase (user is shown an error
              // on LoadingPage below).
              CrashlyticsWrapper.of(context).recordError(
                snapshot.error,
                snapshot.stackTrace,
                reason: "app initialization",
                fatal: true,
              );
            }

            return MediaQuery(
              // Don't allow font sizes too large. After the max, the app starts
              // to look very bad.
              data: MediaQuery.of(context).copyWith(
                textScaler: MediaQuery.of(context).textScaler.clamp(
                    minScaleFactor: minTextScale, maxScaleFactor: maxTextScale),
              ),
              child: snapshot.hasError || !snapshot.hasData
                  ? LandingPage(hasError: snapshot.hasError)
                  : _buildStartPage(),
            );
          },
        ),
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
          onFinished: (_) async {
            await UserPreferenceManager.get.setDidOnboard(true);
            await UserPreferenceManager.get.updateAppVersion();
            setState(() => _state = _State.mainPage);
          },
        );
      case _State.changeLog:
        return ChangeLogPage(
            onTapContinue: (_) => setState(() => _state = _State.mainPage));
    }
  }

  Future<bool> _initialize() async {
    await AppManager.get.init();

    if (await _shouldShowChangeLog()) {
      _state = _State.changeLog;
    } else if (UserPreferenceManager.get.didOnboard) {
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
    if (!UserPreferenceManager.get.didOnboard) {
      return false;
    }

    var oldVersion = UserPreferenceManager.get.appVersion;
    var newVersion = (await _packageInfoWrapper.fromPlatform()).version;
    var didUpdate = isEmpty(oldVersion) ||
        Version.parse(oldVersion!) < Version.parse(newVersion);

    // Sometimes we need to setup defaults values after the app is updated.
    // Do it here.
    if (didUpdate) {
      // TODO: Remove when there are no more 2.7.0 users.
      // Ensure bait variant photo field is shown.
      if (oldVersion == "2.6.0" &&
          UserPreferenceManager.get.baitVariantFieldIds.isNotEmpty) {
        UserPreferenceManager.get.setBaitVariantFieldIds(
            UserPreferenceManager.get.baitVariantFieldIds
              ..add(SaveBaitVariantPageState.imageFieldId));
      }

      // TODO: Remove when there are no more 2.7.0 users.
      // Ensure new trip fields are shown by default.
      if (oldVersion == "2.6.0" &&
          UserPreferenceManager.get.tripFieldIds.isNotEmpty) {
        UserPreferenceManager.get.setTripFieldIds(
          UserPreferenceManager.get.tripFieldIds
            ..addAll([
              tripFieldIdWaterClarity,
              tripFieldIdWaterDepth,
              tripFieldIdWaterTemperature
            ]),
        );
      }

      // TODO: Remove when there are no more 2.7.0 users.
      // Migrate tide deprecations.
      // ignore_for_file: deprecated_member_use_from_same_package
      for (var cat in _catchManager.list()) {
        if (!cat.hasTide()) {
          continue;
        }

        var changed = false;

        if (cat.tide.hasFirstLowTimestamp()) {
          cat.tide.firstLowHeight = Tide_Height(
            timestamp: cat.tide.firstLowTimestamp,
          );
          cat.tide.clearFirstLowTimestamp();
          changed = true;
        }

        if (cat.tide.hasFirstHighTimestamp()) {
          cat.tide.firstHighHeight = Tide_Height(
            timestamp: cat.tide.firstHighTimestamp,
          );
          cat.tide.clearFirstHighTimestamp();
          changed = true;
        }

        if (cat.tide.hasSecondLowTimestamp()) {
          cat.tide.secondLowHeight = Tide_Height(
            timestamp: cat.tide.secondLowTimestamp,
          );
          cat.tide.clearSecondLowTimestamp();
          changed = true;
        }

        if (cat.tide.hasSecondHighTimestamp()) {
          cat.tide.secondHighHeight = Tide_Height(
            timestamp: cat.tide.secondHighTimestamp,
          );
          cat.tide.clearSecondHighTimestamp();
          changed = true;
        }

        if (changed) {
          await _catchManager.addOrUpdate(cat, setImages: false);
        }
      }

      // TODO: Remove when there are no more 2.7.5 users.
      await _fixWaterTemperatureSystem();
    }

    return didUpdate;
  }

  /// Ensure water temperature imperial system is set correctly. Desired
  /// value is imperial_decimal (as done on UnitsPage); however,
  /// UserPreferenceManager was defaulting to imperial_whole, causing
  /// erroneous rounding.
  ///
  /// See https://github.com/cohenadair/anglers-log/issues/976.
  Future<void> _fixWaterTemperatureSystem() async {
    if (UserPreferenceManager.get.waterTemperatureSystem ==
        MeasurementSystem.imperial_whole) {
      await UserPreferenceManager.get
          .setWaterTemperatureSystem(MeasurementSystem.imperial_decimal);
    }

    bool updateWaterTempSystem(MultiMeasurement waterTemp) {
      if (waterTemp.system == MeasurementSystem.imperial_whole) {
        waterTemp.system = MeasurementSystem.imperial_decimal;
        return true;
      }
      return false;
    }

    for (var cat in _catchManager.list()) {
      if (cat.hasWaterTemperature() &&
          updateWaterTempSystem(cat.waterTemperature)) {
        await _catchManager.addOrUpdate(cat, setImages: false);
      }
    }

    for (var trip in _tripManager.list()) {
      if (trip.hasWaterTemperature() &&
          updateWaterTempSystem(trip.waterTemperature)) {
        await _tripManager.addOrUpdate(trip, setImages: false);
      }
    }
  }
}

enum _State {
  mainPage,
  onboarding,
  changeLog,
}
