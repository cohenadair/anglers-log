import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../atmosphere_fetcher.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/editable_form_page.dart';
import '../pages/picker_page.dart';
import '../pages/pro_page.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../subscription_manager.dart';
import '../time_manager.dart';
import '../user_preference_manager.dart';
import '../utils/atmosphere_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/snackbar_utils.dart';
import 'atmosphere_wrap.dart';
import 'date_time_picker.dart';
import 'detail_input.dart';
import 'field.dart';
import 'input_controller.dart';
import 'list_item.dart';
import 'list_picker_input.dart';
import 'multi_list_picker_input.dart';
import 'multi_measurement_input.dart';
import 'text_input.dart';
import 'widget.dart';

class AtmosphereInput extends StatelessWidget {
  final AtmosphereFetcher fetcher;
  final EdgeInsets? padding;
  final InputController<Atmosphere> controller;

  AtmosphereInput({
    required this.fetcher,
    required this.controller,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return DetailInput(
      onTap: () => push(
        context,
        _AtmosphereInputPage(
          fetcher: fetcher,
          controller: controller,
        ),
      ),
      children: [
        Expanded(child: _buildItems(context)),
      ],
    );
  }

  Widget _buildItems(BuildContext context) {
    return ValueListenableBuilder<Atmosphere?>(
      valueListenable: controller,
      builder: (context, atmosphere, _) {
        CrossFadeState state;
        if (atmosphere == null) {
          state = CrossFadeState.showFirst;
        } else {
          state = CrossFadeState.showSecond;
        }

        var firstChild = Text(
          Strings.of(context).catchFieldAtmosphere,
          style: stylePrimary(context),
        );

        Widget secondChild;
        if (atmosphere == null) {
          secondChild = Empty();
        } else {
          secondChild = AtmosphereWrap(atmosphere);
        }

        return AnimatedCrossFade(
          crossFadeState: state,
          duration: defaultAnimationDuration,
          firstChild: firstChild,
          secondChild: secondChild,
        );
      },
    );
  }
}

class _AtmosphereInputPage extends StatefulWidget {
  final AtmosphereFetcher fetcher;
  final InputController<Atmosphere> controller;

  _AtmosphereInputPage({
    required this.fetcher,
    required this.controller,
  });

  @override
  __AtmosphereInputPageState createState() => __AtmosphereInputPageState();
}

class __AtmosphereInputPageState extends State<_AtmosphereInputPage> {
  static final _idTemperature = atmosphereFieldIdTemperature;
  static final _idWindSpeed = atmosphereFieldIdWindSpeed;
  static final _idWindDirection = atmosphereFieldIdWindDirection;
  static final _idPressure = atmosphereFieldIdPressure;
  static final _idHumidity = atmosphereFieldIdHumidity;
  static final _idVisibility = atmosphereFieldIdVisibility;
  static final _idMoonPhase = atmosphereFieldIdMoonPhase;
  static final _idSkyCondition = atmosphereFieldIdSkyCondition;
  static final _idSunriseTimestamp = atmosphereFieldIdSunriseTimestamp;
  static final _idSunsetTimestamp = atmosphereFieldIdSunsetTimestamp;

  final _log = Log("AtmosphereInputPage");

  final _fields = <Id, Field>{};

  late final MultiMeasurementInputState _airTemperatureInputState;
  late final MultiMeasurementInputState _windSpeedInputState;
  late final MultiMeasurementInputState _airPressureInputState;
  late final MultiMeasurementInputState _airVisibilityInputState;

  TimeManager get _timeManager => TimeManager.of(context);

  SubscriptionManager get _subscriptionManager =>
      SubscriptionManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  MultiMeasurementInputController get _temperatureController =>
      _fields[_idTemperature]!.controller as MultiMeasurementInputController;

  SetInputController<SkyCondition> get _skyConditionController =>
      _fields[_idSkyCondition]!.controller as SetInputController<SkyCondition>;

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

    _airTemperatureInputState =
        MultiMeasurementInputState.airTemperature(context);
    _windSpeedInputState = MultiMeasurementInputState.windSpeed(context);
    _airPressureInputState = MultiMeasurementInputState.airPressure(context);
    _airVisibilityInputState =
        MultiMeasurementInputState.airVisibility(context);

    _fields[_idTemperature] = Field(
      id: _idTemperature,
      name: (context) => Strings.of(context).atmosphereInputTemperature,
      controller: _airTemperatureInputState.controller,
    );

    _fields[_idSkyCondition] = Field(
      id: _idSkyCondition,
      name: (context) => Strings.of(context).atmosphereInputSkyConditions,
      controller: SetInputController<SkyCondition>(),
    );

    _fields[_idWindDirection] = Field(
      id: _idWindDirection,
      name: (context) => Strings.of(context).atmosphereInputWindDirection,
      controller: InputController<Direction>(),
    );

    _fields[_idWindSpeed] = Field(
      id: _idWindSpeed,
      name: (context) => Strings.of(context).atmosphereInputWindSpeed,
      controller: _windSpeedInputState.controller,
    );

    _fields[_idPressure] = Field(
      id: _idPressure,
      name: (context) => Strings.of(context).atmosphereInputAtmosphericPressure,
      controller: _airPressureInputState.controller,
    );

    _fields[_idVisibility] = Field(
      id: _idVisibility,
      name: (context) => Strings.of(context).atmosphereInputAirVisibility,
      controller: _airVisibilityInputState.controller,
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

    if (widget.controller.value != null) {
      _updateFromAtmosphere(widget.controller.value!);
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
      onAddFields: (ids) {
        _userPreferenceManager.setAtmosphereFieldIds(ids.toList());

        // Clear fields that are no longer showing.
        for (var field in _fields.values) {
          if (!ids.contains(field.id)) {
            field.controller.clear();
          }
        }
        _updateFromControllers();
      },
      onRefresh: _fetch,
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        PickerListItem(
          padding: insetsDefault,
          title: Strings.of(context).none,
          isSelected: !widget.controller.hasValue,
          onTap: () {
            widget.controller.clear();
            Navigator.pop(context);
          },
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
      return _buildSkyConditions();
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
        state: _airTemperatureInputState,
        onChanged: () {
          _userPreferenceManager
              .setAirTemperatureSystem(_temperatureController.value?.system);
          _updateFromControllers();
        },
      ),
    );
  }

  Widget _buildSkyConditions() {
    return MultiListPickerInput(
      padding: insetsHorizontalDefaultVerticalWidget,
      values: _skyConditionController.value
          .map((c) => c.displayName(context))
          .toSet(),
      emptyValue: (context) =>
          Strings.of(context).atmosphereInputNoSkyConditions,
      onTap: () {
        push(
          context,
          PickerPage<SkyCondition>(
            itemBuilder: () => SkyConditions.pickerItems(context),
            initialValues: _skyConditionController.value,
            title: Text(Strings.of(context).pickerTitleSkyConditions),
            allItem: PickerPageItem<SkyCondition>(
              title: Strings.of(context).all,
              value: SkyCondition.sky_condition_all,
              isMultiNone: true,
            ),
            onFinishedPicking: (context, skyConditions) {
              setState(() {
                _skyConditionController.value = skyConditions;
                _updateFromControllers();
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildWindSpeed() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        state: _windSpeedInputState,
        onChanged: () {
          _userPreferenceManager
              .setWindSpeedSystem(_windSpeedController.value?.system);
          _updateFromControllers();
        },
      ),
    );
  }

  Widget _buildWindDirection() {
    return ListPickerInput.withSinglePickerPage<Direction>(
      context: context,
      controller: _directionController,
      title: Strings.of(context).atmosphereInputWindDirection,
      pickerTitle: Strings.of(context).pickerTitleWindDirection,
      valueDisplayName: _directionController.value?.displayName(context),
      noneItem: Direction.direction_none,
      itemBuilder: Directions.pickerItems,
      onPicked: (value) => setState(() {
        _directionController.value = value;
        _updateFromControllers();
      }),
    );
  }

  Widget _buildPressure() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        state: _airPressureInputState,
        onChanged: () {
          _userPreferenceManager
              .setAirPressureSystem(_pressureController.value?.system);
          _updateFromControllers();
        },
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
        onChanged: (_) => _updateFromControllers(),
      ),
    );
  }

  Widget _buildVisibility() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        state: _airVisibilityInputState,
        onChanged: () {
          _userPreferenceManager
              .setAirVisibilitySystem(_visibilityController.value?.system);
          _updateFromControllers();
        },
      ),
    );
  }

  Widget _buildMoonPhase() {
    return ListPickerInput.withSinglePickerPage<MoonPhase>(
      context: context,
      controller: _moonPhaseController,
      title: Strings.of(context).atmosphereInputMoonPhase,
      pickerTitle: Strings.of(context).pickerTitleMoonPhase,
      valueDisplayName: _moonPhaseController.value?.displayName(context),
      noneItem: MoonPhase.moon_phase_none,
      itemBuilder: MoonPhases.pickerItems,
      onPicked: (value) => setState(() {
        _moonPhaseController.value = value;
        _updateFromControllers();
      }),
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
      controller: _sunriseController,
      onChange: (_) => _updateFromControllers(),
    );
  }

  Widget _buildSunset() {
    return TimePicker(
      context,
      padding: EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingWidget,
      ),
      label: Strings.of(context).atmosphereInputTimeOfSunset,
      controller: _sunsetController,
      onChange: (_) => _updateFromControllers(),
    );
  }

  Future<void> _fetch() async {
    if (_subscriptionManager.isFree) {
      present(context, ProPage());
      return;
    }

    var atmosphere = await widget.fetcher.fetch();
    if (atmosphere == null) {
      showErrorSnackBar(context, Strings.of(context).atmosphereInputFetchError);
      return;
    }
    setState(() {
      _updateFromAtmosphere(atmosphere);
    });
  }

  void _updateFromAtmosphere(Atmosphere atmosphere) {
    if (atmosphere.hasTemperature()) {
      _temperatureController.value = MultiMeasurements.from(
          atmosphere.temperature, _userPreferenceManager.airTemperatureSystem);
    }

    if (atmosphere.skyConditions.isNotEmpty) {
      _skyConditionController.value = atmosphere.skyConditions.toSet();
    }

    if (atmosphere.hasWindDirection()) {
      _directionController.value = atmosphere.windDirection;
    }

    if (atmosphere.hasWindSpeed()) {
      _windSpeedController.value = MultiMeasurements.from(
          atmosphere.windSpeed, _userPreferenceManager.windSpeedSystem);
    }

    if (atmosphere.hasPressure()) {
      _pressureController.value = MultiMeasurements.from(
          atmosphere.pressure, _userPreferenceManager.airPressureSystem);
    }

    if (atmosphere.hasVisibility()) {
      _visibilityController.value = MultiMeasurements.from(
          atmosphere.visibility, _userPreferenceManager.airVisibilitySystem);
    }

    if (atmosphere.hasHumidity()) {
      _humidityController.intValue = atmosphere.humidity;
    }

    if (atmosphere.hasMoonPhase()) {
      _moonPhaseController.value = atmosphere.moonPhase;
    }

    if (atmosphere.hasSunriseTimestamp()) {
      _sunriseController.value = atmosphere.sunriseTimestamp.toInt();
    }

    if (atmosphere.hasSunsetTimestamp()) {
      _sunsetController.value = atmosphere.sunsetTimestamp.toInt();
    }

    widget.controller.value = atmosphere;
  }

  void _updateFromControllers() {
    var result = Atmosphere();
    var isSet = false;

    if (_temperatureController.isSet) {
      result.temperature = _temperatureController.value!.mainValue;
      isSet = true;
    }

    if (_skyConditionController.hasValue) {
      result.skyConditions.addAll(_skyConditionController.value);
      isSet = true;
    }

    if (_directionController.hasValue) {
      result.windDirection = _directionController.value!;
      isSet = true;
    }

    if (_windSpeedController.isSet) {
      result.windSpeed = _windSpeedController.value!.mainValue;
      isSet = true;
    }

    if (_pressureController.isSet) {
      result.pressure = _pressureController.value!.mainValue;
      isSet = true;
    }

    if (_visibilityController.isSet) {
      result.visibility = _visibilityController.value!.mainValue;
      isSet = true;
    }

    if (_humidityController.hasIntValue) {
      result.humidity = _humidityController.intValue!;
      isSet = true;
    }

    if (_moonPhaseController.hasValue) {
      result.moonPhase = _moonPhaseController.value!;
      isSet = true;
    }

    if (_sunriseController.hasValue) {
      result.sunriseTimestamp = Int64(_sunriseController.value);
      isSet = true;
    }

    if (_sunsetController.hasValue) {
      result.sunsetTimestamp = Int64(_sunsetController.value);
      isSet = true;
    }

    widget.controller.value = isSet ? result : null;
  }
}
