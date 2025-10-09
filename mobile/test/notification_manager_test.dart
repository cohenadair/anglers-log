import 'dart:async';

import 'package:adair_flutter_lib/pages/notification_permission_page.dart';
import 'package:adair_flutter_lib/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/notification_manager.dart';
import 'package:mockito/mockito.dart';

import '../../../adair-flutter-lib/test/mocks/mocks.mocks.dart';
import '../../../adair-flutter-lib/test/test_utils/disposable_tester.dart';
import '../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../adair-flutter-lib/test/test_utils/widget.dart';
import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_managers.dart';

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
      managers.lib.localNotificationsWrapper.newInstance(),
    ).thenReturn(mockNotificationsPlugin);
  });

  test("Listens to backup progress stream", () async {
    await notificationManager.init();
    expect(progressController.hasListener, isTrue);
  });

  test("Notify exits early if auto-backup is not enabled", () async {
    when(managers.userPreferenceManager.autoBackup).thenReturn(false);

    var eventCount = 0;
    notificationManager.stream.listen((_) => eventCount++);
    await notificationManager.init();

    progressController.add(
      BackupRestoreProgress(BackupRestoreProgressEnum.signedOut),
    );
    await untilCalled(managers.userPreferenceManager.autoBackup);

    expect(eventCount, 0);
    expect(notificationManager.activeNotifications.isEmpty, isTrue);
  });

  test("Notify exits early if backup event is not an error", () async {
    await notificationManager.init();

    var progress = MockBackupRestoreProgress();
    when(progress.isError).thenReturn(false);

    progressController.add(progress);
    await untilCalled(progress.isError);

    verifyNever(managers.userPreferenceManager.autoBackup);
  });

  test("Listeners are notified on backup errors", () async {
    when(managers.userPreferenceManager.autoBackup).thenReturn(true);
    await notificationManager.init();

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

  // TODO: Remove when NotificationManager inherits from lib.
  testWidgets("Permission request exists early if user denied", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isNotificationDenied,
    ).thenAnswer((_) => Future.value(false));
    when(
      managers.lib.permissionHandlerWrapper.isNotificationGranted,
    ).thenAnswer((_) => Future.value(true));

    late BuildContext context;
    late DisposableTester testWidget;
    await pumpContext(tester, (con) {
      context = con;
      testWidget = const DisposableTester(child: SizedBox());
      return testWidget;
    });

    await notificationManager.requestPermission(context);
    await tester.pumpAndSettle();
    expect(find.byType(NotificationPermissionPage), findsNothing);
    verify(
      managers.lib.permissionHandlerWrapper.isNotificationDenied,
    ).called(1);
  });

  // TODO: Remove when NotificationManager inherits from lib.
  testWidgets("Permission request is issued", (tester) async {
    when(
      managers.lib.permissionHandlerWrapper.isNotificationDenied,
    ).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(
      Testable((_) => PermissionRequestTester(notificationManager)),
    );

    await tapAndSettle(tester, find.text("TEST"));
    expect(find.byType(NotificationPermissionPage), findsOneWidget);
  });
}

// TODO: Remove when NotificationManager inherits from lib.
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
        widget.notificationManager.requestPermission(context);
      },
    );
  }
}
