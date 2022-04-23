import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/widgets/list_item.dart';

import '../atmosphere_fetcher.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/editable_form_page.dart';
import '../pages/form_page.dart';
import '../pages/picker_page.dart';
import '../pages/pro_page.dart';
import '../pages/settings_page.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../subscription_manager.dart';
import '../user_preference_manager.dart';
import '../utils/atmosphere_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/snackbar_utils.dart';
import 'atmosphere_wrap.dart';
import 'button.dart';
import 'date_time_picker.dart';
import 'detail_input.dart';
import 'field.dart';
import 'input_controller.dart';
import 'list_picker_input.dart';
import 'multi_list_picker_input.dart';
import 'multi_measurement_input.dart';
import 'widget.dart';

class AtmosphereInput extends StatelessWidget {
  final AtmosphereFetcher fetcher;
  final InputController<Atmosphere> controller;
  final FishingSpot? fishingSpot;

  const AtmosphereInput({
    required this.fetcher,
    required this.controller,
    this.fishingSpot,
  });

  @override
  Widget build(BuildContext context) {
    return DetailInput(
      onTap: () => push(
        context,
        _AtmosphereInputPage(
          fetcher: fetcher,
          controller: controller,
          fishingSpot: fishingSpot,
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
          Strings.of(context).inputAtmosphere,
          style: stylePrimary(context),
        );

        Widget secondChild;
        if (atmosphere == null) {
          secondChild = const Empty();
        } else {
          secondChild = AtmosphereWrap(atmosphere);
        }

        return AnimatedCrossFade(
          crossFadeState: state,
          duration: animDurationDefault,
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
  final FishingSpot? fishingSpot;

  const _AtmosphereInputPage({
    required this.fetcher,
    required this.controller,
    required this.fishingSpot,
  });

  @override
  __AtmosphereInputPageState createState() => __AtmosphereInputPageState();
}

class __AtmosphereInputPageState extends State<_AtmosphereInputPage> {
  static const _log = Log("AtmosphereInputPage");

  // Note that the input fields do not include a time zone picker. This is
  // because atmosphere is always included in entities that have their own
  // time zone. As such, the atmosphere's time zone is set to that of the
  // parent entity.
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

  final _fields = <Id, Field>{};

  late final MultiMeasurementInputSpec _airTemperatureInputState;
  late final MultiMeasurementInputSpec _airPressureInputState;
  late final MultiMeasurementInputSpec _airVisibilityInputState;
  late final MultiMeasurementInputSpec _airHumidityInputState;
  late final MultiMeasurementInputSpec _windSpeedInputState;

  StreamSubscription<void>? _userPreferenceSubscription;

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

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

  MultiMeasurementInputController get _humidityController =>
      _fields[_idHumidity]!.controller as MultiMeasurementInputController;

  MultiMeasurementInputController get _visibilityController =>
      _fields[_idVisibility]!.controller as MultiMeasurementInputController;

  InputController<MoonPhase> get _moonPhaseController =>
      _fields[_idMoonPhase]!.controller as InputController<MoonPhase>;

  DateTimeInputController get _sunriseController =>
      _fields[_idSunriseTimestamp]!.controller as DateTimeInputController;

  DateTimeInputController get _sunsetController =>
      _fields[_idSunsetTimestamp]!.controller as DateTimeInputController;

  @override
  void initState() {
    super.initState();

    _airTemperatureInputState =
        MultiMeasurementInputSpec.airTemperature(context);
    _airPressureInputState = MultiMeasurementInputSpec.airPressure(context);
    _airVisibilityInputState = MultiMeasurementInputSpec.airVisibility(context);
    _airHumidityInputState = MultiMeasurementInputSpec.airHumidity(context);
    _windSpeedInputState = MultiMeasurementInputSpec.windSpeed(context);

    _fields[_idTemperature] = Field(
      id: _idTemperature,
      name: (context) => Strings.of(context).atmosphereInputTemperature,
      controller: _airTemperatureInputState.newInputController(),
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
      controller: _windSpeedInputState.newInputController(),
    );

    _fields[_idPressure] = Field(
      id: _idPressure,
      name: (context) => Strings.of(context).atmosphereInputAtmosphericPressure,
      controller: _airPressureInputState.newInputController(),
    );

    _fields[_idVisibility] = Field(
      id: _idVisibility,
      name: (context) => Strings.of(context).atmosphereInputAirVisibility,
      controller: _airVisibilityInputState.newInputController(),
    );

    _fields[_idHumidity] = Field(
      id: _idHumidity,
      name: (context) => Strings.of(context).atmosphereInputAirHumidity,
      controller: _airHumidityInputState.newInputController(),
    );

    _fields[_idMoonPhase] = Field(
      id: _idMoonPhase,
      name: (context) => Strings.of(context).atmosphereInputMoonPhase,
      controller: InputController<MoonPhase>(),
    );

    _fields[_idSunriseTimestamp] = Field(
      id: _idSunriseTimestamp,
      name: (context) => Strings.of(context).atmosphereInputTimeOfSunrise,
      controller: DateTimeInputController(context),
    );

    _fields[_idSunsetTimestamp] = Field(
      id: _idSunsetTimestamp,
      name: (context) => Strings.of(context).atmosphereInputTimeOfSunset,
      controller: DateTimeInputController(context),
    );

    if (widget.controller.value != null) {
      _updateFromAtmosphere(widget.controller.value!);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _userPreferenceSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return EditableFormPage(
      title: Text(Strings.of(context).inputAtmosphere),
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
      overflowOptions: [
        FormPageOverflowOption.manageUnits(context),
        FormPageOverflowOption(Strings.of(context).atmosphereInputAutoFetch,
            () => present(context, SettingsPage())),
      ],
      trackedFieldIds: _userPreferenceManager.atmosphereFieldIds,
    );
  }

  Widget _buildHeader() {
    String location = Strings.of(context).atmosphereInputCurrentLocation;
    if (widget.fishingSpot != null) {
      location = _fishingSpotManager.displayName(
        context,
        widget.fishingSpot!,
        useLatLngFallback: true,
        includeLatLngLabels: true,
        includeBodyOfWater: true,
      );
    }

    return Column(
      children: [
        ListItem(
          title: Text(
            location,
            style: stylePrimary(context),
          ),
          subtitle: Text(
            formatDateTime(context, widget.fetcher.dateTime),
            style: stylePrimary(context),
          ),
          trailing: Button(
            text: Strings.of(context).atmosphereInputFetch,
            onPressed: _fetch,
          ),
        ),
        const MinDivider(),
        NoneFormHeader(controller: widget.controller),
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
      _log.e(StackTrace.current, "Unknown input key: $id");
      return const Empty();
    }
  }

  Widget _buildTemperature() {
    return Padding(
      padding: insetsHorizontalDefaultBottomSmall,
      child: MultiMeasurementInput(
        spec: _airTemperatureInputState,
        controller: _temperatureController,
        onChanged: _updateFromControllers,
      ),
    );
  }

  Widget _buildSkyConditions() {
    return MultiListPickerInput(
      padding: insetsDefault,
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
        spec: _windSpeedInputState,
        controller: _windSpeedController,
        onChanged: _updateFromControllers,
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
        spec: _airPressureInputState,
        controller: _pressureController,
        onChanged: _updateFromControllers,
      ),
    );
  }

  Widget _buildHumidity() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        spec: _airHumidityInputState,
        controller: _humidityController,
        onChanged: _updateFromControllers,
      ),
    );
  }

  Widget _buildVisibility() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        spec: _airVisibilityInputState,
        controller: _visibilityController,
        onChanged: _updateFromControllers,
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
      padding: const EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingDefault,
      ),
      label: Strings.of(context).atmosphereInputTimeOfSunrise,
      controller: _sunriseController,
      onChange: (_) => _updateFromControllers(),
    );
  }

  Widget _buildSunset() {
    return TimePicker(
      context,
      padding: const EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingDefault,
      ),
      label: Strings.of(context).atmosphereInputTimeOfSunset,
      controller: _sunsetController,
      onChange: (_) => _updateFromControllers(),
    );
  }

  Future<void> _fetch() async {
    if (_subscriptionManager.isFree) {
      present(context, const ProPage());
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
      _temperatureController.value = MultiMeasurement(
        system: _userPreferenceManager.airTemperatureSystem,
        mainValue: atmosphere.temperature,
      );
    }

    if (atmosphere.skyConditions.isNotEmpty) {
      _skyConditionController.value = atmosphere.skyConditions.toSet();
    }

    if (atmosphere.hasWindDirection()) {
      _directionController.value = atmosphere.windDirection;
    }

    if (atmosphere.hasWindSpeed()) {
      _windSpeedController.value = MultiMeasurement(
        system: _userPreferenceManager.windSpeedSystem,
        mainValue: atmosphere.windSpeed,
      );
    }

    if (atmosphere.hasPressure()) {
      _pressureController.value = MultiMeasurement(
        system: _userPreferenceManager.airPressureSystem,
        mainValue: atmosphere.pressure,
      );
    }

    if (atmosphere.hasVisibility()) {
      _visibilityController.value = MultiMeasurement(
        system: _userPreferenceManager.airVisibilitySystem,
        mainValue: atmosphere.visibility,
      );
    }

    if (atmosphere.hasHumidity()) {
      _humidityController.value = MultiMeasurement(
        mainValue: atmosphere.humidity,
      );
    }

    if (atmosphere.hasMoonPhase()) {
      _moonPhaseController.value = atmosphere.moonPhase;
    }

    if (atmosphere.hasSunriseTimestamp()) {
      _sunriseController.value = atmosphere.sunriseDateTime(context);
    }

    if (atmosphere.hasSunsetTimestamp()) {
      _sunsetController.value = atmosphere.sunsetDateTime(context);
    }

    widget.controller.value = atmosphere;
  }

  void _updateFromControllers() {
    var result = Atmosphere();
    var isSet = false;

    if (_temperatureController.isSet) {
      result.temperature = _temperatureController.value.mainValue;
      isSet = true;
    }

    if (_skyConditionController.value.isNotEmpty) {
      result.skyConditions.addAll(_skyConditionController.value);
      isSet = true;
    }

    if (_directionController.hasValue) {
      result.windDirection = _directionController.value!;
      isSet = true;
    }

    if (_windSpeedController.isSet) {
      result.windSpeed = _windSpeedController.value.mainValue;
      isSet = true;
    }

    if (_pressureController.isSet) {
      result.pressure = _pressureController.value.mainValue;
      isSet = true;
    }

    if (_visibilityController.isSet) {
      result.visibility = _visibilityController.value.mainValue;
      isSet = true;
    }

    if (_humidityController.isSet) {
      result.humidity = _humidityController.value.mainValue;
      isSet = true;
    }

    if (_moonPhaseController.hasValue) {
      result.moonPhase = _moonPhaseController.value!;
      isSet = true;
    }

    if (_sunriseController.hasValue) {
      result.sunriseTimestamp = Int64(_sunriseController.timestamp!);
      isSet = true;
    }

    if (_sunsetController.hasValue) {
      result.sunsetTimestamp = Int64(_sunsetController.timestamp!);
      isSet = true;
    }

    widget.controller.value = isSet ? result : null;
  }
}
