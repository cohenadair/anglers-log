import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/form_page.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/input_controller.dart';
import '../widgets/text_input.dart';

/// The [SaveFishingSpotPage] differs from other "save" pages in that it must
/// be provided an "old" fishing spot. In cases where a new fishing spot is
/// being created, the "old" spot is really a spot picked from a map widget,
/// which is not included in this page.
///
/// This page is essentially for gathering more information about a fishing
/// spot, after its coordinates have already been picked.
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
  }) : assert((editing && oldFishingSpot != null) || oldFishingSpot != null);

  SaveFishingSpotPage.edit(FishingSpot oldFishingSpot)
      : this(
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
    _nameController.value = _oldFishingSpot.name;
  }

  @override
  Widget build(BuildContext context) {
    var title = Strings.of(context).saveFishingSpotPageNewTitle;
    if (widget.editing) {
      title = Strings.of(context).saveFishingSpotPageEditTitle;
    }

    return FormPage.immutable(
      title: Text(title),
      onSave: (_) {
        var newFishingSpot = FishingSpot()
          ..id = _oldFishingSpot.id
          ..lat = _oldFishingSpot.lat
          ..lng = _oldFishingSpot.lng;

        if (isNotEmpty(_nameController.value)) {
          newFishingSpot.name = _nameController.value;
        }

        if (widget.onSave != null) {
          widget.onSave(newFishingSpot);
        } else {
          _fishingSpotManager.addOrUpdate(newFishingSpot);
        }

        return true;
      },
      fieldBuilder: (context) {
        return {
          _idName: TextInput.name(
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
