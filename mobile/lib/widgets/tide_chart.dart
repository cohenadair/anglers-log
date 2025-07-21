import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/date_time.dart';
import 'package:fixnum/fixnum.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/tide_fetcher.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:quiver/iterables.dart';
import 'package:quiver/strings.dart';

import '../../utils/string_utils.dart';
import '../model/gen/anglers_log.pb.dart';
import '../res/dimen.dart';
import '../user_preference_manager.dart';

/// Shows a chart of a given [Tide]. If [Tide.daysHeights] is empty, an [Empty]
/// widget will be shown.
class TideChart extends StatelessWidget {
  static const _lineWidth = 3.0;
  static const _currentRadius = 8.0;
  static const _currentStroke = 0.0;
  static const _borderAlpha = 0.25;
  static const _chartHeight = 200.0;
  static const _timeTitleHeight = 30.0; // Default + small padding.
  static const _heightTitleWidth = 55.0; // Enough to fit "-X.X m".
  static const _heightTitleDecimalPlaces = 1;
  static const _timeTitleIntervalHours = 12;
  static const _tooltipAlpha = 0.40;

  final Tide tide;

  const TideChart(this.tide);

  @override
  Widget build(BuildContext context) {
    if (tide.daysHeights.isEmpty) {
      return const SizedBox();
    }

    return StreamBuilder(
      stream: UserPreferenceManager.get.stream,
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
      color: AppConfig.get.colorAppTheme,
      spots: spots,
      isCurved: true,
      isStrokeCapRound: true,
      barWidth: _lineWidth,
      dotData: FlDotData(
        checkToShowDot: (spot, barData) => spot == currentSpot,
        getDotPainter: (spot, value, barData, index) {
          return FlDotCirclePainter(
            color: AppConfig.get.colorAppTheme,
            strokeWidth: _currentStroke,
            radius: _currentRadius,
          );
        },
      ),
    );

    var lowText = tide.lowDisplayValue(context);
    var highText = tide.highDisplayValue(context);

    BoxDecoration? extremesDecoration;
    Widget extremesWidget = const SizedBox();
    if (isNotEmpty(lowText) || isNotEmpty(highText)) {
      // If extremes are showing, draw some separation between it and the
      // chart.
      extremesDecoration = BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppConfig.get.colorAppTheme.withValues(alpha: _borderAlpha),
          ),
        ),
      );

      Widget low = const SizedBox();
      if (isNotEmpty(lowText)) {
        low = Text(lowText);
      }

      Widget high = const SizedBox();
      if (isNotEmpty(highText)) {
        high = Text(highText);
      }

      extremesWidget = Padding(
        padding: insetsSmall,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            low,
            high,
            Text(Strings.of(context).tideInputDatumValue(TideFetcher.datum)),
          ],
        ),
      );
    }

    return Container(
      padding: insetsTopDefault,
      decoration: BoxDecoration(
        borderRadius: defaultBorderRadius,
        border: Border.all(
          color: AppConfig.get.colorAppTheme.withValues(alpha: _borderAlpha),
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
                    LineBarSpot(barData, currentSpotIndex, currentSpot),
                  ]),
                ],
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles()),
                  rightTitles: const AxisTitles(sideTitles: SideTitles()),
                  bottomTitles: AxisTitles(
                    sideTitles: _buildTimeTitles(context),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: _buildHeightTitles(context),
                  ),
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
      interval: const Duration(
        hours: _timeTitleIntervalHours,
      ).inMilliseconds.toDouble(),
      reservedSize: _timeTitleHeight,
      getTitlesWidget: (value, meta) {
        if (value == meta.min || value == meta.max) {
          return const SizedBox();
        }
        return Padding(
          padding: insetsTopSmall,
          child: Text(formatTimeMillis(context, Int64(value.toInt()), null)),
        );
      },
    );
  }

  SideTitles _buildHeightTitles(BuildContext context) {
    return SideTitles(
      showTitles: true,
      reservedSize: _heightTitleWidth,
      getTitlesWidget: (value, _) {
        return Padding(
          padding: insetsRightSmall,
          child: Text(
            Tide_Height(value: value).displayValue(
              context,
              includeFraction: false,
              decimalPlaces: _heightTitleDecimalPlaces,
            ),
            textAlign: TextAlign.end,
          ),
        );
      },
    );
  }

  LineTouchData _buildLineTouchData(BuildContext context) {
    return LineTouchData(
      enabled: false,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) =>
            AppConfig.get.colorAppTheme.withValues(alpha: _tooltipAlpha),
        tooltipBorder: BorderSide(color: AppConfig.get.colorAppTheme),
        getTooltipItems: (_) => [
          LineTooltipItem(tide.currentDisplayValue(context), styleHeadingSmall),
        ],
      ),
    );
  }
}
