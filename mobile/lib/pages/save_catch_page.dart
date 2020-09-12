import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/pages/add_catch_journey.dart';
import 'package:mobile/pages/bait_list_page.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/pages/fishing_spot_picker_page.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/preferences_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
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
  Id speciesId;

  // At this point, the FishingSpot may not be in the database, but picked on
  // the fly, so passing an ID will not work.
  FishingSpot fishingSpot;
}

class SaveCatchPage extends StatefulWidget {
  /// If set, invoked when it's time to pop the page from the navigation stack.
  final VoidCallback popOverride;

  /// Provides preselected values when displaying a [SaveCatchPage] from an
  /// [AddCatchJourney].
  final CatchJourneyHelper journeyHelper;

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
  static final _idTimestamp = Id.random();
  static final _idImages = Id.random();
  static final _idSpecies = Id.random();
  static final _idFishingSpot = Id.random();
  static final _idBait = Id.random();

  final Log _log = Log("SaveCatchPage");

  final Map<Id, InputData> _fields = {};
  final Completer<GoogleMapController> _fishingSpotMapController = Completer();

  Future<List<PickedImage>> _imagesFuture = Future.value([]);
  List<CustomEntityValue> _customEntityValues = [];

  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);
  BaitManager get _baitManager => BaitManager.of(context);
  CatchManager get _catchManager => CatchManager.of(context);
  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);
  ImageManager get _imageManager => ImageManager.of(context);
  PreferencesManager get _preferencesManager => PreferencesManager.of(context);
  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  TimestampInputController get _timestampController =>
      _fields[_idTimestamp].controller;
  InputController<Id> get _speciesController => _fields[_idSpecies].controller;
  InputController<List<PickedImage>> get _imagesController =>
      _fields[_idImages].controller;
  InputController<FishingSpot> get _fishingSpotController =>
      _fields[_idFishingSpot].controller;
  InputController<Id> get _baitController => _fields[_idBait].controller;

  @override
  void initState() {
    super.initState();

    _fields[_idTimestamp] = InputData(
      id: _idTimestamp,
      controller: TimestampInputController(
        date: DateTime.now(),
        time: TimeOfDay.now(),
      ),
      label: (BuildContext context) =>
          Strings.of(context).saveCatchPageDateTimeLabel,
      removable: false,
      showing: true,
    );

    _fields[_idSpecies] = InputData(
      id: _idSpecies,
      controller: InputController<Species>(),
      label: (BuildContext context) =>
          Strings.of(context).saveCatchPageSpeciesLabel,
      removable: false,
      showing: true,
    );

    _fields[_idBait] = InputData(
      id: _idBait,
      controller: InputController<Bait>(),
      label: (BuildContext context) =>
          Strings.of(context).saveCatchPageBaitLabel,
      showing: true,
    );

    _fields[_idImages] = InputData(
      id: _idImages,
      controller: InputController<List<PickedImage>>(),
      label: (BuildContext context) =>
          Strings.of(context).saveCatchPageImagesLabel,
      showing: true,
    );

    _fields[_idFishingSpot] = InputData(
      id: _idFishingSpot,
      controller: InputController<FishingSpot>(),
      label: (BuildContext context) =>
          Strings.of(context).saveCatchPageFishingSpotLabel,
      showing: true,
    );

    if (widget.journeyHelper != null) {
      if (widget.journeyHelper.images.isNotEmpty) {
        PickedImage image = widget.journeyHelper.images.first;
        if (image.dateTime != null) {
          _timestampController.date = image.dateTime;
          _timestampController.time = TimeOfDay.fromDateTime(image.dateTime);
        }
      }
      _speciesController.value = widget.journeyHelper.speciesId;
      _imagesController.value = widget.journeyHelper.images;
      _fishingSpotController.value = widget.journeyHelper.fishingSpot;
    }

    if (widget.oldCatch != null) {
      _timestampController.value = widget.oldCatch.timestamp;
      _speciesController.value = Id(widget.oldCatch.speciesId);
      _baitController.value = Id(widget.oldCatch.baitId);
      _fishingSpotController.value =
          _fishingSpotManager.entity(Id(widget.oldCatch.fishingSpotId));
      _customEntityValues = widget.oldCatch.customEntityValues;
      _imagesFuture = _pickedImagesForOldCatch;
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
      customEntityIds: _preferencesManager.catchCustomEntityIds,
      customEntityValues: _customEntityValues,
      onBuildField: (id) => _buildField(id),
      onSave: _save,
    );
  }

  Widget _buildField(Id id) {
    if (id == _idTimestamp) {
      return _buildTimestamp();
    } else if (id == _idImages) {
      return _buildImages();
    } else if (id == _idSpecies) {
      return _buildSpecies();
    } else if (id == _idFishingSpot) {
      return _buildFishingSpot();
    } else if (id == _idBait) {
      return _buildBait();
    } else {
      _log.e("Unknown input key: $id");
      return Empty();
    }
  }

  Widget _buildTimestamp() {
    TimestampInputController controller =
        _fields[_idTimestamp].controller;

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
    return EntityListenerBuilder(
      managers: [
        _baitCategoryManager,
        _baitManager,
      ],
      builder: (context) {
        String value;
        Bait bait = _baitManager.entity(_baitController.value);
        if (bait != null) {
          value = _baitManager.formatNameWithCategory(bait);
        }

        return ListPickerInput(
          title: Strings.of(context).saveCatchPageBaitLabel,
          value: value,
          onTap: () {
            push(context, BaitListPage.picker(
              onPicked: (context, pickedBaits) {
                setState(() {
                  _baitController.value = pickedBaits.first;
                });
                return true;
              },
            ));
          },
        );
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
    return EntityListenerBuilder(
      managers: [ _speciesManager ],
      builder: (context) {
        return ListPickerInput(
          title: Strings.of(context).saveCatchPageSpeciesLabel,
          value: _speciesManager.entity(_speciesController.value)?.name,
          onTap: () {
            push(context, SpeciesListPage.picker(
              onPicked: (context, pickedSpecies) {
                setState(() {
                  _speciesController.value = pickedSpecies.first;
                });
                return true;
              },
            ));
          },
        );
      },
    );
  }

  Widget _buildImages() {
    return EmptyFutureBuilder<List<PickedImage>>(
      future: _imagesFuture,
      builder: (context, images) {
        return ImageInput(
          initialImages: _imagesController.value ?? [],
          onImagesPicked: (pickedImages) {
            setState(() {
              _imagesController.value = pickedImages;
              _imagesFuture = Future.value(_imagesController.value);
            });
          },
        );
      },
    );
  }

  FutureOr<bool> _save(Map<Id, dynamic> customFieldValueMap) {
    _preferencesManager.catchCustomEntityIds =
        customFieldValueMap.keys.toList();

    Catch cat = Catch()
      ..id = widget.oldCatch?.id
      ..timestamp = _timestampController.value
      ..speciesId = _speciesController.value?.bytes ?? []
      ..fishingSpotId = _fishingSpotController.value?.id ?? []
      ..baitId = _baitController.value?.bytes ?? []
      ..customEntityValues.addAll(entityValuesFromMap(customFieldValueMap));

    _catchManager.addOrUpdate(cat,
      fishingSpot: _fields[_idFishingSpot].controller.value,
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
            moveMap(_fishingSpotMapController,
                LatLng(pickedFishingSpot.lat, pickedFishingSpot.lng), false);
          });
        }
        Navigator.pop(context);
      },
    ));
  }

  /// Converts [oldCatch] images into a list of [PickedImage] objects to be
  /// managed by the [ImageInput].
  Future<List<PickedImage>> get _pickedImagesForOldCatch async {
    if (widget.oldCatch == null || widget.oldCatch.imageNames.isEmpty) {
      return Future.value([]);
    }

    List<Uint8List> bytesList = await _imageManager.images(context,
      imageNames: widget.oldCatch.imageNames,
      size: galleryMaxThumbSize,
    );

    _imagesController.value =
        bytesList.map((bytes) => PickedImage(thumbData: bytes)).toList();
    return _imagesController.value;
  }
}