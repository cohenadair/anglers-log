import 'package:flutter/material.dart';
import 'package:mobile/res/theme.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../widgets/text.dart';
import 'widget.dart';

class EmptyListPlaceholder extends StatelessWidget {
  static EmptyListPlaceholder noSearchResults(
    BuildContext context, {
    EdgeInsets padding = insetsDefault,
    bool scrollable = false,
  }) {
    return EmptyListPlaceholder(
      title: Strings.of(context).emptyListPlaceholderNoResultsTitle,
      description: Strings.of(context).emptyListPlaceholderNoResultsDescription,
      icon: Icons.search_off,
      padding: padding,
      scrollable: scrollable,
    );
  }

  final String title;
  final String description;

  /// If set, a [IconLabel] is used, and [descriptionIcon] is inserted into
  /// [description].
  final IconData? descriptionIcon;

  final IconData icon;
  final EdgeInsets padding;

  /// If true, will embed the view in a [SingleChildScrollView]. Defaults to
  /// true.
  final bool scrollable;

  const EmptyListPlaceholder({
    required this.title,
    required this.description,
    this.descriptionIcon,
    required this.icon,
    this.padding = insetsDefault,
    this.scrollable = true,
  });

  const EmptyListPlaceholder.static({
    required String title,
    required String description,
    IconData? descriptionIcon,
    required IconData icon,
    EdgeInsets padding = insetsDefault,
  }) : this(
          title: title,
          description: description,
          descriptionIcon: descriptionIcon,
          icon: icon,
          padding: padding,
          scrollable: false,
        );

  @override
  Widget build(BuildContext context) {
    Widget descriptionWidget = const Empty();
    if (isNotEmpty(description)) {
      var overflow = TextOverflow.visible;
      var align = TextAlign.center;
      var enabled = false;

      if (descriptionIcon == null) {
        descriptionWidget = Text(
          description,
          overflow: overflow,
          textAlign: align,
          style: stylePrimary(context, enabled: enabled),
        );
      } else {
        descriptionWidget = IconLabel(
          text: description,
          textArg: Icon(
            descriptionIcon,
            color: context.colorAppBarContent,
          ),
          textStyle: stylePrimary(context, enabled: enabled),
          overflow: overflow,
          align: align,
        );
      }
    }

    var child = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          WatermarkLogo(
            icon: icon,
          ),
          Padding(
            padding: insetsVerticalDefault,
            child: AlertTitleLabel(title),
          ),
          descriptionWidget,
        ],
      ),
    );

    if (scrollable) {
      return Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: child,
          ),
        ),
      );
    } else {
      return child;
    }
  }
}
