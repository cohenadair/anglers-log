import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/page.dart';

class FormPage extends StatefulWidget {
  final String title;
  final Map<String, FormField> inputWidgetMap;
  final Function(Map<String, dynamic>) onSave;

  FormPage({
    this.title,
    @required this.inputWidgetMap,
    this.onSave
  }) : assert(inputWidgetMap != null),
       assert(inputWidgetMap.isNotEmpty),
       assert(inputWidgetMap.values.where((FormField field)
          => field.key == null).isEmpty),
       assert(inputWidgetMap.values.where((FormField field)
          => !(field.key is GlobalKey<FormFieldState>)).isEmpty);

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: widget.title,
        actions: [
          ActionButton.save(
            onPressed: _onPressedSave,
          ),
        ],
      ),
      padding: insetsHorizontalDefault,
      child: Form(
        key: _key,
        child: SingleChildScrollView(
          padding: insetsBottomDefault,
          child: Wrap(
            runSpacing: paddingSmall,
            children: widget.inputWidgetMap.values.toList(),
          ),
        ),
      ),
    );
  }

  void _onPressedSave() {
    if (!_key.currentState.validate()) {
      return;
    }

    _key.currentState.save();
    widget.onSave(_formResult);

    Navigator.pop(context);
  }

  Map<String, dynamic> get _formResult {
    Map<String, dynamic> result = Map();

    widget.inputWidgetMap.forEach((String key, FormField field) {
      var fieldKey = field.key as GlobalKey<FormFieldState>;
      var fieldValue = fieldKey.currentState.value;

      bool fieldIsValid = fieldValue != null;
      fieldIsValid &=
          !(fieldValue is String) || (fieldValue as String).isNotEmpty;

      if (fieldIsValid) {
        result[key] = fieldKey.currentState.value;
      }
    });

    return result;
  }
}