import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../atmosphere_fetcher.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/editable_form_page.dart';
import '../pages/pro_page.dart';
import '../res/dimen.dart';
import '../subscription_manager.dart';
import '../time_manager.dart';
import '../user_preference_manager.dart';
import '../utils/date_time_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/snackbar_utils.dart';
import 'checkbox_input.dart';
import 'date_time_picker.dart';
import 'detail_input.dart';
import 'input_controller.dart';
import 'input_data.dart';
import 'list_picker_input.dart';
import 'multi_measurement_input.dart';
import 'text.dart';
import 'text_input.dart';
import 'widget.dart';

class AtmosphereInput extends StatefulWidget {
  final AtmosphereFetcher fetcher;
  final Atmosphere? initialValue;
  final EdgeInsets? padding;
  final void Function(Atmosphere)? onChanged;

  AtmosphereInput({
    required this.fetcher,
    this.initialValue,
    this.padding,
    this.onChanged,
  });

  @override
  _AtmosphereInputState createState() => _AtmosphereInputState();
}

class _AtmosphereInputState extends State<AtmosphereInput> {
  late Atmosphere _atmosphere;

  @override
  void initState() {
    super.initState();
    _atmosphere = widget.initialValue ?? Atmosphere();
  }

  @override
  Widget build(BuildContext context) {
    return DetailInput(
      onTap: () => push(context, _AtmosphereInputPage(
        fetcher: widget.fetcher,
        initialValue: widget.initialValue,
        onChanged: widget.onChanged,
      )),
      children: [
        Expanded(child: _buildItems()),
      ],
    );
  }

  Widget _buildItems() {
    var children = <Widget>[];

    if (_atmosphere.hasTemperature()) {
      children.add(_AtmosphereItem(
        icon: Icons.filter_drama,
        title: _atmosphere.temperature.displayValue(context),
        subtitle: _atmosphere.skyCondition.displayName(context),
      ));
    }

    if (_atmosphere.hasWindSpeed()) {
      children.add(_AtmosphereItem(
        icon: Icons.air,
        title: _atmosphere.windSpeed.displayValue(context),
        subtitle: _atmosphere.windDirection.displayName(context),
      ));
    }

    if (_atmosphere.hasPressure()) {
      children.add(_AtmosphereItem(
        icon: Icons.speed,
        title: _atmosphere.pressure.displayValue(context),
        subtitle: Strings.of(context).atmosphereInputPressure,
      ));
    }

    if (_atmosphere.hasVisibility()) {
      children.add(_AtmosphereItem(
        icon: Icons.visibility,
        title: _atmosphere.visibility.displayValue(context),
        subtitle: Strings.of(context).atmosphereInputVisibility,
      ));
    }

    if (_atmosphere.hasHumidity()) {
      children.add(_AtmosphereItem(
        icon: Icons.water,
        title: "${_atmosphere.humidity}%",
        subtitle: Strings.of(context).atmosphereInputHumidity,
      ));
    }

    if (_atmosphere.hasSunriseTimestamp()) {
      children.add(_AtmosphereItem(
        icon: Icons.wb_sunny_outlined,
        title: formatTimestampTime(context, _atmosphere.sunriseTimestamp),
        subtitle: Strings.of(context).atmosphereInputSunrise,
      ));
    }

    if (_atmosphere.hasSunsetTimestamp()) {
      children.add(_AtmosphereItem(
        icon: Icons.wb_sunny,
        title: formatTimestampTime(context, _atmosphere.sunsetTimestamp),
        subtitle: Strings.of(context).atmosphereInputSunset,
      ));
    }

    if (_atmosphere.hasMoonPhase()) {
      children.add(_AtmosphereItem(
        icon: Icons.nightlight,
        title: _atmosphere.moonPhase.displayName(context),
        subtitle: Strings.of(context).atmosphereInputMoon,
      ));
    }

    if (children.isEmpty) {
      return PrimaryLabel(Strings.of(context).catchFieldAtmosphere);
    }

    return Wrap(
      spacing: paddingWidget,
      runSpacing: paddingWidget,
      children: children,
    );
  }
}

class _AtmosphereItem extends StatelessWidget {
  static const _width = 65.0;

  final IconData icon;
  final String title;
  final String? subtitle;

  _AtmosphereItem({
    required this.icon,
    required this.title,
    this.subtitle,
  }) : assert(isNotEmpty(title));

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: Column(
        children: [
          Icon(icon),
          PrimaryLabel.multiline(title, align: TextAlign.center),
          isEmpty(subtitle) ? Empty() : SubtitleLabel(subtitle!),
        ],
      ),
    );
  }
}

class _AtmosphereInputPage extends StatefulWidget {
  final AtmosphereFetcher fetcher;
  final Atmosphere? initialValue;
  final void Function(Atmosphere)? onChanged;

  _AtmosphereInputPage({
    required this.fetcher,
    this.initialValue,
    this.onChanged,
  });

  @override
  __AtmosphereInputPageState createState() => __AtmosphereInputPageState();
}

class __AtmosphereInputPageState extends State<_AtmosphereInputPage> {
  // Unique IDs for each field. These are stored in the database and should not
  // be changed.
  static final _idTemperature = Id()
    ..uuid = "efabb5c4-1160-484c-8fdc-a62c71e8e417";
  static final _idWindSpeed = Id()
    ..uuid = "26fc9f13-9e0c-4117-af03-71cbd1a46fb8";
  static final _idWindDirection = Id()
    ..uuid = "3d5a136c-53d6-4198-a5fc-96cbfa620bcf";
  static final _idPressure = Id()
    ..uuid = "cade6d54-aa10-43ef-8741-4421c1a761aa";
  static final _idHumidity = Id()
    ..uuid = "2a799a3f-3eca-4a46-858c-88fb89e66e7b";
  static final _idVisibility = Id()
    ..uuid = "62705e70-9c6b-417d-9a5e-6f3cd59ffd80";
  static final _idMoonPhase = Id()
    ..uuid = "46754037-37bc-4db2-a25e-6cc396d3b815";
  static final _idSkyCondition = Id()
    ..uuid = "d1d6446b-d73d-4343-8f0d-77a51b4a0735";
  static final _idSunriseTimestamp = Id()
    ..uuid = "07a54092-b0dd-43bd-ab07-f26718b2dd7c";
  static final _idSunsetTimestamp = Id()
    ..uuid = "a6a440f4-66a5-4243-b1ce-f3ed4f0cbd66";

  final _log = Log("AtmosphereInputPage");

  final _fields = <Id, Field>{};
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  // Used to determine if a sunset and sunrise time was actually picked or
  // fetched from the web. We don't want to include default times (now) since
  // they are inaccurate.
  var _didPickSunrise = false;
  var _didPickSunset = false;

  TimeManager get _timeManager => TimeManager.of(context);

  SubscriptionManager get _subscriptionManager =>
      SubscriptionManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  MultiMeasurementInputController get _temperatureController =>
      _fields[_idTemperature]!.controller as MultiMeasurementInputController;

  InputController<SkyCondition> get _skyConditionController =>
      _fields[_idSkyCondition]!.controller as InputController<SkyCondition>;

  MultiMeasurementInputController get _windSpeedController =>
      _fields[_idWindSpeed]!.controller as MultiMeasurementInputController;

  InputController<Direction> get _directionController =>
      _fields[_idWindDirection]!.controller as InputController<Direction>;

  MultiMeasurementInputController get _pressureController =>
      _fields[_idPressure]!.controller as MultiMeasurementInputController;

  NumberInputController get _humidityController =>
      _fields[_idHumidity]!.controller as NumberInputController;

  MultiMeasurementInputController get _visibilityController =>
      _fields[_idVisibility]!.controller as MultiMeasurementInputController;

  InputController<MoonPhase> get _moonPhaseController =>
      _fields[_idMoonPhase]!.controller as InputController<MoonPhase>;

  TimestampInputController get _sunriseController =>
      _fields[_idSunriseTimestamp]!.controller as TimestampInputController;

  TimestampInputController get _sunsetController =>
      _fields[_idSunsetTimestamp]!.controller as TimestampInputController;

  @override
  void initState() {
    super.initState();

    _fields[_idTemperature] = Field(
      id: _idTemperature,
      name: (context) => Strings.of(context).atmosphereInputTemperature,
      controller: MultiMeasurementInputController(),
    );

    _fields[_idSkyCondition] = Field(
      id: _idSkyCondition,
      name: (context) => Strings.of(context).atmosphereInputSkyCondition,
      controller: InputController<SkyCondition>(),
    );

    _fields[_idWindDirection] = Field(
      id: _idWindDirection,
      name: (context) => Strings.of(context).atmosphereInputWindDirection,
      controller: InputController<Direction>(),
    );

    _fields[_idWindSpeed] = Field(
      id: _idWindSpeed,
      name: (context) => Strings.of(context).atmosphereInputWindSpeed,
      controller: MultiMeasurementInputController(),
    );

    _fields[_idPressure] = Field(
      id: _idPressure,
      name: (context) => Strings.of(context).atmosphereInputAtmosphericPressure,
      controller: MultiMeasurementInputController(),
    );

    _fields[_idVisibility] = Field(
      id: _idVisibility,
      name: (context) => Strings.of(context).atmosphereInputAirVisibility,
      controller: MultiMeasurementInputController(),
    );

    _fields[_idHumidity] = Field(
      id: _idHumidity,
      name: (context) => Strings.of(context).atmosphereInputAirHumidity,
      controller: NumberInputController(),
    );

    _fields[_idMoonPhase] = Field(
      id: _idMoonPhase,
      name: (context) => Strings.of(context).atmosphereInputMoonPhase,
      controller: InputController<MoonPhase>(),
    );

    _fields[_idSunriseTimestamp] = Field(
      id: _idSunriseTimestamp,
      name: (context) => Strings.of(context).atmosphereInputTimeOfSunrise,
      controller: TimestampInputController(_timeManager),
    );

    _fields[_idSunsetTimestamp] = Field(
      id: _idSunsetTimestamp,
      name: (context) => Strings.of(context).atmosphereInputTimeOfSunset,
      controller: TimestampInputController(_timeManager),
    );

    // Only show fields that the user is interested in.
    var showingFieldIds = _userPreferenceManager.atmosphereFieldIds;
    for (var field in _fields.values) {
      field.showing =
          showingFieldIds.isEmpty || showingFieldIds.contains(field.id);
    }

    // Fetch data if needed.
    if (_subscriptionManager.isPro &&
        _userPreferenceManager.autoFetchAtmosphere &&
        widget.initialValue == null) {
      // This must be done in a post frame callback so
      // _refreshIndicatorKey.currentState returns a non-null value.
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _refreshIndicatorKey.currentState?.show();
      });
    } else if (widget.initialValue != null) {
      _update(widget.initialValue!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EditableFormPage(
      title: Text(Strings.of(context).catchFieldAtmosphere),
      header: _buildHeader(),
      showSaveButton: false,
      allowCustomEntities: false,
      padding: insetsZero,
      fields: _fields,
      onBuildField: _buildField,
      onAddFields: (ids) =>
          _userPreferenceManager.setAtmosphereFieldIds(ids.toList()),
      onRefresh: _fetch,
      refreshIndicatorKey: _refreshIndicatorKey,
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Padding(
          padding: insetsHorizontalDefault,
          child: CheckboxInput(
            label: Strings.of(context).atmosphereInputAutoFetch,
            value: _userPreferenceManager.autoFetchAtmosphere,
            onChanged: (checked) {
              if (_subscriptionManager.isPro && checked) {
                _userPreferenceManager.setAutoFetchAtmosphere(true);
                // Invoke refresh callback and show progress indicator.
                _refreshIndicatorKey.currentState?.show();
              } else if (checked) {
                // "Uncheck" checkbox, since automatically refreshing data is
                // a pro feature.
                setState(() {
                  _userPreferenceManager.setAutoFetchAtmosphere(false);
                });
                present(context, ProPage());
              } else {
                _userPreferenceManager.setAutoFetchAtmosphere(false);
              }
            },
          ),
        ),
        MinDivider(),
      ],
    );
  }

  Widget _buildField(Id id) {
    if (id == _idTemperature) {
      return _buildTemperature();
    } else if (id == _idWindSpeed) {
      return _buildWindSpeed();
    } else if (id == _idWindDirection) {
      return _buildWindDirection();
    } else if (id == _idPressure) {
      return _buildPressure();
    } else if (id == _idHumidity) {
      return _buildHumidity();
    } else if (id == _idVisibility) {
      return _buildVisibility();
    } else if (id == _idMoonPhase) {
      return _buildMoonPhase();
    } else if (id == _idSkyCondition) {
      return _buildSkyCondition();
    } else if (id == _idSunriseTimestamp) {
      return _buildSunrise();
    } else if (id == _idSunsetTimestamp) {
      return _buildSunset();
    } else {
      _log.e("Unknown input key: $id");
      return Empty();
    }
  }

  Widget _buildTemperature() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        spec: MultiMeasurementInputSpec.airTemperature(context),
        controller: _temperatureController,
        onChanged: () => _userPreferenceManager
            .setAirTemperatureSystem(_temperatureController.value?.system),
      ),
    );
  }

  Widget _buildSkyCondition() {
    return ListPickerInput.withSinglePickerPage<SkyCondition>(
      context: context,
      controller: _skyConditionController,
      title: Strings.of(context).atmosphereInputSkyCondition,
      pickerTitle: Strings.of(context).skyConditionPickerTitle,
      valueDisplayName: _skyConditionController.value?.displayName(context),
      noneItem: SkyCondition.sky_condition_none,
      itemBuilder: SkyConditions.pickerItems,
      onPicked: (value) =>
          setState(() => _skyConditionController.value = value),
    );
  }

  Widget _buildWindSpeed() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        spec: MultiMeasurementInputSpec.windSpeed(context),
        controller: _windSpeedController,
        onChanged: () => _userPreferenceManager
            .setWindSpeedSystem(_windSpeedController.value?.system),
      ),
    );
  }

  Widget _buildWindDirection() {
    return ListPickerInput.withSinglePickerPage<Direction>(
      context: context,
      controller: _directionController,
      title: Strings.of(context).atmosphereInputWindDirection,
      pickerTitle: Strings.of(context).directionPickerTitle,
      valueDisplayName: _directionController.value?.displayName(context),
      noneItem: Direction.direction_none,
      itemBuilder: Directions.pickerItems,
      onPicked: (value) => setState(() => _directionController.value = value),
    );
  }

  Widget _buildPressure() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        spec: MultiMeasurementInputSpec.airPressure(context),
        controller: _pressureController,
        onChanged: () => _userPreferenceManager
            .setAirPressureSystem(_pressureController.value?.system),
      ),
    );
  }

  Widget _buildHumidity() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: TextInput.number(
        context,
        controller: _humidityController,
        label: Strings.of(context).atmosphereInputAirHumidity,
        suffixText: "%",
        decimal: false,
        signed: false,
      ),
    );
  }

  Widget _buildVisibility() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        spec: MultiMeasurementInputSpec.airVisibility(context),
        controller: _visibilityController,
        onChanged: () => _userPreferenceManager
            .setAirVisibilitySystem(_visibilityController.value?.system),
      ),
    );
  }

  Widget _buildMoonPhase() {
    return ListPickerInput.withSinglePickerPage<MoonPhase>(
      context: context,
      controller: _moonPhaseController,
      title: Strings.of(context).atmosphereInputMoonPhase,
      pickerTitle: Strings.of(context).moonPhasePickerTitle,
      valueDisplayName: _moonPhaseController.value?.displayName(context),
      noneItem: MoonPhase.moon_phase_none,
      itemBuilder: MoonPhases.pickerItems,
      onPicked: (value) => setState(() => _moonPhaseController.value = value),
    );
  }

  Widget _buildSunrise() {
    return TimePicker(
      context,
      padding: EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingWidget,
      ),
      label: Strings.of(context).atmosphereInputTimeOfSunrise,
      initialTime: _sunriseController.time,
      onChange: (newTime) {
        _sunriseController.time = newTime;
        _didPickSunrise = true;
      },
    );
  }

  Widget _buildSunset() {
    return TimePicker(context,
        padding: EdgeInsets.only(
          left: paddingDefault,
          right: paddingDefault,
          bottom: paddingWidget,
        ),
        label: Strings.of(context).atmosphereInputTimeOfSunset,
        initialTime: _sunsetController.time, onChange: (newTime) {
      _sunsetController.time = newTime;
      _didPickSunset = true;
    });
  }

  Future<void> _fetch() async {
    var atmosphere = await widget.fetcher.fetch();
    if (atmosphere == null) {
      showErrorSnackBar(context, Strings.of(context).atmosphereInputFetchError);
      return;
    }

    _update(atmosphere);
  }

  void _update(Atmosphere atmosphere) {
    // TODO
  }
}
