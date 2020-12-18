import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../res/dimen.dart';
import '../widgets/text.dart';
import 'widget.dart';

class NoResults extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final EdgeInsets padding;

  /// If true, will embed the view in a [SingleChildScrollView]. Defaults to
  /// true.
  final bool scrollable;

  NoResults({
    this.title,
    this.description,
    this.icon,
    this.padding = insetsDefault,
    this.scrollable = true,
  })  : assert(padding != null),
        assert(scrollable != null);

  @override
  Widget build(BuildContext context) {
    var child = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          WatermarkLogo(
            icon: icon ?? Icons.search_off,
            color: Colors.grey.shade400,
          ),
          Padding(
            padding: insetsVerticalDefault,
            child: AlertTitleLabel(title ?? Strings.of(context).noResultsTitle),
          ),
          PrimaryLabel(
            description ?? Strings.of(context).noResultsDescription,
            overflow: TextOverflow.visible,
            align: TextAlign.center,
            enabled: false,
          ),
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
