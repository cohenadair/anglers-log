import 'package:flutter/material.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/pages/form_page.dart';
import 'package:mobile/widgets/input.dart';
import 'package:quiver/strings.dart';

class SaveFishingSpotPage extends StatefulWidget {
  final FishingSpot oldFishingSpot;

  SaveFishingSpotPage({
    @required this.oldFishingSpot,
  }) : assert(oldFishingSpot != null);

  @override
  _SaveFishingSpotPageState createState() => _SaveFishingSpotPageState();
}

class _SaveFishingSpotPageState extends State<SaveFishingSpotPage> {
  final _nameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _nameController.text = widget.oldFishingSpot.name;
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      editable: false,
      onSave: () {
        FishingSpotManager.of(context).createOrUpdate(FishingSpot(
          lat: widget.oldFishingSpot.lat,
          lng: widget.oldFishingSpot.lng,
          name: isNotEmpty(_nameController.text) ? _nameController.text : null,
          id: widget.oldFishingSpot.id,
        ));
      },
      fieldBuilder: (BuildContext context, bool isRemovingFields) {
        return {
          FishingSpot.keyName : TextInput.name(
            context,
            controller: _nameController,
          ),
        };
      },
    );
  }
}