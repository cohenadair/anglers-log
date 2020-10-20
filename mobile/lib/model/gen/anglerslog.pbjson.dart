///
//  Generated code. Do not modify.
//  source: anglerslog.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

const Id$json = const {
  '1': 'Id',
  '2': const [
    const {'1': 'uuid', '3': 1, '4': 1, '5': 9, '10': 'uuid'},
  ],
};

const CustomEntity$json = const {
  '1': 'CustomEntity',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    const {'1': 'type', '3': 4, '4': 1, '5': 14, '6': '.anglerslog.CustomEntity.Type', '10': 'type'},
  ],
  '4': const [CustomEntity_Type$json],
};

const CustomEntity_Type$json = const {
  '1': 'Type',
  '2': const [
    const {'1': 'BOOL', '2': 0},
    const {'1': 'NUMBER', '2': 1},
    const {'1': 'TEXT', '2': 2},
  ],
};

const CustomEntityValue$json = const {
  '1': 'CustomEntityValue',
  '2': const [
    const {'1': 'custom_entity_id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'customEntityId'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

const Bait$json = const {
  '1': 'Bait',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'bait_category_id', '3': 3, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'baitCategoryId'},
    const {'1': 'custom_entity_values', '3': 4, '4': 3, '5': 11, '6': '.anglerslog.CustomEntityValue', '10': 'customEntityValues'},
  ],
};

const BaitCategory$json = const {
  '1': 'BaitCategory',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

const Catch$json = const {
  '1': 'Catch',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'timestamp', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'timestamp'},
    const {'1': 'bait_id', '3': 3, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'baitId'},
    const {'1': 'fishing_spot_id', '3': 4, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'fishingSpotId'},
    const {'1': 'species_id', '3': 5, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'speciesId'},
    const {'1': 'image_names', '3': 6, '4': 3, '5': 9, '10': 'imageNames'},
    const {'1': 'custom_entity_values', '3': 7, '4': 3, '5': 11, '6': '.anglerslog.CustomEntityValue', '10': 'customEntityValues'},
  ],
};

const FishingSpot$json = const {
  '1': 'FishingSpot',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'lat', '3': 3, '4': 1, '5': 1, '10': 'lat'},
    const {'1': 'lng', '3': 4, '4': 1, '5': 1, '10': 'lng'},
  ],
};

const Species$json = const {
  '1': 'Species',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

const SummaryReport$json = const {
  '1': 'SummaryReport',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    const {'1': 'display_date_range_id', '3': 4, '4': 1, '5': 9, '10': 'displayDateRangeId'},
    const {'1': 'start_timestamp', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'startTimestamp'},
    const {'1': 'end_timestamp', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'endTimestamp'},
    const {'1': 'bait_ids', '3': 7, '4': 3, '5': 11, '6': '.anglerslog.Id', '10': 'baitIds'},
    const {'1': 'fishing_spot_ids', '3': 8, '4': 3, '5': 11, '6': '.anglerslog.Id', '10': 'fishingSpotIds'},
    const {'1': 'species_ids', '3': 9, '4': 3, '5': 11, '6': '.anglerslog.Id', '10': 'speciesIds'},
  ],
};

const ComparisonReport$json = const {
  '1': 'ComparisonReport',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    const {'1': 'from_display_date_range_id', '3': 4, '4': 1, '5': 9, '10': 'fromDisplayDateRangeId'},
    const {'1': 'to_display_date_range_id', '3': 5, '4': 1, '5': 9, '10': 'toDisplayDateRangeId'},
    const {'1': 'from_start_timestamp', '3': 6, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'fromStartTimestamp'},
    const {'1': 'to_start_timestamp', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'toStartTimestamp'},
    const {'1': 'from_end_timestamp', '3': 8, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'fromEndTimestamp'},
    const {'1': 'to_end_timestamp', '3': 9, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'toEndTimestamp'},
    const {'1': 'bait_ids', '3': 10, '4': 3, '5': 11, '6': '.anglerslog.Id', '10': 'baitIds'},
    const {'1': 'fishing_spot_ids', '3': 11, '4': 3, '5': 11, '6': '.anglerslog.Id', '10': 'fishingSpotIds'},
    const {'1': 'species_ids', '3': 12, '4': 3, '5': 11, '6': '.anglerslog.Id', '10': 'speciesIds'},
  ],
};

