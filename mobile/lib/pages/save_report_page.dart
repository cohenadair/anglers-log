import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:protobuf/protobuf.dart';
import 'package:quiver/strings.dart';

import '../angler_manager.dart';
import '../bait_manager.dart';
import '../comparison_report_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../log.dart';
import '../method_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../named_entity_manager.dart';
import '../pages/bait_list_page.dart';
import '../pages/fishing_spot_list_page.dart';
import '../pages/form_page.dart';
import '../pages/species_list_page.dart';
import '../res/dimen.dart';
import '../species_manager.dart';
import '../summary_report_manager.dart';
import '../utils/date_time_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/validator.dart';
import '../widgets/checkbox_input.dart';
import '../widgets/date_range_picker_input.dart';
import '../widgets/input_controller.dart';
import '../widgets/input_data.dart';
import '../widgets/multi_list_picker_input.dart';
import '../widgets/radio_input.dart';
import '../widgets/text_input.dart';
import '../widgets/widget.dart';
import 'angler_list_page.dart';
import 'manageable_list_page.dart';
import 'method_list_page.dart';
import 'picker_page.dart';

class SaveReportPage extends StatefulWidget {
  final dynamic oldReport;

  SaveReportPage() : oldReport = null;

  SaveReportPage.edit(this.oldReport) : assert(oldReport != null);

  @override
  _SaveReportPageState createState() => _SaveReportPageState();
}

class _SaveReportPageState extends State<SaveReportPage> {
  static final _idName = randomId();
  static final _idDescription = randomId();
  static final _idType = randomId();
  static final _idStartDateRange = randomId();
  static final _idEndDateRange = randomId();
  static final _idAnglers = randomId();
  static final _idSpecies = randomId();
  static final _idBaits = randomId();
  static final _idFishingSpots = randomId();
  static final _idMethods = randomId();
  static final _idPeriods = randomId();
  static final _idFavoritesOnly = randomId();

  static const _log = Log("SaveReportPage");

  final Key _keySummaryStart = ValueKey(0);
  final Key _keyComparisonStart = ValueKey(1);

  final Map<Id, Field> _fields = {};

  AnglerManager get _anglerManager => AnglerManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  ComparisonReportManager get _comparisonReportManager =>
      ComparisonReportManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  MethodManager get _methodManager => MethodManager.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  SummaryReportManager get _summaryReportManager =>
      SummaryReportManager.of(context);

  TextInputController get _nameController =>
      _fields[_idName]!.controller as TextInputController;

  TextInputController get _descriptionController =>
      _fields[_idDescription]!.controller as TextInputController;

  InputController<_ReportType> get _typeController =>
      _fields[_idType]!.controller as InputController<_ReportType>;

  InputController<DisplayDateRange> get _fromDateRangeController =>
      _fields[_idStartDateRange]!.controller
          as InputController<DisplayDateRange>;

  InputController<DisplayDateRange> get _toDateRangeController =>
      _fields[_idEndDateRange]!.controller as InputController<DisplayDateRange>;

  SetInputController<Angler> get _anglersController =>
      _fields[_idAnglers]!.controller as SetInputController<Angler>;

  SetInputController<Species> get _speciesController =>
      _fields[_idSpecies]!.controller as SetInputController<Species>;

  SetInputController<Bait> get _baitsController =>
      _fields[_idBaits]!.controller as SetInputController<Bait>;

  SetInputController<FishingSpot> get _fishingSpotsController =>
      _fields[_idFishingSpots]!.controller as SetInputController<FishingSpot>;

  SetInputController<Method> get _methodsController =>
      _fields[_idMethods]!.controller as SetInputController<Method>;

  SetInputController<Period> get _periodsController =>
      _fields[_idPeriods]!.controller as SetInputController<Period>;

  BoolInputController get _favoritesOnlyController =>
      _fields[_idFavoritesOnly]!.controller as BoolInputController;

  dynamic get _oldReport => widget.oldReport;

  bool get _editing => _oldReport != null;

  bool get _summary => _typeController.value == _ReportType.summary;

  @override
  void initState() {
    super.initState();

    _fields[_idName] = Field(
      id: _idName,
      controller: TextInputController(
        validator: NameValidator(
          nameExistsMessage: (context) =>
              Strings.of(context).saveCustomReportPageNameExists,
          nameExists: (newName) =>
              _comparisonReportManager.nameExists(newName) ||
              _summaryReportManager.nameExists(newName),
          oldName: _oldReport?.name,
        ),
      ),
    );

    _fields[_idDescription] = Field(
      id: _idDescription,
      controller: TextInputController(),
    );

    _fields[_idType] = Field(
      id: _idType,
      controller: InputController<_ReportType>(),
    );

    _fields[_idStartDateRange] = Field(
      id: _idStartDateRange,
      controller: InputController<DisplayDateRange>(),
    );

    _fields[_idEndDateRange] = Field(
      id: _idStartDateRange,
      controller: InputController<DisplayDateRange>(),
    );

    _fields[_idFavoritesOnly] = Field(
      id: _idFavoritesOnly,
      controller: BoolInputController(),
    );

    _fields[_idPeriods] = Field(
      id: _idPeriods,
      controller: SetInputController<Period>(),
    );

    _fields[_idAnglers] = Field(
      id: _idAnglers,
      controller: SetInputController<Angler>(),
    );

    _fields[_idSpecies] = Field(
      id: _idSpecies,
      controller: SetInputController<Species>(),
    );

    _fields[_idBaits] = Field(
      id: _idBaits,
      controller: SetInputController<Bait>(),
    );

    _fields[_idFishingSpots] = Field(
      id: _idFishingSpots,
      controller: SetInputController<FishingSpot>(),
    );

    _fields[_idMethods] = Field(
      id: _idMethods,
      controller: SetInputController<Method>(),
    );

    if (_editing) {
      if (_oldReport is SummaryReport) {
        var report = _oldReport as SummaryReport;
        _nameController.value = report.name;
        _descriptionController.value = report.description;
        _typeController.value = _ReportType.summary;
        _fromDateRangeController.value = DisplayDateRange.of(
          report.displayDateRangeId,
          report.startTimestamp.toInt(),
          report.endTimestamp.toInt(),
        );
        _toDateRangeController.value = DisplayDateRange.allDates;
        _favoritesOnlyController.value = report.isFavoritesOnly;
        _periodsController.value = report.periods.toSet();
        _initEntitySets(
          anglerIds: report.anglerIds,
          baitIds: report.baitIds,
          fishingSpotIds: report.fishingSpotIds,
          methodIds: report.methodIds,
          speciesIds: report.speciesIds,
        );
      } else if (_oldReport is ComparisonReport) {
        var report = _oldReport as ComparisonReport;
        _nameController.value = report.name;
        _descriptionController.value = report.description;
        _typeController.value = _ReportType.comparison;
        _fromDateRangeController.value = DisplayDateRange.of(
          report.fromDisplayDateRangeId,
          report.fromStartTimestamp.toInt(),
          report.fromEndTimestamp.toInt(),
        );
        _toDateRangeController.value = DisplayDateRange.of(
          report.toDisplayDateRangeId,
          report.toStartTimestamp.toInt(),
          report.toEndTimestamp.toInt(),
        );
        _favoritesOnlyController.value = report.isFavoritesOnly;
        _periodsController.value = report.periods.toSet();
        _initEntitySets(
          anglerIds: report.anglerIds,
          baitIds: report.baitIds,
          fishingSpotIds: report.fishingSpotIds,
          methodIds: report.methodIds,
          speciesIds: report.speciesIds,
        );
      }
    } else {
      _typeController.value = _ReportType.summary;
      _fromDateRangeController.value = DisplayDateRange.allDates;
      _toDateRangeController.value = DisplayDateRange.allDates;
      _periodsController.value = {};
      _initEntitySets();
    }
  }

  void _initEntitySets({
    List<Id> anglerIds = const [],
    List<Id> baitIds = const [],
    List<Id> fishingSpotIds = const [],
    List<Id> methodIds = const [],
    List<Id> speciesIds = const [],
  }) {
    // "Empty" lists will include all entities in reports, so don't actually
    // include every entity in the report object.
    _anglersController.value =
        anglerIds.isEmpty ? {} : _anglerManager.list(anglerIds).toSet();
    _baitsController.value =
        baitIds.isEmpty ? {} : _baitManager.list(baitIds).toSet();
    _fishingSpotsController.value = fishingSpotIds.isEmpty
        ? {}
        : _fishingSpotManager.list(fishingSpotIds).toSet();
    _methodsController.value =
        methodIds.isEmpty ? {} : _methodManager.list(methodIds).toSet();
    _speciesController.value =
        speciesIds.isEmpty ? {} : _speciesManager.list(speciesIds).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      runSpacing: 0,
      padding: insetsZero,
      title: Text(_editing
          ? Strings.of(context).saveCustomReportPageEditTitle
          : Strings.of(context).saveCustomReportPageNewTitle),
      isInputValid: _nameController.valid(context),
      fieldBuilder: (context) => {
        _idName: _buildName(),
        _idDescription: _buildDescription(),
        _idType: _buildType(),
        _idStartDateRange: _buildStartDateRange(),
        _idEndDateRange: _buildEndDateRange(),
        _idFavoritesOnly: _buildFavoritesOnly(),
        _idPeriods: _buildPeriodsPicker(),
        _idAnglers: _buildAnglersPicker(),
        _idSpecies: _buildSpeciesPicker(),
        _idBaits: _buildBaitsPicker(),
        _idFishingSpots: _buildFishingSpotsPicker(),
        _idMethods: _buildMethodsPicker(),
      },
      onSave: _save,
    );
  }

  Widget _buildName() {
    return Padding(
      padding: EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingSmall,
      ),
      child: TextInput.name(
        context,
        controller: _nameController,
        autofocus: true,
        textInputAction: TextInputAction.next,
        // Trigger "Save" button state refresh.
        onChanged: () => setState(() {}),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingSmall,
      ),
      child: TextInput.description(
        context,
        controller: _descriptionController,
      ),
    );
  }

  Widget _buildType() {
    return RadioInput(
      padding: insetsHorizontalDefaultVerticalSmall,
      initialSelectedIndex: _typeController.value!.index,
      optionCount: _ReportType.values.length,
      optionBuilder: (context, index) {
        var type = _ReportType.values[index];
        switch (type) {
          case _ReportType.comparison:
            return Strings.of(context).saveCustomReportPageComparison;
          case _ReportType.summary:
            return Strings.of(context).saveCustomReportPageSummary;
        }
      },
      onSelect: (index) => setState(() {
        _typeController.value = _ReportType.values[index];
      }),
    );
  }

  Widget _buildStartDateRange() {
    return AnimatedSwitcher(
      duration: defaultAnimationDuration,
      child: _summary
          ? _startDateRangePicker(_keySummaryStart, null)
          : _startDateRangePicker(_keyComparisonStart,
              Strings.of(context).saveCustomReportPageStartDateRangeLabel),
    );
  }

  Widget _startDateRangePicker(Key key, String? title) {
    return DateRangePickerInput(
      key: key,
      title: title,
      initialDateRange: _fromDateRangeController.value,
      onPicked: (dateRange) => setState(() {
        _fromDateRangeController.value = dateRange;
      }),
    );
  }

  Widget _buildFavoritesOnly() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: CheckboxInput(
        label: Strings.of(context).saveReportPageFavorites,
        value: _favoritesOnlyController.value,
        onChanged: (checked) => _favoritesOnlyController.value = checked,
      ),
    );
  }

  Widget _buildEndDateRange() {
    return AnimatedSwitcher(
      duration: defaultAnimationDuration,
      child: _summary
          ? Empty()
          : DateRangePickerInput(
              title: Strings.of(context).saveCustomReportPageEndDateRangeLabel,
              initialDateRange: _toDateRangeController.value,
              onPicked: (dateRange) => setState(() {
                _toDateRangeController.value = dateRange;
              }),
            ),
    );
  }

  Widget _buildPeriodsPicker() {
    return MultiListPickerInput(
      padding: insetsHorizontalDefaultVerticalWidget,
      values: _periodsController.value
          .map((p) => nameForPeriod(context, p))
          .toSet(),
      emptyValue: (context) => Strings.of(context).periodPickerAll,
      onTap: () {
        var allPeriods = selectablePeriods();
        push(
          context,
          PickerPage<Period>(
            title: Text(Strings.of(context).periodPickerMultiTitle),
            initialValues: _periodsController.value.isEmpty
                ? ({Period.all}..addAll(allPeriods))
                : _periodsController.value,
            allItem: PickerPageItem<Period>(
              title: Strings.of(context).all,
              value: Period.all,
            ),
            itemBuilder: () => pickerItemsForPeriod(context),
            onFinishedPicking: (context, periods) {
              // Treat an empty controller value as "include all", so we're
              // not including many objects in a protobuf collection.
              setState(() => _periodsController.value =
                  periods.containsAll(allPeriods) ? {} : periods);
            },
          ),
        );
      },
    );
  }

  Widget _buildAnglersPicker() {
    return _buildEntityPicker<Angler>(
      manager: _anglerManager,
      controller: _anglersController,
      emptyValue: Strings.of(context).saveCustomReportPageAllAnglers,
      listPage: (pickerSettings) => AnglerListPage(
        pickerSettings: pickerSettings,
      ),
    );
  }

  Widget _buildSpeciesPicker() {
    return _buildEntityPicker<Species>(
      manager: _speciesManager,
      controller: _speciesController,
      emptyValue: Strings.of(context).saveCustomReportPageAllSpecies,
      listPage: (pickerSettings) => SpeciesListPage(
        pickerSettings: pickerSettings,
      ),
    );
  }

  Widget _buildBaitsPicker() {
    var allBaits = _baitManager.list().toSet();
    return _buildEntityPicker<Bait>(
      manager: _baitManager,
      controller: _baitsController,
      emptyValue: Strings.of(context).saveCustomReportPageAllBaits,
      dynamicListPage: BaitListPage(
        pickerSettings: ManageableListPagePickerSettings<dynamic>(
          onPicked: (context, items) {
            var baits = items as Set<Bait>;
            setState(() => _baitsController.value =
                baits.containsAll(allBaits) ? {} : baits);
            return true;
          },
          initialValues: _baitsController.value.isEmpty
              ? allBaits
              : _baitsController.value,
        ),
      ),
    );
  }

  Widget _buildFishingSpotsPicker() {
    return _buildEntityPicker<FishingSpot>(
      manager: _fishingSpotManager,
      controller: _fishingSpotsController,
      emptyValue: Strings.of(context).saveCustomReportPageAllFishingSpots,
      listPage: (pickerSettings) => FishingSpotListPage(
        pickerSettings: pickerSettings,
      ),
    );
  }

  Widget _buildMethodsPicker() {
    return _buildEntityPicker<Method>(
      manager: _methodManager,
      controller: _methodsController,
      emptyValue: Strings.of(context).saveCustomReportPageAllMethods,
      listPage: (pickerSettings) {
        return MethodListPage(
          pickerSettings: pickerSettings,
        );
      },
    );
  }

  Widget _buildEntityPicker<T extends GeneratedMessage>({
    required NamedEntityManager<T> manager,
    required SetInputController<T> controller,
    required String emptyValue,
    Widget Function(ManageableListPagePickerSettings<T>)? listPage,
    // Used for when a picker page can have multiple entities displayed, such
    // as a BaitListPage, which shows bait categories as well as baits. In
    // these cases a definitive type T does not work.
    Widget? dynamicListPage,
  }) {
    assert(listPage != null || dynamicListPage != null);

    return MultiListPickerInput(
      padding: insetsHorizontalDefaultVerticalWidget,
      values: controller.value.map((e) => manager.name(e)).toSet(),
      emptyValue: (context) => emptyValue,
      onTap: () {
        var pickerPage = dynamicListPage;
        if (pickerPage == null) {
          var allEntities = manager.list().toSet();
          pickerPage = listPage!(
            ManageableListPagePickerSettings<T>(
              onPicked: (context, entities) {
                // Treat an empty controller value as "include all", so we're
                // not including 100s of objects in a protobuf collection.
                setState(() => controller.value =
                    entities.containsAll(allEntities) ? {} : entities);
                return true;
              },
              initialValues:
                  controller.value.isEmpty ? allEntities : controller.value,
            ),
          );
        }

        push(
          context,
          pickerPage,
        );
      },
    );
  }

  FutureOr<bool> _save(BuildContext context) {
    dynamic report;
    switch (_typeController.value!) {
      case _ReportType.summary:
        report = _createSummaryReport();
        break;
      case _ReportType.comparison:
        report = _createComparisonReport();
        break;
    }

    // Remove old report, in case an edit changed the type of report. A change
    // in type requires using a different manager.
    if (_editing) {
      if (_oldReport is SummaryReport) {
        _summaryReportManager.delete((_oldReport as SummaryReport).id);
      } else if (_oldReport is ComparisonReport) {
        _comparisonReportManager.delete((_oldReport as ComparisonReport).id);
      } else {
        _log.e("Unhandled old report type: $report");
      }
    }

    _addOrUpdate(report);
    return true;
  }

  void _addOrUpdate(dynamic report) {
    if (report == null) {
      return;
    }

    if (report is SummaryReport) {
      _summaryReportManager.addOrUpdate(report);
    } else if (report is ComparisonReport) {
      _comparisonReportManager.addOrUpdate(report);
    } else {
      _log.e("Unhandled report type: $report");
    }
  }

  SummaryReport _createSummaryReport() {
    var dateRange = _fromDateRangeController.value!;
    var custom = dateRange == DisplayDateRange.custom;

    var report = SummaryReport()
      ..id = _oldReport?.id ?? randomId()
      ..name = _nameController.value!
      ..displayDateRangeId = dateRange.id
      ..periods.addAll(_periodsController.value)
      ..anglerIds.addAll(_anglersController.value.map((e) => e.id))
      ..baitIds.addAll(_baitsController.value.map((e) => e.id))
      ..fishingSpotIds.addAll(_fishingSpotsController.value.map((e) => e.id))
      ..methodIds.addAll(_methodsController.value.map((e) => e.id))
      ..speciesIds.addAll(_speciesController.value.map((e) => e.id));

    if (isNotEmpty(_descriptionController.value)) {
      report.description = _descriptionController.value!;
    }

    if (_favoritesOnlyController.value) {
      report.isFavoritesOnly = true;
    }

    if (custom) {
      report.startTimestamp = Int64(dateRange.value(context).startMs);
      report.endTimestamp = Int64(dateRange.value(context).endMs);
    }

    return report;
  }

  ComparisonReport _createComparisonReport() {
    var fromDateRange = _fromDateRangeController.value!;
    var toDateRange = _toDateRangeController.value!;
    var customFrom = fromDateRange == DisplayDateRange.custom;
    var customTo = toDateRange == DisplayDateRange.custom;

    var report = ComparisonReport()
      ..id = _oldReport?.id ?? randomId()
      ..name = _nameController.value!
      ..fromDisplayDateRangeId = fromDateRange.id
      ..toDisplayDateRangeId = toDateRange.id
      ..periods.addAll(_periodsController.value)
      ..anglerIds.addAll(_anglersController.value.map((e) => e.id))
      ..baitIds.addAll(_baitsController.value.map((e) => e.id))
      ..fishingSpotIds.addAll(_fishingSpotsController.value.map((e) => e.id))
      ..methodIds.addAll(_methodsController.value.map((e) => e.id))
      ..speciesIds.addAll(_speciesController.value.map((e) => e.id));

    if (isNotEmpty(_descriptionController.value)) {
      report.description = _descriptionController.value!;
    }

    if (_favoritesOnlyController.value) {
      report.isFavoritesOnly = true;
    }

    if (customFrom) {
      report.fromStartTimestamp = Int64(fromDateRange.value(context).startMs);
      report.fromEndTimestamp = Int64(fromDateRange.value(context).endMs);
    }

    if (customTo) {
      report.toStartTimestamp = Int64(toDateRange.value(context).startMs);
      report.toEndTimestamp = Int64(toDateRange.value(context).endMs);
    }

    return report;
  }
}

enum _ReportType { summary, comparison }
