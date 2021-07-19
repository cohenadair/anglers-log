import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'mocks/mocks.dart';
import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';

/// A convenience class that uses a real [UserPreferenceManager] without the
/// Firebase dependency.
class NoFirestoreUserPreferenceManager extends UserPreferenceManager {
  NoFirestoreUserPreferenceManager(AppManager appManager) : super(appManager);

  @override
  bool get enableFirestore => false;

  @override
  bool get shouldUseFirestore => false;
}

/// A widget that wraps a child in default localizations.
class Testable extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  final MediaQueryData mediaQueryData;
  final AppManager appManager;
  final TargetPlatform? platform;

  Testable(
    this.builder, {
    this.mediaQueryData = const MediaQueryData(),
    this.platform,
    StubbedAppManager? appManager,
  }) : appManager = appManager?.app ?? StubbedAppManager().app;

  @override
  Widget build(BuildContext context) {
    return Provider<AppManager>.value(
      value: appManager,
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          platform: platform,
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
            child: Builder(builder: builder),
          ),
        ),
      ),
    );
  }
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

Future<BuildContext> pumpContext(
  WidgetTester tester,
  Widget Function(BuildContext) builder, {
  StubbedAppManager? appManager,
}) async {
  late BuildContext context;
  await tester.pumpWidget(
    Testable(
      (buildContext) {
        context = buildContext;
        return builder(context);
      },
      appManager: appManager,
    ),
  );
  return context;
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
    tester.firstWidget(siblingOfText(tester, parentType, text, find.byType(T)))
        as T;

Finder siblingOfText(
    WidgetTester tester, Type parentType, String text, Finder siblingFinder) {
  return find.descendant(
    of: find.widgetWithText(parentType, text),
    matching: siblingFinder,
  );
}

Type typeOf<T>() => T;

Finder findRichText(String text) {
  return find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText() == text);
}

Finder findManageableListItemCheckbox(WidgetTester tester, String item) {
  return find.descendant(
    of: find.widgetWithText(ManageableListItem, item),
    matching: find.byType(PaddedCheckbox),
  );
}

Finder findListItemCheckbox(WidgetTester tester, String item) {
  return find.descendant(
    of: find.widgetWithText(ListItem, item),
    matching: find.byType(PaddedCheckbox),
  );
}

PaddedCheckbox? findCheckbox(WidgetTester tester, String option) {
  return tester.widget<PaddedCheckbox>(find.descendant(
    of: find.widgetWithText(ListItem, option),
    matching: find.byType(PaddedCheckbox),
  ));
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

Future<void> enterTextFieldAndSettle(
    WidgetTester tester, String textFieldTitle, String text) async {
  await tester.enterText(find.widgetWithText(TextField, textFieldTitle), text);
  await tester.pumpAndSettle();
}

Future<Uint8List?> stubImage(
    StubbedAppManager appManager, WidgetTester tester, String name,
    {bool anyName = false}) async {
  Uint8List? image;
  // runAsync is required here because readAsBytes does real async
  // work and can't be used with pump().
  await tester.runAsync(() async {
    image = await File("test/resources/$name").readAsBytes();
  });
  when(appManager.imageManager.image(
    any,
    fileName: anyName ? anyNamed("fileName") : name,
    size: anyNamed("size"),
  )).thenAnswer((_) => Future.value(image));
  return image;
}

extension CommonFindersExt on CommonFinders {
  Finder textStyle(String? text, TextStyle style) => find.byWidgetPredicate(
      (w) => w is Text && w.style == style && (text == null || w.data == text));

  Finder primaryText(
    BuildContext context, {
    String? text,
  }) {
    return textStyle(text, stylePrimary(context));
  }

  Finder secondaryText(
    BuildContext context, {
    String? text,
  }) {
    return textStyle(text, styleSecondary(context));
  }

  Finder subtitleText(
    BuildContext context, {
    String? text,
  }) {
    return textStyle(text, styleSubtitle(context));
  }

  Finder headingText({
    String? text,
  }) {
    return textStyle(text, styleHeading);
  }

  Finder listHeadingText(
    BuildContext context, {
    String? text,
  }) {
    return textStyle(text, styleListHeading(context));
  }

  Finder noteText(
    BuildContext context, {
    String? text,
  }) {
    return textStyle(text, styleNote(context));
  }
}
