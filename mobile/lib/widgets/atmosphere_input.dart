import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/widgets/fetch_input_header.dart';

import '../atmosphere_fetcher.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/editable_form_page.dart';
import '../pages/form_page.dart';
import '../pages/picker_page.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../user_preference_manager.dart';
import '../utils/atmosphere_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import 'atmosphere_wrap.dart';
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

    for (var field in allAtmosphereFields(context)) {
      _fields[field.id] = field;
    }

    if (widget.controller.value != null) {
      _updateFromAtmosphere(widget.controller.value!);
    }
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
        FormPageOverflowOption.autoFetch(context),
      ],
      trackedFieldIds: _userPreferenceManager.atmosphereFieldIds,
    );
  }

  Widget _buildHeader() {
    return FetchInputHeader<Atmosphere>(
      fishingSpot: widget.fishingSpot,
      defaultErrorMessage: Strings.of(context).inputGenericFetchError,
      dateTime: widget.fetcher.dateTime,
      onFetch: widget.fetcher.fetch,
      onFetchSuccess: (atmosphere) =>
          setState(() => _updateFromAtmosphere(atmosphere)),
      controller: widget.controller,
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
        spec: _temperatureController.spec,
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
        spec: _windSpeedController.spec,
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
        spec: _pressureController.spec,
        controller: _pressureController,
        onChanged: _updateFromControllers,
      ),
    );
  }

  Widget _buildHumidity() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        spec: _humidityController.spec,
        controller: _humidityController,
        onChanged: _updateFromControllers,
      ),
    );
  }

  Widget _buildVisibility() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        spec: _visibilityController.spec,
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

  void _updateFromAtmosphere(Atmosphere atmosphere) {
    if (atmosphere.hasTemperature()) {
      _temperatureController.value = atmosphere.temperature;
    }

    if (atmosphere.skyConditions.isNotEmpty) {
      _skyConditionController.value = atmosphere.skyConditions.toSet();
    }

    if (atmosphere.hasWindDirection()) {
      _directionController.value = atmosphere.windDirection;
    }

    if (atmosphere.hasWindSpeed()) {
      _windSpeedController.value = atmosphere.windSpeed;
    }

    if (atmosphere.hasPressure()) {
      _pressureController.value = atmosphere.pressure;
    }

    if (atmosphere.hasVisibility()) {
      _visibilityController.value = atmosphere.visibility;
    }

    if (atmosphere.hasHumidity()) {
      _humidityController.value = atmosphere.humidity;
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
      result.temperature = _temperatureController.value;
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
      result.windSpeed = _windSpeedController.value;
      isSet = true;
    }

    if (_pressureController.isSet) {
      result.pressure = _pressureController.value;
      isSet = true;
    }

    if (_visibilityController.isSet) {
      result.visibility = _visibilityController.value;
      isSet = true;
    }

    if (_humidityController.isSet) {
      result.humidity = _humidityController.value;
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
