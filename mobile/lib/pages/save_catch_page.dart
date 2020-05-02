import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/catch.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/pages/add_catch_journey.dart';
import 'package:mobile/pages/bait_list_page.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/pages/fishing_spot_picker_page.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/date_time_picker.dart';
import 'package:mobile/widgets/input_data.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:mobile/widgets/image_input.dart';
import 'package:mobile/widgets/static_fishing_spot.dart';
import 'package:mobile/widgets/widget.dart';

/// A utility class to store properties picked in a catch journey.
class CatchJourneyHelper {
  List<PickedImage> images;
  Species species;
  FishingSpot fishingSpot;
}

class SaveCatchPage extends StatefulWidget {
  /// If set, invoked when it's time to pop the page from the navigation stack.
  final VoidCallback popOverride;

  /// Provides preselected values when displaying a [SaveCatchPage] from an
  /// [AddCatchJourney].
  final CatchJourneyHelper journeyHelper;

  /// Set to a non-null value when editing an existing [Catch].
  final Catch oldCatch;

  SaveCatchPage()
      : oldCatch = null,
        popOverride = null,
        journeyHelper = null;

  SaveCatchPage.edit(this.oldCatch)
      : popOverride = null,
        journeyHelper = null;

  SaveCatchPage.fromJourney({
    this.popOverride,
    @required this.journeyHelper,
  }) : assert(journeyHelper != null),
       oldCatch = null;

  @override
  _SaveCatchPageState createState() => _SaveCatchPageState();
}

class _SaveCatchPageState extends State<SaveCatchPage> {
  static const String _timestampKey = "timestamp";
  static const String _imagesKey = "images";
  static const String _speciesKey = "species";
  static const String _fishingSpotKey = "fishing_spot";
  static const String _baitKey = "bait";

  final Log _log = Log("SaveCatchPage");

  final Map<String, InputData> _fields = {};
  final Completer<GoogleMapController> _fishingSpotMapController = Completer();

  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);
  BaitManager get _baitManager => BaitManager.of(context);
  CatchManager get _catchManager => CatchManager.of(context);
  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);
  ImageManager get _imageManager => ImageManager.of(context);
  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  List<Species> get _species => _speciesManager.entityList;

  TimestampInputController get _timestampController =>
      _fields[_timestampKey].controller;
  SpeciesInputController get _speciesController =>
      _fields[_speciesKey].controller;
  ImagesInputController get _imagesController => _fields[_imagesKey].controller;
  FishingSpotInputController get _fishingSpotController =>
      _fields[_fishingSpotKey].controller;
  BaitInputController get _baitController => _fields[_baitKey].controller;

  @override
  void initState() {
    super.initState();

    _fields[_timestampKey] = InputData(
      id: _timestampKey,
      controller: TimestampInputController(
        date: DateTime.now(),
        time: TimeOfDay.now(),
      ),
      label: (BuildContext context) =>
          Strings.of(context).saveCatchPageDateTimeLabel,
      removable: false,
      showing: true,
    );

    _fields[_speciesKey] = InputData(
      id: _speciesKey,
      controller: SpeciesInputController(),
      label: (BuildContext context) =>
          Strings.of(context).saveCatchPageSpeciesLabel,
      removable: false,
      showing: true,
    );

    _fields[_baitKey] = InputData(
      id: _baitKey,
      controller: BaitInputController(),
      label: (BuildContext context) =>
          Strings.of(context).saveCatchPageBaitLabel,
      showing: true,
    );

    _fields[_imagesKey] = InputData(
      id: _imagesKey,
      controller: ImagesInputController(),
      label: (BuildContext context) =>
          Strings.of(context).saveCatchPageImagesLabel,
      showing: true,
    );

    _fields[_fishingSpotKey] = InputData(
      id: _fishingSpotKey,
      controller: FishingSpotInputController(),
      label: (BuildContext context) =>
          Strings.of(context).saveCatchPageFishingSpotLabel,
      showing: true,
    );

    if (widget.journeyHelper != null) {
      if (widget.journeyHelper.images.isNotEmpty) {
        PickedImage image = widget.journeyHelper.images.first;
        _timestampController.date = image.dateTime;
        if (image.dateTime != null) {
          _timestampController.time = TimeOfDay.fromDateTime(image.dateTime);
        }
      }
      _speciesController.value = widget.journeyHelper.species;
      _imagesController.value = widget.journeyHelper.images;
      _fishingSpotController.value = widget.journeyHelper.fishingSpot;
    }

    if (widget.oldCatch != null) {
      _timestampController.value = widget.oldCatch.timestamp;
      _speciesController.value =
          _speciesManager.entity(id: widget.oldCatch.speciesId);
      _baitController.value = _baitManager.entity(id: widget.oldCatch.baitId);
      _fishingSpotController.value =
          _fishingSpotManager.entity(id: widget.oldCatch.fishingSpotId);
      _imagesController.value = _imageManager
          .imageFiles(entityId: widget.oldCatch.id)
          .map((file) => PickedImage(originalFile: file)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return EditableFormPage(
      title: Text(widget.oldCatch == null
          ? Strings.of(context).saveCatchPageNewTitle
          : Strings.of(context).saveCatchPageEditTitle),
      runSpacing: 0,
      padding: insetsZero,
      fields: _fields,
      onBuildField: (id) => _buildField(id),
      onSave: _save,
    );
  }

  Widget _buildField(String id) {
    switch (id) {
      case _timestampKey:
        return _buildTimestamp();
      case _imagesKey:
        return _buildImages();
      case _speciesKey:
        return _buildSpecies();
      case _fishingSpotKey:
        return _buildFishingSpot();
      case _baitKey:
        return _buildBait();
      default:
        _log.e("Unknown input key: $id");
        return Empty();
    }
  }

  Widget _buildTimestamp() {
    TimestampInputController controller =
        _fields[_timestampKey].controller;

    return Padding(
      padding: EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingWidgetSmall,
      ),
      child: DateTimePickerContainer(
        datePicker: DatePicker(
          initialDate: controller.date,
          label: Strings.of(context).saveCatchPageDateLabel,
          onChange: (DateTime newDate) {
            controller.date = newDate;
          },
        ),
        timePicker: TimePicker(
          initialTime: controller.time,
          label: Strings.of(context).saveCatchPageTimeLabel,
          onChange: (TimeOfDay newTime) {
            controller.time = newTime;
          },
        ),
      ),
    );
  }

  Widget _buildBait() {
    return ListPickerInput<Bait>.customTap(
      label: Strings.of(context).saveCatchPageBaitLabel,
      listenerManager: _baitManager,
      valueBuilder: () {
        var bait = _baitController.value;
        if (bait == null) {
          return null;
        }

        var category;
        if (bait.categoryId != null) {
          category = _baitCategoryManager.entity(id: bait.categoryId);
        }

        return formatBaitName(bait, category);
      },
      onTap: () {
        push(context, BaitListPage.picker(
          onPicked: (pickedBait) {
            setState(() {
              _baitController.value = pickedBait;
            });
          },
        ));
      },
    );
  }

  Widget _buildFishingSpot() {
    FishingSpot fishingSpot = _fishingSpotController.value;

    if (fishingSpot == null) {
      return ListItem(
        title: Text(Strings.of(context).saveCatchPageFishingSpotLabel),
        trailing: RightChevronIcon(),
        onTap: () {
          _pushFishingSpotPicker();
        },
      );
    }

    return StaticFishingSpot(fishingSpot,
      padding: EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        top: paddingSmall,
        bottom: paddingSmall,
      ),
      mapController: _fishingSpotMapController,
      onTap: _pushFishingSpotPicker,
    );
  }

  Widget _buildSpecies() {
    return ListPickerInput<Species>.single(
      initialValue: _speciesController.value,
      pageTitle: Text(Strings.of(context).speciesPickerPageTitle),
      labelText: Strings.of(context).saveCatchPageSpeciesLabel,
      listenerManager: _speciesManager,
      itemBuilder: () => entityListToPickerPageItemList<Species>(_species),
      onChanged: (species) => _speciesController.value = species,
      itemManager: PickerPageItemSpeciesManager(context),
      itemEqualsOldValue: (item, oldSpecies) {
        return item.value.id == oldSpecies.id;
      },
    );
  }

  Widget _buildImages() {
    return ImageInput(
      initialImages: _imagesController.value ?? [],
      onImagesPicked: (images) {
        setState(() {
          _imagesController.value = images;
        });
      },
    );
  }

  FutureOr<bool> _save(Map<String, InputData> result) {
    Catch cat = Catch(
      id: widget.oldCatch?.id,
      timestamp: _timestampController.value,
      speciesId: _speciesController.value.id,
      fishingSpotId: _fishingSpotController.value?.id,
      baitId: _baitController.value?.id,
    );

    _catchManager.addOrUpdate(cat,
      fishingSpot: _fields[_fishingSpotKey].controller.value,
      imageFiles: _imagesController.value.map((img) => img.originalFile)
          .toList(),
    );

    if (widget.popOverride != null) {
      widget.popOverride();
      return false;
    }
    return true;
  }

  void _pushFishingSpotPicker() {
    push(context, FishingSpotPickerPage(
      fishingSpot: _fishingSpotController.value,
      onPicked: (context, pickedFishingSpot) {
        if (pickedFishingSpot != _fishingSpotController.value) {
          setState(() {
            _fishingSpotController.value = pickedFishingSpot;
            moveMap(_fishingSpotMapController, pickedFishingSpot.latLng, false);
          });
        }
        Navigator.pop(context);
      },
    ));
  }
}