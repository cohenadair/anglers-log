import 'package:flutter/material.dart';
import 'package:mobile/water_clarity_manager.dart';
import 'package:mobile/widgets/input_controller.dart';

import '../model/gen/anglerslog.pb.dart';
import '../pages/water_clarity_list_page.dart';
import '../utils/string_utils.dart';
import 'entity_picker_input.dart';

class WaterClarityInput extends StatelessWidget {
  final IdInputController controller;

  const WaterClarityInput(this.controller);

  @override
  Widget build(BuildContext context) {
    return EntityPickerInput<WaterClarity>.single(
      manager: WaterClarityManager.of(context),
      controller: controller,
      title: Strings.of(context).fieldWaterClarityLabel,
      listPage: (settings) => WaterClarityListPage(pickerSettings: settings),
    );
  }
}
