import 'package:adair_flutter_lib/utils/string.dart';
import 'package:flutter/material.dart';

import '../model/gen/anglers_log.pb.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/input_controller.dart';
import '../widgets/input_type.dart';

/// A simple structure for storing build information for a form's input fields.
class Field {
  static StringCallback _customEntityName(CustomEntity entity) =>
      (_) => entity.name;

  static StringCallback _customEntityDescription(CustomEntity entity) =>
      (_) => entity.description;

  final Id id;

  /// Returns user-visible label text. This is required for displaying this
  /// input in the list of available inputs in an [EditableFormPage]. If the
  /// [Field] does not belong to an [EditableFormPage], this value can be
  /// null.
  late final StringCallback? name;

  late final StringCallback? description;

  /// Whether the input can be removed from the associated form. Defaults to
  /// `true`.
  final bool isRemovable;

  /// A function that builds a "fake" field; for example, a widget that isn't
  /// actually an input field, like a [MinDivider].
  final Widget Function(BuildContext)? fakeBuilder;

  final InputController controller;

  /// True if the [Widget] associated with this [Field] is currently showing
  /// in the form; false otherwise. This value may be updated when used in an
  /// [EditableFormPage].
  bool isShowing;

  Field({
    required this.id,
    required this.controller,
    this.name,
    StringCallback? description,
    this.isShowing = true,
    this.isRemovable = true,
  }) : fakeBuilder = null {
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
      fakeBuilder = null;

  Field.fake({required Widget Function(BuildContext) builder, Id? id})
    : id = id ?? randomId(),
      controller = InputController(),
      name = null,
      description = null,
      isShowing = true,
      isRemovable = true,
      fakeBuilder = builder;

  bool get isFake => fakeBuilder != null;
}
