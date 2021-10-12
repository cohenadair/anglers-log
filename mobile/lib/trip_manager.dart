import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/angler_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'custom_entity_manager.dart';
import 'fishing_spot_manager.dart';
import 'i18n/strings.dart';
import 'image_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'named_entity_manager.dart';
import 'species_manager.dart';
import 'utils/protobuf_utils.dart';
import 'utils/string_utils.dart';

class TripManager extends NamedEntityManager<Trip> {
  static TripManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).tripManager;

  TripManager(AppManager app) : super(app);

  AnglerManager get _anglerManager => appManager.anglerManager;

  BaitManager get _baitManager => appManager.baitManager;

  CatchManager get _catchManager => appManager.catchManager;

  CustomEntityManager get _customEntityManager =>
      appManager.customEntityManager;

  FishingSpotManager get _fishingSpotManager => appManager.fishingSpotManager;

  ImageManager get _imageManager => appManager.imageManager;

  SpeciesManager get _speciesManager => appManager.speciesManager;

  @override
  Trip entityFromBytes(List<int> bytes) => Trip.fromBuffer(bytes);

  @override
  Id id(Trip entity) => entity.id;

  @override
  String name(Trip entity) => entity.name;

  @override
  String get tableName => "trip";

  @override
  Future<bool> addOrUpdate(
    Trip entity, {
    List<File> imageFiles = const [],
    bool notify = true,
  }) async {
    entity.imageNames.clear();
    entity.imageNames
        .addAll(await _imageManager.save(imageFiles, compress: true));

    return super.addOrUpdate(entity, notify: notify);
  }

  @override
  bool matchesFilter(Id id, String? filter, [BuildContext? context]) {
    var trip = entity(id);
    if (trip == null) {
      return false;
    }

    return super.matchesFilter(trip.id, filter) ||
        _catchManager.idsMatchesFilter(trip.catchIds, filter) ||
        _speciesManager.idsMatchesFilter(
            trip.speciesCatches.map((e) => e.entityId).toList(), filter) ||
        _fishingSpotManager.idsMatchesFilter(
            trip.fishingSpotCatches.map((e) => e.entityId).toList(), filter) ||
        _anglerManager.idsMatchesFilter(
            trip.anglerCatches.map((e) => e.entityId).toList(), filter) ||
        context == null ||
        _baitManager.attachmentsMatchesFilter(
            trip.baitCatches.map((e) => e.attachment).toList(),
            filter,
            context) ||
        (trip.hasWasSkunked() &&
            containsTrimmedLowerCase(
                Strings.of(context).tripPageSkunked, filter!)) ||
        (trip.hasNotes() && containsTrimmedLowerCase(trip.notes, filter!)) ||
        (trip.hasAtmosphere() &&
            trip.atmosphere.matchesFilter(context, filter)) ||
        filterMatchesEntityValues(
            trip.customEntityValues, filter, _customEntityManager);
  }

  String deleteMessage(BuildContext context, Trip trip) {
    return format(Strings.of(context).tripListPageDeleteMessage,
        [trip.displayName(context)]);
  }
}
