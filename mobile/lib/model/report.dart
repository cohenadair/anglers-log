import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../angler_manager.dart';
import '../app_manager.dart';
import '../bait_manager.dart';
import '../catch_manager.dart';
import '../fishing_spot_manager.dart';
import '../species_manager.dart';
import '../time_manager.dart';
import '../utils/collection_utils.dart';
import '../utils/date_time_utils.dart';
import 'gen/anglerslog.pb.dart';

enum ReportSortOrder {
  alphabetical,
  largestToSmallest,
}

/// A class that, when instantiated, gathers all the data required to display
/// a report.
class Report {
  final BuildContext context;
  final DisplayDateRange displayDateRange;
  final ReportSortOrder sortOrder;

  /// When true, calculated collections include 0 quantities. Defaults to false.
  final bool includeZeros;

  /// When set, data is only included in this model if associated with these
  /// [Angler] IDs.
  final Set<Id> anglerIds;

  /// When set, data is only included in this model if associated with these
  /// [Bait] IDs.
  final Set<Id> baitIds;

  /// When set, data is only included in this model if associated with these
  /// [FishingSpot] IDs.
  final Set<Id> fishingSpotIds;

  /// When set, data is only included in this model if associated with these
  /// [Species] IDs.
  final Set<Id> speciesIds;

  final AppManager _appManager;
  final TimeManager _timeManager;

  late DateRange _dateRange;
  int _msSinceLastCatch = 0;

  /// True if the date range of the report includes "now"; false otherwise.
  bool _containsNow = true;

  /// All [Catch] IDs within [displayDateRange].
  final Set<Id> _catchIds = {};
  final Map<Species, Set<Id>> _catchIdsPerSpecies = {};
  Map<Species, int> _catchesPerSpecies = {};

  /// Total number of catches per [FishingSpot].
  Map<FishingSpot, int> _catchesPerFishingSpot = {};

  /// Total number of catches made per fishing spot for each species within
  /// [displayDateRange].
  _MapOfMappedInt<Species?, FishingSpot> _fishingSpotsPerSpecies =
      _MapOfMappedInt();

  /// Total number of catches per [Bait].
  Map<Bait, int> _catchesPerBait = {};

  /// Total number of catches made per bait for each species within
  /// [displayDateRange].
  _MapOfMappedInt<Species?, Bait> _baitsPerSpecies = _MapOfMappedInt();

  AnglerManager get _anglerManager => _appManager.anglerManager;

  BaitManager get _baitManager => _appManager.baitManager;

  CatchManager get _catchManager => _appManager.catchManager;

  FishingSpotManager get _fishingSpotManager => _appManager.fishingSpotManager;

  SpeciesManager get _speciesManager => _appManager.speciesManager;

  DateRange get dateRange => _dateRange;

  bool get containsNow => _containsNow;

  int get msSinceLastCatch => _msSinceLastCatch;

  int get totalCatches => _catchIds.length;

  Set<Id> get allCatchIds => _catchIds;

  Map<Species, Set<Id>> get catchIdsPerSpecies => _catchIdsPerSpecies;

  Map<Species, int> get catchesPerSpecies => _catchesPerSpecies;

  Map<FishingSpot, int> get catchesPerFishingSpot => _catchesPerFishingSpot;

  Map<Bait, int> get catchesPerBait => _catchesPerBait;

  Map<Bait, int> baitsPerSpecies(Species? species) =>
      _baitsPerSpecies[species] ?? {};

  Map<FishingSpot, int> fishingSpotsPerSpecies(Species? species) =>
      _fishingSpotsPerSpecies[species] ?? {};

  Report({
    required this.context,
    this.includeZeros = false,
    this.sortOrder = ReportSortOrder.largestToSmallest,
    this.anglerIds = const {},
    this.baitIds = const {},
    this.fishingSpotIds = const {},
    this.speciesIds = const {},
    DisplayDateRange? displayDateRange,
  })  : _appManager = AppManager.of(context),
        _timeManager = AppManager.of(context).timeManager,
        displayDateRange = displayDateRange ?? DisplayDateRange.allDates {
    var now = _timeManager.currentDateTime;
    _dateRange = this.displayDateRange.getValue(now);
    _containsNow = _dateRange.endDate == now;

    var catches = _catchManager.catchesSortedByTimestamp(
      context,
      dateRange: _dateRange,
      anglerIds: anglerIds,
      baitIds: baitIds,
      fishingSpotIds: fishingSpotIds,
      speciesIds: speciesIds,
    );

    _msSinceLastCatch = catches.isEmpty
        ? 0
        : _timeManager.msSinceEpoch - catches.first.timestamp.toInt();

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

    for (var cat in catches) {
      _catchIds.add(cat.id);

      var species = _speciesManager.entity(cat.speciesId);
      if (species != null) {
        _catchIdsPerSpecies.putIfAbsent(species, () => {});
        _catchIdsPerSpecies[species]!.add(cat.id);
        _catchesPerSpecies.putIfAbsent(species, () => 0);
        _catchesPerSpecies[species] = _catchesPerSpecies[species]! + 1;
      }

      var fishingSpot = _fishingSpotManager.entity(cat.fishingSpotId);
      if (fishingSpot != null) {
        _catchesPerFishingSpot.putIfAbsent(fishingSpot, () => 0);
        _catchesPerFishingSpot[fishingSpot] =
            _catchesPerFishingSpot[fishingSpot]! + 1;
        _fishingSpotsPerSpecies.inc(species, fishingSpot);
      }

      var bait = _baitManager.entity(cat.baitId);
      if (bait != null) {
        _catchesPerBait.putIfAbsent(bait, () => 0);
        _catchesPerBait[bait] = _catchesPerBait[bait]! + 1;
        _baitsPerSpecies.inc(species, bait);
      }
    }

    // Sort all maps.
    switch (sortOrder) {
      case ReportSortOrder.alphabetical:
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
      case ReportSortOrder.largestToSmallest:
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
  void removeZerosComparedTo(Report other) {
    _removeZeros(_catchesPerSpecies, other._catchesPerSpecies);
    _removeZeros(_catchesPerFishingSpot, other._catchesPerFishingSpot);
    _removeZeros(_catchesPerBait, other._catchesPerBait);

    for (var key in _fishingSpotsPerSpecies.value.keys) {
      _removeZeros(
          _fishingSpotsPerSpecies[key], other._fishingSpotsPerSpecies[key]);
    }

    for (var key in _baitsPerSpecies.value.keys) {
      _removeZeros(_baitsPerSpecies[key], other._baitsPerSpecies[key]);
    }
  }

  void _removeZeros<T>(Map<T, int>? map1, Map<T, int>? map2) {
    if (map1 == null || map2 == null) {
      return;
    }

    var keys = map1.keys.toList();
    for (var key in keys) {
      if (!map1.containsKey(key) || !map2.containsKey(key)) {
        continue;
      }

      if (map1[key] == 0 && map2[key] == 0) {
        map1.remove(key);
        map2.remove(key);
      }
    }
  }

  Set<String> filters({
    bool includeSpecies = true,
    bool includeDateRange = true,
  }) {
    var result = <String>{};
    if (includeDateRange) {
      result.add(displayDateRange.title(context));
    }

    if (includeSpecies) {
      result.addAll(
        speciesIds
            .where((id) => _speciesManager.entity(id) != null)
            .map((id) => _speciesManager.entity(id)!.name)
            .toSet(),
      );
    }

    result.addAll(
      baitIds
          .where((id) => _baitManager.entity(id) != null)
          .map((id) => _baitManager.entity(id)!.name)
          .toSet(),
    );

    result.addAll(
      fishingSpotIds
          .where((id) => _fishingSpotManager.entity(id) != null)
          .map((id) => _fishingSpotManager.entity(id)!.name)
          .toSet(),
    );

    result.addAll(
      anglerIds
          .where((id) => _anglerManager.entity(id) != null)
          .map((id) => _anglerManager.entity(id)!.name)
          .toSet(),
    );

    return result;
  }
}

/// A utility class for keeping track of a map of mapped numbers, such as the
/// number of catches per bait per species.
class _MapOfMappedInt<K1, K2> {
  final Map<K1, Map<K2, int>> value = {};

  void inc(K1 key, K2 valueKey, [int? incBy]) {
    value.putIfAbsent(key, () => {});
    value[key]!.putIfAbsent(valueKey, () => 0);
    value[key]![valueKey] = value[key]![valueKey]! + (incBy ?? 1);
  }

  Map<K2, int>? operator [](K1 key) => value[key];

  void operator []=(K1 key, Map<K2, int> newValue) => value[key] = newValue;

  _MapOfMappedInt<K1, K2> sorted([int Function(K2 lhs, K2 rhs)? comparator]) {
    var newValue = _MapOfMappedInt<K1, K2>();
    for (var key in value.keys) {
      newValue[key] = sortedMap(value[key]!, comparator);
    }
    return newValue;
  }
}
