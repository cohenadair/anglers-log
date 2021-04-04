import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'mocks/mocks.dart';
import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';

/// A widget that wraps a child in default localizations.
class Testable extends StatelessWidget {
  final Function(BuildContext) builder;
  final MediaQueryData mediaQueryData;
  final AppManager appManager;

  Testable(
    this.builder, {
    this.mediaQueryData = const MediaQueryData(),
    StubbedAppManager? appManager,
  }) : appManager = appManager?.app ?? StubbedAppManager().app;

  @override
  Widget build(BuildContext context) {
    return Provider<AppManager>.value(
      value: appManager,
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
        ),
        localizationsDelegates: [
          StringsDelegate(),
          DefaultMaterialLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        locale: Locale("en", "CA"),
        home: MediaQuery(
          data: mediaQueryData,
          child: Material(
            child: Builder(
              builder: builder as Widget Function(BuildContext),
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

Future<BuildContext> buildContext(
  WidgetTester tester, {
  bool use24Hour = false,
  StubbedAppManager? appManager,
}) async {
  BuildContext? context;
  await tester.pumpWidget(Testable(
    (buildContext) {
      context = buildContext;
      return Empty();
    },
    mediaQueryData: MediaQueryData(
      devicePixelRatio: 1.0,
      alwaysUse24HourFormat: use24Hour,
    ),
    appManager: appManager,
  ));
  return context!;
}

MockAssetEntity createMockAssetEntity({
  required String fileName,
  String? id,
  DateTime? dateTime,
  LatLng? latLngAsync,
  LatLng? latLngLegacy,
}) {
  return MockAssetEntity(
    fileName: fileName,
    id: id ?? fileName,
    dateTime: dateTime,
    latLngAsync: latLngAsync,
    latLngLegacy: latLngLegacy,
  );
}

MockStream<T> createMockStreamWithSubscription<T>() {
  var stream = MockStream<T>();
  var streamSubscription = MockStreamSubscription<T>();
  when(stream.listen(any)).thenReturn(streamSubscription);
  return stream;
}

T findFirst<T>(WidgetTester tester) => tester.firstWidget(find.byType(T)) as T;

/// Different from [Finder.widgetWithText] in that it works for widgets with
/// generic arguments.
T findFirstWithText<T>(WidgetTester tester, String text) =>
    tester.firstWidget(find.ancestor(
      of: find.text(text),
      matching: find.byWidgetPredicate((widget) => widget is T),
    )) as T;

T findFirstWithIcon<T>(WidgetTester tester, IconData icon) =>
    tester.firstWidget(find.ancestor(
      of: find.byIcon(icon),
      matching: find.byWidgetPredicate((widget) => widget is T),
    )) as T;

T findSiblingOfText<T>(WidgetTester tester, Type parentType, String text) =>
    tester.firstWidget(find.descendant(
      of: find.widgetWithText(parentType, text),
      matching: find.byType(T),
    )) as T;

Finder findRichText(String text) {
  return find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText() == text);
}

bool tapRichTextContaining(
    WidgetTester tester, String fullText, String clickText) {
  return !tester
      .firstWidget<RichText>(findRichText(fullText))
      .text
      .visitChildren((span) {
    if (span is TextSpan && span.text == clickText) {
      (span.recognizer as TapGestureRecognizer).onTap!();
      return false;
    }
    return true;
  });
}

/// Different from [Finder.byType] in that it works for widgets with generic
/// arguments.
List<T> findType<T>(
  WidgetTester tester, {
  bool skipOffstage = true,
}) {
  return tester
      .widgetList(find.byWidgetPredicate(
        (widget) => widget is T,
        skipOffstage: skipOffstage,
      ))
      .map((e) => e as T)
      .toList();
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder,
    [int? durationMillis]) async {
  await tester.tap(finder);
  if (durationMillis == null) {
    await tester.pumpAndSettle();
  } else {
    await tester.pumpAndSettle(Duration(milliseconds: durationMillis));
  }
}

Future<void> enterTextAndSettle(
    WidgetTester tester, Finder finder, String text) async {
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

Future<ui.Image?> loadImage(WidgetTester tester, String path) async {
  ui.Image? image;
  // runAsync is required here because instantiateImageCodec does real async
  // work and can't be used with pump().
  await tester.runAsync(() async {
    var codec = await ui.instantiateImageCodec(File(path).readAsBytesSync());
    image = (await codec.getNextFrame()).image;
  });
  return image;
}
