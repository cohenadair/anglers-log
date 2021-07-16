import 'dart:async';

import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:quiver/strings.dart';

import '../angler_manager.dart';
import '../bait_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../method_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../named_entity_manager.dart';
import '../pages/bait_list_page.dart';
import '../pages/fishing_spot_list_page.dart';
import '../pages/form_page.dart';
import '../pages/species_list_page.dart';
import '../report_manager.dart';
import '../res/dimen.dart';
import '../species_manager.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/validator.dart';
import '../water_clarity_manager.dart';
import '../widgets/checkbox_input.dart';
import '../widgets/date_range_picker_input.dart';
import '../widgets/field.dart';
import '../widgets/input_controller.dart';
import '../widgets/multi_list_picker_input.dart';
import '../widgets/multi_measurement_input.dart';
import '../widgets/number_filter_input.dart';
import '../widgets/radio_input.dart';
import '../widgets/text_input.dart';
import '../widgets/widget.dart';
import 'angler_list_page.dart';
import 'manageable_list_page.dart';
import 'method_list_page.dart';
import 'picker_page.dart';
import 'water_clarity_list_page.dart';

class SaveReportPage extends StatefulWidget {
  final Report? oldReport;

  SaveReportPage() : oldReport = null;

  SaveReportPage.edit(this.oldReport) : assert(oldReport != null);

  @override
  _SaveReportPageState createState() => _SaveReportPageState();
}

class _SaveReportPageState extends State<SaveReportPage> {
  static final _idAirTemperature = randomId();
  static final _idAirHumidity = randomId();
  static final _idAirPressure = randomId();
  static final _idAirVisibility = randomId();
  static final _idAnglers = randomId();
  static final _idBaits = randomId();
  static final _idCatchAndReleaseOnly = randomId();
  static final _idDescription = randomId();
  static final _idEndDateRange = randomId();
  static final _idFavoritesOnly = randomId();
  static final _idFishingSpots = randomId();
  static final _idLength = randomId();
  static final _idMethods = randomId();
  static final _idMoonPhases = randomId();
  static final _idName = randomId();
  static final _idPeriods = randomId();
  static final _idQuantity = randomId();
  static final _idSeasons = randomId();
  static final _idSkyConditions = randomId();
  static final _idSpecies = randomId();
  static final _idStartDateRange = randomId();
  static final _idType = randomId();
  static final _idWaterClarities = randomId();
  static final _idWaterDepth = randomId();
  static final _idWaterTemperature = randomId();
  static final _idWeight = randomId();
  static final _idWindDirections = randomId();
  static final _idWindSpeed = randomId();
  static final _idKeywords = randomId();

  final Key _keySummaryStart = ValueKey(0);
  final Key _keyComparisonStart = ValueKey(1);

  final Map<Id, Field> _fields = {};

  AnglerManager get _anglerManager => AnglerManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  ReportManager get _reportManager => ReportManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  MethodManager get _methodManager => MethodManager.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  WaterClarityManager get _waterClarityManager =>
      WaterClarityManager.of(context);

  TextInputController get _nameController =>
      _fields[_idName]!.controller as TextInputController;

  TextInputController get _descriptionController =>
      _fields[_idDescription]!.controller as TextInputController;

  InputController<Report_Type> get _typeController =>
      _fields[_idType]!.controller as InputController<Report_Type>;

  InputController<DateRange> get _fromDateRangeController =>
      _fields[_idStartDateRange]!.controller as InputController<DateRange>;

  InputController<DateRange> get _toDateRangeController =>
      _fields[_idEndDateRange]!.controller as InputController<DateRange>;

  SetInputController<Angler> get _anglersController =>
      _fields[_idAnglers]!.controller as SetInputController<Angler>;

  SetInputController<Species> get _speciesController =>
      _fields[_idSpecies]!.controller as SetInputController<Species>;

  SetInputController<Bait> get _baitsController =>
      _fields[_idBaits]!.controller as SetInputController<Bait>;

  SetInputController<FishingSpot> get _fishingSpotsController =>
      _fields[_idFishingSpots]!.controller as SetInputController<FishingSpot>;

  SetInputController<Method> get _methodsController =>
      _fields[_idMethods]!.controller as SetInputController<Method>;

  SetInputController<Period> get _periodsController =>
      _fields[_idPeriods]!.controller as SetInputController<Period>;

  BoolInputController get _favoritesOnlyController =>
      _fields[_idFavoritesOnly]!.controller as BoolInputController;

  BoolInputController get _catchAndReleaseOnlyController =>
      _fields[_idCatchAndReleaseOnly]!.controller as BoolInputController;

  SetInputController<Season> get _seasonsController =>
      _fields[_idSeasons]!.controller as SetInputController<Season>;

  SetInputController<WaterClarity> get _waterClaritiesController =>
      _fields[_idWaterClarities]!.controller
          as SetInputController<WaterClarity>;

  NumberFilterInputController get _waterDepthController =>
      _fields[_idWaterDepth]!.controller as NumberFilterInputController;

  NumberFilterInputController get _waterTemperatureController =>
      _fields[_idWaterTemperature]!.controller as NumberFilterInputController;

  NumberFilterInputController get _lengthController =>
      _fields[_idLength]!.controller as NumberFilterInputController;

  NumberFilterInputController get _weightController =>
      _fields[_idWeight]!.controller as NumberFilterInputController;

  NumberFilterInputController get _quantityController =>
      _fields[_idQuantity]!.controller as NumberFilterInputController;

  NumberFilterInputController get _airTemperatureController =>
      _fields[_idAirTemperature]!.controller as NumberFilterInputController;

  NumberFilterInputController get _airPressureController =>
      _fields[_idAirPressure]!.controller as NumberFilterInputController;

  NumberFilterInputController get _airHumidityController =>
      _fields[_idAirHumidity]!.controller as NumberFilterInputController;

  NumberFilterInputController get _airVisibilityController =>
      _fields[_idAirVisibility]!.controller as NumberFilterInputController;

  NumberFilterInputController get _windSpeedController =>
      _fields[_idWindSpeed]!.controller as NumberFilterInputController;

  SetInputController<Direction> get _windDirectionsController =>
      _fields[_idWindDirections]!.controller as SetInputController<Direction>;

  SetInputController<SkyCondition> get _skyConditionsController =>
      _fields[_idSkyConditions]!.controller as SetInputController<SkyCondition>;

  SetInputController<MoonPhase> get _moonPhasesController =>
      _fields[_idMoonPhases]!.controller as SetInputController<MoonPhase>;

  Report? get _oldReport => widget.oldReport;

  bool get _isEditing => _oldReport != null;

  bool get _isComparison => _typeController.value == Report_Type.comparison;

  bool get _isSummary => _typeController.value == Report_Type.summary;

  @override
  void initState() {
    super.initState();

    _fields[_idName] = Field(
      id: _idName,
      controller: TextInputController(
        validator: NameValidator(
          nameExistsMessage: (context) =>
              Strings.of(context).saveReportPageNameExists,
          nameExists: (newName) => _reportManager.nameExists(newName),
          oldName: _oldReport?.name,
        ),
      ),
    );

    _fields[_idDescription] = Field(
      id: _idDescription,
      controller: TextInputController(),
    );

    _fields[_idType] = Field(
      id: _idType,
      controller: InputController<Report_Type>(),
    );

    _fields[_idStartDateRange] = Field(
      id: _idStartDateRange,
      controller: InputController<DateRange>(),
    );

    _fields[_idEndDateRange] = Field(
      id: _idStartDateRange,
      controller: InputController<DateRange>(),
    );

    _fields[_idCatchAndReleaseOnly] = Field(
      id: _idCatchAndReleaseOnly,
      controller: BoolInputController(),
    );

    _fields[_idFavoritesOnly] = Field(
      id: _idFavoritesOnly,
      controller: BoolInputController(),
    );

    _fields[_idWaterDepth] = Field(
      id: _idWaterDepth,
      controller: NumberFilterInputController(),
    );

    _fields[_idWaterTemperature] = Field(
      id: _idWaterTemperature,
      controller: NumberFilterInputController(),
    );

    _fields[_idLength] = Field(
      id: _idLength,
      controller: NumberFilterInputController(),
    );

    _fields[_idWeight] = Field(
      id: _idWeight,
      controller: NumberFilterInputController(),
    );

    _fields[_idQuantity] = Field(
      id: _idQuantity,
      controller: NumberFilterInputController(),
    );

    _fields[_idAirTemperature] = Field(
      id: _idAirTemperature,
      controller: NumberFilterInputController(),
    );

    _fields[_idAirPressure] = Field(
      id: _idAirPressure,
      controller: NumberFilterInputController(),
    );

    _fields[_idAirHumidity] = Field(
      id: _idAirHumidity,
      controller: NumberFilterInputController(),
    );

    _fields[_idAirVisibility] = Field(
      id: _idAirVisibility,
      controller: NumberFilterInputController(),
    );

    _fields[_idWindSpeed] = Field(
      id: _idWindSpeed,
      controller: NumberFilterInputController(),
    );

    _fields[_idWindDirections] = Field(
      id: _idWindDirections,
      controller: SetInputController<Direction>(),
    );

    _fields[_idSkyConditions] = Field(
      id: _idSkyConditions,
      controller: SetInputController<SkyCondition>(),
    );

    _fields[_idMoonPhases] = Field(
      id: _idMoonPhases,
      controller: SetInputController<MoonPhase>(),
    );

    _fields[_idPeriods] = Field(
      id: _idPeriods,
      controller: SetInputController<Period>(),
    );

    _fields[_idSeasons] = Field(
      id: _idSeasons,
      controller: SetInputController<Season>(),
    );

    _fields[_idAnglers] = Field(
      id: _idAnglers,
      controller: SetInputController<Angler>(),
    );

    _fields[_idSpecies] = Field(
      id: _idSpecies,
      controller: SetInputController<Species>(),
    );

    _fields[_idBaits] = Field(
      id: _idBaits,
      controller: SetInputController<Bait>(),
    );

    _fields[_idFishingSpots] = Field(
      id: _idFishingSpots,
      controller: SetInputController<FishingSpot>(),
    );

    _fields[_idMethods] = Field(
      id: _idMethods,
      controller: SetInputController<Method>(),
    );

    _fields[_idWaterClarities] = Field(
      id: _idWaterClarities,
      controller: SetInputController<WaterClarity>(),
    );

    _fields[_idKeywords] = Field(
      id: _idKeywords,
      controller: TextInputController(),
    );

    if (_isEditing) {
      _nameController.value = _oldReport!.name;
      _descriptionController.value = _oldReport!.description;
      _typeController.value = _oldReport!.type;
      _fromDateRangeController.value = _oldReport!.fromDateRange;
      if (_isComparison) {
        _toDateRangeController.value = _oldReport!.toDateRange;
      }
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
      _initEntitySets(
        anglerIds: _oldReport!.anglerIds,
        baitIds: _oldReport!.baitIds,
        fishingSpotIds: _oldReport!.fishingSpotIds,
        methodIds: _oldReport!.methodIds,
        speciesIds: _oldReport!.speciesIds,
        waterClarityIds: _oldReport!.waterClarityIds,
      );
    } else {
      _typeController.value = Report_Type.summary;
      _fromDateRangeController.value =
          DateRange(period: DateRange_Period.allDates);
      if (_isComparison) {
        _toDateRangeController.value =
            DateRange(period: DateRange_Period.allDates);
      }
      _initEntitySets();
    }
  }

  void _initEntitySets({
    List<Id> anglerIds = const [],
    List<Id> baitIds = const [],
    List<Id> fishingSpotIds = const [],
    List<Id> methodIds = const [],
    List<Id> speciesIds = const [],
    List<Id> waterClarityIds = const [],
  }) {
    // "Empty" lists will include all entities in reports, so don't actually
    // include every entity in the report object.
    _anglersController.value =
        anglerIds.isEmpty ? {} : _anglerManager.list(anglerIds).toSet();
    _baitsController.value =
        baitIds.isEmpty ? {} : _baitManager.list(baitIds).toSet();
    _fishingSpotsController.value = fishingSpotIds.isEmpty
        ? {}
        : _fishingSpotManager.list(fishingSpotIds).toSet();
    _methodsController.value =
        methodIds.isEmpty ? {} : _methodManager.list(methodIds).toSet();
    _speciesController.value =
        speciesIds.isEmpty ? {} : _speciesManager.list(speciesIds).toSet();
    _waterClaritiesController.value = waterClarityIds.isEmpty
        ? {}
        : _waterClarityManager.list(waterClarityIds).toSet();
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
      fieldBuilder: (context) => {
        _idName: _buildName(),
        _idDescription: _buildDescription(),
        _idType: _buildType(),
        _idStartDateRange: _buildStartDateRange(),
        _idEndDateRange: _buildEndDateRange(),
        _idCatchAndReleaseOnly: _buildCatchAndReleaseOnly(),
        _idFavoritesOnly: _buildFavoritesOnly(),
        _idWaterDepth: _buildWaterDepth(),
        _idWaterTemperature: _buildWaterTemperature(),
        _idLength: _buildLength(),
        _idWeight: _buildWeight(),
        _idQuantity: _buildQuantity(),
        _idAirTemperature: _buildAirTemperature(),
        _idAirHumidity: _buildAirHumidity(),
        _idAirVisibility: _buildAirVisibility(),
        _idAirPressure: _buildAirPressure(),
        _idWindSpeed: _buildWindSpeed(),
        _idWindDirections: _buildWindDirections(),
        _idSkyConditions: _buildSkyConditions(),
        _idMoonPhases: _buildMoonPhases(),
        _idWaterClarities: _buildWaterClaritiesPicker(),
        _idPeriods: _buildPeriodsPicker(),
        _idSeasons: _buildSeasonsPicker(),
        _idAnglers: _buildAnglersPicker(),
        _idSpecies: _buildSpeciesPicker(),
        _idBaits: _buildBaitsPicker(),
        _idFishingSpots: _buildFishingSpotsPicker(),
        _idMethods: _buildMethodsPicker(),
      },
      onSave: _save,
    );
  }

  Widget _buildName() {
    return Padding(
      padding: EdgeInsets.only(
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
      padding: EdgeInsets.only(
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
      duration: defaultAnimationDuration,
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
    return CheckboxInput(
      label: Strings.of(context).saveReportPageCatchAndRelease,
      value: _catchAndReleaseOnlyController.value,
      onChanged: (checked) => _catchAndReleaseOnlyController.value = checked,
    );
  }

  Widget _buildFavoritesOnly() {
    return CheckboxInput(
      label: Strings.of(context).saveReportPageFavorites,
      value: _favoritesOnlyController.value,
      onChanged: (checked) => _favoritesOnlyController.value = checked,
    );
  }

  Widget _buildWaterDepth() {
    return NumberFilterInput(
      title: Strings.of(context).catchFieldWaterDepthLabel,
      filterTitle: Strings.of(context).filterTitleWaterDepth,
      controller: _waterDepthController,
      inputSpec: MultiMeasurementInputSpec.waterDepth(context),
    );
  }

  Widget _buildWaterTemperature() {
    return NumberFilterInput(
      title: Strings.of(context).catchFieldWaterTemperatureLabel,
      filterTitle: Strings.of(context).filterTitleWaterTemperature,
      controller: _waterTemperatureController,
      inputSpec: MultiMeasurementInputSpec.waterTemperature(context),
    );
  }

  Widget _buildLength() {
    return NumberFilterInput(
      title: Strings.of(context).catchFieldLengthLabel,
      filterTitle: Strings.of(context).filterTitleLength,
      controller: _lengthController,
      inputSpec: MultiMeasurementInputSpec.length(context),
    );
  }

  Widget _buildWeight() {
    return NumberFilterInput(
      title: Strings.of(context).catchFieldWeightLabel,
      filterTitle: Strings.of(context).filterTitleWeight,
      controller: _weightController,
      inputSpec: MultiMeasurementInputSpec.weight(context),
    );
  }

  Widget _buildQuantity() {
    return NumberFilterInput(
      title: Strings.of(context).catchFieldQuantityLabel,
      filterTitle: Strings.of(context).filterTitleQuantity,
      controller: _quantityController,
    );
  }

  Widget _buildEndDateRange() {
    return AnimatedSwitcher(
      duration: defaultAnimationDuration,
      child: _isSummary
          ? Empty()
          : DateRangePickerInput(
              title: Strings.of(context).saveReportPageEndDateRangeLabel,
              initialDateRange: _toDateRangeController.value,
              onPicked: (dateRange) => setState(() {
                _toDateRangeController.value = dateRange;
              }),
            ),
    );
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
    );
  }

  Widget _buildAnglersPicker() {
    return _buildEntityPicker<Angler>(
      manager: _anglerManager,
      controller: _anglersController,
      emptyValue: Strings.of(context).saveReportPageAllAnglers,
      listPage: (pickerSettings) => AnglerListPage(
        pickerSettings: pickerSettings,
      ),
    );
  }

  Widget _buildSpeciesPicker() {
    return _buildEntityPicker<Species>(
      manager: _speciesManager,
      controller: _speciesController,
      emptyValue: Strings.of(context).saveReportPageAllSpecies,
      listPage: (pickerSettings) => SpeciesListPage(
        pickerSettings: pickerSettings,
      ),
    );
  }

  Widget _buildBaitsPicker() {
    var allBaits = _baitManager.list().toSet();
    return _buildEntityPicker<Bait>(
      manager: _baitManager,
      controller: _baitsController,
      emptyValue: Strings.of(context).saveReportPageAllBaits,
      dynamicListPage: BaitListPage(
        pickerSettings: ManageableListPagePickerSettings<dynamic>(
          onPicked: (context, items) {
            var baits = items as Set<Bait>;
            setState(() => _baitsController.value =
                baits.containsAll(allBaits) ? {} : baits);
            return true;
          },
          initialValues: _baitsController.value.isEmpty
              ? allBaits
              : _baitsController.value,
        ),
      ),
    );
  }

  Widget _buildFishingSpotsPicker() {
    return _buildEntityPicker<FishingSpot>(
      manager: _fishingSpotManager,
      controller: _fishingSpotsController,
      emptyValue: Strings.of(context).saveReportPageAllFishingSpots,
      listPage: (pickerSettings) => FishingSpotListPage(
        pickerSettings: pickerSettings,
      ),
    );
  }

  Widget _buildMethodsPicker() {
    return _buildEntityPicker<Method>(
      manager: _methodManager,
      controller: _methodsController,
      emptyValue: Strings.of(context).saveReportPageAllMethods,
      listPage: (pickerSettings) {
        return MethodListPage(
          pickerSettings: pickerSettings,
        );
      },
    );
  }

  Widget _buildAirTemperature() {
    return NumberFilterInput(
      title: Strings.of(context).atmosphereInputAirTemperature,
      filterTitle: Strings.of(context).filterTitleAirTemperature,
      controller: _airTemperatureController,
      inputSpec: MultiMeasurementInputSpec.airTemperature(context),
    );
  }

  Widget _buildAirPressure() {
    return NumberFilterInput(
      title: Strings.of(context).atmosphereInputAtmosphericPressure,
      filterTitle: Strings.of(context).filterTitleAirPressure,
      controller: _airPressureController,
      inputSpec: MultiMeasurementInputSpec.airPressure(context),
    );
  }

  Widget _buildAirHumidity() {
    return NumberFilterInput(
      title: Strings.of(context).atmosphereInputAirHumidity,
      filterTitle: Strings.of(context).filterTitleAirHumidity,
      controller: _airHumidityController,
      inputSpec: MultiMeasurementInputSpec.airHumidity(context),
    );
  }

  Widget _buildAirVisibility() {
    return NumberFilterInput(
      title: Strings.of(context).atmosphereInputAirVisibility,
      filterTitle: Strings.of(context).filterTitleAirVisibility,
      controller: _airVisibilityController,
      inputSpec: MultiMeasurementInputSpec.airVisibility(context),
    );
  }

  Widget _buildWindSpeed() {
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
    );
  }

  Widget _buildMoonPhases() {
    return _buildNonEntityPicker<MoonPhase>(
      controller: _moonPhasesController,
      nameForItem: (context, condition) => condition.chipName(context),
      emptyValue: Strings.of(context).saveReportPageAllMoonPhases,
      pickerPageTitle: Strings.of(context).pickerTitleMoonPhases,
      allItems: MoonPhases.selectable(),
      allItem: MoonPhase.moon_phase_none,
      pickerItems: MoonPhases.pickerItems,
    );
  }

  Widget _buildWaterClaritiesPicker() {
    return _buildEntityPicker<WaterClarity>(
      manager: _waterClarityManager,
      controller: _waterClaritiesController,
      emptyValue: Strings.of(context).saveReportPageAllWaterClarities,
      listPage: (pickerSettings) {
        return WaterClarityListPage(
          pickerSettings: pickerSettings,
        );
      },
    );
  }

  Widget _buildEntityPicker<T extends GeneratedMessage>({
    required NamedEntityManager<T> manager,
    required SetInputController<T> controller,
    required String emptyValue,
    Widget Function(ManageableListPagePickerSettings<T>)? listPage,
    // Used for when a picker page can have multiple entities displayed, such
    // as a BaitListPage, which shows bait categories as well as baits. In
    // these cases a definitive type T does not work.
    Widget? dynamicListPage,
  }) {
    assert(listPage != null || dynamicListPage != null);

    return MultiListPickerInput(
      padding: insetsHorizontalDefaultVerticalWidget,
      values: controller.value.map((e) => manager.name(e)).toSet(),
      emptyValue: (context) => emptyValue,
      onTap: () {
        var pickerPage = dynamicListPage;
        if (pickerPage == null) {
          var allEntities = manager.list().toSet();
          pickerPage = listPage!(
            ManageableListPagePickerSettings<T>(
              onPicked: (context, entities) {
                // Treat an empty controller value as "include all", so we're
                // not including 100s of objects in a protobuf collection.
                setState(() => controller.value =
                    entities.containsAll(allEntities) ? {} : entities);
                return true;
              },
              initialValues:
                  controller.value.isEmpty ? allEntities : controller.value,
            ),
          );
        }

        push(
          context,
          pickerPage,
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
  }) {
    return MultiListPickerInput(
      padding: insetsHorizontalDefaultVerticalWidget,
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

  FutureOr<bool> _save(BuildContext context) {
    var report = Report()
      ..id = _oldReport?.id ?? randomId()
      ..name = _nameController.value!
      ..type = _typeController.value!
      ..periods.addAll(_periodsController.value)
      ..seasons.addAll(_seasonsController.value)
      ..anglerIds.addAll(_anglersController.value.map((e) => e.id))
      ..baitIds.addAll(_baitsController.value.map((e) => e.id))
      ..fishingSpotIds.addAll(_fishingSpotsController.value.map((e) => e.id))
      ..methodIds.addAll(_methodsController.value.map((e) => e.id))
      ..speciesIds.addAll(_speciesController.value.map((e) => e.id))
      ..waterClarityIds.addAll(_waterClaritiesController.value.map((e) => e.id))
      ..windDirections.addAll(_windDirectionsController.value)
      ..skyConditions.addAll(_skyConditionsController.value)
      ..moonPhases.addAll(_moonPhasesController.value);

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
      report.fromDateRange = _fromDateRangeController.value!;
    }

    if (_toDateRangeController.hasValue) {
      report.toDateRange = _toDateRangeController.value!;
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
}
