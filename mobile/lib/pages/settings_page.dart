import 'package:flutter/material.dart';
import 'package:mobile/pages/import_page.dart';
import 'package:mobile/pages/migration_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/multi_measurement_input.dart';

import '../i18n/strings.dart';
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
          _buildFishingSpotDistance(context),
          const MinDivider(),
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
      onSetValue: (checked) =>
          _userPreferenceManager.setAutoFetchAtmosphere(checked),
    );
  }

  Widget _buildUnits(BuildContext context) {
    return ListItem(
      title: Text(Strings.of(context).unitsPageTitle),
      trailing: RightChevronIcon(),
      onTap: () => push(context, UnitsPage()),
    );
  }

  Widget _buildFishingSpotDistance(BuildContext context) {
    return _FishingSpotDistanceInput();
  }

  Widget _buildLegacyImport(BuildContext context) {
    return ListItem(
      title: Text(Strings.of(context).importPageMoreTitle),
      onTap: () => present(context, ImportPage()),
    );
  }

  Widget _buildLegacyMigration(BuildContext context) {
    return ListItem(
      title: Text(Strings.of(context).migrationPageMoreTitle),
      onTap: () => present(context, MigrationPage()),
    );
  }

  Widget _buildAbout() {
    return ListItem(
      title: Text(Strings.of(context).settingsPageAbout),
      trailing: RightChevronIcon(),
      onTap: () => push(context, const AboutPage()),
    );
  }
}

class _FishingSpotDistanceInput extends StatefulWidget {
  @override
  State<_FishingSpotDistanceInput> createState() =>
      _FishingSpotDistanceInputState();
}

class _FishingSpotDistanceInputState extends State<_FishingSpotDistanceInput> {
  late final MultiMeasurementInputSpec _spec;
  late final MultiMeasurementInputController _controller;

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  @override
  void initState() {
    super.initState();
    _spec = MultiMeasurementInputSpec.fishingSpotDistance(context);
    _controller = _spec.newInputController();
    _controller.value = _userPreferenceManager.fishingSpotDistance;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: insetsHorizontalDefaultBottomDefault,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MultiMeasurementInput(
            spec: _spec,
            controller: _controller,
            onChanged: () => _userPreferenceManager
                .setFishingSpotDistance(_controller.value),
          ),
          const VerticalSpace(paddingSmall),
          Text(
            Strings.of(context).settingsPageFishingSpotDistanceDescription,
            overflow: TextOverflow.visible,
            style: styleSubtitle(context),
          )
        ],
      ),
    );
  }
}
