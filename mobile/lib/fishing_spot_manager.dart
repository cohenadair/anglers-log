import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
import 'body_of_water_manager.dart';
import 'catch_manager.dart';
import 'i18n/strings.dart';
import 'image_entity_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'utils/map_utils.dart';
import 'utils/protobuf_utils.dart';
import 'utils/string_utils.dart';

class FishingSpotManager extends ImageEntityManager<FishingSpot> {
  static FishingSpotManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).fishingSpotManager;

  BodyOfWaterManager get _bodyOfWaterManager => appManager.bodyOfWaterManager;

  CatchManager get _catchManager => appManager.catchManager;

  UserPreferenceManager get _userPreferenceManager =>
      appManager.userPreferenceManager;

  FishingSpotManager(AppManager app) : super(app);

  @override
  FishingSpot entityFromBytes(List<int> bytes) => FishingSpot.fromBuffer(bytes);

  @override
  Id id(FishingSpot entity) => entity.id;

  @override
  String name(FishingSpot entity) => entity.name;

  /// Returns [name] if it is not empty, otherwise returns the
  /// spot's coordinates as a string in the format provided by [formatLatLng].
  @override
  String displayName(
    BuildContext context,
    FishingSpot entity, {
    bool useLatLngFallback = true,
    bool includeLatLngLabels = true,
    bool includeBodyOfWater = false,
  }) {
    var spotName = name(entity);
    var bodyOfWaterName =
        _bodyOfWaterManager.displayNameFromId(context, entity.bodyOfWaterId);

    // Name and body of water are both set, body of water is included
    if (isNotEmpty(spotName) &&
        isNotEmpty(bodyOfWaterName) &&
        includeBodyOfWater) {
      return "$spotName ($bodyOfWaterName)";
    }

    String? result = spotName;
    if (isEmpty(result) && includeBodyOfWater) {
      result = bodyOfWaterName;
    }

    var latLng = formatLatLng(
      context: context,
      lat: entity.lat,
      lng: entity.lng,
      includeLabels: includeLatLngLabels,
    );

    // Neither name nor body of water is set, use coordinates.
    if (isEmpty(result) && useLatLngFallback) {
      return latLng;
    }

    // Either name or body of water is set, not both.
    return result ?? "";
  }

  @override
  String? displayNameFromId(
    BuildContext context,
    Id? id, {
    bool useLatLngFallback = true,
    bool includeLatLngLabels = true,
    bool includeBodyOfWater = false,
  }) {
    var spot = entity(id);
    if (spot == null) {
      return null;
    }

    return displayName(
      context,
      spot,
      useLatLngFallback: useLatLngFallback,
      includeLatLngLabels: includeLatLngLabels,
      includeBodyOfWater: includeBodyOfWater,
    );
  }

  @override
  String get tableName => "fishing_spot";

  @override
  void setImageName(FishingSpot entity, String imageName) =>
      entity.imageName = imageName;

  @override
  void clearImageName(FishingSpot entity) => entity.clearImageName();

  @override
  bool matchesFilter(Id id, BuildContext context, String? filter) {
    var fishingSpot = entity(id);
    if (fishingSpot == null) {
      return false;
    }

    return super.matchesFilter(fishingSpot.id, context, filter) ||
        _bodyOfWaterManager.matchesFilter(
            fishingSpot.bodyOfWaterId, context, filter) ||
        containsTrimmedLowerCase(fishingSpot.notes, filter!);
  }

  @override
  List<FishingSpot> listSortedByDisplayName(
    BuildContext context, {
    String? filter,
    Iterable<Id> ids = const [],
  }) {
    var namedSpots = <FishingSpot>[];
    var otherSpots = <FishingSpot>[];

    for (var fishingSpot
        in super.listSortedByDisplayName(context, filter: filter, ids: ids)) {
      if (isEmpty(fishingSpot.name)) {
        otherSpots.add(fishingSpot);
      } else {
        namedSpots.add(fishingSpot);
      }
    }

    return namedSpots..addAll(otherSpots);
  }

  /// Returns the [FishingSpot] with the given [name] and associated
  /// [BodyOfWater] with [bodyOfWaterId] or null if one does not exist.
  FishingSpot? namedWithBodyOfWater(String? name, Id? bodyOfWaterId) {
    return super.named(name, andCondition: (fishingSpot) {
      return bodyOfWaterId == null ||
          fishingSpot.bodyOfWaterId == bodyOfWaterId;
    });
  }

  /// Returns the closest [FishingSpot] within a user-set distance.
  FishingSpot? withinPreferenceRadius(LatLng? latLng) {
    if (latLng == null) {
      return null;
    }

    var meters = _userPreferenceManager.fishingSpotDistance
        .convertToSystem(MeasurementSystem.metric, Unit.meters)
        .mainValue
        .value;

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
