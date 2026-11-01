import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/res/theme.dart';
import 'package:flutter/material.dart';

const maxTextScale = 1.28;
const minTextScale = 1.0;

/// Equivalent to `Colors.grey[700]`, which can't be used in a const context.
const colorFloatingContainerBackgroundDark = Color(0xFF616161);

ThemeData themeLight() {
  return AdairFlutterLibTheme.light().copyWith(
    iconTheme: IconThemeData(color: AppConfig.get.colorAppTheme),
    extensions: _themeExtensions(),
  );
}

ThemeData themeDark() {
  return AdairFlutterLibTheme.dark().copyWith(
    inputDecorationTheme: _inputTheme(),
    textSelectionTheme: _textSelectionTheme(),
    textButtonTheme: _textButtonTheme(),
    tooltipTheme: _tooltipThemeDark(),
    extensions: _themeExtensions(),
  );
}

InputDecorationTheme _inputTheme() {
  return InputDecorationTheme(
    floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
      return TextStyle(
        color:
            (states.contains(WidgetState.focused) &&
                !states.contains(WidgetState.error))
            ? AppConfig.get.colorAppTheme
            : null,
      );
    }),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppConfig.get.colorAppTheme, width: 2.0),
    ),
  );
}

TextSelectionThemeData _textSelectionTheme() {
  return TextSelectionThemeData(cursorColor: AppConfig.get.colorAppTheme);
}

TextButtonThemeData _textButtonTheme() {
  return TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateColor.resolveWith(
        (_) => AppConfig.get.colorAppTheme,
      ),
    ),
  );
}

/// Colors are hardcoded to their dark values, rather than derived from a
/// [BuildContext], because this theme is only ever used in dark mode. Reading
/// them from the context above [MaterialApp] would make the entire app
/// rebuild on every [MediaQuery] change (such as keyboard animations).
TooltipThemeData _tooltipThemeDark() {
  return const TooltipThemeData(
    decoration: BoxDecoration(
      color: colorFloatingContainerBackgroundDark,
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    textStyle: TextStyle(color: Colors.white),
  );
}

List<ThemeExtension> _themeExtensions() => [
  AdairFlutterLibThemeExtension(
    app: AppConfig.get.colorAppTheme,
    onApp: Colors.black,
    onAppSecondary: Colors.black45,
  ),
];

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

  @Deprecated("Use AppConfig.colorAppBarContent instead")
  Color get colorAppBarContent => AppConfig.get.colorAppBarContent(isDarkTheme);

  Color get colorIconFloatingButton =>
      isDarkTheme ? Colors.white : Colors.black;

  Color get colorGreyAccent => isDarkTheme ? Colors.white38 : Colors.black45;

  Color get colorGreyMedium => isDarkTheme ? Colors.white12 : Colors.black12;

  Color get colorFloatingContainerBackground =>
      isDarkTheme ? colorFloatingContainerBackgroundDark : Colors.white;
}
