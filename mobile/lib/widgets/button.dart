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
  final String? text;
  final VoidCallback? onPressed;
  final bool condensed;
  final Color? textColor;

  final String? _stringId;

  ActionButton({
    required this.text,
    this.onPressed,
    this.condensed = false,
    this.textColor,
  }) : _stringId = null;

  ActionButton.done({
    this.onPressed,
    this.condensed = false,
    this.textColor,
  })  : _stringId = "done",
        text = null;

  ActionButton.save({
    this.onPressed,
    this.condensed = false,
    this.textColor,
  })  : _stringId = "save",
        text = null;

  ActionButton.cancel({
    this.onPressed,
    this.condensed = false,
    this.textColor,
  })  : _stringId = "cancel",
        text = null;

  ActionButton.edit({
    this.onPressed,
    this.condensed = false,
    this.textColor,
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

    Widget child = RawMaterialButton(
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

/// A button that appears to be floating on the screen. This is meant to look
/// similar to a [FloatingActionButton]; however, FABs serve a very specific
/// purpose in Material Design, and comes with some overhead to fulfil those
/// purposes. [FloatingButton] is a more lightweight solution that can be used
/// anywhere.
class FloatingButton extends StatelessWidget {
  static const double _fabSize = 40.0;

  final Key? key;
  final EdgeInsets? padding;

  /// The icon shown inside the "floating" part of the button. If null, [text]
  /// must not be empty.
  final IconData? icon;

  /// The text shown inside the "floating" part of the button. If null, [icon]
  /// must not be null.
  final String? text;

  /// A label shown below the "floating" part of the button.
  final String? label;

  final VoidCallback? onPressed;

  /// If true, the "floating" part of the button will be transparent. This is
  /// useful for animating between two [FloatingButton] when the widget
  /// beneath changes color.
  ///
  /// If [text] is not empty, and [transparentBackground] is true, consider
  /// using an [ActionButton] instead.
  final bool transparentBackground;

  /// When true, renders the button with a different background color, to
  /// imply the button has been "toggled".
  final bool pushed;

  final bool _isBackButton;
  final bool _isCloseButton;

  FloatingButton({
    this.key,
    this.padding,
    this.icon,
    this.text,
    this.onPressed,
    this.label,
    this.pushed = false,
    this.transparentBackground = false,
  })  : assert((icon == null && isNotEmpty(text)) ||
            (icon != null && isEmpty(text))),
        _isBackButton = false,
        _isCloseButton = false;

  FloatingButton.icon({
    this.key,
    this.padding,
    required this.icon,
    this.onPressed,
    this.label,
    this.pushed = false,
    this.transparentBackground = false,
  })  : _isBackButton = false,
        _isCloseButton = false,
        text = null;

  FloatingButton.back({
    this.key,
    this.padding,
    this.transparentBackground = false,
  })  : _isBackButton = true,
        _isCloseButton = false,
        onPressed = null,
        label = null,
        pushed = false,
        icon = null,
        text = null;

  FloatingButton.close({
    this.key,
    this.padding,
    this.transparentBackground = false,
  })  : _isBackButton = false,
        _isCloseButton = true,
        onPressed = null,
        label = null,
        pushed = false,
        icon = null,
        text = null;

  @override
  Widget build(BuildContext context) {
    Widget circleChild;
    if (_isBackButton) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        circleChild = Icon(Icons.arrow_back);
      } else {
        // The iOS back button icon is not centered, so add some padding.
        circleChild = Padding(
          padding: insetsLeftWidgetSmall,
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        );
      }
    } else if (isNotEmpty(text)) {
      circleChild = Text(text!.toUpperCase());
    } else {
      circleChild = Icon(
        _isCloseButton ? Icons.close : icon,
        color: Colors.black,
      );
    }

    return Padding(
      key: key,
      padding: padding ?? insetsDefault,
      child: Column(
        children: [
          Container(
            decoration:
                transparentBackground ? null : FloatingBoxDecoration.circle(),
            width: _fabSize,
            height: _fabSize,
            child: RawMaterialButton(
              child: circleChild,
              shape: CircleBorder(),
              fillColor: transparentBackground
                  ? null
                  : (pushed ? Colors.grey : Colors.white),
              onPressed: _isBackButton || _isCloseButton
                  ? () => Navigator.of(context).pop()
                  : onPressed,
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
