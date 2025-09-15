import 'dart:async';

import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:adair_flutter_lib/pages/notification_permission_page.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/utils/page.dart';
import 'package:adair_flutter_lib/utils/widget.dart';
import 'package:adair_flutter_lib/wrappers/local_notifications_wrapper.dart';
import 'package:adair_flutter_lib/wrappers/permission_handler_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/l10n/l10n_extension.dart';
import 'package:mobile/user_preference_manager.dart';

import 'app_manager.dart';
import 'backup_restore_manager.dart';

enum LocalNotificationType { backupProgressError }

// TODO: Inherit from NotificationManagerBase and remove duplicate code.
class NotificationManager {
  static NotificationManager of(BuildContext context) =>
      AppManager.get.notificationManager;

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

  List<LocalNotificationType> get activeNotifications =>
      List.unmodifiable(_activeNotifications);

  Stream<LocalNotificationType> get stream => _controller.stream;

  Future<void> initialize() async {
    _flutterNotifications = LocalNotificationsWrapper.get.newInstance();
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
    BackupRestoreProgress progress,
  ) async {
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
    if (!(await PermissionHandlerWrapper.get.isNotificationDenied)) {
      return;
    }
    safeUseContext(
      state,
      () => present(
        context,
        NotificationPermissionPage(L10n.get.app.notificationPermissionPageDesc),
      ),
    );
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
