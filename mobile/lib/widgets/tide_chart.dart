import 'package:fixnum/fixnum.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:quiver/iterables.dart';
import 'package:quiver/strings.dart';

import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../user_preference_manager.dart';
import 'widget.dart';

/// Shows a chart of a given [Tide]. If [Tide.daysHeights] is empty, an [Empty]
/// widget will be shown.
class TideChart extends StatelessWidget {
  static const _lineWidth = 3.0;
  static const _currentRadius = 8.0;
  static const _currentStroke = 0.0;
  static const _borderOpacity = 0.25;
  static const _chartHeight = 200.0;
  static const _timeTitleHeight = 30.0; // Default + small padding.
  static const _timeTitleIntervalHours = 12;
  static const _tooltipOpacity = 0.40;

  final Tide tide;

  const TideChart(this.tide);

  @override
  Widget build(BuildContext context) {
    if (tide.daysHeights.isEmpty) {
      return const Empty();
    }

    return StreamBuilder(
      stream: UserPreferenceManager.of(context).stream,
      builder: (context, _) => _buildChart(context),
    );
  }

  Widget _buildChart(BuildContext context) {
    var spots = tide.daysHeights
        .map((e) => FlSpot(e.timestamp.toDouble(), e.value))
        .toList();
    var currentSpot = spots.firstWhere(
      (e) =>
          e.x == tide.height.timestamp.toDouble() && e.y == tide.height.value,
    );
    var currentSpotIndex = spots.indexOf(currentSpot);

    var heights = tide.daysHeights.map((e) => e.value).toList();

    var barData = LineChartBarData(
      color: context.colorDefault,
      spots: spots,
      isCurved: true,
      isStrokeCapRound: true,
      barWidth: _lineWidth,
      dotData: FlDotData(
        checkToShowDot: (spot, barData) => spot == currentSpot,
        getDotPainter: (spot, value, barData, index) {
          return FlDotCirclePainter(
            color: context.colorDefault,
            strokeWidth: _currentStroke,
            radius: _currentRadius,
          );
        },
      ),
    );

    var lowText = tide.lowDisplayValue(context);
    var highText = tide.highDisplayValue(context);

    BoxDecoration? extremesDecoration;
    Widget extremesWidget = const Empty();
    if (isNotEmpty(lowText) || isNotEmpty(highText)) {
      // If extremes are showing, draw some separation between it and the
      // chart.
      extremesDecoration = BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colorDefault.withOpacity(_borderOpacity),
          ),
        ),
      );

      Widget low = const Empty();
      if (isNotEmpty(lowText)) {
        low = Text(lowText);
      }

      Widget high = const Empty();
      if (isNotEmpty(highText)) {
        high = Text(highText);
      }

      extremesWidget = Padding(
        padding: insetsSmall,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [low, high],
        ),
      );
    }

    return Container(
      padding: insetsTopDefault,
      decoration: BoxDecoration(
        borderRadius: defaultBorderRadius,
        border: Border.all(
          color: context.colorDefault.withOpacity(_borderOpacity),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: _chartHeight,
            padding: insetsRightSmall,
            decoration: extremesDecoration,
            child: LineChart(
              LineChartData(
                lineBarsData: [barData],
                minY: min(heights)?.floorToDouble(),
                maxY: max(heights)?.ceilToDouble(),
                minX: tide.daysHeights.first.timestamp.toDouble(),
                maxX: tide.daysHeights.last.timestamp.toDouble(),
                showingTooltipIndicators: [
                  ShowingTooltipIndicators([
                    LineBarSpot(
                      barData,
                      currentSpotIndex,
                      currentSpot,
                    ),
                  ]),
                ],
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles()),
                  rightTitles: const AxisTitles(sideTitles: SideTitles()),
                  bottomTitles:
                      AxisTitles(sideTitles: _buildTimeTitles(context)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: _buildLineTouchData(context),
              ),
            ),
          ),
          extremesWidget,
        ],
      ),
    );
  }

  SideTitles _buildTimeTitles(BuildContext context) {
    return SideTitles(
      showTitles: true,
      interval: const Duration(hours: _timeTitleIntervalHours)
          .inMilliseconds
          .toDouble(),
      reservedSize: _timeTitleHeight,
      getTitlesWidget: (value, meta) {
        if (value == meta.min || value == meta.max) {
          return const Empty();
        }
        return Padding(
          padding: insetsTopSmall,
          child: Text(formatTimeMillis(context, Int64(value.toInt()), null)),
        );
      },
    );
  }

  LineTouchData _buildLineTouchData(BuildContext context) {
    return LineTouchData(
      enabled: false,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) =>
            context.colorDefault.withOpacity(_tooltipOpacity),
        tooltipBorder: BorderSide(color: context.colorDefault),
        getTooltipItems: (_) => [
          LineTooltipItem(
            tide.currentDisplayValue(context),
            styleHeadingSmall,
          )
        ],
      ),
    );
  }
}
