import 'package:flutter/material.dart';

import 'widget.dart';

/// This widget animates in from the bottom and is dismissed, by setting the
/// [isVisible] property to `false`.
class SlideUpTransition extends StatefulWidget {
  final Widget child;

  /// Called at the end of a reverse animation; when [isVisible] is set to
  /// false.
  final VoidCallback? onDismissed;
  final bool isVisible;

  const SlideUpTransition({
    required this.child,
    this.onDismissed,
    this.isVisible = true,
  });

  @override
  SlideUpTransitionState createState() => SlideUpTransitionState();
}

class SlideUpTransitionState extends State<SlideUpTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offset;

  late void Function(AnimationStatus) _animationStatusListener;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: animDurationDefault,
    );

    _animationStatusListener = (status) {
      if (status == AnimationStatus.dismissed) {
        widget.onDismissed?.call();
      }
    };
    _controller.addStatusListener(_animationStatusListener);

    _offset = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_animationStatusListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVisible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return SlideTransition(
      position: _offset,
      child: widget.child,
    );
  }
}
