import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
import 'body_of_water_manager.dart';
import 'catch_manager.dart';
import 'i18n/strings.dart';
import 'image_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'named_entity_manager.dart';
import 'utils/map_utils.dart';
import 'utils/string_utils.dart';

class FishingSpotManager extends NamedEntityManager<FishingSpot> {
  static FishingSpotManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).fishingSpotManager;

  BodyOfWaterManager get _bodyOfWaterManager => appManager.bodyOfWaterManager;

  CatchManager get _catchManager => appManager.catchManager;

  ImageManager get _imageManager => appManager.imageManager;

  FishingSpotManager(AppManager app) : super(app);

  @override
  FishingSpot entityFromBytes(List<int> bytes) => FishingSpot.fromBuffer(bytes);

  @override
  Id id(FishingSpot fishingSpot) => fishingSpot.id;

  @override
  String name(FishingSpot fishingSpot) => fishingSpot.name;

  @override
  String get tableName => "fishing_spot";

  @override
  bool matchesFilter(Id id, String? filter, [BuildContext? context]) {
    var fishingSpot = entity(id);
    if (fishingSpot == null) {
      return false;
    }

    return super.matchesFilter(fishingSpot.id, filter) ||
        _bodyOfWaterManager.matchesFilter(fishingSpot.bodyOfWaterId, filter) ||
        containsTrimmedLowerCase(fishingSpot.notes, filter!);
  }

  @override
  List<FishingSpot> listSortedByName({String? filter}) {
    var namedSpots = <FishingSpot>[];
    var otherSpots = <FishingSpot>[];

    for (var fishingSpot in super.listSortedByName(filter: filter)) {
      if (isEmpty(fishingSpot.name)) {
        otherSpots.add(fishingSpot);
      } else {
        namedSpots.add(fishingSpot);
      }
    }

    return namedSpots..addAll(otherSpots);
  }

  @override
  Future<bool> addOrUpdate(
    FishingSpot fishingSpot, {
    File? imageFile,
    bool notify = true,
  }) async {
    if (imageFile != null) {
      var savedImages = await _imageManager.save([imageFile], compress: true);
      if (savedImages.isNotEmpty) {
        fishingSpot.imageName = savedImages.first;
      } else {
        fishingSpot.clearImageName();
      }
    }

    return super.addOrUpdate(fishingSpot, notify: notify);
  }

  /// Returns the closest [FishingSpot] within [meters] of [latLng], or null if
  /// one does not exist. [meters] defaults to 30.
  FishingSpot? withinRadius(LatLng? latLng, [int meters = 30]) {
    if (latLng == null) {
      return null;
    }

    var eligibleFishingSpotsMap = <FishingSpot, double>{};
    for (var fishingSpot in entities.values) {
      var distance =
          distanceBetween(LatLng(fishingSpot.lat, fishingSpot.lng), latLng);
      if (distance <= meters) {
        eligibleFishingSpotsMap[fishingSpot] = distance;
      }
    }

    FishingSpot? result;
    var minDistance = (meters + 1).toDouble();

    eligibleFishingSpotsMap.forEach((fishingSpot, distance) {
      if (distance < minDistance) {
        minDistance = distance;
        result = fishingSpot;
      }
    });

    return result;
  }

  /// Returns a [FishingSpot] with the same coordinates as the given
  /// [FishingSpot], or null if one doesn't exist.
  FishingSpot? withLatLng(FishingSpot? rhs) {
    if (rhs == null) {
      return null;
    }

    return entities.values.firstWhereOrNull((fishingSpot) =>
        fishingSpot.lat == rhs.lat && fishingSpot.lng == rhs.lng);
  }

  int numberOfCatches(Id? fishingSpotId) => numberOf<Catch>(fishingSpotId,
      _catchManager.list(), (cat) => cat.fishingSpotId == fishingSpotId);

  String deleteMessage(BuildContext context, FishingSpot fishingSpot) {
    var numOfCatches = numberOfCatches(fishingSpot.id);
    var hasNameString = numOfCatches == 1
        ? Strings.of(context).mapPageDeleteFishingSpotSingular
        : Strings.of(context).mapPageDeleteFishingSpot;

    if (isNotEmpty(fishingSpot.name)) {
      return format(hasNameString, [fishingSpot.name, numOfCatches]);
    } else if (numOfCatches == 1) {
      return format(Strings.of(context).mapPageDeleteFishingSpotNoNameSingular,
          [numOfCatches]);
    } else {
      return format(
          Strings.of(context).mapPageDeleteFishingSpotNoName, [numOfCatches]);
    }
  }
}
