import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/pages/bait_page.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/pages/fishing_spot_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/chart.dart';
import 'package:mobile/widgets/reports/report_view.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';
import 'package:quiver/time.dart';

/// A widget that includes all "summary" sections for a report.
class ReportSummary extends StatefulWidget {
  /// Returns an updated non-null, non-empty list of [ReportSummaryModel]
  /// objects. This method is called when the widget is initialized an updated.
  final List<ReportSummaryModel> Function() onUpdate;

  /// A list of [EntityManager] objects that trigger [ReportSummary] updates,
  /// in addition to the managers already handled in [ReportView].
  final List<EntityManager> managers;

  final String Function(BuildContext) descriptionBuilder;
  final Widget Function(BuildContext) headerBuilder;

  ReportSummary({
    @required this.onUpdate,
    this.managers = const [],
    this.descriptionBuilder,
    this.headerBuilder,
  }) : assert(onUpdate != null),
       assert(managers != null);

  @override
  _ReportSummaryState createState() => _ReportSummaryState();
}

class _ReportSummaryState extends State<ReportSummary> {
  /// The currently selected species in the species summary.
  Species _currentSpecies;

  List<ReportSummaryModel> _models = [];

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  bool get comparing => _models.length > 1;

  @override
  void initState() {
    super.initState();
    _updateModel();
  }

  @override
  void didUpdateWidget(ReportSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateModel();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (!_hasCatches) {
      children.addAll([
        MinDivider(),
        Padding(
          padding: insetsDefault,
          child: Align(
            alignment: Alignment.center,
            child: PrimaryLabel(
              Strings.of(context).reportViewNoCatches,
            ),
          ),
        ),
      ]);
    } else {
      children.addAll([
        HeadingDivider(Strings.of(context).reportSummaryCatchTitle),
        VerticalSpace(paddingWidget),
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
      ]);
    }

    return ReportView(
      managers: widget.managers,
      onUpdate: _updateModel,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDescription(),
          widget.headerBuilder?.call(context) ?? Empty(),
        ]..addAll(children),
      ),
    );
  }

  Widget _buildDescription() {
    String description = widget.descriptionBuilder?.call(context);
    if (isEmpty(description)) {
      return Empty();
    }

    return Padding(
      padding: insetsDefault,
      child: Label.multiline(description),
    );
  }

  Widget _buildCatchesPerSpecies() => ExpandableChart<Species>(
    title: Strings.of(context).reportSummaryPerSpecies,
    viewAllTitle: Strings.of(context).reportSummaryViewSpecies,
    viewAllDescription: Strings.of(context)
        .reportSummaryCatchesPerSpeciesDescription,
    filters: _filters(includeDateRange: !comparing),
    labelBuilder: (species) => species.name,
    series: _models.map((model) => Series<Species>(model.catchesPerSpecies,
        model.displayDateRange)).toList(),
    rowDetailsPage: (species, dateRange) => CatchListPage(
      enableAdding: false,
      dateRange: dateRange,
      baitIds: _models.first.baitIds,
      fishingSpotIds: _models.first.fishingSpotIds,
      speciesIds: {Id(species.id)},
    ),
  );

  Widget _buildCatchesPerFishingSpot() {
    if (!_hasCatchesPerFishingSpot) {
      return Empty();
    }

    return ExpandableChart<FishingSpot>(
      title: Strings.of(context).reportSummaryPerFishingSpot,
      viewAllTitle: Strings.of(context).reportSummaryViewFishingSpots,
      viewAllDescription: Strings.of(context)
          .reportSummaryCatchesPerFishingSpotDescription,
      filters: _filters(includeDateRange: !comparing),
      labelBuilder: (fishingSpot) => fishingSpot.name,
      series: _models.map((model) =>
          Series<FishingSpot>(model.catchesPerFishingSpot,
              model.displayDateRange)).toList(),
      rowDetailsPage: (fishingSpot, dateRange) => CatchListPage(
        enableAdding: false,
        dateRange: dateRange,
        baitIds: _models.first.baitIds,
        fishingSpotIds: {Id(fishingSpot.id)},
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
      viewAllDescription: Strings.of(context)
          .reportSummaryCatchesPerBaitDescription,
      filters: _filters(includeDateRange: !comparing),
      labelBuilder: (bait) => bait.name,
      series: _models.map((model) => Series<Bait>(model.catchesPerBait,
          model.displayDateRange)).toList(),
      rowDetailsPage: (bait, dateRange) => CatchListPage(
        enableAdding: false,
        dateRange: dateRange,
        baitIds: {Id(bait.id)},
        fishingSpotIds: _models.first.fishingSpotIds,
        speciesIds: _models.first.speciesIds,
      ),
    );
  }

  Widget _buildSinceLastCatch() {
    if (!_hasCatches || comparing || !_models.first.containsNow) {
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
        push(context, SpeciesListPage.picker(
          onPicked: (context, speciesId) {
            setState(() {
              _currentSpecies = _speciesManager.entity(speciesId.first);
            });
            return true;
          },
        ));
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
      viewAllDescription: Strings.of(context)
          .reportSummaryCatchesPerBaitDescription,
      filters: _filters(
        includeSpecies: false,
        includeDateRange: !comparing,
      )..add(_currentSpecies.name),
      labelBuilder: (bait) => bait.name,
      series: _models.map((model) => Series<Bait>(
          model.baitsPerSpecies(_currentSpecies),
          model.displayDateRange)).toList(),
      rowDetailsPage: (bait, _) => BaitPage(Id(bait.id), static: true),
    );
  }

  Widget _buildFishingSpotsPerSpecies() {
    if (!_hasFishingSpotsPerSpecies) {
      return Empty();
    }

    return ExpandableChart<FishingSpot>(
      title: Strings.of(context).reportSummaryPerFishingSpot,
      viewAllTitle: Strings.of(context).reportSummaryViewFishingSpots,
      viewAllDescription: Strings.of(context)
          .reportSummaryCatchesPerFishingSpotDescription,
      filters: _filters(
        includeSpecies: false,
        includeDateRange: !comparing,
      )..add(_currentSpecies.name),
      labelBuilder: (fishingSpot) => fishingSpot.name,
      series: _models.map((model) => Series<FishingSpot>(
          model.fishingSpotsPerSpecies(_currentSpecies),
          model.displayDateRange)).toList(),
      rowDetailsPage: (fishingSpot, _) => FishingSpotPage(Id(fishingSpot.id)),
    );
  }

  Widget _buildViewCatches() {
    return Column(
      children: _models.map((model) => _buildViewCatchesRow(model.allCatchIds,
          model.displayDateRange)).toList(),
    );
  }

  Widget _buildViewCatchesPerSpecies() {
    return Column(
      children: _models.map((model) => _buildViewCatchesRow(
          model.catchIdsPerSpecies[_currentSpecies],
          model.displayDateRange)).toList(),
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
      title: Text(format(Strings.of(context).reportSummaryViewCatches,
          [catchIds.length])),
      subtitle: Text(dateRange.title(context)),
      onTap: () => push(context, CatchListPage(
        enableAdding: false,
        catchIds: catchIds,
      )),
      trailing: RightChevronIcon(),
    );
  }

  void _updateModel() {
    _models = widget.onUpdate();
    assert(_models != null && _models.isNotEmpty);

    if (_currentSpecies == null && _models.first.catchesPerSpecies.isNotEmpty) {
      _currentSpecies = _models.first.catchesPerSpecies.keys.first;
    }
  }

  Set<String> _filters({
    bool includeSpecies = true,
    bool includeDateRange = true,
  }) => _models.fold<Set<String>>({}, (previousValue, element) =>
      previousValue..addAll(element.filters(
        includeSpecies: includeSpecies,
        includeDateRange: includeDateRange,
      )));

  bool get _hasCatches => _meets((model) => model.totalCatches > 0);

  bool get _hasCatchesPerFishingSpot => _meets((model) =>
      model.catchesPerFishingSpot.isNotEmpty);

  bool get _hasCatchesPerBait => _meets((model) =>
      model.catchesPerBait.isNotEmpty);

  bool get _hasBaitsPerSpecies => _meets((model) =>
      model.baitsPerSpecies(_currentSpecies).isNotEmpty);

  bool get _hasFishingSpotsPerSpecies => _meets((model) =>
      model.fishingSpotsPerSpecies(_currentSpecies).isNotEmpty);

  bool _meets(bool Function(ReportSummaryModel model) condition) =>
      _models.firstWhere((model) => condition(model), orElse: () => null)
          != null;
}

enum ReportSummaryModelSortOrder {
  alphabetical, largestToSmallest,
}

/// A class, that when instantiated, gathers all the data required to display
/// a [ReportSummary] widget.
class ReportSummaryModel {
  final AppManager appManager;
  final BuildContext context;
  final Clock clock;
  final DisplayDateRange displayDateRange;
  final ReportSummaryModelSortOrder sortOrder;

  /// When true, calculated collections include 0 quantities. Defaults to false.
  final bool includeZeros;

  /// When set, data is only included in this model if associated with these
  /// [Bait] IDs.
  final Set<Id> baitIds;

  /// When set, data is only included in this model if associated with these
  /// [FishingSpot] IDs.
  final Set<Id> fishingSpotIds;

  /// When set, data is only included in this model if associated with these
  /// [Species] IDs.
  final Set<Id> speciesIds;

  DateRange _dateRange;
  int _msSinceLastCatch = 0;

  /// True if the date range of the report includes "now"; false otherwise.
  bool _containsNow = true;

  /// All [Catch] IDs within [displayDateRange].
  Set<Id> _catchIds = {};
  Map<Species, Set<Id>> _catchIdsPerSpecies = {};
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
  Set<Id> get allCatchIds => _catchIds;
  Map<Species, Set<Id>> get catchIdsPerSpecies => _catchIdsPerSpecies;
  Map<Species, int> get catchesPerSpecies => _catchesPerSpecies;
  Map<FishingSpot, int> get catchesPerFishingSpot => _catchesPerFishingSpot;
  Map<Bait, int> get catchesPerBait => _catchesPerBait;

  Set<String> filters({
    bool includeSpecies = true,
    bool includeDateRange = true,
  }) {
    Set<String> result = {};
    if (includeDateRange) {
      result.add(displayDateRange.title(context));
    }

    if (includeSpecies) {
      result.addAll(speciesIds
          .map((id) => _speciesManager.entity(id)?.name)
          .toSet()
          ..removeWhere((e) => e == null));
    }

    result.addAll(baitIds
        .map((id) => _baitManager.entity(id)?.name)
        .toSet()
        ..removeWhere((e) => e == null));

    result.addAll(fishingSpotIds
        .map((id) => _fishingSpotManager.entity(id)?.name)
        .toSet()
        ..removeWhere((e) => e == null));

    return result;
  }

  Map<Bait, int> baitsPerSpecies(Species species) =>
      _baitsPerSpecies[species] ?? {};
  Map<FishingSpot, int> fishingSpotsPerSpecies(Species species) =>
      _fishingSpotsPerSpecies[species] ?? {};

  ReportSummaryModel({
    @required this.appManager,
    @required this.context,
    this.includeZeros = false,
    this.sortOrder = ReportSummaryModelSortOrder.largestToSmallest,
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
      dateRange: _dateRange,
      baitIds: baitIds,
      fishingSpotIds: fishingSpotIds,
      speciesIds: speciesIds,
    );

    _msSinceLastCatch = catches.isEmpty
        ? 0 : clock.now().millisecondsSinceEpoch - catches.first.timestamp.ms;

    // Fill all collections with zero quantities if necessary.
    if (includeZeros) {
      _speciesManager.list().forEach((species) {
        _catchesPerSpecies.putIfAbsent(species, () => 0);
        _fishingSpotsPerSpecies[species] = {};
        _baitsPerSpecies[species] = {};
      });
      _fishingSpotManager.list().forEach((fishingSpot) {
        _catchesPerFishingSpot.putIfAbsent(fishingSpot, () => 0);
        _fishingSpotsPerSpecies.value
            .forEach((species, map) => map[fishingSpot] = 0);
      });
      _baitManager.list().forEach((bait) {
        _catchesPerBait.putIfAbsent(bait, () => 0);
        _baitsPerSpecies.value.forEach((species, map) => map[bait] = 0);
      });
    }

    for (Catch cat in catches) {
      Species species = _speciesManager.entityFromPbId(cat.speciesId);
      _catchIdsPerSpecies.putIfAbsent(species, () => {});
      _catchIdsPerSpecies[species].add(Id(cat.id));
      _catchesPerSpecies.putIfAbsent(species, () => 0);
      _catchesPerSpecies[species]++;
      _catchIds.add(Id(cat.id));

      FishingSpot fishingSpot =
          _fishingSpotManager.entityFromPbId(cat.fishingSpotId);
      if (fishingSpot != null) {
        _catchesPerFishingSpot.putIfAbsent(fishingSpot, () => 0);
        _catchesPerFishingSpot[fishingSpot]++;
        _fishingSpotsPerSpecies.inc(species, fishingSpot);
      }

      Bait bait = _baitManager.entityFromPbId(cat.baitId);
      if (bait != null) {
        _catchesPerBait.putIfAbsent(bait, () => 0);
        _catchesPerBait[bait]++;
        _baitsPerSpecies.inc(species, bait);
      }
    }

    // Sort all maps.
    switch (sortOrder) {
      case ReportSummaryModelSortOrder.alphabetical:
        _catchesPerSpecies = sortedMap<Species>(_catchesPerSpecies,
            (lhs, rhs) => compareIgnoreCase(lhs.name, rhs.name));
        _catchesPerFishingSpot = sortedMap<FishingSpot>(_catchesPerFishingSpot,
            (lhs, rhs) => compareIgnoreCase(lhs.name, rhs.name));
        _catchesPerBait = sortedMap<Bait>(_catchesPerBait,
            (lhs, rhs) => compareIgnoreCase(lhs.name, rhs.name));
        _fishingSpotsPerSpecies = _fishingSpotsPerSpecies
            .sorted((lhs, rhs) => compareIgnoreCase(lhs.name, rhs.name));
        _baitsPerSpecies = _baitsPerSpecies
            .sorted((lhs, rhs) => compareIgnoreCase(lhs.name, rhs.name));
        break;
      case ReportSummaryModelSortOrder.largestToSmallest:
        _catchesPerSpecies = sortedMap<Species>(_catchesPerSpecies);
        _catchesPerFishingSpot = sortedMap<FishingSpot>(_catchesPerFishingSpot);
        _catchesPerBait = sortedMap<Bait>(_catchesPerBait);
        _fishingSpotsPerSpecies = _fishingSpotsPerSpecies.sorted();
        _baitsPerSpecies = _baitsPerSpecies.sorted();
        break;
    }
  }

  /// Removes data if this model and [other] both have 0 values for a given
  /// data point. Data is removed from both this and [other].
  void removeZerosComparedTo(ReportSummaryModel other) {
    _removeZeros(_catchesPerSpecies, other._catchesPerSpecies);
    _removeZeros(_catchesPerFishingSpot, other._catchesPerFishingSpot);
    _removeZeros(_catchesPerBait, other._catchesPerBait);

    for (Species key in _fishingSpotsPerSpecies.value.keys) {
      _removeZeros(_fishingSpotsPerSpecies[key],
          other._fishingSpotsPerSpecies[key]);
    }

    for (Species key in _baitsPerSpecies.value.keys) {
      _removeZeros(_baitsPerSpecies[key], other._baitsPerSpecies[key]);
    }
  }

  void _removeZeros<T>(Map<T, int> map1, Map<T, int> map2) {
    List<T> keys = map1.keys.toList();
    for (T key in keys) {
      if (!map1.containsKey(key) || !map2.containsKey(key)) {
        continue;
      }

      if (map1[key] == 0 && map2[key] == 0) {
        map1.remove(key);
        map2.remove(key);
      }
    }
  }
}

/// A utility class for keeping track of a map of mapped numbers, such as the
/// number of catches per bait per species.
class _MapOfMappedInt<K1, K2> {
  final Map<K1, Map<K2, int>> value = {};

  void inc(K1 key, K2 valueKey, [int incBy]) {
    value.putIfAbsent(key, () => {});
    value[key].putIfAbsent(valueKey, () => 0);
    value[key][valueKey] += incBy ?? 1;
  }

  Map<K2, int> operator [](K1 key) => value[key];
  void operator []=(K1 key, Map<K2, int> newValue) => value[key] = newValue;

  _MapOfMappedInt<K1, K2> sorted([int Function(K2 lhs, K2 rhs) comparator]) {
    var newValue = _MapOfMappedInt<K1, K2>();
    for (K1 key in value.keys) {
      newValue[key] = sortedMap(value[key], comparator);
    }
    return newValue;
  }
}