import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/comparison_report_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/gen/google/protobuf/timestamp.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/report_manager.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/summary_report_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/bait_list_page.dart';
import 'package:mobile/pages/fishing_spot_list_page.dart';
import 'package:mobile/pages/form_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/validator.dart';
import 'package:mobile/widgets/date_range_picker_input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/input_data.dart';
import 'package:mobile/widgets/multi_list_picker_input.dart';
import 'package:mobile/widgets/radio_input.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mobile/widgets/widget.dart';

class SaveReportPage extends StatefulWidget {
  final dynamic oldReport;

  SaveReportPage() : oldReport = null;
  SaveReportPage.edit(this.oldReport) : assert(oldReport != null);

  @override
  _SaveReportPageState createState() => _SaveReportPageState();
}

class _SaveReportPageState extends State<SaveReportPage> {
  static final _idName = Id.random();
  static final _idDescription = Id.random();
  static final _idType = Id.random();
  static final _idStartDateRange = Id.random();
  static final _idEndDateRange = Id.random();
  static final _idSpecies = Id.random();
  static final _idBaits = Id.random();
  static final _idFishingSpots = Id.random();

  final Key _keySummaryStart = ValueKey(0);
  final Key _keyComparisonStart = ValueKey(1);

  final Map<Id, InputData> _fields = {};

  BaitManager get _baitManager => BaitManager.of(context);
  ComparisonReportManager get _comparisonReportManager =>
      ComparisonReportManager.of(context);
  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);
  SpeciesManager get _speciesManager => SpeciesManager.of(context);
  SummaryReportManager get _summaryReportManager =>
      SummaryReportManager.of(context);

  TextInputController get _nameController => _fields[_idName].controller;
  TextInputController get _descriptionController =>
      _fields[_idDescription].controller;
  InputController<_ReportType> get _typeController =>
      _fields[_idType].controller;
  InputController<DisplayDateRange> get _fromDateRangeController =>
      _fields[_idStartDateRange].controller;
  InputController<DisplayDateRange> get _toDateRangeController =>
      _fields[_idEndDateRange].controller;
  InputController<Set<Id>> get _speciesController =>
      _fields[_idSpecies].controller;
  InputController<Set<Id>> get _baitsController => _fields[_idBaits].controller;
  InputController<Set<Id>> get _fishingSpotsController =>
      _fields[_idFishingSpots].controller;

  bool get _editing => widget.oldReport != null;
  bool get _summary => _typeController.value == _ReportType.summary;

  @override
  void initState() {
    super.initState();

    _fields[_idName] = InputData(
      id: _idName,
      controller: TextInputController(
        validator: NameValidator(
          nameExistsMessage: (context) =>
              Strings.of(context).saveCustomReportPageNameExists,
          nameExists: (newName) =>
              _comparisonReportManager.nameExists(newName)
                  || _summaryReportManager.nameExists(newName),
          oldName: widget.oldReport?.name,
        ),
      ),
    );

    _fields[_idDescription] = InputData(
      id: _idDescription,
      controller: TextInputController(),
    );

    _fields[_idType] = InputData(
      id: _idType,
      controller: InputController<_ReportType>(),
    );

    _fields[_idStartDateRange] = InputData(
      id: _idStartDateRange,
      controller: InputController<DisplayDateRange>(),
    );

    _fields[_idEndDateRange] = InputData(
      id: _idStartDateRange,
      controller: InputController<DisplayDateRange>(),
    );

    _fields[_idSpecies] = InputData(
      id: _idSpecies,
      controller: InputController<Set<Species>>(),
    );

    _fields[_idBaits] = InputData(
      id: _idBaits,
      controller: InputController<Set<Bait>>(),
    );

    _fields[_idFishingSpots] = InputData(
      id: _idFishingSpots,
      controller: InputController<Set<FishingSpot>>(),
    );

    if (widget.oldReport != null) {
      if (widget.oldReport is SummaryReport) {
        var report = widget.oldReport as SummaryReport;
        _nameController.value = report.name;
        _descriptionController.value = report.description;
        _typeController.value = _ReportType.summary;
        _fromDateRangeController.value = DisplayDateRange.of(
            report.displayDateRangeId, report.startTimestamp,
            report.endTimestamp);
        _baitsController.value = Id.fromByteList(report.baitIds);
        _fishingSpotsController.value = Id.fromByteList(report.fishingSpotIds);
        _speciesController.value = Id.fromByteList(report.speciesIds);
      } else if (widget.oldReport is ComparisonReport) {
        var report = widget.oldReport as ComparisonReport;
        _nameController.value = report.name;
        _descriptionController.value = report.description;
        _typeController.value = _ReportType.comparison;
        _fromDateRangeController.value = DisplayDateRange.of(
            report.fromDisplayDateRangeId, report.fromStartTimestamp,
            report.fromEndTimestamp);
        _toDateRangeController.value = DisplayDateRange.of(
            report.toDisplayDateRangeId, report.toStartTimestamp,
            report.toEndTimestamp);
        _baitsController.value = Id.fromByteList(report.baitIds);
        _fishingSpotsController.value = Id.fromByteList(report.fishingSpotIds);
        _speciesController.value = Id.fromByteList(report.speciesIds);
      }
    } else {
      _typeController.value = _ReportType.summary;
      _fromDateRangeController.value = DisplayDateRange.allDates;
    }
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
        _idSpecies: _buildSpeciesPicker(),
        _idBaits: _buildBaitsPicker(),
        _idFishingSpots: _buildFishingSpotsPicker(),
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
      child: TextInput.name(context,
        controller: _nameController,
        autofocus: true,
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
      child: TextInput.description(context,
        controller: _descriptionController,
      ),
    );
  }

  Widget _buildType() {
    return RadioInput(
      padding: insetsVerticalWidgetSmall,
      initialSelectedIndex: _typeController.value.index,
      optionCount: _ReportType.values.length,
      optionBuilder: (context, index) {
        var type = _ReportType.values[index];
        switch (type) {
          case _ReportType.comparison:
            return Strings.of(context).saveCustomReportPageComparison;
          case _ReportType.summary:
            return Strings.of(context).saveCustomReportPageSummary;
        }
        // Shouldn't ever happen.
        return null;
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

  Widget _startDateRangePicker(Key key, String title) {
    return DateRangePickerInput(
      key: key,
      title: title,
      initialDateRange: _fromDateRangeController.value,
      onPicked: (dateRange) => setState(() {
        _fromDateRangeController.value = dateRange;
      }),
    );
  }

  Widget _buildEndDateRange() {
    return AnimatedSwitcher(
      duration: defaultAnimationDuration,
      child: _summary ? Empty() : DateRangePickerInput(
        title: Strings.of(context).saveCustomReportPageEndDateRangeLabel,
        initialDateRange: _toDateRangeController.value,
        onPicked: (dateRange) => setState(() {
          _toDateRangeController.value = dateRange;
        }),
      ),
    );
  }

  Widget _buildSpeciesPicker() {
    return MultiListPickerInput(
      padding: insetsHorizontalDefaultVerticalWidget,
      values: _speciesController
          .value?.map((id) => _speciesManager.entity(id).name)?.toSet(),
      emptyValue: (context) =>
          Strings.of(context).saveCustomReportPageAllSpecies,
      onTap: () {
        push(context, SpeciesListPage.picker(
          multiPicker: true,
          initialValues: _speciesController.value,
          onPicked: (context, pickedSpecies) {
            setState(() {
              _speciesController.value = pickedSpecies;
            });
            return true;
          },
        ));
      },
    );
  }

  Widget _buildBaitsPicker() {
    return MultiListPickerInput(
      padding: insetsHorizontalDefaultVerticalWidget,
      values: _baitsController
          .value?.map((id) => _baitManager.entity(id).name)?.toSet(),
      emptyValue: (context) =>
          Strings.of(context).saveCustomReportPageAllBaits,
      onTap: () {
        push(context, BaitListPage.picker(
          multiPicker: true,
          initialValues: _baitsController.value,
          onPicked: (context, pickedBaits) {
            setState(() {
              _baitsController.value = pickedBaits;
            });
            return true;
          },
        ));
      },
    );
  }

  Widget _buildFishingSpotsPicker() {
    return MultiListPickerInput(
      padding: insetsHorizontalDefaultVerticalWidget,
      values: _fishingSpotsController
          .value?.map((id) => _fishingSpotManager.entity(id).name)?.toSet(),
      emptyValue: (context) =>
          Strings.of(context).saveCustomReportPageAllFishingSpots,
      onTap: () {
        push(context, FishingSpotListPage.picker(
          multiPicker: true,
          initialValues: _fishingSpotsController.value,
          onPicked: (context, pickedFishingSpots) {
            setState(() {
              _fishingSpotsController.value = pickedFishingSpots;
            });
            return true;
          },
        ));
      },
    );
  }

  FutureOr<bool> _save(BuildContext context) {
    dynamic report;
    switch (_typeController.value) {
      case _ReportType.summary:
        report = _createSummaryReport;
        break;
      case _ReportType.comparison:
        report = _createComparisonReport();
        break;
    }

    _customReportManager.addOrUpdate(report);

    return true;
  }

  ReportManager get _customReportManager {
    switch (_typeController.value) {
      case _ReportType.summary:
        return _summaryReportManager;
      case _ReportType.comparison:
        return _comparisonReportManager;
    }
    
    // Can't happen. Silence compiler warning.
    return null;
  }
  
  SummaryReport get _createSummaryReport {
    DisplayDateRange dateRange = _fromDateRangeController.value; 
    bool custom = dateRange == DisplayDateRange.custom;

    return SummaryReport()
      ..id = widget.oldReport?.id
      ..name = _nameController.value
      ..description = _descriptionController.value
      ..displayDateRangeId = dateRange.id
      ..startTimestamp = custom
          ? Timestamp.fromDateTime(dateRange.value.startDate) : null
      ..endTimestamp = custom
          ? Timestamp.fromDateTime(dateRange.value.endDate) : null
      ..baitIds.addAll(Id.toByteList(_baitsController.value))
      ..fishingSpotIds.addAll(Id.toByteList(_fishingSpotsController.value))
      ..speciesIds.addAll(Id.toByteList(_speciesController.value));
  }
  
  ComparisonReport _createComparisonReport() {
    DisplayDateRange fromDateRange = _fromDateRangeController.value;
    DisplayDateRange toDateRange = _toDateRangeController.value;
    bool customFrom = fromDateRange == DisplayDateRange.custom;
    bool customTo = toDateRange == DisplayDateRange.custom;

    return ComparisonReport()
      ..id = widget.oldReport?.id
      ..name = _nameController.value
      ..description = _descriptionController.value
      ..fromDisplayDateRangeId = fromDateRange.id
      ..fromStartTimestamp = customFrom
          ? Timestamp.fromDateTime(fromDateRange.value.startDate) : null
      ..fromEndTimestamp = customFrom
          ? Timestamp.fromDateTime(fromDateRange.value.endDate) : null
      ..toDisplayDateRangeId = toDateRange.id
      ..toStartTimestamp = customTo
          ? Timestamp.fromDateTime(toDateRange.value.startDate) : null
      ..toEndTimestamp = customTo
          ? Timestamp.fromDateTime(toDateRange.value.endDate) : null
      ..baitIds.addAll(Id.toByteList(_baitsController.value))
      ..fishingSpotIds.addAll(Id.toByteList(_fishingSpotsController.value))
      ..speciesIds.addAll(Id.toByteList(_speciesController.value));
  }
}

enum _ReportType {
  summary, comparison,
}