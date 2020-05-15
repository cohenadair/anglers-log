import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/pages/save_name_page.dart';
import 'package:mobile/utils/validator.dart';

class SaveBaitCategoryPage extends StatelessWidget {
  final BaitCategory oldCategory;

  SaveBaitCategoryPage() : oldCategory = null;
  SaveBaitCategoryPage.edit(this.oldCategory);

  bool get _editing => oldCategory != null;

  @override
  Widget build(BuildContext context) {
    BaitCategoryManager categoryManager = BaitCategoryManager.of(context);

    return SaveNamePage(
      title: _editing
          ? Text(Strings.of(context).saveBaitCategoryPageEditTitle)
          : Text(Strings.of(context).saveBaitCategoryPageNewTitle),
      oldName: oldCategory?.name,
      onSave: (newName) {
        var newCategory = BaitCategory(name: newName);
        if (_editing) {
          newCategory = BaitCategory(name: newName, id: oldCategory.id);
        }

        categoryManager.addOrUpdate(newCategory);
        return true;
      },
      validator: NameValidator(
        nameExistsMessage:
            Strings.of(context).saveBaitCategoryPageExistsMessage,
        nameExists: (name) => categoryManager.nameExists(name),
      ),
    );
  }

}