///
//  Generated code. Do not modify.
//  source: anglerslog.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;

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
    const {'1': 'BOOL', '2': 0},
    const {'1': 'NUMBER', '2': 1},
    const {'1': 'TEXT', '2': 2},
  ],
};

/// Descriptor for `CustomEntity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customEntityDescriptor = $convert.base64Decode(
    'CgxDdXN0b21FbnRpdHkSHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlvbhIxCgR0eXBlGAQgASgOMh0uYW5nbGVyc2xvZy5DdXN0b21FbnRpdHkuVHlwZVIEdHlwZSImCgRUeXBlEggKBEJPT0wQABIKCgZOVU1CRVIQARIICgRURVhUEAI=');
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
  ],
};

/// Descriptor for `Catch`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catchDescriptor = $convert.base64Decode(
    'CgVDYXRjaBIeCgJpZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSAmlkEhwKCXRpbWVzdGFtcBgCIAEoBFIJdGltZXN0YW1wEicKB2JhaXRfaWQYAyABKAsyDi5hbmdsZXJzbG9nLklkUgZiYWl0SWQSNgoPZmlzaGluZ19zcG90X2lkGAQgASgLMg4uYW5nbGVyc2xvZy5JZFINZmlzaGluZ1Nwb3RJZBItCgpzcGVjaWVzX2lkGAUgASgLMg4uYW5nbGVyc2xvZy5JZFIJc3BlY2llc0lkEh8KC2ltYWdlX25hbWVzGAYgAygJUgppbWFnZU5hbWVzEk8KFGN1c3RvbV9lbnRpdHlfdmFsdWVzGAcgAygLMh0uYW5nbGVyc2xvZy5DdXN0b21FbnRpdHlWYWx1ZVISY3VzdG9tRW50aXR5VmFsdWVz');
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
@$core.Deprecated('Use summaryReportDescriptor instead')
const SummaryReport$json = const {
  '1': 'SummaryReport',
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
      '1': 'display_date_range_id',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'displayDateRangeId'
    },
    const {
      '1': 'start_timestamp',
      '3': 5,
      '4': 1,
      '5': 4,
      '10': 'startTimestamp'
    },
    const {'1': 'end_timestamp', '3': 6, '4': 1, '5': 4, '10': 'endTimestamp'},
    const {
      '1': 'bait_ids',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'baitIds'
    },
    const {
      '1': 'fishing_spot_ids',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'fishingSpotIds'
    },
    const {
      '1': 'species_ids',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'speciesIds'
    },
  ],
};

/// Descriptor for `SummaryReport`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List summaryReportDescriptor = $convert.base64Decode(
    'Cg1TdW1tYXJ5UmVwb3J0Eh4KAmlkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIgCgtkZXNjcmlwdGlvbhgDIAEoCVILZGVzY3JpcHRpb24SMQoVZGlzcGxheV9kYXRlX3JhbmdlX2lkGAQgASgJUhJkaXNwbGF5RGF0ZVJhbmdlSWQSJwoPc3RhcnRfdGltZXN0YW1wGAUgASgEUg5zdGFydFRpbWVzdGFtcBIjCg1lbmRfdGltZXN0YW1wGAYgASgEUgxlbmRUaW1lc3RhbXASKQoIYmFpdF9pZHMYByADKAsyDi5hbmdsZXJzbG9nLklkUgdiYWl0SWRzEjgKEGZpc2hpbmdfc3BvdF9pZHMYCCADKAsyDi5hbmdsZXJzbG9nLklkUg5maXNoaW5nU3BvdElkcxIvCgtzcGVjaWVzX2lkcxgJIAMoCzIOLmFuZ2xlcnNsb2cuSWRSCnNwZWNpZXNJZHM=');
@$core.Deprecated('Use comparisonReportDescriptor instead')
const ComparisonReport$json = const {
  '1': 'ComparisonReport',
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
      '1': 'from_display_date_range_id',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'fromDisplayDateRangeId'
    },
    const {
      '1': 'to_display_date_range_id',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'toDisplayDateRangeId'
    },
    const {
      '1': 'from_start_timestamp',
      '3': 6,
      '4': 1,
      '5': 4,
      '10': 'fromStartTimestamp'
    },
    const {
      '1': 'to_start_timestamp',
      '3': 7,
      '4': 1,
      '5': 4,
      '10': 'toStartTimestamp'
    },
    const {
      '1': 'from_end_timestamp',
      '3': 8,
      '4': 1,
      '5': 4,
      '10': 'fromEndTimestamp'
    },
    const {
      '1': 'to_end_timestamp',
      '3': 9,
      '4': 1,
      '5': 4,
      '10': 'toEndTimestamp'
    },
    const {
      '1': 'bait_ids',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'baitIds'
    },
    const {
      '1': 'fishing_spot_ids',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'fishingSpotIds'
    },
    const {
      '1': 'species_ids',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'speciesIds'
    },
  ],
};

/// Descriptor for `ComparisonReport`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List comparisonReportDescriptor = $convert.base64Decode(
    'ChBDb21wYXJpc29uUmVwb3J0Eh4KAmlkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIgCgtkZXNjcmlwdGlvbhgDIAEoCVILZGVzY3JpcHRpb24SOgoaZnJvbV9kaXNwbGF5X2RhdGVfcmFuZ2VfaWQYBCABKAlSFmZyb21EaXNwbGF5RGF0ZVJhbmdlSWQSNgoYdG9fZGlzcGxheV9kYXRlX3JhbmdlX2lkGAUgASgJUhR0b0Rpc3BsYXlEYXRlUmFuZ2VJZBIwChRmcm9tX3N0YXJ0X3RpbWVzdGFtcBgGIAEoBFISZnJvbVN0YXJ0VGltZXN0YW1wEiwKEnRvX3N0YXJ0X3RpbWVzdGFtcBgHIAEoBFIQdG9TdGFydFRpbWVzdGFtcBIsChJmcm9tX2VuZF90aW1lc3RhbXAYCCABKARSEGZyb21FbmRUaW1lc3RhbXASKAoQdG9fZW5kX3RpbWVzdGFtcBgJIAEoBFIOdG9FbmRUaW1lc3RhbXASKQoIYmFpdF9pZHMYCiADKAsyDi5hbmdsZXJzbG9nLklkUgdiYWl0SWRzEjgKEGZpc2hpbmdfc3BvdF9pZHMYCyADKAsyDi5hbmdsZXJzbG9nLklkUg5maXNoaW5nU3BvdElkcxIvCgtzcGVjaWVzX2lkcxgMIAMoCzIOLmFuZ2xlcnNsb2cuSWRSCnNwZWNpZXNJZHM=');
// ignore_for_file: constant_identifier_names,lines_longer_than_80_chars,directives_ordering,prefer_mixin,implementation_imports
