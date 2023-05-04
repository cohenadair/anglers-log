import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/pages/catch_page.dart';
import 'package:mobile/pages/scroll_page.dart';
import 'package:mobile/pages/trip_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

import '../entity_manager.dart';
import '../log.dart';
import '../time_manager.dart';
import 'blurred_background_photo.dart';
import 'date_range_picker_input.dart';
import 'empty_list_placeholder.dart';
import 'list_item.dart';

/// A widget that shows a summary of the user's personal best catches and trips.
/// This widget should always be rendered inside a [SliverFillRemaining] widget,
/// otherwise, an exception will be thrown if there is no data to display.
class PersonalBestsReport extends StatefulWidget {
  @override
  State<PersonalBestsReport> createState() => _PersonalBestsReportState();
}

class _PersonalBestsReportState extends State<PersonalBestsReport> {
  static const _rowsPerSpeciesTable = 5;

  final _log = const Log("PersonalBestsReport");

  late DateRange _dateRange;
  late _PersonalBestsReportModel _model;

  CatchManager get _catchManager => CatchManager.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  TripManager get _tripManager => TripManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  @override
  void initState() {
    super.initState();
    _dateRange = _userPreferenceManager.statsDateRange ??
        DateRange(period: DateRange_Period.allDates);
    _refreshModel();
  }

  @override
  void didUpdateWidget(PersonalBestsReport oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refreshModel();
  }

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder(
      managers: [
        _speciesManager,
        _tripManager,
      ],
      onAnyChange: _refreshModel,
      builder: (context) => Column(
        children: [
          _buildDateRangePicker(),
          const MinDivider(),
          ..._buildReportViews(),
        ],
      ),
    );
  }

  List<Widget> _buildReportViews() {
    if (!_model.hasData) {
      return [
        Expanded(
          child: Center(
            child: EmptyListPlaceholder.static(
              title: Strings.of(context).personalBestsNoDataTitle,
              description: Strings.of(context).personalBestsNoDataDescription,
              icon: CustomIcons.catches,
            ),
          ),
        ),
      ];
    }

    return [
      _buildTrip(),
      _buildLongestCatch(),
      _buildHeaviestCatch(),
      _buildLengthPerSpecies(),
      _buildWeightPerSpecies(),
    ];
  }

  Widget _buildDateRangePicker() {
    return DateRangePickerInput(
      initialDateRange: _dateRange,
      onPicked: (dateRange) => setState(() {
        _userPreferenceManager.setStatsDateRange(dateRange);
        _dateRange = dateRange;
        _refreshModel();
      }),
    );
  }

  Widget _buildLongestCatch() {
    if (!_userPreferenceManager.isTrackingLength ||
        _model.longestCatch == null) {
      return const Empty();
    }

    return _BiggestCatch(
      _model.longestCatch!,
      Strings.of(context).personalBestsLongest,
      _model.longestCatch!.length.displayValue(context),
    );
  }

  Widget _buildHeaviestCatch() {
    if (!_userPreferenceManager.isTrackingWeight ||
        _model.heaviestCatch == null) {
      return const Empty();
    }

    return _BiggestCatch(
      _model.heaviestCatch!,
      Strings.of(context).personalBestsHeaviest,
      _model.heaviestCatch!.weight.displayValue(context),
    );
  }

  Widget _buildTrip() {
    if (_model.bestTrip == null) {
      return const Empty();
    }

    var trip = _model.bestTrip!;
    var displayName = _tripManager.displayName(context, trip);

    return _PersonalBest(
      title: Strings.of(context).personalBestsTrip,
      chipText:
          formatNumberOfCatches(context, _tripManager.numberOfCatches(trip)),
      subtitle: displayName,
      secondarySubtitle: isNotEmpty(_tripManager.name(trip))
          ? trip.elapsedDisplayValue(context)
          : null,
      imageName: trip.imageNames.firstOrNull,
      onTap: () => push(context, TripPage(trip)),
    );
  }

  Widget _buildLengthPerSpecies() {
    return _MeasurementPerSpecies(
      title: Strings.of(context).personalBestsSpeciesByLength,
      measurementTitle: Strings.of(context).personalBestsSpeciesByLengthLabel,
      map: _model.lengthBySpecies,
      maxRows: _rowsPerSpeciesTable,
      onTapSpeciesRow: (species) {
        push(
          context,
          CatchListPage(
            enableAdding: false,
            subtitleType: CatchListItemModelSubtitleType.length,
            catches: _catchManager.catches(
              context,
              opt: CatchFilterOptions(
                order: CatchFilterOptions_Order.longest_to_shortest,
                speciesIds: {species.id},
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeightPerSpecies() {
    return _MeasurementPerSpecies(
      title: Strings.of(context).personalBestsSpeciesByWeight,
      measurementTitle: Strings.of(context).personalBestsSpeciesByWeightLabel,
      map: _model.weightBySpecies,
      maxRows: _rowsPerSpeciesTable,
      onTapSpeciesRow: (species) {
        push(
          context,
          CatchListPage(
            enableAdding: false,
            subtitleType: CatchListItemModelSubtitleType.weight,
            catches: _catchManager.catches(
              context,
              opt: CatchFilterOptions(
                order: CatchFilterOptions_Order.heaviest_to_lightest,
                speciesIds: {species.id},
              ),
            ),
          ),
        );
      },
    );
  }

  void _refreshModel() {
    _model = _log.sync("refreshReport", 150,
        () => _PersonalBestsReportModel(context, _dateRange));
  }
}

class _PersonalBestsReportModel {
  Map<Species, _PersonalBestsSpeciesModel> lengthBySpecies = {};
  Map<Species, _PersonalBestsSpeciesModel> weightBySpecies = {};

  Catch? longestCatch;
  Catch? heaviestCatch;

  Trip? bestTrip;

  _PersonalBestsReportModel(BuildContext context, DateRange range) {
    var catchManager = CatchManager.of(context);
    var speciesManager = SpeciesManager.of(context);
    var timeManager = TimeManager.of(context);
    var tripManager = TripManager.of(context);
    var userPreferenceManager = UserPreferenceManager.of(context);

    var lengthSystem = userPreferenceManager.catchLengthSystem;
    var weightSystem = userPreferenceManager.catchWeightSystem;

    if (!range.hasTimeZone()) {
      range.timeZone = timeManager.currentTimeZone;
    }

    for (var cat in catchManager.catches(
      context,
      opt: CatchFilterOptions(
        currentTimeZone: timeManager.currentTimeZone,
        dateRanges: [range],
      ),
    )) {
      if (cat.hasLength() &&
          (longestCatch == null || longestCatch!.length < cat.length)) {
        longestCatch = cat;
      }

      if (cat.hasWeight() &&
          (heaviestCatch == null || heaviestCatch!.weight < cat.weight)) {
        heaviestCatch = cat;
      }

      if (cat.hasSpeciesId() && speciesManager.entityExists(cat.speciesId)) {
        var species = speciesManager.entity(cat.speciesId)!;

        if (cat.hasLength()) {
          lengthBySpecies.putIfAbsent(
            species,
            () => _PersonalBestsSpeciesModel(
                lengthSystem, lengthSystem.lengthUnit),
          );
          lengthBySpecies[species]!.addMeasurement(cat.length);
        }

        if (cat.hasWeight()) {
          weightBySpecies.putIfAbsent(
            species,
            () => _PersonalBestsSpeciesModel(
                weightSystem, weightSystem.weightUnit),
          );
          weightBySpecies[species]!.addMeasurement(cat.weight);
        }
      }
    }

    lengthBySpecies = sortedMap(
        lengthBySpecies, speciesManager.displayNameComparator(context));
    weightBySpecies = sortedMap(
        weightBySpecies, speciesManager.displayNameComparator(context));

    for (var trip in tripManager.list()) {
      if (!range.contains(
          trip.startTimestamp.toInt(), timeManager.now(trip.timeZone))) {
        continue;
      }

      if (bestTrip == null ||
          tripManager.numberOfCatches(trip) >
              tripManager.numberOfCatches(bestTrip!)) {
        bestTrip = trip;
      }
    }
  }

  bool get hasData =>
      lengthBySpecies.isNotEmpty ||
      weightBySpecies.isNotEmpty ||
      longestCatch != null ||
      heaviestCatch != null ||
      bestTrip != null;
}

class _PersonalBestsSpeciesModel {
  final MeasurementSystem system;
  final Unit unit;
  final List<MultiMeasurement> _allMeasurements = [];

  _PersonalBestsSpeciesModel(this.system, this.unit);

  MultiMeasurement? get personalBest =>
      MultiMeasurements.max(_allMeasurements, system, unit);

  MultiMeasurement? get average =>
      MultiMeasurements.average(_allMeasurements, system, unit);

  void addMeasurement(MultiMeasurement value) => _allMeasurements.add(value);
}

class _PersonalBest extends StatelessWidget {
  static const _imageHeight = 230.0;

  final String title;
  final String chipText;
  final String subtitle;
  final String? secondarySubtitle;
  final String? imageName;
  final VoidCallback? onTap;

  const _PersonalBest({
    required this.title,
    required this.chipText,
    required this.subtitle,
    required this.secondarySubtitle,
    this.imageName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPhoto(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const VerticalSpace(paddingDefault),
                    Row(
                      children: [
                        TitleLabel.style2(context, title),
                        MinChip(chipText),
                      ],
                    ),
                    const VerticalSpace(paddingSmall),
                    _buildDetails(context),
                  ],
                ),
              ),
              Padding(
                padding: insetsHorizontalDefault,
                child: RightChevronIcon(),
              ),
            ],
          ),
          const VerticalSpace(paddingDefault),
        ],
      ),
    );
  }

  Widget _buildPhoto() {
    if (isEmpty(imageName)) {
      return const Empty();
    }

    return BlurredBackgroundPhoto(
      imageName: imageName!,
      height: _imageHeight,
      padding: insetsHorizontalDefaultTopDefault,
      borderRadius: defaultBorderRadius,
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Padding(
      padding: insetsLeftDefault,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle, style: stylePrimary(context)),
          isEmpty(secondarySubtitle)
              ? const Empty()
              : Text(
                  secondarySubtitle!,
                  style: styleSecondary(context),
                  overflow: TextOverflow.ellipsis,
                ),
        ],
      ),
    );
  }
}

class _BiggestCatch extends StatelessWidget {
  final Catch cat;
  final String title;
  final String chipText;

  const _BiggestCatch(this.cat, this.title, this.chipText);

  @override
  Widget build(BuildContext context) {
    var speciesManager = SpeciesManager.of(context);
    var species = speciesManager.entity(cat.speciesId);

    return _PersonalBest(
      title: title,
      chipText: chipText,
      subtitle: species == null
          ? Strings.of(context).unknownSpecies
          : speciesManager.displayName(context, species),
      secondarySubtitle: cat.displayTimestamp(context),
      imageName: cat.imageNames.firstOrNull,
      onTap: () => push(context, CatchPage(cat)),
    );
  }
}

class _MeasurementPerSpecies extends StatelessWidget {
  final String? title;
  final String measurementTitle;
  final int? maxRows;
  final Map<Species, _PersonalBestsSpeciesModel> map;
  final void Function(Species) onTapSpeciesRow;

  const _MeasurementPerSpecies({
    required this.measurementTitle,
    required this.map,
    required this.onTapSpeciesRow,
    this.title,
    this.maxRows,
  });

  @override
  Widget build(BuildContext context) {
    if (map.isEmpty) {
      return const Empty();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const VerticalSpace(paddingDefault),
        isEmpty(title) ? const Empty() : TitleLabel.style2(context, title!),
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(),
            1: IntrinsicColumnWidth(),
            2: IntrinsicColumnWidth(),
            3: IntrinsicColumnWidth(),
          },
          children: <TableRow>[
            TableRow(
              children: [
                const TableCell(child: Empty()),
                _buildRightCell(
                  context: context,
                  text: measurementTitle,
                  isBold: true,
                  padding: insetsSmall,
                ),
                _buildRightCell(
                  context: context,
                  text: Strings.of(context).personalBestsAverage,
                  isBold: true,
                  padding: insetsSmall,
                ),
                const TableCell(child: Empty()),
              ],
            ),
            ..._buildSpeciesRows(context),
          ],
        ),
        _buildShowAllRow(context),
      ],
    );
  }

  List<TableRow> _buildSpeciesRows(BuildContext context) {
    var result = <TableRow>[];
    var speciesManager = SpeciesManager.of(context);

    for (var entry in map.entries) {
      var species = entry.key;
      void onTap() => onTapSpeciesRow(species);

      result.add(TableRow(
        children: [
          _buildInkWellCell(
            child: Text(
              speciesManager.displayName(context, species),
              overflow: TextOverflow.ellipsis,
              style: stylePrimary(context),
            ),
            padding: const EdgeInsets.only(
              left: paddingDefault,
              right: paddingSmall,
              top: paddingSmall,
              bottom: paddingSmall,
            ),
            onTap: onTap,
          ),
          _buildRightCell(
            context: context,
            text: entry.value.personalBest!.displayValue(context),
            padding: insetsSmall,
            onTap: onTap,
          ),
          _buildRightCell(
            context: context,
            text: entry.value.average!.displayValue(context),
            padding: insetsSmall,
            onTap: onTap,
          ),
          _buildInkWellCell(
            child: RightChevronIcon(),
            padding: insetsRightDefault,
            onTap: onTap,
          ),
        ],
      ));

      if (maxRows != null && result.length >= maxRows!) {
        break;
      }
    }

    return result;
  }

  Widget _buildRightCell({
    required BuildContext context,
    required String text,
    VoidCallback? onTap,
    bool isBold = false,
    EdgeInsets padding = insetsZero,
  }) {
    var style = stylePrimary(context);
    if (isBold) {
      style = style.copyWith(fontWeight: fontWeightBold);
    }

    return _buildInkWellCell(
      padding: padding,
      onTap: onTap,
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(text, style: style),
      ),
    );
  }

  Widget _buildInkWellCell({
    required Widget child,
    required EdgeInsets padding,
    VoidCallback? onTap,
  }) {
    // TableRowInkWell expands the InkWell to the entire table row, rather than
    // just the cell.
    return TableRowInkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }

  Widget _buildShowAllRow(BuildContext context) {
    if (maxRows == null || map.length <= maxRows!) {
      return const VerticalSpace(paddingDefault);
    }

    return ListItem(
      title: Text(Strings.of(context).personalBestsShowAllSpecies),
      trailing: RightChevronIcon(),
      onTap: () {
        push(
          context,
          _MeasurementPerSpeciesPage(
            title: title,
            measurementTitle: measurementTitle,
            map: map,
            onTapSpeciesRow: onTapSpeciesRow,
          ),
        );
      },
    );
  }
}

class _MeasurementPerSpeciesPage extends StatelessWidget {
  final String? title;
  final String measurementTitle;
  final Map<Species, _PersonalBestsSpeciesModel> map;
  final void Function(Species) onTapSpeciesRow;

  const _MeasurementPerSpeciesPage({
    required this.measurementTitle,
    required this.map,
    required this.onTapSpeciesRow,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      appBar: AppBar(
        title: isEmpty(title) ? const Empty() : Text(title!),
      ),
      children: [
        _MeasurementPerSpecies(
          measurementTitle: measurementTitle,
          map: map,
          onTapSpeciesRow: onTapSpeciesRow,
        ),
      ],
    );
  }
}
