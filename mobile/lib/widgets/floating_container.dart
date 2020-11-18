import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

/// A floating container aligned to the bottom of its container. This widget
/// is meant to be used at the bottom of a map, or to appear floating above a
/// background widget.
///
/// The [title] and [subtitle] widgets are embedded in a [ListItem] widget, and
/// will include a [RightChevronIcon] on the right when [onTap] is not null.
///
/// Addition widgets in [children] will be rendered under the [ListItem].
class FloatingContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final EdgeInsets margin;
  final Alignment alignment;
  final VoidCallback onTap;

  /// Rendered below [title] and [subtitle].
  final List<Widget> children;

  FloatingContainer({
    this.title,
    this.subtitle,
    this.margin,
    this.alignment = Alignment.bottomCenter,
    this.onTap,
    this.children = const [],
  })  : assert(isNotEmpty(title) || isNotEmpty(subtitle)),
        assert(children != null),
        assert(alignment != null);

  bool get _tapEnabled => onTap != null;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
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
              child: ListItem(
                contentPadding: EdgeInsets.only(
                  left: paddingDefault,
                  right: _tapEnabled ? paddingSmall : paddingDefault,
                ),
                title: isNotEmpty(title)
                    ? Label(title, style: styleHeading)
                    : Label(subtitle),
                subtitle: isEmpty(title) || isEmpty(subtitle)
                    ? null
                    : SubtitleLabel(subtitle),
                onTap: onTap,
                trailing: _tapEnabled ? RightChevronIcon() : null,
              ),
            ),
          ]..addAll(children),
        ),
      ),
    );
  }
}
