import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/text.dart';

class SettingsPage extends StatelessWidget {
  final AppManager app;

  SettingsPage(this.app);

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: Strings.of(context).settingsPageTitle,
      ),
      child: ListView(
        children: <Widget>[
          _buildHeading(Strings.of(context).settingsPageAccountHeading),
          _buildLogout(context),
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
        child: HeadingText(title),
      ),
    );
  }

  Widget _buildLogout(BuildContext context) => ListItem(
    title: ErrorText(Strings.of(context).settingsPageLogout),
    onTap: () => showConfirmYesDialog(
      context: context,
      description: Strings.of(context).settingsPathLogoutConfirmMessage,
      onConfirm: () async {
        await app.authManager.logout();
      },
    ),
  );
}