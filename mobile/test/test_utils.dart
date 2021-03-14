import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:mobile/app_manager.dart';
import 'package:mobile/database/legacy_importer.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class MockAssetEntity extends Mock implements AssetEntity {}

class MockAssetPathEntity extends Mock implements AssetPathEntity {}

// ignore: must_be_immutable
class MockCollectionReference extends Mock implements CollectionReference {}

class MockDirectory extends Mock implements Directory {}

class MockDocumentChange extends Mock implements DocumentChange {}

class MockDocumentReference extends Mock implements DocumentReference {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

class MockFile extends Mock implements File {}

class MockFileSystemEntity extends Mock implements FileSystemEntity {}

class MockFullMetadata extends Mock implements FullMetadata {}

class MockGoogleMapController extends Mock
    implements google.GoogleMapController {}

class MockLegacyImporter extends Mock implements LegacyImporter {}

class MockMethodChannel extends Mock implements MethodChannel {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockReference extends Mock implements Reference {}

class MockStream<T> extends Mock implements Stream<T> {}

class MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {}

/// A widget that wraps a child in default localizations.
class Testable extends StatelessWidget {
  final Function(BuildContext) builder;
  final MediaQueryData mediaQueryData;
  final NavigatorObserver navigatorObserver;
  final AppManager appManager;

  Testable(
    this.builder, {
    this.mediaQueryData = const MediaQueryData(),
    this.navigatorObserver,
    this.appManager,
  }) : assert(builder != null);

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
        navigatorObservers:
            navigatorObserver == null ? [] : [navigatorObserver],
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

Future<BuildContext> buildContext(
  WidgetTester tester, {
  bool use24Hour = false,
  AppManager appManager,
}) async {
  BuildContext context;
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
  return context;
}

MockAssetEntity createMockAssetEntity({
  @required String fileName,
  String id,
  DateTime dateTime,
  LatLng latLngAsync,
  LatLng latLngLegacy,
}) {
  var entity = MockAssetEntity();
  when(entity.id).thenReturn(id ?? fileName);
  when(entity.createDateTime).thenReturn(dateTime ?? DateTime.now());
  when(entity.thumbData).thenAnswer(
      (_) => Future.value(File("test/resources/$fileName").readAsBytesSync()));
  when(entity.latlngAsync()).thenAnswer((_) => Future.value(latLngAsync));
  when(entity.latitude).thenReturn(latLngLegacy?.latitude);
  when(entity.longitude).thenReturn(latLngLegacy?.longitude);
  return entity;
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
      (span.recognizer as TapGestureRecognizer).onTap();
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
    [int durationMillis]) async {
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

Future<ui.Image> loadImage(WidgetTester tester, String path) async {
  ui.Image image;
  // runAsync is required here because instantiateImageCodec does real async
  // work and can't be used with pump().
  await tester.runAsync(() async {
    var codec = await ui.instantiateImageCodec(File(path).readAsBytesSync());
    image = (await codec.getNextFrame()).image;
  });
  return image;
}
