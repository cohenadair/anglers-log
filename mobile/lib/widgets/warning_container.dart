import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';
import 'package:mobile/res/style.dart';

import '../res/dimen.dart';

class WarningContainer extends StatelessWidget {
  static final buttonColor = Colors.orange.shade600;

  final List<Widget> children;

  const WarningContainer({this.children = const []});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: stylePrimary(context).copyWith(color: Colors.black),
      child: Container(
        padding: insetsDefault,
        decoration: BoxDecoration(
          color: Colors.orange.shade300,
          borderRadius: defaultBorderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: paddingDefault,
          children: children,
        ),
      ),
    );
  }
}
