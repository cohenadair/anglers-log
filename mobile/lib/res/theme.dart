import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/res/theme.dart';
import 'package:flutter/material.dart';

const maxTextScale = 1.28;
const minTextScale = 1.0;

ThemeData themeLight() {
  return AdairFlutterLibTheme.light().copyWith(
    iconTheme: IconThemeData(color: AppConfig.get.colorAppTheme),
    extensions: _themeExtensions(),
  );
}

ThemeData themeDark(BuildContext context) {
  return AdairFlutterLibTheme.dark().copyWith(
    inputDecorationTheme: _inputTheme(context),
    textSelectionTheme: _textSelectionTheme(context),
    textButtonTheme: _textButtonTheme(context),
    tooltipTheme: _tooltipTheme(context),
    extensions: _themeExtensions(),
  );
}

InputDecorationTheme _inputTheme(BuildContext context) {
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

TextSelectionThemeData _textSelectionTheme(BuildContext context) {
  return TextSelectionThemeData(cursorColor: AppConfig.get.colorAppTheme);
}

TextButtonThemeData _textButtonTheme(BuildContext context) {
  return TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateColor.resolveWith(
        (_) => AppConfig.get.colorAppTheme,
      ),
    ),
  );
}

TooltipThemeData _tooltipTheme(BuildContext context) {
  return TooltipThemeData(
    decoration: BoxDecoration(
      color: context.colorFloatingContainerBackground,
      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
    ),
    textStyle: TextStyle(color: context.colorText),
  );
}

List<ThemeExtension> _themeExtensions() => [
  AdairFlutterLibThemeExtension(
    app: AppConfig.get.colorAppTheme,
    // TODO: These are only used on the LandingPage right now, but may need to
    //  rethink them if they're used elsewhere, since the Anglers' Log "onApp"
    //  text color throughout the app is actually black.
    onApp: Colors.white,
    onAppSecondary: Colors.white54,
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
      isDarkTheme ? Colors.grey[700]! : Colors.white;
}
