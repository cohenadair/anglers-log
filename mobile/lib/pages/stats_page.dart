import 'package:flutter/material.dart';
import 'package:mobile/angler_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/method_manager.dart';
import 'package:mobile/pages/fishing_spot_list_page.dart';
import 'package:mobile/pages/method_list_page.dart';
import 'package:mobile/pages/water_clarity_list_page.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/water_clarity_manager.dart';
import 'package:mobile/widgets/catch_summary.dart';
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
import '../res/gen/custom_icons.dart';
import '../species_manager.dart';
import '../user_preference_manager.dart';
import '../utils/page_utils.dart';
import '../widgets/empty_list_placeholder.dart';
import '../widgets/widget.dart';
import 'angler_list_page.dart';
import 'bait_list_page.dart';
import 'body_of_water_list_page.dart';
import 'manageable_list_page.dart';
import 'picker_page.dart';
import 'species_list_page.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  static const _log = Log("StatsPage");

  /// The currently selected report from the app bar dropdown menu.
  late Report _report;

  ReportManager get _reportManager => ReportManager.of(context);

  AnglerManager get _anglerManager => AnglerManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

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
        managers: [_reportManager],
        onAnyChange: () => _updateCurrentReport(_report.id),
        builder: (context) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: _buildReportDropdown(),
                forceElevated: true,
                pinned: true,
              ),
              _buildHeader(),
              _buildContent(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReportDropdown() {
    return InkWell(
      onTap: () {
        present(
          context,
          ReportListPage(
            pickerSettings: ManageableListPagePickerSettings<dynamic>.single(
              onPicked: (context, report) {
                if (report != _report) {
                  setState(() => _updateCurrentReport(report.id));
                }
                return true;
              },
              initialValue: _report,
            ),
          ),
        );
      },
      child: Padding(
        padding: insetsVerticalDefault,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_reportManager.displayName(context, _report)),
            DropdownIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    Widget child = Empty();
    if (isNotEmpty(_report.description)) {
      child = Padding(
        padding: insetsDefault,
        child: Text(
          _report.description,
          overflow: TextOverflow.visible,
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          child is Empty ? Empty() : const MinDivider(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    Widget? child = _buildReport();
    return SliverVisibility(
      visible: child != null,
      sliver: SliverToBoxAdapter(child: child ?? Empty()),
      replacementSliver: SliverFillRemaining(
        fillOverscroll: true,
        hasScrollBody: false,
        child: Center(
          child: EmptyListPlaceholder.static(
            icon: CustomIcons.catches,
            title: Strings.of(context).reportViewNoCatches,
            description: _report.type == Report_Type.catch_summary
                ? Strings.of(context).reportViewNoCatchesDescription
                : Strings.of(context).reportViewNoCatchesReportDescription,
          ),
        ),
      ),
    );
  }

  Widget? _buildReport() {
    var report = _reportManager.entity(_report.id);
    if (report == null) {
      _log.w("Report ${_report.id} not found");
      return null;
    }

    switch (report.type) {
      case Report_Type.summary:
        return CatchSummary<Catch>.static(
          report: _createCustomReport(report, [report.fromDateRange]),
        );
      case Report_Type.comparison:
        return CatchSummary<Catch>.static(
          report: _createCustomReport(
            report,
            [report.fromDateRange, report.toDateRange],
            includeZeros: true,
          ),
        );
      case Report_Type.catch_summary:
        return CatchSummary<Catch>(
          reportBuilder: (dateRange, _) => CatchSummaryReport<Catch>(
            context: context,
          ),
        );
      case Report_Type.species_summary:
        return _buildSpeciesSummary();
      case Report_Type.angler_summary:
        return _buildAnglerSummary();
      case Report_Type.bait_summary:
        return _buildBaitSummary();
      case Report_Type.body_of_water_summary:
        return _buildBodyOfWaterSummary();
      case Report_Type.fishing_spot_summary:
        return _buildFishingSpotSummary();
      case Report_Type.method_summary:
        return _buildMethodSummary();
      case Report_Type.moon_phase_summary:
        return _buildMoonPhaseSummary();
      case Report_Type.period_summary:
        return _buildPeriodSummary();
      case Report_Type.season_summary:
        return _buildSeasonSummary();
      case Report_Type.tide_summary:
        return _buildTideSummary();
      case Report_Type.water_clarity_summary:
        return _buildWaterClaritySummary();
      case Report_Type.personal_bests:
        return PersonalBestsReport();
      case Report_Type.trip_summary:
        return TripSummary();
    }
  }

  Widget? _buildSpeciesSummary() {
    if (!_speciesManager.hasEntities ||
        !_userPreferencesManager.isTrackingSpecies) {
      return null;
    }

    return CatchSummary<Species>(
      reportBuilder: (dateRange, species) => CatchSummaryReport<Species>(
        context: context,
        ranges: [dateRange],
        speciesIds: singleSet<Id>(species?.id),
      ),
      picker: CatchSummaryPicker<Species>(
        initialValue: _speciesManager.list().first,
        pickerBuilder: (settings) => SpeciesListPage(pickerSettings: settings),
        nameBuilder: (context, species) =>
            _speciesManager.displayName(context, species),
      ),
    );
  }

  Widget? _buildAnglerSummary() {
    if (!_anglerManager.hasEntities ||
        !_userPreferencesManager.isTrackingAnglers) {
      return null;
    }

    return CatchSummary<Angler>(
      reportBuilder: (dateRange, angler) => CatchSummaryReport<Angler>(
        context: context,
        ranges: [dateRange],
        anglerIds: singleSet<Id>(angler?.id),
      ),
      picker: CatchSummaryPicker<Angler>(
        initialValue: _anglerManager.list().first,
        pickerBuilder: (settings) => AnglerListPage(pickerSettings: settings),
        nameBuilder: (context, species) =>
            _anglerManager.displayName(context, species),
      ),
    );
  }

  Widget? _buildBaitSummary() {
    if (!_baitManager.hasEntities || !_userPreferencesManager.isTrackingBaits) {
      return null;
    }

    return CatchSummary<BaitAttachment>(
      reportBuilder: (range, attachment) => CatchSummaryReport<BaitAttachment>(
        context: context,
        ranges: [range],
        baits: singleSet<BaitAttachment>(attachment),
      ),
      picker: CatchSummaryPicker<BaitAttachment>(
        initialValue: _baitManager.list().first.toAttachment(),
        pickerBuilder: (settings) => BaitListPage(
          pickerSettings:
              BaitListPagePickerSettings.fromManageableList(settings),
        ),
        // The fact that this is called at all means the attachment exists
        // and attachmentDisplayValue will return a non-null value.
        nameBuilder: (context, attachment) =>
            _baitManager.attachmentDisplayValue(attachment, context)!,
      ),
    );
  }

  Widget? _buildBodyOfWaterSummary() {
    if (!_bodyOfWaterManager.hasEntities) {
      return null;
    }

    return CatchSummary<BodyOfWater>(
      reportBuilder: (dateRange, bodyOfWater) =>
          CatchSummaryReport<BodyOfWater>(
        context: context,
        ranges: [dateRange],
        bodyOfWaterIds: singleSet<Id>(bodyOfWater?.id),
      ),
      picker: CatchSummaryPicker<BodyOfWater>(
        initialValue: _bodyOfWaterManager.list().first,
        pickerBuilder: (settings) =>
            BodyOfWaterListPage(pickerSettings: settings),
        nameBuilder: (context, bodyOfWater) =>
            _bodyOfWaterManager.displayName(context, bodyOfWater),
      ),
    );
  }

  Widget? _buildFishingSpotSummary() {
    if (!_fishingSpotManager.hasEntities ||
        !_userPreferencesManager.isTrackingFishingSpots) {
      return null;
    }

    return CatchSummary<FishingSpot>(
      reportBuilder: (dateRange, fishingSpot) =>
          CatchSummaryReport<FishingSpot>(
        context: context,
        ranges: [dateRange],
        fishingSpotIds: singleSet<Id>(fishingSpot?.id),
      ),
      picker: CatchSummaryPicker<FishingSpot>(
        initialValue: _fishingSpotManager.list().first,
        pickerBuilder: (settings) => FishingSpotListPage(
            pickerSettings:
                FishingSpotListPagePickerSettings.fromManageableList(settings)),
        nameBuilder: (context, fishingSpot) =>
            _fishingSpotManager.displayName(context, fishingSpot),
      ),
    );
  }

  Widget? _buildMethodSummary() {
    if (!_methodManager.hasEntities ||
        !_userPreferencesManager.isTrackingMethods) {
      return null;
    }

    return CatchSummary<Method>(
      reportBuilder: (dateRange, method) => CatchSummaryReport<Method>(
        context: context,
        ranges: [dateRange],
        methodIds: singleSet<Id>(method?.id),
      ),
      picker: CatchSummaryPicker<Method>(
        initialValue: _methodManager.list().first,
        pickerBuilder: (settings) => MethodListPage(pickerSettings: settings),
        nameBuilder: (context, method) =>
            _methodManager.displayName(context, method),
      ),
    );
  }

  Widget? _buildMoonPhaseSummary() {
    if (!_userPreferencesManager.isTrackingMoonPhases) {
      return null;
    }

    return CatchSummary<MoonPhase>(
      reportBuilder: (dateRange, moonPhase) => CatchSummaryReport<MoonPhase>(
        context: context,
        ranges: [dateRange],
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

  Widget? _buildPeriodSummary() {
    if (!_userPreferencesManager.isTrackingPeriods) {
      return null;
    }

    return CatchSummary<Period>(
      reportBuilder: (dateRange, period) => CatchSummaryReport<Period>(
        context: context,
        ranges: [dateRange],
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

  Widget? _buildSeasonSummary() {
    if (!_userPreferencesManager.isTrackingSeasons) {
      return null;
    }

    return CatchSummary<Season>(
      reportBuilder: (dateRange, season) => CatchSummaryReport<Season>(
        context: context,
        ranges: [dateRange],
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

  Widget? _buildTideSummary() {
    if (!_userPreferencesManager.isTrackingTides) {
      return null;
    }

    return CatchSummary<TideType>(
      reportBuilder: (dateRange, tide) => CatchSummaryReport<TideType>(
        context: context,
        ranges: [dateRange],
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

  Widget? _buildWaterClaritySummary() {
    if (!_waterClarityManager.hasEntities ||
        !_userPreferencesManager.isTrackingWaterClarities) {
      return null;
    }

    return CatchSummary<WaterClarity>(
      reportBuilder: (dateRange, clarity) => CatchSummaryReport<WaterClarity>(
        context: context,
        ranges: [dateRange],
        waterClarityIds: singleSet<Id>(clarity?.id),
      ),
      picker: CatchSummaryPicker<WaterClarity>(
        initialValue: _waterClarityManager.list().first,
        pickerBuilder: (settings) =>
            WaterClarityListPage(pickerSettings: settings),
        nameBuilder: (context, clarity) =>
            _waterClarityManager.displayName(context, clarity),
      ),
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

  CatchSummaryReport<Catch> _createCustomReport(
    Report report,
    Iterable<DateRange> dateRanges, {
    bool includeZeros = false,
    CatchSummarySortOrder sortOrder = CatchSummarySortOrder.alphabetical,
  }) {
    return CatchSummaryReport(
      context: context,
      includeZeros: includeZeros,
      sortOrder: sortOrder,
      ranges: dateRanges,
      isCatchAndReleaseOnly: report.isCatchAndReleaseOnly,
      isFavoritesOnly: report.isFavoritesOnly,
      anglerIds: report.anglerIds.toSet(),
      baits: report.baits.toSet(),
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
