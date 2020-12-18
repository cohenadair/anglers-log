import 'package:flutter/material.dart';
import '../res/dimen.dart';
import '../widgets/widget.dart';

class ScrollPage extends StatelessWidget {
  final AppBar appBar;
  final List<Widget> children;
  final EdgeInsets padding;
  final bool extendBodyBehindAppBar;
  final bool enableHorizontalSafeArea;

  ScrollPage({
    this.appBar,
    this.children = const [],
    this.padding = insetsZero,
    this.extendBodyBehindAppBar = true,
    this.enableHorizontalSafeArea = true,
  })  : assert(children != null),
        assert(padding != null),
        assert(extendBodyBehindAppBar != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      body: SingleChildScrollView(
        // Apply vertical padding inside the child Column so scrolling isn't
        // cut off.
        padding: padding.copyWith(
          top: 0,
          bottom: 0,
        ),
        child: SafeArea(
          left: enableHorizontalSafeArea,
          right: enableHorizontalSafeArea,
          child: Column(
            children: []
              ..add(VerticalSpace(padding.top))
              ..addAll(children)
              ..add(VerticalSpace(padding.bottom)),
          ),
        ),
      ),
    );
  }
}
