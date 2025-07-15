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
import 'mocks/stubbed_managers.dart';
import 'test_utils.dart';

void main() {
  late StubbedManagers managers;
  late NotificationManager notificationManager;

  late StreamController<BackupRestoreProgress> progressController;

  setUp(() async {
    managers = await StubbedManagers.create();
    notificationManager = NotificationManager(managers.app);

    progressController = StreamController<BackupRestoreProgress>.broadcast();
    when(
      managers.backupRestoreManager.progressStream,
    ).thenAnswer((_) => progressController.stream);

    var mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    when(
      mockNotificationsPlugin.initialize(
        any,
        onDidReceiveNotificationResponse: anyNamed(
          "onDidReceiveNotificationResponse",
        ),
      ),
    ).thenAnswer((_) => Future.value());
    when(
      managers.localNotificationsWrapper.newInstance(),
    ).thenReturn(mockNotificationsPlugin);
  });

  test("Listens to backup progress stream", () async {
    await notificationManager.initialize();
    expect(progressController.hasListener, isTrue);
  });

  test("Notify exits early if auto-backup is not enabled", () async {
    when(managers.userPreferenceManager.autoBackup).thenReturn(false);

    var eventCount = 0;
    notificationManager.stream.listen((_) => eventCount++);
    await notificationManager.initialize();

    progressController.add(
      BackupRestoreProgress(BackupRestoreProgressEnum.signedOut),
    );
    await untilCalled(managers.userPreferenceManager.autoBackup);

    expect(eventCount, 0);
    expect(notificationManager.activeNotifications.isEmpty, isTrue);
  });

  test("Notify exits early if backup event is not an error", () async {
    await notificationManager.initialize();

    var progress = MockBackupRestoreProgress();
    when(progress.isError).thenReturn(false);

    progressController.add(progress);
    await untilCalled(progress.isError);

    verifyNever(managers.userPreferenceManager.autoBackup);
  });

  test("Listeners are notified on backup errors", () async {
    when(managers.userPreferenceManager.autoBackup).thenReturn(true);
    await notificationManager.initialize();

    notificationManager.stream.listen(
      expectAsync1((event) {
        expect(event, LocalNotificationType.backupProgressError);
        expect(
          notificationManager.activeNotifications[0],
          LocalNotificationType.backupProgressError,
        );
      }),
    );
    progressController.add(
      BackupRestoreProgress(BackupRestoreProgressEnum.signedOut),
    );
  });

  testWidgets("Permission request exists early if user denied", (tester) async {
    when(
      managers.permissionHandlerWrapper.isNotificationDenied,
    ).thenAnswer((_) => Future.value(false));

    late BuildContext context;
    late DisposableTester testWidget;
    await pumpContext(tester, (con) {
      context = con;
      testWidget = const DisposableTester(child: Empty());
      return testWidget;
    });

    await notificationManager.requestPermissionIfNeeded(
      testWidget.createState(),
      context,
    );
    await tester.pumpAndSettle();
    expect(find.byType(NotificationPermissionPage), findsNothing);
    verify(managers.permissionHandlerWrapper.isNotificationDenied).called(1);
  });

  testWidgets("Permission request is issued", (tester) async {
    when(
      managers.permissionHandlerWrapper.isNotificationDenied,
    ).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(
      Testable((_) => PermissionRequestTester(notificationManager)),
    );

    await tapAndSettle(tester, find.text("TEST"));
    expect(find.byType(NotificationPermissionPage), findsOneWidget);
  });
}

class PermissionRequestTester extends StatefulWidget {
  final NotificationManager notificationManager;

  const PermissionRequestTester(this.notificationManager);

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
        widget.notificationManager.requestPermissionIfNeeded(this, context);
      },
    );
  }
}
