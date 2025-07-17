import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/widgets/floating_container.dart';
import 'package:quiver/strings.dart';

import '../res/style.dart';
import '../utils/share_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/widget.dart';

class Button extends StatelessWidget {
  final String text;

  /// Set to `null` to disable the button.
  final VoidCallback? onPressed;
  final Icon? icon;
  final Color? color;

  const Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return icon == null
        ? ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: _textWidget,
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon!,
            label: _textWidget,
            style: ElevatedButton.styleFrom(backgroundColor: color),
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
  final String text;
  final VoidCallback? onPressed;
  final bool condensed;
  final Color? textColor;

  ActionButton({
    required this.text,
    this.onPressed,
    this.condensed = false,
    this.textColor,
  }) : assert(text.isNotEmpty);

  ActionButton.done(
    BuildContext context, {
    this.onPressed,
    this.condensed = false,
    this.textColor,
  }) : text = Strings.of(context).done;

  ActionButton.save(
    BuildContext context, {
    this.onPressed,
    this.condensed = false,
    this.textColor,
  }) : text = Strings.of(context).save;

  ActionButton.cancel(
    BuildContext context, {
    this.onPressed,
    this.condensed = false,
    this.textColor,
  }) : text = L10n.get.lib.cancel;

  ActionButton.edit(
    BuildContext context, {
    this.onPressed,
    this.condensed = false,
    this.textColor,
  }) : text = Strings.of(context).edit;

  @override
  Widget build(BuildContext context) {
    Widget textWidget = Text(
      text.toUpperCase(),
      style: textColor == null ? null : TextStyle(color: textColor),
    );

    Widget child = RawMaterialButton(
      constraints: const BoxConstraints(),
      padding: EdgeInsets.all(condensed ? paddingSmall : paddingDefault),
      onPressed: onPressed,
      shape: const CircleBorder(side: BorderSide(color: Colors.transparent)),
      textStyle: TextStyle(
        fontWeight: FontWeight.w500,
        color: context.colorAppBarContent,
      ),
      child: textWidget,
    );

    return EnabledOpacity(isEnabled: onPressed != null, child: child);
  }
}

/// An [ActionChip] wrapper.
class ChipButton extends StatelessWidget {
  final double iconSize = 20.0;
  final double fontSize = 13.0;

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  ChipButton({required this.label, this.icon, this.onPressed})
    : assert(isNotEmpty(label));

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: icon == null
          ? null
          : Icon(icon, size: iconSize, color: Colors.black),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: fontWeightBold,
        ),
      ),
      backgroundColor: AppConfig.get.colorAppTheme,
      disabledColor: AppConfig.get.colorAppTheme,
      pressElevation: 1,
      onPressed: onPressed,
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

  const MinimumIconButton({required this.icon, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: insetsZero,
      width: size,
      height: size,
      child: InkWell(
        onTap: onTap,
        child: Icon(
          icon,
          color: onTap == null
              ? Theme.of(context).disabledColor
              : color ?? AppConfig.get.colorAppTheme,
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
  static const double _androidShareOffset = -1.5;
  static const double _iosShareOffset = -1.0;
  static const double _sizeSmallButton = 24.0;
  static const double _sizeSmallIcon = 16.0;
  static const double _sizeDefault = 40.0;

  final EdgeInsets? padding;

  /// The icon shown inside the "floating" part of the button. If null, [text]
  /// must not be empty.
  final IconData? icon;

  /// The size of the icon inside the button. Defaults to null.
  final double? iconSize;

  /// Offsets the icon inside the floating button. Used for icons that don't
  /// quite look centered.
  final double? iconOffsetX;

  /// Offsets the icon inside the floating button. Used for icons that don't
  /// quite look centered.
  final double? iconOffsetY;

  /// The text shown inside the "floating" part of the button. If null, [icon]
  /// must not be null.
  final String? text;

  /// A label shown below the "floating" part of the button.
  final String? label;

  /// The size of the overall button. Defaults to null.
  final double? size;

  /// See [Tooltip.message].
  final String? tooltip;

  final VoidCallback? onPressed;

  /// See [FloatingContainer.isTransparent].
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
    super.key,
    this.padding,
    this.icon,
    this.iconOffsetX,
    this.iconOffsetY,
    this.text,
    this.onPressed,
    this.label,
    this.pushed = false,
    this.transparentBackground = false,
    this.tooltip,
  }) : assert(
         (icon == null && isNotEmpty(text)) || (icon != null && isEmpty(text)),
       ),
       _isBackButton = false,
       _isCloseButton = false,
       iconSize = null,
       size = null;

  const FloatingButton.icon({
    super.key,
    this.padding,
    required this.icon,
    this.iconOffsetX,
    this.iconOffsetY,
    this.onPressed,
    this.label,
    this.pushed = false,
    this.transparentBackground = false,
    this.tooltip,
  }) : _isBackButton = false,
       _isCloseButton = false,
       text = null,
       iconSize = null,
       size = null;

  const FloatingButton.smallIcon({
    super.key,
    this.padding,
    required this.icon,
    this.iconOffsetX,
    this.iconOffsetY,
    this.onPressed,
    this.label,
    this.pushed = false,
    this.transparentBackground = false,
    this.tooltip,
  }) : _isBackButton = false,
       _isCloseButton = false,
       text = null,
       iconSize = _sizeSmallIcon,
       size = _sizeSmallButton;

  const FloatingButton.back({
    super.key,
    this.padding,
    this.transparentBackground = false,
    this.tooltip,
  }) : _isBackButton = true,
       _isCloseButton = false,
       onPressed = null,
       label = null,
       pushed = false,
       icon = null,
       iconOffsetX = null,
       iconOffsetY = null,
       iconSize = null,
       text = null,
       size = null;

  const FloatingButton.close({
    super.key,
    this.padding,
    this.transparentBackground = false,
    this.tooltip,
  }) : _isBackButton = false,
       _isCloseButton = true,
       onPressed = null,
       label = null,
       pushed = false,
       icon = null,
       iconOffsetX = null,
       iconOffsetY = null,
       iconSize = null,
       text = null,
       size = null;

  FloatingButton.share({
    super.key,
    required BuildContext context,
    this.padding,
    this.transparentBackground = false,
    this.onPressed,
  }) : _isBackButton = false,
       _isCloseButton = false,
       icon = shareIconData(context),
       iconOffsetX = IoWrapper.get.isAndroid ? _androidShareOffset : 0,
       iconOffsetY = IoWrapper.get.isAndroid ? 0 : _iosShareOffset,
       tooltip = Strings.of(context).share,
       iconSize = null,
       size = null,
       label = null,
       text = null,
       pushed = false;

  @override
  Widget build(BuildContext context) {
    Widget circleChild;
    if (_isBackButton) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        circleChild = Icon(
          Icons.arrow_back,
          color: context.colorIconFloatingButton,
          size: iconSize,
        );
      } else {
        // The iOS back button icon is not centered, so add some padding.
        circleChild = Padding(
          padding: insetsLeftSmall,
          child: Icon(
            Icons.arrow_back_ios,
            color: context.colorIconFloatingButton,
            size: iconSize,
          ),
        );
      }
    } else if (isNotEmpty(text)) {
      circleChild = Text(text!.toUpperCase());
    } else {
      circleChild = Icon(
        _isCloseButton ? Icons.close : icon,
        color: context.colorIconFloatingButton,
        size: iconSize,
      );
    }

    if (circleChild is Icon && (iconOffsetX != null || iconOffsetY != null)) {
      circleChild = Container(
        transform: Matrix4.translationValues(
          iconOffsetX ?? 0,
          iconOffsetY ?? 0,
          0,
        ),
        child: circleChild,
      );
    }

    return Padding(
      padding: padding ?? insetsDefault,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: _tooltipText(context),
            child: FloatingContainer(
              width: size ?? _sizeDefault,
              height: size ?? _sizeDefault,
              isCircle: true,
              isTransparent: transparentBackground,
              child: RawMaterialButton(
                shape: const CircleBorder(),
                fillColor: transparentBackground
                    ? null
                    : (pushed ? Colors.grey : null),
                onPressed: _isBackButton || _isCloseButton
                    ? () => Navigator.of(context).pop()
                    : onPressed,
                child: circleChild,
              ),
            ),
          ),
          isNotEmpty(label)
              ? Padding(
                  padding: insetsTopSmall,
                  child: Text(label!, style: styleHeadingSmall),
                )
              : const Empty(),
        ],
      ),
    );
  }

  String _tooltipText(BuildContext context) {
    if (_isBackButton) {
      return Strings.of(context).back;
    } else if (_isCloseButton) {
      return Strings.of(context).close;
    } else {
      return tooltip ?? "";
    }
  }
}

class FakeTextButton extends StatelessWidget {
  final String text;

  const FakeTextButton(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppConfig.get.colorAppTheme,
        fontWeight: fontWeightBold,
      ),
      overflow: TextOverflow.visible,
      maxLines: 1,
    );
  }
}
