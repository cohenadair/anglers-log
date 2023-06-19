import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/trip_list_page.dart';
import 'package:mobile/pages/trip_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/tile.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:timezone/data/latest.dart';

import '../entity_manager.dart';
import '../utils/date_time_utils.dart';
import '../wrappers/isolates_wrapper.dart';
import 'date_range_picker_input.dart';

/// A summary of a user's trips. This widget should always be rendered within
/// a [Scrollable] widget.
class TripSummary extends StatefulWidget {
  @override
  State<TripSummary> createState() => _TripSummaryState();
}

class _TripSummaryState extends State<TripSummary> {
  static const _rowHeight = 150.0;

  late Future<List<int>> _reportFuture;
  late TripReport _report;
  late DateRange _dateRange;

  CatchManager get _catchManager => CatchManager.of(context);

  IsolatesWrapper get _isolatesWrapper => IsolatesWrapper.of(context);

  TimeManager get _timeManager => TimeManager.of(context);

  TripManager get _tripManager => TripManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  @override
  void initState() {
    super.initState();

    _dateRange = _userPreferenceManager.statsDateRange ??
        DateRange(period: DateRange_Period.allDates);
    _dateRange.timeZone = _timeManager.currentTimeZone;

    _refreshReport();
  }

  @override
  void didUpdateWidget(TripSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshReport();
  }

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder(
      managers: [
        _tripManager,
      ],
      onAnyChange: _refreshReport,
      builder: (context) {
        return FutureBuilder<List<int>>(
          future: _reportFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Loading();
            }

            _report = TripReport.fromBuffer(snapshot.data!);

            return Column(
              children: [
                _buildDateRangePicker(),
                const MinDivider(),
                const VerticalSpace(paddingDefault),
                _buildTotalRow(),
                const VerticalSpace(paddingDefault),
                _buildLongestAndLastRow(),
                _buildAveragesRow(),
                const VerticalSpace(paddingDefault),
                _buildCatchesRow(),
                const VerticalSpace(paddingDefault),
                _buildWeightRow(),
                _buildLengthRow(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateRangePicker() {
    return DateRangePickerInput(
      initialDateRange: _dateRange,
      onPicked: (dateRange) => setState(() {
        _userPreferenceManager.setStatsDateRange(dateRange);
        _dateRange = dateRange;
        _refreshReport();
      }),
    );
  }

  Widget _buildTotalRow() {
    return TileRow(
      padding: insetsHorizontalDefault,
      items: [
        TileItem(
          title: _report.numberOfTrips.toString(),
          subtitle: _report.numberOfTrips == 1
              ? Strings.of(context).entityNameTrip
              : Strings.of(context).entityNameTrips,
          onTap: _report.numberOfTrips <= 0
              ? null
              : () {
                  return push(
                    context,
                    TripListPage(
                      ids: _tripManager.idSet(entities: _report.trips),
                    ),
                  );
                },
        ),
        TileItem.duration(
          context,
          msDuration: _report.totalMs.toInt(),
          subtitle: Strings.of(context).tripSummaryTotalTripTime,
        ),
      ],
    );
  }

  Widget _buildLongestAndLastRow() {
    var children = <TileItem>[];

    if (_report.hasLongestTrip()) {
      children.add(TileItem.duration(
        context,
        msDuration: _report.longestTrip.duration,
        subtitle: Strings.of(context).tripSummaryLongestTrip,
        onTap: () => push(context, TripPage(_report.longestTrip)),
      ));
    }

    if (_report.containsNow) {
      children.add(TileItem.duration(
        context,
        msDuration: _report.msSinceLastTrip.toInt(),
        subtitle: Strings.of(context).tripSummarySinceLastTrip,
        onTap: _report.hasLastTrip()
            ? () => push(context, TripPage(_report.lastTrip))
            : null,
      ));
    }

    if (children.isEmpty) {
      return const Empty();
    }

    return Padding(
      padding: insetsBottomDefault,
      child: TileRow(
        padding: insetsHorizontalDefault,
        items: children,
      ),
    );
  }

  Widget _buildAveragesRow() {
    return TileRow(
      padding: insetsHorizontalDefault,
      height: _rowHeight,
      items: [
        TileItem.condensedDuration(
          context,
          msDuration: _report.averageTripMs.toInt(),
          subtitle2: Strings.of(context).tripSummaryAverageTripTime,
        ),
        TileItem.condensedDuration(
          context,
          msDuration: _report.averageMsBetweenTrips.toInt(),
          subtitle2: Strings.of(context).tripSummaryAverageTimeBetweenTrips,
        ),
        TileItem.condensedDuration(
          context,
          msDuration: _report.averageMsBetweenCatches.toInt(),
          subtitle2: Strings.of(context).tripSummaryAverageTimeBetweenCatches,
        ),
      ],
    );
  }

  Widget _buildCatchesRow() {
    return TileRow(
      padding: insetsHorizontalDefault,
      items: [
        TileItem(
          title: _report.averageCatchesPerTrip.toStringAsFixed(1),
          subtitle: Strings.of(context).tripSummaryCatchesPerTrip,
        ),
        TileItem(
          title: _report.averageCatchesPerHour.toStringAsFixed(1),
          subtitle: Strings.of(context).tripSummaryCatchesPerHour,
        ),
      ],
    );
  }

  Widget _buildWeightRow() {
    if (!_report.hasAverageWeightPerTrip() ||
        !_report.hasMostWeightInSingleTrip()) {
      return const Empty();
    }

    return Padding(
      padding: insetsBottomDefault,
      child: TileRow(
        padding: insetsHorizontalDefault,
        items: [
          TileItem(
            title: _report.averageWeightPerTrip.displayValue(
              context,
              includeFraction: false,
            ),
            subtitle: Strings.of(context).tripSummaryWeightPerTrip,
          ),
          TileItem(
            title: _report.mostWeightInSingleTrip.displayValue(
              context,
              includeFraction: false,
            ),
            subtitle: Strings.of(context).tripSummaryBestWeight,
            onTap: () => push(context, TripPage(_report.mostWeightTrip)),
          ),
        ],
      ),
    );
  }

  Widget _buildLengthRow() {
    if (!_report.hasAverageLengthPerTrip() ||
        !_report.hasMostLengthInSingleTrip()) {
      return const Empty();
    }

    return Padding(
      padding: insetsBottomDefault,
      child: TileRow(
        padding: insetsHorizontalDefault,
        items: [
          TileItem(
            title: _report.averageLengthPerTrip.displayValue(
              context,
              includeFraction: false,
              mainDecimalPlaces: 0,
            ),
            subtitle: Strings.of(context).tripSummaryLengthPerTrip,
          ),
          TileItem(
            title: _report.mostLengthInSingleTrip.displayValue(
              context,
              includeFraction: false,
              mainDecimalPlaces: 0,
            ),
            subtitle: Strings.of(context).tripSummaryBestLength,
            onTap: () => push(context, TripPage(_report.mostLengthTrip)),
          ),
        ],
      ),
    );
  }

  void _refreshReport() {
    var opt = TripFilterOptions(
      dateRange: _dateRange,
      currentTimestamp: Int64(_timeManager.currentTimestamp),
      currentTimeZone: _timeManager.currentTimeZone,
      catchWeightSystem: _userPreferenceManager.catchWeightSystem,
      catchLengthSystem: _userPreferenceManager.catchLengthSystem,
      allCatches: _catchManager.uuidMap(),
      allTrips: _tripManager.uuidMap(),
    );
    _reportFuture = _isolatesWrapper.computeIntList(
        computeTripReport, opt.writeToBuffer().toList());
  }
}

extension TripReports on TripReport {
  int get numberOfTrips => trips.length;
}

List<int> computeTripReport(List<int> tripFilterOptionsBytes) {
  initializeTimeZones();

  var opt = TripFilterOptions.fromBuffer(tripFilterOptionsBytes);
  assert(opt.hasCurrentTimestamp());
  assert(opt.hasCurrentTimeZone());

  var weightSystem = opt.catchWeightSystem;
  var lengthSystem = opt.catchLengthSystem;

  var now = dateTime(opt.currentTimestamp.toInt(), opt.currentTimeZone);
  var report = TripReport();
  report.containsNow = opt.dateRange.endDate(now) == now;

  var totalCatches = 0;
  var totalCatchesPerHour = 0.0;
  var msBetweenTrips = 0;
  var msBetweenCatchesPerTrip = 0.0;
  var tripWeights = <MultiMeasurement>[];
  var tripLengths = <MultiMeasurement>[];

  report.trips.addAll(TripManager.isolatedFilteredTrips(opt));

  Trip? prevTrip;
  for (var trip in report.trips) {
    var duration = trip.duration;

    if (prevTrip != null) {
      msBetweenTrips += (prevTrip.endTimestamp - trip.startTimestamp).toInt();
    }

    report.totalMs += duration;
    if (!report.hasLastTrip()) {
      report.lastTrip = trip;
    }

    var catchesInTrip = TripManager.isolatedNumberOfCatches(
        trip, (id) => opt.allCatches[id.uuid]);
    totalCatches += catchesInTrip;
    if (duration > 0) {
      totalCatchesPerHour +=
          catchesInTrip / (duration / Duration.millisecondsPerHour);
    }

    if (!report.hasLongestTrip() ||
        report.longestTrip.duration < trip.duration) {
      report.longestTrip = trip;
    }

    var catches = CatchManager.isolatedFilteredCatches(
      CatchFilterOptions(
        currentTimestamp: opt.currentTimestamp,
        currentTimeZone: opt.currentTimeZone,
        catchIds: trip.catchIds.toSet(),
        allCatches: opt.allCatches,
      ),
    );
    if (catches.length > 1) {
      var msBetweenCatches = 0.0;
      var weights = <MultiMeasurement>[];
      var lengths = <MultiMeasurement>[];

      Catch? prevCatch;
      for (var cat in catches) {
        if (cat.hasWeight()) {
          weights.add(cat.weight);
        }

        if (cat.hasLength()) {
          lengths.add(cat.length);
        }

        if (prevCatch != null) {
          msBetweenCatches += (prevCatch.timestamp - cat.timestamp).toInt();
        }

        prevCatch = cat;
      }

      msBetweenCatchesPerTrip += msBetweenCatches / catches.length - 1;

      var avgWeight = MultiMeasurements.average(
          weights, weightSystem, weightSystem.weightUnit);
      if (avgWeight != null) {
        tripWeights.add(avgWeight);
      }

      var avgLength = MultiMeasurements.average(
          lengths, lengthSystem, lengthSystem.lengthUnit);
      if (avgLength != null) {
        tripLengths.add(avgLength);
      }

      var totalWeight =
          MultiMeasurements.sum(weights, weightSystem, weightSystem.weightUnit);
      if (totalWeight != null &&
          (!report.hasMostWeightInSingleTrip() ||
              totalWeight > report.mostWeightInSingleTrip)) {
        report.mostWeightInSingleTrip = totalWeight;
        report.mostWeightTrip = trip;
      }

      var totalLength =
          MultiMeasurements.sum(lengths, lengthSystem, lengthSystem.lengthUnit);
      if (totalLength != null &&
          (!report.hasMostLengthInSingleTrip() ||
              totalLength > report.mostLengthInSingleTrip)) {
        report.mostLengthInSingleTrip = totalLength;
        report.mostLengthTrip = trip;
      }
    }

    prevTrip = trip;
  }

  if (report.hasLastTrip()) {
    report.msSinceLastTrip = Int64(
        now.millisecondsSinceEpoch - report.lastTrip.endTimestamp.toInt());
  }

  if (report.numberOfTrips > 0) {
    report.averageTripMs =
        Int64((report.totalMs.toInt() / report.numberOfTrips).round());
    report.averageCatchesPerTrip = totalCatches / report.numberOfTrips;
    report.averageCatchesPerHour = totalCatchesPerHour / report.numberOfTrips;
    report.averageMsBetweenTrips =
        Int64((msBetweenTrips / report.numberOfTrips - 1).round());
    report.averageMsBetweenCatches =
        Int64((msBetweenCatchesPerTrip / report.numberOfTrips).round());
  }

  var weightPerTrip = MultiMeasurements.average(
      tripWeights, weightSystem, weightSystem.weightUnit);
  if (weightPerTrip != null) {
    report.averageWeightPerTrip = weightPerTrip;
  }

  var lengthPerTrip = MultiMeasurements.average(
      tripLengths, lengthSystem, lengthSystem.lengthUnit);
  if (lengthPerTrip != null) {
    report.averageLengthPerTrip = lengthPerTrip;
  }

  return report.writeToBuffer().toList();
}
