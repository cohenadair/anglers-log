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

import '../entity_manager.dart';
import '../log.dart';
import 'date_range_picker_input.dart';

/// A summary of a user's trips. This widget should always be rendered within
/// a [Scrollable] widget.
class TripSummary extends StatefulWidget {
  @override
  State<TripSummary> createState() => _TripSummaryState();
}

class _TripSummaryState extends State<TripSummary> {
  static const _rowHeight = 150.0;

  final _log = const Log("TripSummary");
  late _TripSummaryReport _report;
  late DateRange _dateRange;

  TimeManager get _timeManager => TimeManager.of(context);

  TripManager get _tripManager => TripManager.of(context);

  @override
  void initState() {
    super.initState();

    _dateRange = DateRange(
      timeZone: _timeManager.currentTimeZone,
      period: DateRange_Period.allDates,
    );

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
      builder: (context) => Column(
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
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return DateRangePickerInput(
      initialDateRange: _dateRange,
      onPicked: (dateRange) => setState(() {
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
          msDuration: _report.totalMs,
          subtitle: Strings.of(context).tripSummaryTotalTripTime,
        ),
      ],
    );
  }

  Widget _buildLongestAndLastRow() {
    var children = <TileItem>[];

    if (_report.longestTrip != null) {
      children.add(TileItem.duration(
        context,
        msDuration: _report.longestTrip!.duration,
        subtitle: Strings.of(context).tripSummaryLongestTrip,
        onTap: () => push(context, TripPage(_report.longestTrip!)),
      ));
    }

    if (_report.containsNow) {
      children.add(TileItem.duration(
        context,
        msDuration: _report.msSinceLastTrip,
        subtitle: Strings.of(context).tripSummarySinceLastTrip,
        onTap: _report.lastTrip == null
            ? null
            : () => push(context, TripPage(_report.lastTrip!)),
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
          msDuration: _report.averageTripMs,
          subtitle2: Strings.of(context).tripSummaryAverageTripTime,
        ),
        TileItem.condensedDuration(
          context,
          msDuration: _report.averageMsBetweenTrips,
          subtitle2: Strings.of(context).tripSummaryAverageTimeBetweenTrips,
        ),
        TileItem.condensedDuration(
          context,
          msDuration: _report.averageMsBetweenCatches,
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
    if (_report.averageWeightPerTrip == null ||
        _report.mostWeightInSingleTrip == null) {
      return const Empty();
    }

    return Padding(
      padding: insetsBottomDefault,
      child: TileRow(
        padding: insetsHorizontalDefault,
        items: [
          TileItem(
            title: _report.averageWeightPerTrip?.displayValue(
              context,
              includeFraction: false,
            ),
            subtitle: Strings.of(context).tripSummaryWeightPerTrip,
          ),
          TileItem(
            title: _report.mostWeightInSingleTrip?.displayValue(
              context,
              includeFraction: false,
            ),
            subtitle: Strings.of(context).tripSummaryBestWeight,
            onTap: () => push(context, TripPage(_report.mostWeightTrip!)),
          ),
        ],
      ),
    );
  }

  Widget _buildLengthRow() {
    if (_report.averageLengthPerTrip == null ||
        _report.mostLengthInSingleTrip == null) {
      return const Empty();
    }

    return Padding(
      padding: insetsBottomDefault,
      child: TileRow(
        padding: insetsHorizontalDefault,
        items: [
          TileItem(
            title: _report.averageLengthPerTrip?.displayValue(
              context,
              includeFraction: false,
            ),
            subtitle: Strings.of(context).tripSummaryLengthPerTrip,
          ),
          TileItem(
            title: _report.mostLengthInSingleTrip?.displayValue(
              context,
              includeFraction: false,
            ),
            subtitle: Strings.of(context).tripSummaryBestLength,
            onTap: () => push(context, TripPage(_report.mostLengthTrip!)),
          ),
        ],
      ),
    );
  }

  void _refreshReport() {
    _report = _log.sync<_TripSummaryReport>(
        "refreshReport", 150, () => _TripSummaryReport(context, _dateRange));
  }
}

class _TripSummaryReport {
  final BuildContext context;
  final DateRange dateRange;

  var trips = <Trip>[];
  var totalMs = 0;

  Trip? longestTrip;
  Trip? lastTrip;
  var msSinceLastTrip = 0;
  var containsNow = false;

  var averageCatchesPerTrip = 0.0;
  var averageCatchesPerHour = 0.0;
  var averageMsBetweenCatches = 0;

  var averageTripMs = 0;
  var averageMsBetweenTrips = 0;

  MultiMeasurement? averageWeightPerTrip;
  MultiMeasurement? mostWeightInSingleTrip;
  Trip? mostWeightTrip;

  MultiMeasurement? averageLengthPerTrip;
  MultiMeasurement? mostLengthInSingleTrip;
  Trip? mostLengthTrip;

  int get numberOfTrips => trips.length;

  _TripSummaryReport(this.context, this.dateRange) {
    var catchManager = CatchManager.of(context);
    var timeManager = TimeManager.of(context);
    var tripManager = TripManager.of(context);
    var userPreferenceManager = UserPreferenceManager.of(context);

    var weightSystem = userPreferenceManager.catchWeightSystem;
    var lengthSystem = userPreferenceManager.catchLengthSystem;

    var now = timeManager.currentDateTime;
    containsNow = dateRange.endDate(now) == now;

    var totalCatches = 0;
    var totalCatchesPerHour = 0.0;
    var msBetweenTrips = 0;
    var msBetweenCatchesPerTrip = 0.0;
    var tripWeights = <MultiMeasurement>[];
    var tripLengths = <MultiMeasurement>[];

    trips = tripManager.trips(
      context: context,
      dateRange: dateRange,
    );

    Trip? prevTrip;
    for (var trip in trips) {
      var duration = trip.duration;

      if (prevTrip != null) {
        msBetweenTrips += (prevTrip.endTimestamp - trip.startTimestamp).toInt();
      }

      totalMs += duration;
      lastTrip ??= trip;

      var catchesInTrip = tripManager.numberOfCatches(trip);
      totalCatches += catchesInTrip;
      if (duration > 0) {
        totalCatchesPerHour +=
            catchesInTrip / (duration / Duration.millisecondsPerHour);
      }

      if (longestTrip == null || longestTrip!.duration < trip.duration) {
        longestTrip = trip;
      }

      var catches = catchManager.catches(
        context,
        opt: CatchFilterOptions(catchIds: trip.catchIds.toSet()),
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

        var totalWeight = MultiMeasurements.sum(
            weights, weightSystem, weightSystem.weightUnit);
        if (totalWeight != null &&
            (mostWeightInSingleTrip == null ||
                totalWeight > mostWeightInSingleTrip!)) {
          mostWeightInSingleTrip = totalWeight;
          mostWeightTrip = trip;
        }

        var totalLength = MultiMeasurements.sum(
            lengths, lengthSystem, lengthSystem.lengthUnit);
        if (totalLength != null &&
            (mostLengthInSingleTrip == null ||
                totalLength > mostLengthInSingleTrip!)) {
          mostLengthInSingleTrip = totalLength;
          mostLengthTrip = trip;
        }
      }

      prevTrip = trip;
    }

    if (lastTrip != null) {
      msSinceLastTrip =
          now.millisecondsSinceEpoch - lastTrip!.endTimestamp.toInt();
    }

    if (numberOfTrips > 0) {
      averageTripMs = (totalMs / numberOfTrips).round();
      averageCatchesPerTrip = totalCatches / numberOfTrips;
      averageCatchesPerHour = totalCatchesPerHour / numberOfTrips;
      averageMsBetweenTrips = (msBetweenTrips / numberOfTrips - 1).round();
      averageMsBetweenCatches =
          (msBetweenCatchesPerTrip / numberOfTrips).round();
    }

    averageWeightPerTrip = MultiMeasurements.average(
        tripWeights, weightSystem, weightSystem.weightUnit);
    averageLengthPerTrip = MultiMeasurements.average(
        tripLengths, lengthSystem, lengthSystem.lengthUnit);
  }
}
