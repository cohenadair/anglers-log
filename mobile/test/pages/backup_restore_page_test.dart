import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/pages/backup_restore_page.dart';
import 'package:mobile/widgets/async_feedback.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late MockGoogleSignInAccount account;

  setUp(() {
    appManager = StubbedAppManager();

    account = MockGoogleSignInAccount();
    when(account.email).thenReturn("test@test.com");
    when(appManager.backupRestoreManager.currentUser).thenReturn(account);
    when(appManager.backupRestoreManager.isSignedIn).thenReturn(true);
    when(appManager.backupRestoreManager.authStream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.backupRestoreManager.progressStream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.backupRestoreManager.isInProgress).thenReturn(false);
    when(appManager.backupRestoreManager.lastProgressError).thenReturn(null);
    when(appManager.backupRestoreManager.hasLastProgressError)
        .thenReturn(false);

    when(appManager.subscriptionManager.isPro).thenReturn(false);

    when(appManager.userPreferenceManager.autoBackup).thenReturn(false);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.userPreferenceManager.lastBackupAt).thenReturn(null);

    when(appManager.ioWrapper.isAndroid).thenReturn(true);
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
    when(appManager.userPreferenceManager.lastBackupAt).thenReturn(null);
    await pumpContext(tester, (_) => BackupPage(), appManager: appManager);
    expect(find.text("Never"), findsOneWidget);
  });

  testWidgets("BackupPage shows last backup as a valid time", (tester) async {
    when(appManager.userPreferenceManager.lastBackupAt)
        .thenReturn(dateTime(2020, 1, 1).millisecondsSinceEpoch);
    await pumpContext(tester, (_) => BackupPage(), appManager: appManager);
    expect(find.text("Jan 1, 2020 at 12:00 AM"), findsOneWidget);
  });

  testWidgets("Auth changes updates state", (tester) async {
    var controller = StreamController<BackupRestoreAuthState>.broadcast();
    var isSignedIn = false;
    MockGoogleSignInAccount? account;

    when(appManager.backupRestoreManager.currentUser)
        .thenAnswer((_) => account);
    when(appManager.backupRestoreManager.isSignedIn)
        .thenAnswer((_) => isSignedIn);
    when(appManager.backupRestoreManager.authStream)
        .thenAnswer((_) => controller.stream);

    await pumpContext(tester, (_) => BackupPage(), appManager: appManager);

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
    verify(appManager.backupRestoreManager.clearLastProgressError()).called(1);
  });

  testWidgets("Close button is disabled when in progress", (tester) async {
    when(appManager.backupRestoreManager.isInProgress).thenReturn(true);
    await pumpContext(tester, (_) => BackupPage(), appManager: appManager);
    expect(findFirst<IconButton>(tester).onPressed, isNull);
  });

  testWidgets("Close button is enabled when idle", (tester) async {
    when(appManager.backupRestoreManager.isInProgress).thenReturn(false);
    await pumpContext(tester, (_) => BackupPage(), appManager: appManager);
    expect(findFirst<IconButton>(tester).onPressed, isNotNull);
  });

  testWidgets("Progress state changes", (tester) async {
    var controller =
        StreamController<BackupRestoreProgress>.broadcast(sync: true);
    when(appManager.backupRestoreManager.progressStream)
        .thenAnswer((_) => controller.stream);

    await pumpContext(tester, (_) => BackupPage(), appManager: appManager);

    await verifyProgressUpdate(
        tester,
        controller,
        BackupRestoreProgressEnum.authClientError,
        "Authentication error, please try again later.");

    await verifyProgressUpdate(
        tester,
        controller,
        BackupRestoreProgressEnum.createFolderError,
        "Failed to create backup folder, please try again later.");

    await verifyProgressUpdate(
        tester,
        controller,
        BackupRestoreProgressEnum.folderNotFound,
        "Backup folder not found. You must backup your data before it can be restored.");

    await verifyProgressUpdate(
        tester,
        controller,
        BackupRestoreProgressEnum.apiRequestError,
        "The network may have been interrupted. Verify your internet connection and try again. If the issue persists, please send Anglers' Log a report for investigation.");

    await verifyProgressUpdate(
        tester,
        controller,
        BackupRestoreProgressEnum.accessDenied,
        "Anglers' Log doesn't have permission to backup your data. Please sign out and sign back in, ensuring the \"See, create, and delete its own configuration data in your Google Drive™.\" box is checked, and try again.");

    await verifyProgressUpdate(
        tester,
        controller,
        BackupRestoreProgressEnum.databaseFileNotFound,
        "Backup data file not found. You must backup your data before it can be restored.");

    await verifyProgressUpdate(tester, controller,
        BackupRestoreProgressEnum.authenticating, "Authenticating...");

    await verifyProgressUpdate(tester, controller,
        BackupRestoreProgressEnum.fetchingFiles, "Fetching data...");

    await verifyProgressUpdate(tester, controller,
        BackupRestoreProgressEnum.creatingFolder, "Creating backup folder...");

    await verifyProgressUpdate(tester, controller,
        BackupRestoreProgressEnum.backingUpDatabase, "Backing up database...");

    await verifyProgressUpdate(tester, controller,
        BackupRestoreProgressEnum.backingUpImages, "Backing up images...");

    await verifyProgressUpdate(tester, controller,
        BackupRestoreProgressEnum.restoringDatabase, "Downloading database...");

    await verifyProgressUpdate(tester, controller,
        BackupRestoreProgressEnum.restoringImages, "Downloading images...");

    await verifyProgressUpdate(tester, controller,
        BackupRestoreProgressEnum.reloadingData, "Reloading data...");

    await verifyProgressUpdate(
        tester, controller, BackupRestoreProgressEnum.finished, "Success!");

    await verifyProgressUpdate(
        tester,
        controller,
        BackupRestoreProgressEnum.networkError,
        "Auto-backup failed due to a network connectivity issue. Please do a manual backup or wait for the next auto-backup attempt.");

    await verifyProgressUpdate(
        tester,
        controller,
        BackupRestoreProgressEnum.signedOut,
        "Auto-backup failed due to an authentication timeout. Please sign in again.");

    await sendProgressUpdate(
        tester, controller, BackupRestoreProgressEnum.cleared);
    expect(findFirst<AsyncFeedback>(tester).state, AsyncFeedbackState.none);
  });

  testWidgets("Access denied hides feedback button", (tester) async {
    var controller =
        StreamController<BackupRestoreProgress>.broadcast(sync: true);
    when(appManager.backupRestoreManager.progressStream)
        .thenAnswer((_) => controller.stream);

    await pumpContext(tester, (_) => BackupPage(), appManager: appManager);
    await verifyProgressUpdate(
      tester,
      controller,
      BackupRestoreProgressEnum.accessDenied,
      "Anglers' Log doesn't have permission to backup your data. Please sign out and sign back in, ensuring the \"See, create, and delete its own configuration data in your Google Drive™.\" box is checked, and try again.",
    );

    expect(find.text("SEND REPORT"), findsNothing);
  });

  testWidgets("Storage full hides feedback button", (tester) async {
    var controller =
        StreamController<BackupRestoreProgress>.broadcast(sync: true);
    when(appManager.backupRestoreManager.progressStream)
        .thenAnswer((_) => controller.stream);

    await pumpContext(tester, (_) => BackupPage(), appManager: appManager);
    await verifyProgressUpdate(
      tester,
      controller,
      BackupRestoreProgressEnum.storageFull,
      "Your Google Drive™ storage is full. Please free some space and try again.",
    );

    expect(find.text("SEND REPORT"), findsNothing);
  });

  testWidgets("Errors show feedback button", (tester) async {
    var controller =
        StreamController<BackupRestoreProgress>.broadcast(sync: true);
    when(appManager.backupRestoreManager.progressStream)
        .thenAnswer((_) => controller.stream);

    await pumpContext(tester, (_) => BackupPage(), appManager: appManager);
    await sendProgressUpdate(
        tester, controller, BackupRestoreProgressEnum.apiRequestError);

    expect(find.text("SEND REPORT"), findsOneWidget);
  });

  testWidgets("Auto-backup checkbox", (tester) async {
    when(appManager.subscriptionManager.isPro).thenReturn(true);

    await pumpContext(tester, (_) => BackupPage(), appManager: appManager);
    await tester.ensureVisible(find.byType(Checkbox));
    await tapAndSettle(tester, find.byType(Checkbox));

    // Enable auto-backup.
    verify(appManager.userPreferenceManager.setAutoBackup(true)).called(1);
    verify(appManager.notificationManager.requestPermissionIfNeeded(any, any))
        .called(1);

    // Disable.
    await tapAndSettle(tester, find.byType(Checkbox));
    verify(appManager.userPreferenceManager.setAutoBackup(false)).called(1);
    verifyNever(
        appManager.notificationManager.requestPermissionIfNeeded(any, any));
  });

  testWidgets("Backup progress error exists when page is shown",
      (tester) async {
    when(appManager.backupRestoreManager.hasLastProgressError).thenReturn(true);
    when(appManager.backupRestoreManager.lastProgressError)
        .thenReturn(BackupRestoreProgress(BackupRestoreProgressEnum.signedOut));

    await pumpContext(tester, (_) => BackupPage(), appManager: appManager);

    verify(appManager.backupRestoreManager.isBackupRestorePageShowing = true)
        .called(1);
    expect(findFirst<AsyncFeedback>(tester).state, AsyncFeedbackState.error);
  });

  testWidgets("BackupRestoreManager state is reset on close", (tester) async {
    when(appManager.backupRestoreManager.hasLastProgressError).thenReturn(true);
    when(appManager.backupRestoreManager.lastProgressError)
        .thenReturn(BackupRestoreProgress(BackupRestoreProgressEnum.signedOut));

    await pumpContext(tester, (_) => BackupPage(), appManager: appManager);
    await tapAndSettle(tester, find.byIcon(Icons.close));

    verify(appManager.backupRestoreManager.clearLastProgressError()).called(1);
    verify(appManager.backupRestoreManager.isBackupRestorePageShowing = false)
        .called(1);
    expect(find.byType(BackupPage), findsNothing);
  });

  testWidgets("RestorePage", (tester) async {
    await pumpContext(tester, (_) => RestorePage(), appManager: appManager);
    expect(find.text("Restore"), findsOneWidget);
  });

  testWidgets("Device backup: Android", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(true);
    when(appManager.urlLauncherWrapper.launch(any, mode: anyNamed("mode")))
        .thenAnswer((_) => Future.value(true));

    await pumpContext(tester, (_) => RestorePage(), appManager: appManager);
    await tapAndSettle(tester, find.text("OPEN DOCUMENTATION"));

    var result = verify(appManager.urlLauncherWrapper
        .launch(captureAny, mode: anyNamed("mode")));
    result.called(1);

    expect(result.captured.first, contains("support.google.com"));
  });

  testWidgets("Device backup: iPhone", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(false);
    when(appManager.ioWrapper.isIOS).thenReturn(true);
    when(appManager.urlLauncherWrapper.launch(any, mode: anyNamed("mode")))
        .thenAnswer((_) => Future.value(true));
    stubIosDeviceInfo(appManager.deviceInfoWrapper, name: "iphone");

    await pumpContext(tester, (_) => RestorePage(), appManager: appManager);
    await tapAndSettle(tester, find.text("OPEN DOCUMENTATION"));

    var result = verify(appManager.urlLauncherWrapper
        .launch(captureAny, mode: anyNamed("mode")));
    result.called(1);

    expect(result.captured.first, contains("ios"));
  });

  testWidgets("Device backup: iPad", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(false);
    when(appManager.ioWrapper.isIOS).thenReturn(true);
    when(appManager.urlLauncherWrapper.launch(any, mode: anyNamed("mode")))
        .thenAnswer((_) => Future.value(true));
    stubIosDeviceInfo(appManager.deviceInfoWrapper, name: "ipad");

    await pumpContext(tester, (_) => RestorePage(), appManager: appManager);
    await tapAndSettle(tester, find.text("OPEN DOCUMENTATION"));

    var result = verify(appManager.urlLauncherWrapper
        .launch(captureAny, mode: anyNamed("mode")));
    result.called(1);

    expect(result.captured.first, contains("ipados"));
  });
}
