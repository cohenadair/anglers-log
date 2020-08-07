import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/res/color.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(AnglersLog());
}

class AnglersLog extends StatefulWidget {
  @override
  _AnglersLogState createState() => _AnglersLogState();
}

class _AnglersLogState extends State<AnglersLog> {
  final AppManager _app = AppManager();
  Future<bool> _appInitializedFuture;

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
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasError || !snapshot.hasData) {
              return Scaffold(
                backgroundColor: Theme.of(context).primaryColor,
              );
            }
            return MainPage();
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

  Future<bool> _initialize() async {
    await _app.dataManager.initialize();
    await _app.locationMonitor.initialize();
    await _app.propertiesManager.initialize();

    // Managers that depend on the ones above.
    await _app.baitCategoryManager.initialize();
    await _app.baitManager.initialize();
    await _app.catchManager.initialize();
    await _app.customComparisonReportManager.initialize();
    await _app.customEntityManager.initialize();
    await _app.customEntityValueManager.initialize();
    await _app.customSummaryReportManager.initialize();
    await _app.fishingSpotManager.initialize();
    await _app.imageManager.initialize();
    await _app.preferencesManager.initialize();
    await _app.speciesManager.initialize();

    return true;
  }
}