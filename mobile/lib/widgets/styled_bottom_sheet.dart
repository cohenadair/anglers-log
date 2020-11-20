import 'package:flutter/material.dart';

import '../res/dimen.dart';
import '../res/style.dart';
import '../widgets/widget.dart';

/// A widget that mimics Material Design bottom sheet behaviour and style. A
/// [BottomSheet] and [ScaffoldState.showBottomSheet] isn't used here because
/// it doesn't provide the desired behaviour of animating from beneath the
/// bottom navigation bar.
///
/// The style of the [StyledBottomSheet] widget is inspired by bottom sheet
/// use in the Google Maps iOS app.
///
/// This widget animates in from the bottom and is dismissible by swiping down,
/// or by setting the [visible] property to `false`.
class StyledBottomSheet extends StatefulWidget {
  final Widget child;

  /// Called when the bottom sheet is dismissed by swiping down, and at the end
  /// of a reverse animation (when [visible] is `false`).
  final VoidCallback onDismissed;
  final bool visible;

  StyledBottomSheet({
    @required this.child,
    @required this.onDismissed,
    this.visible = true,
  })  : assert(child != null),
        assert(onDismissed != null);

  @override
  _StyledBottomSheetState createState() => _StyledBottomSheetState();
}

class _StyledBottomSheetState extends State<StyledBottomSheet>
    with SingleTickerProviderStateMixin {
  final _keyBottomSheet = "key_bottom_sheet";
  final _slideInDurationMs = 150;

  AnimationController _controller;
  Animation<Offset> _offset;

  void Function(AnimationStatus) _animationStatusListener;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _slideInDurationMs),
    );

    _animationStatusListener = (status) {
      if (status == AnimationStatus.dismissed) {
        widget.onDismissed();
      }
    };

    _offset = Tween<Offset>(
      begin: Offset(0.0, 1.1), // +0.1 for the top shadow
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
  void didUpdateWidget(StyledBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.visible != widget.visible) {
      if (widget.visible) {
        _controller.removeStatusListener(_animationStatusListener);
      } else {
        _controller.addStatusListener(_animationStatusListener);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return SlideTransition(
      position: _offset,
      child: Dismissible(
        key: Key(_keyBottomSheet),
        direction: DismissDirection.down,
        onDismissed: (_) => widget.onDismissed(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: boxShadowDefault,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(floatingCornerRadius),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SwipeChip(),
              Padding(
                padding: insetsBottomSmall,
                child: widget.child,
              ),
              // Add some separation between the bottom sheet and the widget
              // below.
              Container(
                constraints: BoxConstraints.expand(height: 1),
                decoration: BoxDecoration(
                  boxShadow: boxShadowDefault,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
