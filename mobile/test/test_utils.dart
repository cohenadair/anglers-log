import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

/// A widget that wraps a child in default localizations.
class Testable extends StatelessWidget {
  final Function(BuildContext) builder;
  final MediaQueryData mediaQueryData;
  final NavigatorObserver navigatorObserver;
  final AppManager appManager;

  Testable(this.builder, {
    this.mediaQueryData = const MediaQueryData(),
    this.navigatorObserver,
    this.appManager,
  }) : assert(builder != null);

  @override
  Widget build(BuildContext context) {
    return Provider<AppManager>.value(
      value: appManager,
      child: MaterialApp(
        localizationsDelegates: [
          StringsDelegate(),
          DefaultMaterialLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        locale: Locale("en", "CA"),
        navigatorObservers: navigatorObserver == null
            ? [] : [navigatorObserver],
        home: MediaQuery(
          data: mediaQueryData,
          child: Material(
            child: Builder(
              builder: builder,
            ),
          ),
        ),
      ),
    );
  }
}

DisplayDateRange stubDateRange(DateRange dateRange) {
  return DisplayDateRange.newCustom(
    getValue: (_) => dateRange,
    getTitle: (_) => "",
  );
}

Future<BuildContext> buildContext(WidgetTester tester, {
  bool use24Hour = false,
  AppManager appManager,
}) async {
  BuildContext context;
  await tester.pumpWidget(
    Testable((buildContext) {
      context = buildContext;
      return Empty();
    },
    mediaQueryData: MediaQueryData(
      devicePixelRatio: 1.0,
      alwaysUse24HourFormat: use24Hour,
    ),
    appManager: appManager,
  ));
  return context;
}

T findFirst<T>(WidgetTester tester) => tester.firstWidget(find.byType(T)) as T;

/// Different from [Finder.widgetWithText] in that it works for widgets with
/// generic arguments.
T findFirstWithText<T>(WidgetTester tester, String text) =>
    tester.firstWidget(find.ancestor(
      of: find.text(text),
      matching: find.byWidgetPredicate((widget) => widget is T),
    )) as T;

/// Different from [Finder.byType] in that it works for widgets with generic
/// arguments.
List<T> findType<T>(WidgetTester tester) =>
    tester.widgetList(find.byWidgetPredicate((widget) => widget is T))
        .map((e) => e as T)
        .toList();

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> enterTextAndSettle(WidgetTester tester, Finder finder, String text)
    async
{
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}