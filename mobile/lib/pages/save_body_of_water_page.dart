import 'package:flutter/material.dart';
import '../body_of_water_manager.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/save_name_page.dart';
import '../utils/protobuf_utils.dart';
import '../utils/validator.dart';

class SaveBodyOfWaterPage extends StatelessWidget {
  final BodyOfWater? oldBodyOfWater;

  const SaveBodyOfWaterPage() : oldBodyOfWater = null;

  const SaveBodyOfWaterPage.edit(this.oldBodyOfWater);

  @override
  Widget build(BuildContext context) {
    var bodyOfWaterManager = BodyOfWaterManager.of(context);

    return SaveNamePage(
      title: oldBodyOfWater == null
          ? Text(Strings.of(context).saveBodyOfWaterPageNewTitle)
          : Text(Strings.of(context).saveBodyOfWaterPageEditTitle),
      oldName: oldBodyOfWater?.name,
      onSave: (newName) {
        bodyOfWaterManager.addOrUpdate(BodyOfWater()
          ..id = oldBodyOfWater?.id ?? randomId()
          ..name = newName!);
        return true;
      },
      validator: NameValidator(
        nameExistsMessage: (context) =>
            Strings.of(context).saveBodyOfWaterPageExistsMessage,
        nameExists: (name) => bodyOfWaterManager.nameExists(name),
      ),
    );
  }
}
