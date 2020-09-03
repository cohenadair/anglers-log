import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/named_entity.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/iterables.dart';
import 'package:quiver/strings.dart';

/// An [ExpandableListItem] that, when tapped, shows a condensed [Chart] widget.
class ExpandableChart<T extends NamedEntity> extends StatelessWidget {
  final String title;
  final String viewAllTitle;
  final String viewAllDescription;
  final Set<String> filters;
  final List<Series<T>> series;
  final Widget Function(T, DateRange) rowDetailsPage;

  ExpandableChart({
    this.title,
    this.viewAllTitle,
    this.viewAllDescription,
    this.filters = const {},
    this.series = const [],
    this.rowDetailsPage,
  }) : assert(series != null),
       assert(filters != null);

  @override
  Widget build(BuildContext context) {
    return ExpansionListItem(
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
      children: [
        Chart<T>(
          series: series,
          padding: insetsHorizontalDefaultVerticalSmall,
          viewAllTitle: viewAllTitle,
          chartPageDescription: viewAllDescription,
          chartPageFilters: filters,
          onTapRow: (entity, dateRange) =>
              push(context, rowDetailsPage(entity, dateRange)),
        ),
      ],
    );
  }
}

class Series<T extends NamedEntity> {
  final Map<T, int> data;
  final DisplayDateRange displayDateRange;

  Color _color;

  Series(this.data, this.displayDateRange)
      : assert (data != null && data.isNotEmpty),
        assert(displayDateRange != null);

  int get length => data.length;
  int get maxValue => max(data.values);

  Series<T> limitToFirst(int count) {
    return Series<T>(firstElements(data, numberOfElements: count),
        displayDateRange).._color = _color;
  }
}

class Chart<T extends NamedEntity> extends StatefulWidget {
  static const _rowColorOpacity = 0.65;

  final EdgeInsets padding;

  /// The data shown in the chart. Length must be >= 1. All [Series]
  /// elements must have equal data lengths.
  final List<Series<T>> series;

  /// The title for the "view all" [ListItem] shown when there are more chart
  /// rows to see.
  final String viewAllTitle;

  /// A description to render on the full page chart shown when the "view all"
  /// row is tapped. This property is ignored when [showAll] is true.
  final String chartPageDescription;

  /// A list of filters that have already been applied to [data]. Values in this
  /// set are rendered at the top of a full page chart view.
  final Set<String> chartPageFilters;

  /// If true, will render all items in [data], otherwise, will show a limited
  /// number of items, with a "show all" button to view the entire chart. This
  /// value defaults to false.
  final bool showAll;

  final String Function(T) labelBuilder;
  final void Function(T, DateRange) onTapRow;

  Chart({
    @required this.series,
    this.padding = insetsZero,
    this.viewAllTitle,
    this.chartPageDescription,
    this.chartPageFilters = const {},
    this.showAll = false,
    this.labelBuilder,
    this.onTapRow,
  }) : assert(showAll || (!showAll && isNotEmpty(viewAllTitle)
           && isNotEmpty(chartPageDescription)),
           "showAll is false; viewAllTitle is required"),
       assert(series != null),
       assert(padding != null),
       assert(series.isNotEmpty),
       assert(chartPageFilters != null)
  {
    List<Color> colors = List.of(Colors.primaries)
        ..remove(Colors.brown)
        ..remove(Colors.blueGrey);

    int seriesLen = series.first.length;
    for (Series series in series) {
      assert(series.length == seriesLen,
          "All data lengths in series must be equal");
      Color color = colors[Random().nextInt(colors.length)];
      colors.remove(color);
      series._color = color.withOpacity(_rowColorOpacity);
    }
  }

  @override
  _ChartState<T> createState() => _ChartState<T>();
}

class _ChartState<T extends NamedEntity> extends State<Chart<T>> {
  static final _log = Log("MyChart");

  static final Color _emptyBgColor = Colors.grey.withOpacity(0.15);

  static const _legendIndicatorSize = 15.0;
  static const _rowHeight = 20.0;
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
      return Empty();
    }
    return Padding(
      padding: widget.padding.copyWith(
        top: paddingWidgetSmall,
        bottom: paddingWidgetSmall,
      ),
      child: Wrap(
        spacing: paddingWidget,
        runSpacing: paddingWidgetTiny,
        children: widget.series.map((series) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _legendIndicatorSize,
              height: _legendIndicatorSize,
              color: series._color,
            ),
            HorizontalSpace(paddingWidgetSmall),
            Text(series.displayDateRange.title(context)),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildChart() {
    List<Widget> children = [];

    // Get largest column value.
    double maxValue = 0;
    for (Series series in _displayData) {
      int max = series.maxValue;
      if (max > maxValue) {
        maxValue = max.toDouble();
      }
    }

    double maxWidth = MediaQuery.of(context).size.width;

    // For every unique NamedEntity in the series, create a child widget.
    List<T> entities = _displayData.first.data.keys.toList();
    for (T entity in entities) {
      for (Series series in _displayData) {
        children.add(_buildChartRow(maxWidth, maxValue, entity, series,
            series.data[entity],
            series._color ?? Theme.of(context).primaryColor));

        // Add space between series rows.
        children.add(VerticalSpace(series == _displayData.last
            ? 0 : paddingWidgetTiny));
      }

      // Add space between rows.
      children.add(VerticalSpace(entity == entities.last ? 0 : paddingDefault));
    }

    return Container(
      padding: widget.padding,
      width: maxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildChartRow(double maxWidth, double maxValue, T entity,
      Series<T> series, int value, Color color)
  {
    if (maxValue <= 0) {
      _log.w("Can't create a chart row with maxValue = 0");
      return Empty();
    }

    return InkWell(
      onTap: widget.onTapRow == null
          ? null
          : () => widget.onTapRow.call(entity, series.displayDateRange.value),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            height: _rowHeight,
            width: maxWidth,
            color: _emptyBgColor,
          ),
          Container(
            height: _rowHeight,
            width: value.toDouble() / maxValue
                * (maxWidth - widget.padding.left - widget.padding.right),
            color: color,
          ),
          Padding(
            padding: insetsHorizontalWidgetTiny,
            child: Label("${entity.name} ($value)"),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAll() {
    if (isEmpty(widget.viewAllTitle) || _maxRowCount <= _condensedRowCount) {
      return VerticalSpace(paddingWidgetSmall);
    }

    return ListItem(
      title: Text(widget.viewAllTitle),
      trailing: RightChevronIcon(),
      onTap: () => push(context, _ChartPage<T>(
        series: widget.series,
        description: widget.chartPageDescription,
        filters: widget.chartPageFilters,
        labelBuilder: widget.labelBuilder,
        onTapRow: widget.onTapRow,
      )),
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
class _ChartPage<T extends NamedEntity> extends StatelessWidget {
  final List<Series<T>> series;
  final String description;
  final Set<String> filters;
  final String Function(T) labelBuilder;
  final void Function(T, DateRange) onTapRow;

  _ChartPage({
    @required this.series,
    @required this.description,
    this.filters = const {},
    this.labelBuilder,
    this.onTapRow,
  }) : assert(series != null),
       assert(isNotEmpty(description)),
       assert(filters != null);

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
                padding: EdgeInsets.only(
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
      return Empty();
    }

    return Padding(
      padding: EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingWidgetSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeadingLabel(Strings.of(context).reportSummaryFilters),
          Wrap(
            spacing: paddingWidgetSmall,
            children: filters.map((filter) => Chip(
              label: Text(filter),
            )).toList(),
          ),
        ],
      ),
    );
  }
}