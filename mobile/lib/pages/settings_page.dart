import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../res/dimen.dart';
import '../widgets/text.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.of(context).settingsPageTitle),
      ),
      body: ListView(
        children: <Widget>[
          _buildHeading("Units"),
        ],
      ),
    );
  }

  Widget _buildHeading(String title) {
    return Padding(
      padding: EdgeInsets.only(
        top: paddingDefault,
        bottom: paddingSmall,
        left: paddingDefault,
        right: paddingDefault,
      ),
      child: SafeArea(
        child: HeadingLabel(title),
      ),
    );
  }
}
