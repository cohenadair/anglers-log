import 'package:flutter/material.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/res/dimen.dart';

import '../model/gen/anglerslog.pb.dart';

class SaveGearPage extends StatelessWidget {
  final Gear? oldGear;

  const SaveGearPage() : oldGear = null;

  const SaveGearPage.edit(this.oldGear);

  @override
  Widget build(BuildContext context) {
    return const EditableFormPage(
      padding: insetsZero,
    );
  }
}
