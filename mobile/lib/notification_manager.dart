import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/widget_utils.dart';
import 'package:mobile/wrappers/local_notifications_wrapper.dart';
import 'package:mobile/wrappers/permission_handler_wrapper.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'backup_restore_manager.dart';
import 'log.dart';
import 'pages/notification_permission_page.dart';
import 'utils/page_utils.dart';

enum LocalNotificationType {
  backupProgressError,
}

class NotificationManager {
  static NotificationManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).notificationManager;

  static const androidChannelIdBackup = "channel-id-backup";

  final _log = const Log("NotificationManager");
  final _activeNotifications = <LocalNotificationType>[];
  final _controller = StreamController<LocalNotificationType>.broadcast();
  final AppManager _appManager;

  // Called when a user taps a notification.
  VoidCallback? onDidReceiveNotificationResponse;
  late final FlutterLocalNotificationsPlugin _flutterNotifications;

  NotificationManager(this._appManager);

  BackupRestoreManager get _backupRestoreManager =>
      _appManager.backupRestoreManager;

  LocalNotificationsWrapper get _localNotificationsWrapper =>
      _appManager.localNotificationsWrapper;

  PermissionHandlerWrapper get _permissionHandlerWrapper =>
      _appManager.permissionHandlerWrapper;

  List<LocalNotificationType> get activeNotifications =>
      List.unmodifiable(_activeNotifications);

  Stream<LocalNotificationType> get stream => _controller.stream;

  Future<void> initialize() async {
    _flutterNotifications = _localNotificationsWrapper.newInstance();
    await _flutterNotifications.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(
          // Permission is requested when needed.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          requestCriticalPermission: false,
          requestProvisionalPermission: false,
        ),
        android: AndroidInitializationSettings("ic_notification"),
      ),
      onDidReceiveNotificationResponse: _onReceiveNotificationResponse,
    );

    _backupRestoreManager.progressStream.listen(_onBackupRestoreProgressEvent);
  }

  Future<void> _notifyBackup(LocalNotificationType notification) async {
    // Only notify of an auth issue if auto-backup is enabled.
    if (!UserPreferenceManager.get.autoBackup) {
      return;
    }

    _log.d("Notify for backup error");
    _activeNotifications.add(notification);
    _controller.add(notification);
  }

  Future<void> _onBackupRestoreProgressEvent(
      BackupRestoreProgress progress) async {
    if (!progress.isError) {
      return;
    }
    _notifyBackup(LocalNotificationType.backupProgressError);
  }

  void _onReceiveNotificationResponse(NotificationResponse details) {
    onDidReceiveNotificationResponse?.call();
  }

  /// If needed, [NotificationPermissionPage] is shown to the user, allowing
  /// them to deny or allow the app to send them local notifications.
  ///
  /// To by-pass the explanation (not recommended), use
  /// [PermissionHandlerWrapper.requestNotification].
  Future<void> requestPermissionIfNeeded(
    State state,
    BuildContext context,
  ) async {
    // Request notification permission if they've never been requested before.
    if (!(await _permissionHandlerWrapper.isNotificationDenied)) {
      return;
    }
    safeUseContext(state, () => present(context, NotificationPermissionPage()));
  }

  /// Shows a local notification. Wrapper for
  /// [FlutterLocalNotificationsPlugin.show].
  Future<void> show({
    String? title,
    String? body,
    NotificationDetails? details,
  }) {
    return _flutterNotifications.show(0, title, body, details);
  }

  void clear(LocalNotificationType type) {
    _activeNotifications.remove(type);
  }
}
