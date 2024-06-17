import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/notification_manager.dart';
import 'package:mobile/pages/notification_permission_page.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late NotificationManager notificationManager;

  late StreamController<BackupRestoreProgress> progressController;

  setUp(() {
    appManager = StubbedAppManager();
    notificationManager = NotificationManager(appManager.app);

    progressController = StreamController<BackupRestoreProgress>.broadcast();
    when(appManager.backupRestoreManager.progressStream)
        .thenAnswer((_) => progressController.stream);

    var mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    when(mockNotificationsPlugin.initialize(
      any,
      onDidReceiveNotificationResponse:
          anyNamed("onDidReceiveNotificationResponse"),
    )).thenAnswer((_) => Future.value());
    when(appManager.localNotificationsWrapper.newInstance())
        .thenReturn(mockNotificationsPlugin);
  });

  test("Listens to backup progress stream", () async {
    await notificationManager.initialize();
    expect(progressController.hasListener, isTrue);
  });

  test("Notify exits early if auto-backup is not enabled", () async {
    when(appManager.userPreferenceManager.autoBackup).thenReturn(false);

    var eventCount = 0;
    notificationManager.stream.listen((_) => eventCount++);
    await notificationManager.initialize();

    progressController
        .add(BackupRestoreProgress(BackupRestoreProgressEnum.signedOut));
    await untilCalled(appManager.userPreferenceManager.autoBackup);

    expect(eventCount, 0);
    expect(notificationManager.activeNotifications.isEmpty, isTrue);
  });

  test("Notify exits early if backup event is not an error", () async {
    await notificationManager.initialize();

    var progress = MockBackupRestoreProgress();
    when(progress.isError).thenReturn(false);

    progressController.add(progress);
    await untilCalled(progress.isError);

    verifyNever(appManager.userPreferenceManager.autoBackup);
  });

  test("Listeners are notified on backup errors", () async {
    when(appManager.userPreferenceManager.autoBackup).thenReturn(true);
    await notificationManager.initialize();

    notificationManager.stream.listen(expectAsync1((event) {
      expect(event, LocalNotificationType.backupProgressError);
      expect(
        notificationManager.activeNotifications[0],
        LocalNotificationType.backupProgressError,
      );
    }));
    progressController
        .add(BackupRestoreProgress(BackupRestoreProgressEnum.signedOut));
  });

  testWidgets("Permission request exists early if user denied", (tester) async {
    when(appManager.permissionHandlerWrapper.isNotificationDenied)
        .thenAnswer((_) => Future.value(false));

    late BuildContext context;
    late DisposableTester testWidget;
    await pumpContext(
      tester,
      (con) {
        context = con;
        testWidget = const DisposableTester(child: Empty());
        return testWidget;
      },
      appManager: appManager,
    );

    await notificationManager.requestPermissionIfNeeded(
      testWidget.createState(),
      context,
    );
    await tester.pumpAndSettle();
    expect(find.byType(NotificationPermissionPage), findsNothing);
    verify(appManager.permissionHandlerWrapper.isNotificationDenied).called(1);
  });

  testWidgets("Permission request is issued", (tester) async {
    when(appManager.permissionHandlerWrapper.isNotificationDenied)
        .thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(Testable(
      (_) => PermissionRequestTester(notificationManager),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("TEST"));
    expect(find.byType(NotificationPermissionPage), findsOneWidget);
  });
}

class PermissionRequestTester extends StatefulWidget {
  NotificationManager notificationManager;

  PermissionRequestTester(this.notificationManager);

  @override
  State<PermissionRequestTester> createState() =>
      _PermissionRequestTesterState();
}

class _PermissionRequestTesterState extends State<PermissionRequestTester> {
  @override
  Widget build(BuildContext context) {
    return Button(
      text: "TEST",
      onPressed: () {
        widget.notificationManager.requestPermissionIfNeeded(
          this,
          context,
        );
      },
    );
  }
}
