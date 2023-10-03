import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../res/style.dart';

void showDiscardChangesDialog(BuildContext context, [VoidCallback? onDiscard]) {
  _showDestructiveDialog(
    context: context,
    description: Text(Strings.of(context).formPageConfirmBackDesc),
    destroyText: Strings.of(context).formPageConfirmBackAction,
    onTapDestroy: () {
      if (onDiscard == null) {
        Navigator.of(context).pop();
      } else {
        onDiscard();
      }
    },
  );
}

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
      titleTextStyle: styleTitleAlert(context),
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
      titleTextStyle: styleTitleAlert(context),
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
      titleTextStyle: styleTitleAlert(context),
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
        foregroundColor: textColor,
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
