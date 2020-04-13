import 'package:flutter/material.dart';
import 'package:mobile/res/color.dart';
import 'package:mobile/res/dimen.dart';

const defaultAnimationDuration = Duration(milliseconds: 200);

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

class Loading extends StatelessWidget {
  static Widget centered() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Loading(padding: insetsDefault),
      ],
    );
  }

  final EdgeInsets _padding;

  // ignore: missing_identifier
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
  final Duration _animDuration = Duration(milliseconds: 150);

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
      child: AnimatedOpacity(
        duration: _animDuration,
        opacity: showing ? 1.0 : 0.0,
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