import 'package:flutter/material.dart';
import 'package:mobile/widgets/widget.dart';

void push(BuildContext context, Widget page, {
  bool fullscreenDialog = false
}) {
  Navigator.of(context, rootNavigator: fullscreenDialog).push(
    MaterialPageRoute(
      builder: (BuildContext context) => page,
      fullscreenDialog: fullscreenDialog,
    ),
  );
}

void present(BuildContext context, Widget page) {
  push(context, page, fullscreenDialog: true);
}

/// Shows the given page immediately with a [FadeAnimation].
void fade(BuildContext context, Widget page) {
  Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: defaultAnimationDuration,
    transitionsBuilder: (context, animation, _, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ));
}