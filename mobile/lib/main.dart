import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/res/color.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => Strings.of(context).appName,
      theme: ThemeData(
        primarySwatch: colorAppTheme,
        buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.primary,
        ),
        iconTheme: IconThemeData(
          color: colorAppTheme,
        ),
        errorColor: Colors.red,
      ),
      home: MainPage(),
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