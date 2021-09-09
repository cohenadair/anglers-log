import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:quiver/strings.dart';

import '../body_of_water_manager.dart';
import '../entity_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/form_page.dart';
import '../res/dimen.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/image_input.dart';
import '../widgets/input_controller.dart';
import '../widgets/list_picker_input.dart';
import '../widgets/text_input.dart';
import '../widgets/widget.dart';
import 'body_of_water_list_page.dart';
import 'image_picker_page.dart';
import 'manageable_list_page.dart';

class SaveFishingSpotPage extends StatefulWidget {
  final FishingSpot? oldFishingSpot;

  /// The coordinates of a new fishing spot being added, usually picked from
  /// a map widget, such as [FishingSpotPickerPage].
  final LatLng? latLng;

  /// Called asynchronously after [FishingSpot] has been committed to the
  /// database.
  final void Function(FishingSpot)? onSave;

  SaveFishingSpotPage({
    required this.latLng,
    this.onSave,
  }) : oldFishingSpot = null;

  SaveFishingSpotPage.edit(this.oldFishingSpot)
      : latLng = null,
        onSave = null;

  @override
  _SaveFishingSpotPageState createState() => _SaveFishingSpotPageState();
}

class _SaveFishingSpotPageState extends State<SaveFishingSpotPage> {
  final _bodyOfWaterController = IdInputController();
  final _nameController = TextInputController();
  final _imageController = InputController<PickedImage>();
  final _notesController = TextInputController();

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  FishingSpot? get _oldFishingSpot => widget.oldFishingSpot;

  bool get _isEditing => _oldFishingSpot != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _bodyOfWaterController.value = _oldFishingSpot!.hasBodyOfWaterId()
          ? _oldFishingSpot!.bodyOfWaterId
          : null;
      _nameController.value =
          _oldFishingSpot!.hasName() ? _oldFishingSpot!.name : null;
      _notesController.value =
          _oldFishingSpot!.hasNotes() ? _oldFishingSpot!.notes : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var title = Strings.of(context).saveFishingSpotPageNewTitle;
    if (widget.oldFishingSpot != null) {
      title = Strings.of(context).saveFishingSpotPageEditTitle;
    }

    return FormPage.immutable(
      runSpacing: 0,
      title: Text(title),
      padding: insetsZero,
      onSave: _onSave,
      fieldBuilder: (context) => [
        _buildBodyOfWater(),
        _buildImage(),
        VerticalSpace(paddingWidgetSmall),
        _buildName(),
        VerticalSpace(paddingWidgetSmall),
        _buildNotes(),
      ],
      isInputValid: true,
    );
  }

  Widget _buildBodyOfWater() {
    return EntityListenerBuilder(
      managers: [_bodyOfWaterManager],
      builder: (context) {
        var bodyOfWater =
            _bodyOfWaterManager.entity(_bodyOfWaterController.value);
        return ListPickerInput(
          title: Strings.of(context).saveFishingSpotPageBodyOfWaterLabel,
          value: bodyOfWater?.name,
          onTap: () {
            push(
              context,
              BodyOfWaterListPage(
                pickerSettings:
                    ManageableListPagePickerSettings<BodyOfWater>.single(
                  onPicked: (context, bodyOfWater) {
                    setState(
                        () => _bodyOfWaterController.value = bodyOfWater?.id);
                    return true;
                  },
                  initialValue: bodyOfWater,
                ),
              ),
            );
          },
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
      initialImageName: _oldFishingSpot?.imageName,
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

  FutureOr<bool> _onSave(BuildContext context) async {
    var newFishingSpot = FishingSpot()
      ..id = _oldFishingSpot?.id ?? randomId()
      ..lat = _oldFishingSpot?.lat ?? widget.latLng!.latitude
      ..lng = _oldFishingSpot?.lng ?? widget.latLng!.longitude;

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

    if (await _fishingSpotManager.addOrUpdate(
      newFishingSpot,
      imageFile: imageFile,
    )) {
      widget.onSave?.call(newFishingSpot);
    }

    return true;
  }
}
