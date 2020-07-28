import 'package:flutter/material.dart';
import 'package:mobile/custom_report_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/model/species.dart';
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

  static const _endDateRangeAnimDuration = Duration(milliseconds: 150);

  final Key _keySummaryStart = ValueKey(0);
  final Key _keyComparisonStart = ValueKey(1);

  final Map<String, InputData> _fields = {};

  CustomReportManager get _customReportManager =>
      CustomReportManager.of(context);

  TextInputController get _nameController => _fields[_keyName].controller;
  TextInputController get _descriptionController =>
      _fields[_keyDescription].controller;
  InputController<CustomReportType> get _typeController =>
      _fields[_keyType].controller;
  InputController<DisplayDateRange> get _startDateRangeController =>
      _fields[_keyStartDateRange].controller;
  InputController<DisplayDateRange> get _endDateRangeController =>
      _fields[_keyEndDateRange].controller;
  InputController<Set<Species>> get _speciesController =>
      _fields[_keySpecies].controller;

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
          nameExists: (newName) => _customReportManager.nameExists(newName),
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

    if (widget.oldReport != null) {
      _nameController.value = widget.oldReport.name;
      _descriptionController.value = widget.oldReport.description;
      _typeController.value = widget.oldReport.type;
      // TODO: Set CatchReport properties
    } else {
      _typeController.value = CustomReportType.summary;
      _startDateRangeController.value = DisplayDateRange.allDates;
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
      },
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
      title: Strings.of(context).saveCustomReportTypeTitle,
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
      duration: _endDateRangeAnimDuration,
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
      initialDateRange: _startDateRangeController.value,
      onPicked: (dateRange) => setState(() {
        _startDateRangeController.value = dateRange;
      }),
    );
  }

  Widget _buildEndDateRange() {
    return AnimatedSwitcher(
      duration: _endDateRangeAnimDuration,
      child: _summary ? Empty() : DateRangePickerInput(
        title: Strings.of(context).saveCustomReportPageEndDateRangeLabel,
        initialDateRange: _endDateRangeController.value,
        onPicked: (dateRange) => setState(() {
          _endDateRangeController.value = dateRange;
        }),
      ),
    );
  }

  Widget _buildSpeciesPicker() {
    return MultiListPickerInput(
      padding: insetsHorizontalDefaultVerticalSmall,
      title: Strings.of(context).saveCustomReportPageSpecies,
      values: _speciesController.value?.map((species) => species.name)?.toSet(),
      emptyValue: (context) => Strings.of(context).all,
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
}