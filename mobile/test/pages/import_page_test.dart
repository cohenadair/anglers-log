import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mobile/pages/import_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;

  var tmpPath = "test/resources/tmp";
  Directory tmpDir;

  setUp(() {
    appManager = MockAppManager(
      mockBaitCategoryManager: true,
      mockBaitManager: true,
      mockCatchManager: true,
      mockDataManager: true,
      mockFishingSpotManager: true,
      mockSpeciesManager: true,
      mockFilePickerWrapper: true,
      mockPathProviderWrapper: true,
    );

    when(appManager.mockBaitCategoryManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockBaitManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockCatchManager.addOrUpdate(
      any,
      imageFiles: anyNamed("imageFiles"),
      compressImages: anyNamed("compressImages"),
      notify: anyNamed("notify"),
    )).thenAnswer((_) => Future.value(true));

    when(appManager.mockDataManager.reset()).thenAnswer((_) => Future.value());

    when(appManager.mockFishingSpotManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.mockSpeciesManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockSpeciesManager.named(any)).thenReturn(Species()
      ..id = randomId()
      ..name = "Bass");

    when(appManager.mockPathProviderWrapper.temporaryPath)
        .thenAnswer((_) => Future.value(tmpPath));

    // Create a temporary directory for images.
    tmpDir = Directory(tmpPath);
    tmpDir.createSync();
  });

  tearDown(() {
    tmpDir.deleteSync(recursive: true);
  });

  testWidgets("Loading state", (tester) async {
    // There's no way to verify a "loading" state due to Flutter's FakeAsync
    // test environment.
  });

  testWidgets("Null picked file resets state to none", (tester) async {
    when(appManager.mockFilePickerWrapper.getFile(
      type: anyNamed("type"),
      fileExtension: anyNamed("fileExtension"),
    )).thenAnswer((_) => Future.value(null));

    await tester.pumpWidget(Testable(
      (_) => ImportPage(),
      appManager: appManager,
    ));
    await tapAndSettle(tester, find.text("CHOOSE FILE"));

    expect(find.byType(Loading), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.error), findsNothing);
  });

  testWidgets(" ", (tester) async {
    when(appManager.mockFilePickerWrapper.getFile(
      type: anyNamed("type"),
      fileExtension: anyNamed("fileExtension"),
    )).thenAnswer(
        (_) => Future.value(File("test/resources/backups/no_journal.zip")));

    await tester.pumpWidget(Testable(
      (_) => ImportPage(),
      appManager: appManager,
    ));
    await tapAndSettle(tester, find.text("CHOOSE FILE"));

    expect(find.byIcon(Icons.error), findsOneWidget);
  });

  testWidgets("Import error feedback button shows feedback page",
      (tester) async {
    when(appManager.mockFilePickerWrapper.getFile(
      type: anyNamed("type"),
      fileExtension: anyNamed("fileExtension"),
    )).thenAnswer(
        (_) => Future.value(File("test/resources/backups/no_journal.zip")));

    await tester.pumpWidget(Testable(
      (_) => ImportPage(),
      appManager: appManager,
    ));
    await tapAndSettle(tester, find.text("CHOOSE FILE"));

    expect(find.text("SEND REPORT"), findsOneWidget);
    await tapAndSettle(tester, find.text("SEND REPORT"));

    expect(find.byType(FeedbackPage), findsOneWidget);
  });

  testWidgets("Successful import error shows success widget", (tester) async {
    when(appManager.mockFilePickerWrapper.getFile(
      type: anyNamed("type"),
      fileExtension: anyNamed("fileExtension"),
    )).thenAnswer((_) =>
        Future.value(File("test/resources/backups/legacy_ios_entities.zip")));

    await tester.pumpWidget(Testable(
      (_) => ImportPage(),
      appManager: appManager,
    ));
    await tapAndSettle(tester, find.text("CHOOSE FILE"));

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
