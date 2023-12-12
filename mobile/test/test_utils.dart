import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/sf_localizations_override.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart';

import 'mocks/mocks.dart';
import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
import 'mocks/stubbed_map_controller.dart';

/// A widget that wraps a child in default localizations.
class Testable extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  final MediaQueryData mediaQueryData;
  final StubbedAppManager appManager;
  final TargetPlatform? platform;
  final ThemeMode? themeMode;

  Testable(
    this.builder, {
    this.mediaQueryData = const MediaQueryData(),
    this.platform,
    this.themeMode,
    StubbedAppManager? appManager,
  }) : appManager = appManager ?? StubbedAppManager();

  @override
  Widget build(BuildContext context) {
    // Always default to light mode.
    when(appManager.userPreferenceManager.themeMode)
        .thenReturn(themeMode ?? ThemeMode.light);

    return Provider<AppManager>.value(
      value: appManager.app,
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: Colors.lightBlue,
          platform: platform,
        ),
        localizationsDelegates: [
          StringsDelegate(),
          const SfLocalizationsOverrideDelegate(),
          DefaultMaterialLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        locale: const Locale("en", "CA"),
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

/// A test widget that allows testing of [child.dispose] by invoking
/// [DisposableTesterState.removeChild].
class DisposableTester extends StatefulWidget {
  final Widget child;

  const DisposableTester({required this.child});

  @override
  DisposableTesterState createState() => DisposableTesterState();
}

class DisposableTesterState extends State<DisposableTester> {
  bool _showChild = true;

  void removeChild() => setState(() => _showChild = false);

  @override
  Widget build(BuildContext context) =>
      _showChild ? widget.child : const Empty();
}

class DidUpdateWidgetTester<T> extends StatefulWidget {
  final T controller;
  final Widget Function(BuildContext, T) childBuilder;

  const DidUpdateWidgetTester(this.controller, this.childBuilder);

  @override
  DidUpdateWidgetTesterState<T> createState() =>
      DidUpdateWidgetTesterState<T>();
}

class DidUpdateWidgetTesterState<T> extends State<DidUpdateWidgetTester<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Button(
          text: "DID UPDATE WIDGET BUTTON",
          onPressed: () => setState(() {}),
        ),
        widget.childBuilder(context, widget.controller),
      ],
    );
  }
}

void setCanvasSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
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
      return const Empty();
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
  MediaQueryData mediaQueryData = const MediaQueryData(),
  ThemeMode? themeMode,
}) async {
  late BuildContext context;
  await tester.pumpWidget(
    Testable(
      (buildContext) {
        context = buildContext;
        return builder(context);
      },
      appManager: appManager,
      mediaQueryData: mediaQueryData,
      themeMode: themeMode,
    ),
  );
  return context;
}

const defaultTimeZone = "America/New_York";

TZDateTime dateTime(
  int year, [
  int month = 1,
  int day = 1,
  int hour = 0,
  int minute = 0,
  int second = 0,
  int millisecond = 0,
  int microsecond = 0,
]) {
  return TZDateTime(getLocation(defaultTimeZone), year, month, day, hour,
      minute, second, millisecond);
}

TZDateTime now() {
  return TZDateTime.now(getLocation(defaultTimeZone));
}

TZDateTime dateTimestamp(int timestamp) {
  return TZDateTime.fromMillisecondsSinceEpoch(
      getLocation(defaultTimeZone), timestamp);
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

Future<void> showPresentedWidget(WidgetTester tester,
    StubbedAppManager appManager, void Function(BuildContext) showSheet) async {
  await pumpContext(
    tester,
    (context) => Button(
      text: "Test",
      onPressed: () => showSheet(context),
    ),
    appManager: appManager,
  );
  await tapAndSettle(tester, find.text("TEST"));
}

T findFirst<T>(WidgetTester tester) => tester.firstWidget(find.byType(T)) as T;

T findLast<T>(WidgetTester tester) =>
    tester.widgetList(find.byType(T)).last as T;

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

Finder findManageableListItemCheckbox(
  WidgetTester tester,
  String item, {
  bool skipOffstage = true,
}) {
  return find.descendant(
    of: find.widgetWithText(
      ManageableListItem,
      item,
      skipOffstage: skipOffstage,
    ),
    matching: find.byType(PaddedCheckbox, skipOffstage: skipOffstage),
    skipOffstage: skipOffstage,
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

Future<void> ensureVisibleAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
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
  StubbedAppManager appManager,
  WidgetTester tester,
  String name, {
  bool anyName = false,
}) async {
  File? file;
  Uint8List? image;
  // runAsync is required here because readAsBytes does real async
  // work and can't be used with pump().
  await tester.runAsync(() async {
    file = File("test/resources/$name");
    image = await file!.readAsBytes();
  });

  when(appManager.imageManager.image(
    fileName: anyName ? anyNamed("fileName") : name,
    size: anyNamed("size"),
    devicePixelRatio: anyNamed("devicePixelRatio"),
  )).thenAnswer((_) => Future.value(image));

  when(appManager.imageManager.images(
    imageNames: anyName ? anyNamed("imageNames") : [name],
    size: anyNamed("size"),
    devicePixelRatio: anyNamed("devicePixelRatio"),
  )).thenAnswer((_) => Future.value({file!: image!}));

  return image;
}

Future<List<Uint8List>> stubImages(
  StubbedAppManager appManager,
  WidgetTester tester,
  List<String> names,
) async {
  var files = <File>[];
  var images = <Uint8List>[];

  // runAsync is required here because readAsBytes does real async
  // work and can't be used with pump().
  await tester.runAsync(() async {
    for (var name in names) {
      var file = File("test/resources/$name");
      files.add(file);
      images.add(await file.readAsBytes());
    }
  });

  when(appManager.imageManager.images(
    imageNames: anyNamed("imageNames"),
    size: anyNamed("size"),
    devicePixelRatio: anyNamed("devicePixelRatio"),
  )).thenAnswer((invocation) {
    var length = invocation.namedArguments[const Symbol("imageNames")].length;
    return Future.value({for (var i = 0; i < length; i++) files[i]: images[i]});
  });

  return images;
}

void stubFetchResponse(StubbedAppManager appManager, String json) {
  var response = MockResponse();
  when(response.statusCode).thenReturn(HttpStatus.ok);
  when(appManager.httpWrapper.get(any))
      .thenAnswer((_) => Future.value(response));
  when(response.body).thenReturn(json);
}

Future<void> pumpMap(WidgetTester tester, StubbedAppManager appManager,
    StubbedMapController mapController, Widget mapWidget) async {
  await tester.pumpWidget(Testable(
    (_) => mapWidget,
    appManager: appManager,
  ));

  // Wait for map future to finish.
  await tester.pumpAndSettle(const Duration(milliseconds: 300));
  await mapController.finishLoading(tester);
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

  Finder headingSmallText({
    String? text,
  }) {
    return textStyle(text, styleHeadingSmall);
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

  Finder disabledText(
    BuildContext context, {
    String? text,
  }) {
    return textStyle(text, styleDisabled(context));
  }

  Finder errorText(
    BuildContext context, {
    String? text,
  }) {
    return textStyle(text, styleError(context));
  }

  Finder successText(
    BuildContext context, {
    String? text,
  }) {
    return textStyle(text, styleSuccess(context));
  }

  Finder substring(String substring, {bool skipOffstage = true}) {
    return byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data != null &&
          widget.data!.contains(substring),
      skipOffstage: skipOffstage,
    );
  }
}
