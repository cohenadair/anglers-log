import 'package:flutter/material.dart';
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