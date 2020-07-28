import 'package:flutter/material.dart';
import 'package:mobile/res/color.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/text.dart';
import 'package:quiver/strings.dart';

const defaultAnimationDuration = Duration(milliseconds: 150);

class Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class MinDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1);
  }
}

class HeadingDivider extends StatelessWidget {
  final String text;

  HeadingDivider(this.text);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MinDivider(),
        Padding(
          padding: EdgeInsets.only(
            top: paddingWidget,
            left: paddingDefault,
            right: paddingDefault,
          ),
          child: HeadingLabel(text),
        ),
      ],
    );
  }
}

class Loading extends StatelessWidget {
  static Widget centered({EdgeInsets padding}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Loading(padding: padding ?? insetsDefault),
      ],
    );
  }

  final EdgeInsets _padding;

  Loading({
    EdgeInsets padding = insetsZero
  }) : _padding = padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding,
      child: SizedBox.fromSize(
        size: Size(20, 20),
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}

/// A widget used to indicate the parent widget responds to the swipe gesture,
/// such as swiping down to close a bottom sheet-style widget.
class SwipeChip extends StatelessWidget {
  final _width = 20.0;
  final _height = 5.0;

  @override
  Widget build(BuildContext context) => Padding(
    padding: insetsVerticalSmall,
    child: Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.all(Radius.circular(_height / 2)),
      ),
    ),
  );
}

/// An [Opacity] wrapper whose state depends on the [enabled] property.
class EnabledOpacity extends StatelessWidget {
  static const double _disabledOpacity = 0.5;

  final Key key;
  final bool enabled;
  final Widget child;

  EnabledOpacity({
    @required this.child,
    this.key,
    this.enabled = true,
  }) : assert(child != null);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      key: key,
      opacity: enabled ? 1.0 : _disabledOpacity,
      child: child,
    );
  }
}

class RightChevronIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.chevron_right,
      color: colorInputIconAccent,
    );
  }
}

class DropdownIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.arrow_drop_down,
      color: colorInputIconAccent,
    );
  }
}

/// A help popup that fades in and out of view.
class HelpTooltip extends StatelessWidget {
  final Widget child;
  final bool showing;
  final EdgeInsets margin;

  HelpTooltip({
    @required this.child,
    this.showing = false,
    this.margin = insetsDefault,
  }) : assert(child != null);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedVisibility(
        visible: showing,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.70),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          padding: insetsDefault,
          margin: margin,
          child: child,
        ),
      ),
    );
  }
}

/// A wrapper for [AnimatedOpacity] with a default duration.
class AnimatedVisibility extends StatelessWidget {
  final Duration _animDuration = Duration(milliseconds: 150);

  final bool visible;
  final Widget child;

  AnimatedVisibility({
    this.visible = true,
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: _animDuration,
      child: child,
    );
  }
}

/// A [FutureBuilder] wrapper that shows an [Empty] widget when the given
/// [Future] doesn't have any data.
class EmptyFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext, T) builder;

  EmptyFutureBuilder({
    @required this.future,
    @required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Empty();
        }
        return builder(context, snapshot.data);
      },
    );
  }
}

class VerticalSpace extends StatelessWidget {
  final double size;

  VerticalSpace(this.size);

  @override
  Widget build(BuildContext context) => Container(
    height: size,
  );
}

class AppBarDropdownItem<T> extends DropdownMenuItem<T> {
  final String text;
  final T value;

  AppBarDropdownItem({
    @required BuildContext context,
    @required this.text,
    @required this.value,
  }) : assert(isNotEmpty(text)),
       assert(value != null),
       super(
         child: Text(text,
           // Use the same theme as default AppBar title text.
           style: Theme.of(context).textTheme.headline6,
         ),
         value: value,
       );
}