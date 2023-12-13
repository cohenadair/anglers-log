import 'package:flutter/material.dart';
import 'package:mobile/gear_manager.dart';
import 'package:mobile/pages/save_gear_page.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/multi_measurement_input.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/image_picker_page.dart';
import '../widgets/field.dart';

// Unique IDs for each gear field. These are stored in the database and
// should not be changed.
final gearFieldIdName = Id()..uuid = "cd151059-1d61-4784-90b0-d28706f8d3e0";
final gearFieldIdImage = Id()..uuid = "25b1957a-e355-49d6-812a-e2f717196d14";
final gearFieldIdRodMakeModel = Id()
  ..uuid = "a9f191e7-1757-43c6-9f7a-5ba4cf6e0a39";
final gearFieldIdRodSerialNumber = Id()
  ..uuid = "790e0b67-6a31-435f-b970-d87a95accfb5";
final gearFieldIdRodLength = Id()
  ..uuid = "1462fe28-3b24-42e6-a59c-115dc940485d";
final gearFieldIdRodAction = Id()
  ..uuid = "da9b42c7-9fc7-48e2-a0bf-3b848f462762";
final gearFieldIdRodPower = Id()..uuid = "7546c902-6e56-4d31-b3db-a5ebf202b5ac";
final gearFieldIdReelMakeModel = Id()
  ..uuid = "b56eba71-d3a7-4577-a5d3-cdbef0b547eb";
final gearFieldIdReelSerialNumber = Id()
  ..uuid = "de5fd2c9-9e15-4c9a-9297-aaf50e02da8a";
final gearFieldIdReelSize = Id()..uuid = "15bd2850-cdb9-433e-99e6-9d706445672c";
final gearFieldIdLineMakeModel = Id()
  ..uuid = "4a97081f-edab-4ee1-9bb1-de8eed5453b4";
final gearFieldIdLineRating = Id()
  ..uuid = "99b86202-2296-4bbc-a01c-d3d0bcdfdf46";
final gearFieldIdLineColor = Id()
  ..uuid = "be1eb7c8-fa6a-4288-bd13-3cd5f479da46";
final gearFieldIdLeaderLength = Id()
  ..uuid = "eb0cde8f-6c81-4b7b-a56e-7be765d3f350";
final gearFieldIdLeaderRating = Id()
  ..uuid = "747bdfa2-c3d7-4a5b-b627-c257cd03072f";
final gearFieldIdTippetLength = Id()
  ..uuid = "73377470-e307-450c-bff0-309ea79ebec7";
final gearFieldIdTippetRating = Id()
  ..uuid = "bda6e5d3-e94c-46e0-ba54-39880aefbd6e";
final gearFieldIdHookMakeModel = Id()
  ..uuid = "65040559-62b9-47d1-bb21-d716d38b17bf";
final gearFieldIdHookSize = Id()..uuid = "5bca8dbd-b4dd-430e-98d8-c69be28145c1";

/// Returns all gear fields, sorted by how they are rendered on a
/// [SaveGearPage].
List<Field> allGearFields(BuildContext context) {
  return [
    Field(
      id: gearFieldIdImage,
      name: (context) => Strings.of(context).gearFieldImage,
      controller: InputController<PickedImage>(),
    ),
    Field(
      id: gearFieldIdName,
      name: (context) => Strings.of(context).inputNameLabel,
      controller: TextInputController.name(),
      isRemovable: false,
    ),
    Field(
      id: gearFieldIdRodMakeModel,
      name: (context) => Strings.of(context).gearFieldRodMakeModel,
      controller: TextInputController(),
    ),
    Field(
      id: gearFieldIdRodSerialNumber,
      name: (context) => Strings.of(context).gearFieldRodSerialNumber,
      controller: TextInputController(),
    ),
    Field(
      id: gearFieldIdRodLength,
      name: (context) => Strings.of(context).gearFieldRodLength,
      controller:
          MultiMeasurementInputSpec.rodLength(context).newInputController(),
    ),
    Field(
      id: gearFieldIdRodAction,
      name: (context) => Strings.of(context).gearFieldRodAction,
      controller: InputController<RodAction>(),
    ),
    Field(
      id: gearFieldIdRodPower,
      name: (context) => Strings.of(context).gearFieldRodPower,
      controller: InputController<RodPower>(),
    ),
    Field(
      id: gearFieldIdReelMakeModel,
      name: (context) => Strings.of(context).gearFieldReelMakeModel,
      controller: TextInputController(),
    ),
    Field(
      id: gearFieldIdReelSerialNumber,
      name: (context) => Strings.of(context).gearFieldReelSerialNumber,
      controller: TextInputController(),
    ),
    Field(
      id: gearFieldIdReelSize,
      name: (context) => Strings.of(context).gearFieldReelSize,
      controller: TextInputController(),
    ),
    Field(
      id: gearFieldIdLineMakeModel,
      name: (context) => Strings.of(context).gearFieldLineMakeModel,
      controller: TextInputController(),
    ),
    Field(
      id: gearFieldIdLineRating,
      name: (context) => Strings.of(context).gearFieldLineRating,
      controller:
          MultiMeasurementInputSpec.lineRating(context).newInputController(),
    ),
    Field(
      id: gearFieldIdLineColor,
      name: (context) => Strings.of(context).gearFieldLineColor,
      controller: TextInputController(),
    ),
    Field(
      id: gearFieldIdLeaderLength,
      name: (context) => Strings.of(context).gearFieldLeaderLength,
      controller:
          MultiMeasurementInputSpec.leaderLength(context).newInputController(),
    ),
    Field(
      id: gearFieldIdLeaderRating,
      name: (context) => Strings.of(context).gearFieldLeaderRating,
      controller:
          MultiMeasurementInputSpec.leaderRating(context).newInputController(),
    ),
    Field(
      id: gearFieldIdTippetLength,
      name: (context) => Strings.of(context).gearFieldTippetLength,
      controller:
          MultiMeasurementInputSpec.tippetLength(context).newInputController(),
    ),
    Field(
      id: gearFieldIdTippetRating,
      name: (context) => Strings.of(context).gearFieldTippetRating,
      controller:
          MultiMeasurementInputSpec.tippetRating(context).newInputController(),
    ),
    Field(
      id: gearFieldIdHookMakeModel,
      name: (context) => Strings.of(context).gearFieldHookMakeModel,
      controller: TextInputController(),
    ),
    Field(
      id: gearFieldIdHookSize,
      name: (context) => Strings.of(context).gearFieldHookSize,
      controller:
          MultiMeasurementInputSpec.hookSize(context).newInputController(),
    ),
  ];
}

class GearListItemModel {
  late final String title;
  late final String? subtitle;
  late final String? imageName;

  GearListItemModel(BuildContext context, Gear gear) {
    var gearManager = GearManager.of(context);
    title = gearManager.displayName(context, gear);
    subtitle = formatNumberOfCatches(
        context, gearManager.numberOfCatchQuantities(gear.id));
    imageName = gear.imageName;
  }
}
