import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:quiver/strings.dart';

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

void showTextFieldAddDialog({
  @required BuildContext context,
  String title,
  String labelText,
  String initialError,
  FutureOr<String> Function(String) validate,
  void Function(String) onAdd,
}) {
  showDialog(
    context: context,
    builder: (context) => _TextFieldDialog(
      title: title,
      labelText: labelText,
      initialError: initialError,
      validate: validate,
      onAdd: onAdd,
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

class _TextFieldDialog extends StatefulWidget {
  final String title;
  final String labelText;
  final String initialError;
  final FutureOr<String> Function(String) validate;
  final void Function(String) onAdd;

  _TextFieldDialog({
    this.title,
    this.labelText,
    this.initialError,
    this.validate,
    this.onAdd,
  });

  @override
  _TextFieldDialogState createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<_TextFieldDialog> {
  final TextInputController _controller = TextInputController();

  bool get _valid => isEmpty(_controller.error(context));

  @override
  void initState() {
    super.initState();
    _controller.errorCallback = (_) => widget.initialError;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      titleTextStyle: styleTitleAlert,
      content: TextInput.name(context,
        controller: _controller,
        autofocus: true,
        onTextChange: _validateName,
      ),
      actions: <Widget>[
        _buildDialogButton(
          context: context,
          name: Strings.of(context).add,
          onTap: () => widget.onAdd?.call(_controller.value.text),
          enabled: _valid,
        ),
        _buildDialogButton(
          context: context,
          name: Strings.of(context).addAnother,
          popOnTap: false,
          onTap: () {
            widget.onAdd?.call(_controller.value.text);
            _controller.clearText();
          },
          enabled: _valid,
        ),
        _buildDialogButton(
          context: context,
          name: Strings.of(context).cancel,
        ),
      ],
    );
  }

  void _validateName() async {
    String error = await widget.validate(_controller.text);
    if (_controller.error(context) != error) {
      setState(() {
        _controller.errorCallback = (context) => error;
      });
    }
  }
}
