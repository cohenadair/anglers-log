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
        DialogButton(label: Strings.of(context).ok),
      ],
    ),
  );
}

Future<void> showCancelDialog(
  BuildContext context, {
  String? title,
  String? description,
  required String actionText,
  VoidCallback? onTapAction,
}) {
  assert(isNotEmpty(actionText));

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: isEmpty(title) ? null : Text(title!),
      titleTextStyle: styleTitleAlert,
      content: isEmpty(description) ? null : Text(description!),
      actions: <Widget>[
        DialogButton(
          label: Strings.of(context).cancel,
        ),
        DialogButton(
          label: actionText,
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
        DialogButton(
          label: Strings.of(context).rateDialogLater,
          onTap: () =>
              // Reset timer to prompt them again later.
              preferences.setRateTimerStartedAt(timeManager.currentTimestamp),
        ),
        DialogButton(
          label: Strings.of(context).rateDialogRate,
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
        DialogButton(
          label: cancelText ?? Strings.of(context).cancel,
        ),
        DialogButton(
          label: destroyText,
          textColor: warning ? null : Colors.red,
          onTap: onTapDestroy,
        ),
      ],
    ),
  );
}

class DialogButton extends StatelessWidget {
  final String label;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool popOnTap;
  final bool isEnabled;

  const DialogButton({
    required this.label,
    this.textColor,
    this.onTap,
    this.popOnTap = true,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: textColor,
      ),
      onPressed: isEnabled
          ? () {
              onTap?.call();
              if (popOnTap) {
                Navigator.pop(context);
              }
            }
          : null,
      child: Text(label.toUpperCase()),
    );
  }
}
