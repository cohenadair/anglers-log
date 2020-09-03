import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/custom_comparison_report_manager.dart';
import 'package:mobile/custom_report_manager.dart';
import 'package:mobile/custom_summary_report_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/custom_comparison_report.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/model/custom_summary_report.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/species.dart';
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

class SaveCustomReportPage extends StatefulWidget {
  final CustomReport oldReport;

  SaveCustomReportPage() : oldReport = null;
  SaveCustomReportPage.edit(this.oldReport);

  @override
  _SaveCustomReportPageState createState() => _SaveCustomReportPageState();
}

class _SaveCustomReportPageState extends State<SaveCustomReportPage> {
  static const _keyName = "name";
  static const _keyDescription = "description";
  static const _keyType = "type";
  static const _keyStartDateRange = "start_date_range";
  static const _keyEndDateRange = "end_date_range";
  static const _keySpecies = "species";
  static const _keyBaits = "baits";
  static const _keyFishingSpots = "fishing_spots";

  final Key _keySummaryStart = ValueKey(0);
  final Key _keyComparisonStart = ValueKey(1);

  final Map<String, InputData> _fields = {};

  CustomComparisonReportManager get _customComparisonReportManager =>
      CustomComparisonReportManager.of(context);
  CustomSummaryReportManager get _customSummaryReportManager =>
      CustomSummaryReportManager.of(context);

  TextInputController get _nameController => _fields[_keyName].controller;
  TextInputController get _descriptionController =>
      _fields[_keyDescription].controller;
  InputController<CustomReportType> get _typeController =>
      _fields[_keyType].controller;
  InputController<DisplayDateRange> get _fromDateRangeController =>
      _fields[_keyStartDateRange].controller;
  InputController<DisplayDateRange> get _toDateRangeController =>
      _fields[_keyEndDateRange].controller;
  InputController<Set<Species>> get _speciesController =>
      _fields[_keySpecies].controller;
  InputController<Set<Bait>> get _baitsController =>
      _fields[_keyBaits].controller;
  InputController<Set<FishingSpot>> get _fishingSpotsController =>
      _fields[_keyFishingSpots].controller;

  bool get _editing => widget.oldReport != null;
  bool get _summary => _typeController.value == CustomReportType.summary;

  @override
  void initState() {
    super.initState();

    _fields[_keyName] = InputData(
      id: _keyName,
      controller: TextInputController(
        validator: NameValidator(
          nameExistsMessage: (context) =>
              Strings.of(context).saveCustomReportPageNameExists,
          nameExists: (newName) =>
              _customComparisonReportManager.nameExists(newName)
                  || _customSummaryReportManager.nameExists(newName),
          oldName: widget.oldReport?.name,
        ),
      ),
    );

    _fields[_keyDescription] = InputData(
      id: _keyDescription,
      controller: TextInputController(),
    );

    _fields[_keyType] = InputData(
      id: _keyType,
      controller: InputController<CustomReportType>(),
    );

    _fields[_keyStartDateRange] = InputData(
      id: _keyStartDateRange,
      controller: InputController<DisplayDateRange>(),
    );

    _fields[_keyEndDateRange] = InputData(
      id: _keyStartDateRange,
      controller: InputController<DisplayDateRange>(),
    );

    _fields[_keySpecies] = InputData(
      id: _keySpecies,
      controller: InputController<Set<Species>>(),
    );

    _fields[_keyBaits] = InputData(
      id: _keyBaits,
      controller: InputController<Set<Bait>>(),
    );

    _fields[_keyFishingSpots] = InputData(
      id: _keyFishingSpots,
      controller: InputController<Set<FishingSpot>>(),
    );

    if (widget.oldReport != null) {
      _nameController.value = widget.oldReport.name;
      _descriptionController.value = widget.oldReport.description;
      _typeController.value = widget.oldReport.type;

      if (widget.oldReport is CustomSummaryReport) {
        var report = widget.oldReport as CustomSummaryReport;
        _fromDateRangeController.value = DisplayDateRange.of(
            report.displayDateRangeId, report.startTimestamp,
            report.endTimestamp);
      } else if (widget.oldReport is CustomComparisonReport) {
        var report = widget.oldReport as CustomComparisonReport;
        _fromDateRangeController.value = DisplayDateRange.of(
            report.fromDisplayDateRangeId, report.fromStartTimestamp,
            report.fromEndTimestamp);
        _toDateRangeController.value = DisplayDateRange.of(
            report.toDisplayDateRangeId, report.toStartTimestamp,
            report.toEndTimestamp);
      }

      CustomReportManager manager = _customReportManager;
      _baitsController.value =
          manager.baits(widget.oldReport.id).toSet();
      _fishingSpotsController.value =
          manager.fishingSpots(widget.oldReport.id).toSet();
      _speciesController.value =
          manager.species(widget.oldReport.id).toSet();
    } else {
      _typeController.value = CustomReportType.summary;
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
        _keyName: _buildName(),
        _keyDescription: _buildDescription(),
        _keyType: _buildType(),
        _keyStartDateRange: _buildStartDateRange(),
        _keyEndDateRange: _buildEndDateRange(),
        _keySpecies: _buildSpeciesPicker(),
        _keyBaits: _buildBaitsPicker(),
        _keyFishingSpots: _buildFishingSpotsPicker(),
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
      optionCount: CustomReportType.values.length,
      optionBuilder: (context, index) {
        var type = CustomReportType.values[index];
        switch (type) {
          case CustomReportType.comparison:
            return Strings.of(context).saveCustomReportPageComparison;
          case CustomReportType.summary:
            return Strings.of(context).saveCustomReportPageSummary;
        }
        // Shouldn't ever happen.
        return null;
      },
      onSelect: (index) => setState(() {
        _typeController.value = CustomReportType.values[index];
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
      values: _speciesController.value?.map((species) => species.name)?.toSet(),
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
      values: _baitsController.value?.map((bait) => bait.name)?.toSet(),
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
      values: _fishingSpotsController.value?.map((bait) => bait.name)?.toSet(),
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
    CustomReport report;
    switch (_typeController.value) {
      case CustomReportType.summary:
        report = _createSummaryReport;
        break;
      case CustomReportType.comparison:
        report = _createComparisonReport();
        break;
    }

    _customReportManager.addOrUpdate(
      report,
      baits: _baitsController.value,
      fishingSpots: _fishingSpotsController.value,
      species: _speciesController.value,
    );

    return true;
  }

  CustomReportManager<CustomReport> get _customReportManager {
    switch (_typeController.value) {
      case CustomReportType.summary:
        return _customSummaryReportManager;
      case CustomReportType.comparison:
        return _customComparisonReportManager;
    }
    
    // Can't happen. Silence compiler warning.
    return null;
  }
  
  CustomSummaryReport get _createSummaryReport {
    DisplayDateRange dateRange = _fromDateRangeController.value; 
    bool custom = dateRange == DisplayDateRange.custom;

    return CustomSummaryReport(
      id: widget.oldReport?.id,
      name: _nameController.value,
      description: _descriptionController.value,
      entityType: EntityType.fishCatch,
      displayDateRangeId: dateRange.id,
      startTimestamp: custom ? dateRange.value.startMs : null,
      endTimestamp: custom ? dateRange.value.endMs : null,
    );
  }
  
  CustomComparisonReport _createComparisonReport() {
    DisplayDateRange fromDateRange = _fromDateRangeController.value;
    DisplayDateRange toDateRange = _toDateRangeController.value;
    bool customFrom = fromDateRange == DisplayDateRange.custom;
    bool customTo = toDateRange == DisplayDateRange.custom;

    return CustomComparisonReport(
      id: widget.oldReport?.id,
      name: _nameController.value,
      description: _descriptionController.value,
      entityType: EntityType.fishCatch,
      fromDisplayDateRangeId: fromDateRange.id,
      fromStartTimestamp: customFrom ? fromDateRange.value.startMs : null,
      fromEndTimestamp: customFrom ? fromDateRange.value.endMs : null,
      toDisplayDateRangeId: toDateRange.id,
      toStartTimestamp: customTo ? toDateRange.value.startMs : null,
      toEndTimestamp: customTo ? toDateRange.value.endMs : null,
    );
  }
}