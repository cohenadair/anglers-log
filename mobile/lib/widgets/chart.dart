import 'dart:math';

import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/named_entity.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

/// An [ExpandableListItem] that, when tapped, shows a condensed [Chart] widget.
class ExpandableChart<T extends NamedEntity> extends StatelessWidget {
  final String title;
  final String viewAllTitle;
  final String viewAllDescription;
  final Set<String> filters;
  final List<ChartSeries<T>> series;
  final Widget Function(T) rowDetailsPage;

  ExpandableChart({
    this.title,
    this.viewAllTitle,
    this.viewAllDescription,
    this.filters = const {},
    this.series = const [],
    this.rowDetailsPage,
  }) : assert(series != null),
       assert(filters != null);
  
  ExpandableChart.singleSeries({
    String title,
    String viewAllTitle,
    String viewAllDescription,
    Set<String> filters = const {},
    ChartSeries<T> series,
    Widget Function(T) rowDetailsPage,
  }) : this(
    title: title,
    viewAllTitle: viewAllTitle,
    viewAllDescription: viewAllDescription,
    filters: filters,
    series: series == null ? const [] : [series],
    rowDetailsPage: rowDetailsPage,
  );

  @override
  Widget build(BuildContext context) {
    return ExpansionListItem(
      title: Text(title),
      children: [
        Chart<T>(
          series: series,
          viewAllTitle: viewAllTitle,
          chartPageDescription: viewAllDescription,
          chartPageFilters: filters,
          onTapRow: (entity) => push(context, rowDetailsPage(entity)),
        ),
      ],
    );
  }
}

class ChartSeries<T extends NamedEntity> {
  final Map<T, int> data;
  final String legendLabel;

  int get length => data.length;

  ChartSeries(this.data, [this.legendLabel]);

  ChartSeries<T> limitToFirst(int count) {
    return ChartSeries<T>(firstElements(data, numberOfElements: count),
        legendLabel);
  }
}

class Chart<T extends NamedEntity> extends StatefulWidget {
  final List<ChartSeries<T>> series;
  final String title;

  /// The title for the "view all" [ListItem] shown when there are more chart
  /// rows to see.
  final String viewAllTitle;

  /// A description to render on the full page chart shown when the "view all"
  /// row is tapped. This property is ignored when [showAll] is true.
  final String chartPageDescription;

  /// A list of filters that have already been applied to [data]. This property
  /// is ignored when [showAll] is true.
  final Set<String> chartPageFilters;

  /// If true, will render all items in [data], otherwise, will show a limited
  /// number of items, with a "show all" button to view the entire chart. This
  /// value defaults to false.
  final bool showAll;

  final String Function(T) labelBuilder;
  final void Function(T) onTapRow;

  Chart({
    @required this.series,
    this.title,
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
       assert(series.isNotEmpty),
       assert(chartPageFilters != null);

  @override
  _ChartState<T> createState() => _ChartState<T>();
}

class _ChartState<T extends NamedEntity> extends State<Chart<T>> {
  static const _rowHeight = 35.0;
  static const _condensedRowCount = 3;

  /// A subset of [widget.series] of size [_condensedRowCount].
  List<ChartSeries<T>> _displayData = [];

  int _rowCount = 0;
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
        _buildTitle(),
        _buildChart(),
        _buildViewAll(),
      ],
    );
  }

  Widget _buildTitle() {
    if (isEmpty(widget.title)) {
      return Empty();
    }

    return Padding(
      padding: EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingWidget,
      ),
      child: HeadingLabel(widget.title),
    );
  }

  Widget _buildChart() {
    return Container(
      padding: insetsHorizontalDefault,
      height: _rowHeight * _rowCount,
      child: BarChart(
        _displayData.map((data) => _buildSeries(data)).toList(),
        animate: true,
        vertical: false,
        barRendererDecorator: BarLabelDecorator<String>(),
        domainAxis: OrdinalAxisSpec(
          renderSpec: NoneRenderSpec(),
        ),
        primaryMeasureAxis: NumericAxisSpec(
          renderSpec: NoneRenderSpec(),
        ),
        layoutConfig: LayoutConfig(
          leftMarginSpec: MarginSpec.fixedPixel(0),
          topMarginSpec: MarginSpec.fixedPixel(0),
          rightMarginSpec: MarginSpec.fixedPixel(0),
          bottomMarginSpec: MarginSpec.defaultSpec,
        ),
        selectionModels: [
          SelectionModelConfig(
            changedListener: (model) {
              widget.onTapRow?.call(model.selectedDatum.first.datum as T);
              // Delay clearing selection so there is visual feedback that the
              // row was tapped.
              Future.delayed(Duration(milliseconds: 50), () {
                setState(() {});
              });
            },
          ),
        ],
        behaviors: widget.series.length > 1 ? [
          SeriesLegend(),
        ] : [],
      ),
    );
  }

  Series<T, String> _buildSeries(ChartSeries<T> series) {
    return Series<T, String>(
      id: series.legendLabel,
      data: series.data.keys.toList(),
      domainFn: (entity, _) => widget.labelBuilder?.call(entity)
          ?? entity.name,
      measureFn: (entity, _) => series.data[entity],
      seriesColor: ColorUtil
          .fromDartColor(Theme.of(context).primaryColor),
      labelAccessorFn: (entity, _) {
        String label = widget.labelBuilder?.call(entity);
        return "${label ?? entity.name} (${series.data[entity]})";
      },
      insideLabelStyleAccessorFn: (_, __) => TextStyleSpec(
        color: ColorUtil.fromDartColor(Colors.black),
      ),
    );
  }

  Widget _buildViewAll() {
    if (isEmpty(widget.viewAllTitle) || _maxRowCount <= _condensedRowCount) {
      return VerticalSpace(paddingWidget);
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
    _rowCount = widget.showAll
        ? _maxRowCount : min(_condensedRowCount, _maxRowCount);
  }
}

/// A full page widget that displays a [Chart] with a lot of rows.
class _ChartPage<T extends NamedEntity> extends StatelessWidget {
  final List<ChartSeries<T>> series;
  final String description;
  final Set<String> filters;
  final String Function(T) labelBuilder;
  final void Function(T) onTapRow;

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
              Padding(
                padding: insetsBottomDefault,
                child: Chart<T>(
                  series: series,
                  labelBuilder: labelBuilder,
                  onTapRow: onTapRow,
                  showAll: true,
                ),
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