import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/database/legacy_importer.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/data_importer.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;

  var tmpPath = "test/resources/data_importer/tmp";
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
    tmpDir.createSync(recursive: true);
  });

  tearDown(() {
    tmpDir.deleteSync(recursive: true);
  });

  DataImporter defaultImporter({
    LegacyImporter importer,
    void Function(bool) onFinish,
  }) =>
      DataImporter(
        importer: importer,
        watermarkIcon: Icons.terrain_sharp,
        titleText: "Title",
        descriptionText: "Description",
        loadingText: "Loading",
        errorText: "Error",
        successText: "Success",
        feedbackPageTitle: "Feedback Page",
        onFinish: onFinish,
      );

  testWidgets("Start button chooses a file to import", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => defaultImporter(),
      appManager: appManager,
    ));
    await tapAndSettle(tester, find.text("CHOOSE FILE"));

    verify(appManager.mockFilePickerWrapper.getFile(
      type: anyNamed("type"),
      fileExtension: anyNamed("fileExtension"),
    )).called(1);
  });

  testWidgets("Start button disabled while loading", (tester) async {
    when(appManager.mockFilePickerWrapper.getFile(
      type: anyNamed("type"),
      fileExtension: anyNamed("fileExtension"),
    )).thenAnswer((_) =>
        Future.value(File("test/resources/backups/legacy_ios_entities.zip")));

    when(appManager.mockDataManager.reset())
        .thenAnswer((_) => Future.delayed(Duration(milliseconds: 100)));

    await tester.pumpWidget(Testable(
      (_) => defaultImporter(),
      appManager: appManager,
    ));
    await tester.tap(find.text("CHOOSE FILE"));
    await tester.pump();

    expect(findFirstWithText<Button>(tester, "CHOOSE FILE").onPressed, isNull);

    // Expire delayed future and verify start button is enabled again.
    await tester.pumpAndSettle(Duration(milliseconds: 150));
    expect(
        findFirstWithText<Button>(tester, "CHOOSE FILE").onPressed, isNotNull);
  });

  testWidgets("Start button starts migration", (tester) async {
    var importer = MockLegacyImporter();
    when(importer.start()).thenAnswer((_) => Future.value());

    await tester.pumpWidget(Testable(
      (_) => defaultImporter(importer: importer),
      appManager: appManager,
    ));
    await tapAndSettle(tester, find.text("START"));

    verifyNever(appManager.mockFilePickerWrapper.getFile(
      type: anyNamed("type"),
      fileExtension: anyNamed("fileExtension"),
    ));
    verify(importer.start()).called(1);
  });

  testWidgets("Start button disabled when migration finishes", (tester) async {
    var importer = MockLegacyImporter();
    when(importer.start()).thenAnswer((_) => Future.value());

    await tester.pumpWidget(Testable(
      (_) => defaultImporter(importer: importer),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("START"));
    expect(findFirstWithText<Button>(tester, "START").onPressed, isNull);
  });

  testWidgets("Null picked file resets state to none", (tester) async {
    when(appManager.mockFilePickerWrapper.getFile(
      type: anyNamed("type"),
      fileExtension: anyNamed("fileExtension"),
    )).thenAnswer((_) => Future.value(null));

    await tester.pumpWidget(Testable(
      (_) => defaultImporter(),
      appManager: appManager,
    ));
    await tapAndSettle(tester, find.text("CHOOSE FILE"));

    expect(find.byType(Loading), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.error), findsNothing);
  });

  testWidgets("Invalid chosen data shows error", (tester) async {
    when(appManager.mockFilePickerWrapper.getFile(
      type: anyNamed("type"),
      fileExtension: anyNamed("fileExtension"),
    )).thenAnswer(
        (_) => Future.value(File("test/resources/backups/no_journal.zip")));

    await tester.pumpWidget(Testable(
      (_) => defaultImporter(),
      appManager: appManager,
    ));
    await tapAndSettle(tester, find.text("CHOOSE FILE"));

    expect(find.byIcon(Icons.error), findsOneWidget);
  });

  testWidgets("Feedback button shows feedback page", (tester) async {
    when(appManager.mockFilePickerWrapper.getFile(
      type: anyNamed("type"),
      fileExtension: anyNamed("fileExtension"),
    )).thenAnswer(
        (_) => Future.value(File("test/resources/backups/no_journal.zip")));

    await tester.pumpWidget(Testable(
      (_) => defaultImporter(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("CHOOSE FILE"));
    await tapAndSettle(tester, find.text("SEND REPORT"));

    expect(find.byType(FeedbackPage), findsOneWidget);
  });

  testWidgets("Successful import shows success widget", (tester) async {
    when(appManager.mockFilePickerWrapper.getFile(
      type: anyNamed("type"),
      fileExtension: anyNamed("fileExtension"),
    )).thenAnswer((_) =>
        Future.value(File("test/resources/backups/legacy_ios_entities.zip")));

    await tester.pumpWidget(Testable(
      (_) => defaultImporter(),
      appManager: appManager,
    ));
    await tapAndSettle(tester, find.text("CHOOSE FILE"));

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets("onFinish called when import is successful", (tester) async {
    var importer = MockLegacyImporter();
    when(importer.start()).thenAnswer((_) => Future.value());

    var called = false;
    var didSucceed = false;
    await tester.pumpWidget(Testable(
      (_) => defaultImporter(
        importer: importer,
        onFinish: (success) {
          didSucceed = success;
          called = true;
        },
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("START"));
    expect(called, isTrue);
    expect(didSucceed, isTrue);
  });

  testWidgets("onFinish called when import is unsuccessful", (tester) async {
    var importer = MockLegacyImporter();
    when(importer.start()).thenAnswer((_) =>
        Future.error(LegacyImporterError.missingJournal, StackTrace.empty));

    var called = false;
    var didSucceed = true;
    await tester.pumpWidget(Testable(
      (_) => defaultImporter(
        importer: importer,
        onFinish: (success) {
          didSucceed = success;
          called = true;
        },
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("START"));
    expect(called, isTrue);
    expect(didSucceed, isFalse);
  });
}
