import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';

class PageAppBarStyle {
  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget leading;

  PageAppBarStyle({
    this.title,
    this.subtitle,
    this.actions,
    this.leading,
  });
}

class Page extends StatelessWidget {
  final Widget child;
  final PageAppBarStyle appBarStyle;
  final EdgeInsets padding;

  Page({
    @required this.child,
    this.appBarStyle,
    this.padding = insetsZero,
  }) : assert(child != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarStyle == null ? null : AppBar(
        title: appBarStyle.subtitle == null
            ? Text(appBarStyle.title == null ? "" : appBarStyle.title)
            : _buildTitleWithSubtitle(context),
        actions: appBarStyle.actions,
        leading: appBarStyle.leading,
      ),
      body: Padding(
        padding: padding,
        child: child,
      ),
    );
  }

  Widget _buildTitleWithSubtitle(BuildContext context) {
    return Padding(
      padding: insetsTopSmall,
      child: Column(
        crossAxisAlignment: Platform.isAndroid
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: <Widget>[
          Text(appBarStyle.title),
          Text(appBarStyle.subtitle,
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}