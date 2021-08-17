import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';

import '../angler_manager.dart';
import '../app_manager.dart';
import '../bait_manager.dart';
import '../catch_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../method_manager.dart';
import '../named_entity_manager.dart';
import '../species_manager.dart';
import '../time_manager.dart';
import '../utils/collection_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../water_clarity_manager.dart';
import 'gen/anglerslog.pb.dart';

enum CalculatedReportSortOrder {
  alphabetical,
  largestToSmallest,
}

/// A class that, when instantiated, gathers all the data required to display
/// a report.
class CalculatedReport {
  final BuildContext context;
  final DateRange dateRange;
  final CalculatedReportSortOrder sortOrder;

  /// When true, calculated collections include 0 quantities. Defaults to false.
  final bool includeZeros;

  /// When set, data is only included in this report if associated with these
  /// [Angler] IDs.
  final Set<Id> anglerIds;

  /// When set, data is only included in this report if associated with these
  /// [BaitAttachment] objects.
  final Set<BaitAttachment> baits;

  /// When set, data is only included in this report if associated with these
  /// [FishingSpot] IDs.
  final Set<Id> fishingSpotIds;

  /// When set, data is only included in this report if associated with these
  /// [Method] IDs.
  final Set<Id> methodIds;

  /// When set, data is only included in this report if associated with these
  /// [Species] IDs.
  final Set<Id> speciesIds;

  /// When set, data is only included in this report if associated with these
  /// [WaterClarity] IDs.
  final Set<Id> waterClarityIds;

  /// When set, data is only included in this report if associated with these
  /// [Period] objects.
  final Set<Period> periods;

  /// When set, data is only included in this report if associated with these
  /// [Season] objects.
  final Set<Season> seasons;

  /// When set, data is only included in this report if associated with these
  /// [Direction] objects.
  final Set<Direction> windDirections;

  /// When set, data is only included in this report if associated with these
  /// [SkyCondition] objects.
  final Set<SkyCondition> skyConditions;

  /// When set, data is only included in this report if associated with these
  /// [MoonPhase] objects.
  final Set<MoonPhase> moonPhases;

  /// When set, data is only included in this report if associated with these
  /// [TideType] objects.
  final Set<TideType> tideTypes;

  /// When not null, catches are only included in this report if the
  /// [Catch.waterDepth] falls within this filter.
  final NumberFilter? waterDepthFilter;

  /// When not null, catches are only included in this report if the
  /// [Catch.waterTemperature] falls within this filter.
  final NumberFilter? waterTemperatureFilter;

  /// When not null, catches are only included in this report if the
  /// [Catch.length] falls within this filter.
  final NumberFilter? lengthFilter;

  /// When not null, catches are only included in this report if the
  /// [Catch.weight] falls within this filter.
  final NumberFilter? weightFilter;

  /// When not null, catches are only included in this report if the
  /// [Catch.quantity] falls within this filter.
  final NumberFilter? quantityFilter;

  /// When not null, catches are only included in this report if the
  /// [Catch.atmosphere] falls within this filter.
  final NumberFilter? airTemperatureFilter;

  /// When not null, catches are only included in this report if the
  /// [Catch.atmosphere] falls within this filter.
  final NumberFilter? airPressureFilter;

  /// When not null, catches are only included in this report if the
  /// [Catch.atmosphere] falls within this filter.
  final NumberFilter? airHumidityFilter;

  /// When not null, catches are only included in this report if the
  /// [Catch.atmosphere] falls within this filter.
  final NumberFilter? airVisibilityFilter;

  /// When not null, catches are only included in this report if the
  /// [Catch.atmosphere] falls within this filter.
  final NumberFilter? windSpeedFilter;

  final AppManager _appManager;
  final TimeManager _timeManager;

  bool _isCatchAndReleaseOnly = false;
  bool _isFavoritesOnly = false;
  int _msSinceLastCatch = 0;

  /// True if the date range of the report includes "now"; false otherwise.
  bool _containsNow = true;

  /// All [Catch] IDs within [dateRange].
  final Set<Id> _catchIds = {};
  final Map<Species, Set<Id>> _catchIdsPerSpecies = {};
  Map<Species, int> _catchesPerSpecies = {};

  /// Total number of catches per [FishingSpot].
  Map<FishingSpot, int> _catchesPerFishingSpot = {};

  /// Total number of catches made per fishing spot for each species within
  /// [dateRange].
  _MapOfMappedInt<Species?, FishingSpot> _fishingSpotsPerSpecies =
      _MapOfMappedInt();

  /// Total number of catches per [Bait].
  Map<BaitAttachment, int> _catchesPerBait = {};

  /// Total number of catches made per bait for each species within
  /// [dateRange].
  _MapOfMappedInt<Species?, BaitAttachment> _baitsPerSpecies =
      _MapOfMappedInt();

  AnglerManager get _anglerManager => _appManager.anglerManager;

  BaitManager get _baitManager => _appManager.baitManager;

  CatchManager get _catchManager => _appManager.catchManager;

  FishingSpotManager get _fishingSpotManager => _appManager.fishingSpotManager;

  MethodManager get _methodManager => _appManager.methodManager;

  SpeciesManager get _speciesManager => _appManager.speciesManager;

  WaterClarityManager get _waterClarityManager =>
      _appManager.waterClarityManager;

  bool get containsNow => _containsNow;

  int get msSinceLastCatch => _msSinceLastCatch;

  int get totalCatches => _catchIds.length;

  Set<Id> get allCatchIds => _catchIds;

  Map<Species, Set<Id>> get catchIdsPerSpecies => _catchIdsPerSpecies;

  Map<Species, int> get catchesPerSpecies => _catchesPerSpecies;

  Map<FishingSpot, int> get catchesPerFishingSpot => _catchesPerFishingSpot;

  Map<BaitAttachment, int> get catchesPerBait => _catchesPerBait;

  Map<BaitAttachment, int> baitsPerSpecies(Species? species) =>
      _baitsPerSpecies[species] ?? {};

  Map<FishingSpot, int> fishingSpotsPerSpecies(Species? species) =>
      _fishingSpotsPerSpecies[species] ?? {};

  CalculatedReport({
    required this.context,
    this.includeZeros = false,
    this.sortOrder = CalculatedReportSortOrder.largestToSmallest,
    this.anglerIds = const {},
    this.baits = const {},
    this.fishingSpotIds = const {},
    this.methodIds = const {},
    this.speciesIds = const {},
    this.waterClarityIds = const {},
    this.periods = const {},
    this.seasons = const {},
    this.windDirections = const {},
    this.skyConditions = const {},
    this.moonPhases = const {},
    this.tideTypes = const {},
    this.waterDepthFilter,
    this.waterTemperatureFilter,
    this.lengthFilter,
    this.weightFilter,
    this.quantityFilter,
    this.airTemperatureFilter,
    this.airPressureFilter,
    this.airHumidityFilter,
    this.airVisibilityFilter,
    this.windSpeedFilter,
    DateRange? range,
    bool isCatchAndReleaseOnly = false,
    bool isFavoritesOnly = false,
  })  : _appManager = AppManager.of(context),
        _timeManager = AppManager.of(context).timeManager,
        dateRange = range ?? DateRange(period: DateRange_Period.allDates) {
    var now = _timeManager.currentDateTime;
    _containsNow = dateRange.endDate(now) == now;
    _isCatchAndReleaseOnly = isCatchAndReleaseOnly;
    _isFavoritesOnly = isFavoritesOnly;

    var catches = _catchManager.catchesSortedByTimestamp(
      context,
      dateRange: dateRange,
      isCatchAndReleaseOnly: _isCatchAndReleaseOnly,
      isFavoritesOnly: _isFavoritesOnly,
      anglerIds: anglerIds,
      baits: baits,
      fishingSpotIds: fishingSpotIds,
      methodIds: methodIds,
      speciesIds: speciesIds,
      waterClarityIds: waterClarityIds,
      periods: periods,
      seasons: seasons,
      windDirections: windDirections,
      skyConditions: skyConditions,
      moonPhases: moonPhases,
      tideTypes: tideTypes,
      waterDepthFilter: waterDepthFilter,
      waterTemperatureFilter: waterTemperatureFilter,
      lengthFilter: lengthFilter,
      weightFilter: weightFilter,
      quantityFilter: quantityFilter,
      airTemperatureFilter: airTemperatureFilter,
      airPressureFilter: airPressureFilter,
      airHumidityFilter: airHumidityFilter,
      airVisibilityFilter: airVisibilityFilter,
      windSpeedFilter: windSpeedFilter,
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
        setZero(BaitAttachment baitAttachment) {
          _catchesPerBait.putIfAbsent(baitAttachment, () => 0);
          _baitsPerSpecies.value
              .forEach((species, map) => map[baitAttachment] = 0);
        }

        if (bait.variants.isEmpty) {
          setZero(bait.toAttachment());
        } else {
          for (var variant in bait.variants) {
            setZero(variant.toAttachment());
          }
        }
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

      for (var baitAttachment in cat.baits) {
        _catchesPerBait.putIfAbsent(baitAttachment, () => 0);
        _catchesPerBait[baitAttachment] = _catchesPerBait[baitAttachment]! + 1;
        _baitsPerSpecies.inc(species, baitAttachment);
      }
    }

    // Sort all maps.
    switch (sortOrder) {
      case CalculatedReportSortOrder.alphabetical:
        _catchesPerSpecies = sortedMap<Species>(
            _catchesPerSpecies, _speciesManager.nameComparator);
        _catchesPerFishingSpot = sortedMap<FishingSpot>(
            _catchesPerFishingSpot, _fishingSpotManager.nameComparator);
        _catchesPerBait = sortedMap<BaitAttachment>(
            _catchesPerBait, _baitManager.attachmentComparator);
        _fishingSpotsPerSpecies =
            _fishingSpotsPerSpecies.sorted(_fishingSpotManager.nameComparator);
        _baitsPerSpecies =
            _baitsPerSpecies.sorted(_baitManager.attachmentComparator);
        break;
      case CalculatedReportSortOrder.largestToSmallest:
        _catchesPerSpecies = sortedMap<Species>(_catchesPerSpecies);
        _catchesPerFishingSpot = sortedMap<FishingSpot>(_catchesPerFishingSpot);
        _catchesPerBait = sortedMap<BaitAttachment>(_catchesPerBait);
        _fishingSpotsPerSpecies = _fishingSpotsPerSpecies.sorted();
        _baitsPerSpecies = _baitsPerSpecies.sorted();
        break;
    }
  }

  /// Removes data if this model and [other] both have 0 values for a given
  /// data point. Data is removed from both this and [other].
  void removeZerosComparedTo(CalculatedReport other) {
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
      result.add(dateRange.displayName(context));
    }

    if (includeSpecies) {
      _addFilters<Species>(_speciesManager, speciesIds, result);
    }

    if (_isCatchAndReleaseOnly) {
      result.add(Strings.of(context).saveReportPageCatchAndRelease);
    }

    if (_isFavoritesOnly) {
      result.add(Strings.of(context).saveReportPageFavorites);
    }

    result.addAll(_baitManager.attachmentsDisplayValues(baits, context));
    _addFilters<FishingSpot>(_fishingSpotManager, fishingSpotIds, result);
    _addFilters<Angler>(_anglerManager, anglerIds, result);
    _addFilters<Method>(_methodManager, methodIds, result);
    _addFilters<WaterClarity>(_waterClarityManager, waterClarityIds, result);

    result.addAll(periods.map((e) => e.displayName(context)));
    result.addAll(seasons.map((e) => e.displayName(context)));
    result.addAll(windDirections.map((e) => e.chipName(context)));
    result.addAll(skyConditions.map((e) => e.displayName(context)));
    result.addAll(moonPhases.map((e) => e.chipName(context)));
    result.addAll(tideTypes.map((e) => e.chipName(context)));

    _addNumberFilterIfNeeded(
        result, Strings.of(context).filterValueWaterDepth, waterDepthFilter);
    _addNumberFilterIfNeeded(
        result,
        Strings.of(context).filterValueWaterTemperature,
        waterTemperatureFilter);
    _addNumberFilterIfNeeded(
        result, Strings.of(context).filterValueLength, lengthFilter);
    _addNumberFilterIfNeeded(
        result, Strings.of(context).filterValueWeight, weightFilter);
    _addNumberFilterIfNeeded(
        result, Strings.of(context).filterValueQuantity, quantityFilter);
    _addNumberFilterIfNeeded(result,
        Strings.of(context).filterValueAirTemperature, airTemperatureFilter);
    _addNumberFilterIfNeeded(
        result, Strings.of(context).filterValueAirPressure, airPressureFilter);
    _addNumberFilterIfNeeded(
        result, Strings.of(context).filterValueAirHumidity, airHumidityFilter);
    _addNumberFilterIfNeeded(result,
        Strings.of(context).filterValueAirVisibility, airVisibilityFilter);
    _addNumberFilterIfNeeded(
        result, Strings.of(context).filterValueWindSpeed, windSpeedFilter);

    return result;
  }

  void _addNumberFilterIfNeeded(
      Set<String> filters, String text, NumberFilter? numberFilter) {
    if (numberFilter == null ||
        numberFilter.boundary == NumberBoundary.number_boundary_any) {
      return;
    }
    filters.add(format(text, [numberFilter.displayValue(context)]));
  }
}

void _addFilters<T extends GeneratedMessage>(
    NamedEntityManager<T> manager, Set<Id> ids, Set<String> result) {
  result.addAll(
    ids
        .where((id) => manager.entity(id) != null)
        .map((id) => manager.name(manager.entity(id)!)),
  );
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
