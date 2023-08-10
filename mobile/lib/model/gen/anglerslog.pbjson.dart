///
//  Generated code. Do not modify.
//  source: anglerslog.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

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
final $typed_data.Uint8List directionDescriptor = $convert.base64Decode(
    'CglEaXJlY3Rpb24SEQoNZGlyZWN0aW9uX2FsbBAAEhIKDmRpcmVjdGlvbl9ub25lEAESCQoFbm9ydGgQAhIOCgpub3J0aF9lYXN0EAMSCAoEZWFzdBAEEg4KCnNvdXRoX2Vhc3QQBRIJCgVzb3V0aBAGEg4KCnNvdXRoX3dlc3QQBxIICgR3ZXN0EAgSDgoKbm9ydGhfd2VzdBAJ');
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
final $typed_data.Uint8List moonPhaseDescriptor = $convert.base64Decode(
    'CglNb29uUGhhc2USEgoObW9vbl9waGFzZV9hbGwQABITCg9tb29uX3BoYXNlX25vbmUQARIHCgNuZXcQAhITCg93YXhpbmdfY3Jlc2NlbnQQAxIRCg1maXJzdF9xdWFydGVyEAQSEgoOd2F4aW5nX2dpYmJvdXMQBRIICgRmdWxsEAYSEgoOd2FuaW5nX2dpYmJvdXMQBxIQCgxsYXN0X3F1YXJ0ZXIQCBITCg93YW5pbmdfY3Jlc2NlbnQQCQ==');
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
    const {'1': 'evening', '2': 8},
  ],
};

/// Descriptor for `Period`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List periodDescriptor = $convert.base64Decode(
    'CgZQZXJpb2QSDgoKcGVyaW9kX2FsbBAAEg8KC3BlcmlvZF9ub25lEAESCAoEZGF3bhACEgsKB21vcm5pbmcQAxIKCgZtaWRkYXkQBBINCglhZnRlcm5vb24QBRIICgRkdXNrEAYSCQoFbmlnaHQQBxILCgdldmVuaW5nEAg=');
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
    const {'1': 'sunny', '2': 16},
  ],
};

/// Descriptor for `SkyCondition`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List skyConditionDescriptor = $convert.base64Decode(
    'CgxTa3lDb25kaXRpb24SFQoRc2t5X2NvbmRpdGlvbl9hbGwQABIWChJza3lfY29uZGl0aW9uX25vbmUQARIICgRzbm93EAISCwoHZHJpenpsZRADEggKBGR1c3QQBBIHCgNmb2cQBRIICgRyYWluEAYSCwoHdG9ybmFkbxAHEggKBGhhaWwQCBIHCgNpY2UQCRIJCgVzdG9ybRAKEggKBG1pc3QQCxIJCgVzbW9rZRAMEgwKCG92ZXJjYXN0EA0SCgoGY2xvdWR5EA4SCQoFY2xlYXIQDxIJCgVzdW5ueRAQ');
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
final $typed_data.Uint8List tideTypeDescriptor = $convert.base64Decode(
    'CghUaWRlVHlwZRIRCg10aWRlX3R5cGVfYWxsEAASEgoOdGlkZV90eXBlX25vbmUQARIHCgNsb3cQAhIMCghvdXRnb2luZxADEggKBGhpZ2gQBBIJCgVzbGFjaxAFEgwKCGluY29taW5nEAY=');
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
    const {'1': 'inch_of_mercury', '2': 16},
  ],
};

/// Descriptor for `Unit`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List unitDescriptor = $convert.base64Decode(
    'CgRVbml0EggKBGZlZXQQABIKCgZpbmNoZXMQARIKCgZwb3VuZHMQAhIKCgZvdW5jZXMQAxIOCgpmYWhyZW5oZWl0EAQSCgoGbWV0ZXJzEAUSDwoLY2VudGltZXRlcnMQBhINCglraWxvZ3JhbXMQBxILCgdjZWxzaXVzEAgSEgoObWlsZXNfcGVyX2hvdXIQCRIXChNraWxvbWV0ZXJzX3Blcl9ob3VyEAoSDQoJbWlsbGliYXJzEAsSGgoWcG91bmRzX3Blcl9zcXVhcmVfaW5jaBAMEgkKBW1pbGVzEA0SDgoKa2lsb21ldGVycxAOEgsKB3BlcmNlbnQQDxITCg9pbmNoX29mX21lcmN1cnkQEA==');
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
@$core.Deprecated('Use atmosphereDescriptor instead')
const Atmosphere$json = const {
  '1': 'Atmosphere',
  '2': const [
    const {
      '1': 'temperature_deprecated',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Measurement',
      '10': 'temperatureDeprecated'
    },
    const {
      '1': 'sky_conditions',
      '3': 2,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.SkyCondition',
      '10': 'skyConditions'
    },
    const {
      '1': 'wind_speed_deprecated',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Measurement',
      '10': 'windSpeedDeprecated'
    },
    const {
      '1': 'wind_direction',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.Direction',
      '10': 'windDirection'
    },
    const {
      '1': 'pressure_deprecated',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Measurement',
      '10': 'pressureDeprecated'
    },
    const {
      '1': 'humidity_deprecated',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Measurement',
      '10': 'humidityDeprecated'
    },
    const {
      '1': 'visibility_deprecated',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Measurement',
      '10': 'visibilityDeprecated'
    },
    const {
      '1': 'moon_phase',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.MoonPhase',
      '10': 'moonPhase'
    },
    const {
      '1': 'sunrise_timestamp',
      '3': 9,
      '4': 1,
      '5': 4,
      '10': 'sunriseTimestamp'
    },
    const {
      '1': 'sunset_timestamp',
      '3': 10,
      '4': 1,
      '5': 4,
      '10': 'sunsetTimestamp'
    },
    const {'1': 'time_zone', '3': 11, '4': 1, '5': 9, '10': 'timeZone'},
    const {
      '1': 'temperature',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'temperature'
    },
    const {
      '1': 'wind_speed',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'windSpeed'
    },
    const {
      '1': 'pressure',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'pressure'
    },
    const {
      '1': 'humidity',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'humidity'
    },
    const {
      '1': 'visibility',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'visibility'
    },
  ],
};

/// Descriptor for `Atmosphere`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List atmosphereDescriptor = $convert.base64Decode(
    'CgpBdG1vc3BoZXJlEk4KFnRlbXBlcmF0dXJlX2RlcHJlY2F0ZWQYASABKAsyFy5hbmdsZXJzbG9nLk1lYXN1cmVtZW50UhV0ZW1wZXJhdHVyZURlcHJlY2F0ZWQSPwoOc2t5X2NvbmRpdGlvbnMYAiADKA4yGC5hbmdsZXJzbG9nLlNreUNvbmRpdGlvblINc2t5Q29uZGl0aW9ucxJLChV3aW5kX3NwZWVkX2RlcHJlY2F0ZWQYAyABKAsyFy5hbmdsZXJzbG9nLk1lYXN1cmVtZW50UhN3aW5kU3BlZWREZXByZWNhdGVkEjwKDndpbmRfZGlyZWN0aW9uGAQgASgOMhUuYW5nbGVyc2xvZy5EaXJlY3Rpb25SDXdpbmREaXJlY3Rpb24SSAoTcHJlc3N1cmVfZGVwcmVjYXRlZBgFIAEoCzIXLmFuZ2xlcnNsb2cuTWVhc3VyZW1lbnRSEnByZXNzdXJlRGVwcmVjYXRlZBJIChNodW1pZGl0eV9kZXByZWNhdGVkGAYgASgLMhcuYW5nbGVyc2xvZy5NZWFzdXJlbWVudFISaHVtaWRpdHlEZXByZWNhdGVkEkwKFXZpc2liaWxpdHlfZGVwcmVjYXRlZBgHIAEoCzIXLmFuZ2xlcnNsb2cuTWVhc3VyZW1lbnRSFHZpc2liaWxpdHlEZXByZWNhdGVkEjQKCm1vb25fcGhhc2UYCCABKA4yFS5hbmdsZXJzbG9nLk1vb25QaGFzZVIJbW9vblBoYXNlEisKEXN1bnJpc2VfdGltZXN0YW1wGAkgASgEUhBzdW5yaXNlVGltZXN0YW1wEikKEHN1bnNldF90aW1lc3RhbXAYCiABKARSD3N1bnNldFRpbWVzdGFtcBIbCgl0aW1lX3pvbmUYCyABKAlSCHRpbWVab25lEj4KC3RlbXBlcmF0dXJlGAwgASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50Ugt0ZW1wZXJhdHVyZRI7Cgp3aW5kX3NwZWVkGA0gASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50Ugl3aW5kU3BlZWQSOAoIcHJlc3N1cmUYDiABKAsyHC5hbmdsZXJzbG9nLk11bHRpTWVhc3VyZW1lbnRSCHByZXNzdXJlEjgKCGh1bWlkaXR5GA8gASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50UghodW1pZGl0eRI8Cgp2aXNpYmlsaXR5GBAgASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50Ugp2aXNpYmlsaXR5');
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
    const {'1': 'image_name', '3': 4, '4': 1, '5': 9, '10': 'imageName'},
    const {
      '1': 'type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.Bait.Type',
      '10': 'type'
    },
    const {
      '1': 'variants',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.BaitVariant',
      '10': 'variants'
    },
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
final $typed_data.Uint8List baitDescriptor = $convert.base64Decode(
    'CgRCYWl0Eh4KAmlkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRI4ChBiYWl0X2NhdGVnb3J5X2lkGAMgASgLMg4uYW5nbGVyc2xvZy5JZFIOYmFpdENhdGVnb3J5SWQSHQoKaW1hZ2VfbmFtZRgEIAEoCVIJaW1hZ2VOYW1lEikKBHR5cGUYBSABKA4yFS5hbmdsZXJzbG9nLkJhaXQuVHlwZVIEdHlwZRIzCgh2YXJpYW50cxgGIAMoCzIXLmFuZ2xlcnNsb2cuQmFpdFZhcmlhbnRSCHZhcmlhbnRzIioKBFR5cGUSDgoKYXJ0aWZpY2lhbBAAEggKBHJlYWwQARIICgRsaXZlEAI=');
@$core.Deprecated('Use baitVariantDescriptor instead')
const BaitVariant$json = const {
  '1': 'BaitVariant',
  '2': const [
    const {
      '1': 'id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'id'
    },
    const {
      '1': 'base_id',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'baseId'
    },
    const {'1': 'color', '3': 3, '4': 1, '5': 9, '10': 'color'},
    const {'1': 'model_number', '3': 4, '4': 1, '5': 9, '10': 'modelNumber'},
    const {'1': 'size', '3': 5, '4': 1, '5': 9, '10': 'size'},
    const {
      '1': 'min_dive_depth',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'minDiveDepth'
    },
    const {
      '1': 'max_dive_depth',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'maxDiveDepth'
    },
    const {'1': 'description', '3': 8, '4': 1, '5': 9, '10': 'description'},
    const {
      '1': 'custom_entity_values',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CustomEntityValue',
      '10': 'customEntityValues'
    },
  ],
};

/// Descriptor for `BaitVariant`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List baitVariantDescriptor = $convert.base64Decode(
    'CgtCYWl0VmFyaWFudBIeCgJpZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSAmlkEicKB2Jhc2VfaWQYAiABKAsyDi5hbmdsZXJzbG9nLklkUgZiYXNlSWQSFAoFY29sb3IYAyABKAlSBWNvbG9yEiEKDG1vZGVsX251bWJlchgEIAEoCVILbW9kZWxOdW1iZXISEgoEc2l6ZRgFIAEoCVIEc2l6ZRJCCg5taW5fZGl2ZV9kZXB0aBgGIAEoCzIcLmFuZ2xlcnNsb2cuTXVsdGlNZWFzdXJlbWVudFIMbWluRGl2ZURlcHRoEkIKDm1heF9kaXZlX2RlcHRoGAcgASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50UgxtYXhEaXZlRGVwdGgSIAoLZGVzY3JpcHRpb24YCCABKAlSC2Rlc2NyaXB0aW9uEk8KFGN1c3RvbV9lbnRpdHlfdmFsdWVzGAkgAygLMh0uYW5nbGVyc2xvZy5DdXN0b21FbnRpdHlWYWx1ZVISY3VzdG9tRW50aXR5VmFsdWVz');
@$core.Deprecated('Use baitAttachmentDescriptor instead')
const BaitAttachment$json = const {
  '1': 'BaitAttachment',
  '2': const [
    const {
      '1': 'bait_id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'baitId'
    },
    const {
      '1': 'variant_id',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'variantId'
    },
  ],
};

/// Descriptor for `BaitAttachment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List baitAttachmentDescriptor = $convert.base64Decode(
    'Cg5CYWl0QXR0YWNobWVudBInCgdiYWl0X2lkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFIGYmFpdElkEi0KCnZhcmlhbnRfaWQYAiABKAsyDi5hbmdsZXJzbG9nLklkUgl2YXJpYW50SWQ=');
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
      '1': 'baits',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.BaitAttachment',
      '10': 'baits'
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
    const {
      '1': 'atmosphere',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Atmosphere',
      '10': 'atmosphere'
    },
    const {
      '1': 'tide',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Tide',
      '10': 'tide'
    },
    const {'1': 'time_zone', '3': 23, '4': 1, '5': 9, '10': 'timeZone'},
  ],
};

/// Descriptor for `Catch`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catchDescriptor = $convert.base64Decode(
    'CgVDYXRjaBIeCgJpZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSAmlkEhwKCXRpbWVzdGFtcBgCIAEoBFIJdGltZXN0YW1wEjAKBWJhaXRzGAMgAygLMhouYW5nbGVyc2xvZy5CYWl0QXR0YWNobWVudFIFYmFpdHMSNgoPZmlzaGluZ19zcG90X2lkGAQgASgLMg4uYW5nbGVyc2xvZy5JZFINZmlzaGluZ1Nwb3RJZBItCgpzcGVjaWVzX2lkGAUgASgLMg4uYW5nbGVyc2xvZy5JZFIJc3BlY2llc0lkEh8KC2ltYWdlX25hbWVzGAYgAygJUgppbWFnZU5hbWVzEk8KFGN1c3RvbV9lbnRpdHlfdmFsdWVzGAcgAygLMh0uYW5nbGVyc2xvZy5DdXN0b21FbnRpdHlWYWx1ZVISY3VzdG9tRW50aXR5VmFsdWVzEisKCWFuZ2xlcl9pZBgIIAEoCzIOLmFuZ2xlcnNsb2cuSWRSCGFuZ2xlcklkEi0KCm1ldGhvZF9pZHMYCSADKAsyDi5hbmdsZXJzbG9nLklkUgltZXRob2RJZHMSKgoGcGVyaW9kGAogASgOMhIuYW5nbGVyc2xvZy5QZXJpb2RSBnBlcmlvZBIfCgtpc19mYXZvcml0ZRgLIAEoCFIKaXNGYXZvcml0ZRIxChV3YXNfY2F0Y2hfYW5kX3JlbGVhc2UYDCABKAhSEndhc0NhdGNoQW5kUmVsZWFzZRIqCgZzZWFzb24YDSABKA4yEi5hbmdsZXJzbG9nLlNlYXNvblIGc2Vhc29uEjgKEHdhdGVyX2NsYXJpdHlfaWQYDiABKAsyDi5hbmdsZXJzbG9nLklkUg53YXRlckNsYXJpdHlJZBI9Cgt3YXRlcl9kZXB0aBgPIAEoCzIcLmFuZ2xlcnNsb2cuTXVsdGlNZWFzdXJlbWVudFIKd2F0ZXJEZXB0aBJJChF3YXRlcl90ZW1wZXJhdHVyZRgQIAEoCzIcLmFuZ2xlcnNsb2cuTXVsdGlNZWFzdXJlbWVudFIQd2F0ZXJUZW1wZXJhdHVyZRI0CgZsZW5ndGgYESABKAsyHC5hbmdsZXJzbG9nLk11bHRpTWVhc3VyZW1lbnRSBmxlbmd0aBI0CgZ3ZWlnaHQYEiABKAsyHC5hbmdsZXJzbG9nLk11bHRpTWVhc3VyZW1lbnRSBndlaWdodBIaCghxdWFudGl0eRgTIAEoDVIIcXVhbnRpdHkSFAoFbm90ZXMYFCABKAlSBW5vdGVzEjYKCmF0bW9zcGhlcmUYFSABKAsyFi5hbmdsZXJzbG9nLkF0bW9zcGhlcmVSCmF0bW9zcGhlcmUSJAoEdGlkZRgWIAEoCzIQLmFuZ2xlcnNsb2cuVGlkZVIEdGlkZRIbCgl0aW1lX3pvbmUYFyABKAlSCHRpbWVab25l');
@$core.Deprecated('Use dateRangeDescriptor instead')
const DateRange$json = const {
  '1': 'DateRange',
  '2': const [
    const {
      '1': 'period',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.DateRange.Period',
      '10': 'period'
    },
    const {
      '1': 'start_timestamp',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'startTimestamp'
    },
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
final $typed_data.Uint8List dateRangeDescriptor = $convert.base64Decode(
    'CglEYXRlUmFuZ2USNAoGcGVyaW9kGAEgASgOMhwuYW5nbGVyc2xvZy5EYXRlUmFuZ2UuUGVyaW9kUgZwZXJpb2QSJwoPc3RhcnRfdGltZXN0YW1wGAIgASgEUg5zdGFydFRpbWVzdGFtcBIjCg1lbmRfdGltZXN0YW1wGAMgASgEUgxlbmRUaW1lc3RhbXASGwoJdGltZV96b25lGBcgASgJUgh0aW1lWm9uZSLjAQoGUGVyaW9kEgwKCGFsbERhdGVzEAASCQoFdG9kYXkQARINCgl5ZXN0ZXJkYXkQAhIMCgh0aGlzV2VlaxADEg0KCXRoaXNNb250aBAEEgwKCHRoaXNZZWFyEAUSDAoIbGFzdFdlZWsQBhINCglsYXN0TW9udGgQBxIMCghsYXN0WWVhchAIEg0KCWxhc3Q3RGF5cxAJEg4KCmxhc3QxNERheXMQChIOCgpsYXN0MzBEYXlzEAsSDgoKbGFzdDYwRGF5cxAMEhAKDGxhc3QxMk1vbnRocxANEgoKBmN1c3RvbRAO');
@$core.Deprecated('Use bodyOfWaterDescriptor instead')
const BodyOfWater$json = const {
  '1': 'BodyOfWater',
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

/// Descriptor for `BodyOfWater`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bodyOfWaterDescriptor = $convert.base64Decode(
    'CgtCb2R5T2ZXYXRlchIeCgJpZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWU=');
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
    const {
      '1': 'body_of_water_id',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'bodyOfWaterId'
    },
    const {'1': 'image_name', '3': 6, '4': 1, '5': 9, '10': 'imageName'},
    const {'1': 'notes', '3': 7, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `FishingSpot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fishingSpotDescriptor = $convert.base64Decode(
    'CgtGaXNoaW5nU3BvdBIeCgJpZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSEAoDbGF0GAMgASgBUgNsYXQSEAoDbG5nGAQgASgBUgNsbmcSNwoQYm9keV9vZl93YXRlcl9pZBgFIAEoCzIOLmFuZ2xlcnNsb2cuSWRSDWJvZHlPZldhdGVySWQSHQoKaW1hZ2VfbmFtZRgGIAEoCVIJaW1hZ2VOYW1lEhQKBW5vdGVzGAcgASgJUgVub3Rlcw==');
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
      '1': 'from_date_range',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.DateRange',
      '10': 'fromDateRange'
    },
    const {
      '1': 'to_date_range',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.DateRange',
      '10': 'toDateRange'
    },
    const {
      '1': 'baits',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.BaitAttachment',
      '10': 'baits'
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
    const {
      '1': 'angler_ids',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'anglerIds'
    },
    const {
      '1': 'method_ids',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'methodIds'
    },
    const {
      '1': 'periods',
      '3': 12,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.Period',
      '10': 'periods'
    },
    const {
      '1': 'is_favorites_only',
      '3': 13,
      '4': 1,
      '5': 8,
      '10': 'isFavoritesOnly'
    },
    const {
      '1': 'is_catch_and_release_only',
      '3': 14,
      '4': 1,
      '5': 8,
      '10': 'isCatchAndReleaseOnly'
    },
    const {
      '1': 'seasons',
      '3': 15,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.Season',
      '10': 'seasons'
    },
    const {
      '1': 'water_clarity_ids',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'waterClarityIds'
    },
    const {
      '1': 'water_depth_filter',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'waterDepthFilter'
    },
    const {
      '1': 'water_temperature_filter',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'waterTemperatureFilter'
    },
    const {
      '1': 'length_filter',
      '3': 19,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'lengthFilter'
    },
    const {
      '1': 'weight_filter',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'weightFilter'
    },
    const {
      '1': 'quantity_filter',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'quantityFilter'
    },
    const {
      '1': 'air_temperature_filter',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'airTemperatureFilter'
    },
    const {
      '1': 'air_pressure_filter',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'airPressureFilter'
    },
    const {
      '1': 'air_humidity_filter',
      '3': 24,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'airHumidityFilter'
    },
    const {
      '1': 'air_visibility_filter',
      '3': 25,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'airVisibilityFilter'
    },
    const {
      '1': 'wind_speed_filter',
      '3': 26,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'windSpeedFilter'
    },
    const {
      '1': 'wind_directions',
      '3': 27,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.Direction',
      '10': 'windDirections'
    },
    const {
      '1': 'sky_conditions',
      '3': 28,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.SkyCondition',
      '10': 'skyConditions'
    },
    const {
      '1': 'moon_phases',
      '3': 29,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.MoonPhase',
      '10': 'moonPhases'
    },
    const {
      '1': 'tide_types',
      '3': 30,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.TideType',
      '10': 'tideTypes'
    },
    const {
      '1': 'body_of_water_ids',
      '3': 31,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'bodyOfWaterIds'
    },
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
final $typed_data.Uint8List reportDescriptor = $convert.base64Decode(
    'CgZSZXBvcnQSHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlvbhIrCgR0eXBlGAQgASgOMhcuYW5nbGVyc2xvZy5SZXBvcnQuVHlwZVIEdHlwZRI9Cg9mcm9tX2RhdGVfcmFuZ2UYBSABKAsyFS5hbmdsZXJzbG9nLkRhdGVSYW5nZVINZnJvbURhdGVSYW5nZRI5Cg10b19kYXRlX3JhbmdlGAYgASgLMhUuYW5nbGVyc2xvZy5EYXRlUmFuZ2VSC3RvRGF0ZVJhbmdlEjAKBWJhaXRzGAcgAygLMhouYW5nbGVyc2xvZy5CYWl0QXR0YWNobWVudFIFYmFpdHMSOAoQZmlzaGluZ19zcG90X2lkcxgIIAMoCzIOLmFuZ2xlcnNsb2cuSWRSDmZpc2hpbmdTcG90SWRzEi8KC3NwZWNpZXNfaWRzGAkgAygLMg4uYW5nbGVyc2xvZy5JZFIKc3BlY2llc0lkcxItCgphbmdsZXJfaWRzGAogAygLMg4uYW5nbGVyc2xvZy5JZFIJYW5nbGVySWRzEi0KCm1ldGhvZF9pZHMYCyADKAsyDi5hbmdsZXJzbG9nLklkUgltZXRob2RJZHMSLAoHcGVyaW9kcxgMIAMoDjISLmFuZ2xlcnNsb2cuUGVyaW9kUgdwZXJpb2RzEioKEWlzX2Zhdm9yaXRlc19vbmx5GA0gASgIUg9pc0Zhdm9yaXRlc09ubHkSOAoZaXNfY2F0Y2hfYW5kX3JlbGVhc2Vfb25seRgOIAEoCFIVaXNDYXRjaEFuZFJlbGVhc2VPbmx5EiwKB3NlYXNvbnMYDyADKA4yEi5hbmdsZXJzbG9nLlNlYXNvblIHc2Vhc29ucxI6ChF3YXRlcl9jbGFyaXR5X2lkcxgQIAMoCzIOLmFuZ2xlcnNsb2cuSWRSD3dhdGVyQ2xhcml0eUlkcxJGChJ3YXRlcl9kZXB0aF9maWx0ZXIYESABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIQd2F0ZXJEZXB0aEZpbHRlchJSChh3YXRlcl90ZW1wZXJhdHVyZV9maWx0ZXIYEiABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIWd2F0ZXJUZW1wZXJhdHVyZUZpbHRlchI9Cg1sZW5ndGhfZmlsdGVyGBMgASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSDGxlbmd0aEZpbHRlchI9Cg13ZWlnaHRfZmlsdGVyGBQgASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSDHdlaWdodEZpbHRlchJBCg9xdWFudGl0eV9maWx0ZXIYFSABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIOcXVhbnRpdHlGaWx0ZXISTgoWYWlyX3RlbXBlcmF0dXJlX2ZpbHRlchgWIAEoCzIYLmFuZ2xlcnNsb2cuTnVtYmVyRmlsdGVyUhRhaXJUZW1wZXJhdHVyZUZpbHRlchJIChNhaXJfcHJlc3N1cmVfZmlsdGVyGBcgASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSEWFpclByZXNzdXJlRmlsdGVyEkgKE2Fpcl9odW1pZGl0eV9maWx0ZXIYGCABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIRYWlySHVtaWRpdHlGaWx0ZXISTAoVYWlyX3Zpc2liaWxpdHlfZmlsdGVyGBkgASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSE2FpclZpc2liaWxpdHlGaWx0ZXISRAoRd2luZF9zcGVlZF9maWx0ZXIYGiABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIPd2luZFNwZWVkRmlsdGVyEj4KD3dpbmRfZGlyZWN0aW9ucxgbIAMoDjIVLmFuZ2xlcnNsb2cuRGlyZWN0aW9uUg53aW5kRGlyZWN0aW9ucxI/Cg5za3lfY29uZGl0aW9ucxgcIAMoDjIYLmFuZ2xlcnNsb2cuU2t5Q29uZGl0aW9uUg1za3lDb25kaXRpb25zEjYKC21vb25fcGhhc2VzGB0gAygOMhUuYW5nbGVyc2xvZy5Nb29uUGhhc2VSCm1vb25QaGFzZXMSMwoKdGlkZV90eXBlcxgeIAMoDjIULmFuZ2xlcnNsb2cuVGlkZVR5cGVSCXRpZGVUeXBlcxI5ChFib2R5X29mX3dhdGVyX2lkcxgfIAMoCzIOLmFuZ2xlcnNsb2cuSWRSDmJvZHlPZldhdGVySWRzEhsKCXRpbWVfem9uZRggIAEoCVIIdGltZVpvbmUiIwoEVHlwZRILCgdzdW1tYXJ5EAASDgoKY29tcGFyaXNvbhAB');
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
@$core.Deprecated('Use tripDescriptor instead')
const Trip$json = const {
  '1': 'Trip',
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
      '1': 'start_timestamp',
      '3': 3,
      '4': 1,
      '5': 4,
      '10': 'startTimestamp'
    },
    const {'1': 'end_timestamp', '3': 4, '4': 1, '5': 4, '10': 'endTimestamp'},
    const {'1': 'image_names', '3': 5, '4': 3, '5': 9, '10': 'imageNames'},
    const {
      '1': 'catch_ids',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'catchIds'
    },
    const {
      '1': 'body_of_water_ids',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'bodyOfWaterIds'
    },
    const {
      '1': 'catches_per_fishing_spot',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Trip.CatchesPerEntity',
      '10': 'catchesPerFishingSpot'
    },
    const {
      '1': 'catches_per_angler',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Trip.CatchesPerEntity',
      '10': 'catchesPerAngler'
    },
    const {
      '1': 'catches_per_species',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Trip.CatchesPerEntity',
      '10': 'catchesPerSpecies'
    },
    const {
      '1': 'catches_per_bait',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Trip.CatchesPerBait',
      '10': 'catchesPerBait'
    },
    const {
      '1': 'custom_entity_values',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CustomEntityValue',
      '10': 'customEntityValues'
    },
    const {'1': 'notes', '3': 13, '4': 1, '5': 9, '10': 'notes'},
    const {
      '1': 'atmosphere',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Atmosphere',
      '10': 'atmosphere'
    },
    const {'1': 'time_zone', '3': 15, '4': 1, '5': 9, '10': 'timeZone'},
    const {
      '1': 'gps_trail_ids',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'gpsTrailIds'
    },
  ],
  '3': const [Trip_CatchesPerEntity$json, Trip_CatchesPerBait$json],
};

@$core.Deprecated('Use tripDescriptor instead')
const Trip_CatchesPerEntity$json = const {
  '1': 'CatchesPerEntity',
  '2': const [
    const {
      '1': 'entity_id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'entityId'
    },
    const {'1': 'value', '3': 2, '4': 1, '5': 13, '10': 'value'},
  ],
};

@$core.Deprecated('Use tripDescriptor instead')
const Trip_CatchesPerBait$json = const {
  '1': 'CatchesPerBait',
  '2': const [
    const {
      '1': 'attachment',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.BaitAttachment',
      '10': 'attachment'
    },
    const {'1': 'value', '3': 2, '4': 1, '5': 13, '10': 'value'},
  ],
};

/// Descriptor for `Trip`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tripDescriptor = $convert.base64Decode(
    'CgRUcmlwEh4KAmlkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRInCg9zdGFydF90aW1lc3RhbXAYAyABKARSDnN0YXJ0VGltZXN0YW1wEiMKDWVuZF90aW1lc3RhbXAYBCABKARSDGVuZFRpbWVzdGFtcBIfCgtpbWFnZV9uYW1lcxgFIAMoCVIKaW1hZ2VOYW1lcxIrCgljYXRjaF9pZHMYBiADKAsyDi5hbmdsZXJzbG9nLklkUghjYXRjaElkcxI5ChFib2R5X29mX3dhdGVyX2lkcxgHIAMoCzIOLmFuZ2xlcnNsb2cuSWRSDmJvZHlPZldhdGVySWRzEloKGGNhdGNoZXNfcGVyX2Zpc2hpbmdfc3BvdBgIIAMoCzIhLmFuZ2xlcnNsb2cuVHJpcC5DYXRjaGVzUGVyRW50aXR5UhVjYXRjaGVzUGVyRmlzaGluZ1Nwb3QSTwoSY2F0Y2hlc19wZXJfYW5nbGVyGAkgAygLMiEuYW5nbGVyc2xvZy5UcmlwLkNhdGNoZXNQZXJFbnRpdHlSEGNhdGNoZXNQZXJBbmdsZXISUQoTY2F0Y2hlc19wZXJfc3BlY2llcxgKIAMoCzIhLmFuZ2xlcnNsb2cuVHJpcC5DYXRjaGVzUGVyRW50aXR5UhFjYXRjaGVzUGVyU3BlY2llcxJJChBjYXRjaGVzX3Blcl9iYWl0GAsgAygLMh8uYW5nbGVyc2xvZy5UcmlwLkNhdGNoZXNQZXJCYWl0Ug5jYXRjaGVzUGVyQmFpdBJPChRjdXN0b21fZW50aXR5X3ZhbHVlcxgMIAMoCzIdLmFuZ2xlcnNsb2cuQ3VzdG9tRW50aXR5VmFsdWVSEmN1c3RvbUVudGl0eVZhbHVlcxIUCgVub3RlcxgNIAEoCVIFbm90ZXMSNgoKYXRtb3NwaGVyZRgOIAEoCzIWLmFuZ2xlcnNsb2cuQXRtb3NwaGVyZVIKYXRtb3NwaGVyZRIbCgl0aW1lX3pvbmUYDyABKAlSCHRpbWVab25lEjIKDWdwc190cmFpbF9pZHMYECADKAsyDi5hbmdsZXJzbG9nLklkUgtncHNUcmFpbElkcxpVChBDYXRjaGVzUGVyRW50aXR5EisKCWVudGl0eV9pZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSCGVudGl0eUlkEhQKBXZhbHVlGAIgASgNUgV2YWx1ZRpiCg5DYXRjaGVzUGVyQmFpdBI6CgphdHRhY2htZW50GAEgASgLMhouYW5nbGVyc2xvZy5CYWl0QXR0YWNobWVudFIKYXR0YWNobWVudBIUCgV2YWx1ZRgCIAEoDVIFdmFsdWU=');
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
      '1': 'main_value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Measurement',
      '10': 'mainValue'
    },
    const {
      '1': 'fraction_value',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Measurement',
      '10': 'fractionValue'
    },
    const {'1': 'is_negative', '3': 4, '4': 1, '5': 8, '10': 'isNegative'},
  ],
};

/// Descriptor for `MultiMeasurement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List multiMeasurementDescriptor = $convert.base64Decode(
    'ChBNdWx0aU1lYXN1cmVtZW50EjUKBnN5c3RlbRgBIAEoDjIdLmFuZ2xlcnNsb2cuTWVhc3VyZW1lbnRTeXN0ZW1SBnN5c3RlbRI2CgptYWluX3ZhbHVlGAIgASgLMhcuYW5nbGVyc2xvZy5NZWFzdXJlbWVudFIJbWFpblZhbHVlEj4KDmZyYWN0aW9uX3ZhbHVlGAMgASgLMhcuYW5nbGVyc2xvZy5NZWFzdXJlbWVudFINZnJhY3Rpb25WYWx1ZRIfCgtpc19uZWdhdGl2ZRgEIAEoCFIKaXNOZWdhdGl2ZQ==');
@$core.Deprecated('Use tideDescriptor instead')
const Tide$json = const {
  '1': 'Tide',
  '2': const [
    const {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.TideType',
      '10': 'type'
    },
    const {
      '1': 'first_low_timestamp',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'firstLowTimestamp'
    },
    const {
      '1': 'first_high_timestamp',
      '3': 3,
      '4': 1,
      '5': 4,
      '10': 'firstHighTimestamp'
    },
    const {'1': 'time_zone', '3': 4, '4': 1, '5': 9, '10': 'timeZone'},
    const {
      '1': 'height',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Tide.Height',
      '10': 'height'
    },
    const {
      '1': 'days_heights',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Tide.Height',
      '10': 'daysHeights'
    },
    const {
      '1': 'second_low_timestamp',
      '3': 7,
      '4': 1,
      '5': 4,
      '10': 'secondLowTimestamp'
    },
    const {
      '1': 'second_high_timestamp',
      '3': 8,
      '4': 1,
      '5': 4,
      '10': 'secondHighTimestamp'
    },
  ],
  '3': const [Tide_Height$json],
};

@$core.Deprecated('Use tideDescriptor instead')
const Tide_Height$json = const {
  '1': 'Height',
  '2': const [
    const {'1': 'timestamp', '3': 1, '4': 1, '5': 4, '10': 'timestamp'},
    const {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
};

/// Descriptor for `Tide`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tideDescriptor = $convert.base64Decode(
    'CgRUaWRlEigKBHR5cGUYASABKA4yFC5hbmdsZXJzbG9nLlRpZGVUeXBlUgR0eXBlEi4KE2ZpcnN0X2xvd190aW1lc3RhbXAYAiABKARSEWZpcnN0TG93VGltZXN0YW1wEjAKFGZpcnN0X2hpZ2hfdGltZXN0YW1wGAMgASgEUhJmaXJzdEhpZ2hUaW1lc3RhbXASGwoJdGltZV96b25lGAQgASgJUgh0aW1lWm9uZRIvCgZoZWlnaHQYBSABKAsyFy5hbmdsZXJzbG9nLlRpZGUuSGVpZ2h0UgZoZWlnaHQSOgoMZGF5c19oZWlnaHRzGAYgAygLMhcuYW5nbGVyc2xvZy5UaWRlLkhlaWdodFILZGF5c0hlaWdodHMSMAoUc2Vjb25kX2xvd190aW1lc3RhbXAYByABKARSEnNlY29uZExvd1RpbWVzdGFtcBIyChVzZWNvbmRfaGlnaF90aW1lc3RhbXAYCCABKARSE3NlY29uZEhpZ2hUaW1lc3RhbXAaPAoGSGVpZ2h0EhwKCXRpbWVzdGFtcBgBIAEoBFIJdGltZXN0YW1wEhQKBXZhbHVlGAIgASgBUgV2YWx1ZQ==');
@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions$json = const {
  '1': 'CatchFilterOptions',
  '2': const [
    const {
      '1': 'order',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.CatchFilterOptions.Order',
      '10': 'order'
    },
    const {
      '1': 'current_timestamp',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'currentTimestamp'
    },
    const {
      '1': 'current_time_zone',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'currentTimeZone'
    },
    const {
      '1': 'all_anglers',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchFilterOptions.AllAnglersEntry',
      '10': 'allAnglers'
    },
    const {
      '1': 'all_baits',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchFilterOptions.AllBaitsEntry',
      '10': 'allBaits'
    },
    const {
      '1': 'all_bodies_of_water',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchFilterOptions.AllBodiesOfWaterEntry',
      '10': 'allBodiesOfWater'
    },
    const {
      '1': 'all_catches',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchFilterOptions.AllCatchesEntry',
      '10': 'allCatches'
    },
    const {
      '1': 'all_fishing_spots',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchFilterOptions.AllFishingSpotsEntry',
      '10': 'allFishingSpots'
    },
    const {
      '1': 'all_methods',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchFilterOptions.AllMethodsEntry',
      '10': 'allMethods'
    },
    const {
      '1': 'all_species',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchFilterOptions.AllSpeciesEntry',
      '10': 'allSpecies'
    },
    const {
      '1': 'all_water_clarities',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchFilterOptions.AllWaterClaritiesEntry',
      '10': 'allWaterClarities'
    },
    const {
      '1': 'is_catch_and_release_only',
      '3': 12,
      '4': 1,
      '5': 8,
      '10': 'isCatchAndReleaseOnly'
    },
    const {
      '1': 'is_favorites_only',
      '3': 13,
      '4': 1,
      '5': 8,
      '10': 'isFavoritesOnly'
    },
    const {
      '1': 'date_ranges',
      '3': 14,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.DateRange',
      '10': 'dateRanges'
    },
    const {
      '1': 'baits',
      '3': 15,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.BaitAttachment',
      '10': 'baits'
    },
    const {
      '1': 'catch_ids',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'catchIds'
    },
    const {
      '1': 'angler_ids',
      '3': 17,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'anglerIds'
    },
    const {
      '1': 'fishing_spot_ids',
      '3': 18,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'fishingSpotIds'
    },
    const {
      '1': 'body_of_water_ids',
      '3': 19,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'bodyOfWaterIds'
    },
    const {
      '1': 'method_ids',
      '3': 20,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'methodIds'
    },
    const {
      '1': 'species_ids',
      '3': 21,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'speciesIds'
    },
    const {
      '1': 'water_clarity_ids',
      '3': 22,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'waterClarityIds'
    },
    const {
      '1': 'periods',
      '3': 23,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.Period',
      '10': 'periods'
    },
    const {
      '1': 'seasons',
      '3': 24,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.Season',
      '10': 'seasons'
    },
    const {
      '1': 'wind_directions',
      '3': 25,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.Direction',
      '10': 'windDirections'
    },
    const {
      '1': 'sky_conditions',
      '3': 26,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.SkyCondition',
      '10': 'skyConditions'
    },
    const {
      '1': 'moon_phases',
      '3': 27,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.MoonPhase',
      '10': 'moonPhases'
    },
    const {
      '1': 'tide_types',
      '3': 28,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.TideType',
      '10': 'tideTypes'
    },
    const {
      '1': 'water_depth_filter',
      '3': 29,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'waterDepthFilter'
    },
    const {
      '1': 'water_temperature_filter',
      '3': 30,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'waterTemperatureFilter'
    },
    const {
      '1': 'length_filter',
      '3': 31,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'lengthFilter'
    },
    const {
      '1': 'weight_filter',
      '3': 32,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'weightFilter'
    },
    const {
      '1': 'quantity_filter',
      '3': 33,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'quantityFilter'
    },
    const {
      '1': 'air_temperature_filter',
      '3': 34,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'airTemperatureFilter'
    },
    const {
      '1': 'air_pressure_filter',
      '3': 35,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'airPressureFilter'
    },
    const {
      '1': 'air_humidity_filter',
      '3': 36,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'airHumidityFilter'
    },
    const {
      '1': 'air_visibility_filter',
      '3': 37,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'airVisibilityFilter'
    },
    const {
      '1': 'wind_speed_filter',
      '3': 38,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'windSpeedFilter'
    },
    const {'1': 'hour', '3': 39, '4': 1, '5': 5, '10': 'hour'},
    const {'1': 'month', '3': 40, '4': 1, '5': 5, '10': 'month'},
    const {
      '1': 'include_anglers',
      '3': 41,
      '4': 1,
      '5': 8,
      '10': 'includeAnglers'
    },
    const {'1': 'include_baits', '3': 42, '4': 1, '5': 8, '10': 'includeBaits'},
    const {
      '1': 'include_bodies_of_water',
      '3': 43,
      '4': 1,
      '5': 8,
      '10': 'includeBodiesOfWater'
    },
    const {
      '1': 'include_methods',
      '3': 44,
      '4': 1,
      '5': 8,
      '10': 'includeMethods'
    },
    const {
      '1': 'include_fishing_spots',
      '3': 45,
      '4': 1,
      '5': 8,
      '10': 'includeFishingSpots'
    },
    const {
      '1': 'include_moon_phases',
      '3': 46,
      '4': 1,
      '5': 8,
      '10': 'includeMoonPhases'
    },
    const {
      '1': 'include_seasons',
      '3': 47,
      '4': 1,
      '5': 8,
      '10': 'includeSeasons'
    },
    const {
      '1': 'include_species',
      '3': 48,
      '4': 1,
      '5': 8,
      '10': 'includeSpecies'
    },
    const {
      '1': 'include_tide_types',
      '3': 49,
      '4': 1,
      '5': 8,
      '10': 'includeTideTypes'
    },
    const {
      '1': 'include_periods',
      '3': 50,
      '4': 1,
      '5': 8,
      '10': 'includePeriods'
    },
    const {
      '1': 'include_water_clarities',
      '3': 51,
      '4': 1,
      '5': 8,
      '10': 'includeWaterClarities'
    },
  ],
  '3': const [
    CatchFilterOptions_AllAnglersEntry$json,
    CatchFilterOptions_AllBaitsEntry$json,
    CatchFilterOptions_AllBodiesOfWaterEntry$json,
    CatchFilterOptions_AllCatchesEntry$json,
    CatchFilterOptions_AllFishingSpotsEntry$json,
    CatchFilterOptions_AllMethodsEntry$json,
    CatchFilterOptions_AllSpeciesEntry$json,
    CatchFilterOptions_AllWaterClaritiesEntry$json
  ],
  '4': const [CatchFilterOptions_Order$json],
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_AllAnglersEntry$json = const {
  '1': 'AllAnglersEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Angler',
      '10': 'value'
    },
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_AllBaitsEntry$json = const {
  '1': 'AllBaitsEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Bait',
      '10': 'value'
    },
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_AllBodiesOfWaterEntry$json = const {
  '1': 'AllBodiesOfWaterEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.BodyOfWater',
      '10': 'value'
    },
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_AllCatchesEntry$json = const {
  '1': 'AllCatchesEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Catch',
      '10': 'value'
    },
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_AllFishingSpotsEntry$json = const {
  '1': 'AllFishingSpotsEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.FishingSpot',
      '10': 'value'
    },
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_AllMethodsEntry$json = const {
  '1': 'AllMethodsEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Method',
      '10': 'value'
    },
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_AllSpeciesEntry$json = const {
  '1': 'AllSpeciesEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Species',
      '10': 'value'
    },
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_AllWaterClaritiesEntry$json = const {
  '1': 'AllWaterClaritiesEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.WaterClarity',
      '10': 'value'
    },
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_Order$json = const {
  '1': 'Order',
  '2': const [
    const {'1': 'unknown', '2': 0},
    const {'1': 'newest_to_oldest', '2': 1},
    const {'1': 'heaviest_to_lightest', '2': 2},
    const {'1': 'longest_to_shortest', '2': 3},
  ],
};

/// Descriptor for `CatchFilterOptions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catchFilterOptionsDescriptor = $convert.base64Decode(
    'ChJDYXRjaEZpbHRlck9wdGlvbnMSOgoFb3JkZXIYASABKA4yJC5hbmdsZXJzbG9nLkNhdGNoRmlsdGVyT3B0aW9ucy5PcmRlclIFb3JkZXISKwoRY3VycmVudF90aW1lc3RhbXAYAiABKARSEGN1cnJlbnRUaW1lc3RhbXASKgoRY3VycmVudF90aW1lX3pvbmUYAyABKAlSD2N1cnJlbnRUaW1lWm9uZRJPCgthbGxfYW5nbGVycxgEIAMoCzIuLmFuZ2xlcnNsb2cuQ2F0Y2hGaWx0ZXJPcHRpb25zLkFsbEFuZ2xlcnNFbnRyeVIKYWxsQW5nbGVycxJJCglhbGxfYmFpdHMYBSADKAsyLC5hbmdsZXJzbG9nLkNhdGNoRmlsdGVyT3B0aW9ucy5BbGxCYWl0c0VudHJ5UghhbGxCYWl0cxJjChNhbGxfYm9kaWVzX29mX3dhdGVyGAYgAygLMjQuYW5nbGVyc2xvZy5DYXRjaEZpbHRlck9wdGlvbnMuQWxsQm9kaWVzT2ZXYXRlckVudHJ5UhBhbGxCb2RpZXNPZldhdGVyEk8KC2FsbF9jYXRjaGVzGAcgAygLMi4uYW5nbGVyc2xvZy5DYXRjaEZpbHRlck9wdGlvbnMuQWxsQ2F0Y2hlc0VudHJ5UgphbGxDYXRjaGVzEl8KEWFsbF9maXNoaW5nX3Nwb3RzGAggAygLMjMuYW5nbGVyc2xvZy5DYXRjaEZpbHRlck9wdGlvbnMuQWxsRmlzaGluZ1Nwb3RzRW50cnlSD2FsbEZpc2hpbmdTcG90cxJPCgthbGxfbWV0aG9kcxgJIAMoCzIuLmFuZ2xlcnNsb2cuQ2F0Y2hGaWx0ZXJPcHRpb25zLkFsbE1ldGhvZHNFbnRyeVIKYWxsTWV0aG9kcxJPCgthbGxfc3BlY2llcxgKIAMoCzIuLmFuZ2xlcnNsb2cuQ2F0Y2hGaWx0ZXJPcHRpb25zLkFsbFNwZWNpZXNFbnRyeVIKYWxsU3BlY2llcxJlChNhbGxfd2F0ZXJfY2xhcml0aWVzGAsgAygLMjUuYW5nbGVyc2xvZy5DYXRjaEZpbHRlck9wdGlvbnMuQWxsV2F0ZXJDbGFyaXRpZXNFbnRyeVIRYWxsV2F0ZXJDbGFyaXRpZXMSOAoZaXNfY2F0Y2hfYW5kX3JlbGVhc2Vfb25seRgMIAEoCFIVaXNDYXRjaEFuZFJlbGVhc2VPbmx5EioKEWlzX2Zhdm9yaXRlc19vbmx5GA0gASgIUg9pc0Zhdm9yaXRlc09ubHkSNgoLZGF0ZV9yYW5nZXMYDiADKAsyFS5hbmdsZXJzbG9nLkRhdGVSYW5nZVIKZGF0ZVJhbmdlcxIwCgViYWl0cxgPIAMoCzIaLmFuZ2xlcnNsb2cuQmFpdEF0dGFjaG1lbnRSBWJhaXRzEisKCWNhdGNoX2lkcxgQIAMoCzIOLmFuZ2xlcnNsb2cuSWRSCGNhdGNoSWRzEi0KCmFuZ2xlcl9pZHMYESADKAsyDi5hbmdsZXJzbG9nLklkUglhbmdsZXJJZHMSOAoQZmlzaGluZ19zcG90X2lkcxgSIAMoCzIOLmFuZ2xlcnNsb2cuSWRSDmZpc2hpbmdTcG90SWRzEjkKEWJvZHlfb2Zfd2F0ZXJfaWRzGBMgAygLMg4uYW5nbGVyc2xvZy5JZFIOYm9keU9mV2F0ZXJJZHMSLQoKbWV0aG9kX2lkcxgUIAMoCzIOLmFuZ2xlcnNsb2cuSWRSCW1ldGhvZElkcxIvCgtzcGVjaWVzX2lkcxgVIAMoCzIOLmFuZ2xlcnNsb2cuSWRSCnNwZWNpZXNJZHMSOgoRd2F0ZXJfY2xhcml0eV9pZHMYFiADKAsyDi5hbmdsZXJzbG9nLklkUg93YXRlckNsYXJpdHlJZHMSLAoHcGVyaW9kcxgXIAMoDjISLmFuZ2xlcnNsb2cuUGVyaW9kUgdwZXJpb2RzEiwKB3NlYXNvbnMYGCADKA4yEi5hbmdsZXJzbG9nLlNlYXNvblIHc2Vhc29ucxI+Cg93aW5kX2RpcmVjdGlvbnMYGSADKA4yFS5hbmdsZXJzbG9nLkRpcmVjdGlvblIOd2luZERpcmVjdGlvbnMSPwoOc2t5X2NvbmRpdGlvbnMYGiADKA4yGC5hbmdsZXJzbG9nLlNreUNvbmRpdGlvblINc2t5Q29uZGl0aW9ucxI2Cgttb29uX3BoYXNlcxgbIAMoDjIVLmFuZ2xlcnNsb2cuTW9vblBoYXNlUgptb29uUGhhc2VzEjMKCnRpZGVfdHlwZXMYHCADKA4yFC5hbmdsZXJzbG9nLlRpZGVUeXBlUgl0aWRlVHlwZXMSRgoSd2F0ZXJfZGVwdGhfZmlsdGVyGB0gASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSEHdhdGVyRGVwdGhGaWx0ZXISUgoYd2F0ZXJfdGVtcGVyYXR1cmVfZmlsdGVyGB4gASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSFndhdGVyVGVtcGVyYXR1cmVGaWx0ZXISPQoNbGVuZ3RoX2ZpbHRlchgfIAEoCzIYLmFuZ2xlcnNsb2cuTnVtYmVyRmlsdGVyUgxsZW5ndGhGaWx0ZXISPQoNd2VpZ2h0X2ZpbHRlchggIAEoCzIYLmFuZ2xlcnNsb2cuTnVtYmVyRmlsdGVyUgx3ZWlnaHRGaWx0ZXISQQoPcXVhbnRpdHlfZmlsdGVyGCEgASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSDnF1YW50aXR5RmlsdGVyEk4KFmFpcl90ZW1wZXJhdHVyZV9maWx0ZXIYIiABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIUYWlyVGVtcGVyYXR1cmVGaWx0ZXISSAoTYWlyX3ByZXNzdXJlX2ZpbHRlchgjIAEoCzIYLmFuZ2xlcnNsb2cuTnVtYmVyRmlsdGVyUhFhaXJQcmVzc3VyZUZpbHRlchJIChNhaXJfaHVtaWRpdHlfZmlsdGVyGCQgASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSEWFpckh1bWlkaXR5RmlsdGVyEkwKFWFpcl92aXNpYmlsaXR5X2ZpbHRlchglIAEoCzIYLmFuZ2xlcnNsb2cuTnVtYmVyRmlsdGVyUhNhaXJWaXNpYmlsaXR5RmlsdGVyEkQKEXdpbmRfc3BlZWRfZmlsdGVyGCYgASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSD3dpbmRTcGVlZEZpbHRlchISCgRob3VyGCcgASgFUgRob3VyEhQKBW1vbnRoGCggASgFUgVtb250aBInCg9pbmNsdWRlX2FuZ2xlcnMYKSABKAhSDmluY2x1ZGVBbmdsZXJzEiMKDWluY2x1ZGVfYmFpdHMYKiABKAhSDGluY2x1ZGVCYWl0cxI1ChdpbmNsdWRlX2JvZGllc19vZl93YXRlchgrIAEoCFIUaW5jbHVkZUJvZGllc09mV2F0ZXISJwoPaW5jbHVkZV9tZXRob2RzGCwgASgIUg5pbmNsdWRlTWV0aG9kcxIyChVpbmNsdWRlX2Zpc2hpbmdfc3BvdHMYLSABKAhSE2luY2x1ZGVGaXNoaW5nU3BvdHMSLgoTaW5jbHVkZV9tb29uX3BoYXNlcxguIAEoCFIRaW5jbHVkZU1vb25QaGFzZXMSJwoPaW5jbHVkZV9zZWFzb25zGC8gASgIUg5pbmNsdWRlU2Vhc29ucxInCg9pbmNsdWRlX3NwZWNpZXMYMCABKAhSDmluY2x1ZGVTcGVjaWVzEiwKEmluY2x1ZGVfdGlkZV90eXBlcxgxIAEoCFIQaW5jbHVkZVRpZGVUeXBlcxInCg9pbmNsdWRlX3BlcmlvZHMYMiABKAhSDmluY2x1ZGVQZXJpb2RzEjYKF2luY2x1ZGVfd2F0ZXJfY2xhcml0aWVzGDMgASgIUhVpbmNsdWRlV2F0ZXJDbGFyaXRpZXMaUQoPQWxsQW5nbGVyc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EigKBXZhbHVlGAIgASgLMhIuYW5nbGVyc2xvZy5BbmdsZXJSBXZhbHVlOgI4ARpNCg1BbGxCYWl0c0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EiYKBXZhbHVlGAIgASgLMhAuYW5nbGVyc2xvZy5CYWl0UgV2YWx1ZToCOAEaXAoVQWxsQm9kaWVzT2ZXYXRlckVudHJ5EhAKA2tleRgBIAEoCVIDa2V5Ei0KBXZhbHVlGAIgASgLMhcuYW5nbGVyc2xvZy5Cb2R5T2ZXYXRlclIFdmFsdWU6AjgBGlAKD0FsbENhdGNoZXNFbnRyeRIQCgNrZXkYASABKAlSA2tleRInCgV2YWx1ZRgCIAEoCzIRLmFuZ2xlcnNsb2cuQ2F0Y2hSBXZhbHVlOgI4ARpbChRBbGxGaXNoaW5nU3BvdHNFbnRyeRIQCgNrZXkYASABKAlSA2tleRItCgV2YWx1ZRgCIAEoCzIXLmFuZ2xlcnNsb2cuRmlzaGluZ1Nwb3RSBXZhbHVlOgI4ARpRCg9BbGxNZXRob2RzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSKAoFdmFsdWUYAiABKAsyEi5hbmdsZXJzbG9nLk1ldGhvZFIFdmFsdWU6AjgBGlIKD0FsbFNwZWNpZXNFbnRyeRIQCgNrZXkYASABKAlSA2tleRIpCgV2YWx1ZRgCIAEoCzITLmFuZ2xlcnNsb2cuU3BlY2llc1IFdmFsdWU6AjgBGl4KFkFsbFdhdGVyQ2xhcml0aWVzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSLgoFdmFsdWUYAiABKAsyGC5hbmdsZXJzbG9nLldhdGVyQ2xhcml0eVIFdmFsdWU6AjgBIl0KBU9yZGVyEgsKB3Vua25vd24QABIUChBuZXdlc3RfdG9fb2xkZXN0EAESGAoUaGVhdmllc3RfdG9fbGlnaHRlc3QQAhIXChNsb25nZXN0X3RvX3Nob3J0ZXN0EAM=');
@$core.Deprecated('Use catchReportDescriptor instead')
const CatchReport$json = const {
  '1': 'CatchReport',
  '2': const [
    const {
      '1': 'models',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel',
      '10': 'models'
    },
    const {
      '1': 'ms_since_last_catch',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'msSinceLastCatch'
    },
    const {
      '1': 'last_catch',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Catch',
      '10': 'lastCatch'
    },
    const {'1': 'contains_now', '3': 6, '4': 1, '5': 8, '10': 'containsNow'},
  ],
};

/// Descriptor for `CatchReport`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catchReportDescriptor = $convert.base64Decode(
    'CgtDYXRjaFJlcG9ydBI0CgZtb2RlbHMYASADKAsyHC5hbmdsZXJzbG9nLkNhdGNoUmVwb3J0TW9kZWxSBm1vZGVscxItChNtc19zaW5jZV9sYXN0X2NhdGNoGAIgASgEUhBtc1NpbmNlTGFzdENhdGNoEjAKCmxhc3RfY2F0Y2gYAyABKAsyES5hbmdsZXJzbG9nLkNhdGNoUglsYXN0Q2F0Y2gSIQoMY29udGFpbnNfbm93GAYgASgIUgtjb250YWluc05vdw==');
@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel$json = const {
  '1': 'CatchReportModel',
  '2': const [
    const {
      '1': 'date_range',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.DateRange',
      '10': 'dateRange'
    },
    const {
      '1': 'catch_ids',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'catchIds'
    },
    const {
      '1': 'per_hour',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerHourEntry',
      '10': 'perHour'
    },
    const {
      '1': 'per_month',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerMonthEntry',
      '10': 'perMonth'
    },
    const {
      '1': 'per_moon_phase',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerMoonPhaseEntry',
      '10': 'perMoonPhase'
    },
    const {
      '1': 'per_period',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerPeriodEntry',
      '10': 'perPeriod'
    },
    const {
      '1': 'per_season',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerSeasonEntry',
      '10': 'perSeason'
    },
    const {
      '1': 'per_tide_type',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerTideTypeEntry',
      '10': 'perTideType'
    },
    const {
      '1': 'per_angler',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerAnglerEntry',
      '10': 'perAngler'
    },
    const {
      '1': 'per_body_of_water',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerBodyOfWaterEntry',
      '10': 'perBodyOfWater'
    },
    const {
      '1': 'per_method',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerMethodEntry',
      '10': 'perMethod'
    },
    const {
      '1': 'per_fishing_spot',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerFishingSpotEntry',
      '10': 'perFishingSpot'
    },
    const {
      '1': 'per_species',
      '3': 13,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerSpeciesEntry',
      '10': 'perSpecies'
    },
    const {
      '1': 'per_water_clarity',
      '3': 14,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerWaterClarityEntry',
      '10': 'perWaterClarity'
    },
    const {
      '1': 'per_bait',
      '3': 15,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerBaitEntry',
      '10': 'perBait'
    },
  ],
  '3': const [
    CatchReportModel_PerHourEntry$json,
    CatchReportModel_PerMonthEntry$json,
    CatchReportModel_PerMoonPhaseEntry$json,
    CatchReportModel_PerPeriodEntry$json,
    CatchReportModel_PerSeasonEntry$json,
    CatchReportModel_PerTideTypeEntry$json,
    CatchReportModel_PerAnglerEntry$json,
    CatchReportModel_PerBodyOfWaterEntry$json,
    CatchReportModel_PerMethodEntry$json,
    CatchReportModel_PerFishingSpotEntry$json,
    CatchReportModel_PerSpeciesEntry$json,
    CatchReportModel_PerWaterClarityEntry$json,
    CatchReportModel_PerBaitEntry$json
  ],
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerHourEntry$json = const {
  '1': 'PerHourEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerMonthEntry$json = const {
  '1': 'PerMonthEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerMoonPhaseEntry$json = const {
  '1': 'PerMoonPhaseEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerPeriodEntry$json = const {
  '1': 'PerPeriodEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerSeasonEntry$json = const {
  '1': 'PerSeasonEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerTideTypeEntry$json = const {
  '1': 'PerTideTypeEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerAnglerEntry$json = const {
  '1': 'PerAnglerEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerBodyOfWaterEntry$json = const {
  '1': 'PerBodyOfWaterEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerMethodEntry$json = const {
  '1': 'PerMethodEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerFishingSpotEntry$json = const {
  '1': 'PerFishingSpotEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerSpeciesEntry$json = const {
  '1': 'PerSpeciesEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerWaterClarityEntry$json = const {
  '1': 'PerWaterClarityEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerBaitEntry$json = const {
  '1': 'PerBaitEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': const {'7': true},
};

/// Descriptor for `CatchReportModel`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catchReportModelDescriptor = $convert.base64Decode(
    'ChBDYXRjaFJlcG9ydE1vZGVsEjQKCmRhdGVfcmFuZ2UYASABKAsyFS5hbmdsZXJzbG9nLkRhdGVSYW5nZVIJZGF0ZVJhbmdlEisKCWNhdGNoX2lkcxgCIAMoCzIOLmFuZ2xlcnNsb2cuSWRSCGNhdGNoSWRzEkQKCHBlcl9ob3VyGAMgAygLMikuYW5nbGVyc2xvZy5DYXRjaFJlcG9ydE1vZGVsLlBlckhvdXJFbnRyeVIHcGVySG91chJHCglwZXJfbW9udGgYBCADKAsyKi5hbmdsZXJzbG9nLkNhdGNoUmVwb3J0TW9kZWwuUGVyTW9udGhFbnRyeVIIcGVyTW9udGgSVAoOcGVyX21vb25fcGhhc2UYBSADKAsyLi5hbmdsZXJzbG9nLkNhdGNoUmVwb3J0TW9kZWwuUGVyTW9vblBoYXNlRW50cnlSDHBlck1vb25QaGFzZRJKCgpwZXJfcGVyaW9kGAYgAygLMisuYW5nbGVyc2xvZy5DYXRjaFJlcG9ydE1vZGVsLlBlclBlcmlvZEVudHJ5UglwZXJQZXJpb2QSSgoKcGVyX3NlYXNvbhgHIAMoCzIrLmFuZ2xlcnNsb2cuQ2F0Y2hSZXBvcnRNb2RlbC5QZXJTZWFzb25FbnRyeVIJcGVyU2Vhc29uElEKDXBlcl90aWRlX3R5cGUYCCADKAsyLS5hbmdsZXJzbG9nLkNhdGNoUmVwb3J0TW9kZWwuUGVyVGlkZVR5cGVFbnRyeVILcGVyVGlkZVR5cGUSSgoKcGVyX2FuZ2xlchgJIAMoCzIrLmFuZ2xlcnNsb2cuQ2F0Y2hSZXBvcnRNb2RlbC5QZXJBbmdsZXJFbnRyeVIJcGVyQW5nbGVyElsKEXBlcl9ib2R5X29mX3dhdGVyGAogAygLMjAuYW5nbGVyc2xvZy5DYXRjaFJlcG9ydE1vZGVsLlBlckJvZHlPZldhdGVyRW50cnlSDnBlckJvZHlPZldhdGVyEkoKCnBlcl9tZXRob2QYCyADKAsyKy5hbmdsZXJzbG9nLkNhdGNoUmVwb3J0TW9kZWwuUGVyTWV0aG9kRW50cnlSCXBlck1ldGhvZBJaChBwZXJfZmlzaGluZ19zcG90GAwgAygLMjAuYW5nbGVyc2xvZy5DYXRjaFJlcG9ydE1vZGVsLlBlckZpc2hpbmdTcG90RW50cnlSDnBlckZpc2hpbmdTcG90Ek0KC3Blcl9zcGVjaWVzGA0gAygLMiwuYW5nbGVyc2xvZy5DYXRjaFJlcG9ydE1vZGVsLlBlclNwZWNpZXNFbnRyeVIKcGVyU3BlY2llcxJdChFwZXJfd2F0ZXJfY2xhcml0eRgOIAMoCzIxLmFuZ2xlcnNsb2cuQ2F0Y2hSZXBvcnRNb2RlbC5QZXJXYXRlckNsYXJpdHlFbnRyeVIPcGVyV2F0ZXJDbGFyaXR5EkQKCHBlcl9iYWl0GA8gAygLMikuYW5nbGVyc2xvZy5DYXRjaFJlcG9ydE1vZGVsLlBlckJhaXRFbnRyeVIHcGVyQmFpdBo6CgxQZXJIb3VyRW50cnkSEAoDa2V5GAEgASgFUgNrZXkSFAoFdmFsdWUYAiABKAVSBXZhbHVlOgI4ARo7Cg1QZXJNb250aEVudHJ5EhAKA2tleRgBIAEoBVIDa2V5EhQKBXZhbHVlGAIgASgFUgV2YWx1ZToCOAEaPwoRUGVyTW9vblBoYXNlRW50cnkSEAoDa2V5GAEgASgFUgNrZXkSFAoFdmFsdWUYAiABKAVSBXZhbHVlOgI4ARo8Cg5QZXJQZXJpb2RFbnRyeRIQCgNrZXkYASABKAVSA2tleRIUCgV2YWx1ZRgCIAEoBVIFdmFsdWU6AjgBGjwKDlBlclNlYXNvbkVudHJ5EhAKA2tleRgBIAEoBVIDa2V5EhQKBXZhbHVlGAIgASgFUgV2YWx1ZToCOAEaPgoQUGVyVGlkZVR5cGVFbnRyeRIQCgNrZXkYASABKAVSA2tleRIUCgV2YWx1ZRgCIAEoBVIFdmFsdWU6AjgBGjwKDlBlckFuZ2xlckVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgFUgV2YWx1ZToCOAEaQQoTUGVyQm9keU9mV2F0ZXJFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoBVIFdmFsdWU6AjgBGjwKDlBlck1ldGhvZEVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgFUgV2YWx1ZToCOAEaQQoTUGVyRmlzaGluZ1Nwb3RFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoBVIFdmFsdWU6AjgBGj0KD1BlclNwZWNpZXNFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoBVIFdmFsdWU6AjgBGkIKFFBlcldhdGVyQ2xhcml0eUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgFUgV2YWx1ZToCOAEaOgoMUGVyQmFpdEVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgFUgV2YWx1ZToCOAE=');
@$core.Deprecated('Use tripFilterOptionsDescriptor instead')
const TripFilterOptions$json = const {
  '1': 'TripFilterOptions',
  '2': const [
    const {
      '1': 'current_timestamp',
      '3': 1,
      '4': 1,
      '5': 4,
      '10': 'currentTimestamp'
    },
    const {
      '1': 'current_time_zone',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'currentTimeZone'
    },
    const {
      '1': 'all_catches',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.TripFilterOptions.AllCatchesEntry',
      '10': 'allCatches'
    },
    const {
      '1': 'all_trips',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.TripFilterOptions.AllTripsEntry',
      '10': 'allTrips'
    },
    const {
      '1': 'catch_weight_system',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.MeasurementSystem',
      '10': 'catchWeightSystem'
    },
    const {
      '1': 'catch_length_system',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.MeasurementSystem',
      '10': 'catchLengthSystem'
    },
    const {
      '1': 'date_range',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.DateRange',
      '10': 'dateRange'
    },
    const {
      '1': 'trip_ids',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'tripIds'
    },
  ],
  '3': const [
    TripFilterOptions_AllCatchesEntry$json,
    TripFilterOptions_AllTripsEntry$json
  ],
};

@$core.Deprecated('Use tripFilterOptionsDescriptor instead')
const TripFilterOptions_AllCatchesEntry$json = const {
  '1': 'AllCatchesEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Catch',
      '10': 'value'
    },
  ],
  '7': const {'7': true},
};

@$core.Deprecated('Use tripFilterOptionsDescriptor instead')
const TripFilterOptions_AllTripsEntry$json = const {
  '1': 'AllTripsEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Trip',
      '10': 'value'
    },
  ],
  '7': const {'7': true},
};

/// Descriptor for `TripFilterOptions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tripFilterOptionsDescriptor = $convert.base64Decode(
    'ChFUcmlwRmlsdGVyT3B0aW9ucxIrChFjdXJyZW50X3RpbWVzdGFtcBgBIAEoBFIQY3VycmVudFRpbWVzdGFtcBIqChFjdXJyZW50X3RpbWVfem9uZRgCIAEoCVIPY3VycmVudFRpbWVab25lEk4KC2FsbF9jYXRjaGVzGAMgAygLMi0uYW5nbGVyc2xvZy5UcmlwRmlsdGVyT3B0aW9ucy5BbGxDYXRjaGVzRW50cnlSCmFsbENhdGNoZXMSSAoJYWxsX3RyaXBzGAQgAygLMisuYW5nbGVyc2xvZy5UcmlwRmlsdGVyT3B0aW9ucy5BbGxUcmlwc0VudHJ5UghhbGxUcmlwcxJNChNjYXRjaF93ZWlnaHRfc3lzdGVtGAUgASgOMh0uYW5nbGVyc2xvZy5NZWFzdXJlbWVudFN5c3RlbVIRY2F0Y2hXZWlnaHRTeXN0ZW0STQoTY2F0Y2hfbGVuZ3RoX3N5c3RlbRgGIAEoDjIdLmFuZ2xlcnNsb2cuTWVhc3VyZW1lbnRTeXN0ZW1SEWNhdGNoTGVuZ3RoU3lzdGVtEjQKCmRhdGVfcmFuZ2UYByABKAsyFS5hbmdsZXJzbG9nLkRhdGVSYW5nZVIJZGF0ZVJhbmdlEikKCHRyaXBfaWRzGAggAygLMg4uYW5nbGVyc2xvZy5JZFIHdHJpcElkcxpQCg9BbGxDYXRjaGVzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSJwoFdmFsdWUYAiABKAsyES5hbmdsZXJzbG9nLkNhdGNoUgV2YWx1ZToCOAEaTQoNQWxsVHJpcHNFbnRyeRIQCgNrZXkYASABKAlSA2tleRImCgV2YWx1ZRgCIAEoCzIQLmFuZ2xlcnNsb2cuVHJpcFIFdmFsdWU6AjgB');
@$core.Deprecated('Use tripReportDescriptor instead')
const TripReport$json = const {
  '1': 'TripReport',
  '2': const [
    const {
      '1': 'date_range',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.DateRange',
      '10': 'dateRange'
    },
    const {
      '1': 'trips',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Trip',
      '10': 'trips'
    },
    const {'1': 'total_ms', '3': 3, '4': 1, '5': 4, '10': 'totalMs'},
    const {
      '1': 'longest_trip',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Trip',
      '10': 'longestTrip'
    },
    const {
      '1': 'last_trip',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Trip',
      '10': 'lastTrip'
    },
    const {
      '1': 'ms_since_last_trip',
      '3': 6,
      '4': 1,
      '5': 4,
      '10': 'msSinceLastTrip'
    },
    const {'1': 'containsNow', '3': 7, '4': 1, '5': 8, '10': 'containsNow'},
    const {
      '1': 'average_catches_per_trip',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'averageCatchesPerTrip'
    },
    const {
      '1': 'average_catches_per_hour',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'averageCatchesPerHour'
    },
    const {
      '1': 'average_ms_between_catches',
      '3': 10,
      '4': 1,
      '5': 4,
      '10': 'averageMsBetweenCatches'
    },
    const {
      '1': 'average_trip_ms',
      '3': 11,
      '4': 1,
      '5': 4,
      '10': 'averageTripMs'
    },
    const {
      '1': 'average_ms_between_trips',
      '3': 12,
      '4': 1,
      '5': 4,
      '10': 'averageMsBetweenTrips'
    },
    const {
      '1': 'average_weight_per_trip',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'averageWeightPerTrip'
    },
    const {
      '1': 'most_weight_in_single_trip',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'mostWeightInSingleTrip'
    },
    const {
      '1': 'most_weight_trip',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Trip',
      '10': 'mostWeightTrip'
    },
    const {
      '1': 'average_length_per_trip',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'averageLengthPerTrip'
    },
    const {
      '1': 'most_length_in_single_trip',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'mostLengthInSingleTrip'
    },
    const {
      '1': 'most_length_trip',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Trip',
      '10': 'mostLengthTrip'
    },
  ],
};

/// Descriptor for `TripReport`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tripReportDescriptor = $convert.base64Decode(
    'CgpUcmlwUmVwb3J0EjQKCmRhdGVfcmFuZ2UYASABKAsyFS5hbmdsZXJzbG9nLkRhdGVSYW5nZVIJZGF0ZVJhbmdlEiYKBXRyaXBzGAIgAygLMhAuYW5nbGVyc2xvZy5UcmlwUgV0cmlwcxIZCgh0b3RhbF9tcxgDIAEoBFIHdG90YWxNcxIzCgxsb25nZXN0X3RyaXAYBCABKAsyEC5hbmdsZXJzbG9nLlRyaXBSC2xvbmdlc3RUcmlwEi0KCWxhc3RfdHJpcBgFIAEoCzIQLmFuZ2xlcnNsb2cuVHJpcFIIbGFzdFRyaXASKwoSbXNfc2luY2VfbGFzdF90cmlwGAYgASgEUg9tc1NpbmNlTGFzdFRyaXASIAoLY29udGFpbnNOb3cYByABKAhSC2NvbnRhaW5zTm93EjcKGGF2ZXJhZ2VfY2F0Y2hlc19wZXJfdHJpcBgIIAEoAVIVYXZlcmFnZUNhdGNoZXNQZXJUcmlwEjcKGGF2ZXJhZ2VfY2F0Y2hlc19wZXJfaG91chgJIAEoAVIVYXZlcmFnZUNhdGNoZXNQZXJIb3VyEjsKGmF2ZXJhZ2VfbXNfYmV0d2Vlbl9jYXRjaGVzGAogASgEUhdhdmVyYWdlTXNCZXR3ZWVuQ2F0Y2hlcxImCg9hdmVyYWdlX3RyaXBfbXMYCyABKARSDWF2ZXJhZ2VUcmlwTXMSNwoYYXZlcmFnZV9tc19iZXR3ZWVuX3RyaXBzGAwgASgEUhVhdmVyYWdlTXNCZXR3ZWVuVHJpcHMSUwoXYXZlcmFnZV93ZWlnaHRfcGVyX3RyaXAYDSABKAsyHC5hbmdsZXJzbG9nLk11bHRpTWVhc3VyZW1lbnRSFGF2ZXJhZ2VXZWlnaHRQZXJUcmlwElgKGm1vc3Rfd2VpZ2h0X2luX3NpbmdsZV90cmlwGA4gASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50UhZtb3N0V2VpZ2h0SW5TaW5nbGVUcmlwEjoKEG1vc3Rfd2VpZ2h0X3RyaXAYDyABKAsyEC5hbmdsZXJzbG9nLlRyaXBSDm1vc3RXZWlnaHRUcmlwElMKF2F2ZXJhZ2VfbGVuZ3RoX3Blcl90cmlwGBAgASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50UhRhdmVyYWdlTGVuZ3RoUGVyVHJpcBJYChptb3N0X2xlbmd0aF9pbl9zaW5nbGVfdHJpcBgRIAEoCzIcLmFuZ2xlcnNsb2cuTXVsdGlNZWFzdXJlbWVudFIWbW9zdExlbmd0aEluU2luZ2xlVHJpcBI6ChBtb3N0X2xlbmd0aF90cmlwGBIgASgLMhAuYW5nbGVyc2xvZy5UcmlwUg5tb3N0TGVuZ3RoVHJpcA==');
@$core.Deprecated('Use gpsTrailPointDescriptor instead')
const GpsTrailPoint$json = const {
  '1': 'GpsTrailPoint',
  '2': const [
    const {'1': 'timestamp', '3': 1, '4': 1, '5': 4, '10': 'timestamp'},
    const {'1': 'lat', '3': 2, '4': 1, '5': 1, '10': 'lat'},
    const {'1': 'lng', '3': 3, '4': 1, '5': 1, '10': 'lng'},
    const {'1': 'heading', '3': 4, '4': 1, '5': 1, '10': 'heading'},
  ],
};

/// Descriptor for `GpsTrailPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gpsTrailPointDescriptor = $convert.base64Decode(
    'Cg1HcHNUcmFpbFBvaW50EhwKCXRpbWVzdGFtcBgBIAEoBFIJdGltZXN0YW1wEhAKA2xhdBgCIAEoAVIDbGF0EhAKA2xuZxgDIAEoAVIDbG5nEhgKB2hlYWRpbmcYBCABKAFSB2hlYWRpbmc=');
@$core.Deprecated('Use gpsTrailDescriptor instead')
const GpsTrail$json = const {
  '1': 'GpsTrail',
  '2': const [
    const {
      '1': 'id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'id'
    },
    const {
      '1': 'start_timestamp',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'startTimestamp'
    },
    const {'1': 'end_timestamp', '3': 3, '4': 1, '5': 4, '10': 'endTimestamp'},
    const {'1': 'time_zone', '3': 4, '4': 1, '5': 9, '10': 'timeZone'},
    const {
      '1': 'points',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.GpsTrailPoint',
      '10': 'points'
    },
    const {
      '1': 'body_of_water_id',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'bodyOfWaterId'
    },
  ],
};

/// Descriptor for `GpsTrail`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gpsTrailDescriptor = $convert.base64Decode(
    'CghHcHNUcmFpbBIeCgJpZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSAmlkEicKD3N0YXJ0X3RpbWVzdGFtcBgCIAEoBFIOc3RhcnRUaW1lc3RhbXASIwoNZW5kX3RpbWVzdGFtcBgDIAEoBFIMZW5kVGltZXN0YW1wEhsKCXRpbWVfem9uZRgEIAEoCVIIdGltZVpvbmUSMQoGcG9pbnRzGAUgAygLMhkuYW5nbGVyc2xvZy5HcHNUcmFpbFBvaW50UgZwb2ludHMSNwoQYm9keV9vZl93YXRlcl9pZBgGIAEoCzIOLmFuZ2xlcnNsb2cuSWRSDWJvZHlPZldhdGVySWQ=');
// ignore_for_file: undefined_named_parameter,no_leading_underscores_for_local_identifiers
