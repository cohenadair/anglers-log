import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/stats/report.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:quiver/time.dart';

/// A class, that when instantiated, gathers all the data required to display
/// an overview of the user's log.
class OverviewReport extends Report {
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

  OverviewReport({
    this.appManager,
    this.clock = const Clock(),
    this.context,
    this.displayDateRange,
  }) : assert(appManager != null),
       assert(context != null),
       assert(displayDateRange!= null)
  {
    DateTime now = clock.now();
    _dateRange = displayDateRange.getValue(clock.now());
    _isCurrentDate = _dateRange.endDate == now;

    List<Catch> catches = _catchManager.catchesSortedByTimestamp(context);
    _msSinceLastCatch = catches.isEmpty
        ? 0 : clock.now().millisecondsSinceEpoch - catches.first.timestamp;

    // Initialize all entities. We want to include everything, even ones with
    // no catches.
    _speciesManager.entityList
        .forEach((species) => _catchesPerSpecies[species] = 0);
    _fishingSpotManager.entityList
        .forEach((fishingSpot) => _catchesPerFishingSpot[fishingSpot] = 0);
    _baitManager.entityList.forEach((bait) => _catchesPerBait[bait] = 0);

    for (Catch cat in _catchManager.entityList) {
      // Skip catches that don't fall within the desired time range.
      if (cat.timestamp < _dateRange.startMs
          || cat.timestamp > _dateRange.endMs)
      {
        continue;
      }

      _catchesPerSpecies[_speciesManager.entity(id: cat.speciesId)]++;
      _totalCatches++;

      if (cat.hasFishingSpot) {
        _catchesPerFishingSpot[
            _fishingSpotManager.entity(id: cat.fishingSpotId)]++;
      }

      if (cat.hasBait) {
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