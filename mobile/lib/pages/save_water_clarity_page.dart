import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/save_name_page.dart';
import '../utils/protobuf_utils.dart';
import '../utils/validator.dart';
import '../water_clarity_manager.dart';

class SaveWaterClarityPage extends StatelessWidget {
  final WaterClarity? oldWaterClarity;

  const SaveWaterClarityPage() : oldWaterClarity = null;

  const SaveWaterClarityPage.edit(this.oldWaterClarity);

  @override
  Widget build(BuildContext context) {
    var waterClarityManager = WaterClarityManager.of(context);

    return SaveNamePage(
      title: oldWaterClarity == null
          ? Text(Strings.of(context).saveWaterClarityPageNewTitle)
          : Text(Strings.of(context).saveWaterClarityPageEditTitle),
      oldName: oldWaterClarity?.name,
      onSave: (newName) {
        waterClarityManager.addOrUpdate(WaterClarity()
          ..id = oldWaterClarity?.id ?? randomId()
          ..name = newName!);
        return true;
      },
      validator: NameValidator(
        nameExistsMessage: (context) =>
            Strings.of(context).saveWaterClarityPageExistsMessage,
        nameExists: (name) => waterClarityManager.nameExists(name),
      ),
    );
  }
}
