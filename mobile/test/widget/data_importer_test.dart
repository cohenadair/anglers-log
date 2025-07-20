import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/channels/migration_channel.dart';
import 'package:mobile/database/legacy_importer.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/data_importer.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  var tmpPath = "test/resources/data_importer/tmp";
  late Directory tmpDir;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.baitCategoryManager.addOrUpdate(any),
    ).thenAnswer((_) => Future.value(true));

    when(
      managers.baitManager.addOrUpdate(
        any,
        imageFile: anyNamed("imageFile"),
        compressImages: anyNamed("compressImages"),
      ),
    ).thenAnswer((_) => Future.value(true));
    when(managers.baitManager.named(any)).thenReturn(null);

    when(
      managers.bodyOfWaterManager.addOrUpdate(any),
    ).thenAnswer((_) => Future.value(true));
    when(managers.bodyOfWaterManager.named(any)).thenReturn(null);

    when(
      managers.catchManager.addOrUpdate(
        any,
        imageFiles: anyNamed("imageFiles"),
        compressImages: anyNamed("compressImages"),
        notify: anyNamed("notify"),
      ),
    ).thenAnswer((_) => Future.value(true));

    when(
      managers.fishingSpotManager.addOrUpdate(any),
    ).thenAnswer((_) => Future.value(true));
    when(
      managers.fishingSpotManager.namedWithBodyOfWater(any, any),
    ).thenReturn(null);

    when(
      managers.filePickerWrapper.pickFiles(
        type: anyNamed("type"),
        allowedExtensions: anyNamed("allowedExtensions"),
      ),
    ).thenAnswer((_) => Future.value(null));

    when(managers.methodManager.named(any)).thenReturn(null);
    when(
      managers.methodManager.addOrUpdate(any),
    ).thenAnswer((_) => Future.value(true));

    when(
      managers.speciesManager.addOrUpdate(any),
    ).thenAnswer((_) => Future.value(true));
    when(managers.speciesManager.named(any)).thenReturn(
      Species()
        ..id = randomId()
        ..name = "Bass",
    );

    when(managers.waterClarityManager.named(any)).thenReturn(null);
    when(
      managers.waterClarityManager.addOrUpdate(any),
    ).thenAnswer((_) => Future.value(true));

    when(
      managers.pathProviderWrapper.temporaryPath,
    ).thenAnswer((_) => Future.value(tmpPath));

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
  }) => DataImporter(
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
    await tester.pumpWidget(Testable((_) => defaultImporter()));
    await tapAndSettle(tester, find.text("CHOOSE FILE"));

    verify(
      managers.filePickerWrapper.pickFiles(
        type: anyNamed("type"),
        allowedExtensions: anyNamed("allowedExtensions"),
      ),
    ).called(1);
  });

  testWidgets("Start button disabled while loading", (tester) async {
    when(
      managers.filePickerWrapper.pickFiles(
        type: anyNamed("type"),
        allowedExtensions: anyNamed("allowedExtensions"),
      ),
    ).thenAnswer(
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

    when(managers.pathProviderWrapper.temporaryPath).thenAnswer(
      (_) => Future.delayed(const Duration(milliseconds: 100), () => tmpPath),
    );

    await tester.pumpWidget(Testable((_) => defaultImporter()));
    await tester.tap(find.text("CHOOSE FILE"));
    await tester.pump();

    expect(findFirstWithText<Button>(tester, "CHOOSE FILE").onPressed, isNull);

    // Expire delayed future and verify start button is enabled again.
    await tester.pumpAndSettle(const Duration(milliseconds: 150));
    expect(
      findFirstWithText<Button>(tester, "CHOOSE FILE").onPressed,
      isNotNull,
    );
  });

  testWidgets("Show legacy json result error immediately", (tester) async {
    var importer = MockLegacyImporter();
    when(importer.legacyJsonResult).thenReturn(
      LegacyJsonResult(
        errorCode: LegacyJsonErrorCode.invalidJson,
        errorDescription: "E",
      ),
    );

    await tester.pumpWidget(
      Testable((_) => defaultImporter(importer: importer)),
    );
    await tapAndSettle(tester, find.text("START"));

    expect(find.text("Error"), findsOneWidget);
    verifyNever(importer.start());
  });

  testWidgets("Start button starts migration", (tester) async {
    var importer = MockLegacyImporter();
    when(importer.legacyJsonResult).thenReturn(LegacyJsonResult());
    when(
      importer.start(),
    ).thenAnswer((_) => Future.delayed(const Duration(milliseconds: 50)));

    await tester.pumpWidget(
      Testable((_) => defaultImporter(importer: importer)),
    );
    await tester.tap(find.text("START"));

    // Pump once so we can verify the loading description is shown.
    await tester.pump();
    expect(find.text("Loading"), findsOneWidget);

    // Finish import.
    await tester.pumpAndSettle();

    verifyNever(
      managers.filePickerWrapper.pickFiles(
        type: anyNamed("type"),
        allowedExtensions: anyNamed("allowedExtensions"),
      ),
    );
    verify(importer.start()).called(1);
  });

  testWidgets("Start button disabled when migration finishes", (tester) async {
    var importer = MockLegacyImporter();
    when(importer.legacyJsonResult).thenReturn(LegacyJsonResult());
    when(importer.start()).thenAnswer((_) => Future.value());

    await tester.pumpWidget(
      Testable((_) => defaultImporter(importer: importer)),
    );

    await tapAndSettle(tester, find.text("START"));
    expect(findFirstWithText<Button>(tester, "START").onPressed, isNull);
  });

  testWidgets("Null picked file resets state to none", (tester) async {
    when(
      managers.filePickerWrapper.pickFiles(
        type: anyNamed("type"),
        allowedExtensions: anyNamed("allowedExtensions"),
      ),
    ).thenAnswer((_) => Future.value(null));

    await tester.pumpWidget(Testable((_) => defaultImporter()));
    await tapAndSettle(tester, find.text("CHOOSE FILE"));

    expect(find.byType(Loading), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.error), findsNothing);
  });

  testWidgets("Invalid chosen data shows error", (tester) async {
    when(
      managers.filePickerWrapper.pickFiles(
        type: anyNamed("type"),
        allowedExtensions: anyNamed("allowedExtensions"),
      ),
    ).thenAnswer(
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

    await tester.pumpWidget(Testable((_) => defaultImporter()));
    await tapAndSettle(tester, find.text("CHOOSE FILE"));

    expect(find.byIcon(Icons.error), findsOneWidget);
    expect(find.text("Error"), findsOneWidget);
  });

  testWidgets("Feedback button shows feedback page", (tester) async {
    when(managers.userPreferenceManager.userName).thenReturn(null);
    when(managers.userPreferenceManager.userEmail).thenReturn(null);

    when(
      managers.filePickerWrapper.pickFiles(
        type: anyNamed("type"),
        allowedExtensions: anyNamed("allowedExtensions"),
      ),
    ).thenAnswer(
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

    await tester.pumpWidget(Testable((_) => defaultImporter()));

    await tapAndSettle(tester, find.text("CHOOSE FILE"));
    await tapAndSettle(tester, find.text("SEND REPORT"));

    expect(find.byType(FeedbackPage), findsOneWidget);
  });

  testWidgets("Successful import shows success widget", (tester) async {
    when(
      managers.filePickerWrapper.pickFiles(
        type: anyNamed("type"),
        allowedExtensions: anyNamed("allowedExtensions"),
      ),
    ).thenAnswer(
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

    await tester.pumpWidget(Testable((_) => defaultImporter()));
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
    await tester.pumpWidget(
      Testable(
        (_) => defaultImporter(
          importer: importer,
          onFinish: (success) {
            didSucceed = success;
            called = true;
          },
        ),
      ),
    );

    await tapAndSettle(tester, find.text("START"));
    expect(called, isTrue);
    expect(didSucceed, isTrue);
  });

  testWidgets("onFinish called when import is unsuccessful", (tester) async {
    var importer = MockLegacyImporter();
    when(importer.legacyJsonResult).thenReturn(LegacyJsonResult());
    when(importer.start()).thenAnswer(
      (_) => Future.error(LegacyImporterError.missingJournal, StackTrace.empty),
    );

    var called = false;
    var didSucceed = true;
    await tester.pumpWidget(
      Testable(
        (_) => defaultImporter(
          importer: importer,
          onFinish: (success) {
            didSucceed = success;
            called = true;
          },
        ),
      ),
    );

    await tapAndSettle(tester, find.text("START"));
    expect(called, isTrue);
    expect(didSucceed, isFalse);
  });
}
