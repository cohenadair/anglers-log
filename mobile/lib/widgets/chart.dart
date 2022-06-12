import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile/utils/color_utils.dart';
import 'package:mobile/widgets/filled_row.dart';
import 'package:quiver/iterables.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/collection_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/list_item.dart';
import '../widgets/widget.dart';

/// An [ExpandableListItem] that, when tapped, shows a condensed [Chart] widget.
class ExpandableChart<T> extends StatelessWidget {
  final String title;
  final String? viewAllTitle;
  final String? viewAllDescription;
  final Set<String> filters;
  final List<Series<T>> series;
  final Widget Function(T, DateRange)? rowDetailsPage;

  /// See [Chart.labelBuilder].
  final String Function(T) labelBuilder;

  const ExpandableChart({
    required this.title,
    this.viewAllTitle,
    this.viewAllDescription,
    this.filters = const {},
    this.series = const [],
    this.rowDetailsPage,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionListItem(
      title: Text(
        title,
        style: const TextStyle(color: Colors.black),
      ),
      children: [
        Chart<T>(
          series: series,
          padding: insetsHorizontalDefaultVerticalSmall,
          viewAllTitle: viewAllTitle,
          chartPageDescription: viewAllDescription,
          chartPageFilters: filters,
          onTapRow: rowDetailsPage == null
              ? null
              : (entity, dateRange) =>
                  push(context, rowDetailsPage!(entity, dateRange)),
          labelBuilder: labelBuilder,
        ),
      ],
    );
  }
}

class Series<T> {
  final Map<T, int> data;

  /// Used as a title in the legend.
  final DateRange dateRange;

  Color? _color;

  Series(this.data, this.dateRange) : assert(data.isNotEmpty);

  int get length => data.length;

  int get maxValue => max(data.values) ?? 0;

  Series<T> limitToFirst(int count) {
    return Series<T>(firstElements(data, numberOfElements: count), dateRange)
      .._color = _color;
  }
}

/// A horizontal bar chart. All [Chart] widgets should be children of a
/// [Scrollable] widget, otherwise an overflow exception may be thrown.
class Chart<T> extends StatefulWidget {
  static const _rowColorOpacity = 0.65;

  final EdgeInsets padding;

  /// The data shown in the chart. Length must be >= 1. All [Series]
  /// elements must have equal data lengths.
  final List<Series<T>> series;

  /// The data shown in the full page chart. If null, [series] is shown.
  final List<Series<T>>? fullPageSeries;

  /// The title for the "view all" [ListItem] shown when there are more chart
  /// rows to see.
  final String? viewAllTitle;

  /// A description to render on the full page chart shown when the "view all"
  /// row is tapped. This property is ignored when [showAll] is true.
  final String? chartPageDescription;

  /// A list of filters that have already been applied to [data]. Values in this
  /// set are rendered at the top of a full page chart view.
  final Set<String> chartPageFilters;

  /// If true, will render all items in [data], otherwise, will show a limited
  /// number of items, with a "show all" button to view the entire chart. This
  /// value defaults to false.
  final bool showAll;

  /// A builder for the label widget on each row of the chart.
  final String? Function(T) labelBuilder;

  final void Function(T, DateRange)? onTapRow;

  Chart({
    required this.series,
    required this.labelBuilder,
    this.fullPageSeries,
    this.padding = insetsZero,
    this.viewAllTitle,
    this.chartPageDescription,
    this.chartPageFilters = const {},
    this.showAll = false,
    this.onTapRow,
  })  : assert(
            showAll ||
                (!showAll &&
                    isNotEmpty(viewAllTitle) &&
                    isNotEmpty(chartPageDescription)),
            "showAll is false; viewAllTitle is required"),
        assert(series.isNotEmpty) {
    var colors = accentColors();
    var seriesLen = series.first.length;
    for (Series series in series) {
      assert(series.length == seriesLen,
          "All data lengths in series must be equal");
      Color color = colors[math.Random().nextInt(colors.length)];
      colors.remove(color);
      series._color = color.withOpacity(_rowColorOpacity);
    }
  }

  @override
  ChartState<T> createState() => ChartState<T>();
}

class ChartState<T> extends State<Chart<T>> {
  static const _legendIndicatorSize = 15.0;
  static const _legendRadius = 4.0;
  static const _rowHeight = 20.0;
  static const _rowCornerRadius = 5.0;
  static const _condensedRowCount = 3;

  /// A subset of [widget.series] of size [_condensedRowCount].
  List<Series<T>> _displayData = [];

  int _maxRowCount = 0;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(Chart<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.series != widget.series) {
      _reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegend(),
        _buildChart(),
        _buildViewAll(),
      ],
    );
  }

  Widget _buildLegend() {
    if (widget.series.length <= 1) {
      return const Empty();
    }
    return Padding(
      padding: widget.padding.copyWith(
        bottom: paddingDefault,
      ),
      child: Wrap(
        spacing: paddingDefault,
        runSpacing: paddingTiny,
        children: widget.series
            .map(
              (series) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                          Radius.circular(_legendRadius)),
                      color: series._color,
                    ),
                    width: _legendIndicatorSize,
                    height: _legendIndicatorSize,
                  ),
                  const HorizontalSpace(paddingSmall),
                  Text(series.dateRange.displayName(context)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildChart() {
    var children = <Widget>[];

    // Get largest row value.
    var maxValue = 0.0;
    for (Series series in _displayData) {
      var max = series.maxValue;
      if (max > maxValue) {
        maxValue = max.toDouble();
      }
    }

    // For every unique item in the series, create a child widget.
    var items = _displayData.first.data.keys.toList();
    for (var item in items) {
      for (var series in _displayData) {
        children.add(
          _buildChartRow(
              maxValue, item, series, series.data[item], series._color),
        );

        // Add space between series rows.
        children
            .add(VerticalSpace(series == _displayData.last ? 0 : paddingTiny));
      }

      // Add space between rows.
      children.add(VerticalSpace(item == items.last ? 0 : paddingDefault));
    }

    return Container(
      padding: widget.padding,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildChartRow(
      double maxValue, T item, Series<T> series, int? value, Color? color) {
    // Set a minimum max value of 1 so if the series values are 0, an "empty"
    // row will still show.
    maxValue = math.max(maxValue, 1);

    // Value can be null here if, for example, item A exists in one series but
    // not another.
    value = value ?? 0;

    return FilledRow(
      height: _rowHeight,
      maxValue: maxValue,
      value: value,
      fillColor: color,
      cornerRadius: _rowCornerRadius,
      label: widget.labelBuilder(item) ?? "",
      labelPadding: insetsHorizontalTiny,
      padding: widget.padding,
      onTap: value <= 0
          ? null
          : () => widget.onTapRow!.call(item, series.dateRange),
    );
  }

  Widget _buildViewAll() {
    if (widget.showAll ||
        isEmpty(widget.viewAllTitle) ||
        _maxRowCount <= _condensedRowCount) {
      return const VerticalSpace(paddingSmall);
    }

    assert(isNotEmpty(widget.chartPageDescription),
        "Must provide a page description");

    return ListItem(
      title: Text(widget.viewAllTitle!),
      trailing: RightChevronIcon(),
      onTap: () => push(
        context,
        _ChartPage<T>(
          series: widget.fullPageSeries ?? widget.series,
          description: widget.chartPageDescription!,
          filters: widget.chartPageFilters,
          labelBuilder: widget.labelBuilder,
          onTapRow: widget.onTapRow,
        ),
      ),
    );
  }

  void _reset() {
    _displayData.clear();

    if (widget.showAll) {
      _displayData = widget.series;
    } else {
      for (var data in widget.series) {
        _displayData.add(data.limitToFirst(_condensedRowCount));
      }
    }

    _maxRowCount = 0;
    for (var data in widget.series) {
      if (data.length > _maxRowCount) {
        _maxRowCount = data.length;
      }
    }
  }
}

/// A full page widget that displays a [Chart] with a lot of rows.
class _ChartPage<T> extends StatelessWidget {
  final List<Series<T>> series;
  final String description;
  final Set<String> filters;
  final String? Function(T) labelBuilder;
  final void Function(T, DateRange)? onTapRow;

  _ChartPage({
    required this.series,
    required this.description,
    required this.labelBuilder,
    this.filters = const {},
    this.onTapRow,
  }) : assert(isNotEmpty(description));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: insetsDefault,
                child: Text(description),
              ),
              _buildFilters(context),
              Chart<T>(
                series: series,
                padding: const EdgeInsets.only(
                  left: paddingDefault,
                  right: paddingDefault,
                  bottom: paddingSmall,
                  top: paddingSmall,
                ),
                labelBuilder: labelBuilder,
                onTapRow: onTapRow,
                showAll: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    if (filters.isEmpty) {
      return const Empty();
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingDefault,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Strings.of(context).reportSummaryFilters,
            style: styleListHeading(context),
          ),
          const VerticalSpace(paddingDefault),
          ChipWrap(filters),
        ],
      ),
    );
  }
}
