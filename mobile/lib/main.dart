import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'auth_manager.dart';
import 'channels/migration_channel.dart';
import 'i18n/strings.dart';
import 'pages/landing_page.dart';
import 'pages/login_page.dart';
import 'pages/main_page.dart';
import 'pages/onboarding/onboarding_journey.dart';
import 'user_preference_manager.dart';
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
  late Future<bool> _appInitializedFuture;
  LegacyJsonResult? _legacyJsonResult;

  /// Used for showing the correct transition widget when logging in.
  var _wasLoggedOut = false;

  AppManager get _app => widget.appManager;
  AuthManager get _authManager => _app.authManager;
  ServicesWrapper get _services => _app.servicesWrapper;
  UserPreferenceManager get _userPreferencesManager =>
      _app.userPreferenceManager;

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
          primarySwatch: Colors.lightBlue,
          buttonTheme: ButtonThemeData(
            disabledColor: Colors.lightBlue.shade500,
          ),
          iconTheme: IconThemeData(
            color: Colors.lightBlue,
          ),
          errorColor: Colors.red,
        ),
        home: FutureBuilder<bool>(
          future: _appInitializedFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError || !snapshot.hasData) {
              return LandingPage();
            }
            return _authStreamBuilder();
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

  /// Returns a widget that listens for authentication changes.
  Widget _authStreamBuilder() {
    return StreamBuilder<void>(
      stream: _authManager.stream,
      builder: (context, _) {
        Widget? child;
        switch (_authManager.state) {
          case AuthState.unknown:
            child = LandingPage();
            break;
          case AuthState.loggedIn:
            if (_userPreferencesManager.didOnboard) {
              child = MainPage();
            } else {
              child = OnboardingJourney(
                legacyJsonResult: _legacyJsonResult,
                // Clear legacy result when migration has completed. This
                // prevents the migration page from showing when switching
                // users (see issue #502).
                onFinishedMigration: () => _legacyJsonResult = null,
                onFinished: () => setState(() {
                  _userPreferencesManager.didOnboard = true;
                }),
              );
            }
            break;
          case AuthState.loggedOut:
            _wasLoggedOut = true;
            child = LoginPage();
            break;
          case AuthState.initializing:
            if (_wasLoggedOut) {
              child = LoginPage();
            } else {
              child = LandingPage();
            }
            break;
        }

        return AnimatedSwitcher(
          duration: defaultAnimationDuration,
          child: child,
        );
      },
    );
  }

  Future<bool> _initialize() async {
    // Initialize managers that don't depend on authentication status.
    await _app.appPreferenceManager.initialize();
    await _app.firebaseWrapper.initializeApp();
    await _app.locationMonitor.initialize();
    await _app.propertiesManager.initialize();
    await _app.subscriptionManager.initialize();

    await _app.authManager.initialize();

    // If the user hasn't yet onboarded, see if there is any legacy data to
    // migrate. We do this here to allow for a smoother transition between the
    // login page and onboarding journey.
    if (!_userPreferencesManager.didOnboard) {
      _legacyJsonResult = await legacyJson(_services);
    }

    return true;
  }
}
