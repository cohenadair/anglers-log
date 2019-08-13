import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/angler.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/input.dart';
import 'package:uuid/uuid.dart';

import 'form_page.dart';

class AddCatchPage extends StatefulWidget {
  @override
  _AddCatchPageState createState() => _AddCatchPageState();
}

class _AddCatchPageState extends State<AddCatchPage> {
  // TODO: Remove
  static final String test1 = Uuid().v1();
  static final String test2 = Uuid().v1();
  static final String test3 = Uuid().v1();
  static final String test4 = Uuid().v1();

  Map<String, TextEditingController> _usedInputOptions = {
    Angler.key: TextEditingController(),
  };

  List<String> _allInputOptions = List.unmodifiable([
    Angler.key,
    test1,
    test2,
    test3,
    test4,
  ]);

  @override
  void dispose() {
    for (TextEditingController controller in _usedInputOptions.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormPage(
      key: UniqueKey(),
      fieldBuilder: (BuildContext context, bool isRemovingFields) {
        return Map.fromIterable(_usedInputOptions.keys,
          key: (item) => item.toString(),
          value: (item) => _getInputField(
            key: item.toString(),
            isRemovingFields: isRemovingFields,
          ),
        );
      },
      onSave: _save,
      addFieldOptions: _allInputOptions.map((String id) {
        return FormPageFieldOption(
          id: id,
          userFacingName: _getUserFacingLabel(id),
          used: _usedInputOptions.keys.contains(id),
        );
      }).toList(),
      onAddField: (String id) {
        setState(() {
          _usedInputOptions.putIfAbsent(id, () => TextEditingController());
        });
      },
      onConfirmRemoveFields: (List<String> fieldsToRemove) {
        setState(() {
          for (String key in fieldsToRemove) {
            _usedInputOptions.remove(key);
          }
        });
      },
    );
  }

  InputField _getInputField({String key, bool isRemovingFields}) {
    switch (key) {
      case Angler.key: return TextInput(
        controller: _usedInputOptions[key],
        label: _getUserFacingLabel(key),
        requiredText: format(Strings.of(context).inputRequiredMessage,
            [Strings.of(context).anglerNameLabel]),
        capitalization: TextCapitalization.words,
        enabled: !isRemovingFields,
      );

      default: return TextInput(
        controller: _usedInputOptions[key],
        label: _getUserFacingLabel(key),
        requiredText: "Test Field is required",
        capitalization: TextCapitalization.words,
        enabled: !isRemovingFields,
      );
    }
  }

  String _getUserFacingLabel(String fieldId) {
    switch (fieldId) {
      case Angler.key: return Strings.of(context).anglerNameLabel;
      default: return "Test Field ${fieldId.substring(fieldId.length - 5)}";
    }
  }

  void _save() {
    Map<String, dynamic> result = {};

    // Angler
    if (_usedInputOptions.containsKey(Angler.key)) {
      Angler angler =
          Angler(name: _usedInputOptions[Angler.key].value.text);
      result.putIfAbsent(Angler.key, () => angler.toMap);
    }

    // Test
    if (_usedInputOptions.containsKey(test1)) {
      result.putIfAbsent(test1, () =>
          _usedInputOptions[test1].value.text);
    }
    if (_usedInputOptions.containsKey(test2)) {
      result.putIfAbsent(test2, () =>
          _usedInputOptions[test2].value.text);
    }
    if (_usedInputOptions.containsKey(test3)) {
      result.putIfAbsent(test3, () =>
          _usedInputOptions[test3].value.text);
    }
    if (_usedInputOptions.containsKey(test4)) {
      result.putIfAbsent(test4, () =>
          _usedInputOptions[test4].value.text);
    }

    print(result);
  }
}