import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/save_name_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/validator.dart';

class SaveBaitCategoryPage extends StatelessWidget {
  final BaitCategory oldBaitCategory;

  SaveBaitCategoryPage() : oldBaitCategory = null;
  SaveBaitCategoryPage.edit(this.oldBaitCategory)
      : assert(oldBaitCategory != null);

  @override
  Widget build(BuildContext context) {
    BaitCategoryManager baitCategoryManager = BaitCategoryManager.of(context);

    return SaveNamePage(
      title: oldBaitCategory == null
          ? Text(Strings.of(context).saveBaitCategoryPageNewTitle)
          : Text(Strings.of(context).saveBaitCategoryPageEditTitle),
      oldName: oldBaitCategory?.name,
      onSave: (newName) {
        baitCategoryManager.addOrUpdate(BaitCategory()
          ..id = oldBaitCategory?.id ?? randomId()
          ..name = newName);
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
