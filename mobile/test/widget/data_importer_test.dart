import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/channels/migration_channel.dart';
import 'package:mobile/database/legacy_importer.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/data_importer.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  var tmpPath = "test/resources/data_importer/tmp";
  late Directory tmpDir;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.baitCategoryManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.baitManager.addOrUpdate(
      any,
      imageFile: anyNamed("imageFile"),
      compressImages: anyNamed("compressImages"),
    )).thenAnswer((_) => Future.value(true));
    when(appManager.baitManager.named(any)).thenReturn(null);

    when(appManager.bodyOfWaterManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.bodyOfWaterManager.named(any)).thenReturn(null);

    when(appManager.catchManager.addOrUpdate(
      any,
      imageFiles: anyNamed("imageFiles"),
      compressImages: anyNamed("compressImages"),
      notify: anyNamed("notify"),
    )).thenAnswer((_) => Future.value(true));

    when(appManager.fishingSpotManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.fishingSpotManager.namedWithBodyOfWater(any, any))
        .thenReturn(null);

    when(appManager.filePickerWrapper.pickFiles(
      type: anyNamed("type"),
      allowedExtensions: anyNamed("allowedExtensions"),
    )).thenAnswer((_) => Future.value(null));

    when(appManager.methodManager.named(any)).thenReturn(null);
    when(appManager.methodManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.speciesManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.speciesManager.named(any)).thenReturn(Species()
      ..id = randomId()
      ..name = "Bass");

    when(appManager.waterClarityManager.named(any)).thenReturn(null);
    when(appManager.waterClarityManager.addOrUpdate(any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.pathProviderWrapper.temporaryPath)
        .thenAnswer((_) => Future.value(tmpPath));

    // Create a temporary directory for images.
    tmpDir = Directory(tmpPath);
    tmpDir.createSync(recursive: true);
  });

  tearDown(() {
    tmpDir.deleteSync(recursive: true);
  });

  DataImporter defaultImporter({
    LegacyImporter? importer,
    void Function(bool)? onFinish,
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

    verify(appManager.filePickerWrapper.pickFiles(
      type: anyNamed("type"),
      allowedExtensions: anyNamed("allowedExtensions"),
    )).called(1);
  });

  testWidgets("Start button disabled while loading", (tester) async {
    when(appManager.filePickerWrapper.pickFiles(
      type: anyNamed("type"),
      allowedExtensions: anyNamed("allowedExtensions"),
    )).thenAnswer(
      (_) => Future.value(
        FilePickerResult([
          PlatformFile(
            path: "test/resources/backups/legacy_ios_entities.zip",
            name: "legacy_ios_entities.zip",
            size: 100,
          ),
        ]),
      ),
    );

    when(appManager.pathProviderWrapper.temporaryPath).thenAnswer((_) =>
        Future.delayed(const Duration(milliseconds: 100), () => tmpPath));

    await tester.pumpWidget(Testable(
      (_) => defaultImporter(),
      appManager: appManager,
    ));
    await tester.tap(find.text("CHOOSE FILE"));
    await tester.pump();

    expect(findFirstWithText<Button>(tester, "CHOOSE FILE").onPressed, isNull);

    // Expire delayed future and verify start button is enabled again.
    await tester.pumpAndSettle(const Duration(milliseconds: 150));
    expect(
        findFirstWithText<Button>(tester, "CHOOSE FILE").onPressed, isNotNull);
  });

  testWidgets("Show legacy json result error immediately", (tester) async {
    var importer = MockLegacyImporter();
    when(importer.legacyJsonResult).thenReturn(LegacyJsonResult(
      errorCode: LegacyJsonErrorCode.invalidJson,
      errorDescription: "E",
    ));

    await tester.pumpWidget(Testable(
      (_) => defaultImporter(importer: importer),
      appManager: appManager,
    ));
    await tapAndSettle(tester, find.text("START"));

    expect(find.text("Error"), findsOneWidget);
    verifyNever(importer.start());
  });

  testWidgets("Start button starts migration", (tester) async {
    var importer = MockLegacyImporter();
    when(importer.legacyJsonResult).thenReturn(LegacyJsonResult());
    when(importer.start())
        .thenAnswer((_) => Future.delayed(const Duration(milliseconds: 50)));

    await tester.pumpWidget(Testable(
      (_) => defaultImporter(importer: importer),
      appManager: appManager,
    ));
    await tester.tap(find.text("START"));

    // Pump once so we can verify the loading description is shown.
    await tester.pump();
    expect(find.text("Loading"), findsOneWidget);

    // Finish import.
    await tester.pumpAndSettle();

    verifyNever(appManager.filePickerWrapper.pickFiles(
      type: anyNamed("type"),
      allowedExtensions: anyNamed("allowedExtensions"),
    ));
    verify(importer.start()).called(1);
  });

  testWidgets("Start button disabled when migration finishes", (tester) async {
    var importer = MockLegacyImporter();
    when(importer.legacyJsonResult).thenReturn(LegacyJsonResult());
    when(importer.start()).thenAnswer((_) => Future.value());

    await tester.pumpWidget(Testable(
      (_) => defaultImporter(importer: importer),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("START"));
    expect(findFirstWithText<Button>(tester, "START").onPressed, isNull);
  });

  testWidgets("Null picked file resets state to none", (tester) async {
    when(appManager.filePickerWrapper.pickFiles(
      type: anyNamed("type"),
      allowedExtensions: anyNamed("allowedExtensions"),
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
    when(appManager.filePickerWrapper.pickFiles(
      type: anyNamed("type"),
      allowedExtensions: anyNamed("allowedExtensions"),
    )).thenAnswer(
      (_) => Future.value(
        FilePickerResult([
          PlatformFile(
            path: "test/resources/backups/no_journal.zip",
            name: "no_journal.zip",
            size: 100,
          ),
        ]),
      ),
    );

    await tester.pumpWidget(Testable(
      (_) => defaultImporter(),
      appManager: appManager,
    ));
    await tapAndSettle(tester, find.text("CHOOSE FILE"));

    expect(find.byIcon(Icons.error), findsOneWidget);
    expect(find.text("Error"), findsOneWidget);
  });

  testWidgets("Feedback button shows feedback page", (tester) async {
    when(appManager.userPreferenceManager.userName).thenReturn(null);
    when(appManager.userPreferenceManager.userEmail).thenReturn(null);

    when(appManager.filePickerWrapper.pickFiles(
      type: anyNamed("type"),
      allowedExtensions: anyNamed("allowedExtensions"),
    )).thenAnswer(
      (_) => Future.value(
        FilePickerResult([
          PlatformFile(
            path: "test/resources/backups/no_journal.zip",
            name: "no_journal.zip",
            size: 100,
          ),
        ]),
      ),
    );

    await tester.pumpWidget(Testable(
      (_) => defaultImporter(),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("CHOOSE FILE"));
    await tapAndSettle(tester, find.text("SEND REPORT"));

    expect(find.byType(FeedbackPage), findsOneWidget);
  });

  testWidgets("Successful import shows success widget", (tester) async {
    when(appManager.filePickerWrapper.pickFiles(
      type: anyNamed("type"),
      allowedExtensions: anyNamed("allowedExtensions"),
    )).thenAnswer(
      (_) => Future.value(
        FilePickerResult([
          PlatformFile(
            path: "test/resources/backups/legacy_ios_entities.zip",
            name: "no_journal.zip",
            size: 100,
          ),
        ]),
      ),
    );

    await tester.pumpWidget(Testable(
      (_) => defaultImporter(),
      appManager: appManager,
    ));
    await tapAndSettle(tester, find.text("CHOOSE FILE"));

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text("Success"), findsOneWidget);
  });

  testWidgets("onFinish called when import is successful", (tester) async {
    var importer = MockLegacyImporter();
    when(importer.legacyJsonResult).thenReturn(LegacyJsonResult());
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
    when(importer.legacyJsonResult).thenReturn(LegacyJsonResult());
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
