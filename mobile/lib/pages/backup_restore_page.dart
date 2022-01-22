import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mobile/pages/scroll_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/async_feedback.dart';
import 'package:mobile/widgets/cloud_auth.dart';
import 'package:mobile/widgets/widget.dart';

class BackupPage extends StatelessWidget {
  static const icon = Icons.cloud_upload;

  @override
  Widget build(BuildContext context) {
    return _BackupRestorePage(
      title: Strings.of(context).backupPageTitle,
      errorPageTitle: Strings.of(context).backupPageErrorTitle,
      actionLabel: Strings.of(context).backupPageAction,
      description: Strings.of(context).backupPageDescription,
      icon: icon,
      onTapAction: BackupRestoreManager.of(context).backup,
    );
  }
}

class RestorePage extends StatelessWidget {
  static const icon = Icons.cloud_download;

  @override
  Widget build(BuildContext context) {
    return _BackupRestorePage(
      title: Strings.of(context).restorePageTitle,
      errorPageTitle: Strings.of(context).restorePageErrorTitle,
      actionLabel: Strings.of(context).restorePageAction,
      description: Strings.of(context).restorePageDescription,
      icon: icon,
      onTapAction: BackupRestoreManager.of(context).restore,
    );
  }
}

class _BackupRestorePage extends StatefulWidget {
  final String title;
  final String errorPageTitle;
  final String? errorPageWarning;
  final String actionLabel;
  final String description;
  final IconData icon;
  final VoidCallback onTapAction;

  const _BackupRestorePage({
    required this.title,
    required this.errorPageTitle,
    this.errorPageWarning,
    required this.actionLabel,
    required this.description,
    required this.icon,
    required this.onTapAction,
  });

  @override
  State<_BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<_BackupRestorePage> {
  late final StreamSubscription _authSubscription;
  late final StreamSubscription _progressSubscription;

  var _inProgress = false;
  var _progressState = AsyncFeedbackState.none;
  String? _progressDescription;
  String? _progressError;

  BackupRestoreManager get _backupRestoreManager =>
      BackupRestoreManager.of(context);

  @override
  void initState() {
    super.initState();
    _authSubscription =
        _backupRestoreManager.authStream.listen((authState) => setState(() {}));

    _progressSubscription =
        _backupRestoreManager.progressStream.listen((progress) {
      setState(() {
        _inProgress = progress.value != BackupRestoreProgressEnum.finished;
        _updateProgressState(progress);
      });
    });
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
      appBar: TransparentAppBar(
        context,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: Theme.of(context).primaryColor,
          onPressed: _inProgress ? null : Navigator.of(context).pop,
        ),
      ),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: WatermarkLogo(
            icon: widget.icon,
            title: widget.title,
          ),
        ),
        _buildAuthWidget(),
        _buildActionWidget(),
      ],
    );
  }

  Widget _buildAuthWidget() {
    return Column(
      children: const [
        CloudAuth(padding: insetsDefault),
        MinDivider(),
      ],
    );
  }

  Widget _buildActionWidget() {
    return Padding(
      padding: insetsDefault,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.description,
            style: stylePrimary(context),
          ),
          const VerticalSpace(paddingDefault),
          Center(
            child: AsyncFeedback(
              state: _progressState,
              description: _progressDescription,
              actionText: widget.actionLabel,
              action: _backupRestoreManager.isSignedIn ? _performAction : null,
              feedbackPage: FeedbackPage(
                title: widget.errorPageTitle,
                error: _progressError,
                warningMessage: widget.errorPageWarning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performAction() {
    widget.onTapAction();
  }

  void _updateProgressState(BackupRestoreProgress progress) {
    switch (progress.value) {
      case BackupRestoreProgressEnum.authClientError:
        _progressState = AsyncFeedbackState.error;
        _progressError = progress.value.toString();
        _progressDescription = "Authentication error, please try again later.";
        break;
      case BackupRestoreProgressEnum.createFolderError:
        _progressState = AsyncFeedbackState.error;
        _progressError = progress.value.toString();
        _progressDescription =
            "Failed to create backup folder, please try again later.";
        break;
      case BackupRestoreProgressEnum.folderNotFound:
        _progressState = AsyncFeedbackState.error;
        _progressError = progress.value.toString();
        _progressDescription =
            "Backup folder not found. You must backup your data before it can be restored.";
        break;
      case BackupRestoreProgressEnum.apiRequestError:
        _progressState = AsyncFeedbackState.error;
        _progressError =
            progress.apiError?.toString() ?? progress.value.toString();
        _progressDescription =
            "Unknown error, please send Anglers' Log a report for investigation.";
        break;
      case BackupRestoreProgressEnum.databaseFileNotFound:
        _progressState = AsyncFeedbackState.error;
        _progressError = progress.value.toString();
        _progressDescription =
            "Backup data file not found. You must backup your data before it can be restored.";
        break;
      case BackupRestoreProgressEnum.authenticating:
        _progressState = AsyncFeedbackState.loading;
        _progressDescription = "Authenticating...";
        break;
      case BackupRestoreProgressEnum.fetchingFiles:
        _progressState = AsyncFeedbackState.loading;
        _progressDescription = "Fetching data...";
        break;
      case BackupRestoreProgressEnum.creatingFolder:
        _progressState = AsyncFeedbackState.loading;
        _progressDescription = "Creating backup folder...";
        break;
      case BackupRestoreProgressEnum.backingUpDatabase:
        _progressState = AsyncFeedbackState.loading;
        _progressDescription = "Backing up database...";
        break;
      case BackupRestoreProgressEnum.backingUpImages:
        _progressState = AsyncFeedbackState.loading;
        _progressDescription = "Backing up images "
            "${progress.percentage == null ? "" : "(${progress.percentage}%)"}"
            "...";
        break;
      case BackupRestoreProgressEnum.restoringDatabase:
        _progressState = AsyncFeedbackState.loading;
        _progressDescription = "Downloading database...";
        break;
      case BackupRestoreProgressEnum.restoringImages:
        _progressState = AsyncFeedbackState.loading;
        _progressDescription = "Downloading images "
            "${progress.percentage == null ? "" : "(${progress.percentage}%)"}"
            "...";
        break;
      case BackupRestoreProgressEnum.reloadingData:
        _progressState = AsyncFeedbackState.loading;
        _progressDescription = "Reloading data...";
        break;
      case BackupRestoreProgressEnum.finished:
        _progressState = AsyncFeedbackState.success;
        _progressDescription = "Success!";
        break;
    }
  }
}
