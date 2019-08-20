import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/res/color.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  final AppManager _app = AppManager();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => Strings.of(context).appName,
      theme: ThemeData(
        primarySwatch: colorAppTheme,
        buttonTheme: ButtonThemeData(
          disabledColor: colorAppTheme.shade500,
        ),
        iconTheme: IconThemeData(
          color: colorAppTheme,
        ),
        errorColor: Colors.red,
      ),
      home: MainPage(_app),
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
    );
  }
}