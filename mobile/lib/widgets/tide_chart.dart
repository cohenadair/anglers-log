import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile/res/theme.dart';
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
  static const lineWidth = 3.0;
  static const currentRadius = 8.0;
  static const currentStroke = 0.0;
  static const borderOpacity = 0.25;
  static const chartHeight = 200.0;

  final Tide tide;

  /// When true, will include all tide information below the chart. If false,
  /// only the tide height information will show.
  final bool isSummary;

  const TideChart(
    this.tide, {
    this.isSummary = true,
  });

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

    var heights = tide.daysHeights.map((e) => e.value).toList();

    var barData = LineChartBarData(
      color: context.colorDefault,
      spots: spots,
      isCurved: true,
      isStrokeCapRound: true,
      barWidth: lineWidth,
      dotData: FlDotData(
        checkToShowDot: (spot, barData) => spot == currentSpot,
        getDotPainter: (spot, value, barData, index) {
          return FlDotCirclePainter(
            color: context.colorDefault,
            strokeWidth: currentStroke,
            radius: currentRadius,
          );
        },
      ),
    );

    var extremesText = tide.extremesDisplayValue(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: defaultBorderRadius,
        border: Border.all(
          color: context.colorDefault.withOpacity(borderOpacity),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: chartHeight,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: context.colorDefault.withOpacity(borderOpacity),
                ),
              ),
            ),
            child: LineChart(
              LineChartData(
                lineBarsData: [barData],
                minY: min(heights)?.floorToDouble(),
                maxY: max(heights)?.ceilToDouble(),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
              ),
            ),
          ),
          const VerticalSpace(paddingSmall),
          Padding(
            padding: insetsHorizontalSmall,
            child: Text(tide.currentDisplayValue(
              context,
              useChipName: isSummary,
            )),
          ),
          !isSummary || isEmpty(extremesText)
              ? const Empty()
              : Padding(
                  padding: insetsHorizontalSmall,
                  child: Text(extremesText),
                ),
          const VerticalSpace(paddingSmall),
        ],
      ),
    );
  }
}
