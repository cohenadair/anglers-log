import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../res/dimen.dart';
import '../res/style.dart';
import '../widgets/list_item.dart';
import '../widgets/widget.dart';

/// A floating container aligned to the bottom of its container. This widget
/// is meant to be used at the bottom of a map, or to appear floating above a
/// background widget.
///
/// The [title] and [subtitle] widgets are embedded in a [ListItem] widget, and
/// will include a [RightChevronIcon] on the right when [onTap] is not null.
///
/// Addition widgets in [children] will be rendered under the [ListItem].
class FloatingContainer extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final EdgeInsets? margin;
  final Alignment? alignment;
  final VoidCallback? onTap;

  /// Rendered below [title] and [subtitle].
  final List<Widget> children;

  FloatingContainer({
    this.title,
    this.subtitle,
    this.margin,
    this.alignment,
    this.onTap,
    this.children = const [],
  }) : assert(isNotEmpty(title) || isNotEmpty(subtitle));

  bool get _tapEnabled => onTap != null;

  @override
  Widget build(BuildContext context) {
    String? title;
    String? subtitle;
    if (isNotEmpty(this.title)) {
      title = this.title;
      subtitle = this.subtitle;
    } else if (isNotEmpty(this.subtitle)) {
      title = this.subtitle;
    }

    return Align(
      alignment: alignment ?? Alignment.bottomCenter,
      child: Container(
        margin: margin ?? insetsDefault,
        decoration: FloatingBoxDecoration.rectangle(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              clipBehavior: Clip.antiAlias,
              borderRadius:
                  BorderRadius.all(Radius.circular(floatingCornerRadius)),
              color: Colors.transparent,
              child: ImageListItem(
                title: title,
                subtitle: subtitle,
                onTap: onTap,
                trailing: _tapEnabled ? RightChevronIcon() : null,
                showPlaceholder: false,
              ),
            ),
          ]..addAll(children),
        ),
      ),
    );
  }
}
