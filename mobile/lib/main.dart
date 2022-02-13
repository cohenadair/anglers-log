import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'channels/migration_channel.dart';
import 'i18n/strings.dart';
import 'pages/landing_page.dart';
import 'pages/main_page.dart';
import 'pages/onboarding/onboarding_journey.dart';
import 'user_preference_manager.dart';
import 'wrappers/services_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(AnglersLog(AppManager()));
}

class AnglersLog extends StatefulWidget {
  final AppManager appManager;

  const AnglersLog(this.appManager);

  @override
  _AnglersLogState createState() => _AnglersLogState();
}

class _AnglersLogState extends State<AnglersLog> {
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
            if (snapshot.hasError || !snapshot.hasData) {
              return LandingPage();
            } else if (_userPreferencesManager.didOnboard) {
              return MainPage();
            } else {
              return OnboardingJourney(
                legacyJsonResult: _legacyJsonResult,
                onFinished: () => _userPreferencesManager
                    .setDidOnboard(true)
                    .then((value) => setState(() {})),
              );
            }
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
