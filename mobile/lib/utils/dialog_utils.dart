import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/style.dart';

void showDeleteDialog({
  @required BuildContext context,
  String title,
  String description,
  VoidCallback onDelete
}) {
  _showDestructiveDialog(
    context: context,
    title: title,
    description: description,
    destroyText: Strings.of(context).delete,
    onTapDestroy: onDelete,
  );
}

void showConfirmYesDialog({
  @required BuildContext context,
  String description,
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
  String description,
  VoidCallback onContinue,
}) {
  _showDestructiveDialog(
    context: context,
    description: description,
    destroyText: Strings.of(context).continueString,
    onTapDestroy: onContinue,
  );
}

void showErrorDialog({
  @required BuildContext context,
  String description,
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
  String description,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: title == null ? null : Text(title),
      titleTextStyle: styleTitleAlert,
      content: description == null ? null : Text(description),
      actions: <Widget>[
        _buildDialogButton(context: context, name: Strings.of(context).ok),
      ],
    ),
  );
}

void _showDestructiveDialog({
  @required BuildContext context,
  String title,
  String description,
  String cancelText,
  String destroyText,
  VoidCallback onTapDestroy,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: title == null ? null : Text(title),
      titleTextStyle: styleTitleAlert,
      content: description == null ? null : Text(description),
      actions: <Widget>[
        _buildDialogButton(
          context: context,
          name: cancelText ?? Strings.of(context).cancel,
        ),
        _buildDialogButton(
          context: context,
          name: destroyText,
          textColor: Colors.red,
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
    onPressed: enabled ? () {
      onTap?.call();
      if (popOnTap) {
        Navigator.pop(context);
      }
    } : null,
  );
}
