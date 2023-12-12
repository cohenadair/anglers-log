import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/gear_manager.dart';
import 'package:mobile/pages/catch_page.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/wrappers/isolates_wrapper.dart';
import 'package:protobuf/protobuf.dart';
import 'package:timezone/data/latest.dart';

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
import '../utils/date_time_utils.dart' as dt_utils;
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../water_clarity_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/catch_list_page.dart';

import 'chart.dart';
import 'date_range_picker_input.dart';
import 'list_picker_input.dart';
import 'tile.dart';
import 'widget.dart';

/// A widget that shows a summary of the catches determined by [report]. This
/// widget should always be rendered inside a [Scrollable] widget.
class CatchSummary<T> extends StatefulWidget {
  final CatchFilterOptions Function(T?) filterOptionsBuilder;

  /// When not null, renders a [ListPickerInput] widget that allows the user
  /// to pick an instance of [T] from which to generate a new report.
  final CatchSummaryPicker<T>? picker;

  /// When true, the [DateRangePicker] is not shown.
  final bool isStatic;

  const CatchSummary({
    Key? key,
    required this.filterOptionsBuilder,
    this.picker,
    this.isStatic = false,
  }) : super(key: key);

  @override
  State<CatchSummary<T>> createState() => _CatchSummaryState<T>();
}

class _CatchSummaryState<T> extends State<CatchSummary<T>> {
  late Future<List<int>> _reportFuture;
  late CatchReport _report;
  late CatchFilterOptions _reportOptions;
  late DateRange _dateRange;
  T? _entity;

  AnglerManager get _anglerManager => AnglerManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  CatchManager get _catchManager => CatchManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  GearManager get _gearManager => GearManager.of(context);

  IsolatesWrapper get _isolatesWrapper => IsolatesWrapper.of(context);

  MethodManager get _methodManager => MethodManager.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  TimeManager get _timeManager => TimeManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  WaterClarityManager get _waterClarityManager =>
      WaterClarityManager.of(context);

  @override
  void initState() {
    super.initState();
    _dateRange = _userPreferenceManager.statsDateRange ??
        DateRange(period: DateRange_Period.allDates);
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
      builder: (context) => FutureBuilder<List<int>>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Loading();
          }

          _report = CatchReport.fromBuffer(snapshot.data!);

          return Column(
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
              _buildCatchesPerGear(),
              const VerticalSpace(paddingDefault),
            ],
          );
        },
      ),
    );
  }

  List<CatchReportModel> get _models => _report.models;

  Widget _buildDateRangePicker() {
    if (widget.isStatic) {
      return const Empty();
    }

    return DateRangePickerInput(
      initialDateRange: _dateRange,
      onPicked: (dateRange) => setState(() {
        _userPreferenceManager.setStatsDateRange(dateRange);
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
      value: widget.picker!.nameBuilder(context, _entity as T),
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

  TileItem _buildCatchesTileItem(CatchReportModel model) {
    var quantity = _catchManager.totalQuantity(model.catchIds);
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
        msDuration: _report.msSinceLastCatch.toInt(),
        subtitle: Strings.of(context).reportSummarySinceLastCatch,
        onTap: _report.hasLastCatch()
            ? () => push(context, CatchPage(_report.lastCatch))
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
        TitleLabel.style2(context, title),
        const VerticalSpace(paddingDefault),
        Chart<E>(
          series: series,
          fullPageSeries: fullPageSeries,
          padding: insetsHorizontalDefaultBottomSmall,
          viewAllTitle: viewAllTitle,
          chartPageDescription: viewAllDescription,
          chartPageFilters: _reportOptions.displayFilters(context, _report),
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
      labelBuilder: (hour) => dt_utils.formatHourRange(context, hour, hour + 1),
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
          DateFormat(dt_utils.monthFormat).format(DateTime(0, month)),
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
      series: _entitySeries((model) => model.perSpecies, _speciesManager),
      labelBuilder: (entity) => _speciesManager.displayName(context, entity),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        speciesIds: [entity.id],
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
      series:
          _entitySeries((model) => model.perFishingSpot, _fishingSpotManager),
      labelBuilder: (entity) => _fishingSpotManager.displayName(
        context,
        entity,
        includeBodyOfWater: true,
      ),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        fishingSpotIds: [entity.id],
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
      series: _report.toSeries<BaitAttachment>(
        (model) => {
          for (var id
              // Remove baits that don't exist. This can happen if a bait
              // associated with a catch is deleted.
              in List.of(model.perBait.keys)
                ..removeWhere((id) => !_baitManager
                    .attachmentExists(BaitAttachments.fromPbMapKey(id))))
            BaitAttachments.fromPbMapKey(id): model.perBait[id]!
        },
      ),
      labelBuilder: (entity) => _attachmentDisplayValue(entity),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        baitAttachments: [entity],
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
      series: _report.toSeries<MoonPhase>(
        (model) => {
          for (var index in model.perMoonPhase.keys)
            MoonPhase.values[index]: model.perMoonPhase[index]!
        },
      ),
      labelBuilder: (entity) => entity.displayName(context),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        moonPhases: [entity],
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
      series: _report.toSeries<TideType>(
        (model) => {
          for (var index in model.perTideType.keys)
            TideType.values[index]: model.perTideType[index]!
        },
      ),
      labelBuilder: (entity) => entity.displayName(context),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        tideTypes: [entity],
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
      series: _entitySeries((model) => model.perAngler, _anglerManager),
      labelBuilder: (entity) => _anglerManager.displayName(context, entity),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        anglerIds: [entity.id],
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
      series:
          _entitySeries((model) => model.perBodyOfWater, _bodyOfWaterManager),
      labelBuilder: (entity) =>
          _bodyOfWaterManager.displayName(context, entity),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        bodyOfWaterIds: [entity.id],
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
      series: _entitySeries((model) => model.perMethod, _methodManager),
      labelBuilder: (entity) => _methodManager.displayName(context, entity),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        methodIds: [entity.id],
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
      series: _report.toSeries<Period>(
        (model) => {
          for (var index in model.perPeriod.keys)
            Period.values[index]: model.perPeriod[index]!
        },
      ),
      labelBuilder: (entity) => entity.displayName(context),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        periods: [entity],
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
      series: _report.toSeries<Season>(
        (model) => {
          for (var index in model.perSeason.keys)
            Season.values[index]: model.perSeason[index]!
        },
      ),
      labelBuilder: (entity) => entity.displayName(context),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        seasons: [entity],
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
      series:
          _entitySeries((model) => model.perWaterClarity, _waterClarityManager),
      labelBuilder: (entity) =>
          _waterClarityManager.displayName(context, entity),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        waterClarityIds: [entity.id],
      ),
    );
  }

  Widget _buildCatchesPerGear() {
    if (!_report.hasPerGear) {
      return const Empty();
    }

    return _buildCatchesPerEntity<Gear>(
      title: Strings.of(context).reportSummaryPerGear,
      viewAllTitle: Strings.of(context).reportSummaryViewGear,
      viewAllDescription: Strings.of(context).reportSummaryPerGearDescription,
      series: _entitySeries((model) => model.perGear, _gearManager),
      labelBuilder: (entity) => _gearManager.displayName(context, entity),
      catchListBuilder: (entity, dateRange) => _buildCatchList(
        dateRange,
        gearIds: [entity.id],
      ),
    );
  }

  Widget _buildCatchList(
    DateRange dateRange, {
    List<Id>? anglerIds,
    List<BaitAttachment>? baitAttachments,
    List<Id>? bodyOfWaterIds,
    List<Id>? catchIds,
    List<Id>? fishingSpotIds,
    List<Id>? methodIds,
    List<MoonPhase>? moonPhases,
    List<Period>? periods,
    List<Season>? seasons,
    List<Id>? speciesIds,
    List<TideType>? tideTypes,
    List<Id>? waterClarityIds,
    List<Id>? gearIds,
    int? hour,
    int? month,
  }) {
    var filterOptions = _reportOptions.deepCopy()
      ..dateRanges.clear()
      ..dateRanges.add(dateRange);

    if (anglerIds != null) {
      filterOptions.anglerIds
        ..clear()
        ..addAll(anglerIds);
    }

    if (baitAttachments != null) {
      filterOptions.baits
        ..clear()
        ..addAll(baitAttachments);
    }

    if (bodyOfWaterIds != null) {
      filterOptions.bodyOfWaterIds
        ..clear()
        ..addAll(bodyOfWaterIds);
    }

    if (catchIds != null) {
      filterOptions.catchIds
        ..clear()
        ..addAll(catchIds);
    }

    if (fishingSpotIds != null) {
      filterOptions.fishingSpotIds
        ..clear()
        ..addAll(fishingSpotIds);
    }

    if (methodIds != null) {
      filterOptions.methodIds
        ..clear()
        ..addAll(methodIds);
    }

    if (moonPhases != null) {
      filterOptions.moonPhases
        ..clear()
        ..addAll(moonPhases);
    }

    if (periods != null) {
      filterOptions.periods
        ..clear()
        ..addAll(periods);
    }

    if (seasons != null) {
      filterOptions.seasons
        ..clear()
        ..addAll(seasons);
    }

    if (speciesIds != null) {
      filterOptions.speciesIds
        ..clear()
        ..addAll(speciesIds);
    }

    if (tideTypes != null) {
      filterOptions.tideTypes
        ..clear()
        ..addAll(tideTypes);
    }

    if (waterClarityIds != null) {
      filterOptions.waterClarityIds
        ..clear()
        ..addAll(waterClarityIds);
    }

    if (gearIds != null) {
      filterOptions.gearIds
        ..clear()
        ..addAll(gearIds);
    }

    if (hour != null) {
      filterOptions.hour = hour;
    }

    if (month != null) {
      filterOptions.month = month;
    }

    return CatchListPage(
      enableAdding: false,
      catches: _catchManager.catches(context, opt: filterOptions),
    );
  }

  String _attachmentDisplayValue(BaitAttachment attachment) {
    return _baitManager.attachmentDisplayValue(context, attachment);
  }

  List<Series<E>> _entitySeries<E extends GeneratedMessage>(
      Map<String, int> Function(CatchReportModel) entityMap,
      EntityManager<E> manager) {
    return _report.toSeries<E>((model) {
      // Filter out any entities that don't exist. This can happen when entities
      // associated with catches are deleted.
      var nonNullMap = Map<String, int>.of(entityMap(model))
        ..removeWhere((key, value) => !manager.entityExists(Id(uuid: key)));
      return nonNullMap.map<E, int>((key, value) =>
          MapEntry(manager.entity(Id(uuid: key))!, entityMap(model)[key]!));
    });
  }

  void _refreshReport() {
    var opt = widget.filterOptionsBuilder(_entity);

    // Setup default values if they aren't already set.
    if (opt.dateRanges.isEmpty) {
      opt.dateRanges.add(_dateRange);
    }

    if (!opt.hasCurrentTimestamp()) {
      opt.currentTimestamp = Int64(_timeManager.currentTimestamp);
    }

    if (!opt.hasCurrentTimeZone()) {
      opt.currentTimeZone = _timeManager.currentTimeZone;
    }

    opt.allAnglers
      ..clear()
      ..addAll(_anglerManager.uuidMap());
    opt.allBaits
      ..clear()
      ..addAll(_baitManager.uuidMap());
    opt.allBodiesOfWater
      ..clear()
      ..addAll(_bodyOfWaterManager.uuidMap());
    opt.allCatches
      ..clear()
      ..addAll(_catchManager.uuidMap());
    opt.allFishingSpots
      ..clear()
      ..addAll(_fishingSpotManager.uuidMap());
    opt.allMethods
      ..clear()
      ..addAll(_methodManager.uuidMap());
    opt.allSpecies
      ..clear()
      ..addAll(_speciesManager.uuidMap());
    opt.allWaterClarities
      ..clear()
      ..addAll(_waterClarityManager.uuidMap());
    opt.allGear
      ..clear()
      ..addAll(_gearManager.uuidMap());

    opt.includeAnglers =
        T != Angler && _userPreferenceManager.isTrackingAnglers;
    opt.includeBaits =
        T != BaitAttachment && _userPreferenceManager.isTrackingBaits;
    opt.includeBodiesOfWater = T != BodyOfWater;
    opt.includeMethods =
        T != Method && _userPreferenceManager.isTrackingMethods;
    opt.includeFishingSpots =
        T != FishingSpot && _userPreferenceManager.isTrackingFishingSpots;
    opt.includeMoonPhases =
        T != MoonPhase && _userPreferenceManager.isTrackingMoonPhases;
    opt.includeSeasons =
        T != Season && _userPreferenceManager.isTrackingSeasons;
    opt.includeSpecies =
        T != Species && _userPreferenceManager.isTrackingSpecies;
    opt.includeTideTypes =
        T != TideType && _userPreferenceManager.isTrackingTides;
    opt.includePeriods =
        T != Period && _userPreferenceManager.isTrackingPeriods;
    opt.includeWaterClarities =
        T != WaterClarity && _userPreferenceManager.isTrackingWaterClarities;
    opt.includeGear = T != Gear && _userPreferenceManager.isTrackingGear;

    _reportOptions = opt;
    _reportFuture = _isolatesWrapper.computeIntList(
        computeCatchReport, opt.writeToBuffer().toList());
  }
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

extension CatchReports on CatchReport {
  bool get hasCatches => models.containsWhere((e) => e.catchIds.isNotEmpty);

  bool get hasPerAngler => models.containsWhere((e) => e.perAngler.isNotEmpty);

  bool get hasPerBait => models.containsWhere((e) => e.perBait.isNotEmpty);

  bool get hasPerBodyOfWater =>
      models.containsWhere((e) => e.perBodyOfWater.isNotEmpty);

  bool get hasPerMethod => models.containsWhere((e) => e.perMethod.isNotEmpty);

  bool get hasPerFishingSpot =>
      models.containsWhere((e) => e.perFishingSpot.isNotEmpty);

  bool get hasPerMoonPhase =>
      models.containsWhere((e) => e.perMoonPhase.isNotEmpty);

  bool get hasPerSeason => models.containsWhere((e) => e.perSeason.isNotEmpty);

  bool get hasPerSpecies =>
      models.containsWhere((e) => e.perSpecies.isNotEmpty);

  bool get hasPerTideType =>
      models.containsWhere((e) => e.perTideType.isNotEmpty);

  bool get hasPerPeriod => models.containsWhere((e) => e.perPeriod.isNotEmpty);

  bool get hasPerWaterClarity =>
      models.containsWhere((e) => e.perWaterClarity.isNotEmpty);

  bool get hasPerGear => models.containsWhere((e) => e.perGear.isNotEmpty);

  bool get isComparing => models.length > 1;

  List<Series<E>> toSeries<E>(
      Map<E, int> Function(CatchReportModel) perEntity) {
    return models
        .map((model) => Series<E>(perEntity(model), model.dateRange))
        .toList();
  }
}

extension CatchFilterOptionsExt on CatchFilterOptions {
  Set<String> displayFilters(
    BuildContext context,
    CatchReport report, {
    bool includeSpecies = true,
  }) {
    var result = <String>{};
    if (report.models.length == 1) {
      result.add(report.models.first.dateRange.displayName(context));
    }

    if (includeSpecies) {
      _addFilters<Species>(
          context, SpeciesManager.of(context), speciesIds, result);
    }

    if (isCatchAndReleaseOnly) {
      result.add(Strings.of(context).saveReportPageCatchAndReleaseFilter);
    }

    if (isFavoritesOnly) {
      result.add(Strings.of(context).saveReportPageFavoritesFilter);
    }

    result.addAll(
        BaitManager.of(context).attachmentsDisplayValues(context, baits));
    _addFilters<FishingSpot>(
        context, FishingSpotManager.of(context), fishingSpotIds, result);
    _addFilters<BodyOfWater>(
        context, BodyOfWaterManager.of(context), bodyOfWaterIds, result);
    _addFilters<Angler>(context, AnglerManager.of(context), anglerIds, result);
    _addFilters<Method>(context, MethodManager.of(context), methodIds, result);
    _addFilters<WaterClarity>(
        context, WaterClarityManager.of(context), waterClarityIds, result);
    _addFilters<Gear>(context, GearManager.of(context), gearIds, result);

    result.addAll(periods.map((e) => e.displayName(context)));
    result.addAll(seasons.map((e) => e.displayName(context)));
    result.addAll(windDirections.map((e) => e.chipName(context)));
    result.addAll(skyConditions.map((e) => e.displayName(context)));
    result.addAll(moonPhases.map((e) => e.chipName(context)));
    result.addAll(tideTypes.map((e) => e.chipName(context)));

    _addNumberFilterIfNeeded(context, result,
        Strings.of(context).filterValueWaterDepth, waterDepthFilter);
    _addNumberFilterIfNeeded(
        context,
        result,
        Strings.of(context).filterValueWaterTemperature,
        waterTemperatureFilter);
    _addNumberFilterIfNeeded(
        context, result, Strings.of(context).filterValueLength, lengthFilter);
    _addNumberFilterIfNeeded(
        context, result, Strings.of(context).filterValueWeight, weightFilter);
    _addNumberFilterIfNeeded(context, result,
        Strings.of(context).filterValueQuantity, quantityFilter);
    _addNumberFilterIfNeeded(context, result,
        Strings.of(context).filterValueAirTemperature, airTemperatureFilter);
    _addNumberFilterIfNeeded(context, result,
        Strings.of(context).filterValueAirPressure, airPressureFilter);
    _addNumberFilterIfNeeded(context, result,
        Strings.of(context).filterValueAirHumidity, airHumidityFilter);
    _addNumberFilterIfNeeded(context, result,
        Strings.of(context).filterValueAirVisibility, airVisibilityFilter);
    _addNumberFilterIfNeeded(context, result,
        Strings.of(context).filterValueWindSpeed, windSpeedFilter);

    return result;
  }

  void _addFilters<E extends GeneratedMessage>(BuildContext context,
      NamedEntityManager<E> manager, List<Id> ids, Set<String> result) {
    result.addAll(
      ids
          .where((id) => manager.entity(id) != null)
          .map((id) => manager.displayName(context, manager.entity(id)!)),
    );
  }

  void _addNumberFilterIfNeeded(BuildContext context, Set<String> filters,
      String text, NumberFilter? numberFilter) {
    if (numberFilter == null ||
        numberFilter.boundary == NumberBoundary.number_boundary_any) {
      return;
    }
    filters.add(format(text, [numberFilter.displayValue(context)]));
  }
}

extension CatchReportModels on CatchReportModel {
  static CatchReportModel create(
      CatchFilterOptions opt, DateRange dateRange, Iterable<Catch> catches) {
    return CatchReportModel(dateRange: dateRange)
      .._fillCollectionsWithZeros(opt)
      .._fillCollections(opt, catches)
      .._sortCollections();
  }

  void _fillCollectionsWithZeros(CatchFilterOptions opt) {
    if (opt.includeBaits) {
      for (var bait in opt.allBaits.values) {
        if (bait.variants.isEmpty) {
          var attachment = bait.toAttachment();
          if (opt.baits.isEmpty || opt.baits.contains(attachment)) {
            perBait.putIfAbsent(attachment.toPbMapKey(), () => 0);
          }
        } else {
          for (var variant in bait.variants) {
            var attachment = variant.toAttachment();
            if (opt.baits.isEmpty || opt.baits.contains(attachment)) {
              perBait.putIfAbsent(attachment.toPbMapKey(), () => 0);
            }
          }
        }
      }
    }

    _fillWithZeros<int>(
        true, List<int>.generate(Duration.hoursPerDay, (i) => i), perHour);
    _fillWithZeros<int>(
        true,
        List<int>.generate(dt_utils.Durations.monthsPerYear - 1, (i) => i + 1),
        perMonth);

    _fillWithZeros<String>(opt.includeAnglers, opt.allAnglers.keys, perAngler,
        opt.anglerIds.toUuids());
    _fillWithZeros<String>(opt.includeBodiesOfWater, opt.allBodiesOfWater.keys,
        perBodyOfWater, opt.bodyOfWaterIds.toUuids());
    _fillWithZeros<String>(opt.includeMethods, opt.allMethods.keys, perMethod,
        opt.methodIds.toUuids());
    _fillWithZeros<String>(opt.includeFishingSpots, opt.allFishingSpots.keys,
        perFishingSpot, opt.fishingSpotIds.toUuids());
    _fillWithZeros<int>(opt.includeMoonPhases, MoonPhases.selectableValues(),
        perMoonPhase, opt.moonPhases.values());
    _fillWithZeros<int>(opt.includePeriods, Periods.selectableValues(),
        perPeriod, opt.periods.values());
    _fillWithZeros<int>(opt.includeSeasons, Seasons.selectableValues(),
        perSeason, opt.seasons.values());
    _fillWithZeros<String>(opt.includeSpecies, opt.allSpecies.keys, perSpecies,
        opt.speciesIds.toUuids());
    _fillWithZeros<int>(opt.includeTideTypes, TideTypes.selectableValues(),
        perTideType, opt.tideTypes.values());
    _fillWithZeros<String>(
        opt.includeWaterClarities,
        opt.allWaterClarities.keys,
        perWaterClarity,
        opt.waterClarityIds.toUuids());
    _fillWithZeros<String>(
        opt.includeGear, opt.allGear.keys, perGear, opt.gearIds.toUuids());
  }

  void _fillWithZeros<E>(bool include, Iterable<E> all, Map<E, int> sink,
      [Iterable<E> filter = const []]) {
    if (!include) {
      return;
    }
    for (var item in all) {
      if (filter.isEmpty || filter.contains(item)) {
        sink.putIfAbsent(item, () => 0);
      }
    }
  }

  void _fillCollections(CatchFilterOptions opt, Iterable<Catch> catches) {
    for (var cat in catches) {
      catchIds.add(cat.id);

      var dt = dt_utils.dateTime(cat.timestamp.toInt(),
          cat.hasTimeZone() ? cat.timeZone : opt.currentTimeZone);
      _inc(true, dt.hour, perHour, cat);
      _inc(true, dt.month, perMonth, cat);

      _inc<String>(
        opt.includeAnglers,
        opt.allAnglers[cat.anglerId.uuid]?.id.uuid,
        perAngler,
        cat,
      );

      for (var attachment in cat.baits) {
        _inc<String>(
          opt.includeBaits && opt.allBaits.containsKey(attachment.baitId.uuid),
          attachment.toPbMapKey(),
          perBait,
          cat,
        );
      }

      var fishingSpot = opt.allFishingSpots[cat.fishingSpotId.uuid];
      _inc<String>(
        opt.includeBodiesOfWater,
        opt.allBodiesOfWater[fishingSpot?.bodyOfWaterId.uuid]?.id.uuid,
        perBodyOfWater,
        cat,
      );

      _inc<String>(
        opt.includeFishingSpots,
        fishingSpot?.id.uuid,
        perFishingSpot,
        cat,
      );

      for (var methodId in cat.methodIds) {
        _inc<String>(
          opt.includeMethods,
          opt.allMethods[methodId.uuid]?.id.uuid,
          perMethod,
          cat,
        );
      }

      if (cat.hasAtmosphere() && cat.atmosphere.hasMoonPhase()) {
        _inc<int>(
          opt.includeMoonPhases,
          cat.atmosphere.moonPhase.value,
          perMoonPhase,
          cat,
        );
      }

      if (cat.hasPeriod()) {
        _inc<int>(opt.includePeriods, cat.period.value, perPeriod, cat);
      }

      if (cat.hasSeason()) {
        _inc<int>(opt.includeSeasons, cat.season.value, perSeason, cat);
      }

      _inc(
        opt.includeSpecies,
        opt.allSpecies[cat.speciesId.uuid]?.id.uuid,
        perSpecies,
        cat,
      );

      if (cat.hasTide() && cat.tide.hasType()) {
        _inc<int>(opt.includeTideTypes, cat.tide.type.value, perTideType, cat);
      }

      _inc(
        opt.includeWaterClarities,
        opt.allWaterClarities[cat.waterClarityId.uuid]?.id.uuid,
        perWaterClarity,
        cat,
      );

      for (var gearId in cat.gearIds) {
        _inc<String>(
          opt.includeGear,
          opt.allGear[gearId.uuid]?.id.uuid,
          perGear,
          cat,
        );
      }
    }
  }

  void _inc<E>(bool include, E? entity, Map<E, int> sink, Catch cat) {
    if (!include) {
      return;
    }

    if (entity != null) {
      sink.putIfAbsent(entity, () => 0);
      sink[entity] = sink[entity]! + (cat.hasQuantity() ? cat.quantity : 1);
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
    sortIntMap(perGear);
  }
}

List<int> computeCatchReport(List<int> catchFilterOptionsBytes) {
  initializeTimeZones();

  var opt = CatchFilterOptions.fromBuffer(catchFilterOptionsBytes);
  assert(opt.hasCurrentTimestamp());
  assert(opt.hasCurrentTimeZone());

  var now = opt.currentTimestamp.toInt();
  var report = CatchReport();

  for (var dateRange in opt.dateRanges) {
    var catches = CatchManager.isolatedFilteredCatches(opt);
    report.models.add(CatchReportModels.create(opt, dateRange, catches));
    report.containsNow |= dateRange
            .endDate(dt_utils.dateTime(now, opt.currentTimeZone))
            .millisecondsSinceEpoch ==
        now;

    if (catches.isEmpty || report.models.length > 1) {
      continue;
    }

    // Initialize properties that only apply when not comparing.
    report.lastCatch = catches.first;
    report.msSinceLastCatch =
        opt.currentTimestamp - report.lastCatch.timestamp.toInt();
  }

  return report.writeToBuffer().toList();
}
