import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
import 'auth_manager.dart';
import 'channels/migration_channel.dart';
import 'i18n/strings.dart';
import 'pages/landing_page.dart';
import 'pages/login_page.dart';
import 'pages/main_page.dart';
import 'pages/onboarding/onboarding_journey.dart';
import 'preferences_manager.dart';
import 'res/color.dart';
import 'widgets/widget.dart';
import 'wrappers/services_wrapper.dart';

void main() {
  runApp(AnglersLog(AppManager()));
}

class AnglersLog extends StatefulWidget {
  final AppManager appManager;

  AnglersLog(this.appManager);

  @override
  _AnglersLogState createState() => _AnglersLogState();
}

class _AnglersLogState extends State<AnglersLog> {
  Future<bool> _appInitializedFuture;
  LegacyJsonResult _legacyJsonResult;

  AppManager get _app => widget.appManager;
  AuthManager get _authManager => _app.authManager;
  PreferencesManager get _preferencesManager => _app.preferencesManager;
  ServicesWrapper get _services => _app.servicesWrapper;

  @override
  void initState() {
    super.initState();

    // Wait for all app initializations before showing the app as "ready".
    _appInitializedFuture = _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AppManager>.value(
      value: _app,
      child: MaterialApp(
        onGenerateTitle: (context) => Strings.of(context).appName,
        theme: ThemeData(
          primarySwatch: colorAppTheme,
          accentColor: colorAppTheme,
          buttonTheme: ButtonThemeData(
            disabledColor: colorAppTheme.shade500,
          ),
          iconTheme: IconThemeData(
            color: colorAppTheme,
          ),
          cupertinoOverrideTheme: CupertinoThemeData(
            // Gives TextField cursors a black tint in search bars.
            primaryColor: Colors.black,
          ),
          errorColor: Colors.red,
        ),
        home: FutureBuilder<bool>(
          future: _appInitializedFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError || !snapshot.hasData) {
              return LandingPage();
            }

            Widget firstPage;
            if (_preferencesManager.didOnboard) {
              firstPage = MainPage();
            } else {
              firstPage = OnboardingJourney(
                legacyJsonResult: _legacyJsonResult,
                onFinished: () => setState(() {
                  _preferencesManager.didOnboard = true;
                }),
              );
            }

            return authChangesListener(firstPage);
          },
        ),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          StringsDelegate(),
          DefaultMaterialLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en', 'US'),
          Locale('en', 'CA'),
        ],
      ),
    );
  }

  /// Returns a widget that listens for authentications changes.
  Widget authChangesListener(Widget authenticated) {
    return StreamBuilder<User>(
      stream: _authManager.authStateChanges,
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: defaultAnimationDuration,
          child: isNotEmpty(_authManager.userId) ? authenticated : LoginPage(),
        );
      },
    );
  }

  Future<bool> _initialize() async {
    await _app.firebaseWrapper.initializeApp();

    await _app.authManager.initialize();
    await _app.dataManager.initialize();
    await _app.locationMonitor.initialize();
    await _app.propertiesManager.initialize();

    // Managers that depend on the ones above.
    await _app.baitCategoryManager.initialize();
    await _app.baitManager.initialize();
    await _app.catchManager.initialize();
    await _app.comparisonReportManager.initialize();
    await _app.customEntityManager.initialize();
    await _app.fishingSpotManager.initialize();
    await _app.imageManager.initialize();
    await _app.preferencesManager.initialize();
    await _app.speciesManager.initialize();
    await _app.summaryReportManager.initialize();

    // If the user hasn't yet onboarded, see if there is any legacy data to
    // migrate. We do this here to allow for a smoother transition between the
    // login page and onboarding journey.
    if (!_preferencesManager.didOnboard) {
      _legacyJsonResult = await legacyJson(_services);
    }

    return true;
  }
}
