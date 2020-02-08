import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/utils/date_time_utils.dart';

/// An abstract class for storing a value of an input widget, such as a
/// text field or check box.
class InputController<T> {
  T value;

  InputController({
    this.value,
  });

  void dispose() {
    clear();
  }

  void clear() {
    value = null;
  }
}

class ImageInputController extends InputController<File> {
}

class TextInputController extends InputController<TextEditingController> {
  TextInputController({
    @required TextEditingController controller,
  }) : assert(controller != null),
       super(value: controller);

  @override
  void dispose() {
    value.dispose();
  }

  @override
  void clear() {
    value.clear();
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