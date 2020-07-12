import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:quiver/time.dart';

/// A class, that when instantiated, gathers all the data required to display
/// an overview of the user's log.
class StatsOverviewData {
  final AppManager appManager;
  final Clock clock;
  final BuildContext context;
  final DisplayDateRange displayDateRange;

  final DateRange _dateRange;
  int _msSinceLastCatch = 0;
  int _totalCatches = 0;
  Map<Species, int> _catchesPerSpecies = {};

  int get msSinceLastCatch => _msSinceLastCatch;
  int get totalCatches => _totalCatches;
  Map<Species, int> get allCatchesPerSpecies => _catchesPerSpecies;

  CatchManager get _catchManager => appManager.catchManager;
  SpeciesManager get _speciesManager => appManager.speciesManager;

  StatsOverviewData({
    this.appManager,
    this.clock = const Clock(),
    this.context,
    this.displayDateRange,
  }) : assert(appManager != null),
       assert(context != null),
       assert(displayDateRange!= null),
       _dateRange = displayDateRange.getValue(clock.now())
  {
    Catch mostRecentCatch =
        _catchManager.catchesSortedByTimestamp(context).first;
    _msSinceLastCatch = mostRecentCatch == null
        ? 0 : clock.now().millisecondsSinceEpoch - mostRecentCatch.timestamp;

    _catchesPerSpecies = _calculateCatchesPerSpecies(_dateRange);
    _totalCatches = _catchesPerSpecies.values
        .fold(0, (previousValue, value) => previousValue + value);
  }

  /// Returns the number of catches per species. The resulting [Map] will not
  /// exceed [maxResultLength], and is sorted by highest to lowest [Species]
  /// quantity.
  Map<Species, int> catchesPerSpecies({int maxResultLength}) {
    if (maxResultLength == null) {
      return LinkedHashMap.from(_catchesPerSpecies);
    }

    Map<Species, int> result = {};
    _catchesPerSpecies.keys
        .toList()
        .sublist(0, min(_catchesPerSpecies.length, maxResultLength))
        .forEach((key) {
          result[key] = _catchesPerSpecies[key];
        });

    return result;
  }

  /// Returns a [Map], sorted by highest quantity first, of [Species] to catch
  /// quantity.
  Map<Species, int> _calculateCatchesPerSpecies(DateRange range) {
    Map<Species, int> quantityMap = {};

    // Initialize all species. We want to include all species, even ones with
    // no catches.
    _speciesManager.entityList
        .forEach((species) => quantityMap[species] = 0);

    // Count all species quantities.
    for (Catch cat in _catchManager.entityList) {
      // Skip catches that don't fall within the desired time range.
      if (cat.timestamp < range.startMs || cat.timestamp > range.endMs) {
        continue;
      }

      quantityMap[_speciesManager.entity(id: cat.speciesId)]++;
    }

    var sortedKeys = quantityMap.keys.toList()
        ..sort((lhs, rhs) => quantityMap[rhs].compareTo(quantityMap[lhs]));

    var sortedMap = LinkedHashMap<Species, int>();
    sortedKeys.forEach((key) => sortedMap[key] = quantityMap[key]);

    return sortedMap;
  }
}