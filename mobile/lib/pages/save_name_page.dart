import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../pages/form_page.dart';
import '../utils/string_utils.dart';
import '../utils/validator.dart';
import '../widgets/input_controller.dart';
import '../widgets/text_input.dart';

/// A generic page for getting a "Name" input from the user.
class SaveNamePage extends StatefulWidget {
  /// See [AppBar.title].
  final Widget title;

  final String? oldName;

  /// Invoked when the "Save" button is pressed. The value entered is passed to
  /// this callback.
  ///
  /// See [FormPage.onSave].
  final bool Function(String?)? onSave;

  /// Invoked when the name input changes.
  final NameValidator? validator;

  const SaveNamePage({
    required this.title,
    this.oldName,
    this.onSave,
    this.validator,
  });

  @override
  SaveNamePageState createState() => SaveNamePageState();
}

class SaveNamePageState extends State<SaveNamePage> {
  late final TextInputController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextInputController(
      validator: NameValidator(
        nameExists: widget.validator?.nameExists,
        nameExistsMessage: widget.validator?.nameExistsMessage,
        oldName: widget.validator?.oldName ?? widget.oldName,
      ),
    );

    if (isNotEmpty(widget.oldName)) {
      _controller.value = widget.oldName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      title: widget.title,
      onSave: () {
        if (isNotEmpty(widget.oldName) &&
            isNotEmpty(_controller.value) &&
            equalsTrimmedIgnoreCase(widget.oldName!, _controller.value!)) {
          // If the name didn't change, act as though "back" or "cancel" was
          // pressed.
          return true;
        }

        if (widget.onSave == null || widget.onSave!(_controller.value)) {
          return true;
        }

        return false;
      },
      fieldBuilder: (context) => [
        TextInput.name(
          context,
          controller: _controller,
          autofocus: true,
          // Trigger "Save" button state refresh.
          onChanged: (_) => setState(() {}),
        ),
      ],
      isInputValid: _controller.isValid(context),
    );
  }
}
