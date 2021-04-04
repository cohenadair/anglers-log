import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../widgets/widget.dart';

class Button extends StatelessWidget {
  final String text;

  /// Set to `null` to disable the button.
  final VoidCallback? onPressed;
  final Icon? icon;
  final Color? color;

  Button({
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return icon == null
        ? ElevatedButton(
            child: _textWidget,
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              primary: color,
            ),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon!,
            label: _textWidget,
            style: ElevatedButton.styleFrom(
              primary: color,
            ),
          );
  }

  Widget get _textWidget => Text(text.toUpperCase());
}

/// A button wrapper meant to be used as an action in an [AppBar]. If this
/// button is to be rendered to the left of an [IconButton], such as an overflow
/// menu button, set [condensed] to true to remove extra padding.
///
/// This button can also be used as a [TextButton] replacement.
class ActionButton extends StatelessWidget {
  final double _floatingLetterSpacing = -0.5;

  final String? text;
  final VoidCallback? onPressed;
  final bool condensed;
  final bool floating;
  final Color? textColor;

  final String? _stringId;

  ActionButton({
    required this.text,
    this.onPressed,
    this.condensed = false,
    this.floating = false,
    this.textColor,
  }) : _stringId = null;

  ActionButton.done({
    this.onPressed,
    this.condensed = false,
    this.textColor,
    this.floating = false,
  })  : _stringId = "done",
        text = null;

  ActionButton.save({
    this.onPressed,
    this.condensed = false,
    this.textColor,
    this.floating = false,
  })  : _stringId = "save",
        text = null;

  ActionButton.cancel({
    this.onPressed,
    this.condensed = false,
    this.textColor,
    this.floating = false,
  })  : _stringId = "cancel",
        text = null;

  ActionButton.edit({
    this.onPressed,
    this.condensed = false,
    this.textColor,
    this.floating = false,
  })  : _stringId = "edit",
        text = null;

  @override
  Widget build(BuildContext context) {
    var textValue =
        (isNotEmpty(_stringId) ? Strings.of(context).fromId(_stringId!) : text)!
            .toUpperCase();

    Widget textWidget = Text(
      textValue,
      style: textColor == null ? null : TextStyle(color: textColor),
    );

    Widget child;
    if (floating) {
      child = FloatingActionButton(
        child: Text(
          textValue,
          style: TextStyle(
            letterSpacing: _floatingLetterSpacing,
          ),
        ),
        backgroundColor: Colors.white,
        onPressed: onPressed,
        mini: true,
      );
    } else {
      child = RawMaterialButton(
        constraints: BoxConstraints(),
        padding: EdgeInsets.all(condensed ? paddingSmall : paddingDefault),
        onPressed: onPressed,
        child: textWidget,
        shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
        textStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      );
    }

    return EnabledOpacity(
      enabled: onPressed != null,
      child: child,
    );
  }
}

/// An [ActionChip] wrapper.
class ChipButton extends StatelessWidget {
  final double iconSize = 20.0;
  final double fontSize = 13.0;

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  ChipButton({
    required this.label,
    this.icon,
    this.onPressed,
  }) : assert(isNotEmpty(label));

  @override
  Widget build(BuildContext context) {
    return ActionChip(
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
      onPressed: onPressed == null ? () {} : onPressed!,
    );
  }
}

/// An icon button Widget that breaks the Material [IconButton] padding/margin
/// requirement.
class MinimumIconButton extends StatelessWidget {
  final double size = 24.0;

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  MinimumIconButton({
    required this.icon,
    this.color,
    this.onTap,
  });

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
  static const double _fabSize = 40.0;

  final EdgeInsets? padding;
  final IconData icon;
  final String? label;
  final VoidCallback onPressed;

  /// When true, renders the button with a different background color, to
  /// imply the button has been "toggled".
  final bool pushed;

  FloatingIconButton({
    this.padding,
    required this.icon,
    required this.onPressed,
    this.label,
    this.pushed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? insetsDefault,
      child: Column(
        children: [
          Container(
            decoration: FloatingBoxDecoration.circle(),
            width: _fabSize,
            height: _fabSize,
            child: RawMaterialButton(
              child: Icon(
                icon,
                color: Colors.black,
              ),
              shape: CircleBorder(),
              fillColor: pushed ? Colors.grey : Colors.white,
              onPressed: onPressed,
            ),
          ),
          isNotEmpty(label)
              ? Padding(
                  padding: insetsTopSmall,
                  child: Text(
                    label!,
                    style: styleHeadingSmall,
                  ),
                )
              : Empty(),
        ],
      ),
    );
  }
}

class SmallTextButton extends StatelessWidget {
  static final _fontSize = 14.0;

  final String text;
  final VoidCallback? onPressed;

  SmallTextButton({
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: _fontSize,
          fontWeight: FontWeight.normal,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
