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
class FloatingBottomContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final EdgeInsets margin;
  final VoidCallback onTap;

  /// Rendered below [title] and [subtitle].
  final List<Widget> children;

  FloatingBottomContainer({
    this.title,
    this.subtitle,
    this.margin,
    this.onTap,
    this.children = const [],
  }) : assert(isNotEmpty(title) || isNotEmpty(subtitle)),
       assert(children != null);

  bool get _tapEnabled => onTap != null;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: margin ?? insetsDefault,
          decoration: FloatingBoxDecoration.rectangle(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.all(
                    Radius.circular(floatingCornerRadius)),
                color: Colors.transparent,
                child: ListItem(
                  contentPadding: EdgeInsets.only(
                    left: paddingDefault,
                    right: _tapEnabled ? paddingSmall : paddingDefault,
                  ),
                  title: isNotEmpty(title)
                      ? Label(title, style: styleHeading) : Label(subtitle),
                  subtitle: isEmpty(title) ? null : SubtitleLabel(subtitle),
                  onTap: onTap,
                  trailing: _tapEnabled ? RightChevronIcon() : null,
                ),
              ),
            ]..addAll(children),
          ),
        ),
      ),
    );
  }
}