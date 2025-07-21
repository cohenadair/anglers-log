import 'dart:async';

import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/pages/scroll_page.dart';
import 'package:adair_flutter_lib/res/anim.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/date_time.dart';
import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/notification_manager.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/device_utils.dart';
import 'package:mobile/widgets/async_feedback.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/cloud_auth.dart';
import 'package:mobile/widgets/label_value.dart';
import 'package:mobile/widgets/warning_container.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mobile/wrappers/url_launcher_wrapper.dart';
import 'package:quiver/strings.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/string_utils.dart';
import '../widgets/button.dart';

class BackupPage extends StatefulWidget {
  static const icon = Icons.cloud_upload;

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  BackupRestoreManager get _backupRestoreManager =>
      BackupRestoreManager.of(context);

  NotificationManager get _notificationManager =>
      NotificationManager.of(context);

  @override
  Widget build(BuildContext context) {
    return _BackupRestorePage(
      title: Strings.of(context).backupPageTitle,
      errorPageTitle: Strings.of(context).backupPageErrorTitle,
      actionLabel: Strings.of(context).backupPageAction,
      description: Strings.of(context).backupPageDescription,
      icon: BackupPage.icon,
      extra: _buildBackupDetails(context),
      onTapAction: _backupRestoreManager.backup,
    );
  }

  Widget _buildBackupDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProCheckboxInput(
          padding: insetsZero,
          label: Strings.of(context).backupPageAutoTitle,
          value: UserPreferenceManager.get.autoBackup,
          onSetValue: (checked) {
            UserPreferenceManager.get.setAutoBackup(checked);
            if (checked) {
              _notificationManager.requestPermissionIfNeeded(this, context);
            }
          },
        ),
        Container(height: paddingDefault),
        StreamBuilder(
          stream: UserPreferenceManager.get.stream,
          builder: (context, _) {
            var lastBackupAt = UserPreferenceManager.get.lastBackupAt;
            return LabelValue(
              padding: insetsZero,
              label: Strings.of(context).backupPageLastBackupLabel,
              value: lastBackupAt == null
                  ? Strings.of(context).backupPageLastBackupNever
                  : formatTimestamp(
                      context,
                      lastBackupAt,
                      TimeManager.get.currentTimeZone,
                    ),
            );
          },
        ),
      ],
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
  final String actionLabel;
  final String description;
  final IconData icon;

  /// Rendered before the description.
  final Widget? extra;

  final VoidCallback onTapAction;

  const _BackupRestorePage({
    required this.title,
    required this.errorPageTitle,
    required this.actionLabel,
    required this.description,
    required this.icon,
    this.extra,
    required this.onTapAction,
  });

  @override
  State<_BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<_BackupRestorePage> {
  static const _driveBackupUrl =
      "https://support.google.com/googleone/answer/9149304?hl=en&co=GENIE.Platform%3DAndroid";
  static const _iCloudBackupUrlPhone =
      "https://support.apple.com/en-ca/guide/iphone/iph3ecf67d29/ios";
  static const _iCloudBackupUrlPad =
      "https://support.apple.com/en-ca/guide/ipad/ipad9a74df05xx/ipados";

  late final StreamSubscription _authSubscription;
  late final StreamSubscription _progressSubscription;
  final _scrollController = ScrollController();

  var _progressState = AsyncFeedbackState.none;
  BackupRestoreProgress? _backupRestoreProgress;
  String? _progressDescription;
  String? _progressError;

  BackupRestoreManager get _backupRestoreManager =>
      BackupRestoreManager.of(context);

  @override
  void initState() {
    super.initState();

    _authSubscription = _backupRestoreManager.authStream.listen(
      (_) => setState(() => _backupRestoreManager.clearLastProgressError()),
    );
    _progressSubscription = _backupRestoreManager.progressStream.listen((
      progress,
    ) {
      setState(() => _backupRestoreProgress = progress);
      _postFrameScrollToBottom();
    });

    _backupRestoreProgress = _backupRestoreManager.lastProgressError;
    if (_backupRestoreManager.hasLastProgressError) {
      _postFrameScrollToBottom();
    }

    _backupRestoreManager.isBackupRestorePageShowing = true;
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _progressSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _updateProgressState();

    return ScrollPage(
      controller: _scrollController,
      appBar: TransparentAppBar(
        context,
        // Can't use CloseButton here because setting onPressed to null does
        // not disable the button.
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: AppConfig.get.colorAppTheme,
          onPressed: _backupRestoreManager.isInProgress ? null : _pop,
        ),
      ),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: WatermarkLogo(icon: widget.icon, title: widget.title),
        ),
        _buildDeprecationWarning(),
        _buildAuthWidget(),
        _buildActionWidget(),
      ],
    );
  }

  Widget _buildDeprecationWarning() {
    if (IoWrapper.get.isAndroid) {
      return _buildWarningContainer(
        Strings.of(context).backupRestorePageWarningGoogle,
        Future.value(_driveBackupUrl),
      );
    } else {
      return _buildWarningContainer(
        Strings.of(context).backupRestorePageWarningApple,
        _iCloudBackupUrl(),
      );
    }
  }

  Widget _buildWarningContainer(String text, Future<String> docUrl) {
    return Padding(
      padding: insetsHorizontalDefaultTopDefault,
      child: WarningContainer(
        children: [
          Text(text),
          Text(Strings.of(context).backupRestorePageWarningOwnRisk),
          Align(
            alignment: Alignment.center,
            child: Button(
              text: Strings.of(context).backupRestorePageOpenDoc,
              onPressed: () async => UrlLauncherWrapper.of(
                context,
              ).launch(await docUrl, mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.open_in_new),
              color: WarningContainer.buttonColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthWidget() {
    return const Column(
      children: [
        CloudAuth(padding: insetsDefault),
        MinDivider(),
      ],
    );
  }

  Widget _buildActionWidget() {
    Widget extra = const SizedBox();
    if (widget.extra != null) {
      extra = Padding(padding: insetsBottomDefault, child: widget.extra);
    }

    FeedbackPage? feedbackPage;
    if (isNotEmpty(_progressError)) {
      feedbackPage = FeedbackPage(
        title: widget.errorPageTitle,
        error: _progressError,
        attachment: "BackupRestorePage - ${_progressDescription ?? "Unknown"}",
      );
    }

    return Padding(
      padding: insetsDefault,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          extra,
          Text(widget.description, style: stylePrimary(context)),
          Container(height: paddingDefault),
          Center(
            child: AsyncFeedback(
              state: _progressState,
              description: _progressDescription,
              descriptionDetail: _progressError,
              actionText: widget.actionLabel,
              action: _backupRestoreManager.isSignedIn
                  ? widget.onTapAction
                  : null,
              feedbackPage: feedbackPage,
            ),
          ),
        ],
      ),
    );
  }

  void _updateProgressState() {
    if (_backupRestoreProgress == null) {
      return;
    }

    var progress = _backupRestoreProgress!;

    switch (progress.value) {
      case BackupRestoreProgressEnum.authClientError:
        _progressState = AsyncFeedbackState.error;
        _progressError = progress.value.toString();
        _progressDescription = Strings.of(context).backupRestoreAuthError;
        break;
      case BackupRestoreProgressEnum.createFolderError:
        _progressState = AsyncFeedbackState.error;
        _progressError = progress.value.toString();
        _progressDescription = Strings.of(
          context,
        ).backupRestoreCreateFolderError;
        break;
      case BackupRestoreProgressEnum.folderNotFound:
        _progressState = AsyncFeedbackState.error;
        _progressError = progress.value.toString();
        _progressDescription = Strings.of(context).backupRestoreFolderNotFound;
        break;
      case BackupRestoreProgressEnum.apiRequestError:
        _progressState = AsyncFeedbackState.error;
        _progressError =
            progress.apiError?.toString() ?? progress.value.toString();
        _progressDescription = Strings.of(context).backupRestoreApiRequestError;
        break;
      case BackupRestoreProgressEnum.databaseFileNotFound:
        _progressState = AsyncFeedbackState.error;
        _progressError = progress.value.toString();
        _progressDescription = Strings.of(
          context,
        ).backupRestoreDatabaseNotFound;
        break;
      case BackupRestoreProgressEnum.accessDenied:
        _progressState = AsyncFeedbackState.error;
        _progressError = null;
        _progressDescription = Strings.of(context).backupRestoreAccessDenied;
        break;
      case BackupRestoreProgressEnum.authenticating:
        _progressState = AsyncFeedbackState.loading;
        _progressError = null;
        _progressDescription = Strings.of(context).backupRestoreAuthenticating;
        break;
      case BackupRestoreProgressEnum.fetchingFiles:
        _progressState = AsyncFeedbackState.loading;
        _progressError = null;
        _progressDescription = Strings.of(context).backupRestoreFetchingFiles;
        break;
      case BackupRestoreProgressEnum.creatingFolder:
        _progressState = AsyncFeedbackState.loading;
        _progressError = null;
        _progressDescription = Strings.of(context).backupRestoreCreatingFolder;
        break;
      case BackupRestoreProgressEnum.backingUpDatabase:
        _progressState = AsyncFeedbackState.loading;
        _progressError = null;
        _progressDescription = Strings.of(
          context,
        ).backupRestoreBackingUpDatabase;
        break;
      case BackupRestoreProgressEnum.backingUpImages:
        _progressState = AsyncFeedbackState.loading;
        _progressError = null;
        _progressDescription = Strings.of(
          context,
        ).backupRestoreBackingUpImages(progress.percentageString);
        break;
      case BackupRestoreProgressEnum.restoringDatabase:
        _progressState = AsyncFeedbackState.loading;
        _progressError = null;
        _progressDescription = Strings.of(
          context,
        ).backupRestoreDownloadingDatabase;
        break;
      case BackupRestoreProgressEnum.restoringImages:
        _progressState = AsyncFeedbackState.loading;
        _progressError = null;
        _progressDescription = Strings.of(
          context,
        ).backupRestoreDownloadingImages(progress.percentageString);
        break;
      case BackupRestoreProgressEnum.reloadingData:
        _progressState = AsyncFeedbackState.loading;
        _progressError = null;
        _progressDescription = Strings.of(context).backupRestoreReloadingData;
        break;
      case BackupRestoreProgressEnum.finished:
        _progressState = AsyncFeedbackState.success;
        _progressError = null;
        _progressDescription = Strings.of(context).backupRestoreSuccess;
        break;
      case BackupRestoreProgressEnum.networkError:
        _progressState = AsyncFeedbackState.error;
        _progressError = progress.value.toString();
        _progressDescription = Strings.of(
          context,
        ).backupRestoreAutoNetworkError;
      case BackupRestoreProgressEnum.signedOut:
        _progressState = AsyncFeedbackState.error;
        _progressError = progress.value.toString();
        _progressDescription = Strings.of(
          context,
        ).backupRestoreAutoSignedOutError;
      case BackupRestoreProgressEnum.cleared:
        _progressState = AsyncFeedbackState.none;
        _progressError = null;
        _progressDescription = null;
        _backupRestoreProgress = null;
      case BackupRestoreProgressEnum.storageFull:
        _progressState = AsyncFeedbackState.error;
        _progressError = null;
        _progressDescription = Strings.of(context).backupRestoreStorageFull;
    }
  }

  void _postFrameScrollToBottom() {
    // Scroll to the bottom when the state updates. Depending on screen size,
    // users may not be able to see success or error messages.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: animDurationDefault,
        curve: Curves.linear,
      );
    });
  }

  void _pop() {
    _backupRestoreManager.clearLastProgressError();
    _backupRestoreManager.isBackupRestorePageShowing = false;
    Navigator.of(context).pop();
  }

  Future<String> _iCloudBackupUrl() async {
    return (await isPad()) ? _iCloudBackupUrlPad : _iCloudBackupUrlPhone;
  }
}
