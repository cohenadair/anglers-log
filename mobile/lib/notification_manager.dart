import 'dart:async';

import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:adair_flutter_lib/managers/notification_manager_base.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:mobile/l10n/l10n_extension.dart';
import 'package:mobile/user_preference_manager.dart';

import 'app_manager.dart';
import 'backup_restore_manager.dart';

enum LocalNotificationType { backupProgressError }

class NotificationManager extends NotificationManagerBase {
  static NotificationManager of(BuildContext context) =>
      AppManager.get.notificationManager;

  static const idBackup = 1;
  static const androidChannelIdBackup = "channel-id-backup";

  final _log = const Log("NotificationManager");
  final _activeNotifications = <LocalNotificationType>[];
  final _controller = StreamController<LocalNotificationType>.broadcast();
  final AppManager _appManager;

  NotificationManager(this._appManager);

  BackupRestoreManager get _backupRestoreManager =>
      _appManager.backupRestoreManager;

  List<LocalNotificationType> get activeNotifications =>
      List.unmodifiable(_activeNotifications);

  Stream<LocalNotificationType> get stream => _controller.stream;

  @override
  Future<void> init() async {
    await super.init();
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

  Future<bool> requestPermission(BuildContext context) {
    return super.requestPermissionIfNeeded(
      context,
      L10n.get.app.notificationPermissionPageDesc,
    );
  }
}
