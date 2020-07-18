import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/named_entity.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/pages/date_range_picker_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/stats/overview_report.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/label_value.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

class OverviewReportView extends StatefulWidget {
  @override
  _OverviewReportViewState createState() => _OverviewReportViewState();
}

class _OverviewReportViewState extends State<OverviewReportView> {
  static const _catchesBySpeciesChartId = "catches_by_species_chart_id";
  static const _catchesByFishingSpotChartId =
      "catches_by_fishing_spot_chart_id";
  static const _catchesByBaitChartId = "catches_by_bait_chart_id";

  DisplayDateRange _currentDateRange =
      DisplayDateRange.of(DisplayDateRange.allDates.id);

  OverviewReport _overview;

  bool get _hasCatches => _overview.totalCatches > 0;
  bool get _hasFishingSpots => _overview.totalFishingSpots > 0;
  bool get _hasBaits => _overview.totalBaits > 0;

  @override
  void initState() {
    super.initState();
    _resetOverview();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: SingleChildScrollView(
        child: EntityListenerBuilder(
          managers: [
            BaitManager.of(context),
            CatchManager.of(context),
            FishingSpotManager.of(context),
            SpeciesManager.of(context),
          ],
          onUpdate: () => _resetOverview(),
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDurationPicker(),
              _buildCatchItems(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationPicker() => ListPickerInput<DisplayDateRange>(
    initialValues: Set.of([_currentDateRange]),
    value: _currentDateRange.title(context),
    onTap: () {
      push(context, DateRangePickerPage(
        initialValue: _currentDateRange,
        onDateRangePicked: (dateRange) {
          setState(() {
            _currentDateRange = dateRange;
            _resetOverview();
          });
          Navigator.of(context).pop();
        },
      ));
    },
  );

  Widget _buildCatchItems() {
    if (!_hasCatches) {
      // TODO: Design a nicer widget here.
      return Column(
        children: [
          MinDivider(),
          Padding(
            padding: insetsDefault,
            child: PrimaryLabel(
              Strings.of(context).overviewReportViewNoCatches,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildViewCatchesRow(),
        _buildSummary(),
        _buildSpecies(),
        _buildFishingSpots(),
        _buildBaits(),
      ],
    );
  }

  Widget _buildViewCatchesRow() {
    return ListItem(
      title: Text(Strings.of(context).overviewReportViewViewCatches),
      onTap: () => push(context, CatchListPage(
        dateRange: _overview.dateRange,
      )),
      trailing: RightChevronIcon(),
    );
  }

  Widget _buildSummary() {
    return Column(
      children: [
        HeadingDivider(Strings.of(context).overviewReportViewSummary),
        VerticalSpace(paddingWidget),
        LabelValue(
          padding: insetsHorizontalDefault,
          label: Strings.of(context).overviewReportViewNumberOfCatches,
          value: _overview.totalCatches.toString(),
        ),
        VerticalSpace(paddingWidget),
        _hasCatches && _overview.isCurrentDate ? LabelValue(
          padding: EdgeInsets.only(
            left: paddingDefault,
            right: paddingDefault,
            bottom: paddingWidget,
          ),
          label: Strings.of(context).overviewReportViewSinceLastCatch,
          value: formatDuration(
            context: context,
            millisecondsDuration: _overview.msSinceLastCatch,
            includesSeconds: false,
            condensed: true,
          ),
        ) : Empty(),
        LabelValue(
          padding: EdgeInsets.only(
            left: paddingDefault,
            right: paddingDefault,
          ),
          label: Strings.of(context).overviewReportViewNumberOfFishingSpots,
          value: _overview.totalFishingSpots.toString(),
        ),
        VerticalSpace(paddingWidget),
        LabelValue(
          padding: EdgeInsets.only(
            left: paddingDefault,
            right: paddingDefault,
          ),
          label: Strings.of(context).overviewReportViewNumberOfBaits,
          value: _overview.totalBaits.toString(),
        ),
        VerticalSpace(paddingWidget),
      ],
    );
  }

  Widget _buildSpecies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeadingDivider(Strings.of(context).overviewReportViewSpecies),
        _OverviewChart<Species>(
          id: _catchesBySpeciesChartId,
          data: _overview.catchesPerSpecies,
          padding: EdgeInsets.only(
            top: paddingWidget,
            left: paddingDefault,
            right: paddingDefault,
          ),
          onTapRow: (species) => push(context, CatchListPage(
            species: species,
          )),
        ),
        VerticalSpace(paddingDefaultDouble),
      ],
    );
  }

  Widget _buildFishingSpots() {
    if (!_hasFishingSpots) {
      return Empty();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeadingDivider(Strings.of(context).overviewReportViewFishingSpots),
        VerticalSpace(paddingWidget),
        _OverviewChart<FishingSpot>(
          id: _catchesByFishingSpotChartId,
          data: _overview.catchesPerFishingSpot,
          padding: insetsHorizontalDefault,
          onTapRow: (fishingSpot) => push(context, CatchListPage(
            fishingSpot: fishingSpot,
          )),
        ),
        VerticalSpace(paddingDefaultDouble),
      ],
    );
  }

  Widget _buildBaits() {
    if (!_hasBaits) {
      return Empty();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeadingDivider(Strings.of(context).overviewReportViewBaits),
        VerticalSpace(paddingWidget),
        _OverviewChart<Bait>(
          id: _catchesByBaitChartId,
          data: _overview.catchesPerBait,
          padding: insetsHorizontalDefault,
          onTapRow: (bait) => push(context, CatchListPage(
            bait: bait,
          )),
        ),
        VerticalSpace(paddingDefaultDouble),
      ],
    );
  }

  void _resetOverview() {
    _overview = OverviewReport(
      appManager: AppManager.of(context),
      context: context,
      displayDateRange: _currentDateRange,
    );
  }
}

class _OverviewChart<T extends NamedEntity> extends StatefulWidget {
  final String id;
  final Map<T, int> data;
  final EdgeInsets padding;
  final String Function(T) labelBuilder;
  final void Function(T) onTapRow;

  _OverviewChart({
    @required this.id,
    @required this.data,
    this.padding,
    this.labelBuilder,
    this.onTapRow,
  });

  @override
  __OverviewChartState<T> createState() => __OverviewChartState<T>();
}

class __OverviewChartState<T extends NamedEntity>
    extends State<_OverviewChart<T>>
{
  static const _rowHeight = 50.0;
  static const _rowCount = 5;

  /// A subset of [widget.data] of size [_rowCount].
  Map<T, int> _displayData;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(_OverviewChart<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? insetsDefault,
      child: _buildChart(context),
    );
  }

  Widget _buildChart(BuildContext context) {
    return Container(
      height: _rowHeight * _rowCount,
      child: BarChart(
        [
          Series<T, String>(
            id: widget.id,
            data: _displayData.keys.toList(),
            domainFn: (entity, _) =>
                widget.labelBuilder?.call(entity) ?? entity.name,
            measureFn: (entity, _) => _displayData[entity],
            seriesColor: ColorUtil
                .fromDartColor(Theme.of(context).primaryColor),
            labelAccessorFn: (entity, _) =>
                "${widget.labelBuilder?.call(entity) ?? entity.name} "
                "(${_displayData[entity]})",
            insideLabelStyleAccessorFn: (species, _) => TextStyleSpec(
              color: ColorUtil.fromDartColor(Colors.black),
            ),
          ),
        ],
        animate: true,
        vertical: false,
        barRendererDecorator: BarLabelDecorator<String>(),
        domainAxis: OrdinalAxisSpec(
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
            }
          ),
        ],
      ),
    );
  }

  void _reset() {
    _displayData = firstElements(widget.data,
      numberOfElements: _rowCount,
    );
  }
}