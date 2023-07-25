import 'package:flutter/material.dart';
import 'package:mobile/pages/import_page.dart';
import 'package:mobile/pages/migration_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/multi_measurement_input.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../user_preference_manager.dart';
import '../utils/map_utils.dart';
import '../utils/page_utils.dart';
import '../widgets/checkbox_input.dart';
import '../widgets/list_item.dart';
import '../widgets/list_picker_input.dart';
import '../widgets/widget.dart';
import 'about_page.dart';
import 'picker_page.dart';
import 'units_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
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
          _buildFetchTide(context),
          _buildTheme(),
          _buildUnits(context),
          _buildFishingSpotDistance(context),
          _buildMinGpsTrailDistance(context),
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

  Widget _buildFetchTide(BuildContext context) {
    return ProCheckboxInput(
      label: Strings.of(context).settingsPageFetchTideTitle,
      description: Strings.of(context).settingsPageFetchTideDescription,
      value: _userPreferenceManager.autoFetchTide,
      onSetValue: (checked) => _userPreferenceManager.setAutoFetchTide(checked),
    );
  }

  Widget _buildTheme() {
    var currentTheme = _userPreferenceManager.themeMode;
    String themeName;
    switch (currentTheme) {
      case ThemeMode.system:
        themeName = Strings.of(context).settingsPageThemeSystem;
        break;
      case ThemeMode.light:
        themeName = Strings.of(context).settingsPageThemeLight;
        break;
      case ThemeMode.dark:
        themeName = Strings.of(context).settingsPageThemeDark;
        break;
    }

    return ListPickerInput(
      title: Strings.of(context).settingsPageThemeTitle,
      value: themeName,
      onTap: () {
        push(
          context,
          PickerPage<ThemeMode>.single(
            title: Text(Strings.of(context).settingsPageThemeSelect),
            initialValue: currentTheme,
            itemBuilder: () => [
              PickerPageItem<ThemeMode>(
                title: Strings.of(context).settingsPageThemeSystem,
                value: ThemeMode.system,
              ),
              PickerPageItem<ThemeMode>(
                title: Strings.of(context).settingsPageThemeLight,
                value: ThemeMode.light,
              ),
              PickerPageItem<ThemeMode>(
                title: Strings.of(context).settingsPageThemeDark,
                value: ThemeMode.dark,
              ),
            ],
            onFinishedPicking: (context, pickedItem) {
              if (MapType.of(context) != MapType.satellite) {
                _userPreferenceManager.setMapType(pickedItem == ThemeMode.light
                    ? MapType.light.id
                    : MapType.dark.id);
              }

              _userPreferenceManager.setThemeMode(pickedItem);
              Navigator.of(context).pop();
            },
          ),
        );
      },
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
    return _MultiMeasurementSetting(
      spec: MultiMeasurementInputSpec.fishingSpotDistance(context),
      description:
          Strings.of(context).settingsPageFishingSpotDistanceDescription,
      initialValue: _userPreferenceManager.fishingSpotDistance,
      onChanged: (value) =>
          _userPreferenceManager.setFishingSpotDistance(value),
    );
  }

  Widget _buildMinGpsTrailDistance(BuildContext context) {
    return _MultiMeasurementSetting(
      spec: MultiMeasurementInputSpec.minGpsTrailDistance(context),
      description:
          Strings.of(context).settingsPageMinGpsTrailDistanceDescription,
      initialValue: _userPreferenceManager.minGpsTrailDistance,
      onChanged: (value) =>
          _userPreferenceManager.setMinGpsTrailDistance(value),
    );
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

class _MultiMeasurementSetting extends StatefulWidget {
  final MultiMeasurementInputSpec spec;
  final String description;
  final MultiMeasurement initialValue;
  final void Function(MultiMeasurement) onChanged;

  const _MultiMeasurementSetting({
    required this.spec,
    required this.description,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_MultiMeasurementSetting> createState() =>
      _MultiMeasurementSettingState();
}

class _MultiMeasurementSettingState extends State<_MultiMeasurementSetting> {
  late final MultiMeasurementInputSpec _spec;
  late final MultiMeasurementInputController _controller;

  @override
  void initState() {
    super.initState();
    _spec = widget.spec;
    _controller = _spec.newInputController();
    _controller.value = widget.initialValue;
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
            onChanged: () => widget.onChanged(_controller.value),
          ),
          const VerticalSpace(paddingSmall),
          Text(
            widget.description,
            overflow: TextOverflow.visible,
            style: styleSubtitle(context),
          )
        ],
      ),
    );
  }
}
