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
  final Widget _child;
  final PageAppBarStyle _appBarStyle;

  Page({
    @required Widget child,
    PageAppBarStyle appBarStyle,
  }) : assert(child != null),
       _child = child,
       _appBarStyle = appBarStyle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarStyle == null ? null : AppBar(
        title: _appBarStyle.subtitle == null
            ? Text(_appBarStyle.title == null ? "" : _appBarStyle.title)
            : _buildTitleWithSubtitle(context),
        actions: _appBarStyle.actions,
        leading: _appBarStyle.leading,
      ),
      body: _child,
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
          Text(_appBarStyle.title),
          Text(_appBarStyle.subtitle,
            style: Theme.of(context).textTheme.subtitle.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}