import 'package:flutter/material.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/input_type.dart';

/// A simple structure for storing build information for a form's input fields.
class InputData {
  static String Function(BuildContext)
      _customEntityLabel(CustomEntity entity) => (_) => entity.name;

  final Id id;

  /// Returns user-visible label text. This is required for displaying this
  /// input in the list of available inputs in an [EditableFormPage]. If the
  /// [InputData] does not belong to an [EditableFormPage], this value can be
  /// null.
  final String Function(BuildContext) label;

  /// Whether the input can be removed from the associated form. Defaults to
  /// `true`.
  final bool removable;

  /// True of the [InputData] is fake. This is useful for inserting section
  /// separators in to the form.
  final bool fake;

  /// True if the [Widget] associated with this [InputData] is currently showing
  /// in the form; false otherwise. This value may be updated when used in an
  /// [EditableFormPage].
  bool showing;

  InputController controller;

  InputData({
    @required this.id,
    @required this.controller,
    this.label,
    this.showing = true,
    this.removable = true,
  }) : assert(id != null),
       assert(controller != null),
       fake = false;

  InputData.fromCustomEntity(CustomEntity entity)
      : assert(entity != null),
        id = entity.id,
        controller = inputTypeController(entity.type),
        label = _customEntityLabel(entity),
        showing = true,
        removable = true,
        fake = false;

  InputData.fake()
      : id = randomId(),
        controller = InputController(),
        label = null,
        showing = true,
        removable = true,
        fake = true;
}