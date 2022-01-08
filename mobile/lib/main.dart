import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

  ServicesWrapper get _services => _appManager.servicesWrapper;

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
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('en', 'CA'),
        ],
      ),
    );
  }

  Future<bool> _initialize() async {
    // Managers that don't depend on anything.
    await _appManager.locationMonitor.initialize();
    await _appManager.propertiesManager.initialize();
    await _appManager.subscriptionManager.initialize();

    // Need to initialize the local database before anything else, since all
    // entity managers depend on the local database.
    await _appManager.localDatabaseManager.initialize();

    // UserPreferenceManager includes "pro" override and needs to be initialized
    // before managers that upload data to Firebase.
    await _appManager.userPreferenceManager.initialize();

    await _appManager.anglerManager.initialize();
    await _appManager.baitCategoryManager.initialize();
    await _appManager.baitManager.initialize();
    await _appManager.bodyOfWaterManager.initialize();
    await _appManager.catchManager.initialize();
    await _appManager.customEntityManager.initialize();
    await _appManager.fishingSpotManager.initialize();
    await _appManager.methodManager.initialize();
    await _appManager.reportManager.initialize();
    await _appManager.speciesManager.initialize();
    await _appManager.tripManager.initialize();
    await _appManager.waterClarityManager.initialize();

    // Ensure everything is initialized before managing any image state.
    await _appManager.imageManager.initialize();

    // If the user hasn't yet onboarded, see if there is any legacy data to
    // migrate. We do this here to allow for a smoother transition between the
    // login page and onboarding journey.
    if (!_userPreferencesManager.didOnboard) {
      _legacyJsonResult = await legacyJson(_services);
    }

    return true;
  }
}
