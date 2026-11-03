import 'package:flutter/material.dart';

/// Focuses the first focusable descendant of [child] once the enclosing route
/// has finished animating in.
///
/// Use this in place of autofocusing a text field on a newly pushed page.
/// Showing the keyboard while a route is still animating in makes the
/// animation noticeably janky, particularly on iOS.
class RouteAutofocus extends StatefulWidget {
  final Widget child;

  /// When false, focus is never requested. Defaults to true. Only read when
  /// the widget is first inserted into the tree; later changes are ignored.
  final bool isEnabled;

  const RouteAutofocus({required this.child, this.isEnabled = true});

  @override
  State<RouteAutofocus> createState() => _RouteAutofocusState();
}

class _RouteAutofocusState extends State<RouteAutofocus> {
  final _focusNode = FocusNode(canRequestFocus: false, skipTraversal: true);

  ModalRoute<dynamic>? _route;
  Animation<double>? _routeAnimation;

  @override
  void initState() {
    super.initState();

    if (widget.isEnabled) {
      // Wait for the first frame so the child's focus nodes are attached.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _focusAfterRouteAnimation(),
      );
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteAnimationStatusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(focusNode: _focusNode, child: widget.child);
  }

  void _focusAfterRouteAnimation() {
    // The widget may have been removed in the same frame it was inserted.
    if (!mounted) {
      return;
    }

    _route = ModalRoute.of(context);
    final animation = _route?.animation;
    if (animation == null || animation.isCompleted) {
      _focusChild();
      return;
    }

    _routeAnimation = animation
      ..addStatusListener(_onRouteAnimationStatusChanged);
  }

  void _onRouteAnimationStatusChanged(AnimationStatus status) {
    if (!status.isCompleted) {
      return;
    }

    _routeAnimation?.removeStatusListener(_onRouteAnimationStatusChanged);
    _routeAnimation = null;
    _focusChild();
  }

  void _focusChild() {
    final target = _focusNode.traversalDescendants.firstOrNull;

    // Don't take focus while another route is showing on top of this one.
    if (target == null || !(_route?.isCurrent ?? true)) {
      return;
    }

    // Like TextField.autofocus, only focuses the target if nothing else in the
    // scope already has focus, such as a field the user tapped mid-animation.
    _focusNode.enclosingScope?.autofocus(target);
  }
}
