import 'package:flutter/material.dart';

import '../auth_manager.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../res/style.dart';
import '../utils/dialog_utils.dart';
import '../utils/page_utils.dart';
import '../widgets/list_item.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';
import 'pro_page.dart';

class SettingsPage extends StatelessWidget {
  final _log = Log("SettingsPage");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.of(context).settingsPageTitle),
      ),
      body: ListView(
        children: <Widget>[
          _buildPro(context),
          MinDivider(),
          _buildLogout(context),
        ],
      ),
    );
  }

  Widget _buildPro(BuildContext context) {
    return ListItem(
      title: Text(Strings.of(context).morePagePro),
      leading: Icon(Icons.stars),
      onTap: () => present(context, ProPage()),
    );
  }

  Widget _buildLogout(BuildContext context) {
    var authManager = AuthManager.of(context);

    return ListItem(
      title: Label(
        Strings.of(context).settingsPageLogout,
        style: styleError,
      ),
      leading: Icon(
        Icons.logout,
        color: styleError.color,
      ),
      onTap: () {
        _log.d("Logging out of ${authManager.userEmail}");

        showConfirmYesDialog(
          context: context,
          description:
              Label(Strings.of(context).settingsPageLogoutConfirmMessage),
          onConfirm: () async => AuthManager.of(context).logout(),
        );
      },
    );
  }
}
