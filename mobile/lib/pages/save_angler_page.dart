import 'package:flutter/material.dart';

import '../angler_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/save_name_page.dart';
import '../utils/protobuf_utils.dart';
import '../utils/validator.dart';

class SaveAnglerPage extends StatelessWidget {
  final Angler? oldAngler;

  const SaveAnglerPage() : oldAngler = null;

  const SaveAnglerPage.edit(this.oldAngler);

  @override
  Widget build(BuildContext context) {
    var anglerManager = AnglerManager.of(context);

    return SaveNamePage(
      title: oldAngler == null
          ? Text(Strings.of(context).saveAnglerPageNewTitle)
          : Text(Strings.of(context).saveAnglerPageEditTitle),
      oldName: oldAngler?.name,
      onSave: (newName) {
        anglerManager.addOrUpdate(Angler()
          ..id = oldAngler?.id ?? randomId()
          ..name = newName!);
        return true;
      },
      validator: NameValidator(
        nameExistsMessage: (context) =>
            Strings.of(context).saveAnglerPageExistsMessage,
        nameExists: (name) => anglerManager.nameExists(name),
      ),
    );
  }
}
