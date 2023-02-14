import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/pages/edit_coordinates_page.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/entity_picker_input.dart';
import 'package:mobile/widgets/list_picker_input.dart';
import 'package:quiver/strings.dart';

import '../body_of_water_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/form_page.dart';
import '../res/dimen.dart';
import '../widgets/image_input.dart';
import '../widgets/input_controller.dart';
import '../widgets/text_input.dart';
import '../widgets/widget.dart';
import 'body_of_water_list_page.dart';
import 'image_picker_page.dart';

class SaveFishingSpotPage extends StatefulWidget {
  final FishingSpot oldFishingSpot;

  const SaveFishingSpotPage.edit(this.oldFishingSpot);

  @override
  SaveFishingSpotPageState createState() => SaveFishingSpotPageState();
}

class SaveFishingSpotPageState extends State<SaveFishingSpotPage> {
  final _bodyOfWaterController = IdInputController();
  final _nameController = TextInputController();
  final _imageController = InputController<PickedImage>();
  final _notesController = TextInputController();
  final _coordinatesController = InputController<FishingSpot>();

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  FishingSpot get _oldFishingSpot => widget.oldFishingSpot;

  @override
  void initState() {
    super.initState();

    _bodyOfWaterController.value = _oldFishingSpot.hasBodyOfWaterId()
        ? _oldFishingSpot.bodyOfWaterId
        : null;
    _nameController.value =
        _oldFishingSpot.hasName() ? _oldFishingSpot.name : null;
    _notesController.value =
        _oldFishingSpot.hasNotes() ? _oldFishingSpot.notes : null;
    _coordinatesController.value = _oldFishingSpot;
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      runSpacing: 0,
      title: Text(Strings.of(context).saveFishingSpotPageEditTitle),
      padding: insetsZero,
      onSave: _onSave,
      fieldBuilder: (context) => [
        _buildBodyOfWater(),
        _buildCoordinates(),
        _buildImage(),
        const VerticalSpace(paddingSmall),
        _buildName(),
        const VerticalSpace(paddingSmall),
        _buildNotes(),
      ],
      isInputValid: true,
    );
  }

  Widget _buildBodyOfWater() {
    return EntityPickerInput<BodyOfWater>.single(
      manager: _bodyOfWaterManager,
      controller: _bodyOfWaterController,
      title: Strings.of(context).saveFishingSpotPageBodyOfWaterLabel,
      listPage: (settings) => BodyOfWaterListPage(pickerSettings: settings),
    );
  }

  Widget _buildCoordinates() {
    return ValueListenableBuilder<FishingSpot?>(
      valueListenable: _coordinatesController,
      builder: (context, _, __) {
        String? value;
        if (_coordinatesController.hasValue) {
          value = formatLatLng(
            context: context,
            lat: _coordinatesController.value!.lat,
            lng: _coordinatesController.value!.lng,
            includeLabels: false,
          );
        }

        return ListPickerInput(
          title: Strings.of(context).saveFishingSpotPageCoordinatesLabel,
          value: value,
          onTap: () =>
              push(context, EditCoordinatesPage(_coordinatesController)),
        );
      },
    );
  }

  Widget _buildName() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: TextInput.name(
        context,
        controller: _nameController,
        autofocus: true,
      ),
    );
  }

  Widget _buildImage() {
    return SingleImageInput(
      initialImageName: _oldFishingSpot.imageName,
      controller: _imageController,
    );
  }

  Widget _buildNotes() {
    return Padding(
      padding: insetsHorizontalDefault,
      child: TextInput.description(
        context,
        title: Strings.of(context).inputNotesLabel,
        controller: _notesController,
      ),
    );
  }

  FutureOr<bool> _onSave() {
    var newFishingSpot = FishingSpot()
      ..id = _oldFishingSpot.id
      ..lat = _coordinatesController.value!.lat
      ..lng = _coordinatesController.value!.lng;

    if (_bodyOfWaterController.hasValue) {
      newFishingSpot.bodyOfWaterId = _bodyOfWaterController.value!;
    }

    if (isNotEmpty(_nameController.value)) {
      newFishingSpot.name = _nameController.value!;
    }

    if (isNotEmpty(_notesController.value)) {
      newFishingSpot.notes = _notesController.value!;
    }

    File? imageFile;
    if (_imageController.hasValue &&
        _imageController.value!.originalFile != null) {
      imageFile = _imageController.value!.originalFile!;
    }

    _fishingSpotManager.addOrUpdate(
      newFishingSpot,
      imageFile: imageFile,
    );

    return true;
  }
}
