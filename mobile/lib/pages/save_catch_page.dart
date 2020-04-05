import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/widgets/date_time_picker.dart';
import 'package:mobile/widgets/input.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/widget.dart';

/// A utility class to store properties picked in a catch journey.
class CatchPageJourneyHelper {
  final List<PickedImage> images;
  final Species species;
  final FishingSpot fishingSpot;

  CatchPageJourneyHelper({
    this.images,
    this.species,
    this.fishingSpot,
  }) : assert(species != null);
}

class SaveCatchPage extends StatefulWidget {
  /// If set, invoked when it's time to pop the page from the navigation stack.
  final VoidCallback popOverride;

  final CatchPageJourneyHelper journeyHelper;

  SaveCatchPage({
    this.popOverride,
  }) : journeyHelper = null;

  SaveCatchPage.fromJourney({
    this.popOverride,
    @required this.journeyHelper,
  });

  @override
  _SaveCatchPageState createState() => _SaveCatchPageState();
}

class _SaveCatchPageState extends State<SaveCatchPage> {
  static const String _timestampKey = "timestamp";
  static const String _photosKey = "photos";
  static const String _speciesKey = "species";
  static const String _fishingSpotKey = "fishing_spot";
  static const String _baitKey = "bait";

  final _log = Log("SaveBaitPage");

  final Map<String, InputData> _allInputFields = {};

  List<Species> _species = [];

  SpeciesInputController get _speciesController =>
      _allInputFields[_speciesKey].controller;
  ImagesInputController get _photosController =>
      _allInputFields[_photosKey].controller;
  FishingSpotInputController get _fishingSpotController =>
      _allInputFields[_fishingSpotKey].controller;

  @override
  void initState() {
    super.initState();

    _allInputFields[_timestampKey] = InputData(
      id: _timestampKey,
      controller: TimestampInputController(
        date: DateTime.now(),
        time: TimeOfDay.now(),
      ),
      label: (BuildContext context) =>
          Strings.of(context).saveCatchPageDateTimeLabel,
      removable: false,
    );

    _allInputFields[_speciesKey] = InputData(
      id: _speciesKey,
      controller: SpeciesInputController(),
      label: (BuildContext context) =>
          Strings.of(context).saveCatchPageSpeciesLabel,
      removable: false,
    );

    _allInputFields[_photosKey] = InputData(
      id: _photosKey,
      controller: ImagesInputController(),
      label: (BuildContext context) =>
          Strings.of(context).saveCatchPagePhotosLabel,
    );

    _allInputFields[_fishingSpotKey] = InputData(
      id: _fishingSpotKey,
      controller: FishingSpotInputController(),
      label: (BuildContext context) =>
          Strings.of(context).saveCatchPageFishingSpotLabel,
    );

    _allInputFields[_baitKey] = InputData(
      id: _baitKey,
      controller: BaitInputController(),
      label: (BuildContext context) =>
          Strings.of(context).saveCatchPageBaitLabel,
    );

    if (widget.journeyHelper != null) {
      _speciesController.value = widget.journeyHelper.species;
      _photosController.value = widget.journeyHelper.images;
      _fishingSpotController.value = widget.journeyHelper.fishingSpot;
    }
  }

  @override
  Widget build(BuildContext context) {
    return EditableFormPage(
      title: Text(Strings.of(context).saveCatchPageNewTitle),
      padding: insetsZero,
      allFields: _allInputFields,
      initialFields: {
        _timestampKey: _allInputFields[_timestampKey],
        _photosKey: _allInputFields[_photosKey],
        _speciesKey: _allInputFields[_speciesKey],
        _fishingSpotKey: _allInputFields[_fishingSpotKey],
        _baitKey: _allInputFields[_baitKey],
      },
      onBuildField: (id, isRemovingFields) =>
          _buildField(context, id, isRemovingFields),
      onSave: _save,
    );
  }

  Widget _buildField(BuildContext context, String id, bool isRemovingFields) {
    switch (id) {
      case _timestampKey:
        return _buildTimestamp(context, isRemovingFields);
      case _photosKey:
        return _buildPhotos(context, isRemovingFields);
      case _speciesKey:
        return _buildSpecies(context, isRemovingFields);
      case _fishingSpotKey:
        return _buildFishingSpot(context, isRemovingFields);
      case _baitKey:
        return _buildBait(context, isRemovingFields);
      default:
        print("Unknown input key: $id");
        return Empty();
    }
  }

  Widget _buildTimestamp(BuildContext context, bool isRemovingFields) {
    TimestampInputController controller =
        _allInputFields[_timestampKey].controller;

    return Padding(
      padding: insetsHorizontalDefault,
      child: DateTimePickerContainer(
        datePicker: DatePicker(
          initialDate: controller.date,
          label: Strings.of(context).saveCatchPageDateLabel,
          enabled: !isRemovingFields,
          onChange: (DateTime newDate) {
            controller.date = newDate;
          },
        ),
        timePicker: TimePicker(
          initialTime: controller.time,
          label: Strings.of(context).saveCatchPageTimeLabel,
          enabled: !isRemovingFields,
          onChange: (TimeOfDay newTime) {
            controller.time = newTime;
          },
        ),
      ),
    );
  }

  Widget _buildBait(BuildContext context, bool isRemovingFields) {
    return Empty();
  }

  Widget _buildFishingSpot(BuildContext context, bool isRemovingFields) {
    return Empty();
  }

  Widget _buildSpecies(BuildContext context, bool isRemovingFields) {
    return ListPickerInput<Species>.single(
      initialValue: _speciesController.value,
      pageTitle: Text(Strings.of(context).speciesPickerPageTitle),
      enabled: !isRemovingFields,
      labelText: Strings.of(context).saveCatchPageSpeciesLabel,
      futureStreamHolder: SpeciesPickerFutureStreamHolder(context,
        currentValue: () => _speciesController.value,
        onUpdate: (allSpecies, currentSpecies) {
          _log.d("Species updated...");
          _species = allSpecies;
          _speciesController.value = currentSpecies;
        }
      ),
      itemBuilder: () => entityListToPickerPageItemList<Species>(_species),
      onChanged: (species) => _speciesController.value = species,
      itemManager: PickerPageItemSpeciesManager(context),
      itemEqualsOldValue: (item, oldSpecies) {
        return item.value.id == oldSpecies.id;
      },
    );
  }

  Widget _buildPhotos(BuildContext context, bool isRemovingFields) {
    return Empty();
  }

  FutureOr<bool> _save(Map<String, InputData> result) {
    print("Timestamp: ${_allInputFields[_timestampKey].controller.value}");
    print("Photos: ${_allInputFields[_photosKey].controller.value}");
    print("Species: ${_allInputFields[_speciesKey].controller.value}");
    print("Fishing spot: ${_allInputFields[_fishingSpotKey].controller.value}");
    print("Bait: ${_allInputFields[_baitKey].controller.value}");

    if (widget.popOverride != null) {
      widget.popOverride();
      return false;
    }
    return true;
  }
}