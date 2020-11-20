import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../res/style.dart';

void showDeleteDialog({
  @required BuildContext context,
  String title,
  Widget description,
  VoidCallback onDelete,
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
  @required BuildContext context,
  Widget description,
  VoidCallback onConfirm,
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
  @required BuildContext context,
  String title,
  Widget description,
  VoidCallback onContinue,
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
  @required BuildContext context,
  Widget description,
}) {
  showOkDialog(
    context: context,
    title: Strings.of(context).error,
    description: description,
  );
}

void showOkDialog({
  @required BuildContext context,
  String title,
  Widget description,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: title == null ? null : Text(title),
      titleTextStyle: styleTitleAlert,
      content: description == null ? null : description,
      actions: <Widget>[
        _buildDialogButton(context: context, name: Strings.of(context).ok),
      ],
    ),
  );
}

void _showDestructiveDialog({
  @required BuildContext context,
  String title,
  Widget description,
  String cancelText,
  String destroyText,
  VoidCallback onTapDestroy,
  bool warning = false,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: title == null ? null : Text(title),
      titleTextStyle: styleTitleAlert,
      content: description == null ? null : description,
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
  @required BuildContext context,
  @required String name,
  Color textColor,
  VoidCallback onTap,
  bool popOnTap = true,
  bool enabled = true,
}) {
  return FlatButton(
    child: Text(name.toUpperCase()),
    textColor: textColor,
    onPressed: enabled
        ? () {
            onTap?.call();
            if (popOnTap) {
              Navigator.pop(context);
            }
          }
        : null,
  );
}
