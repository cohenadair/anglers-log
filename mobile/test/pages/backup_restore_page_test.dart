import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/pages/backup_restore_page.dart';
import 'package:mobile/widgets/async_feedback.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;
  late MockGoogleSignInAccount account;

  setUp(() async {
    managers = await StubbedManagers.create();

    account = MockGoogleSignInAccount();
    when(account.email).thenReturn("test@test.com");
    when(managers.backupRestoreManager.currentUser).thenReturn(account);
    when(managers.backupRestoreManager.isSignedIn).thenReturn(true);
    when(
      managers.backupRestoreManager.authStream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      managers.backupRestoreManager.progressStream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.backupRestoreManager.isInProgress).thenReturn(false);
    when(managers.backupRestoreManager.lastProgressError).thenReturn(null);
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(false);

    when(managers.lib.subscriptionManager.isPro).thenReturn(false);

    when(managers.userPreferenceManager.autoBackup).thenReturn(false);
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.userPreferenceManager.lastBackupAt).thenReturn(null);

    when(managers.lib.ioWrapper.isAndroid).thenReturn(true);
  });

  Future<void> sendProgressUpdate(
    WidgetTester tester,
    StreamController<BackupRestoreProgress> controller,
    BackupRestoreProgressEnum value,
  ) async {
    controller.add(BackupRestoreProgress(value));
    // Use pump() instead of pumpAndSettle() because a Loading() widget is
    // animating and will never settle.
    await tester.pump();
  }

  Future<void> verifyProgressUpdate(
    WidgetTester tester,
    StreamController<BackupRestoreProgress> controller,
    BackupRestoreProgressEnum value,
    String label,
  ) async {
    await sendProgressUpdate(tester, controller, value);
    expect(find.text(label), findsOneWidget);
  }

  testWidgets("BackupPage shows last backup as never", (tester) async {
    when(managers.userPreferenceManager.lastBackupAt).thenReturn(null);
    await pumpContext(tester, (_) => BackupPage());
    expect(find.text("Never"), findsOneWidget);
  });

  testWidgets("BackupPage shows last backup as a valid time", (tester) async {
    when(
      managers.userPreferenceManager.lastBackupAt,
    ).thenReturn(dateTime(2020, 1, 1).millisecondsSinceEpoch);
    await pumpContext(tester, (_) => BackupPage());
    expect(find.text("Jan 1, 2020 at 12:00 AM"), findsOneWidget);
  });

  testWidgets("Auth changes updates state", (tester) async {
    var controller = StreamController<BackupRestoreAuthState>.broadcast();
    var isSignedIn = false;
    MockGoogleSignInAccount? account;

    when(managers.backupRestoreManager.currentUser).thenAnswer((_) => account);
    when(
      managers.backupRestoreManager.isSignedIn,
    ).thenAnswer((_) => isSignedIn);
    when(
      managers.backupRestoreManager.authStream,
    ).thenAnswer((_) => controller.stream);

    await pumpContext(tester, (_) => BackupPage());

    // Verify action is disabled while signed out.
    expect(findFirst<AsyncFeedback>(tester).action, isNull);

    // Trigger sign in.
    isSignedIn = true;
    account = MockGoogleSignInAccount();
    when(account.email).thenReturn("test@test.com");
    controller.add(BackupRestoreAuthState.signedIn);
    await tester.pumpAndSettle();

    // Verify action is now clickable.
    expect(findFirst<AsyncFeedback>(tester).action, isNotNull);
    verify(managers.backupRestoreManager.clearLastProgressError()).called(1);
  });

  testWidgets("Close button is disabled when in progress", (tester) async {
    when(managers.backupRestoreManager.isInProgress).thenReturn(true);
    await pumpContext(tester, (_) => BackupPage());
    expect(findFirst<IconButton>(tester).onPressed, isNull);
  });

  testWidgets("Close button is enabled when idle", (tester) async {
    when(managers.backupRestoreManager.isInProgress).thenReturn(false);
    await pumpContext(tester, (_) => BackupPage());
    expect(findFirst<IconButton>(tester).onPressed, isNotNull);
  });

  testWidgets("Progress state changes", (tester) async {
    var controller = StreamController<BackupRestoreProgress>.broadcast(
      sync: true,
    );
    when(
      managers.backupRestoreManager.progressStream,
    ).thenAnswer((_) => controller.stream);

    await pumpContext(tester, (_) => BackupPage());

    await verifyProgressUpdate(
      tester,
      controller,
      .authClientError,
      "Authentication error, please try again later.",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .createFolderError,
      "Failed to create backup folder, please try again later.",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .folderNotFound,
      "Backup folder not found. You must backup your data before it can be restored.",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .apiRequestError,
      "The network may have been interrupted. Verify your internet connection and try again. If the issue persists, please send Anglers' Log a report for investigation.",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .accessDenied,
      "Anglers' Log doesn't have permission to backup your data. Please sign out and sign back in, ensuring the \"See, create, and delete its own configuration data in your Google Drive™.\" box is checked, and try again.",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .databaseFileNotFound,
      "Backup data file not found. You must backup your data before it can be restored.",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .authenticating,
      "Authenticating...",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .fetchingFiles,
      "Fetching data...",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .creatingFolder,
      "Creating backup folder...",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .backingUpData,
      "Backing up data...",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .restoringDatabase,
      "Downloading database...",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .restoringImages,
      "Downloading images...",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .reloadingData,
      "Reloading data...",
    );

    await verifyProgressUpdate(tester, controller, .finished, "Success!");

    await verifyProgressUpdate(
      tester,
      controller,
      .networkError,
      "Auto-backup failed due to a network connectivity issue. Please do a manual backup or wait for the next auto-backup attempt.",
    );

    await verifyProgressUpdate(
      tester,
      controller,
      .signedOut,
      "Auto-backup failed due to an authentication timeout. Please sign in again.",
    );

    await sendProgressUpdate(tester, controller, .cleared);
    expect(findFirst<AsyncFeedback>(tester).state, AsyncFeedbackState.none);
  });

  testWidgets("Access denied hides feedback button", (tester) async {
    var controller = StreamController<BackupRestoreProgress>.broadcast(
      sync: true,
    );
    when(
      managers.backupRestoreManager.progressStream,
    ).thenAnswer((_) => controller.stream);

    await pumpContext(tester, (_) => BackupPage());
    await verifyProgressUpdate(
      tester,
      controller,
      .accessDenied,
      "Anglers' Log doesn't have permission to backup your data. Please sign out and sign back in, ensuring the \"See, create, and delete its own configuration data in your Google Drive™.\" box is checked, and try again.",
    );

    expect(find.text("SEND REPORT"), findsNothing);
  });

  testWidgets("Storage full hides feedback button", (tester) async {
    var controller = StreamController<BackupRestoreProgress>.broadcast(
      sync: true,
    );
    when(
      managers.backupRestoreManager.progressStream,
    ).thenAnswer((_) => controller.stream);

    await pumpContext(tester, (_) => BackupPage());
    await verifyProgressUpdate(
      tester,
      controller,
      .storageFull,
      "Your Google Drive™ storage is full. Please free some space and try again.",
    );

    expect(find.text("SEND REPORT"), findsNothing);
  });

  testWidgets("Errors show feedback button", (tester) async {
    var controller = StreamController<BackupRestoreProgress>.broadcast(
      sync: true,
    );
    when(
      managers.backupRestoreManager.progressStream,
    ).thenAnswer((_) => controller.stream);

    await pumpContext(tester, (_) => BackupPage());
    await sendProgressUpdate(tester, controller, .apiRequestError);

    expect(find.text("SEND REPORT"), findsOneWidget);
  });

  testWidgets("Auto-backup checkbox", (tester) async {
    when(managers.lib.subscriptionManager.isPro).thenReturn(true);
    when(
      managers.notificationManager.requestPermission(any),
    ).thenAnswer((_) => Future.value(true));

    await pumpContext(tester, (_) => BackupPage());
    await tester.ensureVisible(find.byType(Checkbox));
    await tapAndSettle(tester, find.byType(Checkbox));

    // Enable auto-backup.
    verify(managers.userPreferenceManager.setAutoBackup(true)).called(1);
    verify(managers.notificationManager.requestPermission(any)).called(1);

    // Disable.
    await tapAndSettle(tester, find.byType(Checkbox));
    verify(managers.userPreferenceManager.setAutoBackup(false)).called(1);
    verifyNever(managers.notificationManager.requestPermission(any));
  });

  testWidgets("Backup progress error exists when page is shown", (
    tester,
  ) async {
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(true);
    when(
      managers.backupRestoreManager.lastProgressError,
    ).thenReturn(BackupRestoreProgress(.signedOut));

    await pumpContext(tester, (_) => BackupPage());

    verify(
      managers.backupRestoreManager.isBackupRestorePageShowing = true,
    ).called(1);
    expect(findFirst<AsyncFeedback>(tester).state, AsyncFeedbackState.error);
  });

  testWidgets("BackupRestoreManager state is reset on close", (tester) async {
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(true);
    when(
      managers.backupRestoreManager.lastProgressError,
    ).thenReturn(BackupRestoreProgress(.signedOut));

    await pumpContext(tester, (_) => BackupPage());
    await tapAndSettle(tester, find.byIcon(Icons.close));

    verify(managers.backupRestoreManager.clearLastProgressError()).called(1);
    verify(
      managers.backupRestoreManager.isBackupRestorePageShowing = false,
    ).called(1);
    expect(find.byType(BackupPage), findsNothing);
  });

  testWidgets("RestorePage", (tester) async {
    await pumpContext(tester, (_) => RestorePage());
    expect(find.text("Restore"), findsOneWidget);
  });

  testWidgets("Device backup: Android", (tester) async {
    when(managers.lib.ioWrapper.isAndroid).thenReturn(true);
    when(
      managers.urlLauncherWrapper.launch(any, mode: anyNamed("mode")),
    ).thenAnswer((_) => Future.value(true));

    await pumpContext(tester, (_) => RestorePage());
    await tapAndSettle(tester, find.text("OPEN DOCUMENTATION"));

    var result = verify(
      managers.urlLauncherWrapper.launch(captureAny, mode: anyNamed("mode")),
    );
    result.called(1);

    expect(result.captured.first, contains("support.google.com"));
  });

  testWidgets("Device backup: iPhone", (tester) async {
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);
    when(managers.lib.ioWrapper.isIOS).thenReturn(true);
    when(
      managers.urlLauncherWrapper.launch(any, mode: anyNamed("mode")),
    ).thenAnswer((_) => Future.value(true));
    stubIosDeviceInfo(managers.lib.deviceInfoWrapper, name: "iphone");

    await pumpContext(tester, (_) => RestorePage());
    await tapAndSettle(tester, find.text("OPEN DOCUMENTATION"));

    var result = verify(
      managers.urlLauncherWrapper.launch(captureAny, mode: anyNamed("mode")),
    );
    result.called(1);

    expect(result.captured.first, contains("ios"));
  });

  testWidgets("Device backup: iPad", (tester) async {
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);
    when(managers.lib.ioWrapper.isIOS).thenReturn(true);
    when(
      managers.urlLauncherWrapper.launch(any, mode: anyNamed("mode")),
    ).thenAnswer((_) => Future.value(true));
    stubIosDeviceInfo(managers.lib.deviceInfoWrapper, name: "ipad");

    await pumpContext(tester, (_) => RestorePage());
    await tapAndSettle(tester, find.text("OPEN DOCUMENTATION"));

    var result = verify(
      managers.urlLauncherWrapper.launch(captureAny, mode: anyNamed("mode")),
    );
    result.called(1);

    expect(result.captured.first, contains("ipados"));
  });
}
