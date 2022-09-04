import 'package:flutter/material.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../res/style.dart';
import '../time_manager.dart';
import '../user_preference_manager.dart';
import 'store_utils.dart';

void showDeleteDialog({
  required BuildContext context,
  String? title,
  Widget? description,
  VoidCallback? onDelete,
}) {
  _showDestructiveDialog(
    context: context,
    title: title ?? Strings.of(context).delete,
    description: description,
    destroyText: Strings.of(context).delete,
    onTapDestroy: onDelete,
  );
}

void showConfirmYesDialog({
  required BuildContext context,
  Widget? description,
  VoidCallback? onConfirm,
}) {
  _showDestructiveDialog(
    context: context,
    description: description,
    cancelText: Strings.of(context).no,
    destroyText: Strings.of(context).yes,
    onTapDestroy: onConfirm,
  );
}

void showWarningDialog({
  required BuildContext context,
  String? title,
  Widget? description,
  VoidCallback? onContinue,
}) {
  _showDestructiveDialog(
    context: context,
    title: title,
    description: description,
    destroyText: Strings.of(context).continueString,
    onTapDestroy: onContinue,
    warning: true,
  );
}

void showErrorDialog({
  required BuildContext context,
  Widget? description,
}) {
  showOkDialog(
    context: context,
    title: Strings.of(context).error,
    description: description,
  );
}

void showOkDialog({
  required BuildContext context,
  String? title,
  Widget? description,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: isEmpty(title) ? null : Text(title!),
      titleTextStyle: styleTitleAlert,
      content: description,
      actions: <Widget>[
        _buildDialogButton(context: context, name: Strings.of(context).ok),
      ],
    ),
  );
}

void showCancelDialog(
  BuildContext context, {
  String? title,
  String? description,
  required String actionText,
  VoidCallback? onTapAction,
}) {
  assert(isNotEmpty(actionText));

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: isEmpty(title) ? null : Text(title!),
      titleTextStyle: styleTitleAlert,
      content: isEmpty(description) ? null : Text(description!),
      actions: <Widget>[
        _buildDialogButton(
          context: context,
          name: Strings.of(context).cancel,
        ),
        _buildDialogButton(
          context: context,
          name: actionText,
          onTap: onTapAction,
        ),
      ],
    ),
  );
}

/// Returns true of the dialog asking the user to rate the app is shown; false
/// otherwise.
bool showRateDialogIfNeeded(BuildContext context) {
  var preferences = UserPreferenceManager.of(context);
  var timeManager = TimeManager.of(context);

  // Exit early if the user has already rated the app.
  if (preferences.didRateApp) {
    return false;
  }

  if (!isFrequencyTimerReady(
    timeManager: timeManager,
    timerStartedAt: preferences.rateTimerStartedAt,
    setTimer: preferences.setRateTimerStartedAt,
    frequency: (Duration.millisecondsPerDay * (365 / 4)).round(),
  )) {
    return false;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(Strings.of(context).rateDialogTitle),
      titleTextStyle: styleTitleAlert,
      content: Text(Strings.of(context).rateDialogDescription),
      actions: <Widget>[
        _buildDialogButton(
          context: context,
          name: Strings.of(context).rateDialogLater,
          onTap: () =>
              // Reset timer to prompt them again later.
              preferences.setRateTimerStartedAt(timeManager.currentTimestamp),
        ),
        _buildDialogButton(
          context: context,
          name: Strings.of(context).rateDialogRate,
          onTap: () {
            preferences.setDidRateApp(true);
            launchStore(context);
          },
        ),
      ],
    ),
  );

  return true;
}

void _showDestructiveDialog({
  required BuildContext context,
  String? title,
  Widget? description,
  String? cancelText,
  required String destroyText,
  VoidCallback? onTapDestroy,
  bool warning = false,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: title == null ? null : Text(title),
      titleTextStyle: styleTitleAlert,
      content: description,
      actions: <Widget>[
        _buildDialogButton(
          context: context,
          name: cancelText ?? Strings.of(context).cancel,
        ),
        _buildDialogButton(
          context: context,
          name: destroyText,
          textColor: warning ? null : Colors.red,
          onTap: onTapDestroy,
        ),
      ],
    ),
  );
}

Widget _buildDialogButton({
  required BuildContext context,
  required String name,
  Color? textColor,
  VoidCallback? onTap,
  bool popOnTap = true,
  bool enabled = true,
}) {
  return TextButton(
    style: TextButton.styleFrom(
      foregroundColor: textColor,
    ),
    onPressed: enabled
        ? () {
            onTap?.call();
            if (popOnTap) {
              Navigator.pop(context);
            }
          }
        : null,
    child: Text(name.toUpperCase()),
  );
}
