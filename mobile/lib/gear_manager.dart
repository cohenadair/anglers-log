import 'package:flutter/material.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'catch_manager.dart';
import 'i18n/strings.dart';
import 'image_entity_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/string_utils.dart';

class GearManager extends ImageEntityManager<Gear> {
  static GearManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).gearManager;

  CatchManager get _catchManager => appManager.catchManager;

  GearManager(AppManager app) : super(app);

  @override
  Gear entityFromBytes(List<int> bytes) => Gear.fromBuffer(bytes);

  @override
  Id id(Gear entity) => entity.id;

  @override
  String name(Gear entity) => entity.name;

  @override
  String get tableName => "gear";

  @override
  void clearImageName(Gear entity) => entity.clearImageName();

  @override
  bool matchesFilter(Id id, BuildContext context, String? filter) {
    var gear = entity(id);
    if (gear == null) {
      return false;
    }

    return super.matchesFilter(gear.id, context, filter) ||
        containsTrimmedLowerCase(gear.rodMakeModel, filter!) ||
        containsTrimmedLowerCase(gear.rodSerialNumber, filter) ||
        containsTrimmedLowerCase(gear.reelMakeModel, filter) ||
        containsTrimmedLowerCase(gear.reelSerialNumber, filter) ||
        containsTrimmedLowerCase(gear.reelSize.toString(), filter) ||
        containsTrimmedLowerCase(gear.lineMakeModel, filter) ||
        containsTrimmedLowerCase(gear.lineColor, filter) ||
        containsTrimmedLowerCase(gear.hookMakeModel, filter) ||
        containsTrimmedLowerCase(
            gear.rodLength.displayValue(context), filter) ||
        containsTrimmedLowerCase(gear.rodAction.displayName(context), filter) ||
        containsTrimmedLowerCase(gear.rodPower.displayName(context), filter) ||
        containsTrimmedLowerCase(
            gear.lineRating.displayValue(context), filter) ||
        containsTrimmedLowerCase(
            gear.leaderLength.displayValue(context), filter) ||
        containsTrimmedLowerCase(
            gear.leaderRating.displayValue(context), filter) ||
        containsTrimmedLowerCase(
            gear.tippetLength.displayValue(context), filter) ||
        containsTrimmedLowerCase(
            gear.tippetRating.displayValue(context), filter) ||
        containsTrimmedLowerCase(gear.hookSize.displayValue(context), filter);
  }

  @override
  void setImageName(Gear entity, String imageName) =>
      entity.imageName = imageName;

  int numberOfCatches(Id? gearId) {
    return numberOf<Catch>(
      gearId,
      _catchManager.list(),
      (cat) => cat.gearIds.where((id) => id == gearId).isNotEmpty,
    );
  }

  /// Returns the number of catches made with the given [Gear] ID. This is
  /// different from [numberOfCatches] in that [Catch.quantity] is used, instead
  /// of 1.
  int numberOfCatchQuantities(Id? gearId) {
    return numberOf<Catch>(
      gearId,
      _catchManager.list(),
      (cat) => cat.gearIds.where((id) => id == gearId).isNotEmpty,
      (cat) => cat.hasQuantity() ? cat.quantity : 1,
    );
  }

  String deleteMessage(BuildContext context, Gear gear) {
    var numOfCatches = numberOfCatches(gear.id);
    var string = numOfCatches == 1
        ? Strings.of(context).gearListPageDeleteMessageSingular
        : Strings.of(context).gearListPageDeleteMessage;
    return format(string, [displayName(context, gear), numOfCatches]);
  }
}
