import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/trip_manager.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/input_controller.dart';
import '../widgets/text_input.dart';
import 'form_page.dart';

class SaveTripPage extends StatefulWidget {
  final Trip? oldTrip;

  const SaveTripPage() : oldTrip = null;

  const SaveTripPage.edit(this.oldTrip);

  @override
  _SaveTripPageState createState() => _SaveTripPageState();
}

class _SaveTripPageState extends State<SaveTripPage> {
  final _nameController = TextInputController.name();

  Trip? get _oldTrip => widget.oldTrip;

  bool get _isEditing => _oldTrip != null;

  TripManager get _tripManager => TripManager.of(context);

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _nameController.value = _oldTrip!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      title: _isEditing
          ? Text(Strings.of(context).saveTripPageEditTitle)
          : Text(Strings.of(context).saveTripPageNewTitle),
      padding: insetsZero,
      fieldBuilder: (context) => [
        _buildName(),
      ],
      onSave: _save,
      isInputValid: true,
      runSpacing: 0,
    );
  }

  Widget _buildName() {
    return TextInput.name(
      context,
      controller: _nameController,
    );
  }

  FutureOr<bool> _save(BuildContext context) {
    // imageNames is set in _tripManager.addOrUpdate.
    var newTrip = Trip()
      ..id = _oldTrip?.id ?? randomId()
      ..name = _nameController.value!;

    _tripManager.addOrUpdate(newTrip, imageFiles: []);
    return true;
  }
}
