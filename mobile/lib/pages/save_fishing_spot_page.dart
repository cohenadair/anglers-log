import 'package:flutter/material.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/entity.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/pages/form_page.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:quiver/strings.dart';

class SaveFishingSpotPage extends StatefulWidget {
  final FishingSpot oldFishingSpot;
  final bool editing;

  /// If non-null, is invoked when the save button is pressed. In this case,
  /// a database call is _not_ made. Instead, the new fishing spot is passed
  /// to this callback.
  final void Function(FishingSpot) onSave;

  SaveFishingSpotPage({
    @required this.oldFishingSpot,
    this.editing = false,
    this.onSave,
  }) : assert(oldFishingSpot != null);

  @override
  _SaveFishingSpotPageState createState() => _SaveFishingSpotPageState();
}

class _SaveFishingSpotPageState extends State<SaveFishingSpotPage> {
  final _nameController = TextInputController();
  
  @override
  void initState() {
    super.initState();
    _nameController.text = widget.oldFishingSpot.name;
  }

  @override
  Widget build(BuildContext context) {
    String title = Strings.of(context).saveFishingSpotPageNewTitle;
    if (widget.editing) {
      title = Strings.of(context).saveFishingSpotPageEditTitle;
    }

    return FormPage.immutable(
      title: Text(title),
      onSave: () {
        FishingSpot newFishingSpot = FishingSpot(
          lat: widget.oldFishingSpot.lat,
          lng: widget.oldFishingSpot.lng,
          name: isNotEmpty(_nameController.text) ? _nameController.text : null,
          id: widget.oldFishingSpot.id,
        );

        if (widget.onSave != null) {
          widget.onSave(newFishingSpot);
        } else {
          FishingSpotManager.of(context).createOrUpdate(newFishingSpot);
        }

        return true;
      },
      fieldBuilder: (BuildContext context) {
        return {
          Entity.keyName : TextInput.name(
            context,
            controller: _nameController,
            autofocus: true,
          ),
        };
      },
      isInputValid: true,
    );
  }
}