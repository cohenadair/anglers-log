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
import 'package:mobile/pages/bait_page.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/pages/fishing_spot_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/chart.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/time.dart';

/// A widget that includes all "summary" sections for a report.
class ReportSummary extends StatefulWidget {
  final ReportSummaryModel model;

  ReportSummary({
    @required this.model,
  }) : assert(model != null);

  @override
  _ReportSummary createState() => _ReportSummary();
}

class _ReportSummary extends State<ReportSummary> {
  /// The currently selected species in the species summary.
  Species _currentSpecies;

  ReportSummaryModel get _model => widget.model;

  @override
  void initState() {
    super.initState();
    _updateCurrentSpecies();
  }

  @override
  void didUpdateWidget(ReportSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateCurrentSpecies();
  }

  @override
  Widget build(BuildContext context) {
    if (_model.totalCatches <= 0) {
      return Column(
        children: [
          MinDivider(),
          Padding(
            padding: insetsDefault,
            child: PrimaryLabel(
              Strings.of(context).reportViewNoCatches,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        HeadingDivider(Strings.of(context).reportSummaryCatchTitle),
        VerticalSpace(paddingWidget),
        _buildViewCatches(_model.allCatchIds),
        _buildSinceLastCatch(),
        _buildCatchesPerSpecies(),
        _buildCatchesPerFishingSpot(),
        _buildCatchesPerBait(),
        HeadingDivider(Strings.of(context).reportSummarySpeciesTitle),
        VerticalSpace(paddingWidget),
        _buildSpeciesPicker(),
        _buildViewCatches(_model.catchIdsPerSpecies[_currentSpecies]),
        _buildFishingSpotsPerSpecies(),
        _buildBaitsPerSpecies(),
      ],
    );
  }

  Widget _buildCatchesPerSpecies() => ExpandableChart<Species>.singleSeries(
    title: Strings.of(context).reportSummaryPerSpecies,
    viewAllTitle: Strings.of(context).reportSummaryViewSpecies,
    viewAllDescription: Strings.of(context)
        .reportSummaryCatchesPerSpeciesDescription,
    filters: _model.filters,
    series: ChartSeries<Species>(_model.catchesPerSpecies),
    rowDetailsPage: (species) => CatchListPage(
      enableAdding: false,
      dateRange: _model.dateRange,
      speciesIds: {species.id},
    ),
  );

  Widget _buildCatchesPerFishingSpot() {
    if (_model.catchesPerFishingSpot.isEmpty) {
      return Empty();
    }

    return ExpandableChart<FishingSpot>.singleSeries(
      title: Strings.of(context).reportSummaryPerFishingSpot,
      viewAllTitle: Strings.of(context).reportSummaryViewFishingSpots,
      viewAllDescription: Strings.of(context)
          .reportSummaryCatchesPerFishingSpotDescription,
      filters: _model.filters,
      series: ChartSeries<FishingSpot>(_model.catchesPerFishingSpot),
      rowDetailsPage: (fishingSpot) => CatchListPage(
        enableAdding: false,
        dateRange: _model.dateRange,
        fishingSpotIds: {fishingSpot.id},
      ),
    );
  }

  Widget _buildCatchesPerBait() {
    if (_model.catchesPerBait.isEmpty) {
      return Empty();
    }

    return ExpandableChart<Bait>.singleSeries(
      title: Strings.of(context).reportSummaryPerBait,
      viewAllTitle: Strings.of(context).reportSummaryViewBaits,
      viewAllDescription: Strings.of(context)
          .reportSummaryCatchesPerBaitDescription,
      filters: _model.filters,
      series: ChartSeries<Bait>(_model.catchesPerBait),
      rowDetailsPage: (bait) => CatchListPage(
        enableAdding: false,
        dateRange: _model.dateRange,
        baitIds: {bait.id},
      ),
    );
  }

  Widget _buildSinceLastCatch() {
    if (_model.totalCatches <= 0 || !_model.containsNow) {
      return Empty();
    }

    return ListItem(
      title: Text(Strings.of(context).reportSummarySinceLastCatch),
      trailing: SecondaryLabel(formatDuration(
        context: context,
        millisecondsDuration: _model.msSinceLastCatch,
        includesSeconds: false,
        condensed: true,
      )),
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
    Map<Bait, int> baits = _model.baitsPerSpecies(_currentSpecies);
    if (baits.isEmpty) {
      return Empty();
    }

    return ExpandableChart<Bait>.singleSeries(
      title: Strings.of(context).reportSummaryPerBait,
      viewAllTitle: Strings.of(context).reportSummaryViewBaits,
      viewAllDescription: Strings.of(context)
          .reportSummaryCatchesPerBaitDescription,
      filters: _model.filters,
      series: ChartSeries<Bait>(_model.catchesPerBait),
      rowDetailsPage: (bait) => BaitPage(bait.id, static: true),
    );
  }

  Widget _buildFishingSpotsPerSpecies() {
    Map<FishingSpot, int> fishingSpots =
        _model.fishingSpotsPerSpecies(_currentSpecies);
    if (fishingSpots.isEmpty) {
      return Empty();
    }

    return ExpandableChart<FishingSpot>.singleSeries(
      title: Strings.of(context).reportSummaryPerFishingSpot,
      viewAllTitle: Strings.of(context).reportSummaryViewFishingSpots,
      viewAllDescription: Strings.of(context)
          .reportSummaryCatchesPerFishingSpotDescription,
      filters: _model.filters,
      series: ChartSeries<FishingSpot>(fishingSpots),
      rowDetailsPage: (fishingSpot) => FishingSpotPage(fishingSpot.id),
    );
  }

  Widget _buildViewCatches([Set<String> catchIds]) {
    catchIds = catchIds ?? {};

    if (catchIds.isEmpty) {
      return ListItem(
        title: Text(Strings.of(context).reportSummaryNumberOfCatches),
        trailing: SecondaryLabel("0"),
      );
    }

    return ListItem(
      title: Text(format(Strings.of(context).reportSummaryViewCatches,
          [catchIds.length])),
      onTap: () => push(context, CatchListPage(
        enableAdding: false,
        catchIds: catchIds,
      )),
      trailing: RightChevronIcon(),
    );
  }

  void _updateCurrentSpecies() {
    if (_model.catchesPerSpecies.isNotEmpty) {
      _currentSpecies = _model.catchesPerSpecies.keys.first;
    }
  }
}

/// A class, that when instantiated, gathers all the data required to display
/// a [ReportSummary] widget.
class ReportSummaryModel {
  final AppManager appManager;
  final BuildContext context;
  final Clock clock;
  final DisplayDateRange displayDateRange;

  /// When set, data is only included in this model if associated with these
  /// [Bait] IDs.
  final Set<String> baitIds;

  /// When set, data is only included in this model if associated with these
  /// [FishingSpot] IDs.
  final Set<String> fishingSpotIds;

  /// When set, data is only included in this model if associated with these
  /// [Species] IDs.
  final Set<String> speciesIds;

  DateRange _dateRange;
  int _msSinceLastCatch = 0;

  /// True if the date range of the report includes "now"; false otherwise.
  bool _containsNow = true;

  /// All [Catch] IDs within [displayDateRange].
  Set<String> _catchIds = {};
  Map<Species, Set<String>> _catchIdsPerSpecies = {};
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
  int get totalCatches => _catchIds.length;
  Set<String> get allCatchIds => _catchIds;
  Map<Species, Set<String>> get catchIdsPerSpecies => _catchIdsPerSpecies;
  Map<Species, int> get catchesPerSpecies => _catchesPerSpecies;
  Map<FishingSpot, int> get catchesPerFishingSpot => _catchesPerFishingSpot;
  Map<Bait, int> get catchesPerBait => _catchesPerBait;

  Set<String> get filters {
    Set<String> result = {};
    result.add(displayDateRange.title(context));
    result.addAll(speciesIds.map((id) => _speciesManager.entity(id: id).name).toSet());
    result.addAll(baitIds.map((id) => _baitManager.entity(id: id).name).toSet());
    result.addAll(fishingSpotIds.map((id) => _fishingSpotManager.entity(id: id).name).toSet());
    return result;
  }

  Map<Bait, int> baitsPerSpecies(Species species) =>
      _baitsPerSpecies[species] ?? {};
  Map<FishingSpot, int> fishingSpotsPerSpecies(Species species) =>
      _fishingSpotsPerSpecies[species] ?? {};

  ReportSummaryModel({
    @required this.appManager,
    @required this.context,
    this.clock = const Clock(),
    this.baitIds = const {},
    this.fishingSpotIds = const {},
    this.speciesIds = const {},
    DisplayDateRange displayDateRange,
  }) : assert(appManager != null),
       assert(context != null),
       assert(baitIds != null),
       assert(fishingSpotIds != null),
       assert(speciesIds != null),
       displayDateRange = displayDateRange ?? DisplayDateRange.allDates
  {
    DateTime now = clock.now();
    _dateRange = displayDateRange.getValue(now);
    _containsNow = _dateRange.endDate == now;

    List<Catch> catches = _catchManager.catchesSortedByTimestamp(
      context,
      baitIds: baitIds,
      fishingSpotIds: fishingSpotIds,
      speciesIds: speciesIds,
    );

    _msSinceLastCatch = catches.isEmpty
        ? 0 : clock.now().millisecondsSinceEpoch - catches.first.timestamp;

    for (Catch cat in catches) {
      // Skip catches that don't fall within the desired time range.
      if (cat.timestamp < _dateRange.startMs
          || cat.timestamp > _dateRange.endMs)
      {
        continue;
      }

      Species species = _speciesManager.entity(id: cat.speciesId);
      _catchIdsPerSpecies.putIfAbsent(species, () => {});
      _catchIdsPerSpecies[species].add(cat.id);
      _catchesPerSpecies.putIfAbsent(species, () => 0);
      _catchesPerSpecies[species]++;
      _catchIds.add(cat.id);

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