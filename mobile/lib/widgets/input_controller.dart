import 'package:flutter/material.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/validator.dart';
import 'package:quiver/strings.dart';

/// A class for storing a value of an input widget, such as a text field or
/// check box.
class InputController<T> {
  /// The value of the controller, such as [bool] or [TextEditingController].
  T value;

  /// Invoked when validating input.
  ValidationCallback validate;

  InputController({
    this.value,
    this.validate,
  });

  void dispose() {
    clear();
  }

  void clear() {
    value = null;
  }

  String error(BuildContext context) => validate?.call(context);
}

class TextInputController extends InputController<TextEditingController> {
  TextInputController({
    TextEditingController controller,
    ValidationCallback validate,
  }) : super(
    value: controller == null ? TextEditingController() : controller,
    validate: validate,
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
  set value(int millisSinceEpoch) {
    if (millisSinceEpoch == null) {
      date = null;
      time = null;
      return;
    }
    date = DateTime.fromMillisecondsSinceEpoch(millisSinceEpoch);
    time = TimeOfDay.fromDateTime(date);
  }

  @override
  void clear() {
    super.clear();
    date = null;
    time = null;
  }
}

class BaitCategoryInputController extends InputController<BaitCategory> {
}

class SpeciesInputController extends InputController<Species> {
}

class FishingSpotInputController extends InputController<FishingSpot> {
}

class BaitInputController extends InputController<Bait> {
}

class ImageInputController extends InputController<PickedImage> {
}

class ImagesInputController extends InputController<List<PickedImage>> {
}