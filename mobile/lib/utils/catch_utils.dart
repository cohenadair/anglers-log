import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/image_picker_page.dart';
import '../widgets/input_controller.dart';
import '../widgets/input_data.dart';

// Unique IDs for each catch field. These are stored in the database and
// should not be changed.
Id catchFieldIdTimestamp() =>
    Id()..uuid = "dbe382be-b219-4703-af11-a8ce16a191b7";

Id catchFieldIdImages() => Id()..uuid = "cb268ed0-59e2-469e-9279-a74e15ff42e8";

Id catchFieldIdSpecies() => Id()..uuid = "7c4a5178-4e3b-4b97-ac69-b4a5439c4d94";

Id catchFieldIdFishingSpot() =>
    Id()..uuid = "2e4e6124-6fc8-4a60-b8f3-b42debd97a99";

Id catchFieldIdBait() => Id()..uuid = "916e26ae-9448-4cef-b518-cfe4b4c1e5e8";

/// Returns all catch fields, sorted by how they are rendered on a
/// [SaveCatchPage].
List<Field> allCatchFields() {
  return [
    Field(
      id: catchFieldIdTimestamp(),
      removable: false,
      name: (context) => Strings.of(context).catchFieldDateTime,
      controller: TimestampInputController(),
    ),
    Field(
      id: catchFieldIdSpecies(),
      removable: false,
      name: (context) => Strings.of(context).catchFieldSpecies,
      controller: InputController<Id>(),
    ),
    Field(
      id: catchFieldIdBait(),
      name: (context) => Strings.of(context).catchFieldBaitLabel,
      controller: InputController<Id>(),
    ),
    Field(
      id: catchFieldIdImages(),
      name: (context) => Strings.of(context).catchFieldImages,
      controller: InputController<List<PickedImage>>(),
    ),
    Field(
      id: catchFieldIdFishingSpot(),
      name: (context) => Strings.of(context).catchFieldFishingSpot,
      description: (context) =>
          Strings.of(context).catchFieldFishingSpotDescription,
      controller: InputController<Id>(),
    ),
  ];
}

/// Returns all catch fields sorted alphabetically.
List<Field> allCatchFieldsSorted(BuildContext context) {
  var fields = allCatchFields();
  fields.sort((lhs, rhs) => lhs.name(context).compareTo(rhs.name(context)));
  return fields;
}
