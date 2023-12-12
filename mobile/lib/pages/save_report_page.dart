import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/gear_manager.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/widgets/entity_picker_input.dart';
import 'package:quiver/strings.dart';

import '../angler_manager.dart';
import '../body_of_water_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../method_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/fishing_spot_list_page.dart';
import '../pages/form_page.dart';
import '../pages/species_list_page.dart';
import '../report_manager.dart';
import '../res/dimen.dart';
import '../species_manager.dart';
import '../user_preference_manager.dart';
import '../utils/atmosphere_utils.dart';
import '../utils/catch_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/validator.dart';
import '../water_clarity_manager.dart';
import '../widgets/checkbox_input.dart';
import '../widgets/date_range_picker_input.dart';
import '../widgets/input_controller.dart';
import '../widgets/multi_list_picker_input.dart';
import '../widgets/multi_measurement_input.dart';
import '../widgets/number_filter_input.dart';
import '../widgets/radio_input.dart';
import '../widgets/text_input.dart';
import '../widgets/time_zone_input.dart';
import '../widgets/widget.dart';
import 'angler_list_page.dart';
import 'bait_list_page.dart';
import 'body_of_water_list_page.dart';
import 'gear_list_page.dart';
import 'method_list_page.dart';
import 'picker_page.dart';
import 'water_clarity_list_page.dart';

class SaveReportPage extends StatefulWidget {
  final Report? oldReport;

  const SaveReportPage() : oldReport = null;

  const SaveReportPage.edit(this.oldReport) : assert(oldReport != null);

  @override
  SaveReportPageState createState() => SaveReportPageState();
}

class SaveReportPageState extends State<SaveReportPage> {
  static const Key _keySummaryStart = ValueKey(0);
  static const Key _keyComparisonStart = ValueKey(1);

  late final TextInputController _nameController;
  late final TimeZoneInputController _timeZoneController;
  final _descriptionController = TextInputController();
  final _typeController = InputController<Report_Type>();
  final _fromDateRangeController = InputController<DateRange>();
  final _toDateRangeController = InputController<DateRange>();
  final _anglersController = SetInputController<Id>();
  final _speciesController = SetInputController<Id>();
  final _baitsController = SetInputController<BaitAttachment>();
  final _gearController = SetInputController<Id>();
  final _fishingSpotsController = SetInputController<Id>();
  final _bodiesOfWaterController = SetInputController<Id>();
  final _methodsController = SetInputController<Id>();
  final _periodsController = SetInputController<Period>();
  final _favoritesOnlyController = BoolInputController();
  final _catchAndReleaseOnlyController = BoolInputController();
  final _seasonsController = SetInputController<Season>();
  final _waterClaritiesController = SetInputController<Id>();
  final _waterDepthController = NumberFilterInputController();
  final _waterTemperatureController = NumberFilterInputController();
  final _lengthController = NumberFilterInputController();
  final _weightController = NumberFilterInputController();
  final _quantityController = NumberFilterInputController();
  final _airTemperatureController = NumberFilterInputController();
  final _airPressureController = NumberFilterInputController();
  final _airHumidityController = NumberFilterInputController();
  final _airVisibilityController = NumberFilterInputController();
  final _windSpeedController = NumberFilterInputController();
  final _windDirectionsController = SetInputController<Direction>();
  final _skyConditionsController = SetInputController<SkyCondition>();
  final _moonPhasesController = SetInputController<MoonPhase>();
  final _tideTypesController = SetInputController<TideType>();

  AnglerManager get _anglerManager => AnglerManager.of(context);

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  ReportManager get _reportManager => ReportManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  GearManager get _gearManager => GearManager.of(context);

  MethodManager get _methodManager => MethodManager.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  TimeManager get _timeManager => TimeManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  WaterClarityManager get _waterClarityManager =>
      WaterClarityManager.of(context);

  Report? get _oldReport => widget.oldReport;

  bool get _isEditing => _oldReport != null;

  bool get _isComparison => _typeController.value == Report_Type.comparison;

  bool get _isSummary => _typeController.value == Report_Type.summary;

  @override
  void initState() {
    super.initState();

    _nameController = TextInputController(
      validator: NameValidator(
        nameExistsMessage: (context) =>
            Strings.of(context).saveReportPageNameExists,
        nameExists: (newName) => _reportManager.nameExists(newName),
        oldName: _oldReport?.name,
      ),
    );

    _timeZoneController = TimeZoneInputController(context);

    if (_isEditing) {
      _nameController.value = _oldReport!.name;
      _descriptionController.value = _oldReport!.description;
      _typeController.value = _oldReport!.type;
      _fromDateRangeController.value = _oldReport!.fromDateRange;
      if (_oldReport!.hasToDateRange()) {
        _toDateRangeController.value = _oldReport!.toDateRange;
      }
      _timeZoneController.value = _oldReport!.timeZone;
      _catchAndReleaseOnlyController.value = _oldReport!.isCatchAndReleaseOnly;
      _favoritesOnlyController.value = _oldReport!.isFavoritesOnly;
      _periodsController.value = _oldReport!.periods.toSet();
      _seasonsController.value = _oldReport!.seasons.toSet();
      _waterDepthController.value = _oldReport!.waterDepthFilter;
      _waterTemperatureController.value = _oldReport!.waterTemperatureFilter;
      _lengthController.value = _oldReport!.lengthFilter;
      _weightController.value = _oldReport!.weightFilter;
      _quantityController.value = _oldReport!.quantityFilter;
      _airTemperatureController.value = _oldReport!.airTemperatureFilter;
      _airPressureController.value = _oldReport!.airPressureFilter;
      _airHumidityController.value = _oldReport!.airHumidityFilter;
      _airVisibilityController.value = _oldReport!.airVisibilityFilter;
      _windSpeedController.value = _oldReport!.windSpeedFilter;
      _windDirectionsController.value = _oldReport!.windDirections.toSet();
      _skyConditionsController.value = _oldReport!.skyConditions.toSet();
      _moonPhasesController.value = _oldReport!.moonPhases.toSet();
      _tideTypesController.value = _oldReport!.tideTypes.toSet();
      _baitsController.value = _oldReport!.baits.toSet();
      _initEntitySets(
        anglerIds: _oldReport!.anglerIds,
        fishingSpotIds: _oldReport!.fishingSpotIds,
        bodyOfWaterIds: _oldReport!.bodyOfWaterIds,
        methodIds: _oldReport!.methodIds,
        speciesIds: _oldReport!.speciesIds,
        waterClarityIds: _oldReport!.waterClarityIds,
        gearIds: _oldReport!.gearIds,
      );
    } else {
      _typeController.value = Report_Type.summary;
      _fromDateRangeController.value = DateRange(
        period: DateRange_Period.allDates,
        timeZone: _timeManager.currentTimeZone,
      );
      if (_isComparison) {
        _toDateRangeController.value = DateRange(
          period: DateRange_Period.allDates,
          timeZone: _timeManager.currentTimeZone,
        );
      }
      _initEntitySets();
    }
  }

  void _initEntitySets({
    List<Id> anglerIds = const [],
    List<Id> fishingSpotIds = const [],
    List<Id> bodyOfWaterIds = const [],
    List<Id> methodIds = const [],
    List<Id> speciesIds = const [],
    List<Id> waterClarityIds = const [],
    List<Id> gearIds = const [],
  }) {
    // "Empty" lists will include all entities in reports, so don't actually
    // include every entity in the report object.
    _anglersController.value =
        anglerIds.isEmpty ? {} : _anglerManager.idSet(ids: anglerIds);
    _fishingSpotsController.value = fishingSpotIds.isEmpty
        ? {}
        : _fishingSpotManager.idSet(ids: fishingSpotIds);
    _bodiesOfWaterController.value = bodyOfWaterIds.isEmpty
        ? {}
        : _bodyOfWaterManager.idSet(ids: bodyOfWaterIds);
    _methodsController.value =
        methodIds.isEmpty ? {} : _methodManager.idSet(ids: methodIds);
    _speciesController.value =
        speciesIds.isEmpty ? {} : _speciesManager.idSet(ids: speciesIds);
    _waterClaritiesController.value = waterClarityIds.isEmpty
        ? {}
        : _waterClarityManager.idSet(ids: waterClarityIds);
    _gearController.value =
        gearIds.isEmpty ? {} : _gearManager.idSet(ids: gearIds);
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      runSpacing: 0,
      padding: insetsZero,
      title: Text(_isEditing
          ? Strings.of(context).saveReportPageEditTitle
          : Strings.of(context).saveReportPageNewTitle),
      isInputValid: _nameController.isValid(context),
      fieldBuilder: (context) => [
        _buildName(),
        _buildDescription(),
        _buildType(),
        _buildStartDateRange(),
        _buildEndDateRange(),
        _buildTimeZone(),
        _buildCatchAndReleaseOnly(),
        _buildFavoritesOnly(),
        _buildWaterDepth(),
        _buildWaterTemperature(),
        _buildLength(),
        _buildWeight(),
        _buildQuantity(),
        _buildAirTemperature(),
        _buildAirHumidity(),
        _buildAirVisibility(),
        _buildAirPressure(),
        _buildWindSpeed(),
        _buildWindDirections(),
        _buildSkyConditions(),
        _buildMoonPhases(),
        _buildTideTypes(),
        _buildWaterClaritiesPicker(),
        _buildPeriodsPicker(),
        _buildSeasonsPicker(),
        _buildAnglersPicker(),
        _buildSpeciesPicker(),
        _buildBaitsPicker(),
        _buildGearPicker(),
        _buildBodiesOfWaterPicker(),
        _buildFishingSpotsPicker(),
        _buildMethodsPicker(),
      ],
      onSave: _save,
    );
  }

  Widget _buildName() {
    return Padding(
      padding: const EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingSmall,
      ),
      child: TextInput.name(
        context,
        controller: _nameController,
        autofocus: true,
        textInputAction: TextInputAction.next,
        // Trigger "Save" button state refresh.
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingSmall,
      ),
      child: TextInput.description(
        context,
        controller: _descriptionController,
      ),
    );
  }

  Widget _buildType() {
    return RadioInput(
      padding: insetsHorizontalDefaultVerticalSmall,
      initialSelectedIndex: _typeController.value!.value,
      optionCount: Report_Type.values.length,
      optionBuilder: (context, index) {
        var type = Report_Type.values[index];
        switch (type) {
          case Report_Type.comparison:
            return Strings.of(context).saveReportPageComparison;
          case Report_Type.summary:
          // Fallthrough.
          default:
            return Strings.of(context).saveReportPageSummary;
        }
      },
      onSelect: (index) =>
          setState(() => _typeController.value = Report_Type.values[index]),
    );
  }

  Widget _buildStartDateRange() {
    return AnimatedSwitcher(
      duration: animDurationDefault,
      child: _isSummary
          ? _startDateRangePicker(_keySummaryStart, null)
          : _startDateRangePicker(_keyComparisonStart,
              Strings.of(context).saveReportPageStartDateRangeLabel),
    );
  }

  Widget _startDateRangePicker(Key key, String? title) {
    return DateRangePickerInput(
      key: key,
      title: title,
      initialDateRange: _fromDateRangeController.value,
      onPicked: (dateRange) => setState(() {
        _fromDateRangeController.value = dateRange;
      }),
    );
  }

  Widget _buildCatchAndReleaseOnly() {
    if (hideCatchField(catchFieldIdCatchAndRelease)) {
      return const Empty();
    }

    return CheckboxInput(
      label: Strings.of(context).saveReportPageCatchAndRelease,
      value: _catchAndReleaseOnlyController.value,
      onChanged: (checked) => _catchAndReleaseOnlyController.value = checked,
    );
  }

  Widget _buildFavoritesOnly() {
    if (hideCatchField(catchFieldIdFavorite)) {
      return const Empty();
    }

    return CheckboxInput(
      label: Strings.of(context).saveReportPageFavorites,
      value: _favoritesOnlyController.value,
      onChanged: (checked) => _favoritesOnlyController.value = checked,
    );
  }

  Widget _buildWaterDepth() {
    if (hideCatchField(catchFieldIdWaterDepth)) {
      return const Empty();
    }

    return NumberFilterInput(
      title: Strings.of(context).catchFieldWaterDepthLabel,
      filterTitle: Strings.of(context).filterTitleWaterDepth,
      controller: _waterDepthController,
      inputSpec: MultiMeasurementInputSpec.waterDepth(context),
    );
  }

  Widget _buildWaterTemperature() {
    if (hideCatchField(catchFieldIdWaterTemperature)) {
      return const Empty();
    }

    return NumberFilterInput(
      title: Strings.of(context).catchFieldWaterTemperatureLabel,
      filterTitle: Strings.of(context).filterTitleWaterTemperature,
      controller: _waterTemperatureController,
      inputSpec: MultiMeasurementInputSpec.waterTemperature(context),
    );
  }

  Widget _buildLength() {
    if (hideCatchField(catchFieldIdLength)) {
      return const Empty();
    }

    return NumberFilterInput(
      title: Strings.of(context).catchFieldLengthLabel,
      filterTitle: Strings.of(context).filterTitleLength,
      controller: _lengthController,
      inputSpec: MultiMeasurementInputSpec.length(context),
    );
  }

  Widget _buildWeight() {
    if (hideCatchField(catchFieldIdWeight)) {
      return const Empty();
    }

    return NumberFilterInput(
      title: Strings.of(context).catchFieldWeightLabel,
      filterTitle: Strings.of(context).filterTitleWeight,
      controller: _weightController,
      inputSpec: MultiMeasurementInputSpec.weight(context),
    );
  }

  Widget _buildQuantity() {
    if (hideCatchField(catchFieldIdQuantity)) {
      return const Empty();
    }

    return NumberFilterInput(
      title: Strings.of(context).catchFieldQuantityLabel,
      filterTitle: Strings.of(context).filterTitleQuantity,
      controller: _quantityController,
    );
  }

  Widget _buildEndDateRange() {
    return AnimatedSwitcher(
      duration: animDurationDefault,
      child: _isSummary
          ? const Empty()
          : DateRangePickerInput(
              title: Strings.of(context).saveReportPageEndDateRangeLabel,
              initialDateRange: _toDateRangeController.value,
              onPicked: (dateRange) => setState(() {
                _toDateRangeController.value = dateRange;
              }),
            ),
    );
  }

  Widget _buildTimeZone() {
    if (hideCatchField(catchFieldIdTimeZone)) {
      return const Empty();
    }
    return TimeZoneInput(controller: _timeZoneController);
  }

  Widget _buildPeriodsPicker() {
    return _buildNonEntityPicker<Period>(
      controller: _periodsController,
      nameForItem: (context, period) => period.displayName(context),
      emptyValue: Strings.of(context).periodPickerAll,
      pickerPageTitle: Strings.of(context).pickerTitleTimesOfDay,
      allItems: Periods.selectable(),
      allItem: Period.period_all,
      pickerItems: Periods.pickerItems,
      isHidden: hideCatchField(catchFieldIdPeriod),
    );
  }

  Widget _buildSeasonsPicker() {
    return _buildNonEntityPicker<Season>(
      controller: _seasonsController,
      nameForItem: (context, season) => season.displayName(context),
      emptyValue: Strings.of(context).seasonPickerAll,
      pickerPageTitle: Strings.of(context).pickerTitleSeasons,
      allItems: Seasons.selectable(),
      allItem: Season.season_all,
      pickerItems: Seasons.pickerItems,
      isHidden: hideCatchField(catchFieldIdSeason),
    );
  }

  Widget _buildAnglersPicker() {
    return EntityPickerInput<Angler>.multi(
      manager: _anglerManager,
      controller: _anglersController,
      emptyValue: Strings.of(context).saveReportPageAllAnglers,
      isEmptyAll: true,
      isHidden: hideCatchField(catchFieldIdAngler),
      listPage: (pickerSettings) => AnglerListPage(
        pickerSettings: pickerSettings,
      ),
    );
  }

  Widget _buildSpeciesPicker() {
    return EntityPickerInput<Species>.multi(
      manager: _speciesManager,
      controller: _speciesController,
      emptyValue: Strings.of(context).saveReportPageAllSpecies,
      isEmptyAll: true,
      isHidden: hideCatchField(catchFieldIdSpecies),
      listPage: (pickerSettings) => SpeciesListPage(
        pickerSettings: pickerSettings,
      ),
    );
  }

  Widget _buildBaitsPicker() {
    if (hideCatchField(catchFieldIdBait)) {
      return const Empty();
    }

    return BaitPickerInput(
      controller: _baitsController,
      emptyValue: (context) => Strings.of(context).saveReportPageAllBaits,
      isAllEmpty: true,
    );
  }

  Widget _buildGearPicker() {
    if (hideCatchField(catchFieldIdGear)) {
      return const Empty();
    }

    return EntityPickerInput<Gear>.multi(
      manager: _gearManager,
      controller: _gearController,
      emptyValue: Strings.of(context).saveReportPageAllGear,
      isEmptyAll: true,
      isHidden: hideCatchField(catchFieldIdGear),
      listPage: (pickerSettings) => GearListPage(
        pickerSettings: pickerSettings,
      ),
    );
  }

  Widget _buildBodiesOfWaterPicker() {
    return EntityPickerInput<BodyOfWater>.multi(
      manager: _bodyOfWaterManager,
      controller: _bodiesOfWaterController,
      emptyValue: Strings.of(context).saveReportPageAllBodiesOfWater,
      isEmptyAll: true,
      isHidden: hideCatchField(catchFieldIdFishingSpot),
      listPage: (pickerSettings) => BodyOfWaterListPage(
        pickerSettings: pickerSettings,
      ),
    );
  }

  Widget _buildFishingSpotsPicker() {
    return EntityPickerInput<FishingSpot>.multi(
      manager: _fishingSpotManager,
      controller: _fishingSpotsController,
      emptyValue: Strings.of(context).saveReportPageAllFishingSpots,
      isEmptyAll: true,
      isHidden: hideCatchField(catchFieldIdFishingSpot),
      displayNameOverride: (fishingSpot) => _fishingSpotManager
          .displayName(context, fishingSpot, includeBodyOfWater: true),
      customListPage: (onPicked, initialValues) => FishingSpotListPage(
        pickerSettings: FishingSpotListPagePickerSettings(
          onPicked: onPicked,
          initialValues: initialValues,
        ),
      ),
    );
  }

  Widget _buildMethodsPicker() {
    return EntityPickerInput<Method>.multi(
      manager: _methodManager,
      controller: _methodsController,
      emptyValue: Strings.of(context).saveReportPageAllMethods,
      isEmptyAll: true,
      isHidden: hideCatchField(catchFieldIdMethods),
      listPage: (pickerSettings) {
        return MethodListPage(
          pickerSettings: pickerSettings,
        );
      },
    );
  }

  Widget _buildAirTemperature() {
    if (hideAtmosphereField(atmosphereFieldIdTemperature)) {
      return const Empty();
    }

    return NumberFilterInput(
      title: Strings.of(context).atmosphereInputAirTemperature,
      filterTitle: Strings.of(context).filterTitleAirTemperature,
      controller: _airTemperatureController,
      inputSpec: MultiMeasurementInputSpec.airTemperature(context),
    );
  }

  Widget _buildAirPressure() {
    if (hideAtmosphereField(atmosphereFieldIdPressure)) {
      return const Empty();
    }

    return NumberFilterInput(
      title: Strings.of(context).atmosphereInputAtmosphericPressure,
      filterTitle: Strings.of(context).filterTitleAirPressure,
      controller: _airPressureController,
      inputSpec: MultiMeasurementInputSpec.airPressure(context),
    );
  }

  Widget _buildAirHumidity() {
    if (hideAtmosphereField(atmosphereFieldIdHumidity)) {
      return const Empty();
    }

    return NumberFilterInput(
      title: Strings.of(context).atmosphereInputAirHumidity,
      filterTitle: Strings.of(context).filterTitleAirHumidity,
      controller: _airHumidityController,
      inputSpec: MultiMeasurementInputSpec.airHumidity(context),
    );
  }

  Widget _buildAirVisibility() {
    if (hideAtmosphereField(atmosphereFieldIdVisibility)) {
      return const Empty();
    }

    return NumberFilterInput(
      title: Strings.of(context).atmosphereInputAirVisibility,
      filterTitle: Strings.of(context).filterTitleAirVisibility,
      controller: _airVisibilityController,
      inputSpec: MultiMeasurementInputSpec.airVisibility(context),
    );
  }

  Widget _buildWindSpeed() {
    if (hideAtmosphereField(atmosphereFieldIdWindSpeed)) {
      return const Empty();
    }

    return NumberFilterInput(
      title: Strings.of(context).atmosphereInputWindSpeed,
      filterTitle: Strings.of(context).filterTitleWindSpeed,
      controller: _windSpeedController,
      inputSpec: MultiMeasurementInputSpec.windSpeed(context),
    );
  }

  Widget _buildWindDirections() {
    return _buildNonEntityPicker<Direction>(
      controller: _windDirectionsController,
      nameForItem: (context, direction) => direction.chipName(context),
      emptyValue: Strings.of(context).saveReportPageAllWindDirections,
      pickerPageTitle: Strings.of(context).pickerTitleWindDirections,
      allItems: Directions.selectable(),
      allItem: Direction.direction_none,
      pickerItems: Directions.pickerItems,
      isHidden: hideAtmosphereField(atmosphereFieldIdWindDirection),
    );
  }

  Widget _buildSkyConditions() {
    return _buildNonEntityPicker<SkyCondition>(
      controller: _skyConditionsController,
      nameForItem: (context, condition) => condition.displayName(context),
      emptyValue: Strings.of(context).saveReportPageAllSkyConditions,
      pickerPageTitle: Strings.of(context).pickerTitleSkyConditions,
      allItems: SkyConditions.selectable(),
      allItem: SkyCondition.sky_condition_none,
      pickerItems: SkyConditions.pickerItems,
      isHidden: hideAtmosphereField(atmosphereFieldIdSkyCondition),
    );
  }

  Widget _buildMoonPhases() {
    return _buildNonEntityPicker<MoonPhase>(
      controller: _moonPhasesController,
      nameForItem: (context, moonPhase) => moonPhase.chipName(context),
      emptyValue: Strings.of(context).saveReportPageAllMoonPhases,
      pickerPageTitle: Strings.of(context).pickerTitleMoonPhases,
      allItems: MoonPhases.selectable(),
      allItem: MoonPhase.moon_phase_none,
      pickerItems: MoonPhases.pickerItems,
      isHidden: hideAtmosphereField(atmosphereFieldIdMoonPhase),
    );
  }

  Widget _buildTideTypes() {
    return _buildNonEntityPicker<TideType>(
      controller: _tideTypesController,
      nameForItem: (context, type) => type.chipName(context),
      emptyValue: Strings.of(context).saveReportPageAllTideTypes,
      pickerPageTitle: Strings.of(context).pickerTitleTides,
      allItems: TideTypes.selectable(),
      allItem: TideType.tide_type_none,
      pickerItems: TideTypes.pickerItems,
      isHidden: hideCatchField(catchFieldIdTide),
    );
  }

  Widget _buildWaterClaritiesPicker() {
    return EntityPickerInput<WaterClarity>.multi(
      manager: _waterClarityManager,
      controller: _waterClaritiesController,
      emptyValue: Strings.of(context).saveReportPageAllWaterClarities,
      isEmptyAll: true,
      isHidden: hideCatchField(catchFieldIdWaterClarity),
      listPage: (pickerSettings) {
        return WaterClarityListPage(
          pickerSettings: pickerSettings,
        );
      },
    );
  }

  Widget _buildNonEntityPicker<T>({
    required SetInputController<T> controller,
    required String Function(BuildContext, T) nameForItem,
    required String emptyValue,
    required String pickerPageTitle,
    required Set<T> allItems,
    required T allItem,
    required List<PickerPageItem<T>> Function(BuildContext) pickerItems,
    required bool isHidden,
  }) {
    if (isHidden) {
      return const Empty();
    }

    return MultiListPickerInput(
      padding: insetsDefault,
      values:
          controller.value.map((item) => nameForItem(context, item)).toSet(),
      emptyValue: (context) => emptyValue,
      onTap: () {
        push(
          context,
          PickerPage<T>(
            title: Text(pickerPageTitle),
            initialValues: controller.value.isEmpty
                ? ({allItem}..addAll(allItems))
                : controller.value,
            allItem: PickerPageItem<T>(
              title: Strings.of(context).all,
              value: allItem,
            ),
            itemBuilder: () => pickerItems(context),
            onFinishedPicking: (context, items) {
              // Treat an empty controller value as "include all", so we're
              // not including many objects in a protobuf collection.
              setState(() =>
                  controller.value = items.containsAll(allItems) ? {} : items);
            },
          ),
        );
      },
    );
  }

  FutureOr<bool> _save() {
    var report = Report()
      ..id = _oldReport?.id ?? randomId()
      ..name = _nameController.value!
      ..type = _typeController.value!
      ..timeZone = _timeZoneController.value
      ..periods.addAll(_periodsController.value)
      ..seasons.addAll(_seasonsController.value)
      ..anglerIds.addAll(_anglersController.value)
      ..baits.addAll(_baitsController.value)
      ..gearIds.addAll(_gearController.value)
      ..fishingSpotIds.addAll(_fishingSpotsController.value)
      ..bodyOfWaterIds.addAll(_bodiesOfWaterController.value)
      ..methodIds.addAll(_methodsController.value)
      ..speciesIds.addAll(_speciesController.value)
      ..waterClarityIds.addAll(_waterClaritiesController.value)
      ..windDirections.addAll(_windDirectionsController.value)
      ..skyConditions.addAll(_skyConditionsController.value)
      ..moonPhases.addAll(_moonPhasesController.value)
      ..tideTypes.addAll(_tideTypesController.value);

    if (isNotEmpty(_descriptionController.value)) {
      report.description = _descriptionController.value!;
    }

    if (_catchAndReleaseOnlyController.value) {
      report.isCatchAndReleaseOnly = true;
    }

    if (_favoritesOnlyController.value) {
      report.isFavoritesOnly = true;
    }

    if (_fromDateRangeController.hasValue) {
      report.fromDateRange = (_fromDateRangeController.value!.toBuilder()
          as DateRange)
        ..timeZone = report.timeZone;
    }

    if (_toDateRangeController.hasValue) {
      report.toDateRange = (_toDateRangeController.value!.toBuilder()
          as DateRange)
        ..timeZone = report.timeZone;
    }

    if (_waterDepthController.shouldAddToReport) {
      report.waterDepthFilter = _waterDepthController.value!;
    }

    if (_waterTemperatureController.shouldAddToReport) {
      report.waterTemperatureFilter = _waterTemperatureController.value!;
    }

    if (_lengthController.shouldAddToReport) {
      report.lengthFilter = _lengthController.value!;
    }

    if (_weightController.shouldAddToReport) {
      report.weightFilter = _weightController.value!;
    }

    if (_quantityController.shouldAddToReport) {
      report.quantityFilter = _quantityController.value!;
    }

    if (_airTemperatureController.shouldAddToReport) {
      report.airTemperatureFilter = _airTemperatureController.value!;
    }

    if (_airPressureController.shouldAddToReport) {
      report.airPressureFilter = _airPressureController.value!;
    }

    if (_airHumidityController.shouldAddToReport) {
      report.airHumidityFilter = _airHumidityController.value!;
    }

    if (_airVisibilityController.shouldAddToReport) {
      report.airVisibilityFilter = _airVisibilityController.value!;
    }

    if (_windSpeedController.shouldAddToReport) {
      report.windSpeedFilter = _windSpeedController.value!;
    }

    _reportManager.addOrUpdate(report);
    return true;
  }

  bool hideCatchField(Id id) {
    return _userPreferenceManager.catchFieldIds.isNotEmpty &&
        !_userPreferenceManager.catchFieldIds.contains(id);
  }

  bool hideAtmosphereField(Id id) {
    return hideCatchField(catchFieldIdAtmosphere) ||
        (_userPreferenceManager.atmosphereFieldIds.isNotEmpty &&
            !_userPreferenceManager.atmosphereFieldIds.contains(id));
  }
}
