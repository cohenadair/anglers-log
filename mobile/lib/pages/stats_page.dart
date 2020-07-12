import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/pages/date_range_picker_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/stats_overview_data.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/label_value.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/widget.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  static const _summarySpeciesChartId = "CatchQuantityChart";

  static const _chartRowHeight = 50.0;
  static const _chartAnimDuration = Duration(milliseconds: 150);
  static const _summarySpeciesMaxCount = 5;

  DisplayDateRange _currentDateRange =
      DisplayDateRange.of(DisplayDateRange.allDates.id);

  StatsOverviewData _overviewData;
  Map<Species, int> _catchesPerSpecies;
  bool _summaryShowingAllSpecies = false;
  double _summarySpeciesChartHeight = 0.0;

  bool get _hasCatches => _overviewData.totalCatches > 0;

  @override
  void initState() {
    super.initState();
    _resetOverviewData();
  }

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder(
      managers: [
        CatchManager.of(context),
      ],
      onUpdate: () => _resetOverviewData(),
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(Strings.of(context).statsPageTitle),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDurationPicker(),
                HeadingDivider(Strings.of(context).statsPageHeadingSummary),
                _buildSummary(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationPicker() => ListPickerInput<DisplayDateRange>(
    initialValues: Set.of([_currentDateRange]),
    value: _currentDateRange.getTitle(context),
    onTap: () {
      push(context, DateRangePickerPage(
        initialValue: _currentDateRange,
        onDateRangePicked: (dateRange) {
          setState(() {
            _currentDateRange = dateRange;
            _resetOverviewData();
          });
          Navigator.of(context).pop();
        },
      ));
    },
  );

  Widget _buildSummary() {
    return Padding(
      padding: insetsVerticalWidget,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _hasCatches ? LabelValue(
            padding: EdgeInsets.only(
              left: paddingDefault,
              right: paddingDefault,
              bottom: paddingWidget,
            ),
            label: Strings.of(context).statsPageOverviewSinceLastCatch,
            value: formatDuration(
              context: context,
              millisecondsDuration: _overviewData.msSinceLastCatch,
              includesSeconds: false,
              condensed: true,
            ),
          ) : Empty(),
          LabelValue(
            padding: insetsHorizontalDefault,
            label: Strings.of(context).statsPageOverviewTotalCatches,
            value: _overviewData.totalCatches.toString(),
          ),
          _hasCatches ? AnimatedContainer(
            duration: _chartAnimDuration,
            padding: insetsDefault,
            height: _summarySpeciesChartHeight,
            child: _buildSpeciesCountChart(),
          ) : Empty(),
          _buildShowMoreSpeciesButton(),
        ],
      ),
    );
  }

  Widget _buildSpeciesCountChart() {
    // TODO: Set bar width instead of full chart width
    // https://github.com/google/charts/issues/167
    return BarChart(
      [
        Series<Species, String>(
          id: _summarySpeciesChartId,
          data: _catchesPerSpecies.keys.toList(),
          domainFn: (species, _) => species.name,
          measureFn: (species, _) => _catchesPerSpecies[species],
          seriesColor: ColorUtil
              .fromDartColor(Theme.of(context).primaryColor),
          labelAccessorFn: (species, _) => "${species.name} "
              "(${_catchesPerSpecies[species]})",
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
        bottomMarginSpec: MarginSpec.fixedPixel(0),
      ),
      selectionModels: [
        SelectionModelConfig(
          changedListener: (model) {
            push(context, CatchListPage(
              species: model.selectedDatum.first.datum as Species,
            ));
            // Delay clearing selection so there is visual feedback that the
            // row was tapped.
            Future.delayed(Duration(milliseconds: 1000), () {
              setState(() {});
            });
          },
        ),
      ],
    );
  }

  Widget _buildShowMoreSpeciesButton() {
    if (!_hasCatches
        || _overviewData.allCatchesPerSpecies.length <= _summarySpeciesMaxCount)
    {
      return Empty();
    }

    return Padding(
      padding: EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        top: paddingWidget,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Button(
          text: _summaryShowingAllSpecies
              ? format(Strings.of(context).statsPageOverviewShowOnlySpecies,
                  [_summarySpeciesMaxCount])
              : Strings.of(context).statsPageOverviewShowAllSpecies,
          onPressed: () => setState(() {
            _summaryShowingAllSpecies = !_summaryShowingAllSpecies;
            _resetSummarySpeciesChart();
          }),
        ),
      ),
    );
  }

  void _resetOverviewData() {
    _overviewData = StatsOverviewData(
      context: context,
      displayDateRange: _currentDateRange,
    );
    _resetSummarySpeciesChart();
  }

  void _resetSummarySpeciesChart() {
    _catchesPerSpecies = _overviewData.catchesPerSpecies(
      maxResultLength: _summaryShowingAllSpecies
          ? null : _summarySpeciesMaxCount,
    );
    _summarySpeciesChartHeight = _chartRowHeight * _catchesPerSpecies.length;
  }
}