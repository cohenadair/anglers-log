import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/res/color.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(new AnglersLog());
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
    _appInitializedFuture = Future.wait([
      _app.dataManager.initialize(_app),
      _app.locationMonitor.initialize(),
      _app.propertiesManager.initialize(),
    ]).then((_) async {
      // Initializations that depend on first initializations to be finished.
      return Future.wait([
        _app.baitCategoryManager.initialize(),
        _app.baitManager.initialize(),
        _app.catchManager.initialize(),
        _app.fishingSpotManager.initialize(),
        _app.imageManager.initialize(),
        _app.speciesManager.initialize(),
      ]).then((_) => true);
    });
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
}