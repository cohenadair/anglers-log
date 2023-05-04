import 'package:flutter/material.dart';
import 'package:mobile/user_preference_manager.dart';

ThemeData themeLight() {
  return ThemeData(
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

ThemeData themeDark() => ThemeData.dark();

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
    switch (UserPreferenceManager.of(this).themeMode) {
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

  Color get colorDefault => Colors.lightBlue;

  Color get colorGreyAccent => isDarkTheme ? Colors.white38 : Colors.black45;

  Color get colorGreyMedium => isDarkTheme ? Colors.white12 : Colors.black12;

  Color get colorGreyAccentLight =>
      isDarkTheme ? Colors.grey.shade800 : Colors.grey.shade200;

  Color get colorFloatingContainerBackground =>
      isDarkTheme ? Theme.of(this).colorScheme.background : Colors.white;

  Color get colorBoxShadow => isDarkTheme ? Colors.black54 : Colors.grey;
}
