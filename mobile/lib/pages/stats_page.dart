import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:mobile/angler_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/gear_manager.dart';
import 'package:mobile/method_manager.dart';
import 'package:mobile/pages/fishing_spot_list_page.dart';
import 'package:mobile/pages/gear_list_page.dart';
import 'package:mobile/pages/method_list_page.dart';
import 'package:mobile/pages/water_clarity_list_page.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/report_utils.dart';
import 'package:mobile/water_clarity_manager.dart';
import 'package:mobile/widgets/catch_summary.dart';
import 'package:mobile/widgets/empty_list_placeholder.dart';
import 'package:mobile/widgets/personal_bests_report.dart';
import 'package:mobile/widgets/trip_summary.dart';
import 'package:quiver/strings.dart';

import '../entity_manager.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/report_list_page.dart';
import '../report_manager.dart';
import '../res/dimen.dart';
import '../species_manager.dart';
import '../user_preference_manager.dart';
import '../utils/page_utils.dart';
import '../widgets/app_bar_dropdown.dart';
import '../widgets/widget.dart';
import 'angler_list_page.dart';
import 'bait_list_page.dart';
import 'body_of_water_list_page.dart';
import 'manageable_list_page.dart';
import 'picker_page.dart';
import 'species_list_page.dart';

class StatsPage extends StatefulWidget {
  @override
  StatsPageState createState() => StatsPageState();
}

class StatsPageState extends State<StatsPage> {
  static const _log = Log("StatsPage");

  final _scrollController = ScrollController();

  /// The currently selected report from the app bar dropdown menu.
  late Report _report;

  ReportManager get _reportManager => ReportManager.of(context);

  AnglerManager get _anglerManager => AnglerManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  CatchManager get _catchManager => CatchManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  GearManager get _gearManager => GearManager.of(context);

  MethodManager get _methodManager => MethodManager.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  UserPreferenceManager get _userPreferencesManager =>
      UserPreferenceManager.of(context);

  WaterClarityManager get _waterClarityManager =>
      WaterClarityManager.of(context);

  @override
  void initState() {
    super.initState();

    // Set a default.
    _report = _reportManager.defaultReport;

    // Load previously selected report.
    _updateCurrentReport(
        _userPreferencesManager.selectedReportId ?? _report.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EntityListenerBuilder(
        managers: [
          _reportManager,
          _catchManager,
        ],
        streams: [
          _userPreferencesManager.stream,
        ],
        onAnyChange: () => _updateCurrentReport(_report.id),
        builder: (context) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                title: _buildReportDropdown(),
                forceElevated: true,
                pinned: true,
              ),
              HorizontalSliverSafeArea(sliver: _buildHeader()),
              HorizontalSliverSafeArea(sliver: _buildContent()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReportDropdown() {
    return AppBarDropdown(
      title: _reportManager.displayName(context, _report),
      padding: insetsVerticalDefault,
      onTap: () {
        present(
          context,
          ReportListPage(
            pickerSettings: ManageableListPagePickerSettings<dynamic>.single(
              onPicked: (context, report) {
                if (report != _report) {
                  setState(() {
                    // Reset scrolling to the top of the page.
                    _scrollController.jumpTo(0.0);
                    _updateCurrentReport(report.id);
                  });
                }
                return true;
              },
              initialValue: _report,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    Widget child = const Empty();
    if (isNotEmpty(_report.description)) {
      child = Padding(
        padding: insetsDefault,
        child: Text(
          _report.description,
          overflow: TextOverflow.visible,
          style: stylePrimary(context),
        ),
      );
    }
    return SliverToBoxAdapter(child: child);
  }

  Widget _buildContent() {
    Widget child;
    if (_catchManager.hasEntities) {
      child = _buildReport();
    } else {
      child = Center(
        child: EmptyListPlaceholder.static(
          icon: CustomIcons.catches,
          title: Strings.of(context).reportViewEmptyLog,
          description: Strings.of(context).reportViewEmptyLogDescription,
          descriptionIcon: iconBottomBarAdd,
        ),
      );
    }

    return SliverFillRemaining(
      fillOverscroll: true,
      hasScrollBody: false,
      child: child,
    );
  }

  Widget _buildReport() {
    if (_report.hasType()) {
      switch (_report.type) {
        case Report_Type.summary:
          return _buildCustomSummary();
        case Report_Type.comparison:
          return _buildCustomComparison();
      }
    }

    if (_report.id == reportIdCatchSummary) {
      return _buildCatchSummary();
    } else if (_report.id == reportIdSpeciesSummary) {
      return _buildSpeciesSummary();
    } else if (_report.id == reportIdAnglerSummary) {
      return _buildAnglerSummary();
    } else if (_report.id == reportIdBaitSummary) {
      return _buildBaitSummary();
    } else if (_report.id == reportIdBodyOfWaterSummary) {
      return _buildBodyOfWaterSummary();
    } else if (_report.id == reportIdFishingSpotSummary) {
      return _buildFishingSpotSummary();
    } else if (_report.id == reportIdMethodSummary) {
      return _buildMethodSummary();
    } else if (_report.id == reportIdMoonPhaseSummary) {
      return _buildMoonPhaseSummary();
    } else if (_report.id == reportIdPeriodSummary) {
      return _buildPeriodSummary();
    } else if (_report.id == reportIdSeasonSummary) {
      return _buildSeasonSummary();
    } else if (_report.id == reportIdTideTypeSummary) {
      return _buildTideSummary();
    } else if (_report.id == reportIdWaterClaritySummary) {
      return _buildWaterClaritySummary();
    } else if (_report.id == reportIdPersonalBests) {
      return PersonalBestsReport();
    } else if (_report.id == reportIdTripSummary) {
      return TripSummary();
    } else if (_report.id == reportIdGearSummary) {
      return _buildGearSummary();
    } else {
      // Included for safety, but can't actually happen.
      _log.e(StackTrace.current, "Unknown report ID: ${_report.id}");
      return const Empty();
    }
  }

  Widget _buildCustomSummary() {
    return _buildEntityCatchSummary<Catch>(
      filterOptionsBuilder: (_) =>
          _createCustomReportFilterOptions(_report, [_report.fromDateRange]),
      isStatic: true,
    );
  }

  Widget _buildCustomComparison() {
    return _buildEntityCatchSummary<Catch>(
      filterOptionsBuilder: (_) => _createCustomReportFilterOptions(
        _report,
        [_report.fromDateRange, _report.toDateRange],
      ),
      isStatic: true,
    );
  }

  Widget _buildCatchSummary() {
    // Note: isEmpty parameter isn't needed here since this widget will never
    // get built if there are no catches in the log.
    return _buildEntityCatchSummary<Catch>(
      filterOptionsBuilder: (_) => CatchFilterOptions(),
    );
  }

  Widget _buildSpeciesSummary() {
    // Note: isEmpty parameter isn't needed here since this widget will never
    // get built if there are no catches in the log. If there are catches in
    // the log, there will be at least one species.
    return _buildEntityCatchSummary<Species>(
      filterOptionsBuilder: (species) => CatchFilterOptions(
        speciesIds: singleSet<Id>(species?.id),
      ),
      picker: CatchSummaryPicker<Species>(
        initialValue: _speciesManager.list().firstOrNull,
        pickerBuilder: (settings) => SpeciesListPage(pickerSettings: settings),
        nameBuilder: (context, species) =>
            _speciesManager.displayName(context, species),
      ),
    );
  }

  Widget _buildAnglerSummary() {
    return _buildEntityCatchSummary<Angler>(
      isEmpty: !_anglerManager.hasEntities,
      filterOptionsBuilder: (angler) => CatchFilterOptions(
        anglerIds: singleSet<Id>(angler?.id),
      ),
      picker: CatchSummaryPicker<Angler>(
        initialValue: _anglerManager.list().firstOrNull,
        pickerBuilder: (settings) => AnglerListPage(pickerSettings: settings),
        nameBuilder: (context, species) =>
            _anglerManager.displayName(context, species),
      ),
      emptyWidget: EmptyListPlaceholder.static(
        icon: iconAngler,
        title: Strings.of(context).anglerListPageEmptyListTitle,
        description: Strings.of(context).anglersSummaryEmpty,
      ),
    );
  }

  Widget _buildBaitSummary() {
    return _buildEntityCatchSummary<BaitAttachment>(
      isEmpty: !_baitManager.hasEntities,
      filterOptionsBuilder: (attachment) => CatchFilterOptions(
        baits: singleSet<BaitAttachment>(attachment),
      ),
      picker: CatchSummaryPicker<BaitAttachment>(
        initialValue: _baitManager.list().firstOrNull?.toAttachment(),
        pickerBuilder: (settings) => BaitListPage(
          pickerSettings:
              BaitListPagePickerSettings.fromManageableList(settings),
        ),
        nameBuilder: (context, attachment) =>
            _baitManager.attachmentDisplayValue(
          context,
          attachment,
          showAllVariantsLabel: true,
        ),
      ),
      emptyWidget: EmptyListPlaceholder.static(
        icon: iconBait,
        title: Strings.of(context).baitListPageEmptyListTitle,
        description: Strings.of(context).baitsSummaryEmpty,
      ),
    );
  }

  Widget _buildGearSummary() {
    return _buildEntityCatchSummary<Gear>(
      isEmpty: !_gearManager.hasEntities,
      filterOptionsBuilder: (gear) => CatchFilterOptions(
        gearIds: singleSet<Id>(gear?.id),
      ),
      picker: CatchSummaryPicker<Gear>(
        initialValue: _gearManager.list().firstOrNull,
        pickerBuilder: (settings) => GearListPage(pickerSettings: settings),
        nameBuilder: (context, gear) => _gearManager.displayName(context, gear),
      ),
      emptyWidget: EmptyListPlaceholder.static(
        icon: iconGear,
        title: Strings.of(context).gearListPageEmptyListTitle,
        description: Strings.of(context).gearSummaryEmpty,
      ),
    );
  }

  Widget _buildBodyOfWaterSummary() {
    return _buildEntityCatchSummary<BodyOfWater>(
      isEmpty: !_bodyOfWaterManager.hasEntities,
      filterOptionsBuilder: (bodyOfWater) => CatchFilterOptions(
        bodyOfWaterIds: singleSet<Id>(bodyOfWater?.id),
      ),
      picker: CatchSummaryPicker<BodyOfWater>(
        initialValue: _bodyOfWaterManager.list().firstOrNull,
        pickerBuilder: (settings) =>
            BodyOfWaterListPage(pickerSettings: settings),
        nameBuilder: (context, bodyOfWater) =>
            _bodyOfWaterManager.displayName(context, bodyOfWater),
      ),
      emptyWidget: EmptyListPlaceholder.static(
        icon: iconBodyOfWater,
        title: Strings.of(context).bodyOfWaterListPageEmptyListTitle,
        description: Strings.of(context).bodiesOfWaterSummaryEmpty,
      ),
    );
  }

  Widget _buildFishingSpotSummary() {
    return _buildEntityCatchSummary<FishingSpot>(
      isEmpty: !_fishingSpotManager.hasEntities,
      filterOptionsBuilder: (fishingSpot) => CatchFilterOptions(
        fishingSpotIds: singleSet<Id>(fishingSpot?.id),
      ),
      picker: CatchSummaryPicker<FishingSpot>(
        initialValue: _fishingSpotManager.list().firstOrNull,
        pickerBuilder: (settings) => FishingSpotListPage(
            pickerSettings:
                FishingSpotListPagePickerSettings.fromManageableList(settings)),
        nameBuilder: (context, fishingSpot) =>
            _fishingSpotManager.displayName(context, fishingSpot),
      ),
      emptyWidget: EmptyListPlaceholder.static(
        icon: iconFishingSpot,
        title: Strings.of(context).fishingSpotListPageEmptyListTitle,
        description: Strings.of(context).fishingSpotsSummaryEmpty,
      ),
    );
  }

  Widget _buildMethodSummary() {
    return _buildEntityCatchSummary<Method>(
      isEmpty: !_methodManager.hasEntities,
      filterOptionsBuilder: (method) => CatchFilterOptions(
        methodIds: singleSet<Id>(method?.id),
      ),
      picker: CatchSummaryPicker<Method>(
        initialValue: _methodManager.list().firstOrNull,
        pickerBuilder: (settings) => MethodListPage(pickerSettings: settings),
        nameBuilder: (context, method) =>
            _methodManager.displayName(context, method),
      ),
      emptyWidget: EmptyListPlaceholder.static(
        icon: iconMethod,
        title: Strings.of(context).methodListPageEmptyListTitle,
        description: Strings.of(context).methodSummaryEmpty,
      ),
    );
  }

  Widget _buildMoonPhaseSummary() {
    return _buildEntityCatchSummary<MoonPhase>(
      filterOptionsBuilder: (moonPhase) => CatchFilterOptions(
        moonPhases: singleSet<MoonPhase>(moonPhase),
      ),
      picker: CatchSummaryPicker<MoonPhase>(
        initialValue: MoonPhases.selectable().first,
        pickerBuilder: (settings) => _buildEnumPickerPage(
          settings,
          Strings.of(context).pickerTitleMoonPhase,
          MoonPhases.pickerItems(context),
        ),
        nameBuilder: (context, moonPhase) => moonPhase.displayName(context),
      ),
    );
  }

  Widget _buildPeriodSummary() {
    return _buildEntityCatchSummary<Period>(
      filterOptionsBuilder: (period) => CatchFilterOptions(
        periods: singleSet<Period>(period),
      ),
      picker: CatchSummaryPicker<Period>(
        initialValue: Periods.selectable().first,
        pickerBuilder: (settings) => _buildEnumPickerPage(
          settings,
          Strings.of(context).pickerTitleTimeOfDay,
          Periods.pickerItems(context),
        ),
        nameBuilder: (context, period) => period.displayName(context),
      ),
    );
  }

  Widget _buildSeasonSummary() {
    return _buildEntityCatchSummary<Season>(
      filterOptionsBuilder: (season) => CatchFilterOptions(
        seasons: singleSet<Season>(season),
      ),
      picker: CatchSummaryPicker<Season>(
        initialValue: Seasons.selectable().first,
        pickerBuilder: (settings) => _buildEnumPickerPage(
          settings,
          Strings.of(context).pickerTitleSeason,
          Seasons.pickerItems(context),
        ),
        nameBuilder: (context, season) => season.displayName(context),
      ),
    );
  }

  Widget _buildTideSummary() {
    return _buildEntityCatchSummary<TideType>(
      filterOptionsBuilder: (tide) => CatchFilterOptions(
        tideTypes: singleSet<TideType>(tide),
      ),
      picker: CatchSummaryPicker<TideType>(
        initialValue: TideTypes.selectable().first,
        pickerBuilder: (settings) => _buildEnumPickerPage(
          settings,
          Strings.of(context).pickerTitleTide,
          TideTypes.pickerItems(context),
        ),
        nameBuilder: (context, tide) => tide.displayName(context),
      ),
    );
  }

  Widget _buildWaterClaritySummary() {
    return _buildEntityCatchSummary<WaterClarity>(
      isEmpty: !_waterClarityManager.hasEntities,
      filterOptionsBuilder: (clarity) => CatchFilterOptions(
        waterClarityIds: singleSet<Id>(clarity?.id),
      ),
      picker: CatchSummaryPicker<WaterClarity>(
        initialValue: _waterClarityManager.list().firstOrNull,
        pickerBuilder: (settings) =>
            WaterClarityListPage(pickerSettings: settings),
        nameBuilder: (context, clarity) =>
            _waterClarityManager.displayName(context, clarity),
      ),
      emptyWidget: EmptyListPlaceholder.static(
        icon: iconWaterClarity,
        title: Strings.of(context).waterClarityListPageEmptyListTitle,
        description: Strings.of(context).waterClaritiesSummaryEmpty,
      ),
    );
  }

  Widget _buildEntityCatchSummary<T>({
    required CatchFilterOptions Function(T?) filterOptionsBuilder,
    EmptyListPlaceholder? emptyWidget,
    bool isEmpty = false,
    bool isStatic = false,
    CatchSummaryPicker<T>? picker,
  }) {
    assert(!isEmpty || emptyWidget != null);

    if (isEmpty) {
      return Center(child: emptyWidget);
    }

    return CatchSummary<T>(
      // Key is required here because every report is an instance of
      // CatchSummary, which will need to be rebuilt when a new report is
      // selected. Having a unique key value here tells the build process that
      // the widget has changed.
      key: ValueKey(_report.id),
      filterOptionsBuilder: filterOptionsBuilder,
      picker: picker,
      isStatic: isStatic,
    );
  }

  Widget _buildEnumPickerPage<T>(ManageableListPagePickerSettings<T> settings,
      String title, List<PickerPageItem<T>> pickerItems) {
    return PickerPage<T>.single(
      title: Text(title),
      initialValue: settings.initialValues.first,
      itemBuilder: () => pickerItems,
      onFinishedPicking: (context, pickedItem) {
        settings.onPicked(context, {pickedItem});
        Navigator.of(context).pop();
      },
    );
  }

  void _updateCurrentReport(Id? newReportId) {
    _report =
        _reportManager.entity(newReportId) ?? _reportManager.defaultReport;
    _userPreferencesManager.setSelectedReportId(_report.id);
  }

  CatchFilterOptions _createCustomReportFilterOptions(
    Report report,
    Iterable<DateRange> dateRanges,
  ) {
    return CatchFilterOptions(
      dateRanges: dateRanges,
      isCatchAndReleaseOnly: report.isCatchAndReleaseOnly,
      isFavoritesOnly: report.isFavoritesOnly,
      anglerIds: report.anglerIds.toSet(),
      baits: report.baits.toSet(),
      gearIds: report.gearIds.toSet(),
      fishingSpotIds: report.fishingSpotIds.toSet(),
      bodyOfWaterIds: report.bodyOfWaterIds.toSet(),
      methodIds: report.methodIds.toSet(),
      speciesIds: report.speciesIds.toSet(),
      waterClarityIds: report.waterClarityIds.toSet(),
      periods: report.periods.toSet(),
      seasons: report.seasons.toSet(),
      windDirections: report.windDirections.toSet(),
      skyConditions: report.skyConditions.toSet(),
      moonPhases: report.moonPhases.toSet(),
      tideTypes: report.tideTypes.toSet(),
      waterDepthFilter:
          report.hasWaterDepthFilter() ? report.waterDepthFilter : null,
      waterTemperatureFilter: report.hasWaterTemperatureFilter()
          ? report.waterTemperatureFilter
          : null,
      lengthFilter: report.hasLengthFilter() ? report.lengthFilter : null,
      weightFilter: report.hasWeightFilter() ? report.weightFilter : null,
      quantityFilter: report.hasQuantityFilter() ? report.quantityFilter : null,
      airTemperatureFilter:
          report.hasAirTemperatureFilter() ? report.airTemperatureFilter : null,
      airPressureFilter:
          report.hasAirPressureFilter() ? report.airPressureFilter : null,
      airHumidityFilter:
          report.hasAirHumidityFilter() ? report.airHumidityFilter : null,
      airVisibilityFilter:
          report.hasAirVisibilityFilter() ? report.airVisibilityFilter : null,
      windSpeedFilter:
          report.hasWindSpeedFilter() ? report.windSpeedFilter : null,
    );
  }
}
