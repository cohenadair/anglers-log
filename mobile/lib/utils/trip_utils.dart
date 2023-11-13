import 'package:flutter/material.dart';
import 'package:mobile/pages/save_trip_page.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../widgets/field.dart';
import '../widgets/input_controller.dart';

// Unique IDs for each trip field. These are stored in the database and should
// not be changed.
final tripFieldIdStartTimestamp =
    Id(uuid: "0f012ca1-aae3-4aec-86e2-d85479eb6d66");
final tripFieldIdEndTimestamp =
    Id(uuid: "c6afa4ff-add6-4a01-b69a-ba6f9b456c85");
final tripFieldIdTimeZone = Id(uuid: "205933d4-27f5-4917-ae92-08366a469963");
final tripFieldIdName = Id(uuid: "d9a83fa6-926d-474d-8ddf-8d0e044d2ea4");
final tripFieldIdImages = Id(uuid: "8c593cbb-4782-49c7-b540-0c22d8175b3f");
final tripFieldIdCatches = Id(uuid: "0806fcc4-5d77-44b4-85e2-ebc066f37e12");
final tripFieldIdBodiesOfWater =
    Id(uuid: "45c91a90-62d1-47fe-b360-c5494a265ef6");
final tripFieldIdCatchesPerFishingSpot =
    Id(uuid: "70d19321-1cc7-4842-b7e4-252ce79f18d0");
final tripFieldIdCatchesPerAngler =
    Id(uuid: "20288727-76f3-49fc-a975-0d740931e3a4");
final tripFieldIdCatchesPerSpecies =
    Id(uuid: "d7864201-af18-464a-8815-571aa6f82f8c");
final tripFieldIdCatchesPerBait =
    Id(uuid: "ad35c21c-13cb-486b-812d-6315d0bf5004");
final tripFieldIdNotes = Id(uuid: "3d3bc3c9-e316-49fe-8427-ae344dffe38e");
final tripFieldIdAtmosphere = Id(uuid: "b7f6ad7f-e1b8-4e15-b29c-688429787dd9");
final tripFieldIdGpsTrails = Id(uuid: "fa8600e6-c18e-44d5-9761-dd8eb8433e43");

/// Returns all trip fields, sorted by how they are rendered on an
/// [SaveTripPage].
List<Field> allTripFields(BuildContext context) {
  return [
    Field(
      id: tripFieldIdCatches,
      name: (context) => Strings.of(context).entityNameCatches,
      description: (context) => Strings.of(context).saveTripPageCatchesDesc,
      controller: SetInputController<Id>(),
    ),
    Field(
      id: tripFieldIdBodiesOfWater,
      name: (context) => Strings.of(context).entityNameBodiesOfWater,
      controller: SetInputController<Id>(),
    ),
    Field(
      id: tripFieldIdStartTimestamp,
      isRemovable: false,
      name: (context) => Strings.of(context).saveTripPageStartDateTime,
      controller: CurrentDateTimeInputController(context),
    ),
    Field(
      id: tripFieldIdEndTimestamp,
      isRemovable: false,
      name: (context) => Strings.of(context).saveTripPageEndDateTime,
      controller: CurrentDateTimeInputController(context),
    ),
    Field(
      id: tripFieldIdTimeZone,
      name: (context) => Strings.of(context).timeZoneInputLabel,
      description: (context) => Strings.of(context).timeZoneInputDescription,
      controller: TimeZoneInputController(context),
    ),
    Field(
      id: tripFieldIdName,
      name: (context) => Strings.of(context).inputNameLabel,
      controller: TextInputController(),
    ),
    Field(
      id: tripFieldIdNotes,
      name: (context) => Strings.of(context).inputNotesLabel,
      controller: TextInputController(),
    ),
    Field(
      id: tripFieldIdImages,
      name: (context) => Strings.of(context).tripFieldPhotos,
      controller: ImagesInputController(),
    ),
    Field(
      id: tripFieldIdAtmosphere,
      name: (context) => Strings.of(context).inputAtmosphere,
      controller: InputController<Atmosphere>(),
    ),
    Field(
      id: tripFieldIdCatchesPerAngler,
      name: (context) => Strings.of(context).tripCatchesPerAngler,
      controller: SetInputController<Trip_CatchesPerEntity>(),
    ),
    Field(
      id: tripFieldIdCatchesPerBait,
      name: (context) => Strings.of(context).tripCatchesPerBait,
      controller: SetInputController<Trip_CatchesPerBait>(),
    ),
    Field(
      id: tripFieldIdCatchesPerFishingSpot,
      name: (context) => Strings.of(context).tripCatchesPerFishingSpot,
      controller: SetInputController<Trip_CatchesPerEntity>(),
    ),
    Field(
      id: tripFieldIdCatchesPerSpecies,
      name: (context) => Strings.of(context).tripCatchesPerSpecies,
      controller: SetInputController<Trip_CatchesPerEntity>(),
    ),
    Field(
      id: tripFieldIdGpsTrails,
      name: (context) => Strings.of(context).entityNameGpsTrails,
      controller: SetInputController<Id>(),
    ),
  ];
}
