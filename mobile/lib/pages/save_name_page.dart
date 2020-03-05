import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/pages/form_page.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:quiver/strings.dart';

/// A generic page for getting a "Name" input from the user.
class SaveNamePage extends StatefulWidget {
  final String title;

  /// Invoked when the "Save" button is pressed. The value entered is padded to
  /// this callback.
  final void Function(String) onSave;

  /// Invoked when the name input changes.
  final FutureOr<String> Function(String) validate;

  SaveNamePage({
    @required this.title,
    this.onSave,
    this.validate,
  });

  @override
  _SaveNamePageState createState() => _SaveNamePageState();
}

class _SaveNamePageState extends State<SaveNamePage> {
  final _controller = TextInputController(
    errorCallback: (context) => Strings.of(context).inputGenericRequired,
  );

  @override
  Widget build(BuildContext context) {
    return FormPage(
      title: widget.title,
      editable: false,
      onSave: () => widget.onSave?.call(_controller.text),
      fieldBuilder: (context, _) {
        return {
          Entity.keyName : TextInput.name(
            context,
            controller: _controller,
            autofocus: true,
            onTextChange: () async {
              String error = await widget.validate(_controller.text);
              if (_controller.error(context) != error) {
                setState(() {
                  _controller.errorCallback = (context) => error;
                });
              }
            },
          ),
        };
      },
      isInputValid: isEmpty(_controller.error(context)),
    );
  }
}