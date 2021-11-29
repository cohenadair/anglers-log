import 'package:flutter/material.dart';

import '../res/dimen.dart';
import 'widget.dart';

/// A generic widget to be used in input forms. This widget includes a
/// [RightChevronIcon] on the right side of the view to indicate that tapping
/// it will open another page, normally for picking or gathering additional
/// information from the user.
class DetailInput extends StatelessWidget {
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool isEnabled;

  /// The children of the widget, laid out in a [Row].
  final List<Widget> children;

  const DetailInput({
    this.padding,
    this.onTap,
    this.isEnabled = true,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    var items = List.of(children)
      ..add(Padding(
        padding: insetsLeftSmall,
        child: RightChevronIcon(),
      ));

    return EnabledOpacity(
      isEnabled: isEnabled,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        child: Padding(
          padding: padding ?? insetsDefault,
          child: HorizontalSafeArea(
            child: Row(children: items),
          ),
        ),
      ),
    );
  }
}
