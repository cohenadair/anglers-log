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

    when(appManager.subscriptionManager.isPro).thenReturn(false);

    when(appManager.userPreferenceManager.autoBackup).thenReturn(false);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.userPreferenceManager.lastBackupAt).thenReturn(null);
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
        "An error occurred. The network may have been interrupted; please verify your internet connection and try again. If the issue persists, please send Anglers' Log a report for investigation.");

    await verifyProgressUpdate(
        tester,
        controller,
        BackupRestoreProgressEnum.accessDenied,
        "Anglers' Log doesn't have permission to backup your data. Please sign out and sign back in, ensuring the \"See, create, and delete its own configuration data in your Google Drive.\" box is checked, and try again.");

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
        "Anglers' Log doesn't have permission to backup your data. Please sign out and sign back in, ensuring the \"See, create, and delete its own configuration data in your Google Drive.\" box is checked, and try again.");

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
}
