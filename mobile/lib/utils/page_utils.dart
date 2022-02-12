import 'package:flutter/material.dart';

import '../widgets/widget.dart';

void push(
  BuildContext context,
  Widget page, {
  bool fullscreenDialog = false,
  VoidCallback? onFinish,
}) {
  Navigator.of(context, rootNavigator: fullscreenDialog)
      .push(
        MaterialPageRoute(
          builder: (context) => page,
          fullscreenDialog: fullscreenDialog,
        ),
      )
      .then((_) => onFinish?.call());
}

void present(
  BuildContext context,
  Widget page, {
  VoidCallback? onFinish,
}) {
  push(context, page, fullscreenDialog: true, onFinish: onFinish);
}

/// Shows the given page immediately with a [FadeAnimation].
void fade(BuildContext context, Widget page, {bool opaque = false}) {
  Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
    opaque: opaque,
    pageBuilder: (_, __, ___) => page,
    transitionDuration: animDurationDefault,
    transitionsBuilder: (context, animation, _, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ));
}
