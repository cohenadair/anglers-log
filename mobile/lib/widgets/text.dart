import 'package:flutter/material.dart';
import 'package:mobile/res/style.dart';

class HeadingText extends StatelessWidget {
  final String _text;

  HeadingText(this._text);

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      style: Theme.of(context).textTheme.body2.copyWith(
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

class ErrorText extends StatelessWidget {
  final String text;

  ErrorText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: styleError,
    );
  }
}

/// Text that matches the primary label in a [ListTile].
class LabelText extends StatelessWidget {
  final String text;

  LabelText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.subhead,
    );
  }
}

class DisabledText extends StatelessWidget {
  final String text;

  DisabledText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: Theme.of(context).disabledColor),
    );
  }
}