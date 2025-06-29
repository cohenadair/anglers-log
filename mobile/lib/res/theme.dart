import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/user_preference_manager.dart';

// TODO: This is just small enough so the "EDIT" action bar button doesn't wrap.
//  Should investigate whether the button can be made larger.
const maxTextScale = 1.28;
const minTextScale = 1.0;

ThemeData themeLight() {
  return ThemeData(
    useMaterial3: false,
    buttonTheme: ButtonThemeData(
      disabledColor: Colors.lightBlue.shade500,
    ),
    iconTheme: const IconThemeData(
      color: Colors.lightBlue,
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.lightBlue)
        .copyWith(error: Colors.red),
  );
}

ThemeData themeDark(BuildContext context) {
  return ThemeData.dark(useMaterial3: false).copyWith(
    inputDecorationTheme: inputTheme(context),
    textSelectionTheme: textSelectionTheme(context),
    textButtonTheme: textButtonTheme(context),
    tooltipTheme: tooltipTheme(context),
  );
}

InputDecorationTheme inputTheme(BuildContext context) {
  return InputDecorationTheme(
    floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
      return TextStyle(
        color: (states.contains(WidgetState.focused) &&
                !states.contains(WidgetState.error))
            ? context.colorDefault
            : null,
      );
    }),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: context.colorDefault,
        width: 2.0,
      ),
    ),
  );
}

TextSelectionThemeData textSelectionTheme(BuildContext context) {
  return TextSelectionThemeData(
    cursorColor: context.colorDefault,
  );
}

TextButtonThemeData textButtonTheme(BuildContext context) {
  return TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor:
          WidgetStateColor.resolveWith((_) => context.colorDefault),
    ),
  );
}

TooltipThemeData tooltipTheme(BuildContext context) {
  return TooltipThemeData(
    decoration: BoxDecoration(
      color: context.colorFloatingContainerBackground,
      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
    ),
    textStyle: TextStyle(
      color: context.colorText,
    ),
  );
}

extension BuildContexts on BuildContext {
  /// Rebuilds all children of this [BuildContext], including const widgets.
  ///
  /// This method should _only_ be used in special circumstances, where a complete
  /// rebuild (including const widgets) is necessary, such as when the app's
  /// theme has changed.
  ///
  /// For more details, see https://stackoverflow.com/a/58513635/3304388.
  void rebuildAllChildren() {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    if (this is Element) {
      (this as Element).visitChildren(rebuild);
    }
  }

  bool get isDarkTheme {
    switch (UserPreferenceManager.get.themeMode) {
      case ThemeMode.system:
        return MediaQuery.of(this).platformBrightness == Brightness.dark;
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
    }
  }

  Color get colorAppBarContent => isDarkTheme ? Colors.white : Colors.black;

  Color get colorText => isDarkTheme ? Colors.white : Colors.black;

  Color get colorIconFloatingButton =>
      isDarkTheme ? Colors.white : Colors.black;

  MaterialColor get colorDefault => Colors.lightBlue;

  Color get colorGreyAccent => isDarkTheme ? Colors.white38 : Colors.black45;

  Color get colorGreyMedium => isDarkTheme ? Colors.white12 : Colors.black12;

  Color get colorGreyAccentLight =>
      isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade200;

  Color get colorFloatingContainerBackground =>
      isDarkTheme ? Colors.grey[700]! : Colors.white;

  Color get colorBoxShadow => isDarkTheme ? Colors.black54 : Colors.grey;

  SystemUiOverlayStyle get appBarSystemStyle =>
      isDarkTheme ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
}
