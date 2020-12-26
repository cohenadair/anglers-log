import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../bait_manager.dart';
import '../catch_manager.dart';
import '../comparison_report_manager.dart';
import '../entity_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../model/gen/google/protobuf/timestamp.pb.dart';
import '../model/overview_report.dart';
import '../model/report.dart';
import '../pages/report_list_page.dart';
import '../preferences_manager.dart';
import '../res/dimen.dart';
import '../res/gen/custom_icons.dart';
import '../species_manager.dart';
import '../summary_report_manager.dart';
import '../utils/date_time_utils.dart';
import '../utils/page_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/chart.dart';
import '../widgets/date_range_picker_input.dart';
import '../widgets/empty_list_placeholder.dart';
import '../widgets/list_item.dart';
import '../widgets/list_picker_input.dart';
import '../widgets/text.dart';
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

  final List<Report> _models = [];

  /// The currently selected date range for viewing an [OverviewReport].
  var _currentOverviewDateRange =
      DisplayDateRange.of(DisplayDateRange.allDates.id);

  /// The currently selected report from the app bar dropdown menu.
  dynamic _currentReport;

  /// The currently selected species in the species summary.
  Species _currentSpecies;

  BaitManager get _baitManager => BaitManager.of(context);

  CatchManager get _catchManager => CatchManager.of(context);

  ComparisonReportManager get _comparisonReportManager =>
      ComparisonReportManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  PreferencesManager get _preferencesManager => PreferencesManager.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  SummaryReportManager get _summaryReportManager =>
      SummaryReportManager.of(context);

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
    _updateCurrentReport(_preferencesManager.selectedReportId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EntityListenerBuilder(
        managers: [
          _catchManager,
          _baitManager,
          _fishingSpotManager,
          _comparisonReportManager,
          _speciesManager,
          _summaryReportManager,
        ],
        onUpdate: () => _updateCurrentReport(_currentReport.id),
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
    } else if ((_currentReport is SummaryReport ||
            _currentReport is ComparisonReport) &&
        isNotEmpty(_currentReport.description)) {
      child = Padding(
        padding: insetsDefault,
        child: Label.multiline(_currentReport.description),
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
          child: HeadingLabel(Strings.of(context).reportSummaryCatchTitle),
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
                : Strings.of(context)
                    .reportViewNoCatchesCustomReportDescription,
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
              Series<Species>(model.catchesPerSpecies, model.displayDateRange))
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
      labelBuilder: (fishingSpot) => fishingSpot.name,
      series: _models
          .map((model) => Series<FishingSpot>(
              model.catchesPerFishingSpot, model.displayDateRange))
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
          .map((model) =>
              Series<Bait>(model.catchesPerBait, model.displayDateRange))
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
      trailing: SecondaryLabel(formatDuration(
        context: context,
        millisecondsDuration: _models.first.msSinceLastCatch,
        includesSeconds: false,
        condensed: true,
      )),
    );
  }

  Widget _buildSpeciesPicker() {
    return ListPickerInput(
      value: _currentSpecies.name,
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
      )..add(_currentSpecies.name),
      labelBuilder: (bait) => bait.name,
      series: _models
          .map((model) => Series<Bait>(
              model.baitsPerSpecies(_currentSpecies), model.displayDateRange))
          .toList(),
      rowDetailsPage: (bait, _) => BaitPage(bait.id, static: true),
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
      )..add(_currentSpecies.name),
      labelBuilder: (fishingSpot) => fishingSpot.name,
      series: _models
          .map((model) => Series<FishingSpot>(
              model.fishingSpotsPerSpecies(_currentSpecies),
              model.displayDateRange))
          .toList(),
      rowDetailsPage: (fishingSpot, _) => FishingSpotPage(fishingSpot.id),
    );
  }

  Widget _buildViewCatches() {
    return Column(
      children: _models
          .map((model) =>
              _buildViewCatchesRow(model.allCatchIds, model.displayDateRange))
          .toList(),
    );
  }

  Widget _buildViewCatchesPerSpecies() {
    return Column(
      children: _models
          .map((model) => _buildViewCatchesRow(
              model.catchIdsPerSpecies[_currentSpecies],
              model.displayDateRange))
          .toList(),
    );
  }

  Widget _buildViewCatchesRow(Set<Id> catchIds, DisplayDateRange dateRange) {
    catchIds = catchIds ?? {};

    if (catchIds.isEmpty) {
      return ListItem(
        title: Text(Strings.of(context).reportSummaryNumberOfCatches),
        subtitle: Text(dateRange.title(context)),
        trailing: SecondaryLabel("0"),
      );
    }

    return ListItem(
      title: Text(format(
          Strings.of(context).reportSummaryViewCatches, [catchIds.length])),
      subtitle: Text(dateRange.title(context)),
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

  void _updateCurrentReport(Id newReportId) {
    // If the current report no longer exists, show an overview.
    if (newReportId == null ||
        (!_summaryReportManager.entityExists(newReportId) &&
            !_comparisonReportManager.entityExists(newReportId))) {
      _currentReport = OverviewReport();
    } else {
      // Always retrieve the latest report from the database. If the report was
      // edited, we'll need the latest data.
      _currentReport = _summaryReportManager.entity(newReportId) ??
          _comparisonReportManager.entity(newReportId);
    }

    _preferencesManager.selectedReportId = _currentReport.id;
    _models.clear();

    if (_currentReport is OverviewReport) {
      _models.add(_createOverviewModel());
    } else if (_currentReport is SummaryReport) {
      _models.add(_createSummaryModel());
    } else if (_currentReport is ComparisonReport) {
      _models.addAll(_createComparisonModels());
    } else {
      _log.w("Invalid report type: ${_currentReport.runtimeType}");
    }

    var catchesPerSpecies = _models.first.catchesPerSpecies;
    if (_currentSpecies == null && catchesPerSpecies.isNotEmpty) {
      if (_models.first.speciesIds.isEmpty) {
        _currentSpecies = catchesPerSpecies.keys.first;
      } else {
        _currentSpecies = catchesPerSpecies.keys.firstWhere(
            (species) => species.id == _models.first.speciesIds.first);
      }
    }
  }

  Report _createOverviewModel() {
    return Report(
      context: context,
      displayDateRange: _currentOverviewDateRange,
    );
  }

  Report _createSummaryModel() {
    var report = _summaryReportManager.entity(_currentReport.id);

    return _createCustomReportModel(
      context,
      report,
      report.displayDateRangeId,
      report.startTimestamp,
      report.endTimestamp,
    );
  }

  List<Report> _createComparisonModels() {
    var report = _comparisonReportManager.entity(_currentReport.id);

    var fromModel = _createCustomReportModel(
      context,
      report,
      report.fromDisplayDateRangeId,
      report.fromStartTimestamp,
      report.fromEndTimestamp,
      includeZeros: true,
    );
    var toModel = _createCustomReportModel(
      context,
      report,
      report.toDisplayDateRangeId,
      report.toStartTimestamp,
      report.toEndTimestamp,
      includeZeros: true,
    );
    fromModel.removeZerosComparedTo(toModel);

    return [
      fromModel,
      toModel,
    ];
  }

  Report _createCustomReportModel(
    BuildContext context,
    dynamic report,
    String displayDateRangeId,
    Timestamp startTimestamp,
    Timestamp endTimestamp, {
    bool includeZeros = false,
  }) {
    return Report(
      context: context,
      includeZeros: includeZeros,
      sortOrder: ReportSortOrder.alphabetical,
      displayDateRange:
          DisplayDateRange.of(displayDateRangeId, startTimestamp, endTimestamp),
      baitIds: report.baitIds.toSet(),
      fishingSpotIds: report.fishingSpotIds.toSet(),
      speciesIds: report.speciesIds.toSet(),
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

  bool _meets(bool Function(Report model) condition) {
    return _models.firstWhere((model) => condition(model),
            orElse: () => null) !=
        null;
  }
}
