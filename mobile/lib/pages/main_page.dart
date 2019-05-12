import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

class MainPage extends StatelessWidget {
  MainPage();

  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: Strings.of(context).appName,
      ),
      child: Empty(),
    );
  }
}