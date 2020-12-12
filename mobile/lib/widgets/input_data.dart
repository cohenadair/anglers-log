import 'package:flutter/material.dart';

import '../model/gen/anglerslog.pb.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/input_controller.dart';
import '../widgets/input_type.dart';

/// A simple structure for storing build information for a form's input fields.
class Field {
  static String Function(BuildContext) _customEntityName(CustomEntity entity) =>
      (_) => entity.name;

  static String Function(BuildContext) _customEntityDescription(
          CustomEntity entity) =>
      (_) => entity.description;

  final Id id;

  /// Returns user-visible label text. This is required for displaying this
  /// input in the list of available inputs in an [EditableFormPage]. If the
  /// [Field] does not belong to an [EditableFormPage], this value can be
  /// null.
  final String Function(BuildContext) name;

  final String Function(BuildContext) description;

  /// Whether the input can be removed from the associated form. Defaults to
  /// `true`.
  final bool removable;

  /// True if the [Field] is fake. This is useful for inserting section
  /// separators in to the form.
  final bool fake;

  /// True if the [Widget] associated with this [Field] is currently showing
  /// in the form; false otherwise. This value may be updated when used in an
  /// [EditableFormPage].
  bool showing;

  InputController controller;

  Field({
    @required this.id,
    @required this.controller,
    this.name,
    this.description,
    this.showing = true,
    this.removable = true,
  })  : assert(id != null),
        assert(controller != null),
        fake = false;

  Field.fromCustomEntity(CustomEntity entity)
      : assert(entity != null),
        id = entity.id,
        controller = inputTypeController(entity.type),
        name = _customEntityName(entity),
        description = _customEntityDescription(entity),
        showing = true,
        removable = true,
        fake = false;

  Field.fake()
      : id = randomId(),
        controller = InputController(),
        name = null,
        description = null,
        showing = true,
        removable = true,
        fake = true;
}
