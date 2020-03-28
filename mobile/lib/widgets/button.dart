import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class Button extends StatelessWidget {
  final String text;

  /// Set to `null` to disable the button.
  final VoidCallback onPressed;
  final Icon icon;
  final Color color;

  Button({
    @required this.text,
    @required this.onPressed,
    this.icon,
    this.color,
  }) : assert(text != null);

  @override
  Widget build(BuildContext context) {
    return icon == null ? RaisedButton(
      child: _textWidget,
      onPressed: onPressed,
      color: color,
    ) : RaisedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: _textWidget,
      color: color,
    );
  }

  Widget get _textWidget => Text(text.toUpperCase());
}

/// A button wrapper meant to be used as an action in an [AppBar]. If this
/// button is to be rendered to the left of an [IconButton], such as an overflow
/// menu button, set [condensed] to true to remove extra padding.
class ActionButton extends StatelessWidget {
  final double defaultSize = 40;

  final String text;
  final VoidCallback onPressed;
  final bool condensed;
  final Color textColor;

  final String _stringId;

  ActionButton({
    @required this.text,
    this.onPressed,
    this.condensed = false,
    this.textColor,
  }) : _stringId = null;

  ActionButton.done({this.onPressed, this.condensed = false, this.textColor})
      : _stringId = "done",
        text = null;

  ActionButton.save({this.onPressed, this.condensed = false, this.textColor})
      : _stringId = "save",
        text = null;

  ActionButton.cancel({this.onPressed, this.condensed = false, this.textColor})
      : _stringId = "cancel",
        text = null;

  ActionButton.edit({this.onPressed, this.condensed = false, this.textColor})
      : _stringId = "edit",
        text = null;

  @override
  Widget build(BuildContext context) {
    Widget textWidget = Text(
      (text == null ? Strings.of(context).fromId(_stringId) : text)
          .toUpperCase(),
      style: textColor == null ? null : TextStyle(
        color: textColor
      ),
    );

    if (condensed) {
      return EnabledOpacity(
        enabled: onPressed != null,
        child: RawMaterialButton(
          constraints: BoxConstraints(),
          padding: EdgeInsets.all(paddingSmall),
          onPressed: onPressed,
          child: textWidget,
          shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          textStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      );
    } else {
      return FlatButton(
        child: textWidget,
        onPressed: onPressed,
      );
    }
  }
}

/// An [ActionChip] wrapper.
class ChipButton extends StatelessWidget {
  final double iconSize = 20.0;
  final double fontSize = 13.0;

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  ChipButton({
    @required this.label,
    this.icon,
    this.onPressed
  }) : assert(isNotEmpty(label));

  @override
  Widget build(BuildContext context) => ActionChip(
    avatar: Icon(
      icon,
      size: iconSize,
      color: Colors.black,
    ),
    label: Text(
      label,
      style: TextStyle(
        color: Colors.black,
        fontSize: fontSize,
        fontWeight: fontWeightBold,
      ),
    ),
    backgroundColor: Theme.of(context).accentColor,
    pressElevation: 1,
    onPressed: onPressed == null ? () {} : onPressed,
  );
}

/// An icon button Widget that breaks the Material [IconButton] padding/margin
/// requirement.
class MinimumIconButton extends StatelessWidget {
  final double size = 24.0;

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  MinimumIconButton({
    @required this.icon,
    this.color,
    this.onTap,
  }) : assert(icon != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: insetsZero,
      width: size,
      height: size,
      child: GestureDetector(
        onTap: onTap,
        child: Icon(
          icon,
          color: color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class FloatingIconButton extends StatelessWidget {
  final double size = 40.0;

  final EdgeInsets padding;
  final IconData icon;
  final VoidCallback onPressed;

  FloatingIconButton({
    this.padding,
    @required this.icon,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? insetsDefault,
      child: Container(
        decoration: FloatingBoxDecoration.circle(),
        width: size,
        height: size,
        child: RawMaterialButton(
          child: Icon(
            icon,
            color: Colors.black,
          ),
          shape: CircleBorder(),
          fillColor: Colors.white,
          onPressed: onPressed,
        ),
      ),
    );
  }

}