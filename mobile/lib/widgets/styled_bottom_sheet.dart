import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/widget.dart';

/// A widget that mimics Material Design bottom sheet behaviour and style. A
/// [BottomSheet] and [ScaffoldState.showBottomSheet] isn't used here because
/// it doesn't provide the desired behaviour of animating from beneath the
/// bottom navigation bar.
///
/// The style of the [StyledBottomSheet] widget is inspired by bottoms sheet
/// use in the Google Maps iOS app.
///
/// This widget animates in from the bottom and is dismissible by swiping down.
class StyledBottomSheet extends StatefulWidget {
  final Widget child;
  final VoidCallback onDismissed;

  StyledBottomSheet({
    @required this.child,
    @required this.onDismissed,
  }) : assert(child != null),
       assert(onDismissed != null);

  @override
  _StyledBottomSheetState createState() => _StyledBottomSheetState();
}

class _StyledBottomSheetState extends State<StyledBottomSheet>
    with SingleTickerProviderStateMixin
{
  final _keyBottomSheet = "key_bottom_sheet";
  final _slideInDurationMs = 150;

  AnimationController _controller;
  Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _slideInDurationMs),
    );

    _offset = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: Dismissible(
        key: Key(_keyBottomSheet),
        direction: DismissDirection.down,
        onDismissed: (_) => widget.onDismissed(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: boxShadowTop,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10.0),
            ),
          ),
          child: Padding(
            padding: insetsTopSmall,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SwipeChip(),
                Padding(
                  padding: EdgeInsets.only(
                    left: paddingDefault,
                    right: paddingDefault,
                    bottom: paddingDefault,
                    top: paddingSmall,
                  ),
                  child: widget.child,
                ),
                // Add some separation between the bottom sheet and the widget
                // below.
                Container(
                  constraints: BoxConstraints.expand(height: 1),
                  decoration: BoxDecoration(
                    boxShadow: boxShadowTop,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}