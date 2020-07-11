import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/species.dart';
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
  static const _chartRowHeight = 50.0;
  static const _summarySpeciesMaxCount = 5;

  DisplayDateRange _currentDateRange =
      DisplayDateRange.of(DisplayDateRange.allDates.id);

  StatsOverviewData _overviewData;
  bool _summaryShowingAllSpecies = false;

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
                HeadingDivider(Strings.of(context).statsPageCatchesByWeight),
                _buildCatchesByWeight(),
                HeadingDivider(Strings.of(context).statsPageCatchesByLength),
                _buildCatchesByLength(),
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
    Map<Species, int> catchesPerSpecies =
        _overviewData.catchesPerSpecies(
          maxResultLength: _summaryShowingAllSpecies
              ? null : _summarySpeciesMaxCount,
        );

    return Padding(
      padding: insetsVerticalWidget,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelValue(
            padding: insetsHorizontalDefault,
            label: Strings.of(context).statsPageOverviewSinceLastCatch,
            value: _hasCatches ? formatDuration(
              context: context,
              millisecondsDuration: _overviewData.msSinceLastCatch,
              includesSeconds: false,
              condensed: true,
            ) : Strings.of(context).na,
          ),
          VerticalSpace(paddingWidget),
          LabelValue(
            padding: insetsHorizontalDefault,
            label: Strings.of(context).statsPageOverviewTotalCatches,
            value: _overviewData.totalCatches.toString(),
          ),
          _hasCatches ? Container(
            padding: insetsDefault,
            height: _chartRowHeight * catchesPerSpecies.length,
            child: BarChart(
              [
                Series<Species, String>(
                  id: "CatchQuantityChart",
                  data: catchesPerSpecies.keys.toList(),
                  domainFn: (species, _) => species.name,
                  measureFn: (species, _) => catchesPerSpecies[species],
                  seriesColor: ColorUtil
                      .fromDartColor(Theme.of(context).primaryColor),
                  labelAccessorFn: (species, _) => "${species.name} "
                      "(${catchesPerSpecies[species]})",
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
            ),
          ) : Empty(),
          VerticalSpace(paddingWidget),
          Padding(
            padding: insetsHorizontalDefault,
            child: Align(
              alignment: Alignment.centerRight,
              child: Button(
                text: _summaryShowingAllSpecies ? format(
                  Strings.of(context).statsPageOverviewShowOnlySpecies,
                      [_summarySpeciesMaxCount],
                ) : Strings.of(context).statsPageOverviewShowAllSpecies,
                onPressed: () => setState(() {
                  _summaryShowingAllSpecies = !_summaryShowingAllSpecies;
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatchesByWeight() => Padding(
    padding: insetsBottomWidget,
    child: Empty(),
  );

  Widget _buildCatchesByLength() => Padding(
    padding: insetsBottomWidget,
    child: Empty(),
  );

  void _resetOverviewData() {
    _overviewData = StatsOverviewData(
      context: context,
      displayDateRange: _currentDateRange,
    );
  }
}