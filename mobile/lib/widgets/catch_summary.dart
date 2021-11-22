import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:protobuf/protobuf.dart';

import '../angler_manager.dart';
import '../bait_manager.dart';
import '../body_of_water_manager.dart';
import '../catch_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../method_manager.dart';
import '../named_entity_manager.dart';
import '../species_manager.dart';
import '../time_manager.dart';
import '../user_preference_manager.dart';
import '../utils/collection_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../water_clarity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:quiver/strings.dart';

import 'chart.dart';
import 'date_range_picker_input.dart';
import 'list_item.dart';
import 'list_picker_input.dart';
import 'view_catches_list.dart';
import 'widget.dart';

enum CatchSummarySortOrder {
  alphabetical,
  largestToSmallest,
}

/// A widget that shows a summary of the catches determined by [report].
class CatchSummary<T> extends StatefulWidget {
  final CatchSummaryReport<T> Function(DateRange, T?) reportBuilder;

  /// When not null, renders a [ListPickerInput] widget that allows the user
  /// to pick an instance of [T] from which to generate a new report.
  final CatchSummaryPicker<T>? picker;

  /// When true, the [DateRangePicker] is not shown.
  final bool isStatic;

  const CatchSummary({
    required this.reportBuilder,
    this.picker,
    this.isStatic = false,
  });

  CatchSummary.static({
    required CatchSummaryReport<T> report,
    this.picker,
  })  : reportBuilder = ((_, __) => report),
        isStatic = true;

  @override
  State<CatchSummary<T>> createState() => _CatchSummaryState<T>();
}

class _CatchSummaryState<T> extends State<CatchSummary<T>> {
  late CatchSummaryReport<T> _report;
  T? _entity;

  var _dateRange = DateRange(period: DateRange_Period.allDates);

  AnglerManager get _anglerManager => AnglerManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  CatchManager get _catchManager => CatchManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  MethodManager get _methodManager => MethodManager.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  WaterClarityManager get _waterClarityManager =>
      WaterClarityManager.of(context);

  @override
  void initState() {
    super.initState();
    _entity = widget.picker?.initialValue;
    _refreshReport();
  }

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder(
      managers: [
        _catchManager,
        _baitManager,
        _fishingSpotManager,
        _speciesManager,
      ],
      onAnyChange: _refreshReport,
      builder: (context) => Column(
        children: [
          _buildDateRangePicker(),
          _buildEntityPicker(),
          _buildViewCatches(),
          _buildSinceLastCatch(context),
          _buildCatchesPerSpecies(context),
          _buildCatchesPerFishingSpot(context),
          _buildCatchesPerBait(context),
          _buildCatchesPerMoonPhase(context),
          _buildCatchesPerTideType(context),
          _buildCatchesPerAngler(context),
          _buildCatchesPerBodyOfWater(context),
          _buildCatchesPerMethod(context),
          _buildCatchesPerPeriod(context),
          _buildCatchesPerSeason(context),
          _buildCatchesPerWaterClarity(context),
        ],
      ),
    );
  }

  Iterable<_CatchSummaryReportModel<T>> get _models => _report.models;

  Widget _buildDateRangePicker() {
    if (widget.isStatic) {
      return Empty();
    }

    return DateRangePickerInput(
      initialDateRange: _dateRange,
      onPicked: (dateRange) => setState(() {
        _dateRange = dateRange;
        _refreshReport();
      }),
    );
  }

  Widget _buildEntityPicker() {
    if (widget.picker == null || _entity == null) {
      return Empty();
    }

    return ListPickerInput(
      value: widget.picker!.nameBuilder(context, _entity!),
      onTap: () {
        push(
          context,
          widget.picker!.pickerBuilder(
            ManageableListPagePickerSettings<T>.single(
              initialValue: _entity,
              isRequired: true,
              onPicked: (context, entity) {
                if (entity != null && entity != _entity) {
                  setState(() {
                    _entity = entity;
                    _refreshReport();
                  });
                }
                return true;
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewCatches() {
    return ViewCatchesList(
        _models.map((e) => ViewCatchesListModel(e.catchIds, e.dateRange)));
  }

  Widget _buildSinceLastCatch(BuildContext context) {
    if (!_report.hasCatches || _report.isComparing || !_report.containsNow) {
      return Empty();
    }

    return ListItem(
      title: Text(Strings.of(context).reportSummarySinceLastCatch),
      trailing: Text(
        formatDuration(
          context: context,
          millisecondsDuration: _report.msSinceLastCatch,
          includesSeconds: false,
          condensed: true,
        ),
        style: styleSecondary(context),
      ),
    );
  }

  Widget _buildCatchesPerSpecies(BuildContext context) {
    if (!_report.hasPerSpecies) {
      return Empty();
    }

    return ExpandableChart<Species>(
      title: Strings.of(context).reportSummaryPerSpecies,
      viewAllTitle: Strings.of(context).reportSummaryViewSpecies,
      viewAllDescription:
          Strings.of(context).reportSummaryPerSpeciesDescription,
      filters: _report.filters(),
      labelBuilder: (species) => species.name,
      series: _report.toSeries<Species>((model) => model.perSpecies),
      rowDetailsPage: (species, dateRange) => _buildCatchList(
        dateRange,
        speciesIds: {species.id},
      ),
    );
  }

  Widget _buildCatchesPerFishingSpot(BuildContext context) {
    if (!_report.hasPerFishingSpot) {
      return Empty();
    }

    return ExpandableChart<FishingSpot>(
      title: Strings.of(context).reportSummaryPerFishingSpot,
      viewAllTitle: Strings.of(context).reportSummaryViewFishingSpots,
      viewAllDescription:
          Strings.of(context).reportSummaryPerFishingSpotDescription,
      filters: _report.filters(),
      labelBuilder: (fishingSpot) =>
          FishingSpotManager.of(context).displayName(context, fishingSpot),
      series: _report.toSeries<FishingSpot>((model) => model.perFishingSpot),
      rowDetailsPage: (fishingSpot, dateRange) => _buildCatchList(
        dateRange,
        fishingSpotIds: {fishingSpot.id},
      ),
    );
  }

  Widget _buildCatchesPerBait(BuildContext context) {
    if (!_report.hasPerBait) {
      return Empty();
    }

    return ExpandableChart<BaitAttachment>(
      title: Strings.of(context).reportSummaryPerBait,
      viewAllTitle: Strings.of(context).reportSummaryViewBaits,
      viewAllDescription: Strings.of(context).reportSummaryPerBaitDescription,
      filters: _report.filters(),
      labelBuilder: (attachment) =>
          _attachmentDisplayValue(context, attachment),
      series: _report.toSeries<BaitAttachment>((model) => model.perBait),
      rowDetailsPage: (baitAttachment, dateRange) => _buildCatchList(
        dateRange,
        baitAttachments: {baitAttachment},
      ),
    );
  }

  Widget _buildCatchesPerMoonPhase(BuildContext context) {
    if (!_report.hasPerMoonPhase) {
      return Empty();
    }

    return ExpandableChart<MoonPhase>(
      title: Strings.of(context).reportSummaryPerMoonPhase,
      viewAllTitle: Strings.of(context).reportSummaryViewMoonPhases,
      viewAllDescription:
          Strings.of(context).reportSummaryPerMoonPhaseDescription,
      filters: _report.filters(),
      labelBuilder: (moonPhase) => moonPhase.displayName(context),
      series: _report.toSeries<MoonPhase>((model) => model.perMoonPhase),
      rowDetailsPage: (moonPhase, dateRange) => _buildCatchList(
        dateRange,
        moonPhases: {moonPhase},
      ),
    );
  }

  Widget _buildCatchesPerTideType(BuildContext context) {
    if (!_report.hasPerTideType) {
      return Empty();
    }

    return ExpandableChart<TideType>(
      title: Strings.of(context).reportSummaryPerTideType,
      viewAllTitle: Strings.of(context).reportSummaryViewTides,
      viewAllDescription: Strings.of(context).reportSummaryPerTideDescription,
      filters: _report.filters(),
      labelBuilder: (tideType) => tideType.displayName(context),
      series: _report.toSeries<TideType>((model) => model.perTideType),
      rowDetailsPage: (tideType, dateRange) => _buildCatchList(
        dateRange,
        tideTypes: {tideType},
      ),
    );
  }

  Widget _buildCatchesPerAngler(BuildContext context) {
    if (!_report.hasPerAngler) {
      return Empty();
    }

    return ExpandableChart<Angler>(
      title: Strings.of(context).reportSummaryPerAngler,
      viewAllTitle: Strings.of(context).reportSummaryViewAnglers,
      viewAllDescription: Strings.of(context).reportSummaryPerAnglerDescription,
      filters: _report.filters(),
      labelBuilder: (angler) => _anglerManager.displayName(context, angler),
      series: _report.toSeries<Angler>((model) => model.perAngler),
      rowDetailsPage: (angler, dateRange) => _buildCatchList(
        dateRange,
        anglerIds: {angler.id},
      ),
    );
  }

  Widget _buildCatchesPerBodyOfWater(BuildContext context) {
    if (!_report.hasPerBodyOfWater) {
      return Empty();
    }

    return ExpandableChart<BodyOfWater>(
      title: Strings.of(context).reportSummaryPerBodyOfWater,
      viewAllTitle: Strings.of(context).reportSummaryViewBodiesOfWater,
      viewAllDescription:
          Strings.of(context).reportSummaryPerBodyOfWaterDescription,
      filters: _report.filters(),
      labelBuilder: (bodyOfWater) =>
          _bodyOfWaterManager.displayName(context, bodyOfWater),
      series: _report.toSeries<BodyOfWater>((model) => model.perBodyOfWater),
      rowDetailsPage: (bodyOfWater, dateRange) => _buildCatchList(
        dateRange,
        bodyOfWaterIds: {bodyOfWater.id},
      ),
    );
  }

  Widget _buildCatchesPerMethod(BuildContext context) {
    if (!_report.hasPerMethod) {
      return Empty();
    }

    return ExpandableChart<Method>(
      title: Strings.of(context).reportSummaryPerMethod,
      viewAllTitle: Strings.of(context).reportSummaryViewMethods,
      viewAllDescription: Strings.of(context).reportSummaryPerMethodDescription,
      filters: _report.filters(),
      labelBuilder: (method) => _methodManager.displayName(context, method),
      series: _report.toSeries<Method>((model) => model.perMethod),
      rowDetailsPage: (method, dateRange) => _buildCatchList(
        dateRange,
        methodIds: {method.id},
      ),
    );
  }

  Widget _buildCatchesPerPeriod(BuildContext context) {
    if (!_report.hasPerPeriod) {
      return Empty();
    }

    return ExpandableChart<Period>(
      title: Strings.of(context).reportSummaryPerPeriod,
      viewAllTitle: Strings.of(context).reportSummaryViewPeriods,
      viewAllDescription: Strings.of(context).reportSummaryPerPeriodDescription,
      filters: _report.filters(),
      labelBuilder: (period) => period.displayName(context),
      series: _report.toSeries<Period>((model) => model.perPeriod),
      rowDetailsPage: (period, dateRange) => _buildCatchList(
        dateRange,
        periods: {period},
      ),
    );
  }

  Widget _buildCatchesPerSeason(BuildContext context) {
    if (!_report.hasPerSeason) {
      return Empty();
    }

    return ExpandableChart<Season>(
      title: Strings.of(context).reportSummaryPerSeason,
      viewAllTitle: Strings.of(context).reportSummaryViewSeasons,
      viewAllDescription: Strings.of(context).reportSummaryPerSeasonDescription,
      filters: _report.filters(),
      labelBuilder: (moonPhase) => moonPhase.displayName(context),
      series: _report.toSeries<Season>((model) => model.perSeason),
      rowDetailsPage: (season, dateRange) => _buildCatchList(
        dateRange,
        seasons: {season},
      ),
    );
  }

  Widget _buildCatchesPerWaterClarity(BuildContext context) {
    if (!_report.hasPerWaterClarity) {
      return Empty();
    }

    return ExpandableChart<WaterClarity>(
      title: Strings.of(context).reportSummaryPerWaterClarity,
      viewAllTitle: Strings.of(context).reportSummaryViewWaterClarities,
      viewAllDescription:
          Strings.of(context).reportSummaryPerWaterClarityDescription,
      filters: _report.filters(),
      labelBuilder: (waterClarity) =>
          _waterClarityManager.displayName(context, waterClarity),
      series: _report.toSeries<WaterClarity>((model) => model.perWaterClarity),
      rowDetailsPage: (waterClarity, dateRange) => _buildCatchList(
        dateRange,
        waterClarityIds: {waterClarity.id},
      ),
    );
  }

  Widget _buildCatchList(
    DateRange dateRange, {
    Set<Id>? anglerIds,
    Set<BaitAttachment>? baitAttachments,
    Set<Id>? bodyOfWaterIds,
    Set<Id>? fishingSpotIds,
    Set<Id>? methodIds,
    Set<MoonPhase>? moonPhases,
    Set<Period>? periods,
    Set<Season>? seasons,
    Set<Id>? speciesIds,
    Set<TideType>? tideTypes,
    Set<Id>? waterClarityIds,
  }) {
    return CatchListPage(
      enableAdding: false,
      catches: _catchManager.catchesSortedByTimestamp(
        context,
        dateRange: dateRange,
        anglerIds: anglerIds ?? _report.anglerIds,
        baits: baitAttachments ?? _report.baits,
        bodyOfWaterIds: bodyOfWaterIds ?? _report.bodyOfWaterIds,
        fishingSpotIds: fishingSpotIds ?? _report.fishingSpotIds,
        methodIds: methodIds ?? _report.methodIds,
        moonPhases: moonPhases ?? _report.moonPhases,
        periods: periods ?? _report.periods,
        seasons: seasons ?? _report.seasons,
        speciesIds: speciesIds ?? _report.speciesIds,
        tideTypes: tideTypes ?? _report.tideTypes,
        waterClarityIds: waterClarityIds ?? _report.waterClarityIds,
      ),
    );
  }

  String _attachmentDisplayValue(
      BuildContext context, BaitAttachment attachment) {
    var value =
        BaitManager.of(context).attachmentDisplayValue(attachment, context);
    assert(isNotEmpty(value), "Cannot display a bait that doesn't exist");
    return value!;
  }

  void _refreshReport() => _report = widget.reportBuilder(_dateRange, _entity);
}

class CatchSummaryPicker<T> {
  /// A function that builds the picker widget. The given
  /// [ManageableListPagePickerSettings] should be used.
  final Widget Function(ManageableListPagePickerSettings<T>) pickerBuilder;

  final String Function(BuildContext, T) nameBuilder;
  final T? initialValue;

  CatchSummaryPicker({
    required this.pickerBuilder,
    required this.nameBuilder,
    this.initialValue,
  });
}

/// A class that, when instantiated, gathers all the data required to display
/// a report.
class CatchSummaryReport<T> {
  final BuildContext context;
  final CatchSummarySortOrder sortOrder;
  final bool isCatchAndReleaseOnly;
  final bool isFavoritesOnly;
  final List<DateRange> dateRanges = [
    DateRange(period: DateRange_Period.allDates),
  ];

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
  /// [BodyOfWater] IDs.
  final Set<Id> bodyOfWaterIds;

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

  final List<_CatchSummaryReportModel<T>> _models = [];
  int _msSinceLastCatch = 0;

  /// True if the date range of the report includes "now"; false otherwise.
  bool _containsNow = true;

  AnglerManager get _anglerManager => AnglerManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  CatchManager get _catchManager => CatchManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  MethodManager get _methodManager => MethodManager.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  TimeManager get _timeManager => TimeManager.of(context);

  WaterClarityManager get _waterClarityManager =>
      WaterClarityManager.of(context);

  Iterable<_CatchSummaryReportModel<T>> get models => List.of(_models);

  int get msSinceLastCatch => _msSinceLastCatch;

  bool get containsNow => _containsNow;

  bool get hasCatches =>
      _models.firstWhereOrNull((e) => e.catchIds.isNotEmpty) != null;

  bool get hasPerAngler =>
      _models.firstWhereOrNull((e) => e.perAngler.isNotEmpty) != null;

  bool get hasPerBait =>
      _models.firstWhereOrNull((e) => e.perBait.isNotEmpty) != null;

  bool get hasPerBodyOfWater =>
      _models.firstWhereOrNull((e) => e.perBodyOfWater.isNotEmpty) != null;

  bool get hasPerMethod =>
      _models.firstWhereOrNull((e) => e.perMethod.isNotEmpty) != null;

  bool get hasPerFishingSpot =>
      _models.firstWhereOrNull((e) => e.perFishingSpot.isNotEmpty) != null;

  bool get hasPerMoonPhase =>
      _models.firstWhereOrNull((e) => e.perMoonPhase.isNotEmpty) != null;

  bool get hasPerSeason =>
      _models.firstWhereOrNull((e) => e.perSeason.isNotEmpty) != null;

  bool get hasPerSpecies =>
      _models.firstWhereOrNull((e) => e.perSpecies.isNotEmpty) != null;

  bool get hasPerTideType =>
      _models.firstWhereOrNull((e) => e.perTideType.isNotEmpty) != null;

  bool get hasPerPeriod =>
      _models.firstWhereOrNull((e) => e.perPeriod.isNotEmpty) != null;

  bool get hasPerWaterClarity =>
      _models.firstWhereOrNull((e) => e.perWaterClarity.isNotEmpty) != null;

  bool get isComparing => _models.length > 1;

  CatchSummaryReport({
    required this.context,
    this.includeZeros = false,
    this.sortOrder = CatchSummarySortOrder.largestToSmallest,
    this.anglerIds = const {},
    this.baits = const {},
    this.fishingSpotIds = const {},
    this.bodyOfWaterIds = const {},
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
    this.isCatchAndReleaseOnly = false,
    this.isFavoritesOnly = false,
    Iterable<DateRange> ranges = const [],
  }) {
    if (ranges.isNotEmpty) {
      dateRanges.clear();
      dateRanges.addAll(ranges);
    }

    var now = _timeManager.currentDateTime;
    _containsNow =
        dateRanges.firstWhereOrNull((e) => e.endDate(now) == now) != null;

    for (var dateRange in dateRanges) {
      var catches = _catchManager.catchesSortedByTimestamp(
        context,
        dateRange: dateRange,
        isCatchAndReleaseOnly: isCatchAndReleaseOnly,
        isFavoritesOnly: isFavoritesOnly,
        anglerIds: anglerIds,
        baits: baits,
        fishingSpotIds: fishingSpotIds,
        bodyOfWaterIds: bodyOfWaterIds,
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

      _models.add(_CatchSummaryReportModel<T>(
        context: context,
        dateRange: dateRange,
        catches: catches,
        fillWithZeros: includeZeros,
      ));

      if (catches.isEmpty) {
        continue;
      }

      var sinceLast =
          _timeManager.msSinceEpoch - catches.first.timestamp.toInt();
      if (sinceLast < _msSinceLastCatch || _msSinceLastCatch == 0) {
        _msSinceLastCatch = sinceLast;
      }
    }
  }

  List<Series<E>> toSeries<E>(
      Map<E, int> Function(_CatchSummaryReportModel<T>) perEntity) {
    return _models
        .map((model) => Series<E>(perEntity(model), model.dateRange))
        .toList();
  }

  Set<String> filters({
    bool includeSpecies = true,
  }) {
    var result = <String>{};
    if (models.length == 1) {
      result.add(models.first.dateRange.displayName(context));
    }

    if (includeSpecies) {
      _addFilters<Species>(_speciesManager, speciesIds, result);
    }

    if (isCatchAndReleaseOnly) {
      result.add(Strings.of(context).saveReportPageCatchAndRelease);
    }

    if (isFavoritesOnly) {
      result.add(Strings.of(context).saveReportPageFavorites);
    }

    result.addAll(_baitManager.attachmentsDisplayValues(baits, context));
    _addFilters<FishingSpot>(_fishingSpotManager, fishingSpotIds, result);
    _addFilters<BodyOfWater>(_bodyOfWaterManager, bodyOfWaterIds, result);
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

  void _addFilters<E extends GeneratedMessage>(
      NamedEntityManager<E> manager, Set<Id> ids, Set<String> result) {
    result.addAll(
      ids
          .where((id) => manager.entity(id) != null)
          .map((id) => manager.name(manager.entity(id)!)),
    );
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

class _CatchSummaryReportModel<T> {
  final BuildContext context;
  final DateRange dateRange;

  final Set<Id> _catchIds = {};
  Map<Angler, int> _perAngler = {};
  Map<BaitAttachment, int> _perBait = {};
  Map<BodyOfWater, int> _perBodyOfWater = {};
  Map<Method, int> _perMethod = {};
  Map<FishingSpot, int> _perFishingSpot = {};
  Map<MoonPhase, int> _perMoonPhase = {};
  Map<Period, int> _perPeriod = {};
  Map<Season, int> _perSeason = {};
  Map<Species, int> _perSpecies = {};
  Map<TideType, int> _perTideType = {};
  Map<WaterClarity, int> _perWaterClarity = {};

  _CatchSummaryReportModel({
    required this.context,
    required this.dateRange,
    Iterable<Catch> catches = const [],
    bool fillWithZeros = false,
    CatchSummarySortOrder sortOrder = CatchSummarySortOrder.largestToSmallest,
  }) {
    if (fillWithZeros) {
      _fillCollectionsWithZeros();
    }

    _fillCollections(catches);
    _sortCollections(sortOrder);
  }

  AnglerManager get _anglerManager => AnglerManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  MethodManager get _methodManager => MethodManager.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  WaterClarityManager get _waterClarityManager =>
      WaterClarityManager.of(context);

  Set<Id> get catchIds => Set.of(_catchIds);

  Map<Angler, int> get perAngler => Map.of(_perAngler);

  Map<BaitAttachment, int> get perBait => Map.of(_perBait);

  Map<BodyOfWater, int> get perBodyOfWater => Map.of(_perBodyOfWater);

  Map<Method, int> get perMethod => Map.of(_perMethod);

  Map<FishingSpot, int> get perFishingSpot => Map.of(_perFishingSpot);

  Map<MoonPhase, int> get perMoonPhase => Map.of(_perMoonPhase);

  Map<Period, int> get perPeriod => Map.of(_perPeriod);

  Map<Season, int> get perSeason => Map.of(_perSeason);

  Map<Species, int> get perSpecies => Map.of(_perSpecies);

  Map<TideType, int> get perTideType => Map.of(_perTideType);

  Map<WaterClarity, int> get perWaterClarity => Map.of(_perWaterClarity);

  void _fillCollectionsWithZeros() {
    if (_includeBaits) {
      for (var bait in _baitManager.list()) {
        if (bait.variants.isEmpty) {
          _perBait.putIfAbsent(bait.toAttachment(), () => 0);
        } else {
          for (var variant in bait.variants) {
            _perBait.putIfAbsent(variant.toAttachment(), () => 0);
          }
        }
      }
    }

    _fillWithZeros(_includeAnglers, _anglerManager.list(), _perAngler);
    _fillWithZeros(
        _includeBodiesOfWater, _bodyOfWaterManager.list(), _perBodyOfWater);
    _fillWithZeros(_includeMethods, _methodManager.list(), _perMethod);
    _fillWithZeros(
        _includeFishingSpots, _fishingSpotManager.list(), _perFishingSpot);
    _fillWithZeros(_includeMoonPhases, MoonPhases.selectable(), _perMoonPhase);
    _fillWithZeros(_includePeriods, Periods.selectable(), _perPeriod);
    _fillWithZeros(_includeSeasons, Seasons.selectable(), _perSeason);
    _fillWithZeros(_includeSpecies, _speciesManager.list(), _perSpecies);
    _fillWithZeros(_includeTides, TideTypes.selectable(), _perTideType);
    _fillWithZeros(
        _includeWaterClarities, _waterClarityManager.list(), _perWaterClarity);
  }

  void _fillWithZeros<E>(bool include, Iterable<E> all, Map<E, int> sink) {
    if (!include) {
      return;
    }
    for (var item in all) {
      sink.putIfAbsent(item, () => 0);
    }
  }

  void _fillCollections(Iterable<Catch> catches) {
    for (var cat in catches) {
      _catchIds.add(cat.id);

      _inc(_includeAnglers, _anglerManager.entity(cat.anglerId), _perAngler);

      for (var attachment in cat.baits) {
        _inc(_includeBaits && _baitManager.entityExists(attachment.baitId),
            attachment, _perBait);
      }

      _inc(
        _includeBodiesOfWater,
        _bodyOfWaterManager.entity(
            _fishingSpotManager.entity(cat.fishingSpotId)?.bodyOfWaterId),
        _perBodyOfWater,
      );

      _inc(_includeFishingSpots, _fishingSpotManager.entity(cat.fishingSpotId),
          _perFishingSpot);

      for (var methodId in cat.methodIds) {
        _inc(_includeMethods, _methodManager.entity(methodId), _perMethod);
      }

      if (cat.hasAtmosphere() && cat.atmosphere.hasMoonPhase()) {
        _inc(_includeMoonPhases,
            MoonPhase.valueOf(cat.atmosphere.moonPhase.value), _perMoonPhase);
      }

      if (cat.hasPeriod()) {
        _inc(_includePeriods, Period.valueOf(cat.period.value), _perPeriod);
      }

      if (cat.hasSeason()) {
        _inc(_includeSeasons, Season.valueOf(cat.season.value), _perSeason);
      }

      _inc(_includeSpecies, _speciesManager.entity(cat.speciesId), _perSpecies);

      if (cat.hasTide() && cat.tide.hasType()) {
        _inc(
            _includeTides, TideType.valueOf(cat.tide.type.value), _perTideType);
      }

      _inc(_includeWaterClarities,
          _waterClarityManager.entity(cat.waterClarityId), _perWaterClarity);
    }
  }

  void _inc<E>(bool include, E? entity, Map<E, int> sink) {
    if (!include) {
      return;
    }

    if (entity != null) {
      sink.putIfAbsent(entity, () => 0);
      sink[entity] = sink[entity]! + 1;
    }
  }

  void _sortCollections(CatchSummarySortOrder sortOrder) {
    switch (sortOrder) {
      case CatchSummarySortOrder.alphabetical:
        _perAngler = sortedMap(_perAngler, _anglerManager.nameComparator);
        _perBait = sortedMap(_perBait, _baitManager.attachmentComparator);
        _perBodyOfWater =
            sortedMap(_perBodyOfWater, _bodyOfWaterManager.nameComparator);
        _perFishingSpot =
            sortedMap(_perFishingSpot, _fishingSpotManager.nameComparator);
        _perMethod = sortedMap(_perMethod, _methodManager.nameComparator);
        _perMoonPhase =
            sortedMap(_perMoonPhase, MoonPhases.nameComparator(context));
        _perPeriod = sortedMap(_perPeriod, Periods.nameComparator(context));
        _perSeason = sortedMap(_perSeason, Seasons.nameComparator(context));
        _perSpecies = sortedMap(_perSpecies, _speciesManager.nameComparator);
        _perTideType =
            sortedMap(_perTideType, TideTypes.nameComparator(context));
        _perWaterClarity =
            sortedMap(_perWaterClarity, _waterClarityManager.nameComparator);
        break;
      case CatchSummarySortOrder.largestToSmallest:
        _perAngler = sortedMap(_perAngler);
        _perBait = sortedMap(_perBait);
        _perBodyOfWater = sortedMap(_perBodyOfWater);
        _perFishingSpot = sortedMap(_perFishingSpot);
        _perMethod = sortedMap(_perMethod);
        _perMoonPhase = sortedMap(_perMoonPhase);
        _perPeriod = sortedMap(_perPeriod);
        _perSeason = sortedMap(_perSeason);
        _perSpecies = sortedMap(_perSpecies);
        _perTideType = sortedMap(_perTideType);
        _perWaterClarity = sortedMap(_perWaterClarity);
        break;
    }
  }

  /// Removes data if this model and [other] both have 0 values for a given
  /// data point. Data is removed from both this and [other].
  void removeZerosComparedTo(_CatchSummaryReportModel other) {
    _removeZeros(_perAngler, other._perAngler);
    _removeZeros(_perBait, other._perBait);
    _removeZeros(_perBodyOfWater, other._perBodyOfWater);
    _removeZeros(_perFishingSpot, other._perFishingSpot);
    _removeZeros(_perMethod, other._perMethod);
    _removeZeros(_perMoonPhase, other._perMoonPhase);
    _removeZeros(_perSeason, other._perPeriod);
    _removeZeros(_perSpecies, other._perSpecies);
    _removeZeros(_perTideType, other._perTideType);
    _removeZeros(_perWaterClarity, other._perWaterClarity);
  }

  void _removeZeros<E>(Map<E, int>? map1, Map<E, int>? map2) {
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

  bool get _includeAnglers =>
      T != Angler && _userPreferenceManager.isTrackingAnglers;

  bool get _includeBaits =>
      T != BaitAttachment && _userPreferenceManager.isTrackingBaits;

  bool get _includeBodiesOfWater => T != BodyOfWater;

  bool get _includeMethods =>
      T != Method && _userPreferenceManager.isTrackingMethods;

  bool get _includeFishingSpots =>
      T != FishingSpot && _userPreferenceManager.isTrackingFishingSpots;

  bool get _includeMoonPhases =>
      T != MoonPhase && _userPreferenceManager.isTrackingMoonPhases;

  bool get _includeSeasons =>
      T != Season && _userPreferenceManager.isTrackingSeasons;

  bool get _includeSpecies =>
      T != Species && _userPreferenceManager.isTrackingSpecies;

  bool get _includeTides => T != Tide && _userPreferenceManager.isTrackingTides;

  bool get _includePeriods =>
      T != Period && _userPreferenceManager.isTrackingPeriods;

  bool get _includeWaterClarities =>
      T != WaterClarity && _userPreferenceManager.isTrackingWaterClarities;
}
