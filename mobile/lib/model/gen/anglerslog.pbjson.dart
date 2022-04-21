///
//  Generated code. Do not modify.
//  source: anglerslog.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use directionDescriptor instead')
const Direction$json = const {
  '1': 'Direction',
  '2': const [
    const {'1': 'direction_all', '2': 0},
    const {'1': 'direction_none', '2': 1},
    const {'1': 'north', '2': 2},
    const {'1': 'north_east', '2': 3},
    const {'1': 'east', '2': 4},
    const {'1': 'south_east', '2': 5},
    const {'1': 'south', '2': 6},
    const {'1': 'south_west', '2': 7},
    const {'1': 'west', '2': 8},
    const {'1': 'north_west', '2': 9},
  ],
};

/// Descriptor for `Direction`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List directionDescriptor = $convert.base64Decode('CglEaXJlY3Rpb24SEQoNZGlyZWN0aW9uX2FsbBAAEhIKDmRpcmVjdGlvbl9ub25lEAESCQoFbm9ydGgQAhIOCgpub3J0aF9lYXN0EAMSCAoEZWFzdBAEEg4KCnNvdXRoX2Vhc3QQBRIJCgVzb3V0aBAGEg4KCnNvdXRoX3dlc3QQBxIICgR3ZXN0EAgSDgoKbm9ydGhfd2VzdBAJ');
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
final $typed_data.Uint8List measurementSystemDescriptor = $convert.base64Decode('ChFNZWFzdXJlbWVudFN5c3RlbRISCg5pbXBlcmlhbF93aG9sZRAAEhQKEGltcGVyaWFsX2RlY2ltYWwQARIKCgZtZXRyaWMQAg==');
@$core.Deprecated('Use moonPhaseDescriptor instead')
const MoonPhase$json = const {
  '1': 'MoonPhase',
  '2': const [
    const {'1': 'moon_phase_all', '2': 0},
    const {'1': 'moon_phase_none', '2': 1},
    const {'1': 'new', '2': 2},
    const {'1': 'waxing_crescent', '2': 3},
    const {'1': 'first_quarter', '2': 4},
    const {'1': 'waxing_gibbous', '2': 5},
    const {'1': 'full', '2': 6},
    const {'1': 'waning_gibbous', '2': 7},
    const {'1': 'last_quarter', '2': 8},
    const {'1': 'waning_crescent', '2': 9},
  ],
};

/// Descriptor for `MoonPhase`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List moonPhaseDescriptor = $convert.base64Decode('CglNb29uUGhhc2USEgoObW9vbl9waGFzZV9hbGwQABITCg9tb29uX3BoYXNlX25vbmUQARIHCgNuZXcQAhITCg93YXhpbmdfY3Jlc2NlbnQQAxIRCg1maXJzdF9xdWFydGVyEAQSEgoOd2F4aW5nX2dpYmJvdXMQBRIICgRmdWxsEAYSEgoOd2FuaW5nX2dpYmJvdXMQBxIQCgxsYXN0X3F1YXJ0ZXIQCBITCg93YW5pbmdfY3Jlc2NlbnQQCQ==');
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
final $typed_data.Uint8List numberBoundaryDescriptor = $convert.base64Decode('Cg5OdW1iZXJCb3VuZGFyeRIXChNudW1iZXJfYm91bmRhcnlfYW55EAASDQoJbGVzc190aGFuEAESGQoVbGVzc190aGFuX29yX2VxdWFsX3RvEAISDAoIZXF1YWxfdG8QAxIQCgxncmVhdGVyX3RoYW4QBBIcChhncmVhdGVyX3RoYW5fb3JfZXF1YWxfdG8QBRIJCgVyYW5nZRAG');
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
final $typed_data.Uint8List periodDescriptor = $convert.base64Decode('CgZQZXJpb2QSDgoKcGVyaW9kX2FsbBAAEg8KC3BlcmlvZF9ub25lEAESCAoEZGF3bhACEgsKB21vcm5pbmcQAxIKCgZtaWRkYXkQBBINCglhZnRlcm5vb24QBRIICgRkdXNrEAYSCQoFbmlnaHQQBw==');
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
final $typed_data.Uint8List seasonDescriptor = $convert.base64Decode('CgZTZWFzb24SDgoKc2Vhc29uX2FsbBAAEg8KC3NlYXNvbl9ub25lEAESCgoGd2ludGVyEAISCgoGc3ByaW5nEAMSCgoGc3VtbWVyEAQSCgoGYXV0dW1uEAU=');
@$core.Deprecated('Use skyConditionDescriptor instead')
const SkyCondition$json = const {
  '1': 'SkyCondition',
  '2': const [
    const {'1': 'sky_condition_all', '2': 0},
    const {'1': 'sky_condition_none', '2': 1},
    const {'1': 'snow', '2': 2},
    const {'1': 'drizzle', '2': 3},
    const {'1': 'dust', '2': 4},
    const {'1': 'fog', '2': 5},
    const {'1': 'rain', '2': 6},
    const {'1': 'tornado', '2': 7},
    const {'1': 'hail', '2': 8},
    const {'1': 'ice', '2': 9},
    const {'1': 'storm', '2': 10},
    const {'1': 'mist', '2': 11},
    const {'1': 'smoke', '2': 12},
    const {'1': 'overcast', '2': 13},
    const {'1': 'cloudy', '2': 14},
    const {'1': 'clear', '2': 15},
  ],
};

/// Descriptor for `SkyCondition`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List skyConditionDescriptor = $convert.base64Decode('CgxTa3lDb25kaXRpb24SFQoRc2t5X2NvbmRpdGlvbl9hbGwQABIWChJza3lfY29uZGl0aW9uX25vbmUQARIICgRzbm93EAISCwoHZHJpenpsZRADEggKBGR1c3QQBBIHCgNmb2cQBRIICgRyYWluEAYSCwoHdG9ybmFkbxAHEggKBGhhaWwQCBIHCgNpY2UQCRIJCgVzdG9ybRAKEggKBG1pc3QQCxIJCgVzbW9rZRAMEgwKCG92ZXJjYXN0EA0SCgoGY2xvdWR5EA4SCQoFY2xlYXIQDw==');
@$core.Deprecated('Use tideTypeDescriptor instead')
const TideType$json = const {
  '1': 'TideType',
  '2': const [
    const {'1': 'tide_type_all', '2': 0},
    const {'1': 'tide_type_none', '2': 1},
    const {'1': 'low', '2': 2},
    const {'1': 'outgoing', '2': 3},
    const {'1': 'high', '2': 4},
    const {'1': 'slack', '2': 5},
    const {'1': 'incoming', '2': 6},
  ],
};

/// Descriptor for `TideType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List tideTypeDescriptor = $convert.base64Decode('CghUaWRlVHlwZRIRCg10aWRlX3R5cGVfYWxsEAASEgoOdGlkZV90eXBlX25vbmUQARIHCgNsb3cQAhIMCghvdXRnb2luZxADEggKBGhpZ2gQBBIJCgVzbGFjaxAFEgwKCGluY29taW5nEAY=');
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
    const {'1': 'miles_per_hour', '2': 9},
    const {'1': 'kilometers_per_hour', '2': 10},
    const {'1': 'millibars', '2': 11},
    const {'1': 'pounds_per_square_inch', '2': 12},
    const {'1': 'miles', '2': 13},
    const {'1': 'kilometers', '2': 14},
    const {'1': 'percent', '2': 15},
  ],
};

/// Descriptor for `Unit`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List unitDescriptor = $convert.base64Decode('CgRVbml0EggKBGZlZXQQABIKCgZpbmNoZXMQARIKCgZwb3VuZHMQAhIKCgZvdW5jZXMQAxIOCgpmYWhyZW5oZWl0EAQSCgoGbWV0ZXJzEAUSDwoLY2VudGltZXRlcnMQBhINCglraWxvZ3JhbXMQBxILCgdjZWxzaXVzEAgSEgoObWlsZXNfcGVyX2hvdXIQCRIXChNraWxvbWV0ZXJzX3Blcl9ob3VyEAoSDQoJbWlsbGliYXJzEAsSGgoWcG91bmRzX3Blcl9zcXVhcmVfaW5jaBAMEgkKBW1pbGVzEA0SDgoKa2lsb21ldGVycxAOEgsKB3BlcmNlbnQQDw==');
@$core.Deprecated('Use idDescriptor instead')
const Id$json = const {
  '1': 'Id',
  '2': const [
    const {'1': 'uuid', '3': 1, '4': 1, '5': 9, '10': 'uuid'},
  ],
};

/// Descriptor for `Id`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List idDescriptor = $convert.base64Decode('CgJJZBISCgR1dWlkGAEgASgJUgR1dWlk');
@$core.Deprecated('Use atmosphereDescriptor instead')
const Atmosphere$json = const {
  '1': 'Atmosphere',
  '2': const [
    const {'1': 'temperature', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Measurement', '10': 'temperature'},
    const {'1': 'sky_conditions', '3': 2, '4': 3, '5': 14, '6': '.anglerslog.SkyCondition', '10': 'skyConditions'},
    const {'1': 'wind_speed', '3': 3, '4': 1, '5': 11, '6': '.anglerslog.Measurement', '10': 'windSpeed'},
    const {'1': 'wind_direction', '3': 4, '4': 1, '5': 14, '6': '.anglerslog.Direction', '10': 'windDirection'},
    const {'1': 'pressure', '3': 5, '4': 1, '5': 11, '6': '.anglerslog.Measurement', '10': 'pressure'},
    const {'1': 'humidity', '3': 6, '4': 1, '5': 11, '6': '.anglerslog.Measurement', '10': 'humidity'},
    const {'1': 'visibility', '3': 7, '4': 1, '5': 11, '6': '.anglerslog.Measurement', '10': 'visibility'},
    const {'1': 'moon_phase', '3': 8, '4': 1, '5': 14, '6': '.anglerslog.MoonPhase', '10': 'moonPhase'},
    const {'1': 'sunrise_timestamp', '3': 9, '4': 1, '5': 4, '10': 'sunriseTimestamp'},
    const {'1': 'sunset_timestamp', '3': 10, '4': 1, '5': 4, '10': 'sunsetTimestamp'},
    const {'1': 'time_zone', '3': 11, '4': 1, '5': 9, '10': 'timeZone'},
  ],
};

/// Descriptor for `Atmosphere`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List atmosphereDescriptor = $convert.base64Decode('CgpBdG1vc3BoZXJlEjkKC3RlbXBlcmF0dXJlGAEgASgLMhcuYW5nbGVyc2xvZy5NZWFzdXJlbWVudFILdGVtcGVyYXR1cmUSPwoOc2t5X2NvbmRpdGlvbnMYAiADKA4yGC5hbmdsZXJzbG9nLlNreUNvbmRpdGlvblINc2t5Q29uZGl0aW9ucxI2Cgp3aW5kX3NwZWVkGAMgASgLMhcuYW5nbGVyc2xvZy5NZWFzdXJlbWVudFIJd2luZFNwZWVkEjwKDndpbmRfZGlyZWN0aW9uGAQgASgOMhUuYW5nbGVyc2xvZy5EaXJlY3Rpb25SDXdpbmREaXJlY3Rpb24SMwoIcHJlc3N1cmUYBSABKAsyFy5hbmdsZXJzbG9nLk1lYXN1cmVtZW50UghwcmVzc3VyZRIzCghodW1pZGl0eRgGIAEoCzIXLmFuZ2xlcnNsb2cuTWVhc3VyZW1lbnRSCGh1bWlkaXR5EjcKCnZpc2liaWxpdHkYByABKAsyFy5hbmdsZXJzbG9nLk1lYXN1cmVtZW50Ugp2aXNpYmlsaXR5EjQKCm1vb25fcGhhc2UYCCABKA4yFS5hbmdsZXJzbG9nLk1vb25QaGFzZVIJbW9vblBoYXNlEisKEXN1bnJpc2VfdGltZXN0YW1wGAkgASgEUhBzdW5yaXNlVGltZXN0YW1wEikKEHN1bnNldF90aW1lc3RhbXAYCiABKARSD3N1bnNldFRpbWVzdGFtcBIbCgl0aW1lX3pvbmUYCyABKAlSCHRpbWVab25l');
@$core.Deprecated('Use customEntityDescriptor instead')
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
final $typed_data.Uint8List customEntityDescriptor = $convert.base64Decode('CgxDdXN0b21FbnRpdHkSHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlvbhIxCgR0eXBlGAQgASgOMh0uYW5nbGVyc2xvZy5DdXN0b21FbnRpdHkuVHlwZVIEdHlwZSIpCgRUeXBlEgsKB2Jvb2xlYW4QABIKCgZudW1iZXIQARIICgR0ZXh0EAI=');
@$core.Deprecated('Use customEntityValueDescriptor instead')
const CustomEntityValue$json = const {
  '1': 'CustomEntityValue',
  '2': const [
    const {'1': 'custom_entity_id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'customEntityId'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `CustomEntityValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customEntityValueDescriptor = $convert.base64Decode('ChFDdXN0b21FbnRpdHlWYWx1ZRI4ChBjdXN0b21fZW50aXR5X2lkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFIOY3VzdG9tRW50aXR5SWQSFAoFdmFsdWUYAiABKAlSBXZhbHVl');
@$core.Deprecated('Use baitDescriptor instead')
const Bait$json = const {
  '1': 'Bait',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'bait_category_id', '3': 3, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'baitCategoryId'},
    const {'1': 'image_name', '3': 4, '4': 1, '5': 9, '10': 'imageName'},
    const {'1': 'type', '3': 5, '4': 1, '5': 14, '6': '.anglerslog.Bait.Type', '10': 'type'},
    const {'1': 'variants', '3': 6, '4': 3, '5': 11, '6': '.anglerslog.BaitVariant', '10': 'variants'},
  ],
  '4': const [Bait_Type$json],
};

@$core.Deprecated('Use baitDescriptor instead')
const Bait_Type$json = const {
  '1': 'Type',
  '2': const [
    const {'1': 'artificial', '2': 0},
    const {'1': 'real', '2': 1},
    const {'1': 'live', '2': 2},
  ],
};

/// Descriptor for `Bait`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List baitDescriptor = $convert.base64Decode('CgRCYWl0Eh4KAmlkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRI4ChBiYWl0X2NhdGVnb3J5X2lkGAMgASgLMg4uYW5nbGVyc2xvZy5JZFIOYmFpdENhdGVnb3J5SWQSHQoKaW1hZ2VfbmFtZRgEIAEoCVIJaW1hZ2VOYW1lEikKBHR5cGUYBSABKA4yFS5hbmdsZXJzbG9nLkJhaXQuVHlwZVIEdHlwZRIzCgh2YXJpYW50cxgGIAMoCzIXLmFuZ2xlcnNsb2cuQmFpdFZhcmlhbnRSCHZhcmlhbnRzIioKBFR5cGUSDgoKYXJ0aWZpY2lhbBAAEggKBHJlYWwQARIICgRsaXZlEAI=');
@$core.Deprecated('Use baitVariantDescriptor instead')
const BaitVariant$json = const {
  '1': 'BaitVariant',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'base_id', '3': 2, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'baseId'},
    const {'1': 'color', '3': 3, '4': 1, '5': 9, '10': 'color'},
    const {'1': 'model_number', '3': 4, '4': 1, '5': 9, '10': 'modelNumber'},
    const {'1': 'size', '3': 5, '4': 1, '5': 9, '10': 'size'},
    const {'1': 'min_dive_depth', '3': 6, '4': 1, '5': 11, '6': '.anglerslog.MultiMeasurement', '10': 'minDiveDepth'},
    const {'1': 'max_dive_depth', '3': 7, '4': 1, '5': 11, '6': '.anglerslog.MultiMeasurement', '10': 'maxDiveDepth'},
    const {'1': 'description', '3': 8, '4': 1, '5': 9, '10': 'description'},
    const {'1': 'custom_entity_values', '3': 9, '4': 3, '5': 11, '6': '.anglerslog.CustomEntityValue', '10': 'customEntityValues'},
  ],
};

/// Descriptor for `BaitVariant`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List baitVariantDescriptor = $convert.base64Decode('CgtCYWl0VmFyaWFudBIeCgJpZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSAmlkEicKB2Jhc2VfaWQYAiABKAsyDi5hbmdsZXJzbG9nLklkUgZiYXNlSWQSFAoFY29sb3IYAyABKAlSBWNvbG9yEiEKDG1vZGVsX251bWJlchgEIAEoCVILbW9kZWxOdW1iZXISEgoEc2l6ZRgFIAEoCVIEc2l6ZRJCCg5taW5fZGl2ZV9kZXB0aBgGIAEoCzIcLmFuZ2xlcnNsb2cuTXVsdGlNZWFzdXJlbWVudFIMbWluRGl2ZURlcHRoEkIKDm1heF9kaXZlX2RlcHRoGAcgASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50UgxtYXhEaXZlRGVwdGgSIAoLZGVzY3JpcHRpb24YCCABKAlSC2Rlc2NyaXB0aW9uEk8KFGN1c3RvbV9lbnRpdHlfdmFsdWVzGAkgAygLMh0uYW5nbGVyc2xvZy5DdXN0b21FbnRpdHlWYWx1ZVISY3VzdG9tRW50aXR5VmFsdWVz');
@$core.Deprecated('Use baitAttachmentDescriptor instead')
const BaitAttachment$json = const {
  '1': 'BaitAttachment',
  '2': const [
    const {'1': 'bait_id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'baitId'},
    const {'1': 'variant_id', '3': 2, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'variantId'},
  ],
};

/// Descriptor for `BaitAttachment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List baitAttachmentDescriptor = $convert.base64Decode('Cg5CYWl0QXR0YWNobWVudBInCgdiYWl0X2lkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFIGYmFpdElkEi0KCnZhcmlhbnRfaWQYAiABKAsyDi5hbmdsZXJzbG9nLklkUgl2YXJpYW50SWQ=');
@$core.Deprecated('Use baitCategoryDescriptor instead')
const BaitCategory$json = const {
  '1': 'BaitCategory',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `BaitCategory`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List baitCategoryDescriptor = $convert.base64Decode('CgxCYWl0Q2F0ZWdvcnkSHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGAIgASgJUgRuYW1l');
@$core.Deprecated('Use catchDescriptor instead')
const Catch$json = const {
  '1': 'Catch',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'timestamp', '3': 2, '4': 1, '5': 4, '10': 'timestamp'},
    const {'1': 'baits', '3': 3, '4': 3, '5': 11, '6': '.anglerslog.BaitAttachment', '10': 'baits'},
    const {'1': 'fishing_spot_id', '3': 4, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'fishingSpotId'},
    const {'1': 'species_id', '3': 5, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'speciesId'},
    const {'1': 'image_names', '3': 6, '4': 3, '5': 9, '10': 'imageNames'},
    const {'1': 'custom_entity_values', '3': 7, '4': 3, '5': 11, '6': '.anglerslog.CustomEntityValue', '10': 'customEntityValues'},
    const {'1': 'angler_id', '3': 8, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'anglerId'},
    const {'1': 'method_ids', '3': 9, '4': 3, '5': 11, '6': '.anglerslog.Id', '10': 'methodIds'},
    const {'1': 'period', '3': 10, '4': 1, '5': 14, '6': '.anglerslog.Period', '10': 'period'},
    const {'1': 'is_favorite', '3': 11, '4': 1, '5': 8, '10': 'isFavorite'},
    const {'1': 'was_catch_and_release', '3': 12, '4': 1, '5': 8, '10': 'wasCatchAndRelease'},
    const {'1': 'season', '3': 13, '4': 1, '5': 14, '6': '.anglerslog.Season', '10': 'season'},
    const {'1': 'water_clarity_id', '3': 14, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'waterClarityId'},
    const {'1': 'water_depth', '3': 15, '4': 1, '5': 11, '6': '.anglerslog.MultiMeasurement', '10': 'waterDepth'},
    const {'1': 'water_temperature', '3': 16, '4': 1, '5': 11, '6': '.anglerslog.MultiMeasurement', '10': 'waterTemperature'},
    const {'1': 'length', '3': 17, '4': 1, '5': 11, '6': '.anglerslog.MultiMeasurement', '10': 'length'},
    const {'1': 'weight', '3': 18, '4': 1, '5': 11, '6': '.anglerslog.MultiMeasurement', '10': 'weight'},
    const {'1': 'quantity', '3': 19, '4': 1, '5': 13, '10': 'quantity'},
    const {'1': 'notes', '3': 20, '4': 1, '5': 9, '10': 'notes'},
    const {'1': 'atmosphere', '3': 21, '4': 1, '5': 11, '6': '.anglerslog.Atmosphere', '10': 'atmosphere'},
    const {'1': 'tide', '3': 22, '4': 1, '5': 11, '6': '.anglerslog.Tide', '10': 'tide'},
    const {'1': 'time_zone', '3': 23, '4': 1, '5': 9, '10': 'timeZone'},
  ],
};

/// Descriptor for `Catch`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catchDescriptor = $convert.base64Decode('CgVDYXRjaBIeCgJpZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSAmlkEhwKCXRpbWVzdGFtcBgCIAEoBFIJdGltZXN0YW1wEjAKBWJhaXRzGAMgAygLMhouYW5nbGVyc2xvZy5CYWl0QXR0YWNobWVudFIFYmFpdHMSNgoPZmlzaGluZ19zcG90X2lkGAQgASgLMg4uYW5nbGVyc2xvZy5JZFINZmlzaGluZ1Nwb3RJZBItCgpzcGVjaWVzX2lkGAUgASgLMg4uYW5nbGVyc2xvZy5JZFIJc3BlY2llc0lkEh8KC2ltYWdlX25hbWVzGAYgAygJUgppbWFnZU5hbWVzEk8KFGN1c3RvbV9lbnRpdHlfdmFsdWVzGAcgAygLMh0uYW5nbGVyc2xvZy5DdXN0b21FbnRpdHlWYWx1ZVISY3VzdG9tRW50aXR5VmFsdWVzEisKCWFuZ2xlcl9pZBgIIAEoCzIOLmFuZ2xlcnNsb2cuSWRSCGFuZ2xlcklkEi0KCm1ldGhvZF9pZHMYCSADKAsyDi5hbmdsZXJzbG9nLklkUgltZXRob2RJZHMSKgoGcGVyaW9kGAogASgOMhIuYW5nbGVyc2xvZy5QZXJpb2RSBnBlcmlvZBIfCgtpc19mYXZvcml0ZRgLIAEoCFIKaXNGYXZvcml0ZRIxChV3YXNfY2F0Y2hfYW5kX3JlbGVhc2UYDCABKAhSEndhc0NhdGNoQW5kUmVsZWFzZRIqCgZzZWFzb24YDSABKA4yEi5hbmdsZXJzbG9nLlNlYXNvblIGc2Vhc29uEjgKEHdhdGVyX2NsYXJpdHlfaWQYDiABKAsyDi5hbmdsZXJzbG9nLklkUg53YXRlckNsYXJpdHlJZBI9Cgt3YXRlcl9kZXB0aBgPIAEoCzIcLmFuZ2xlcnNsb2cuTXVsdGlNZWFzdXJlbWVudFIKd2F0ZXJEZXB0aBJJChF3YXRlcl90ZW1wZXJhdHVyZRgQIAEoCzIcLmFuZ2xlcnNsb2cuTXVsdGlNZWFzdXJlbWVudFIQd2F0ZXJUZW1wZXJhdHVyZRI0CgZsZW5ndGgYESABKAsyHC5hbmdsZXJzbG9nLk11bHRpTWVhc3VyZW1lbnRSBmxlbmd0aBI0CgZ3ZWlnaHQYEiABKAsyHC5hbmdsZXJzbG9nLk11bHRpTWVhc3VyZW1lbnRSBndlaWdodBIaCghxdWFudGl0eRgTIAEoDVIIcXVhbnRpdHkSFAoFbm90ZXMYFCABKAlSBW5vdGVzEjYKCmF0bW9zcGhlcmUYFSABKAsyFi5hbmdsZXJzbG9nLkF0bW9zcGhlcmVSCmF0bW9zcGhlcmUSJAoEdGlkZRgWIAEoCzIQLmFuZ2xlcnNsb2cuVGlkZVIEdGlkZRIbCgl0aW1lX3pvbmUYFyABKAlSCHRpbWVab25l');
@$core.Deprecated('Use dateRangeDescriptor instead')
const DateRange$json = const {
  '1': 'DateRange',
  '2': const [
    const {'1': 'period', '3': 1, '4': 1, '5': 14, '6': '.anglerslog.DateRange.Period', '10': 'period'},
    const {'1': 'start_timestamp', '3': 2, '4': 1, '5': 4, '10': 'startTimestamp'},
    const {'1': 'end_timestamp', '3': 3, '4': 1, '5': 4, '10': 'endTimestamp'},
    const {'1': 'time_zone', '3': 23, '4': 1, '5': 9, '10': 'timeZone'},
  ],
  '4': const [DateRange_Period$json],
};

@$core.Deprecated('Use dateRangeDescriptor instead')
const DateRange_Period$json = const {
  '1': 'Period',
  '2': const [
    const {'1': 'allDates', '2': 0},
    const {'1': 'today', '2': 1},
    const {'1': 'yesterday', '2': 2},
    const {'1': 'thisWeek', '2': 3},
    const {'1': 'thisMonth', '2': 4},
    const {'1': 'thisYear', '2': 5},
    const {'1': 'lastWeek', '2': 6},
    const {'1': 'lastMonth', '2': 7},
    const {'1': 'lastYear', '2': 8},
    const {'1': 'last7Days', '2': 9},
    const {'1': 'last14Days', '2': 10},
    const {'1': 'last30Days', '2': 11},
    const {'1': 'last60Days', '2': 12},
    const {'1': 'last12Months', '2': 13},
    const {'1': 'custom', '2': 14},
  ],
};

/// Descriptor for `DateRange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dateRangeDescriptor = $convert.base64Decode('CglEYXRlUmFuZ2USNAoGcGVyaW9kGAEgASgOMhwuYW5nbGVyc2xvZy5EYXRlUmFuZ2UuUGVyaW9kUgZwZXJpb2QSJwoPc3RhcnRfdGltZXN0YW1wGAIgASgEUg5zdGFydFRpbWVzdGFtcBIjCg1lbmRfdGltZXN0YW1wGAMgASgEUgxlbmRUaW1lc3RhbXASGwoJdGltZV96b25lGBcgASgJUgh0aW1lWm9uZSLjAQoGUGVyaW9kEgwKCGFsbERhdGVzEAASCQoFdG9kYXkQARINCgl5ZXN0ZXJkYXkQAhIMCgh0aGlzV2VlaxADEg0KCXRoaXNNb250aBAEEgwKCHRoaXNZZWFyEAUSDAoIbGFzdFdlZWsQBhINCglsYXN0TW9udGgQBxIMCghsYXN0WWVhchAIEg0KCWxhc3Q3RGF5cxAJEg4KCmxhc3QxNERheXMQChIOCgpsYXN0MzBEYXlzEAsSDgoKbGFzdDYwRGF5cxAMEhAKDGxhc3QxMk1vbnRocxANEgoKBmN1c3RvbRAO');
@$core.Deprecated('Use bodyOfWaterDescriptor instead')
const BodyOfWater$json = const {
  '1': 'BodyOfWater',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `BodyOfWater`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bodyOfWaterDescriptor = $convert.base64Decode('CgtCb2R5T2ZXYXRlchIeCgJpZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWU=');
@$core.Deprecated('Use fishingSpotDescriptor instead')
const FishingSpot$json = const {
  '1': 'FishingSpot',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'lat', '3': 3, '4': 1, '5': 1, '10': 'lat'},
    const {'1': 'lng', '3': 4, '4': 1, '5': 1, '10': 'lng'},
    const {'1': 'body_of_water_id', '3': 5, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'bodyOfWaterId'},
    const {'1': 'image_name', '3': 6, '4': 1, '5': 9, '10': 'imageName'},
    const {'1': 'notes', '3': 7, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `FishingSpot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fishingSpotDescriptor = $convert.base64Decode('CgtGaXNoaW5nU3BvdBIeCgJpZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSEAoDbGF0GAMgASgBUgNsYXQSEAoDbG5nGAQgASgBUgNsbmcSNwoQYm9keV9vZl93YXRlcl9pZBgFIAEoCzIOLmFuZ2xlcnNsb2cuSWRSDWJvZHlPZldhdGVySWQSHQoKaW1hZ2VfbmFtZRgGIAEoCVIJaW1hZ2VOYW1lEhQKBW5vdGVzGAcgASgJUgVub3Rlcw==');
@$core.Deprecated('Use numberFilterDescriptor instead')
const NumberFilter$json = const {
  '1': 'NumberFilter',
  '2': const [
    const {'1': 'boundary', '3': 1, '4': 1, '5': 14, '6': '.anglerslog.NumberBoundary', '10': 'boundary'},
    const {'1': 'from', '3': 2, '4': 1, '5': 11, '6': '.anglerslog.MultiMeasurement', '10': 'from'},
    const {'1': 'to', '3': 3, '4': 1, '5': 11, '6': '.anglerslog.MultiMeasurement', '10': 'to'},
  ],
};

/// Descriptor for `NumberFilter`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List numberFilterDescriptor = $convert.base64Decode('CgxOdW1iZXJGaWx0ZXISNgoIYm91bmRhcnkYASABKA4yGi5hbmdsZXJzbG9nLk51bWJlckJvdW5kYXJ5Ughib3VuZGFyeRIwCgRmcm9tGAIgASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50UgRmcm9tEiwKAnRvGAMgASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50UgJ0bw==');
@$core.Deprecated('Use speciesDescriptor instead')
const Species$json = const {
  '1': 'Species',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Species`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List speciesDescriptor = $convert.base64Decode('CgdTcGVjaWVzEh4KAmlkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZQ==');
@$core.Deprecated('Use reportDescriptor instead')
const Report$json = const {
  '1': 'Report',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    const {'1': 'type', '3': 4, '4': 1, '5': 14, '6': '.anglerslog.Report.Type', '10': 'type'},
    const {'1': 'from_date_range', '3': 5, '4': 1, '5': 11, '6': '.anglerslog.DateRange', '10': 'fromDateRange'},
    const {'1': 'to_date_range', '3': 6, '4': 1, '5': 11, '6': '.anglerslog.DateRange', '10': 'toDateRange'},
    const {'1': 'baits', '3': 7, '4': 3, '5': 11, '6': '.anglerslog.BaitAttachment', '10': 'baits'},
    const {'1': 'fishing_spot_ids', '3': 8, '4': 3, '5': 11, '6': '.anglerslog.Id', '10': 'fishingSpotIds'},
    const {'1': 'species_ids', '3': 9, '4': 3, '5': 11, '6': '.anglerslog.Id', '10': 'speciesIds'},
    const {'1': 'angler_ids', '3': 10, '4': 3, '5': 11, '6': '.anglerslog.Id', '10': 'anglerIds'},
    const {'1': 'method_ids', '3': 11, '4': 3, '5': 11, '6': '.anglerslog.Id', '10': 'methodIds'},
    const {'1': 'periods', '3': 12, '4': 3, '5': 14, '6': '.anglerslog.Period', '10': 'periods'},
    const {'1': 'is_favorites_only', '3': 13, '4': 1, '5': 8, '10': 'isFavoritesOnly'},
    const {'1': 'is_catch_and_release_only', '3': 14, '4': 1, '5': 8, '10': 'isCatchAndReleaseOnly'},
    const {'1': 'seasons', '3': 15, '4': 3, '5': 14, '6': '.anglerslog.Season', '10': 'seasons'},
    const {'1': 'water_clarity_ids', '3': 16, '4': 3, '5': 11, '6': '.anglerslog.Id', '10': 'waterClarityIds'},
    const {'1': 'water_depth_filter', '3': 17, '4': 1, '5': 11, '6': '.anglerslog.NumberFilter', '10': 'waterDepthFilter'},
    const {'1': 'water_temperature_filter', '3': 18, '4': 1, '5': 11, '6': '.anglerslog.NumberFilter', '10': 'waterTemperatureFilter'},
    const {'1': 'length_filter', '3': 19, '4': 1, '5': 11, '6': '.anglerslog.NumberFilter', '10': 'lengthFilter'},
    const {'1': 'weight_filter', '3': 20, '4': 1, '5': 11, '6': '.anglerslog.NumberFilter', '10': 'weightFilter'},
    const {'1': 'quantity_filter', '3': 21, '4': 1, '5': 11, '6': '.anglerslog.NumberFilter', '10': 'quantityFilter'},
    const {'1': 'air_temperature_filter', '3': 22, '4': 1, '5': 11, '6': '.anglerslog.NumberFilter', '10': 'airTemperatureFilter'},
    const {'1': 'air_pressure_filter', '3': 23, '4': 1, '5': 11, '6': '.anglerslog.NumberFilter', '10': 'airPressureFilter'},
    const {'1': 'air_humidity_filter', '3': 24, '4': 1, '5': 11, '6': '.anglerslog.NumberFilter', '10': 'airHumidityFilter'},
    const {'1': 'air_visibility_filter', '3': 25, '4': 1, '5': 11, '6': '.anglerslog.NumberFilter', '10': 'airVisibilityFilter'},
    const {'1': 'wind_speed_filter', '3': 26, '4': 1, '5': 11, '6': '.anglerslog.NumberFilter', '10': 'windSpeedFilter'},
    const {'1': 'wind_directions', '3': 27, '4': 3, '5': 14, '6': '.anglerslog.Direction', '10': 'windDirections'},
    const {'1': 'sky_conditions', '3': 28, '4': 3, '5': 14, '6': '.anglerslog.SkyCondition', '10': 'skyConditions'},
    const {'1': 'moon_phases', '3': 29, '4': 3, '5': 14, '6': '.anglerslog.MoonPhase', '10': 'moonPhases'},
    const {'1': 'tide_types', '3': 30, '4': 3, '5': 14, '6': '.anglerslog.TideType', '10': 'tideTypes'},
    const {'1': 'body_of_water_ids', '3': 31, '4': 3, '5': 11, '6': '.anglerslog.Id', '10': 'bodyOfWaterIds'},
    const {'1': 'time_zone', '3': 32, '4': 1, '5': 9, '10': 'timeZone'},
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
final $typed_data.Uint8List reportDescriptor = $convert.base64Decode('CgZSZXBvcnQSHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlvbhIrCgR0eXBlGAQgASgOMhcuYW5nbGVyc2xvZy5SZXBvcnQuVHlwZVIEdHlwZRI9Cg9mcm9tX2RhdGVfcmFuZ2UYBSABKAsyFS5hbmdsZXJzbG9nLkRhdGVSYW5nZVINZnJvbURhdGVSYW5nZRI5Cg10b19kYXRlX3JhbmdlGAYgASgLMhUuYW5nbGVyc2xvZy5EYXRlUmFuZ2VSC3RvRGF0ZVJhbmdlEjAKBWJhaXRzGAcgAygLMhouYW5nbGVyc2xvZy5CYWl0QXR0YWNobWVudFIFYmFpdHMSOAoQZmlzaGluZ19zcG90X2lkcxgIIAMoCzIOLmFuZ2xlcnNsb2cuSWRSDmZpc2hpbmdTcG90SWRzEi8KC3NwZWNpZXNfaWRzGAkgAygLMg4uYW5nbGVyc2xvZy5JZFIKc3BlY2llc0lkcxItCgphbmdsZXJfaWRzGAogAygLMg4uYW5nbGVyc2xvZy5JZFIJYW5nbGVySWRzEi0KCm1ldGhvZF9pZHMYCyADKAsyDi5hbmdsZXJzbG9nLklkUgltZXRob2RJZHMSLAoHcGVyaW9kcxgMIAMoDjISLmFuZ2xlcnNsb2cuUGVyaW9kUgdwZXJpb2RzEioKEWlzX2Zhdm9yaXRlc19vbmx5GA0gASgIUg9pc0Zhdm9yaXRlc09ubHkSOAoZaXNfY2F0Y2hfYW5kX3JlbGVhc2Vfb25seRgOIAEoCFIVaXNDYXRjaEFuZFJlbGVhc2VPbmx5EiwKB3NlYXNvbnMYDyADKA4yEi5hbmdsZXJzbG9nLlNlYXNvblIHc2Vhc29ucxI6ChF3YXRlcl9jbGFyaXR5X2lkcxgQIAMoCzIOLmFuZ2xlcnNsb2cuSWRSD3dhdGVyQ2xhcml0eUlkcxJGChJ3YXRlcl9kZXB0aF9maWx0ZXIYESABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIQd2F0ZXJEZXB0aEZpbHRlchJSChh3YXRlcl90ZW1wZXJhdHVyZV9maWx0ZXIYEiABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIWd2F0ZXJUZW1wZXJhdHVyZUZpbHRlchI9Cg1sZW5ndGhfZmlsdGVyGBMgASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSDGxlbmd0aEZpbHRlchI9Cg13ZWlnaHRfZmlsdGVyGBQgASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSDHdlaWdodEZpbHRlchJBCg9xdWFudGl0eV9maWx0ZXIYFSABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIOcXVhbnRpdHlGaWx0ZXISTgoWYWlyX3RlbXBlcmF0dXJlX2ZpbHRlchgWIAEoCzIYLmFuZ2xlcnNsb2cuTnVtYmVyRmlsdGVyUhRhaXJUZW1wZXJhdHVyZUZpbHRlchJIChNhaXJfcHJlc3N1cmVfZmlsdGVyGBcgASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSEWFpclByZXNzdXJlRmlsdGVyEkgKE2Fpcl9odW1pZGl0eV9maWx0ZXIYGCABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIRYWlySHVtaWRpdHlGaWx0ZXISTAoVYWlyX3Zpc2liaWxpdHlfZmlsdGVyGBkgASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSE2FpclZpc2liaWxpdHlGaWx0ZXISRAoRd2luZF9zcGVlZF9maWx0ZXIYGiABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIPd2luZFNwZWVkRmlsdGVyEj4KD3dpbmRfZGlyZWN0aW9ucxgbIAMoDjIVLmFuZ2xlcnNsb2cuRGlyZWN0aW9uUg53aW5kRGlyZWN0aW9ucxI/Cg5za3lfY29uZGl0aW9ucxgcIAMoDjIYLmFuZ2xlcnNsb2cuU2t5Q29uZGl0aW9uUg1za3lDb25kaXRpb25zEjYKC21vb25fcGhhc2VzGB0gAygOMhUuYW5nbGVyc2xvZy5Nb29uUGhhc2VSCm1vb25QaGFzZXMSMwoKdGlkZV90eXBlcxgeIAMoDjIULmFuZ2xlcnNsb2cuVGlkZVR5cGVSCXRpZGVUeXBlcxI5ChFib2R5X29mX3dhdGVyX2lkcxgfIAMoCzIOLmFuZ2xlcnNsb2cuSWRSDmJvZHlPZldhdGVySWRzEhsKCXRpbWVfem9uZRggIAEoCVIIdGltZVpvbmUiIwoEVHlwZRILCgdzdW1tYXJ5EAASDgoKY29tcGFyaXNvbhAB');
@$core.Deprecated('Use anglerDescriptor instead')
const Angler$json = const {
  '1': 'Angler',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Angler`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List anglerDescriptor = $convert.base64Decode('CgZBbmdsZXISHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGAIgASgJUgRuYW1l');
@$core.Deprecated('Use methodDescriptor instead')
const Method$json = const {
  '1': 'Method',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Method`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List methodDescriptor = $convert.base64Decode('CgZNZXRob2QSHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGAIgASgJUgRuYW1l');
@$core.Deprecated('Use waterClarityDescriptor instead')
const WaterClarity$json = const {
  '1': 'WaterClarity',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `WaterClarity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List waterClarityDescriptor = $convert.base64Decode('CgxXYXRlckNsYXJpdHkSHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGAIgASgJUgRuYW1l');
@$core.Deprecated('Use tripDescriptor instead')
const Trip$json = const {
  '1': 'Trip',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'start_timestamp', '3': 3, '4': 1, '5': 4, '10': 'startTimestamp'},
    const {'1': 'end_timestamp', '3': 4, '4': 1, '5': 4, '10': 'endTimestamp'},
    const {'1': 'image_names', '3': 5, '4': 3, '5': 9, '10': 'imageNames'},
    const {'1': 'catch_ids', '3': 6, '4': 3, '5': 11, '6': '.anglerslog.Id', '10': 'catchIds'},
    const {'1': 'body_of_water_ids', '3': 7, '4': 3, '5': 11, '6': '.anglerslog.Id', '10': 'bodyOfWaterIds'},
    const {'1': 'catches_per_fishing_spot', '3': 8, '4': 3, '5': 11, '6': '.anglerslog.Trip.CatchesPerEntity', '10': 'catchesPerFishingSpot'},
    const {'1': 'catches_per_angler', '3': 9, '4': 3, '5': 11, '6': '.anglerslog.Trip.CatchesPerEntity', '10': 'catchesPerAngler'},
    const {'1': 'catches_per_species', '3': 10, '4': 3, '5': 11, '6': '.anglerslog.Trip.CatchesPerEntity', '10': 'catchesPerSpecies'},
    const {'1': 'catches_per_bait', '3': 11, '4': 3, '5': 11, '6': '.anglerslog.Trip.CatchesPerBait', '10': 'catchesPerBait'},
    const {'1': 'custom_entity_values', '3': 12, '4': 3, '5': 11, '6': '.anglerslog.CustomEntityValue', '10': 'customEntityValues'},
    const {'1': 'notes', '3': 13, '4': 1, '5': 9, '10': 'notes'},
    const {'1': 'atmosphere', '3': 14, '4': 1, '5': 11, '6': '.anglerslog.Atmosphere', '10': 'atmosphere'},
    const {'1': 'time_zone', '3': 15, '4': 1, '5': 9, '10': 'timeZone'},
  ],
  '3': const [Trip_CatchesPerEntity$json, Trip_CatchesPerBait$json],
};

@$core.Deprecated('Use tripDescriptor instead')
const Trip_CatchesPerEntity$json = const {
  '1': 'CatchesPerEntity',
  '2': const [
    const {'1': 'entity_id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'entityId'},
    const {'1': 'value', '3': 2, '4': 1, '5': 13, '10': 'value'},
  ],
};

@$core.Deprecated('Use tripDescriptor instead')
const Trip_CatchesPerBait$json = const {
  '1': 'CatchesPerBait',
  '2': const [
    const {'1': 'attachment', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.BaitAttachment', '10': 'attachment'},
    const {'1': 'value', '3': 2, '4': 1, '5': 13, '10': 'value'},
  ],
};

/// Descriptor for `Trip`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tripDescriptor = $convert.base64Decode('CgRUcmlwEh4KAmlkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRInCg9zdGFydF90aW1lc3RhbXAYAyABKARSDnN0YXJ0VGltZXN0YW1wEiMKDWVuZF90aW1lc3RhbXAYBCABKARSDGVuZFRpbWVzdGFtcBIfCgtpbWFnZV9uYW1lcxgFIAMoCVIKaW1hZ2VOYW1lcxIrCgljYXRjaF9pZHMYBiADKAsyDi5hbmdsZXJzbG9nLklkUghjYXRjaElkcxI5ChFib2R5X29mX3dhdGVyX2lkcxgHIAMoCzIOLmFuZ2xlcnNsb2cuSWRSDmJvZHlPZldhdGVySWRzEloKGGNhdGNoZXNfcGVyX2Zpc2hpbmdfc3BvdBgIIAMoCzIhLmFuZ2xlcnNsb2cuVHJpcC5DYXRjaGVzUGVyRW50aXR5UhVjYXRjaGVzUGVyRmlzaGluZ1Nwb3QSTwoSY2F0Y2hlc19wZXJfYW5nbGVyGAkgAygLMiEuYW5nbGVyc2xvZy5UcmlwLkNhdGNoZXNQZXJFbnRpdHlSEGNhdGNoZXNQZXJBbmdsZXISUQoTY2F0Y2hlc19wZXJfc3BlY2llcxgKIAMoCzIhLmFuZ2xlcnNsb2cuVHJpcC5DYXRjaGVzUGVyRW50aXR5UhFjYXRjaGVzUGVyU3BlY2llcxJJChBjYXRjaGVzX3Blcl9iYWl0GAsgAygLMh8uYW5nbGVyc2xvZy5UcmlwLkNhdGNoZXNQZXJCYWl0Ug5jYXRjaGVzUGVyQmFpdBJPChRjdXN0b21fZW50aXR5X3ZhbHVlcxgMIAMoCzIdLmFuZ2xlcnNsb2cuQ3VzdG9tRW50aXR5VmFsdWVSEmN1c3RvbUVudGl0eVZhbHVlcxIUCgVub3RlcxgNIAEoCVIFbm90ZXMSNgoKYXRtb3NwaGVyZRgOIAEoCzIWLmFuZ2xlcnNsb2cuQXRtb3NwaGVyZVIKYXRtb3NwaGVyZRIbCgl0aW1lX3pvbmUYDyABKAlSCHRpbWVab25lGlUKEENhdGNoZXNQZXJFbnRpdHkSKwoJZW50aXR5X2lkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFIIZW50aXR5SWQSFAoFdmFsdWUYAiABKA1SBXZhbHVlGmIKDkNhdGNoZXNQZXJCYWl0EjoKCmF0dGFjaG1lbnQYASABKAsyGi5hbmdsZXJzbG9nLkJhaXRBdHRhY2htZW50UgphdHRhY2htZW50EhQKBXZhbHVlGAIgASgNUgV2YWx1ZQ==');
@$core.Deprecated('Use measurementDescriptor instead')
const Measurement$json = const {
  '1': 'Measurement',
  '2': const [
    const {'1': 'unit', '3': 1, '4': 1, '5': 14, '6': '.anglerslog.Unit', '10': 'unit'},
    const {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
};

/// Descriptor for `Measurement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List measurementDescriptor = $convert.base64Decode('CgtNZWFzdXJlbWVudBIkCgR1bml0GAEgASgOMhAuYW5nbGVyc2xvZy5Vbml0UgR1bml0EhQKBXZhbHVlGAIgASgBUgV2YWx1ZQ==');
@$core.Deprecated('Use multiMeasurementDescriptor instead')
const MultiMeasurement$json = const {
  '1': 'MultiMeasurement',
  '2': const [
    const {'1': 'system', '3': 1, '4': 1, '5': 14, '6': '.anglerslog.MeasurementSystem', '10': 'system'},
    const {'1': 'mainValue', '3': 2, '4': 1, '5': 11, '6': '.anglerslog.Measurement', '10': 'mainValue'},
    const {'1': 'fractionValue', '3': 3, '4': 1, '5': 11, '6': '.anglerslog.Measurement', '10': 'fractionValue'},
  ],
};

/// Descriptor for `MultiMeasurement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List multiMeasurementDescriptor = $convert.base64Decode('ChBNdWx0aU1lYXN1cmVtZW50EjUKBnN5c3RlbRgBIAEoDjIdLmFuZ2xlcnNsb2cuTWVhc3VyZW1lbnRTeXN0ZW1SBnN5c3RlbRI1CgltYWluVmFsdWUYAiABKAsyFy5hbmdsZXJzbG9nLk1lYXN1cmVtZW50UgltYWluVmFsdWUSPQoNZnJhY3Rpb25WYWx1ZRgDIAEoCzIXLmFuZ2xlcnNsb2cuTWVhc3VyZW1lbnRSDWZyYWN0aW9uVmFsdWU=');
@$core.Deprecated('Use tideDescriptor instead')
const Tide$json = const {
  '1': 'Tide',
  '2': const [
    const {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.anglerslog.TideType', '10': 'type'},
    const {'1': 'low_timestamp', '3': 2, '4': 1, '5': 4, '10': 'lowTimestamp'},
    const {'1': 'high_timestamp', '3': 3, '4': 1, '5': 4, '10': 'highTimestamp'},
    const {'1': 'time_zone', '3': 4, '4': 1, '5': 9, '10': 'timeZone'},
  ],
};

/// Descriptor for `Tide`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tideDescriptor = $convert.base64Decode('CgRUaWRlEigKBHR5cGUYASABKA4yFC5hbmdsZXJzbG9nLlRpZGVUeXBlUgR0eXBlEiMKDWxvd190aW1lc3RhbXAYAiABKARSDGxvd1RpbWVzdGFtcBIlCg5oaWdoX3RpbWVzdGFtcBgDIAEoBFINaGlnaFRpbWVzdGFtcBIbCgl0aW1lX3pvbmUYBCABKAlSCHRpbWVab25l');
// ignore_for_file: undefined_named_parameter,constant_identifier_names
