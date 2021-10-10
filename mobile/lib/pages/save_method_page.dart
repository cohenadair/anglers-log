import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../method_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/save_name_page.dart';
import '../utils/protobuf_utils.dart';
import '../utils/validator.dart';

class SaveMethodPage extends StatelessWidget {
  final Method? oldMethod;

  const SaveMethodPage() : oldMethod = null;

  const SaveMethodPage.edit(this.oldMethod);

  @override
  Widget build(BuildContext context) {
    var methodManager = MethodManager.of(context);

    return SaveNamePage(
      title: oldMethod == null
          ? Text(Strings.of(context).saveMethodPageNewTitle)
          : Text(Strings.of(context).saveMethodPageEditTitle),
      oldName: oldMethod?.name,
      onSave: (newName) {
        methodManager.addOrUpdate(Method()
          ..id = oldMethod?.id ?? randomId()
          ..name = newName!);
        return true;
      },
      validator: NameValidator(
        nameExistsMessage: (context) =>
            Strings.of(context).saveMethodPageExistsMessage,
        nameExists: (name) => methodManager.nameExists(name),
      ),
    );
  }
}
