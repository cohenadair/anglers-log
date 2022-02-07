import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/pages/catch_page.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/text.dart';
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
import '../utils/date_time_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../water_clarity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:quiver/strings.dart';

import 'chart.dart';
import 'date_range_picker_input.dart';
import 'list_picker_input.dart';
import 'tile.dart';
import 'widget.dart';

enum CatchSummarySortOrder {
  alphabetical,
  largestToSmallest,
}

/// A widget that shows a summary of the catches determined by [report]. This
/// widget should always be rendered inside a [Scrollable] widget.
class CatchSummary<T> extends StatefulWidget {
  final CatchSummaryReport<T> Function(DateRange, T?) reportBuilder;

  /// When not null, renders a [ListPickerInput] widget that allows the user
  /// to pick an instance of [T] from which to generate a new report.
  final CatchSummaryPicker<T>? picker;

  /// When true, the [DateRangePicker] is not shown.
  final bool isStatic;

  const CatchSummary({
    Key? key,
    required this.reportBuilder,
    this.picker,
    this.isStatic = false,
  }) : super(key: key);

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
  void didUpdateWidget(CatchSummary<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshReport();
  }

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder(
      managers: [
        _anglerManager,
        _baitManager,
        _bodyOfWaterManager,
        _fishingSpotManager,
        _methodManager,
        _speciesManager,
        _waterClarityManager,
      ],
      onAnyChange: _refreshReport,
      builder: (context) => Column(
        children: [
          _buildDateRangePicker(),
          _buildEntityPicker(),
          const MinDivider(),
          const VerticalSpace(paddingDefault),
          _buildCatchesTiles(),
          const VerticalSpace(paddingDefault),
          _buildCatchesPerHour(),
          _buildCatchesPerMonth(),
          _buildCatchesPerSpecies(),
          _buildCatchesPerFishingSpot(),
          _buildCatchesPerBait(),
          _buildCatchesPerMoonPhase(),
          _buildCatchesPerTideType(),
          _buildCatchesPerAngler(),
          _buildCatchesPerBodyOfWater(),
          _buildCatchesPerMethod(),
          _buildCatchesPerPeriod(),
          _buildCatchesPerSeason(),
          _buildCatchesPerWaterClarity(),
          const VerticalSpace(paddingDefault),
        ],
      ),
    );
  }

  Iterable<_CatchSummaryReportModel<T>> get _models => _report.models;

  Widget _buildDateRangePicker() {
    if (widget.isStatic) {
      return const Empty();
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
      return const Empty();
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
                if (entity != _entity) {
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

  Widget _buildCatchesTiles() {
    var items = [
      _buildCatchesTileItem(_models.first),
    ];

    var rightItem = _buildRightTileItem();
    if (rightItem != null) {
      items.add(rightItem);
    }

    return TileRow(
      padding: insetsHorizontalDefault,
      items: items,
    );
  }

  TileItem _buildCatchesTileItem(_CatchSummaryReportModel model) {
    var quantity = model.catchIds.length;
    return TileItem(
      title: quantity.toString(),
      subtitle: quantity == 1
          ? Strings.of(context).entityNameCatch
          : Strings.of(context).entityNameCatches,
      subtitle2: model.dateRange.displayName(context),
      onTap: quantity <= 0
          ? null
          : () => push(
                context,
                _buildCatchList(
                  model.dateRange,
                  catchIds: model.catchIds,
                ),
              ),
    );
  }

  TileItem? _buildRightTileItem() {
    if (_report.isComparing) {
      // Show the number of catches in the second model.
      return _buildCatchesTileItem(_models.last);
    } else if (_report.containsNow) {
      // If we're not comparing, and the current date contains now (such as
      // "this year"), show the time since the last catch was made.
      return TileItem.duration(
        context,
        msDuration: _report.msSinceLastCatch,
        subtitle: Strings.of(context).reportSummarySinceLastCatch,
        onTap: _report.hasLastCatch
            ? () => push(context, CatchPage(_report.lastCatch!))
            : null,
      );
    }

    return null;
  }

  Widget _buildCatchesPerEntity<E>({
    required String title,
    required String viewAllTitle,
    required String viewAllDescription,
    required List<Series<E>> series,
    List<Series<E>>? fullPageSeries,
    required Widget Function(E, DateRange) catchListBuilder,
    required String Function(E) labelBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const VerticalSpace(paddingDefault),
        TitleLabel.style2(title),
        const VerticalSpace(paddingDefault),
        Chart<E>(
          series: series,
          fullPageSeries: fullPageSeries,
          padding: insetsHorizontalDefaultBottomSmall,
          viewAllTitle: viewAllTitle,
          chartPageDescription: viewAllDescription,
          chartPageFilters: _report.filters(),
          onTapRow: (entity, dateRange) =>
              push(context, catchListBuilder(entity, dateRange)),
          labelBuilder: labelBuilder,
        ),
      ],
    );
  }

  Widget _buildCatchesPerHour() {
    return _buildCatchesPerEntity<int>(
      title: Strings.of(context).reportSummaryPerHour,
      viewAllTitle: Strings.of(context).reportSummaryViewAllHours,
      viewAllDescription:
          Strings.of(context).reportSummaryViewAllHoursDescription,
      series: _report.toSeries<int>((model) => model.perHour),
      fullPageSeries:
          _report.toSeries<int>((model) => sortedMapByIntKey(model.perHour)),
      labelBuilder: (hour) => formatHourRange(context, hour, hour + 1),
      catchListBuilder: (hour, dateRange) => _buildCatchList(
        dateRange,
        hour: hour,
      ),
    );
  }

  Widget _buildCatchesPerMonth() {
    return _buildCatchesPerEntity<int>(
      title: Strings.of(context).reportSummaryPerMonth,
      viewAllTitle: Strings.of(context).reportSummaryViewAllMonths,
      viewAllDescription:
          Strings.of(context).reportSummaryViewAllMonthsDescription,
      series: _report.toSeries<int>((model) => model.perMonth),
      fullPageSeries:
          _report.toSeries<int>((model) => sortedMapByIntKey(model.perMonth)),
      labelBuilder: (month) =>
          DateFormat(monthFormat).format(DateTime(0, month)),
      catchListBuilder: (month, dateRange) => _buildCatchList(
        dateRange,
        month: month,
      ),
    );
  }

  Widget _buildCatchesPerSpecies() {
    if (!_report.hasPerSpecies) {
      return const Empty();
    }

    return _buildCatchesPerEntity<Species>(
      title: Strings.of(context).reportSummaryPerSpecies,
      viewAllTitle: Strings.of(context).reportSummaryViewSpecies,
      viewAllDescription:
          Strings.of(context).reportSummaryPerSpeciesDescription,
      series: _report.toSeries<Species>((model) => model.perSpecies),
      labelBuilder: (entity) => _speciesManager.displayName(context, entity),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        speciesIds: {entity.id},
      ),
    );
  }

  Widget _buildCatchesPerFishingSpot() {
    if (!_report.hasPerFishingSpot) {
      return const Empty();
    }

    return _buildCatchesPerEntity<FishingSpot>(
      title: Strings.of(context).reportSummaryPerFishingSpot,
      viewAllTitle: Strings.of(context).reportSummaryViewFishingSpots,
      viewAllDescription:
          Strings.of(context).reportSummaryPerFishingSpotDescription,
      series: _report.toSeries<FishingSpot>((model) => model.perFishingSpot),
      labelBuilder: (entity) => _fishingSpotManager.displayName(
        context,
        entity,
        includeBodyOfWater: true,
      ),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        fishingSpotIds: {entity.id},
      ),
    );
  }

  Widget _buildCatchesPerBait() {
    if (!_report.hasPerBait) {
      return const Empty();
    }

    return _buildCatchesPerEntity<BaitAttachment>(
      title: Strings.of(context).reportSummaryPerBait,
      viewAllTitle: Strings.of(context).reportSummaryViewBaits,
      viewAllDescription: Strings.of(context).reportSummaryPerBaitDescription,
      series: _report.toSeries<BaitAttachment>((model) => model.perBait),
      labelBuilder: (entity) => _attachmentDisplayValue(entity),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        baitAttachments: {entity},
      ),
    );
  }

  Widget _buildCatchesPerMoonPhase() {
    if (!_report.hasPerMoonPhase) {
      return const Empty();
    }

    return _buildCatchesPerEntity<MoonPhase>(
      title: Strings.of(context).reportSummaryPerMoonPhase,
      viewAllTitle: Strings.of(context).reportSummaryViewMoonPhases,
      viewAllDescription:
          Strings.of(context).reportSummaryPerMoonPhaseDescription,
      series: _report.toSeries<MoonPhase>((model) => model.perMoonPhase),
      labelBuilder: (entity) => entity.displayName(context),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        moonPhases: {entity},
      ),
    );
  }

  Widget _buildCatchesPerTideType() {
    if (!_report.hasPerTideType) {
      return const Empty();
    }

    return _buildCatchesPerEntity<TideType>(
      title: Strings.of(context).reportSummaryPerTideType,
      viewAllTitle: Strings.of(context).reportSummaryViewTides,
      viewAllDescription: Strings.of(context).reportSummaryPerTideDescription,
      series: _report.toSeries<TideType>((model) => model.perTideType),
      labelBuilder: (entity) => entity.displayName(context),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        tideTypes: {entity},
      ),
    );
  }

  Widget _buildCatchesPerAngler() {
    if (!_report.hasPerAngler) {
      return const Empty();
    }

    return _buildCatchesPerEntity<Angler>(
      title: Strings.of(context).reportSummaryPerAngler,
      viewAllTitle: Strings.of(context).reportSummaryViewAnglers,
      viewAllDescription: Strings.of(context).reportSummaryPerAnglerDescription,
      series: _report.toSeries<Angler>((model) => model.perAngler),
      labelBuilder: (entity) => _anglerManager.displayName(context, entity),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        anglerIds: {entity.id},
      ),
    );
  }

  Widget _buildCatchesPerBodyOfWater() {
    if (!_report.hasPerBodyOfWater) {
      return const Empty();
    }

    return _buildCatchesPerEntity<BodyOfWater>(
      title: Strings.of(context).reportSummaryPerBodyOfWater,
      viewAllTitle: Strings.of(context).reportSummaryViewBodiesOfWater,
      viewAllDescription:
          Strings.of(context).reportSummaryPerBodyOfWaterDescription,
      series: _report.toSeries<BodyOfWater>((model) => model.perBodyOfWater),
      labelBuilder: (entity) =>
          _bodyOfWaterManager.displayName(context, entity),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        bodyOfWaterIds: {entity.id},
      ),
    );
  }

  Widget _buildCatchesPerMethod() {
    if (!_report.hasPerMethod) {
      return const Empty();
    }

    return _buildCatchesPerEntity<Method>(
      title: Strings.of(context).reportSummaryPerMethod,
      viewAllTitle: Strings.of(context).reportSummaryViewMethods,
      viewAllDescription: Strings.of(context).reportSummaryPerMethodDescription,
      series: _report.toSeries<Method>((model) => model.perMethod),
      labelBuilder: (entity) => _methodManager.displayName(context, entity),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        methodIds: {entity.id},
      ),
    );
  }

  Widget _buildCatchesPerPeriod() {
    if (!_report.hasPerPeriod) {
      return const Empty();
    }

    return _buildCatchesPerEntity<Period>(
      title: Strings.of(context).reportSummaryPerPeriod,
      viewAllTitle: Strings.of(context).reportSummaryViewPeriods,
      viewAllDescription: Strings.of(context).reportSummaryPerPeriodDescription,
      series: _report.toSeries<Period>((model) => model.perPeriod),
      labelBuilder: (entity) => entity.displayName(context),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        periods: {entity},
      ),
    );
  }

  Widget _buildCatchesPerSeason() {
    if (!_report.hasPerSeason) {
      return const Empty();
    }

    return _buildCatchesPerEntity<Season>(
      title: Strings.of(context).reportSummaryPerSeason,
      viewAllTitle: Strings.of(context).reportSummaryViewSeasons,
      viewAllDescription: Strings.of(context).reportSummaryPerSeasonDescription,
      series: _report.toSeries<Season>((model) => model.perSeason),
      labelBuilder: (entity) => entity.displayName(context),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        seasons: {entity},
      ),
    );
  }

  Widget _buildCatchesPerWaterClarity() {
    if (!_report.hasPerWaterClarity) {
      return const Empty();
    }

    return _buildCatchesPerEntity<WaterClarity>(
      title: Strings.of(context).reportSummaryPerWaterClarity,
      viewAllTitle: Strings.of(context).reportSummaryViewWaterClarities,
      viewAllDescription:
          Strings.of(context).reportSummaryPerWaterClarityDescription,
      series: _report.toSeries<WaterClarity>((model) => model.perWaterClarity),
      labelBuilder: (entity) =>
          _waterClarityManager.displayName(context, entity),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        waterClarityIds: {entity.id},
      ),
    );
  }

  Widget _buildCatchList(
    DateRange dateRange, {
    Set<Id>? anglerIds,
    Set<BaitAttachment>? baitAttachments,
    Set<Id>? bodyOfWaterIds,
    Set<Id>? catchIds,
    Set<Id>? fishingSpotIds,
    Set<Id>? methodIds,
    Set<MoonPhase>? moonPhases,
    Set<Period>? periods,
    Set<Season>? seasons,
    Set<Id>? speciesIds,
    Set<TideType>? tideTypes,
    Set<Id>? waterClarityIds,
    int? hour,
    int? month,
  }) {
    return CatchListPage(
      enableAdding: false,
      catches: _catchManager.catches(
        context,
        dateRange: dateRange,
        anglerIds: anglerIds ?? _report.anglerIds,
        baits: baitAttachments ?? _report.baits,
        bodyOfWaterIds: bodyOfWaterIds ?? _report.bodyOfWaterIds,
        catchIds: catchIds ?? const {},
        fishingSpotIds: fishingSpotIds ?? _report.fishingSpotIds,
        methodIds: methodIds ?? _report.methodIds,
        moonPhases: moonPhases ?? _report.moonPhases,
        periods: periods ?? _report.periods,
        seasons: seasons ?? _report.seasons,
        speciesIds: speciesIds ?? _report.speciesIds,
        tideTypes: tideTypes ?? _report.tideTypes,
        waterClarityIds: waterClarityIds ?? _report.waterClarityIds,
        hour: hour,
        month: month,
      ),
    );
  }

  String _attachmentDisplayValue(BaitAttachment attachment) {
    var value = _baitManager.attachmentDisplayValue(context, attachment);
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
  Catch? _lastCatch;

  /// True if the date range of the report includes "now"; false otherwise.
  late final bool containsNow;

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

  Catch? get lastCatch => _lastCatch?.deepCopy();

  bool get hasLastCatch => _lastCatch != null;

  bool get hasCatches => _models.containsWhere((e) => e.catchIds.isNotEmpty);

  bool get hasPerAngler => _models.containsWhere((e) => e.perAngler.isNotEmpty);

  bool get hasPerBait => _models.containsWhere((e) => e.perBait.isNotEmpty);

  bool get hasPerBodyOfWater =>
      _models.containsWhere((e) => e.perBodyOfWater.isNotEmpty);

  bool get hasPerMethod => _models.containsWhere((e) => e.perMethod.isNotEmpty);

  bool get hasPerFishingSpot =>
      _models.containsWhere((e) => e.perFishingSpot.isNotEmpty);

  bool get hasPerMoonPhase =>
      _models.containsWhere((e) => e.perMoonPhase.isNotEmpty);

  bool get hasPerSeason => _models.containsWhere((e) => e.perSeason.isNotEmpty);

  bool get hasPerSpecies =>
      _models.containsWhere((e) => e.perSpecies.isNotEmpty);

  bool get hasPerTideType =>
      _models.containsWhere((e) => e.perTideType.isNotEmpty);

  bool get hasPerPeriod => _models.containsWhere((e) => e.perPeriod.isNotEmpty);

  bool get hasPerWaterClarity =>
      _models.containsWhere((e) => e.perWaterClarity.isNotEmpty);

  bool get isComparing => dateRanges.length > 1;

  int get msSinceLastCatch => _msSinceLastCatch;

  CatchSummaryReport({
    required this.context,
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
    containsNow = dateRanges.containsWhere((e) => e.endDate(now) == now);

    for (var dateRange in dateRanges) {
      var catches = _catchManager.catches(
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
      ));

      if (catches.isEmpty || isComparing) {
        continue;
      }

      // Initialize properties that only apply when not comparing.
      _lastCatch = catches.first;
      _msSinceLastCatch =
          _timeManager.msSinceEpoch - _lastCatch!.timestamp.toInt();
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
      result.add(Strings.of(context).saveReportPageCatchAndReleaseFilter);
    }

    if (isFavoritesOnly) {
      result.add(Strings.of(context).saveReportPageFavoritesFilter);
    }

    result.addAll(_baitManager.attachmentsDisplayValues(context, baits));
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

  final Set<Id> catchIds = {};
  final Map<int, int> perHour = {};
  final Map<int, int> perMonth = {};
  final Map<Angler, int> perAngler = {};
  final Map<BaitAttachment, int> perBait = {};
  final Map<BodyOfWater, int> perBodyOfWater = {};
  final Map<Method, int> perMethod = {};
  final Map<FishingSpot, int> perFishingSpot = {};
  final Map<MoonPhase, int> perMoonPhase = {};
  final Map<Period, int> perPeriod = {};
  final Map<Season, int> perSeason = {};
  final Map<Species, int> perSpecies = {};
  final Map<TideType, int> perTideType = {};
  final Map<WaterClarity, int> perWaterClarity = {};

  _CatchSummaryReportModel({
    required this.context,
    required this.dateRange,
    Iterable<Catch> catches = const [],
  }) {
    _fillCollectionsWithZeros();
    _fillCollections(catches);
    _sortCollections();
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

  void _fillCollectionsWithZeros() {
    if (_includeBaits) {
      for (var bait in _baitManager.list()) {
        if (bait.variants.isEmpty) {
          perBait.putIfAbsent(bait.toAttachment(), () => 0);
        } else {
          for (var variant in bait.variants) {
            perBait.putIfAbsent(variant.toAttachment(), () => 0);
          }
        }
      }
    }

    _fillWithZeros(true,
        List<int>.generate(Duration.hoursPerDay, (i) => i), perHour);
    _fillWithZeros(
        true,
        List<int>.generate(Durations.monthsPerYear - 1, (i) => i + 1),
        perMonth);
    _fillWithZeros(_includeAnglers, _anglerManager.list(), perAngler);
    _fillWithZeros(
        _includeBodiesOfWater, _bodyOfWaterManager.list(), perBodyOfWater);
    _fillWithZeros(_includeMethods, _methodManager.list(), perMethod);
    _fillWithZeros(
        _includeFishingSpots, _fishingSpotManager.list(), perFishingSpot);
    _fillWithZeros(_includeMoonPhases, MoonPhases.selectable(), perMoonPhase);
    _fillWithZeros(_includePeriods, Periods.selectable(), perPeriod);
    _fillWithZeros(_includeSeasons, Seasons.selectable(), perSeason);
    _fillWithZeros(_includeSpecies, _speciesManager.list(), perSpecies);
    _fillWithZeros(_includeTideTypes, TideTypes.selectable(), perTideType);
    _fillWithZeros(
        _includeWaterClarities, _waterClarityManager.list(), perWaterClarity);
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
      catchIds.add(cat.id);

      var dateTime = cat.timestamp.toDateTime();
      _inc(true, dateTime.hour, perHour);
      _inc(true, dateTime.month, perMonth);

      _inc(_includeAnglers, _anglerManager.entity(cat.anglerId), perAngler);

      for (var attachment in cat.baits) {
        _inc(_includeBaits && _baitManager.entityExists(attachment.baitId),
            attachment, perBait);
      }

      _inc(
        _includeBodiesOfWater,
        _bodyOfWaterManager.entity(
            _fishingSpotManager.entity(cat.fishingSpotId)?.bodyOfWaterId),
        perBodyOfWater,
      );

      _inc(_includeFishingSpots, _fishingSpotManager.entity(cat.fishingSpotId),
          perFishingSpot);

      for (var methodId in cat.methodIds) {
        _inc(_includeMethods, _methodManager.entity(methodId), perMethod);
      }

      if (cat.hasAtmosphere() && cat.atmosphere.hasMoonPhase()) {
        _inc(_includeMoonPhases,
            MoonPhase.valueOf(cat.atmosphere.moonPhase.value), perMoonPhase);
      }

      if (cat.hasPeriod()) {
        _inc(_includePeriods, Period.valueOf(cat.period.value), perPeriod);
      }

      if (cat.hasSeason()) {
        _inc(_includeSeasons, Season.valueOf(cat.season.value), perSeason);
      }

      _inc(_includeSpecies, _speciesManager.entity(cat.speciesId), perSpecies);

      if (cat.hasTide() && cat.tide.hasType()) {
        _inc(_includeTideTypes, TideType.valueOf(cat.tide.type.value),
            perTideType);
      }

      _inc(_includeWaterClarities,
          _waterClarityManager.entity(cat.waterClarityId), perWaterClarity);
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

  void _sortCollections() {
    sortIntMap(perHour);
    sortIntMap(perMonth);
    sortIntMap(perAngler);
    sortIntMap(perBait);
    sortIntMap(perBodyOfWater);
    sortIntMap(perFishingSpot);
    sortIntMap(perMethod);
    sortIntMap(perMoonPhase);
    sortIntMap(perPeriod);
    sortIntMap(perSeason);
    sortIntMap(perSpecies);
    sortIntMap(perTideType);
    sortIntMap(perWaterClarity);
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

  bool get _includeTideTypes =>
      T != TideType && _userPreferenceManager.isTrackingTides;

  bool get _includePeriods =>
      T != Period && _userPreferenceManager.isTrackingPeriods;

  bool get _includeWaterClarities =>
      T != WaterClarity && _userPreferenceManager.isTrackingWaterClarities;
}
