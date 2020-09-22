import 'package:flutter/material.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/form_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/text_input.dart';

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
  }) : assert((editing && oldFishingSpot != null)
      || oldFishingSpot != null);

  SaveFishingSpotPage.edit(FishingSpot oldFishingSpot) : this(
    oldFishingSpot: oldFishingSpot,
    editing: true,
    onSave: null,
  );

  @override
  _SaveFishingSpotPageState createState() => _SaveFishingSpotPageState();
}

class _SaveFishingSpotPageState extends State<SaveFishingSpotPage> {
  static final _idName = randomId();

  final _nameController = TextInputController();

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  FishingSpot get _oldFishingSpot => widget.oldFishingSpot;

  @override
  void initState() {
    super.initState();
    _nameController.value = _oldFishingSpot?.name;
  }

  @override
  Widget build(BuildContext context) {
    String title = Strings.of(context).saveFishingSpotPageNewTitle;
    if (widget.editing) {
      title = Strings.of(context).saveFishingSpotPageEditTitle;
    }

    return FormPage.immutable(
      title: Text(title),
      onSave: (_) {
        FishingSpot newFishingSpot = FishingSpot()
          ..id = _oldFishingSpot?.id ?? randomId()
          ..lat = _oldFishingSpot?.lat
          ..lng = _oldFishingSpot?.lng
          ..name = _nameController.value;

        if (widget.onSave != null) {
          widget.onSave(newFishingSpot);
        } else {
          _fishingSpotManager.addOrUpdate(newFishingSpot);
        }

        return true;
      },
      fieldBuilder: (BuildContext context) {
        return {
          _idName : TextInput.name(
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