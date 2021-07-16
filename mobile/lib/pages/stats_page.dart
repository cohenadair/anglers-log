import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../bait_manager.dart';
import '../catch_manager.dart';
import '../entity_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/calculated_report.dart';
import '../model/gen/anglerslog.pb.dart';
import '../model/overview_report.dart';
import '../pages/report_list_page.dart';
import '../report_manager.dart';
import '../res/dimen.dart';
import '../res/gen/custom_icons.dart';
import '../res/style.dart';
import '../species_manager.dart';
import '../user_preference_manager.dart';
import '../utils/date_time_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/chart.dart';
import '../widgets/date_range_picker_input.dart';
import '../widgets/empty_list_placeholder.dart';
import '../widgets/list_item.dart';
import '../widgets/list_picker_input.dart';
import '../widgets/widget.dart';
import 'bait_page.dart';
import 'catch_list_page.dart';
import 'fishing_spot_page.dart';
import 'manageable_list_page.dart';
import 'species_list_page.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  static const _log = Log("StatsPage");

  final List<CalculatedReport> _models = [];

  /// The currently selected date range for viewing an [OverviewReport].
  var _currentOverviewDateRange = DateRange(period: DateRange_Period.allDates);

  /// The currently selected report from the app bar dropdown menu.
  dynamic _currentReport;

  // TODO: Figure something out so this isn't nullable.
  /// The currently selected species in the species summary.
  Species? _currentSpecies;

  BaitManager get _baitManager => BaitManager.of(context);

  CatchManager get _catchManager => CatchManager.of(context);

  ReportManager get _reportManager => ReportManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  UserPreferenceManager get _userPreferencesManager =>
      UserPreferenceManager.of(context);

  bool get _isComparing => _models.length > 1;

  bool get _hasCatches => _meets((model) => model.totalCatches > 0);

  bool get _hasCatchesPerFishingSpot =>
      _meets((model) => model.catchesPerFishingSpot.isNotEmpty);

  bool get _hasCatchesPerBait =>
      _meets((model) => model.catchesPerBait.isNotEmpty);

  bool get _hasBaitsPerSpecies =>
      _meets((model) => model.baitsPerSpecies(_currentSpecies).isNotEmpty);

  bool get _hasFishingSpotsPerSpecies => _meets(
      (model) => model.fishingSpotsPerSpecies(_currentSpecies).isNotEmpty);

  @override
  void initState() {
    super.initState();
    _updateCurrentReport(_userPreferencesManager.selectedReportId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EntityListenerBuilder(
        managers: [
          _catchManager,
          _baitManager,
          _fishingSpotManager,
          _reportManager,
          _speciesManager,
        ],
        onAnyChange: () => _updateCurrentReport(_currentReport.id),
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
                if (report != _currentReport) {
                  setState(() {
                    _updateCurrentReport(report.id);
                  });
                }
                return true;
              },
              initialValue: _currentReport,
            ),
          ),
        );
      },
      child: Padding(
        padding: insetsVerticalDefault,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentReport is OverviewReport
                  ? _currentReport.title(context)
                  : _currentReport.name,
            ),
            DropdownIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    Widget child = Empty();
    if (_currentReport is OverviewReport) {
      child = DateRangePickerInput(
        initialDateRange: _currentOverviewDateRange,
        onPicked: (dateRange) => setState(() {
          _currentOverviewDateRange = dateRange;
          _updateCurrentReport(_currentReport.id);
        }),
      );
    } else if (_currentReport is Report &&
        isNotEmpty(_currentReport.description)) {
      child = Padding(
        padding: insetsDefault,
        child: Text(
          _currentReport.description!,
          overflow: TextOverflow.visible,
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          child is Empty ? Empty() : MinDivider(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Do not load widgets unless there are catches in the current report.
    var children = <Widget>[];
    if (_hasCatches) {
      children = [
        Padding(
          padding: insetsDefault,
          child: Text(
            Strings.of(context).reportSummaryCatchTitle,
            style: styleListHeading(context),
          ),
        ),
        _buildViewCatches(),
        _buildSinceLastCatch(),
        _buildCatchesPerSpecies(),
        _buildCatchesPerFishingSpot(),
        _buildCatchesPerBait(),
        HeadingDivider(Strings.of(context).reportSummarySpeciesTitle),
        VerticalSpace(paddingWidget),
        _buildSpeciesPicker(),
        _buildViewCatchesPerSpecies(),
        _buildFishingSpotsPerSpecies(),
        _buildBaitsPerSpecies(),
      ];
    }

    return SliverVisibility(
      visible: _hasCatches,
      sliver: SliverList(
        delegate: SliverChildListDelegate(children),
      ),
      replacementSliver: SliverFillRemaining(
        fillOverscroll: true,
        hasScrollBody: false,
        child: Center(
          child: EmptyListPlaceholder.static(
            icon: CustomIcons.catches,
            title: Strings.of(context).reportViewNoCatches,
            description: _currentReport is OverviewReport
                ? Strings.of(context).reportViewNoCatchesDescription
                : Strings.of(context).reportViewNoCatchesReportDescription,
          ),
        ),
      ),
    );
  }

  Widget _buildCatchesPerSpecies() {
    return ExpandableChart<Species>(
      title: Strings.of(context).reportSummaryPerSpecies,
      viewAllTitle: Strings.of(context).reportSummaryViewSpecies,
      viewAllDescription:
          Strings.of(context).reportSummaryCatchesPerSpeciesDescription,
      filters: _filters(includeDateRange: !_isComparing),
      labelBuilder: (species) => species.name,
      series: _models
          .map((model) =>
              Series<Species>(model.catchesPerSpecies, model.dateRange))
          .toList(),
      rowDetailsPage: (species, dateRange) => CatchListPage(
        enableAdding: false,
        dateRange: dateRange,
        baitIds: _models.first.baitIds,
        fishingSpotIds: _models.first.fishingSpotIds,
        speciesIds: {species.id},
      ),
    );
  }

  Widget _buildCatchesPerFishingSpot() {
    if (!_hasCatchesPerFishingSpot) {
      return Empty();
    }

    return ExpandableChart<FishingSpot>(
      title: Strings.of(context).reportSummaryPerFishingSpot,
      viewAllTitle: Strings.of(context).reportSummaryViewFishingSpots,
      viewAllDescription:
          Strings.of(context).reportSummaryCatchesPerFishingSpotDescription,
      filters: _filters(includeDateRange: !_isComparing),
      labelBuilder: (fishingSpot) => fishingSpot.displayName(context),
      series: _models
          .map((model) =>
              Series<FishingSpot>(model.catchesPerFishingSpot, model.dateRange))
          .toList(),
      rowDetailsPage: (fishingSpot, dateRange) => CatchListPage(
        enableAdding: false,
        dateRange: dateRange,
        baitIds: _models.first.baitIds,
        fishingSpotIds: {fishingSpot.id},
        speciesIds: _models.first.speciesIds,
      ),
    );
  }

  Widget _buildCatchesPerBait() {
    if (!_hasCatchesPerBait) {
      return Empty();
    }

    return ExpandableChart<Bait>(
      title: Strings.of(context).reportSummaryPerBait,
      viewAllTitle: Strings.of(context).reportSummaryViewBaits,
      viewAllDescription:
          Strings.of(context).reportSummaryCatchesPerBaitDescription,
      filters: _filters(includeDateRange: !_isComparing),
      labelBuilder: (bait) => bait.name,
      series: _models
          .map((model) => Series<Bait>(model.catchesPerBait, model.dateRange))
          .toList(),
      rowDetailsPage: (bait, dateRange) => CatchListPage(
        enableAdding: false,
        dateRange: dateRange,
        baitIds: {bait.id},
        fishingSpotIds: _models.first.fishingSpotIds,
        speciesIds: _models.first.speciesIds,
      ),
    );
  }

  Widget _buildSinceLastCatch() {
    if (!_hasCatches || _isComparing || !_models.first.containsNow) {
      return Empty();
    }

    return ListItem(
      title: Text(Strings.of(context).reportSummarySinceLastCatch),
      trailing: Text(
        formatDuration(
          context: context,
          millisecondsDuration: _models.first.msSinceLastCatch,
          includesSeconds: false,
          condensed: true,
        ),
        style: styleSecondary(context),
      ),
    );
  }

  Widget _buildSpeciesPicker() {
    return ListPickerInput(
      value: _currentSpecies!.name,
      onTap: () {
        push(
          context,
          SpeciesListPage(
            pickerSettings: ManageableListPagePickerSettings<Species>.single(
              onPicked: (context, species) {
                setState(() => _currentSpecies = species);
                return true;
              },
              isRequired: true,
              initialValue: _currentSpecies,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBaitsPerSpecies() {
    if (!_hasBaitsPerSpecies) {
      return Empty();
    }

    return ExpandableChart<Bait>(
      title: Strings.of(context).reportSummaryPerBait,
      viewAllTitle: Strings.of(context).reportSummaryViewBaits,
      viewAllDescription:
          Strings.of(context).reportSummaryBaitsPerSpeciesDescription,
      filters: _filters(
        includeSpecies: false,
        includeDateRange: !_isComparing,
      )..add(_currentSpecies!.name),
      labelBuilder: (bait) => bait.name,
      series: _models
          .map((model) => Series<Bait>(
              model.baitsPerSpecies(_currentSpecies), model.dateRange))
          .toList(),
      rowDetailsPage: (bait, _) => BaitPage(bait, static: true),
    );
  }

  Widget _buildFishingSpotsPerSpecies() {
    if (!_hasFishingSpotsPerSpecies) {
      return Empty();
    }

    return ExpandableChart<FishingSpot>(
      title: Strings.of(context).reportSummaryPerFishingSpot,
      viewAllTitle: Strings.of(context).reportSummaryViewFishingSpots,
      viewAllDescription:
          Strings.of(context).reportSummaryFishingSpotsPerSpeciesDescription,
      filters: _filters(
        includeSpecies: false,
        includeDateRange: !_isComparing,
      )..add(_currentSpecies!.name),
      labelBuilder: (fishingSpot) => fishingSpot.displayName(context),
      series: _models
          .map((model) => Series<FishingSpot>(
              model.fishingSpotsPerSpecies(_currentSpecies), model.dateRange))
          .toList(),
      rowDetailsPage: (fishingSpot, _) => FishingSpotPage(fishingSpot),
    );
  }

  Widget _buildViewCatches() {
    return Column(
      children: _models
          .map((model) =>
              _buildViewCatchesRow(model.allCatchIds, model.dateRange))
          .toList(),
    );
  }

  Widget _buildViewCatchesPerSpecies() {
    return Column(
      children: _models.map((model) {
        var catchIds = <Id>{};
        if (_currentSpecies != null &&
            model.catchIdsPerSpecies[_currentSpecies!] != null) {
          catchIds = model.catchIdsPerSpecies[_currentSpecies!]!;
        }
        return _buildViewCatchesRow(
          catchIds,
          model.dateRange,
        );
      }).toList(),
    );
  }

  Widget _buildViewCatchesRow(Set<Id> catchIds, DateRange dateRange) {
    if (catchIds.isEmpty) {
      return ListItem(
        title: Text(Strings.of(context).reportSummaryNumberOfCatches),
        subtitle: Text(dateRange.displayName(context)),
        trailing: Text("0", style: styleSecondary(context)),
      );
    }

    return ListItem(
      title: Text(format(
          Strings.of(context).reportSummaryViewCatches, [catchIds.length])),
      subtitle: Text(dateRange.displayName(context)),
      onTap: () => push(
        context,
        CatchListPage(
          enableAdding: false,
          catchIds: catchIds,
        ),
      ),
      trailing: RightChevronIcon(),
    );
  }

  void _updateCurrentReport(Id? newReportId) {
    // If the current report no longer exists, show an overview.
    if (!_reportManager.entityExists(newReportId)) {
      _currentReport = OverviewReport();
    } else {
      // Always retrieve the latest report from the database. If the report was
      // edited, we'll need the latest data.
      _currentReport = _reportManager.entity(newReportId);
    }

    _userPreferencesManager.setSelectedReportId(_currentReport.id);
    _models.clear();

    if (_currentReport is OverviewReport) {
      _models.add(_createOverviewModel());
    } else if (_currentReport is Report) {
      _models.addAll(_currentReport.type == Report_Type.comparison
          ? _createComparisonModels()
          : _createSummaryModel());
    } else {
      _log.w("Invalid report type: ${_currentReport.runtimeType}");
    }

    if (_currentSpecies == null) {
      // By default, show the species with the most catches.
      Id? maxId;
      var maxValue = 0;
      for (var model in _models) {
        for (var entry in model.catchesPerSpecies.entries) {
          if (entry.value >= maxValue) {
            maxId = entry.key.id;
            maxValue = entry.value;
          }
        }
      }

      if (maxId != null) {
        _currentSpecies = _speciesManager.entity(maxId);
      }
    } else {
      // Get updated species from the database.
      _currentSpecies = _speciesManager.entity(_currentSpecies!.id);
    }
  }

  CalculatedReport _createOverviewModel() {
    return CalculatedReport(
      context: context,
      range: _currentOverviewDateRange,
    );
  }

  List<CalculatedReport> _createSummaryModel() {
    var report = _reportManager.entity(_currentReport.id)!;

    return [
      _createReportModel(
        context,
        report,
        report.fromDateRange,
        sortOrder: CalculatedReportSortOrder.largestToSmallest,
      )
    ];
  }

  List<CalculatedReport> _createComparisonModels() {
    var report = _reportManager.entity(_currentReport.id)!;

    var fromModel = _createReportModel(
      context,
      report,
      report.fromDateRange,
      includeZeros: true,
    );
    var toModel = _createReportModel(
      context,
      report,
      report.toDateRange,
      includeZeros: true,
    );
    fromModel.removeZerosComparedTo(toModel);

    return [
      fromModel,
      toModel,
    ];
  }

  CalculatedReport _createReportModel(
    BuildContext context,
    Report report,
    DateRange dateRange, {
    bool includeZeros = false,
    CalculatedReportSortOrder sortOrder =
        CalculatedReportSortOrder.alphabetical,
  }) {
    return CalculatedReport(
      context: context,
      includeZeros: includeZeros,
      sortOrder: sortOrder,
      range: dateRange,
      isCatchAndReleaseOnly: report.isCatchAndReleaseOnly,
      isFavoritesOnly: report.isFavoritesOnly,
      anglerIds: report.anglerIds.toSet(),
      baitIds: report.baitIds.toSet(),
      fishingSpotIds: report.fishingSpotIds.toSet(),
      methodIds: report.methodIds.toSet(),
      speciesIds: report.speciesIds.toSet(),
      waterClarityIds: report.waterClarityIds.toSet(),
      periods: report.periods.toSet(),
      seasons: report.seasons.toSet(),
      windDirections: report.windDirections.toSet(),
      skyConditions: report.skyConditions.toSet(),
      moonPhases: report.moonPhases.toSet(),
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

  Set<String> _filters({
    bool includeSpecies = true,
    bool includeDateRange = true,
  }) {
    return _models.fold<Set<String>>({}, (previousValue, model) {
      return previousValue
        ..addAll(
          model.filters(
            includeSpecies: includeSpecies,
            includeDateRange: includeDateRange,
          ),
        );
    });
  }

  bool _meets(bool Function(CalculatedReport model) condition) {
    return _models.firstWhereOrNull((model) => condition(model)) != null;
  }
}
