import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/chart.dart';
import 'package:mobile/widgets/date_range_picker_input.dart';
import 'package:mobile/widgets/label_value.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/report_view.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/time.dart';

class OverviewReportView extends StatefulWidget {
  final ScrollController scrollController;

  OverviewReportView({
    this.scrollController,
  });

  @override
  _OverviewReportViewState createState() => _OverviewReportViewState();
}

class _OverviewReportViewState extends State<OverviewReportView> {
  static const _catchesBySpeciesChartId = "catches_per_species";
  static const _catchesByFishingSpotChartId = "catches_per_fishing_spot";
  static const _catchesByBaitChartId = "catches_per_bait";

  DisplayDateRange _currentDateRange =
      DisplayDateRange.of(DisplayDateRange.allDates.id);

  OverviewReportViewData _overview;

  bool get _hasCatches => _overview.totalCatches > 0;
  bool get _hasFishingSpots => _overview.totalFishingSpots > 0;
  bool get _hasBaits => _overview.totalBaits > 0;

  @override
  void initState() {
    super.initState();
    _resetOverview();
  }

  @override
  Widget build(BuildContext context) {
    return ReportView(
      onUpdate: () => _resetOverview(),
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDurationPicker(),
          _buildCatchItems(),
        ],
      ),
    );
  }

  Widget _buildDurationPicker() => DateRangePickerInput(
    initialDateRange: _currentDateRange,
    onPicked: (dateRange) => setState(() {
      _currentDateRange = dateRange;
      _resetOverview();
    }),
  );

  Widget _buildCatchItems() {
    if (!_hasCatches) {
      // TODO: Design a nicer widget here.
      return Column(
        children: [
          MinDivider(),
          Padding(
            padding: insetsDefault,
            child: PrimaryLabel(
              Strings.of(context).overviewReportViewNoCatches,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildViewCatchesRow(),
        _buildSummary(),
        MinDivider(),
        _buildSpecies(),
        MinDivider(),
        _buildFishingSpots(),
        MinDivider(),
        _buildBaits(),
      ],
    );
  }

  Widget _buildViewCatchesRow() {
    return ListItem(
      title: Text(Strings.of(context).reportViewViewCatches),
      onTap: () => push(context, CatchListPage(
        dateRange: _overview.dateRange,
      )),
      trailing: RightChevronIcon(),
    );
  }

  Widget _buildSummary() {
    // TODO: Show "96/150" for fishing spots/baits with catches
    return Column(
      children: [
        HeadingDivider(Strings.of(context).overviewReportViewSummary),
        VerticalSpace(paddingWidget),
        LabelValue(
          padding: insetsHorizontalDefault,
          label: Strings.of(context).overviewReportViewNumberOfCatches,
          value: _overview.totalCatches.toString(),
        ),
        VerticalSpace(paddingWidget),
        _hasCatches && _overview.isCurrentDate ? LabelValue(
          padding: EdgeInsets.only(
            left: paddingDefault,
            right: paddingDefault,
            bottom: paddingWidget,
          ),
          label: Strings.of(context).overviewReportViewSinceLastCatch,
          value: formatDuration(
            context: context,
            millisecondsDuration: _overview.msSinceLastCatch,
            includesSeconds: false,
            condensed: true,
          ),
        ) : Empty(),
        LabelValue(
          padding: EdgeInsets.only(
            left: paddingDefault,
            right: paddingDefault,
          ),
          label: Strings.of(context).overviewReportViewNumberOfFishingSpots,
          value: _overview.totalFishingSpots.toString(),
        ),
        VerticalSpace(paddingWidget),
        LabelValue(
          padding: EdgeInsets.only(
            left: paddingDefault,
            right: paddingDefault,
          ),
          label: Strings.of(context).overviewReportViewNumberOfBaits,
          value: _overview.totalBaits.toString(),
        ),
        VerticalSpace(paddingWidget),
      ],
    );
  }

  Widget _buildSpecies() {
    return ExpansionListItem(
      title: HeadingLabel(Strings.of(context).overviewReportViewSpecies),
      scrollController: widget.scrollController,
      children: [
        Chart<Species>(
          id: _catchesBySpeciesChartId,
          data: _overview.catchesPerSpecies,
          viewAllTitle: Strings.of(context).overviewReportViewViewSpecies,
          viewAllDescription: Strings.of(context)
              .overviewReportViewViewSpeciesDescription,
          onTapRow: (species) => push(context, CatchListPage(
            speciesIds: {species.id},
          )),
        ),
      ],
    );
  }

  Widget _buildFishingSpots() {
    if (!_hasFishingSpots) {
      return Empty();
    }

    return ExpansionListItem(
      title: HeadingLabel(Strings.of(context).overviewReportViewFishingSpots),
      scrollController: widget.scrollController,
      children: [
        Chart<FishingSpot>(
          id: _catchesByFishingSpotChartId,
          data: _overview.catchesPerFishingSpot,
          viewAllTitle: Strings.of(context).overviewReportViewViewFishingSpots,
          viewAllDescription: Strings.of(context)
              .overviewReportViewViewFishingSpotsDescription,
          onTapRow: (fishingSpot) => push(context, CatchListPage(
            fishingSpotIds: {fishingSpot.id},
          )),
        ),
      ],
    );
  }

  Widget _buildBaits() {
    if (!_hasBaits) {
      return Empty();
    }

    return ExpansionListItem(
      title: HeadingLabel(Strings.of(context).overviewReportViewBaits),
      scrollController: widget.scrollController,
      children: [
        Chart<Bait>(
          id: _catchesByBaitChartId,
          data: _overview.catchesPerBait,
          viewAllTitle: Strings.of(context).overviewReportViewViewBaits,
          viewAllDescription: Strings.of(context)
              .overviewReportViewViewBaitsDescription,
          onTapRow: (bait) => push(context, CatchListPage(
            baitIds: {bait.id},
          )),
        ),
      ],
    );
  }

  void _resetOverview() {
    _overview = OverviewReportViewData(
      appManager: AppManager.of(context),
      context: context,
      displayDateRange: _currentDateRange,
    );
  }
}

/// A class, that when instantiated, gathers all the data required to display
/// an overview of the user's log.
class OverviewReportViewData {
  final AppManager appManager;
  final Clock clock;
  final BuildContext context;
  final DisplayDateRange displayDateRange;

  DateRange _dateRange;

  // Catches
  int _msSinceLastCatch = 0;

  /// True if the date range of the report includes "now"; false otherwise.
  bool _isCurrentDate = true;

  /// Total number of catches within the given time period.
  int _totalCatches = 0;
  Map<Species, int> _catchesPerSpecies = {};

  /// Total number of fishing spots from which a catch was made within the
  /// given time period.
  int _fishingSpotsWithCatches = 0;
  Map<FishingSpot, int> _catchesPerFishingSpot = {};

  /// Total number of fishing spots from which a catch was made within the
  /// given time period.
  int _baitsWithCatches = 0;
  Map<Bait, int> _catchesPerBait = {};

  BaitManager get _baitManager => appManager.baitManager;
  CatchManager get _catchManager => appManager.catchManager;
  FishingSpotManager get _fishingSpotManager => appManager.fishingSpotManager;
  SpeciesManager get _speciesManager => appManager.speciesManager;

  DateRange get dateRange => _dateRange;
  bool get isCurrentDate => _isCurrentDate;
  int get msSinceLastCatch => _msSinceLastCatch;
  int get totalCatches => _totalCatches;
  Map<Species, int> get catchesPerSpecies => _catchesPerSpecies;

  int get totalFishingSpots => _fishingSpotsWithCatches;
  Map<FishingSpot, int> get catchesPerFishingSpot => _catchesPerFishingSpot;

  int get totalBaits => _baitsWithCatches;
  Map<Bait, int> get catchesPerBait => _catchesPerBait;

  OverviewReportViewData({
    this.appManager,
    this.clock = const Clock(),
    this.context,
    DisplayDateRange displayDateRange,
  }) : assert(appManager != null),
       assert(context != null),
       displayDateRange = displayDateRange ?? DisplayDateRange.allDates
  {
    DateTime now = clock.now();
    _dateRange = displayDateRange.getValue(clock.now());
    _isCurrentDate = _dateRange.endDate == now;

    List<Catch> catches = _catchManager.catchesSortedByTimestamp(context);
    _msSinceLastCatch = catches.isEmpty
        ? 0 : clock.now().millisecondsSinceEpoch - catches.first.timestamp;

    // Initialize all entities. We want to include everything, even ones with
    // no catches.
    _speciesManager.entityList()
        .forEach((species) => _catchesPerSpecies[species] = 0);
    _fishingSpotManager.entityList()
        .forEach((fishingSpot) => _catchesPerFishingSpot[fishingSpot] = 0);
    _baitManager.entityList().forEach((bait) => _catchesPerBait[bait] = 0);

    for (Catch cat in _catchManager.entityList()) {
      // Skip catches that don't fall within the desired time range.
      if (cat.timestamp < _dateRange.startMs
          || cat.timestamp > _dateRange.endMs)
      {
        continue;
      }

      _catchesPerSpecies[_speciesManager.entity(id: cat.speciesId)]++;
      _totalCatches++;

      if (_fishingSpotManager.entityExists(id: cat.fishingSpotId)) {
        _catchesPerFishingSpot[
            _fishingSpotManager.entity(id: cat.fishingSpotId)]++;
      }

      if (_baitManager.entityExists(id: cat.baitId)) {
        _catchesPerBait[_baitManager.entity(id: cat.baitId)]++;
      }
    }

    // Add up total catch count for other entities.
    _catchesPerFishingSpot.forEach((_, value) {
      if (value > 0) {
        _fishingSpotsWithCatches++;
      }
    });
    _catchesPerBait.forEach((_, value) {
      if (value > 0) {
        _baitsWithCatches++;
      }
    });

    // Sort all maps.
    _catchesPerSpecies = sortedMap<Species>(_catchesPerSpecies);
    _catchesPerFishingSpot = sortedMap<FishingSpot>(_catchesPerFishingSpot);
    _catchesPerBait = sortedMap<Bait>(_catchesPerBait);
  }
}