import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quiver/strings.dart';

import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/form_page.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/input_controller.dart';
import '../widgets/text_input.dart';

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
  final _nameController = TextInputController();

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  FishingSpot? get _oldFishingSpot => widget.oldFishingSpot;

  @override
  void initState() {
    super.initState();
    _nameController.value = _oldFishingSpot?.name;
  }

  @override
  Widget build(BuildContext context) {
    var title = Strings.of(context).saveFishingSpotPageNewTitle;
    if (widget.oldFishingSpot != null) {
      title = Strings.of(context).saveFishingSpotPageEditTitle;
    }

    return FormPage.immutable(
      title: Text(title),
      onSave: (_) {
        var newFishingSpot = FishingSpot()
          ..id = _oldFishingSpot?.id ?? randomId()
          ..lat = _oldFishingSpot?.lat ?? widget.latLng!.latitude
          ..lng = _oldFishingSpot?.lng ?? widget.latLng!.longitude;

        if (isNotEmpty(_nameController.value)) {
          newFishingSpot.name = _nameController.value!;
        }

        _fishingSpotManager.addOrUpdate(newFishingSpot);
        widget.onSave?.call(newFishingSpot);

        return true;
      },
      fieldBuilder: (context) => [
        TextInput.name(
          context,
          controller: _nameController,
          autofocus: true,
        ),
      ],
      isInputValid: true,
    );
  }
}
