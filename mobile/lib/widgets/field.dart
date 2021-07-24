import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/input_controller.dart';
import '../widgets/input_type.dart';

/// A simple structure for storing build information for a form's input fields.
class Field {
  static LocalizedString _customEntityName(CustomEntity entity) =>
      (_) => entity.name;

  static LocalizedString _customEntityDescription(CustomEntity entity) =>
      (_) => entity.description;

  final Id id;

  /// Returns user-visible label text. This is required for displaying this
  /// input in the list of available inputs in an [EditableFormPage]. If the
  /// [Field] does not belong to an [EditableFormPage], this value can be
  /// null.
  late final LocalizedString? name;

  late final LocalizedString? description;

  /// Whether the input can be removed from the associated form. Defaults to
  /// `true`.
  final bool isRemovable;

  /// True if the [Field] is fake. This is useful for inserting section
  /// separators in to the form.
  final bool isFake;

  final InputController controller;

  /// True if the [Widget] associated with this [Field] is currently showing
  /// in the form; false otherwise. This value may be updated when used in an
  /// [EditableFormPage].
  bool isShowing;

  Field({
    required this.id,
    required this.controller,
    this.name,
    LocalizedString? description,
    this.isShowing = true,
    this.isRemovable = true,
  }) : isFake = false {
    if (description == null && !isRemovable) {
      // Fields without a description and not removable are by definition,
      // required. Indicate this is the case in the user-facing description.
      this.description = (context) => Strings.of(context).inputGenericRequired;
    } else {
      this.description = description;
    }
  }

  Field.fromCustomEntity(CustomEntity entity)
      : id = entity.id,
        controller = inputTypeController(entity.type),
        name = _customEntityName(entity),
        description = _customEntityDescription(entity),
        isShowing = true,
        isRemovable = true,
        isFake = false;

  Field.fake()
      : id = randomId(),
        controller = InputController(),
        name = null,
        description = null,
        isShowing = true,
        isRemovable = true,
        isFake = true;
}
