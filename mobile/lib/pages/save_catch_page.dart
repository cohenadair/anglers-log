import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';

import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../catch_manager.dart';
import '../entity_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../image_manager.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/bait_list_page.dart';
import '../pages/editable_form_page.dart';
import '../pages/fishing_spot_picker_page.dart';
import '../pages/image_picker_page.dart';
import '../pages/species_list_page.dart';
import '../res/dimen.dart';
import '../species_manager.dart';
import '../time_manager.dart';
import '../user_preference_manager.dart';
import '../utils/catch_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/image_input.dart';
import '../widgets/input_controller.dart';
import '../widgets/input_data.dart';
import '../widgets/list_item.dart';
import '../widgets/list_picker_input.dart';
import '../widgets/static_fishing_spot.dart';
import '../widgets/widget.dart';
import 'manageable_list_page.dart';

class SaveCatchPage extends StatefulWidget {
  /// If set, invoked when it's time to pop the page from the navigation stack.
  final VoidCallback popOverride;

  final List<PickedImage> images;
  final Id speciesId;
  final Id fishingSpotId;

  final Catch oldCatch;

  /// See [EditableFormPage.popupMenuKey].
  final GlobalKey<PopupMenuButtonState> popupMenuKey;

  SaveCatchPage({
    this.popupMenuKey,
    this.images = const [],
    this.speciesId,
    this.fishingSpotId,
    this.popOverride,
  })  : assert(images != null),
        oldCatch = null;

  SaveCatchPage.edit(this.oldCatch)
      : assert(oldCatch != null),
        popupMenuKey = null,
        popOverride = null,
        images = const [],
        speciesId = null,
        fishingSpotId = null;

  @override
  _SaveCatchPageState createState() => _SaveCatchPageState();
}

class _SaveCatchPageState extends State<SaveCatchPage> {
  static final _idTimestamp = catchFieldIdTimestamp();
  static final _idImages = catchFieldIdImages();
  static final _idSpecies = catchFieldIdSpecies();
  static final _idFishingSpot = catchFieldIdFishingSpot();
  static final _idBait = catchFieldIdBait();

  final _log = Log("SaveCatchPage");

  final Map<Id, Field> _fields = {};

  Future<List<PickedImage>> _imagesFuture = Future.value([]);
  List<CustomEntityValue> _customEntityValues = [];

  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  CatchManager get _catchManager => CatchManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  ImageManager get _imageManager => ImageManager.of(context);

  UserPreferenceManager get _userPreferencesManager =>
      UserPreferenceManager.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  TimeManager get _timeManager => TimeManager.of(context);

  Catch get _oldCatch => widget.oldCatch;

  TimestampInputController get _timestampController =>
      _fields[_idTimestamp].controller;

  InputController<Id> get _speciesController => _fields[_idSpecies].controller;

  InputController<List<PickedImage>> get _imagesController =>
      _fields[_idImages].controller;

  InputController<Id> get _fishingSpotController =>
      _fields[_idFishingSpot].controller;

  InputController<Id> get _baitController => _fields[_idBait].controller;

  bool get _editing => _oldCatch != null;

  @override
  void initState() {
    super.initState();

    var showingFieldIds = _userPreferencesManager.catchFieldIds;
    for (var field in allCatchFields()) {
      _fields[field.id] = field;
      // By default, show all fields.
      _fields[field.id].showing = showingFieldIds == null ||
          showingFieldIds.isEmpty ||
          showingFieldIds.contains(field.id);
    }

    if (_editing) {
      _timestampController.value = _oldCatch.timestamp.toInt();
      _speciesController.value = _oldCatch.speciesId;
      _baitController.value = _oldCatch.baitId;
      _fishingSpotController.value = _oldCatch.fishingSpotId;
      _customEntityValues = _oldCatch.customEntityValues;
      _imagesFuture = _pickedImagesForOldCatch;
    } else {
      if (widget.images.isNotEmpty) {
        var image = widget.images.first;
        if (image.dateTime != null) {
          _timestampController.date = image.dateTime;
          _timestampController.time = TimeOfDay.fromDateTime(image.dateTime);
        }
      }
      _speciesController.value = widget.speciesId;
      _imagesController.value = widget.images;
      _fishingSpotController.value = widget.fishingSpotId;
    }
  }

  @override
  Widget build(BuildContext context) {
    _timestampController.date =
        _timestampController.date ?? _timeManager.currentDateTime;
    _timestampController.time =
        _timestampController.time ?? _timeManager.currentTime;

    return EditableFormPage(
      popupMenuKey: widget.popupMenuKey,
      title: Text(_editing
          ? Strings.of(context).saveCatchPageEditTitle
          : Strings.of(context).saveCatchPageNewTitle),
      runSpacing: 0,
      padding: insetsZero,
      fields: _fields,
      customEntityIds: _userPreferencesManager.catchCustomEntityIds,
      customEntityValues: _customEntityValues,
      onBuildField: _buildField,
      onAddFields: (ids) =>
          _userPreferencesManager.catchFieldIds = ids.toList(),
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: paddingWidgetSmall,
      ),
      child: DateTimePicker(
        datePicker: DatePicker(
          context,
          initialDate: _timestampController.date,
          label: Strings.of(context).catchFieldDate,
          onChange: (newDate) => _timestampController.date = newDate,
        ),
        timePicker: TimePicker(
          context,
          initialTime: _timestampController.time,
          label: Strings.of(context).catchFieldTime,
          onChange: (newTime) => _timestampController.time = newTime,
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
        if (_baitController.value != null) {
          value = _baitManager.formatNameWithCategory(_baitController.value);
        }

        return ListPickerInput(
          title: Strings.of(context).catchFieldBaitLabel,
          value: value,
          onTap: () {
            push(
              context,
              BaitListPage(
                pickerSettings:
                    ManageableListPagePickerSettings<dynamic>.single(
                  onPicked: (context, bait) {
                    setState(() => _baitController.value = bait?.id);
                    return true;
                  },
                  initialValue: _baitManager.entity(_baitController.value),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFishingSpot() {
    return EntityListenerBuilder(
      managers: [
        _fishingSpotManager,
      ],
      builder: (context) {
        var fishingSpot =
            _fishingSpotManager.entity(_fishingSpotController.value);

        if (fishingSpot == null) {
          return ListItem(
            title: Text(Strings.of(context).catchFieldFishingSpot),
            trailing: RightChevronIcon(),
            onTap: _pushFishingSpotPicker,
          );
        }

        return StaticFishingSpot(
          fishingSpot,
          padding: insetsHorizontalDefaultVerticalSmall,
          onTap: _pushFishingSpotPicker,
        );
      },
    );
  }

  Widget _buildSpecies() {
    return EntityListenerBuilder(
      managers: [
        _speciesManager,
      ],
      builder: (context) {
        var species = _speciesManager.entity(_speciesController.value);
        return ListPickerInput(
          title: Strings.of(context).catchFieldSpecies,
          value: species?.name,
          onTap: () {
            push(
              context,
              SpeciesListPage(
                pickerSettings:
                    ManageableListPagePickerSettings<Species>.single(
                  onPicked: (context, species) {
                    setState(() => _speciesController.value = species?.id);
                    return true;
                  },
                  initialValue: species,
                  isRequired: true,
                ),
              ),
            );
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
    _userPreferencesManager.catchCustomEntityIds =
        customFieldValueMap.keys.toList();

    // imageNames is set in _catchManager.addOrUpdate
    var cat = Catch()
      ..id = _oldCatch?.id ?? randomId()
      ..timestamp = Int64(_timestampController.value)
      ..speciesId = _speciesController.value
      ..customEntityValues.addAll(entityValuesFromMap(customFieldValueMap));

    if (_fishingSpotController.value != null) {
      cat.fishingSpotId = _fishingSpotController.value;
    }

    if (_baitController.value != null) {
      cat.baitId = _baitController.value;
    }

    _catchManager.addOrUpdate(
      cat,
      imageFiles:
          _imagesController.value?.map((img) => img.originalFile)?.toList(),
    );

    if (widget.popOverride != null) {
      widget.popOverride();
      return false;
    }

    return true;
  }

  void _pushFishingSpotPicker() {
    push(
      context,
      FishingSpotPickerPage(
        fishingSpotId: _fishingSpotController.value,
        onPicked: (context, pickedFishingSpot) {
          if (pickedFishingSpot == null ||
              pickedFishingSpot.id != _fishingSpotController.value) {
            setState(() {
              _fishingSpotController.value = pickedFishingSpot?.id;
            });
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  /// Converts [oldCatch] images into a list of [PickedImage] objects to be
  /// managed by the [ImageInput].
  Future<List<PickedImage>> get _pickedImagesForOldCatch async {
    if (!_editing || _oldCatch.imageNames.isEmpty) {
      return Future.value([]);
    }

    var bytesList = await _imageManager.images(
      context,
      imageNames: _oldCatch.imageNames,
      size: galleryMaxThumbSize,
    );

    _imagesController.value =
        bytesList.map((bytes) => PickedImage(thumbData: bytes)).toList();
    return _imagesController.value;
  }
}
