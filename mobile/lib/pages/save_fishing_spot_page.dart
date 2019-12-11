import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/pages/form_page.dart';
import 'package:mobile/widgets/input.dart';
import 'package:quiver/strings.dart';

class SaveFishingSpotPage extends StatefulWidget {
  final AppManager app;
  final FishingSpot oldFishingSpot;

  SaveFishingSpotPage({
    @required this.app,
    @required this.oldFishingSpot,
  }) : assert(app != null),
       assert(oldFishingSpot != null);

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
      app: widget.app,
      editable: false,
      onSave: () {
        FishingSpot newFishingSpot = FishingSpot(
          latLng: widget.oldFishingSpot.latLng,
          name: isNotEmpty(_nameController.text) ? _nameController.text : null,
          id: widget.oldFishingSpot.id,
        );
        print(newFishingSpot.toString());
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