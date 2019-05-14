import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';

class Button extends StatelessWidget {
  final String _text;
  final VoidCallback _onPressed;
  final Icon _icon;
  final Color _color;

  Button({
    @required String text,
    @required VoidCallback onPressed,
    Icon icon,
    Color color,
  }) : assert(text != null),
       assert(onPressed != null),
       _text = text,
       _onPressed = onPressed,
       _icon = icon,
       _color = color;

  @override
  Widget build(BuildContext context) {
    return _icon == null ? RaisedButton(
      child: _textWidget,
      onPressed: _onPressed,
      color: _color,
    ) : RaisedButton.icon(
      onPressed: _onPressed,
      icon: _icon,
      label: _textWidget,
      color: _color,
    );
  }

  Widget get _textWidget => Text(_text.toUpperCase());
}

/// A [FlatButton] wrapper meant to be used as an action in an [AppBar].
class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  final String _stringId;

  ActionButton({
    @required this.text,
    this.onPressed,
  }) : _stringId = null;

  ActionButton.done({this.onPressed})
      : _stringId = "done",
        text = null;

  ActionButton.save({this.onPressed})
      : _stringId = "save",
        text = null;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPressed,
      child: Text((text == null ? Strings.of(context).fromId(_stringId) : text)
          .toUpperCase()
      ),
      textColor: Colors.white,
    );
  }
}