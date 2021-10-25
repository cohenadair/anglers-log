import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:mobile/widgets/entity_picker_input.dart';
import 'package:quiver/strings.dart';

import '../angler_manager.dart';
import '../app_manager.dart';
import '../atmosphere_fetcher.dart';
import '../catch_manager.dart';
import '../entity_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../location_monitor.dart';
import '../log.dart';
import '../method_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/editable_form_page.dart';
import '../pages/image_picker_page.dart';
import '../pages/species_list_page.dart';
import '../res/dimen.dart';
import '../species_manager.dart';
import '../subscription_manager.dart';
import '../user_preference_manager.dart';
import '../utils/catch_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../water_clarity_manager.dart';
import '../widgets/atmosphere_input.dart';
import '../widgets/checkbox_input.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/field.dart';
import '../widgets/fishing_spot_details.dart';
import '../widgets/fishing_spot_map.dart';
import '../widgets/image_input.dart';
import '../widgets/input_controller.dart';
import '../widgets/list_item.dart';
import '../widgets/list_picker_input.dart';
import '../widgets/multi_measurement_input.dart';
import '../widgets/text_input.dart';
import '../widgets/tide_input.dart';
import '../widgets/widget.dart';
import 'angler_list_page.dart';
import 'bait_list_page.dart';
import 'form_page.dart';
import 'method_list_page.dart';
import 'water_clarity_list_page.dart';

class SaveCatchPage extends StatefulWidget {
  /// If set, invoked when it's time to pop the page from the navigation stack.
  final VoidCallback? popOverride;

  final List<PickedImage> images;
  final Id? speciesId;
  final FishingSpot? fishingSpot;

  final Catch? oldCatch;

  /// See [EditableFormPage.popupMenuKey].
  final GlobalKey<PopupMenuButtonState>? popupMenuKey;

  const SaveCatchPage({
    required this.speciesId,
    this.popupMenuKey,
    this.images = const [],
    this.fishingSpot,
    this.popOverride,
  }) : oldCatch = null;

  const SaveCatchPage.edit(this.oldCatch)
      : popupMenuKey = null,
        popOverride = null,
        images = const [],
        speciesId = null,
        fishingSpot = null;

  @override
  _SaveCatchPageState createState() => _SaveCatchPageState();
}

class _SaveCatchPageState extends State<SaveCatchPage> {
  static final _idAngler = catchFieldIdAngler;
  static final _idAtmosphere = catchFieldIdAtmosphere;
  static final _idBait = catchFieldIdBait;
  static final _idCatchAndRelease = catchFieldIdCatchAndRelease;
  static final _idFavorite = catchFieldIdFavorite;
  static final _idFishingSpot = catchFieldIdFishingSpot;
  static final _idImages = catchFieldIdImages;
  static final _idLength = catchFieldIdLength;
  static final _idMethods = catchFieldIdMethods;
  static final _idNotes = catchFieldIdNotes;
  static final _idPeriod = catchFieldIdPeriod;
  static final _idQuantity = catchFieldIdQuantity;
  static final _idSeason = catchFieldIdSeason;
  static final _idSpecies = catchFieldIdSpecies;
  static final _idTide = catchFieldIdTide;
  static final _idTimestamp = catchFieldIdTimestamp;
  static final _idWaterClarity = catchFieldIdWaterClarity;
  static final _idWaterDepth = catchFieldIdWaterDepth;
  static final _idWaterTemperature = catchFieldIdWaterTemperature;
  static final _idWeight = catchFieldIdWeight;

  final _log = const Log("SaveCatchPage");
  final Map<Id, Field> _fields = {};

  late final MultiMeasurementInputSpec _waterDepthInputState;
  late final MultiMeasurementInputSpec _waterTemperatureInputState;
  late final MultiMeasurementInputSpec _lengthInputState;
  late final MultiMeasurementInputSpec _weightInputState;

  // Used to persist the user-selected season value, when the catch's timestamp
  // changes.
  bool _overwriteSeasonCalculation = false;

  List<CustomEntityValue> _customEntityValues = [];
  StreamSubscription<void>? _userPreferenceSubscription;

  AnglerManager get _anglerManager => AnglerManager.of(context);

  CatchManager get _catchManager => CatchManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);

  MethodManager get _methodManager => MethodManager.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  SubscriptionManager get _subscriptionManager =>
      SubscriptionManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  WaterClarityManager get _waterClarityManager =>
      WaterClarityManager.of(context);

  Catch? get _oldCatch => widget.oldCatch;

  TimestampInputController get _timestampController =>
      _fields[_idTimestamp]!.controller as TimestampInputController;

  InputController<Period> get _periodController =>
      _fields[_idPeriod]!.controller as InputController<Period>;

  InputController<Season> get _seasonController =>
      _fields[_idSeason]!.controller as InputController<Season>;

  IdInputController get _speciesController =>
      _fields[_idSpecies]!.controller as IdInputController;

  ImagesInputController get _imagesController =>
      _fields[_idImages]!.controller as ImagesInputController;

  InputController<FishingSpot> get _fishingSpotController =>
      _fields[_idFishingSpot]!.controller as InputController<FishingSpot>;

  SetInputController<BaitAttachment> get _baitsController =>
      _fields[_idBait]!.controller as SetInputController<BaitAttachment>;

  IdInputController get _anglerController =>
      _fields[_idAngler]!.controller as IdInputController;

  BoolInputController get _catchAndReleaseController =>
      _fields[_idCatchAndRelease]!.controller as BoolInputController;

  BoolInputController get _favoriteController =>
      _fields[_idFavorite]!.controller as BoolInputController;

  SetInputController<Id> get _methodsController =>
      _fields[_idMethods]!.controller as SetInputController<Id>;

  IdInputController get _waterClarityController =>
      _fields[_idWaterClarity]!.controller as IdInputController;

  MultiMeasurementInputController get _waterDepthController =>
      _fields[_idWaterDepth]!.controller as MultiMeasurementInputController;

  MultiMeasurementInputController get _waterTemperatureController =>
      _fields[_idWaterTemperature]!.controller
          as MultiMeasurementInputController;

  MultiMeasurementInputController get _lengthController =>
      _fields[_idLength]!.controller as MultiMeasurementInputController;

  MultiMeasurementInputController get _weightController =>
      _fields[_idWeight]!.controller as MultiMeasurementInputController;

  NumberInputController get _quantityController =>
      _fields[_idQuantity]!.controller as NumberInputController;

  TextInputController get _notesController =>
      _fields[_idNotes]!.controller as TextInputController;

  InputController<Atmosphere> get _atmosphereController =>
      _fields[_idAtmosphere]!.controller as InputController<Atmosphere>;

  InputController<Tide> get _tideController =>
      _fields[_idTide]!.controller as InputController<Tide>;

  bool get _editing => _oldCatch != null;

  @override
  void initState() {
    super.initState();

    for (var field in allCatchFields(context)) {
      _fields[field.id] = field;
    }

    // Need to set this here (rather than exclusively in EditableFormPage) so
    // the auto-fetch atmosphere method is invoked correctly.
    _fields[catchFieldIdAtmosphere]!.isShowing = _userPreferenceManager
            .catchFieldIds.isEmpty ||
        _userPreferenceManager.catchFieldIds.contains(catchFieldIdAtmosphere);

    _waterDepthInputState = MultiMeasurementInputSpec.waterDepth(context);
    _waterTemperatureInputState =
        MultiMeasurementInputSpec.waterTemperature(context);
    _lengthInputState = MultiMeasurementInputSpec.length(context);
    _weightInputState = MultiMeasurementInputSpec.weight(context);

    if (_editing) {
      _timestampController.value = _oldCatch!.timestamp.toInt();
      _periodController.value =
          _oldCatch!.hasPeriod() ? _oldCatch!.period : null;
      _seasonController.value =
          _oldCatch!.hasSeason() ? _oldCatch!.season : null;
      _speciesController.value = _oldCatch!.speciesId;
      _baitsController.value = _oldCatch!.baits.toSet();
      _fishingSpotController.value =
          _fishingSpotManager.entity(_oldCatch!.fishingSpotId);
      _anglerController.value = _oldCatch!.anglerId;
      _catchAndReleaseController.value = _oldCatch!.wasCatchAndRelease;
      _favoriteController.value = _oldCatch!.isFavorite;
      _methodsController.value = _oldCatch!.methodIds.toSet();
      _waterClarityController.value = _oldCatch!.waterClarityId;
      _waterDepthController.value =
          _oldCatch!.hasWaterDepth() ? _oldCatch!.waterDepth : null;
      _waterTemperatureController.value =
          _oldCatch!.hasWaterTemperature() ? _oldCatch!.waterTemperature : null;
      _lengthController.value =
          _oldCatch!.hasLength() ? _oldCatch!.length : null;
      _weightController.value =
          _oldCatch!.hasWeight() ? _oldCatch!.weight : null;
      _quantityController.intValue =
          _oldCatch!.hasQuantity() ? _oldCatch!.quantity : null;
      _notesController.value =
          isEmpty(_oldCatch!.notes) ? null : _oldCatch!.notes;
      _atmosphereController.value =
          _oldCatch!.hasAtmosphere() ? _oldCatch!.atmosphere : null;
      _tideController.value = _oldCatch!.hasTide() ? _oldCatch!.tide : null;
      _customEntityValues = _oldCatch!.customEntityValues;
    } else {
      if (widget.images.isNotEmpty) {
        var image = widget.images.first;
        if (image.dateTime != null) {
          _timestampController.date = image.dateTime;
          _timestampController.time = TimeOfDay.fromDateTime(image.dateTime!);
        }
      }
      _speciesController.value = widget.speciesId;
      _imagesController.value = widget.images;
      _fishingSpotController.value = widget.fishingSpot;
      _methodsController.value = {};

      _calculateSeasonIfNeeded();
      _fetchAtmosphereIfNeeded();
    }

    _userPreferenceSubscription = _userPreferenceManager.stream.listen((_) {
      _waterDepthController.system = _userPreferenceManager.waterDepthSystem;
      _waterTemperatureController.system =
          _userPreferenceManager.waterTemperatureSystem;
      _lengthController.system = _userPreferenceManager.catchLengthSystem;
      _weightController.system = _userPreferenceManager.catchWeightSystem;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userPreferenceSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return EditableFormPage(
      popupMenuKey: widget.popupMenuKey,
      title: Text(_editing
          ? Strings.of(context).saveCatchPageEditTitle
          : Strings.of(context).saveCatchPageNewTitle),
      runSpacing: 0,
      padding: insetsZero,
      fields: _fields,
      trackedFieldIds: _userPreferenceManager.catchFieldIds,
      customEntityIds: _userPreferenceManager.catchCustomEntityIds,
      customEntityValues: _customEntityValues,
      onBuildField: _buildField,
      onAddFields: (ids) =>
          _userPreferenceManager.setCatchFieldIds(ids.toList()),
      onSave: _save,
      overflowOptions: [FormPageOverflowOption.manageUnits(context)],
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
      return _buildBaits();
    } else if (id == _idAngler) {
      return _buildAngler();
    } else if (id == _idMethods) {
      return _buildMethods();
    } else if (id == _idPeriod) {
      return _buildPeriod();
    } else if (id == _idFavorite) {
      return _buildFavorite();
    } else if (id == _idCatchAndRelease) {
      return _buildCatchAndRelease();
    } else if (id == _idSeason) {
      return _buildSeason();
    } else if (id == _idWaterClarity) {
      return _buildWaterClarity();
    } else if (id == _idWaterDepth) {
      return _buildWaterDepth();
    } else if (id == _idWaterTemperature) {
      return _buildWaterTemperature();
    } else if (id == _idLength) {
      return _buildLength();
    } else if (id == _idWeight) {
      return _buildWeight();
    } else if (id == _idQuantity) {
      return _buildQuantity();
    } else if (id == _idNotes) {
      return _buildNotes();
    } else if (id == _idAtmosphere) {
      return _buildAtmosphere();
    } else if (id == _idTide) {
      return _buildTide();
    } else {
      _log.e("Unknown input key: $id");
      return Empty();
    }
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: paddingWidgetSmall,
      ),
      child: DateTimePicker(
        datePicker: DatePicker(
          context,
          controller: _timestampController,
          label: Strings.of(context).catchFieldDate,
          onChange: (newDate) {
            _fetchAtmosphereIfNeeded();
            setState(_calculateSeasonIfNeeded);
          },
        ),
        timePicker: TimePicker(
          context,
          controller: _timestampController,
          label: Strings.of(context).catchFieldTime,
          onChange: (_) => _fetchAtmosphereIfNeeded(),
        ),
      ),
    );
  }

  Widget _buildBaits() {
    return BaitPickerInput(
      controller: _baitsController,
      emptyValue: (context) => Strings.of(context).catchFieldNoBaits,
    );
  }

  Widget _buildAngler() {
    return EntityPickerInput<Angler>.single(
      manager: _anglerManager,
      controller: _anglerController,
      title: Strings.of(context).catchFieldAnglerLabel,
      listPage: (settings) => AnglerListPage(pickerSettings: settings),
    );
  }

  Widget _buildWaterClarity() {
    return EntityPickerInput<WaterClarity>.single(
      manager: _waterClarityManager,
      controller: _waterClarityController,
      title: Strings.of(context).catchFieldWaterClarityLabel,
      listPage: (settings) => WaterClarityListPage(pickerSettings: settings),
    );
  }

  Widget _buildWaterDepth() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        spec: _waterDepthInputState,
        controller: _waterDepthController,
      ),
    );
  }

  Widget _buildWaterTemperature() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        spec: _waterTemperatureInputState,
        controller: _waterTemperatureController,
      ),
    );
  }

  Widget _buildLength() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        spec: _lengthInputState,
        controller: _lengthController,
      ),
    );
  }

  Widget _buildWeight() {
    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: MultiMeasurementInput(
        spec: _weightInputState,
        controller: _weightController,
      ),
    );
  }

  Widget _buildQuantity() {
    return Padding(
      padding: const EdgeInsets.only(
        top: paddingSmall,
        left: paddingDefault,
        right: paddingDefault,
      ),
      child: TextInput.number(
        context,
        controller: _quantityController,
        label: Strings.of(context).catchFieldQuantityLabel,
        signed: false,
        decimal: false,
      ),
    );
  }

  Widget _buildNotes() {
    return Padding(
      padding: const EdgeInsets.only(
        top: paddingSmall,
        left: paddingDefault,
        right: paddingDefault,
      ),
      child: TextInput.description(
        context,
        title: Strings.of(context).catchFieldNotesLabel,
        controller: _notesController,
      ),
    );
  }

  Widget _buildAtmosphere() {
    return AtmosphereInput(
      fetcher: newAtmosphereFetcher(),
      controller: _atmosphereController,
    );
  }

  Widget _buildTide() {
    return TideInput(controller: _tideController);
  }

  Widget _buildMethods() {
    return EntityPickerInput<Method>.multi(
      manager: _methodManager,
      controller: _methodsController,
      emptyValue: Strings.of(context).catchFieldNoMethods,
      listPage: (settings) => MethodListPage(pickerSettings: settings),
    );
  }

  Widget _buildPeriod() {
    return ListPickerInput.withSinglePickerPage<Period>(
      context: context,
      controller: _periodController,
      title: Strings.of(context).catchFieldPeriod,
      pickerTitle: Strings.of(context).pickerTitleTimeOfDay,
      valueDisplayName: _periodController.value?.displayName(context),
      noneItem: Period.period_none,
      itemBuilder: Periods.pickerItems,
      onPicked: (value) => setState(() => _periodController.value = value),
    );
  }

  Widget _buildSeason() {
    return ValueListenableBuilder(
      valueListenable: _fishingSpotController,
      builder: (_, __, ___) {
        _calculateSeasonIfNeeded();

        return ListPickerInput.withSinglePickerPage<Season>(
          context: context,
          controller: _seasonController,
          title: Strings.of(context).catchFieldSeason,
          pickerTitle: Strings.of(context).pickerTitleSeason,
          valueDisplayName: _seasonController.value?.displayName(context),
          noneItem: Season.season_none,
          itemBuilder: Seasons.pickerItems,
          onPicked: (value) => setState(() {
            _overwriteSeasonCalculation = true;
            _seasonController.value = value;
          }),
        );
      },
    );
  }

  Widget _buildFavorite() {
    return CheckboxInput(
      label: Strings.of(context).catchFieldFavorite,
      value: _favoriteController.value,
      onChanged: (checked) => _favoriteController.value = checked,
    );
  }

  Widget _buildCatchAndRelease() {
    return CheckboxInput(
      label: Strings.of(context).catchFieldCatchAndRelease,
      value: _catchAndReleaseController.value,
      onChanged: (checked) => _catchAndReleaseController.value = checked,
    );
  }

  Widget _buildFishingSpot() {
    return EntityListenerBuilder(
      managers: [
        _fishingSpotManager,
      ],
      builder: (context) {
        return ValueListenableBuilder<FishingSpot?>(
          valueListenable: _fishingSpotController,
          builder: (context, pickedSpot, __) {
            // Always fetch the latest version if it exists.
            var fishingSpot =
                _fishingSpotManager.entity(_fishingSpotController.value?.id) ??
                    pickedSpot;

            if (fishingSpot == null) {
              return ListItem(
                title: Text(Strings.of(context).catchFieldFishingSpot),
                trailing: RightChevronIcon(),
                onTap: _pushFishingSpotPicker,
              );
            }

            return FishingSpotDetails(
              fishingSpot,
              isListItem: true,
              onTap: _pushFishingSpotPicker,
            );
          },
        );
      },
    );
  }

  Widget _buildSpecies() {
    return EntityPickerInput<Species>.single(
      manager: _speciesManager,
      controller: _speciesController,
      title: Strings.of(context).catchFieldSpecies,
      listPage: (settings) => SpeciesListPage(
          pickerSettings: settings.copyWith(
        isRequired: true,
      )),
    );
  }

  Widget _buildImages() {
    return ImageInput(
      initialImageNames: _oldCatch?.imageNames ?? [],
      controller: _imagesController,
    );
  }

  FutureOr<bool> _save(Map<Id, dynamic> customFieldValueMap) {
    _userPreferenceManager
        .setCatchCustomEntityIds(customFieldValueMap.keys.toList());

    // imageNames is set in _catchManager.addOrUpdate
    var cat = Catch()
      ..id = _oldCatch?.id ?? randomId()
      ..timestamp = Int64(_timestampController.value)
      ..speciesId = _speciesController.value!
      ..customEntityValues.addAll(entityValuesFromMap(customFieldValueMap));

    if (_fishingSpotController.hasValue) {
      cat.fishingSpotId = _fishingSpotController.value!.id;

      // If the fishing spot doesn't yet exist in the database, add it now.
      // This can happen when a user picks a completely new fishing spot, but
      // doesn't save any property changes, such as setting a name or body of
      // water.
      if (!_fishingSpotManager.entityExists(cat.fishingSpotId)) {
        _fishingSpotManager.addOrUpdate(_fishingSpotController.value!);
      }
    }

    if (_baitsController.value.isNotEmpty) {
      cat.baits.addAll(_baitsController.value);
    } else {
      cat.baits.clear();
    }

    if (_anglerController.hasValue) {
      cat.anglerId = _anglerController.value!;
    }

    if (_waterClarityController.hasValue) {
      cat.waterClarityId = _waterClarityController.value!;
    }

    if (_waterDepthController.isSet) {
      cat.waterDepth = _waterDepthController.value;
    }

    if (_waterTemperatureController.isSet) {
      cat.waterTemperature = _waterTemperatureController.value;
    }

    if (_lengthController.isSet) {
      cat.length = _lengthController.value;
    }

    if (_weightController.isSet) {
      cat.weight = _weightController.value;
    }

    if (_methodsController.value.isNotEmpty) {
      cat.methodIds.addAll(_methodsController.value);
    } else {
      cat.methodIds.clear();
    }

    if (_periodController.hasValue) {
      cat.period = _periodController.value!;
    }

    if (_seasonController.hasValue) {
      cat.season = _seasonController.value!;
    }

    // If the user cares about (i.e. the field is showing) catch and release
    // data, always set it.
    if (_fields[_idCatchAndRelease] != null &&
        _fields[_idCatchAndRelease]!.isShowing) {
      cat.wasCatchAndRelease = _catchAndReleaseController.value;
    }

    if (_favoriteController.value) {
      cat.isFavorite = true;
    }

    if (_quantityController.hasIntValue) {
      cat.quantity = _quantityController.intValue!;
    }

    if (isNotEmpty(_notesController.value)) {
      cat.notes = _notesController.value!;
    }

    if (_atmosphereController.hasValue) {
      cat.atmosphere = _atmosphereController.value!;
    }

    if (_tideController.hasValue) {
      cat.tide = _tideController.value!;
    }

    _catchManager.addOrUpdate(
      cat,
      imageFiles: _imagesController.originalFiles,
    );

    if (widget.popOverride != null) {
      widget.popOverride!();
      return false;
    }

    return true;
  }

  void _pushFishingSpotPicker() {
    push(
      context,
      FishingSpotMap(
        pickerSettings: FishingSpotMapPickerSettings(
          controller: _fishingSpotController,
        ),
      ),
    );
  }

  void _calculateSeasonIfNeeded() {
    if (!_fields[_idSeason]!.isShowing || _overwriteSeasonCalculation) {
      return;
    }

    var spot = _fishingSpotController.value;
    _seasonController.value =
        Seasons.from(_timestampController.dateTime, spot?.lat);
  }

  AtmosphereFetcher newAtmosphereFetcher() {
    var fishingSpot = _fishingSpotController.value;
    return AtmosphereFetcher(AppManager.of(context), _timestampController.value,
        fishingSpot?.latLng ?? _locationMonitor.currentLocation);
  }

  void _fetchAtmosphereIfNeeded() {
    if (_subscriptionManager.isFree ||
        !_fields[_idAtmosphere]!.isShowing ||
        !_userPreferenceManager.autoFetchAtmosphere) {
      return;
    }

    newAtmosphereFetcher()
        .fetch()
        .then((atmosphere) => _atmosphereController.value = atmosphere);
  }
}
