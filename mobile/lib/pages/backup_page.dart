import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/backup_and_restore_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/widget.dart';

import 'scroll_page.dart';

class BackupPage extends StatefulWidget {
  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  late final StreamSubscription _authSubscription;
  late final StreamSubscription _progressSubscription;

  BackupAndRestoreProgress? _progress;
  BackupAndRestoreAuthState? _authState;

  BackupAndRestoreManager get _backupAndRestoreManager =>
      BackupAndRestoreManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  @override
  void initState() {
    super.initState();
    _authSubscription = _backupAndRestoreManager.authStream
        .listen((authState) => setState(() => _authState = authState));
    _progressSubscription = _backupAndRestoreManager.progressStream
        .listen((progress) => setState(() => _progress = progress));
  }

  @override
  void dispose() {
    super.dispose();
    _authSubscription.cancel();
    _progressSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      appBar: TransparentAppBar(context),
      extendBodyBehindAppBar: true,
      padding: insetsDefault,
      children: [
        _buildSignIn(),
        _authState == BackupAndRestoreAuthState.error
            ? Text(
                "Auth error",
                style: styleError(context),
              )
            : Empty(),
        Button(
          text: "Backup Now",
          onPressed: _backupAndRestoreManager.isSignedIn ? _backup : null,
        ),
        Text(
          "Last backup: ${_backupAndRestoreManager.lastBackupAt == null ? "Never" : formatTimestamp(context, _backupAndRestoreManager.lastBackupAt!)}",
        ),
        Button(
          text: "Restore Now",
          onPressed: _backupAndRestoreManager.isSignedIn ? _restore : null,
        ),
        Text(_progress?.value.toString() ?? "Not started"),
      ],
    );
  }

  Widget _buildSignIn() {
    if (_backupAndRestoreManager.isSignedIn) {
      return Row(
        children: [
          Text(_backupAndRestoreManager.currentUser!.email),
          Button(
            text: "Disconnect",
            onPressed: () => _userPreferenceManager.setDidSetupBackup(false),
          )
        ],
      );
    } else {
      return Button(
        text: "Connect Google Account",
        onPressed: () => _userPreferenceManager.setDidSetupBackup(true),
      );
    }
  }

  void _backup() {
    _backupAndRestoreManager.backup();
  }

  void _restore() {
    _backupAndRestoreManager.restore();
  }
}
