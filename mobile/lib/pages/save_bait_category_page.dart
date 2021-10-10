import 'package:flutter/material.dart';

import '../bait_category_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/save_name_page.dart';
import '../utils/protobuf_utils.dart';
import '../utils/validator.dart';

class SaveBaitCategoryPage extends StatelessWidget {
  final BaitCategory? oldBaitCategory;

  const SaveBaitCategoryPage() : oldBaitCategory = null;

  const SaveBaitCategoryPage.edit(this.oldBaitCategory);

  @override
  Widget build(BuildContext context) {
    var baitCategoryManager = BaitCategoryManager.of(context);

    return SaveNamePage(
      title: oldBaitCategory == null
          ? Text(Strings.of(context).saveBaitCategoryPageNewTitle)
          : Text(Strings.of(context).saveBaitCategoryPageEditTitle),
      oldName: oldBaitCategory?.name,
      onSave: (newName) {
        baitCategoryManager.addOrUpdate(BaitCategory()
          ..id = oldBaitCategory?.id ?? randomId()
          ..name = newName!);
        return true;
      },
      validator: NameValidator(
        nameExistsMessage: (context) =>
            Strings.of(context).saveBaitCategoryPageExistsMessage,
        nameExists: (name) => baitCategoryManager.nameExists(name),
      ),
    );
  }
}
