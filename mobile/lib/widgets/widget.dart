import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';

const defaultAnimationDuration = Duration(milliseconds: 200);

class Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox();
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