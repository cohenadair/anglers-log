import 'package:flutter/material.dart';
import 'package:mobile/pages/editable_form_page.dart';
import 'package:mobile/widgets/input.dart';
import 'package:mobile/widgets/widget.dart';

class SaveBaitPage extends StatefulWidget {
  @override
  _SaveBaitPageState createState() => _SaveBaitPageState();
}

class _SaveBaitPageState extends State<SaveBaitPage> {
  final Map<String, InputData> _allInputFields = {
  };

  @override
  Widget build(BuildContext context) {
    return EditableFormPage(
      allFields: _allInputFields,
      initialFields: {
      },
      onBuildField: (id, isRemovingFields) {
        switch (id) {
          default:
            print("Unknown input key: $id");
            return Empty();
        }
      },
      onSave: _save,
    );
  }

  void _save(Map<String, InputData> result) {
    print(result);
  }
}