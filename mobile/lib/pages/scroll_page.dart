import 'package:flutter/material.dart';
import '../res/dimen.dart';
import '../widgets/widget.dart';

class ScrollPage extends StatelessWidget {
  final AppBar? appBar;
  final List<Widget> children;

  /// See [Scaffold.persistentFooterButtons].
  final List<Widget>? footer;

  final EdgeInsets padding;

  /// See [Scaffold.extendBodyBehindAppBar].
  final bool extendBodyBehindAppBar;

  final bool enableHorizontalSafeArea;
  final bool centerContent;

  ScrollPage({
    this.appBar,
    this.children = const [],
    this.footer,
    this.padding = insetsZero,
    this.extendBodyBehindAppBar = true,
    this.enableHorizontalSafeArea = true,
    this.centerContent = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget scrollView = SingleChildScrollView(
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
    );

    if (centerContent) {
      scrollView = Center(
        child: scrollView,
      );
    }

    return Scaffold(
      appBar: appBar,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      persistentFooterButtons: footer,
      body: scrollView,
    );
  }
}
