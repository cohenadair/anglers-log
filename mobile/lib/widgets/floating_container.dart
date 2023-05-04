import 'package:flutter/material.dart';
import 'package:mobile/res/theme.dart';

import '../res/dimen.dart';
import '../res/style.dart';

/// A floating container resembling a [Card], with our own style.
class FloatingContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool isCircle;

  /// If true, the [Container.decoration] is null. This is useful for animating
  /// between two [FloatingContainer] when the widget beneath changes color.
  final bool isTransparent;

  const FloatingContainer({
    Key? key,
    this.child,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.isCircle = false,
    this.isTransparent = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var child = this.child;
    if (onTap != null) {
      child = InkWell(
        borderRadius: BorderRadius.circular(floatingCornerRadius),
        onTap: onTap,
        child: child,
      );
    }

    var decoration = BoxDecoration(
      color: context.colorFloatingContainerBackground,
      boxShadow: boxShadowDefault(context),
    );

    if (isCircle) {
      decoration = decoration.copyWith(shape: BoxShape.circle);
    } else {
      decoration = decoration.copyWith(
        borderRadius:
            const BorderRadius.all(Radius.circular(floatingCornerRadius)),
      );
    }

    return Container(
      margin: margin,
      padding: padding,
      width: width,
      height: height,
      decoration: isTransparent ? null : decoration,
      clipBehavior: isTransparent ? Clip.none : Clip.antiAlias,
      // Wrap the child in a Material widget so fill animation is shown
      // on top of the parent Container widget when children are tapped.
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}
