import 'package:flutter/material.dart';
import 'package:mobile/pages/import_page.dart';
import 'package:mobile/pages/migration_page.dart';

import '../i18n/strings.dart';
import '../res/gen/custom_icons.dart';
import '../user_preference_manager.dart';
import '../utils/page_utils.dart';
import '../widgets/checkbox_input.dart';
import '../widgets/list_item.dart';
import '../widgets/widget.dart';
import 'about_page.dart';
import 'units_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.of(context).settingsPageTitle),
      ),
      body: ListView(
        children: <Widget>[
          _buildFetchAtmosphere(context),
          _buildUnits(context),
          _buildLegacyImport(context),
          _buildLegacyMigration(context),
          const MinDivider(),
          _buildAbout(),
        ],
      ),
    );
  }

  Widget _buildFetchAtmosphere(BuildContext context) {
    return ProCheckboxInput(
      label: Strings.of(context).settingsPageFetchAtmosphereTitle,
      description: Strings.of(context).settingsPageFetchAtmosphereDescription,
      value: _userPreferenceManager.autoFetchAtmosphere,
      leading: const Icon(Icons.air),
      onSetValue: (checked) =>
          _userPreferenceManager.setAutoFetchAtmosphere(checked),
    );
  }

  Widget _buildUnits(BuildContext context) {
    return ListItem(
      title: Text(Strings.of(context).unitsPageTitle),
      leading: const Icon(CustomIcons.ruler),
      trailing: RightChevronIcon(),
      onTap: () => push(context, UnitsPage()),
    );
  }

  Widget _buildLegacyImport(BuildContext context) {
    return ListItem(
      leading: const Icon(Icons.cloud_download),
      title: Text(Strings.of(context).importPageMoreTitle),
      onTap: () => present(context, ImportPage()),
    );
  }

  Widget _buildLegacyMigration(BuildContext context) {
    return ListItem(
      leading: const Icon(Icons.sync),
      title: Text(Strings.of(context).migrationPageMoreTitle),
      onTap: () => present(context, MigrationPage()),
    );
  }

  Widget _buildAbout() {
    return ListItem(
      title: Text(Strings.of(context).settingsPageAbout),
      leading: const Icon(CustomIcons.catches),
      trailing: RightChevronIcon(),
      onTap: () => push(context, const AboutPage()),
    );
  }
}
