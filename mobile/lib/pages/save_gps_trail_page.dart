import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/gps_trail_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:protobuf/protobuf.dart';

import '../body_of_water_manager.dart';
import '../i18n/strings.dart';
import '../res/dimen.dart';
import '../widgets/entity_picker_input.dart';
import '../widgets/input_controller.dart';
import 'body_of_water_list_page.dart';
import 'form_page.dart';

class SaveGpsTrailPage extends StatefulWidget {
  final GpsTrail oldTrail;

  const SaveGpsTrailPage.edit(this.oldTrail);

  @override
  State<SaveGpsTrailPage> createState() => _SaveGpsTrailPageState();
}

class _SaveGpsTrailPageState extends State<SaveGpsTrailPage> {
  final _bodyOfWaterController = IdInputController();

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  GpsTrailManager get _gpsTrailManager => GpsTrailManager.of(context);

  GpsTrail get _oldTrail => widget.oldTrail;

  @override
  void initState() {
    super.initState();
    _bodyOfWaterController.value =
        _oldTrail.hasBodyOfWaterId() ? _oldTrail.bodyOfWaterId : null;
  }

  @override
  Widget build(BuildContext context) {
    return FormPage.immutable(
      runSpacing: 0,
      title: Text(Strings.of(context).saveGpsTrailPageEditTitle),
      padding: insetsZero,
      onSave: _onSave,
      fieldBuilder: (context) => [
        _buildBodyOfWater(),
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

  FutureOr<bool> _onSave() {
    var newFishingSpot = _oldTrail.deepCopy();

    if (_bodyOfWaterController.hasValue) {
      newFishingSpot.bodyOfWaterId = _bodyOfWaterController.value!;
    }

    return _gpsTrailManager.addOrUpdate(newFishingSpot);
  }
}
