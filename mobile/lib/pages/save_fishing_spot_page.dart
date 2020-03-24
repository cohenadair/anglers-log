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

  SaveFishingSpotPage({
    @required this.oldFishingSpot,
    this.editing = false,
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
        FishingSpotManager.of(context).createOrUpdate(FishingSpot(
          lat: widget.oldFishingSpot.lat,
          lng: widget.oldFishingSpot.lng,
          name: isNotEmpty(_nameController.text) ? _nameController.text : null,
          id: widget.oldFishingSpot.id,
        ));
        return true;
      },
      fieldBuilder: (BuildContext context, bool isRemovingFields) {
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