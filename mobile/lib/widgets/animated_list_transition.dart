import 'package:flutter/material.dart';

/// A widget to be used with all [AnimatedList] and [SliverAnimatedList]
/// throughout the app.
class AnimatedListTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const AnimatedListTransition({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      child: child,
    );
  }
}
