import 'package:flutter/material.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:quiver/strings.dart';

/// A class for storing a value of an input widget, such as a text field or
/// check box.
class InputController<T> {
  /// The value of the controller, such as [bool] or [TextEditingController].
  T value;

  /// A callback for rendering an error message for the input. A function is
  /// required for use with localized strings.
  String Function(BuildContext) errorCallback;

  InputController({
    this.value,
    this.errorCallback,
  });

  void dispose() {
    clear();
  }

  void clear() {
    value = null;
  }

  String error(BuildContext context) => errorCallback?.call(context);
}

class BaitCategoryController extends InputController<BaitCategory> {
}

class ImageInputController extends InputController<PickedImage> {
}

class TextInputController extends InputController<TextEditingController> {
  TextInputController({
    TextEditingController controller,
    String Function(BuildContext) errorCallback,
  }) : super(
    value: controller == null ? TextEditingController() : controller,
    errorCallback: errorCallback,
  );

  String get text => value.text.trim();
  set text(String text) => value.text = isEmpty(text) ? text : text.trim();

  @override
  void dispose() {
    value.dispose();
  }

  @override
  void clear() {
    value.clear();
  }

  void clearText() {
    value.value = TextEditingValue(text: "");
  }
}

class TimestampInputController extends InputController<int> {
  /// The date component of the controller.
  DateTime date;

  /// The time component of the controller.
  TimeOfDay time;

  TimestampInputController({
    this.date,
    this.time,
  });

  @override
  int get value => combine(date, time).millisecondsSinceEpoch;

  @override
  void clear() {
    super.clear();
    date = null;
    time = null;
  }
}