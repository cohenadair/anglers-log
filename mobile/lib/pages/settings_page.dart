import 'package:flutter/material.dart';

import '../auth_manager.dart';
import '../i18n/strings.dart';
import '../res/style.dart';
import '../utils/dialog_utils.dart';
import '../widgets/list_item.dart';
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
          _buildLogout(context),
        ],
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return ListItem(
      title: Label(
        Strings.of(context).settingsPageLogout,
        style: styleError,
      ),
      onTap: () => showConfirmYesDialog(
        context: context,
        description:
            Label(Strings.of(context).settingsPageLogoutConfirmMessage),
        onConfirm: () async => AuthManager.of(context).logout(),
      ),
    );
  }
}
