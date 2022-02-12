import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

Future<T?> showOurBottomSheet<T>(
    BuildContext context, Widget Function(BuildContext) builder) {
  return showModalBottomSheet<T?>(
    isScrollControlled: true,
    useRootNavigator: true,
    context: context,
    builder: builder,
  );
}

class OurBottomSheet extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const OurBottomSheet({
    this.title,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = const Empty();
    if (isNotEmpty(title)) {
      titleWidget = Padding(
        padding: insetsDefault,
        child: Text(
          title!,
          style: styleHeadingSmall,
        ),
      );
    }

    return SafeArea(
      bottom: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: SwipeChip(),
          ),
          titleWidget,
          ...children,
        ],
      ),
    );
  }
}
