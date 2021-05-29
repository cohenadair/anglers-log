///
//  Generated code. Do not modify.
//  source: anglerslog.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use measurementSystemDescriptor instead')
const MeasurementSystem$json = const {
  '1': 'MeasurementSystem',
  '2': const [
    const {'1': 'imperial_whole', '2': 0},
    const {'1': 'imperial_decimal', '2': 1},
    const {'1': 'metric', '2': 2},
  ],
};

/// Descriptor for `MeasurementSystem`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List measurementSystemDescriptor = $convert.base64Decode(
    'ChFNZWFzdXJlbWVudFN5c3RlbRISCg5pbXBlcmlhbF93aG9sZRAAEhQKEGltcGVyaWFsX2RlY2ltYWwQARIKCgZtZXRyaWMQAg==');
@$core.Deprecated('Use numberBoundaryDescriptor instead')
const NumberBoundary$json = const {
  '1': 'NumberBoundary',
  '2': const [
    const {'1': 'number_boundary_any', '2': 0},
    const {'1': 'less_than', '2': 1},
    const {'1': 'less_than_or_equal_to', '2': 2},
    const {'1': 'equal_to', '2': 3},
    const {'1': 'greater_than', '2': 4},
    const {'1': 'greater_than_or_equal_to', '2': 5},
    const {'1': 'range', '2': 6},
  ],
};

/// Descriptor for `NumberBoundary`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List numberBoundaryDescriptor = $convert.base64Decode(
    'Cg5OdW1iZXJCb3VuZGFyeRIXChNudW1iZXJfYm91bmRhcnlfYW55EAASDQoJbGVzc190aGFuEAESGQoVbGVzc190aGFuX29yX2VxdWFsX3RvEAISDAoIZXF1YWxfdG8QAxIQCgxncmVhdGVyX3RoYW4QBBIcChhncmVhdGVyX3RoYW5fb3JfZXF1YWxfdG8QBRIJCgVyYW5nZRAG');
@$core.Deprecated('Use periodDescriptor instead')
const Period$json = const {
  '1': 'Period',
  '2': const [
    const {'1': 'period_all', '2': 0},
    const {'1': 'period_none', '2': 1},
    const {'1': 'dawn', '2': 2},
    const {'1': 'morning', '2': 3},
    const {'1': 'midday', '2': 4},
    const {'1': 'afternoon', '2': 5},
    const {'1': 'dusk', '2': 6},
    const {'1': 'night', '2': 7},
  ],
};

/// Descriptor for `Period`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List periodDescriptor = $convert.base64Decode(
    'CgZQZXJpb2QSDgoKcGVyaW9kX2FsbBAAEg8KC3BlcmlvZF9ub25lEAESCAoEZGF3bhACEgsKB21vcm5pbmcQAxIKCgZtaWRkYXkQBBINCglhZnRlcm5vb24QBRIICgRkdXNrEAYSCQoFbmlnaHQQBw==');
@$core.Deprecated('Use seasonDescriptor instead')
const Season$json = const {
  '1': 'Season',
  '2': const [
    const {'1': 'season_all', '2': 0},
    const {'1': 'season_none', '2': 1},
    const {'1': 'winter', '2': 2},
    const {'1': 'spring', '2': 3},
    const {'1': 'summer', '2': 4},
    const {'1': 'autumn', '2': 5},
  ],
};

/// Descriptor for `Season`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List seasonDescriptor = $convert.base64Decode(
    'CgZTZWFzb24SDgoKc2Vhc29uX2FsbBAAEg8KC3NlYXNvbl9ub25lEAESCgoGd2ludGVyEAISCgoGc3ByaW5nEAMSCgoGc3VtbWVyEAQSCgoGYXV0dW1uEAU=');
@$core.Deprecated('Use unitDescriptor instead')
const Unit$json = const {
  '1': 'Unit',
  '2': const [
    const {'1': 'feet', '2': 0},
    const {'1': 'inches', '2': 1},
    const {'1': 'pounds', '2': 2},
    const {'1': 'ounces', '2': 3},
    const {'1': 'fahrenheit', '2': 4},
    const {'1': 'meters', '2': 5},
    const {'1': 'centimeters', '2': 6},
    const {'1': 'kilograms', '2': 7},
    const {'1': 'celsius', '2': 8},
  ],
};

/// Descriptor for `Unit`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List unitDescriptor = $convert.base64Decode(
    'CgRVbml0EggKBGZlZXQQABIKCgZpbmNoZXMQARIKCgZwb3VuZHMQAhIKCgZvdW5jZXMQAxIOCgpmYWhyZW5oZWl0EAQSCgoGbWV0ZXJzEAUSDwoLY2VudGltZXRlcnMQBhINCglraWxvZ3JhbXMQBxILCgdjZWxzaXVzEAg=');
@$core.Deprecated('Use idDescriptor instead')
const Id$json = const {
  '1': 'Id',
  '2': const [
    const {'1': 'uuid', '3': 1, '4': 1, '5': 9, '10': 'uuid'},
  ],
};

/// Descriptor for `Id`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List idDescriptor =
    $convert.base64Decode('CgJJZBISCgR1dWlkGAEgASgJUgR1dWlk');
@$core.Deprecated('Use customEntityDescriptor instead')
const CustomEntity$json = const {
  '1': 'CustomEntity',
  '2': const [
    const {
      '1': 'id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'id'
    },
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    const {
      '1': 'type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.CustomEntity.Type',
      '10': 'type'
    },
  ],
  '4': const [CustomEntity_Type$json],
};

@$core.Deprecated('Use customEntityDescriptor instead')
const CustomEntity_Type$json = const {
  '1': 'Type',
  '2': const [
    const {'1': 'boolean', '2': 0},
    const {'1': 'number', '2': 1},
    const {'1': 'text', '2': 2},
  ],
};

/// Descriptor for `CustomEntity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customEntityDescriptor = $convert.base64Decode(
    'CgxDdXN0b21FbnRpdHkSHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlvbhIxCgR0eXBlGAQgASgOMh0uYW5nbGVyc2xvZy5DdXN0b21FbnRpdHkuVHlwZVIEdHlwZSIpCgRUeXBlEgsKB2Jvb2xlYW4QABIKCgZudW1iZXIQARIICgR0ZXh0EAI=');
@$core.Deprecated('Use customEntityValueDescriptor instead')
const CustomEntityValue$json = const {
  '1': 'CustomEntityValue',
  '2': const [
    const {
      '1': 'custom_entity_id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'customEntityId'
    },
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `CustomEntityValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customEntityValueDescriptor = $convert.base64Decode(
    'ChFDdXN0b21FbnRpdHlWYWx1ZRI4ChBjdXN0b21fZW50aXR5X2lkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFIOY3VzdG9tRW50aXR5SWQSFAoFdmFsdWUYAiABKAlSBXZhbHVl');
@$core.Deprecated('Use baitDescriptor instead')
const Bait$json = const {
  '1': 'Bait',
  '2': const [
    const {
      '1': 'id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'id'
    },
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {
      '1': 'bait_category_id',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'baitCategoryId'
    },
    const {
      '1': 'custom_entity_values',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CustomEntityValue',
      '10': 'customEntityValues'
    },
  ],
};

/// Descriptor for `Bait`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List baitDescriptor = $convert.base64Decode(
    'CgRCYWl0Eh4KAmlkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRI4ChBiYWl0X2NhdGVnb3J5X2lkGAMgASgLMg4uYW5nbGVyc2xvZy5JZFIOYmFpdENhdGVnb3J5SWQSTwoUY3VzdG9tX2VudGl0eV92YWx1ZXMYBCADKAsyHS5hbmdsZXJzbG9nLkN1c3RvbUVudGl0eVZhbHVlUhJjdXN0b21FbnRpdHlWYWx1ZXM=');
@$core.Deprecated('Use baitCategoryDescriptor instead')
const BaitCategory$json = const {
  '1': 'BaitCategory',
  '2': const [
    const {
      '1': 'id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'id'
    },
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `BaitCategory`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List baitCategoryDescriptor = $convert.base64Decode(
    'CgxCYWl0Q2F0ZWdvcnkSHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGAIgASgJUgRuYW1l');
@$core.Deprecated('Use catchDescriptor instead')
const Catch$json = const {
  '1': 'Catch',
  '2': const [
    const {
      '1': 'id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'id'
    },
    const {'1': 'timestamp', '3': 2, '4': 1, '5': 4, '10': 'timestamp'},
    const {
      '1': 'bait_id',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'baitId'
    },
    const {
      '1': 'fishing_spot_id',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'fishingSpotId'
    },
    const {
      '1': 'species_id',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'speciesId'
    },
    const {'1': 'image_names', '3': 6, '4': 3, '5': 9, '10': 'imageNames'},
    const {
      '1': 'custom_entity_values',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CustomEntityValue',
      '10': 'customEntityValues'
    },
    const {
      '1': 'angler_id',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'anglerId'
    },
    const {
      '1': 'method_ids',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'methodIds'
    },
    const {
      '1': 'period',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.Period',
      '10': 'period'
    },
    const {'1': 'is_favorite', '3': 11, '4': 1, '5': 8, '10': 'isFavorite'},
    const {
      '1': 'was_catch_and_release',
      '3': 12,
      '4': 1,
      '5': 8,
      '10': 'wasCatchAndRelease'
    },
    const {
      '1': 'season',
      '3': 13,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.Season',
      '10': 'season'
    },
    const {
      '1': 'water_clarity_id',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'waterClarityId'
    },
    const {
      '1': 'water_depth',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'waterDepth'
    },
    const {
      '1': 'water_temperature',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'waterTemperature'
    },
    const {
      '1': 'length',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'length'
    },
    const {
      '1': 'weight',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'weight'
    },
    const {'1': 'quantity', '3': 19, '4': 1, '5': 13, '10': 'quantity'},
    const {'1': 'notes', '3': 20, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `Catch`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catchDescriptor = $convert.base64Decode(
    'CgVDYXRjaBIeCgJpZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSAmlkEhwKCXRpbWVzdGFtcBgCIAEoBFIJdGltZXN0YW1wEicKB2JhaXRfaWQYAyABKAsyDi5hbmdsZXJzbG9nLklkUgZiYWl0SWQSNgoPZmlzaGluZ19zcG90X2lkGAQgASgLMg4uYW5nbGVyc2xvZy5JZFINZmlzaGluZ1Nwb3RJZBItCgpzcGVjaWVzX2lkGAUgASgLMg4uYW5nbGVyc2xvZy5JZFIJc3BlY2llc0lkEh8KC2ltYWdlX25hbWVzGAYgAygJUgppbWFnZU5hbWVzEk8KFGN1c3RvbV9lbnRpdHlfdmFsdWVzGAcgAygLMh0uYW5nbGVyc2xvZy5DdXN0b21FbnRpdHlWYWx1ZVISY3VzdG9tRW50aXR5VmFsdWVzEisKCWFuZ2xlcl9pZBgIIAEoCzIOLmFuZ2xlcnNsb2cuSWRSCGFuZ2xlcklkEi0KCm1ldGhvZF9pZHMYCSADKAsyDi5hbmdsZXJzbG9nLklkUgltZXRob2RJZHMSKgoGcGVyaW9kGAogASgOMhIuYW5nbGVyc2xvZy5QZXJpb2RSBnBlcmlvZBIfCgtpc19mYXZvcml0ZRgLIAEoCFIKaXNGYXZvcml0ZRIxChV3YXNfY2F0Y2hfYW5kX3JlbGVhc2UYDCABKAhSEndhc0NhdGNoQW5kUmVsZWFzZRIqCgZzZWFzb24YDSABKA4yEi5hbmdsZXJzbG9nLlNlYXNvblIGc2Vhc29uEjgKEHdhdGVyX2NsYXJpdHlfaWQYDiABKAsyDi5hbmdsZXJzbG9nLklkUg53YXRlckNsYXJpdHlJZBI9Cgt3YXRlcl9kZXB0aBgPIAEoCzIcLmFuZ2xlcnNsb2cuTXVsdGlNZWFzdXJlbWVudFIKd2F0ZXJEZXB0aBJJChF3YXRlcl90ZW1wZXJhdHVyZRgQIAEoCzIcLmFuZ2xlcnNsb2cuTXVsdGlNZWFzdXJlbWVudFIQd2F0ZXJUZW1wZXJhdHVyZRI0CgZsZW5ndGgYESABKAsyHC5hbmdsZXJzbG9nLk11bHRpTWVhc3VyZW1lbnRSBmxlbmd0aBI0CgZ3ZWlnaHQYEiABKAsyHC5hbmdsZXJzbG9nLk11bHRpTWVhc3VyZW1lbnRSBndlaWdodBIaCghxdWFudGl0eRgTIAEoDVIIcXVhbnRpdHkSFAoFbm90ZXMYFCABKAlSBW5vdGVz');
@$core.Deprecated('Use fishingSpotDescriptor instead')
const FishingSpot$json = const {
  '1': 'FishingSpot',
  '2': const [
    const {
      '1': 'id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'id'
    },
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'lat', '3': 3, '4': 1, '5': 1, '10': 'lat'},
    const {'1': 'lng', '3': 4, '4': 1, '5': 1, '10': 'lng'},
  ],
};

/// Descriptor for `FishingSpot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fishingSpotDescriptor = $convert.base64Decode(
    'CgtGaXNoaW5nU3BvdBIeCgJpZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSEAoDbGF0GAMgASgBUgNsYXQSEAoDbG5nGAQgASgBUgNsbmc=');
@$core.Deprecated('Use numberFilterDescriptor instead')
const NumberFilter$json = const {
  '1': 'NumberFilter',
  '2': const [
    const {
      '1': 'boundary',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.NumberBoundary',
      '10': 'boundary'
    },
    const {
      '1': 'from',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'from'
    },
    const {
      '1': 'to',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'to'
    },
  ],
};

/// Descriptor for `NumberFilter`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List numberFilterDescriptor = $convert.base64Decode(
    'CgxOdW1iZXJGaWx0ZXISNgoIYm91bmRhcnkYASABKA4yGi5hbmdsZXJzbG9nLk51bWJlckJvdW5kYXJ5Ughib3VuZGFyeRIwCgRmcm9tGAIgASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50UgRmcm9tEiwKAnRvGAMgASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50UgJ0bw==');
@$core.Deprecated('Use speciesDescriptor instead')
const Species$json = const {
  '1': 'Species',
  '2': const [
    const {
      '1': 'id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'id'
    },
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Species`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List speciesDescriptor = $convert.base64Decode(
    'CgdTcGVjaWVzEh4KAmlkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZQ==');
@$core.Deprecated('Use reportDescriptor instead')
const Report$json = const {
  '1': 'Report',
  '2': const [
    const {
      '1': 'id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'id'
    },
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    const {
      '1': 'type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.Report.Type',
      '10': 'type'
    },
    const {
      '1': 'from_display_date_range_id',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'fromDisplayDateRangeId'
    },
    const {
      '1': 'to_display_date_range_id',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'toDisplayDateRangeId'
    },
    const {
      '1': 'from_start_timestamp',
      '3': 7,
      '4': 1,
      '5': 4,
      '10': 'fromStartTimestamp'
    },
    const {
      '1': 'to_start_timestamp',
      '3': 8,
      '4': 1,
      '5': 4,
      '10': 'toStartTimestamp'
    },
    const {
      '1': 'from_end_timestamp',
      '3': 9,
      '4': 1,
      '5': 4,
      '10': 'fromEndTimestamp'
    },
    const {
      '1': 'to_end_timestamp',
      '3': 10,
      '4': 1,
      '5': 4,
      '10': 'toEndTimestamp'
    },
    const {
      '1': 'bait_ids',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'baitIds'
    },
    const {
      '1': 'fishing_spot_ids',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'fishingSpotIds'
    },
    const {
      '1': 'species_ids',
      '3': 13,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'speciesIds'
    },
    const {
      '1': 'angler_ids',
      '3': 14,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'anglerIds'
    },
    const {
      '1': 'method_ids',
      '3': 15,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'methodIds'
    },
    const {
      '1': 'periods',
      '3': 16,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.Period',
      '10': 'periods'
    },
    const {
      '1': 'is_favorites_only',
      '3': 17,
      '4': 1,
      '5': 8,
      '10': 'isFavoritesOnly'
    },
    const {
      '1': 'is_catch_and_release_only',
      '3': 18,
      '4': 1,
      '5': 8,
      '10': 'isCatchAndReleaseOnly'
    },
    const {
      '1': 'seasons',
      '3': 19,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.Season',
      '10': 'seasons'
    },
    const {
      '1': 'water_clarity_ids',
      '3': 20,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'waterClarityIds'
    },
    const {
      '1': 'water_depth_filter',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'waterDepthFilter'
    },
    const {
      '1': 'water_temperature_filter',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'waterTemperatureFilter'
    },
    const {
      '1': 'length_filter',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'lengthFilter'
    },
    const {
      '1': 'weight_filter',
      '3': 24,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'weightFilter'
    },
    const {
      '1': 'quantity_filter',
      '3': 25,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'quantityFilter'
    },
  ],
  '4': const [Report_Type$json],
};

@$core.Deprecated('Use reportDescriptor instead')
const Report_Type$json = const {
  '1': 'Type',
  '2': const [
    const {'1': 'summary', '2': 0},
    const {'1': 'comparison', '2': 1},
  ],
};

/// Descriptor for `Report`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reportDescriptor = $convert.base64Decode(
    'CgZSZXBvcnQSHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlvbhIrCgR0eXBlGAQgASgOMhcuYW5nbGVyc2xvZy5SZXBvcnQuVHlwZVIEdHlwZRI6Chpmcm9tX2Rpc3BsYXlfZGF0ZV9yYW5nZV9pZBgFIAEoCVIWZnJvbURpc3BsYXlEYXRlUmFuZ2VJZBI2Chh0b19kaXNwbGF5X2RhdGVfcmFuZ2VfaWQYBiABKAlSFHRvRGlzcGxheURhdGVSYW5nZUlkEjAKFGZyb21fc3RhcnRfdGltZXN0YW1wGAcgASgEUhJmcm9tU3RhcnRUaW1lc3RhbXASLAoSdG9fc3RhcnRfdGltZXN0YW1wGAggASgEUhB0b1N0YXJ0VGltZXN0YW1wEiwKEmZyb21fZW5kX3RpbWVzdGFtcBgJIAEoBFIQZnJvbUVuZFRpbWVzdGFtcBIoChB0b19lbmRfdGltZXN0YW1wGAogASgEUg50b0VuZFRpbWVzdGFtcBIpCghiYWl0X2lkcxgLIAMoCzIOLmFuZ2xlcnNsb2cuSWRSB2JhaXRJZHMSOAoQZmlzaGluZ19zcG90X2lkcxgMIAMoCzIOLmFuZ2xlcnNsb2cuSWRSDmZpc2hpbmdTcG90SWRzEi8KC3NwZWNpZXNfaWRzGA0gAygLMg4uYW5nbGVyc2xvZy5JZFIKc3BlY2llc0lkcxItCgphbmdsZXJfaWRzGA4gAygLMg4uYW5nbGVyc2xvZy5JZFIJYW5nbGVySWRzEi0KCm1ldGhvZF9pZHMYDyADKAsyDi5hbmdsZXJzbG9nLklkUgltZXRob2RJZHMSLAoHcGVyaW9kcxgQIAMoDjISLmFuZ2xlcnNsb2cuUGVyaW9kUgdwZXJpb2RzEioKEWlzX2Zhdm9yaXRlc19vbmx5GBEgASgIUg9pc0Zhdm9yaXRlc09ubHkSOAoZaXNfY2F0Y2hfYW5kX3JlbGVhc2Vfb25seRgSIAEoCFIVaXNDYXRjaEFuZFJlbGVhc2VPbmx5EiwKB3NlYXNvbnMYEyADKA4yEi5hbmdsZXJzbG9nLlNlYXNvblIHc2Vhc29ucxI6ChF3YXRlcl9jbGFyaXR5X2lkcxgUIAMoCzIOLmFuZ2xlcnNsb2cuSWRSD3dhdGVyQ2xhcml0eUlkcxJGChJ3YXRlcl9kZXB0aF9maWx0ZXIYFSABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIQd2F0ZXJEZXB0aEZpbHRlchJSChh3YXRlcl90ZW1wZXJhdHVyZV9maWx0ZXIYFiABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIWd2F0ZXJUZW1wZXJhdHVyZUZpbHRlchI9Cg1sZW5ndGhfZmlsdGVyGBcgASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSDGxlbmd0aEZpbHRlchI9Cg13ZWlnaHRfZmlsdGVyGBggASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSDHdlaWdodEZpbHRlchJBCg9xdWFudGl0eV9maWx0ZXIYGSABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIOcXVhbnRpdHlGaWx0ZXIiIwoEVHlwZRILCgdzdW1tYXJ5EAASDgoKY29tcGFyaXNvbhAB');
@$core.Deprecated('Use anglerDescriptor instead')
const Angler$json = const {
  '1': 'Angler',
  '2': const [
    const {
      '1': 'id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'id'
    },
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Angler`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List anglerDescriptor = $convert.base64Decode(
    'CgZBbmdsZXISHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGAIgASgJUgRuYW1l');
@$core.Deprecated('Use methodDescriptor instead')
const Method$json = const {
  '1': 'Method',
  '2': const [
    const {
      '1': 'id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'id'
    },
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Method`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List methodDescriptor = $convert.base64Decode(
    'CgZNZXRob2QSHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGAIgASgJUgRuYW1l');
@$core.Deprecated('Use waterClarityDescriptor instead')
const WaterClarity$json = const {
  '1': 'WaterClarity',
  '2': const [
    const {
      '1': 'id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'id'
    },
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `WaterClarity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List waterClarityDescriptor = $convert.base64Decode(
    'CgxXYXRlckNsYXJpdHkSHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGAIgASgJUgRuYW1l');
@$core.Deprecated('Use measurementDescriptor instead')
const Measurement$json = const {
  '1': 'Measurement',
  '2': const [
    const {
      '1': 'unit',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.Unit',
      '10': 'unit'
    },
    const {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
};

/// Descriptor for `Measurement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List measurementDescriptor = $convert.base64Decode(
    'CgtNZWFzdXJlbWVudBIkCgR1bml0GAEgASgOMhAuYW5nbGVyc2xvZy5Vbml0UgR1bml0EhQKBXZhbHVlGAIgASgBUgV2YWx1ZQ==');
@$core.Deprecated('Use multiMeasurementDescriptor instead')
const MultiMeasurement$json = const {
  '1': 'MultiMeasurement',
  '2': const [
    const {
      '1': 'system',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.MeasurementSystem',
      '10': 'system'
    },
    const {
      '1': 'mainValue',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Measurement',
      '10': 'mainValue'
    },
    const {
      '1': 'fractionValue',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Measurement',
      '10': 'fractionValue'
    },
  ],
};

/// Descriptor for `MultiMeasurement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List multiMeasurementDescriptor = $convert.base64Decode(
    'ChBNdWx0aU1lYXN1cmVtZW50EjUKBnN5c3RlbRgBIAEoDjIdLmFuZ2xlcnNsb2cuTWVhc3VyZW1lbnRTeXN0ZW1SBnN5c3RlbRI1CgltYWluVmFsdWUYAiABKAsyFy5hbmdsZXJzbG9nLk1lYXN1cmVtZW50UgltYWluVmFsdWUSPQoNZnJhY3Rpb25WYWx1ZRgDIAEoCzIXLmFuZ2xlcnNsb2cuTWVhc3VyZW1lbnRSDWZyYWN0aW9uVmFsdWU=');
// ignore_for_file: constant_identifier_names,lines_longer_than_80_chars,directives_ordering,prefer_mixin,implementation_imports
