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
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/chart.dart';
import 'package:mobile/widgets/date_range_picker_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/report_view.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/time.dart';

class OverviewReportView extends StatefulWidget {
  @override
  _OverviewReportViewState createState() => _OverviewReportViewState();
}

class _OverviewReportViewState extends State<OverviewReportView> {
  static const _chartIdCatchesPerSpecies = "catches_per_species";
  static const _chartIdCatchesPerFishingSpot = "catches_per_fishing_spot";
  static const _chartIdCatchesPerBait = "catches_per_bait";
  static const _chartIdFishingSpotsPerSpecies = "fishing_spots_per_species";
  static const _chartIdBaitPerSpecies = "baits_per_species";

  DisplayDateRange _currentDateRange =
      DisplayDateRange.of(DisplayDateRange.allDates.id);

  OverviewReportViewData _overview;
  Species _currentSpecies;

  bool get _hasCatches => _overview.totalCatches > 0;
  bool get _hasFishingSpots => _overview.catchesPerFishingSpot.isNotEmpty;
  bool get _hasBaits => _overview.catchesPerBait.isNotEmpty;

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
        _buildCatchSummary(),
        _buildSpeciesSummary(),
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

  Widget _buildCatchSummary() {
    return Column(
      children: [
        HeadingDivider(Strings.of(context).overviewReportViewSummary),
        VerticalSpace(paddingWidget),
        ListItem(
          title: Text(Strings.of(context).overviewReportViewNumberOfCatches),
          trailing: SecondaryLabel("${_overview.totalCatches}"),
        ),
        _hasCatches && _overview.containsNow ? ListItem(
          title: Text(Strings.of(context).overviewReportViewSinceLastCatch),
          trailing: SecondaryLabel(formatDuration(
            context: context,
            millisecondsDuration: _overview.msSinceLastCatch,
            includesSeconds: false,
            condensed: true,
          )),
        ) : Empty(),
        _buildCatchesPerSpecies(),
        _buildCatchesPerFishingSpot(),
        _buildCatchesPerBait(),
      ],
    );
  }

  Widget _buildCatchesPerSpecies() {
    return ExpansionListItem(
      title: Text(Strings.of(context).overviewReportViewSpecies),
      children: [
        Chart<Species>(
          id: _chartIdCatchesPerSpecies,
          data: _overview.catchesPerSpecies,
          viewAllTitle: Strings.of(context).overviewReportViewViewSpecies,
          viewAllDescription: Strings.of(context)
              .overviewReportViewViewSpeciesDescription,
          onTapRow: (species) => push(context, CatchListPage(
            dateRange: _overview.dateRange,
            speciesIds: {species.id},
          )),
        ),
        MinDivider(),
      ],
    );
  }

  Widget _buildCatchesPerFishingSpot() {
    if (!_hasFishingSpots) {
      return Empty();
    }

    return ExpansionListItem(
      title: Text(Strings.of(context).overviewReportViewFishingSpots),
      children: [
        Chart<FishingSpot>(
          id: _chartIdCatchesPerFishingSpot,
          data: _overview.catchesPerFishingSpot,
          viewAllTitle: Strings.of(context).overviewReportViewViewFishingSpots,
          viewAllDescription: Strings.of(context)
              .overviewReportViewViewFishingSpotsDescription,
          onTapRow: (fishingSpot) => push(context, CatchListPage(
            dateRange: _overview.dateRange,
            fishingSpotIds: {fishingSpot.id},
          )),
        ),
        MinDivider(),
      ],
    );
  }

  Widget _buildCatchesPerBait() {
    if (!_hasBaits) {
      return Empty();
    }

    return ExpansionListItem(
      title: Text(Strings.of(context).overviewReportViewBaits),
      children: [
        Chart<Bait>(
          id: _chartIdCatchesPerBait,
          data: _overview.catchesPerBait,
          viewAllTitle: Strings.of(context).overviewReportViewViewBaits,
          viewAllDescription: Strings.of(context)
              .overviewReportViewViewBaitsDescription,
          onTapRow: (bait) => push(context, CatchListPage(
            dateRange: _overview.dateRange,
            baitIds: {bait.id},
          )),
        ),
      ],
    );
  }
  
  Widget _buildSpeciesSummary() {
    return Column(
      children: [
        HeadingDivider(Strings.of(context).overviewReportViewSpeciesSummary),
        VerticalSpace(paddingWidget),
        _buildSpeciesPicker(),
        ListItem(
          title: Text(Strings.of(context).overviewReportViewNumberOfCatches),
          trailing: SecondaryLabel(
              "${_overview.catchesPerSpecies[_currentSpecies] ?? 0}"),
        ),
        _buildFishingSpotsPerSpecies(),
        _buildBaitsPerSpecies(),
      ],
    );
  }

  Widget _buildSpeciesPicker() {
    return ListPickerInput(
      value: _currentSpecies.name,
      onTap: () {
        push(context, SpeciesListPage.picker(
          onPicked: (context, pickedSpecies) {
            setState(() {
              _currentSpecies = pickedSpecies.first;
            });
            return true;
          },
        ));
      },
    );
  }

  Widget _buildBaitsPerSpecies() {
    Map<Bait, int> baits = _overview.baitsPerSpecies(_currentSpecies);
    if (baits.isEmpty) {
      return Empty();
    }

    return ExpansionListItem(
      title: Text(Strings.of(context).overviewReportViewBaits),
      children: [
        Chart<Bait>(
          id: _chartIdBaitPerSpecies,
          data: baits,
          viewAllTitle: Strings.of(context).overviewReportViewViewBaits,
          viewAllDescription: format(
            Strings.of(context).overviewReportViewBaitsPerSpeciesDescription,
            [_currentSpecies.name],
          ),
          // TODO
          onTapRow: (species) => print("show bait list"),
        ),
        MinDivider(),
      ],
    );
  }

  Widget _buildFishingSpotsPerSpecies() {
    Map<FishingSpot, int> fishingSpots =
        _overview.fishingSpotsPerSpecies(_currentSpecies);
    if (fishingSpots.isEmpty) {
      return Empty();
    }

    return ExpansionListItem(
      title: Text(Strings.of(context).overviewReportViewFishingSpots),
      children: [
        Chart<FishingSpot>(
          id: _chartIdFishingSpotsPerSpecies,
          data: fishingSpots,
          viewAllTitle: Strings.of(context).overviewReportViewViewFishingSpots,
          viewAllDescription: format(
            Strings.of(context)
                .overviewReportViewFishingSpotsPerSpeciesDescription,
            [_currentSpecies.name],
          ),
          // TODO
          onTapRow: (species) => print("show fishing spots map"),
        ),
        MinDivider(),
      ],
    );
  }

  void _resetOverview() {
    _overview = OverviewReportViewData(
      appManager: AppManager.of(context),
      context: context,
      displayDateRange: _currentDateRange,
    );

    if (_overview.catchesPerSpecies.isNotEmpty) {
      _currentSpecies = _overview.catchesPerSpecies.keys.first;
    }
  }
}

/// A class, that when instantiated, gathers all the data required to display
/// an overview of the user's log.
class OverviewReportViewData {
  final AppManager appManager;
  final BuildContext context;
  final Clock clock;
  final DisplayDateRange displayDateRange;

  DateRange _dateRange;
  int _msSinceLastCatch = 0;

  /// True if the date range of the report includes "now"; false otherwise.
  bool _containsNow = true;

  /// Total number of catches within [displayDateRange].
  int _totalCatches = 0;
  Map<Species, int> _catchesPerSpecies = {};

  /// Total number of catches per [FishingSpot].
  Map<FishingSpot, int> _catchesPerFishingSpot = {};

  /// Total number of catches made per fishing spot for each species within
  /// [displayDateRange].
  _MapOfMappedInt<Species, FishingSpot> _fishingSpotsPerSpecies =
      _MapOfMappedInt();

  /// Total number of catches per [Bait].
  Map<Bait, int> _catchesPerBait = {};

  /// Total number of catches made per bait for each species within
  /// [displayDateRange].
  _MapOfMappedInt<Species, Bait> _baitsPerSpecies = _MapOfMappedInt();

  BaitManager get _baitManager => appManager.baitManager;
  CatchManager get _catchManager => appManager.catchManager;
  FishingSpotManager get _fishingSpotManager => appManager.fishingSpotManager;
  SpeciesManager get _speciesManager => appManager.speciesManager;

  DateRange get dateRange => _dateRange;
  bool get containsNow => _containsNow;
  int get msSinceLastCatch => _msSinceLastCatch;
  int get totalCatches => _totalCatches;
  Map<Species, int> get catchesPerSpecies => _catchesPerSpecies;
  Map<FishingSpot, int> get catchesPerFishingSpot => _catchesPerFishingSpot;
  Map<Bait, int> get catchesPerBait => _catchesPerBait;

  Map<Bait, int> baitsPerSpecies(Species species) =>
      _baitsPerSpecies[species] ?? {};
  Map<FishingSpot, int> fishingSpotsPerSpecies(Species species) =>
      _fishingSpotsPerSpecies[species] ?? {};

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
    _dateRange = displayDateRange.getValue(now);
    _containsNow = _dateRange.endDate == now;

    List<Catch> catches = _catchManager.catchesSortedByTimestamp(context);
    _msSinceLastCatch = catches.isEmpty
        ? 0 : clock.now().millisecondsSinceEpoch - catches.first.timestamp;

    for (Catch cat in _catchManager.entityList()) {
      // Skip catches that don't fall within the desired time range.
      if (cat.timestamp < _dateRange.startMs
          || cat.timestamp > _dateRange.endMs)
      {
        continue;
      }

      Species species = _speciesManager.entity(id: cat.speciesId);
      _catchesPerSpecies.putIfAbsent(species, () => 0);
      _catchesPerSpecies[species]++;
      _totalCatches++;

      if (_fishingSpotManager.entityExists(id: cat.fishingSpotId)) {
        FishingSpot fishingSpot =
            _fishingSpotManager.entity(id: cat.fishingSpotId);
        _catchesPerFishingSpot.putIfAbsent(fishingSpot, () => 0);
        _catchesPerFishingSpot[fishingSpot]++;
        _fishingSpotsPerSpecies.inc(species, fishingSpot);
      }

      if (_baitManager.entityExists(id: cat.baitId)) {
        Bait bait = _baitManager.entity(id: cat.baitId);
        _catchesPerBait.putIfAbsent(bait, () => 0);
        _catchesPerBait[bait]++;
        _baitsPerSpecies.inc(species, bait);
      }
    }

    // Sort all maps.
    _catchesPerSpecies = sortedMap<Species>(_catchesPerSpecies);
    _catchesPerFishingSpot = sortedMap<FishingSpot>(_catchesPerFishingSpot);
    _catchesPerBait = sortedMap<Bait>(_catchesPerBait);
    _fishingSpotsPerSpecies = _fishingSpotsPerSpecies.sorted();
    _baitsPerSpecies = _baitsPerSpecies.sorted();
  }
}

/// A utility class for keeping track of a map of mapped numbers, such as the
/// number of catches per bait per species.
class _MapOfMappedInt<K1, K2> {
  final Map<K1, Map<K2, int>> value = {};

  void inc(K1 key, K2 valueKey) {
    value.putIfAbsent(key, () => {});
    value[key].putIfAbsent(valueKey, () => 0);
    value[key][valueKey]++;
  }

  Map<K2, int> operator [](K1 key) => value[key];
  void operator []=(K1 key, Map<K2, int> newValue) => value[key] = newValue;

  _MapOfMappedInt<K1, K2> sorted() {
    var newValue = _MapOfMappedInt<K1, K2>();
    for (K1 key in value.keys) {
      newValue[key] = sortedMap(value[key]);
    }
    return newValue;
  }
}