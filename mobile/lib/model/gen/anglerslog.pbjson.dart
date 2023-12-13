//
//  Generated code. Do not modify.
//  source: anglerslog.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use directionDescriptor instead')
const Direction$json = {
  '1': 'Direction',
  '2': [
    {'1': 'direction_all', '2': 0},
    {'1': 'direction_none', '2': 1},
    {'1': 'north', '2': 2},
    {'1': 'north_east', '2': 3},
    {'1': 'east', '2': 4},
    {'1': 'south_east', '2': 5},
    {'1': 'south', '2': 6},
    {'1': 'south_west', '2': 7},
    {'1': 'west', '2': 8},
    {'1': 'north_west', '2': 9},
  ],
};

/// Descriptor for `Direction`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List directionDescriptor = $convert.base64Decode(
    'CglEaXJlY3Rpb24SEQoNZGlyZWN0aW9uX2FsbBAAEhIKDmRpcmVjdGlvbl9ub25lEAESCQoFbm'
    '9ydGgQAhIOCgpub3J0aF9lYXN0EAMSCAoEZWFzdBAEEg4KCnNvdXRoX2Vhc3QQBRIJCgVzb3V0'
    'aBAGEg4KCnNvdXRoX3dlc3QQBxIICgR3ZXN0EAgSDgoKbm9ydGhfd2VzdBAJ');

@$core.Deprecated('Use measurementSystemDescriptor instead')
const MeasurementSystem$json = {
  '1': 'MeasurementSystem',
  '2': [
    {'1': 'imperial_whole', '2': 0},
    {'1': 'imperial_decimal', '2': 1},
    {'1': 'metric', '2': 2},
  ],
};

/// Descriptor for `MeasurementSystem`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List measurementSystemDescriptor = $convert.base64Decode(
    'ChFNZWFzdXJlbWVudFN5c3RlbRISCg5pbXBlcmlhbF93aG9sZRAAEhQKEGltcGVyaWFsX2RlY2'
    'ltYWwQARIKCgZtZXRyaWMQAg==');

@$core.Deprecated('Use moonPhaseDescriptor instead')
const MoonPhase$json = {
  '1': 'MoonPhase',
  '2': [
    {'1': 'moon_phase_all', '2': 0},
    {'1': 'moon_phase_none', '2': 1},
    {'1': 'new', '2': 2},
    {'1': 'waxing_crescent', '2': 3},
    {'1': 'first_quarter', '2': 4},
    {'1': 'waxing_gibbous', '2': 5},
    {'1': 'full', '2': 6},
    {'1': 'waning_gibbous', '2': 7},
    {'1': 'last_quarter', '2': 8},
    {'1': 'waning_crescent', '2': 9},
  ],
};

/// Descriptor for `MoonPhase`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List moonPhaseDescriptor = $convert.base64Decode(
    'CglNb29uUGhhc2USEgoObW9vbl9waGFzZV9hbGwQABITCg9tb29uX3BoYXNlX25vbmUQARIHCg'
    'NuZXcQAhITCg93YXhpbmdfY3Jlc2NlbnQQAxIRCg1maXJzdF9xdWFydGVyEAQSEgoOd2F4aW5n'
    'X2dpYmJvdXMQBRIICgRmdWxsEAYSEgoOd2FuaW5nX2dpYmJvdXMQBxIQCgxsYXN0X3F1YXJ0ZX'
    'IQCBITCg93YW5pbmdfY3Jlc2NlbnQQCQ==');

@$core.Deprecated('Use numberBoundaryDescriptor instead')
const NumberBoundary$json = {
  '1': 'NumberBoundary',
  '2': [
    {'1': 'number_boundary_any', '2': 0},
    {'1': 'less_than', '2': 1},
    {'1': 'less_than_or_equal_to', '2': 2},
    {'1': 'equal_to', '2': 3},
    {'1': 'greater_than', '2': 4},
    {'1': 'greater_than_or_equal_to', '2': 5},
    {'1': 'range', '2': 6},
  ],
};

/// Descriptor for `NumberBoundary`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List numberBoundaryDescriptor = $convert.base64Decode(
    'Cg5OdW1iZXJCb3VuZGFyeRIXChNudW1iZXJfYm91bmRhcnlfYW55EAASDQoJbGVzc190aGFuEA'
    'ESGQoVbGVzc190aGFuX29yX2VxdWFsX3RvEAISDAoIZXF1YWxfdG8QAxIQCgxncmVhdGVyX3Ro'
    'YW4QBBIcChhncmVhdGVyX3RoYW5fb3JfZXF1YWxfdG8QBRIJCgVyYW5nZRAG');

@$core.Deprecated('Use periodDescriptor instead')
const Period$json = {
  '1': 'Period',
  '2': [
    {'1': 'period_all', '2': 0},
    {'1': 'period_none', '2': 1},
    {'1': 'dawn', '2': 2},
    {'1': 'morning', '2': 3},
    {'1': 'midday', '2': 4},
    {'1': 'afternoon', '2': 5},
    {'1': 'dusk', '2': 6},
    {'1': 'night', '2': 7},
    {'1': 'evening', '2': 8},
  ],
};

/// Descriptor for `Period`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List periodDescriptor = $convert.base64Decode(
    'CgZQZXJpb2QSDgoKcGVyaW9kX2FsbBAAEg8KC3BlcmlvZF9ub25lEAESCAoEZGF3bhACEgsKB2'
    '1vcm5pbmcQAxIKCgZtaWRkYXkQBBINCglhZnRlcm5vb24QBRIICgRkdXNrEAYSCQoFbmlnaHQQ'
    'BxILCgdldmVuaW5nEAg=');

@$core.Deprecated('Use seasonDescriptor instead')
const Season$json = {
  '1': 'Season',
  '2': [
    {'1': 'season_all', '2': 0},
    {'1': 'season_none', '2': 1},
    {'1': 'winter', '2': 2},
    {'1': 'spring', '2': 3},
    {'1': 'summer', '2': 4},
    {'1': 'autumn', '2': 5},
  ],
};

/// Descriptor for `Season`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List seasonDescriptor = $convert.base64Decode(
    'CgZTZWFzb24SDgoKc2Vhc29uX2FsbBAAEg8KC3NlYXNvbl9ub25lEAESCgoGd2ludGVyEAISCg'
    'oGc3ByaW5nEAMSCgoGc3VtbWVyEAQSCgoGYXV0dW1uEAU=');

@$core.Deprecated('Use skyConditionDescriptor instead')
const SkyCondition$json = {
  '1': 'SkyCondition',
  '2': [
    {'1': 'sky_condition_all', '2': 0},
    {'1': 'sky_condition_none', '2': 1},
    {'1': 'snow', '2': 2},
    {'1': 'drizzle', '2': 3},
    {'1': 'dust', '2': 4},
    {'1': 'fog', '2': 5},
    {'1': 'rain', '2': 6},
    {'1': 'tornado', '2': 7},
    {'1': 'hail', '2': 8},
    {'1': 'ice', '2': 9},
    {'1': 'storm', '2': 10},
    {'1': 'mist', '2': 11},
    {'1': 'smoke', '2': 12},
    {'1': 'overcast', '2': 13},
    {'1': 'cloudy', '2': 14},
    {'1': 'clear', '2': 15},
    {'1': 'sunny', '2': 16},
  ],
};

/// Descriptor for `SkyCondition`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List skyConditionDescriptor = $convert.base64Decode(
    'CgxTa3lDb25kaXRpb24SFQoRc2t5X2NvbmRpdGlvbl9hbGwQABIWChJza3lfY29uZGl0aW9uX2'
    '5vbmUQARIICgRzbm93EAISCwoHZHJpenpsZRADEggKBGR1c3QQBBIHCgNmb2cQBRIICgRyYWlu'
    'EAYSCwoHdG9ybmFkbxAHEggKBGhhaWwQCBIHCgNpY2UQCRIJCgVzdG9ybRAKEggKBG1pc3QQCx'
    'IJCgVzbW9rZRAMEgwKCG92ZXJjYXN0EA0SCgoGY2xvdWR5EA4SCQoFY2xlYXIQDxIJCgVzdW5u'
    'eRAQ');

@$core.Deprecated('Use tideTypeDescriptor instead')
const TideType$json = {
  '1': 'TideType',
  '2': [
    {'1': 'tide_type_all', '2': 0},
    {'1': 'tide_type_none', '2': 1},
    {'1': 'low', '2': 2},
    {'1': 'outgoing', '2': 3},
    {'1': 'high', '2': 4},
    {'1': 'slack', '2': 5},
    {'1': 'incoming', '2': 6},
  ],
};

/// Descriptor for `TideType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List tideTypeDescriptor = $convert.base64Decode(
    'CghUaWRlVHlwZRIRCg10aWRlX3R5cGVfYWxsEAASEgoOdGlkZV90eXBlX25vbmUQARIHCgNsb3'
    'cQAhIMCghvdXRnb2luZxADEggKBGhpZ2gQBBIJCgVzbGFjaxAFEgwKCGluY29taW5nEAY=');

@$core.Deprecated('Use unitDescriptor instead')
const Unit$json = {
  '1': 'Unit',
  '2': [
    {'1': 'feet', '2': 0},
    {'1': 'inches', '2': 1},
    {'1': 'pounds', '2': 2},
    {'1': 'ounces', '2': 3},
    {'1': 'fahrenheit', '2': 4},
    {'1': 'meters', '2': 5},
    {'1': 'centimeters', '2': 6},
    {'1': 'kilograms', '2': 7},
    {'1': 'celsius', '2': 8},
    {'1': 'miles_per_hour', '2': 9},
    {'1': 'kilometers_per_hour', '2': 10},
    {'1': 'millibars', '2': 11},
    {'1': 'pounds_per_square_inch', '2': 12},
    {'1': 'miles', '2': 13},
    {'1': 'kilometers', '2': 14},
    {'1': 'percent', '2': 15},
    {'1': 'inch_of_mercury', '2': 16},
    {'1': 'pound_test', '2': 17},
    {'1': 'x', '2': 18},
    {'1': 'hashtag', '2': 19},
    {'1': 'aught', '2': 20},
  ],
};

/// Descriptor for `Unit`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List unitDescriptor = $convert.base64Decode(
    'CgRVbml0EggKBGZlZXQQABIKCgZpbmNoZXMQARIKCgZwb3VuZHMQAhIKCgZvdW5jZXMQAxIOCg'
    'pmYWhyZW5oZWl0EAQSCgoGbWV0ZXJzEAUSDwoLY2VudGltZXRlcnMQBhINCglraWxvZ3JhbXMQ'
    'BxILCgdjZWxzaXVzEAgSEgoObWlsZXNfcGVyX2hvdXIQCRIXChNraWxvbWV0ZXJzX3Blcl9ob3'
    'VyEAoSDQoJbWlsbGliYXJzEAsSGgoWcG91bmRzX3Blcl9zcXVhcmVfaW5jaBAMEgkKBW1pbGVz'
    'EA0SDgoKa2lsb21ldGVycxAOEgsKB3BlcmNlbnQQDxITCg9pbmNoX29mX21lcmN1cnkQEBIOCg'
    'pwb3VuZF90ZXN0EBESBQoBeBASEgsKB2hhc2h0YWcQExIJCgVhdWdodBAU');

@$core.Deprecated('Use rodActionDescriptor instead')
const RodAction$json = {
  '1': 'RodAction',
  '2': [
    {'1': 'rod_action_all', '2': 0},
    {'1': 'rod_action_none', '2': 1},
    {'1': 'x_fast', '2': 2},
    {'1': 'fast', '2': 3},
    {'1': 'moderate_fast', '2': 4},
    {'1': 'moderate', '2': 5},
    {'1': 'slow', '2': 6},
  ],
};

/// Descriptor for `RodAction`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List rodActionDescriptor = $convert.base64Decode(
    'CglSb2RBY3Rpb24SEgoOcm9kX2FjdGlvbl9hbGwQABITCg9yb2RfYWN0aW9uX25vbmUQARIKCg'
    'Z4X2Zhc3QQAhIICgRmYXN0EAMSEQoNbW9kZXJhdGVfZmFzdBAEEgwKCG1vZGVyYXRlEAUSCAoE'
    'c2xvdxAG');

@$core.Deprecated('Use rodPowerDescriptor instead')
const RodPower$json = {
  '1': 'RodPower',
  '2': [
    {'1': 'rod_power_all', '2': 0},
    {'1': 'rod_power_none', '2': 1},
    {'1': 'ultralight', '2': 2},
    {'1': 'light', '2': 3},
    {'1': 'medium_light', '2': 4},
    {'1': 'medium', '2': 5},
    {'1': 'medium_heavy', '2': 6},
    {'1': 'heavy', '2': 7},
    {'1': 'x_heavy', '2': 8},
    {'1': 'xx_heavy', '2': 9},
    {'1': 'xxx_heavy', '2': 10},
  ],
};

/// Descriptor for `RodPower`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List rodPowerDescriptor = $convert.base64Decode(
    'CghSb2RQb3dlchIRCg1yb2RfcG93ZXJfYWxsEAASEgoOcm9kX3Bvd2VyX25vbmUQARIOCgp1bH'
    'RyYWxpZ2h0EAISCQoFbGlnaHQQAxIQCgxtZWRpdW1fbGlnaHQQBBIKCgZtZWRpdW0QBRIQCgxt'
    'ZWRpdW1faGVhdnkQBhIJCgVoZWF2eRAHEgsKB3hfaGVhdnkQCBIMCgh4eF9oZWF2eRAJEg0KCX'
    'h4eF9oZWF2eRAK');

@$core.Deprecated('Use idDescriptor instead')
const Id$json = {
  '1': 'Id',
  '2': [
    {'1': 'uuid', '3': 1, '4': 1, '5': 9, '10': 'uuid'},
  ],
};

/// Descriptor for `Id`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List idDescriptor =
    $convert.base64Decode('CgJJZBISCgR1dWlkGAEgASgJUgR1dWlk');

@$core.Deprecated('Use atmosphereDescriptor instead')
const Atmosphere$json = {
  '1': 'Atmosphere',
  '2': [
    {
      '1': 'temperature_deprecated',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Measurement',
      '10': 'temperatureDeprecated'
    },
    {
      '1': 'sky_conditions',
      '3': 2,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.SkyCondition',
      '10': 'skyConditions'
    },
    {
      '1': 'wind_speed_deprecated',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Measurement',
      '10': 'windSpeedDeprecated'
    },
    {
      '1': 'wind_direction',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.Direction',
      '10': 'windDirection'
    },
    {
      '1': 'pressure_deprecated',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Measurement',
      '10': 'pressureDeprecated'
    },
    {
      '1': 'humidity_deprecated',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Measurement',
      '10': 'humidityDeprecated'
    },
    {
      '1': 'visibility_deprecated',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Measurement',
      '10': 'visibilityDeprecated'
    },
    {
      '1': 'moon_phase',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.MoonPhase',
      '10': 'moonPhase'
    },
    {
      '1': 'sunrise_timestamp',
      '3': 9,
      '4': 1,
      '5': 4,
      '10': 'sunriseTimestamp'
    },
    {'1': 'sunset_timestamp', '3': 10, '4': 1, '5': 4, '10': 'sunsetTimestamp'},
    {'1': 'time_zone', '3': 11, '4': 1, '5': 9, '10': 'timeZone'},
    {
      '1': 'temperature',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'temperature'
    },
    {
      '1': 'wind_speed',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'windSpeed'
    },
    {
      '1': 'pressure',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'pressure'
    },
    {
      '1': 'humidity',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'humidity'
    },
    {
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
    'CgpBdG1vc3BoZXJlEk4KFnRlbXBlcmF0dXJlX2RlcHJlY2F0ZWQYASABKAsyFy5hbmdsZXJzbG'
    '9nLk1lYXN1cmVtZW50UhV0ZW1wZXJhdHVyZURlcHJlY2F0ZWQSPwoOc2t5X2NvbmRpdGlvbnMY'
    'AiADKA4yGC5hbmdsZXJzbG9nLlNreUNvbmRpdGlvblINc2t5Q29uZGl0aW9ucxJLChV3aW5kX3'
    'NwZWVkX2RlcHJlY2F0ZWQYAyABKAsyFy5hbmdsZXJzbG9nLk1lYXN1cmVtZW50UhN3aW5kU3Bl'
    'ZWREZXByZWNhdGVkEjwKDndpbmRfZGlyZWN0aW9uGAQgASgOMhUuYW5nbGVyc2xvZy5EaXJlY3'
    'Rpb25SDXdpbmREaXJlY3Rpb24SSAoTcHJlc3N1cmVfZGVwcmVjYXRlZBgFIAEoCzIXLmFuZ2xl'
    'cnNsb2cuTWVhc3VyZW1lbnRSEnByZXNzdXJlRGVwcmVjYXRlZBJIChNodW1pZGl0eV9kZXByZW'
    'NhdGVkGAYgASgLMhcuYW5nbGVyc2xvZy5NZWFzdXJlbWVudFISaHVtaWRpdHlEZXByZWNhdGVk'
    'EkwKFXZpc2liaWxpdHlfZGVwcmVjYXRlZBgHIAEoCzIXLmFuZ2xlcnNsb2cuTWVhc3VyZW1lbn'
    'RSFHZpc2liaWxpdHlEZXByZWNhdGVkEjQKCm1vb25fcGhhc2UYCCABKA4yFS5hbmdsZXJzbG9n'
    'Lk1vb25QaGFzZVIJbW9vblBoYXNlEisKEXN1bnJpc2VfdGltZXN0YW1wGAkgASgEUhBzdW5yaX'
    'NlVGltZXN0YW1wEikKEHN1bnNldF90aW1lc3RhbXAYCiABKARSD3N1bnNldFRpbWVzdGFtcBIb'
    'Cgl0aW1lX3pvbmUYCyABKAlSCHRpbWVab25lEj4KC3RlbXBlcmF0dXJlGAwgASgLMhwuYW5nbG'
    'Vyc2xvZy5NdWx0aU1lYXN1cmVtZW50Ugt0ZW1wZXJhdHVyZRI7Cgp3aW5kX3NwZWVkGA0gASgL'
    'MhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50Ugl3aW5kU3BlZWQSOAoIcHJlc3N1cmUYDi'
    'ABKAsyHC5hbmdsZXJzbG9nLk11bHRpTWVhc3VyZW1lbnRSCHByZXNzdXJlEjgKCGh1bWlkaXR5'
    'GA8gASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50UghodW1pZGl0eRI8Cgp2aXNpYm'
    'lsaXR5GBAgASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50Ugp2aXNpYmlsaXR5');

@$core.Deprecated('Use customEntityDescriptor instead')
const CustomEntity$json = {
  '1': 'CustomEntity',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.CustomEntity.Type',
      '10': 'type'
    },
  ],
  '4': [CustomEntity_Type$json],
};

@$core.Deprecated('Use customEntityDescriptor instead')
const CustomEntity_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'boolean', '2': 0},
    {'1': 'number', '2': 1},
    {'1': 'text', '2': 2},
  ],
};

/// Descriptor for `CustomEntity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customEntityDescriptor = $convert.base64Decode(
    'CgxDdXN0b21FbnRpdHkSHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGA'
    'IgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlvbhIxCgR0eXBlGAQg'
    'ASgOMh0uYW5nbGVyc2xvZy5DdXN0b21FbnRpdHkuVHlwZVIEdHlwZSIpCgRUeXBlEgsKB2Jvb2'
    'xlYW4QABIKCgZudW1iZXIQARIICgR0ZXh0EAI=');

@$core.Deprecated('Use customEntityValueDescriptor instead')
const CustomEntityValue$json = {
  '1': 'CustomEntityValue',
  '2': [
    {
      '1': 'custom_entity_id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'customEntityId'
    },
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `CustomEntityValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customEntityValueDescriptor = $convert.base64Decode(
    'ChFDdXN0b21FbnRpdHlWYWx1ZRI4ChBjdXN0b21fZW50aXR5X2lkGAEgASgLMg4uYW5nbGVyc2'
    'xvZy5JZFIOY3VzdG9tRW50aXR5SWQSFAoFdmFsdWUYAiABKAlSBXZhbHVl');

@$core.Deprecated('Use baitDescriptor instead')
const Bait$json = {
  '1': 'Bait',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'bait_category_id',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'baitCategoryId'
    },
    {'1': 'image_name', '3': 4, '4': 1, '5': 9, '10': 'imageName'},
    {
      '1': 'type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.Bait.Type',
      '10': 'type'
    },
    {
      '1': 'variants',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.BaitVariant',
      '10': 'variants'
    },
  ],
  '4': [Bait_Type$json],
};

@$core.Deprecated('Use baitDescriptor instead')
const Bait_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'artificial', '2': 0},
    {'1': 'real', '2': 1},
    {'1': 'live', '2': 2},
  ],
};

/// Descriptor for `Bait`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List baitDescriptor = $convert.base64Decode(
    'CgRCYWl0Eh4KAmlkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFICaWQSEgoEbmFtZRgCIAEoCVIEbm'
    'FtZRI4ChBiYWl0X2NhdGVnb3J5X2lkGAMgASgLMg4uYW5nbGVyc2xvZy5JZFIOYmFpdENhdGVn'
    'b3J5SWQSHQoKaW1hZ2VfbmFtZRgEIAEoCVIJaW1hZ2VOYW1lEikKBHR5cGUYBSABKA4yFS5hbm'
    'dsZXJzbG9nLkJhaXQuVHlwZVIEdHlwZRIzCgh2YXJpYW50cxgGIAMoCzIXLmFuZ2xlcnNsb2cu'
    'QmFpdFZhcmlhbnRSCHZhcmlhbnRzIioKBFR5cGUSDgoKYXJ0aWZpY2lhbBAAEggKBHJlYWwQAR'
    'IICgRsaXZlEAI=');

@$core.Deprecated('Use baitVariantDescriptor instead')
const BaitVariant$json = {
  '1': 'BaitVariant',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    {
      '1': 'base_id',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'baseId'
    },
    {'1': 'color', '3': 3, '4': 1, '5': 9, '10': 'color'},
    {'1': 'model_number', '3': 4, '4': 1, '5': 9, '10': 'modelNumber'},
    {'1': 'size', '3': 5, '4': 1, '5': 9, '10': 'size'},
    {
      '1': 'min_dive_depth',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'minDiveDepth'
    },
    {
      '1': 'max_dive_depth',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'maxDiveDepth'
    },
    {'1': 'description', '3': 8, '4': 1, '5': 9, '10': 'description'},
    {
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
    'CgtCYWl0VmFyaWFudBIeCgJpZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSAmlkEicKB2Jhc2VfaW'
    'QYAiABKAsyDi5hbmdsZXJzbG9nLklkUgZiYXNlSWQSFAoFY29sb3IYAyABKAlSBWNvbG9yEiEK'
    'DG1vZGVsX251bWJlchgEIAEoCVILbW9kZWxOdW1iZXISEgoEc2l6ZRgFIAEoCVIEc2l6ZRJCCg'
    '5taW5fZGl2ZV9kZXB0aBgGIAEoCzIcLmFuZ2xlcnNsb2cuTXVsdGlNZWFzdXJlbWVudFIMbWlu'
    'RGl2ZURlcHRoEkIKDm1heF9kaXZlX2RlcHRoGAcgASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYX'
    'N1cmVtZW50UgxtYXhEaXZlRGVwdGgSIAoLZGVzY3JpcHRpb24YCCABKAlSC2Rlc2NyaXB0aW9u'
    'Ek8KFGN1c3RvbV9lbnRpdHlfdmFsdWVzGAkgAygLMh0uYW5nbGVyc2xvZy5DdXN0b21FbnRpdH'
    'lWYWx1ZVISY3VzdG9tRW50aXR5VmFsdWVz');

@$core.Deprecated('Use baitAttachmentDescriptor instead')
const BaitAttachment$json = {
  '1': 'BaitAttachment',
  '2': [
    {
      '1': 'bait_id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'baitId'
    },
    {
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
    'Cg5CYWl0QXR0YWNobWVudBInCgdiYWl0X2lkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFIGYmFpdE'
    'lkEi0KCnZhcmlhbnRfaWQYAiABKAsyDi5hbmdsZXJzbG9nLklkUgl2YXJpYW50SWQ=');

@$core.Deprecated('Use baitCategoryDescriptor instead')
const BaitCategory$json = {
  '1': 'BaitCategory',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `BaitCategory`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List baitCategoryDescriptor = $convert.base64Decode(
    'CgxCYWl0Q2F0ZWdvcnkSHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGA'
    'IgASgJUgRuYW1l');

@$core.Deprecated('Use catchDescriptor instead')
const Catch$json = {
  '1': 'Catch',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    {'1': 'timestamp', '3': 2, '4': 1, '5': 4, '10': 'timestamp'},
    {
      '1': 'baits',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.BaitAttachment',
      '10': 'baits'
    },
    {
      '1': 'fishing_spot_id',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'fishingSpotId'
    },
    {
      '1': 'species_id',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'speciesId'
    },
    {'1': 'image_names', '3': 6, '4': 3, '5': 9, '10': 'imageNames'},
    {
      '1': 'custom_entity_values',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CustomEntityValue',
      '10': 'customEntityValues'
    },
    {
      '1': 'angler_id',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'anglerId'
    },
    {
      '1': 'method_ids',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'methodIds'
    },
    {
      '1': 'period',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.Period',
      '10': 'period'
    },
    {'1': 'is_favorite', '3': 11, '4': 1, '5': 8, '10': 'isFavorite'},
    {
      '1': 'was_catch_and_release',
      '3': 12,
      '4': 1,
      '5': 8,
      '10': 'wasCatchAndRelease'
    },
    {
      '1': 'season',
      '3': 13,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.Season',
      '10': 'season'
    },
    {
      '1': 'water_clarity_id',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'waterClarityId'
    },
    {
      '1': 'water_depth',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'waterDepth'
    },
    {
      '1': 'water_temperature',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'waterTemperature'
    },
    {
      '1': 'length',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'length'
    },
    {
      '1': 'weight',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'weight'
    },
    {'1': 'quantity', '3': 19, '4': 1, '5': 13, '10': 'quantity'},
    {'1': 'notes', '3': 20, '4': 1, '5': 9, '10': 'notes'},
    {
      '1': 'atmosphere',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Atmosphere',
      '10': 'atmosphere'
    },
    {
      '1': 'tide',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Tide',
      '10': 'tide'
    },
    {'1': 'time_zone', '3': 23, '4': 1, '5': 9, '10': 'timeZone'},
    {
      '1': 'gear_ids',
      '3': 24,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'gearIds'
    },
  ],
};

/// Descriptor for `Catch`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catchDescriptor = $convert.base64Decode(
    'CgVDYXRjaBIeCgJpZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSAmlkEhwKCXRpbWVzdGFtcBgCIA'
    'EoBFIJdGltZXN0YW1wEjAKBWJhaXRzGAMgAygLMhouYW5nbGVyc2xvZy5CYWl0QXR0YWNobWVu'
    'dFIFYmFpdHMSNgoPZmlzaGluZ19zcG90X2lkGAQgASgLMg4uYW5nbGVyc2xvZy5JZFINZmlzaG'
    'luZ1Nwb3RJZBItCgpzcGVjaWVzX2lkGAUgASgLMg4uYW5nbGVyc2xvZy5JZFIJc3BlY2llc0lk'
    'Eh8KC2ltYWdlX25hbWVzGAYgAygJUgppbWFnZU5hbWVzEk8KFGN1c3RvbV9lbnRpdHlfdmFsdW'
    'VzGAcgAygLMh0uYW5nbGVyc2xvZy5DdXN0b21FbnRpdHlWYWx1ZVISY3VzdG9tRW50aXR5VmFs'
    'dWVzEisKCWFuZ2xlcl9pZBgIIAEoCzIOLmFuZ2xlcnNsb2cuSWRSCGFuZ2xlcklkEi0KCm1ldG'
    'hvZF9pZHMYCSADKAsyDi5hbmdsZXJzbG9nLklkUgltZXRob2RJZHMSKgoGcGVyaW9kGAogASgO'
    'MhIuYW5nbGVyc2xvZy5QZXJpb2RSBnBlcmlvZBIfCgtpc19mYXZvcml0ZRgLIAEoCFIKaXNGYX'
    'Zvcml0ZRIxChV3YXNfY2F0Y2hfYW5kX3JlbGVhc2UYDCABKAhSEndhc0NhdGNoQW5kUmVsZWFz'
    'ZRIqCgZzZWFzb24YDSABKA4yEi5hbmdsZXJzbG9nLlNlYXNvblIGc2Vhc29uEjgKEHdhdGVyX2'
    'NsYXJpdHlfaWQYDiABKAsyDi5hbmdsZXJzbG9nLklkUg53YXRlckNsYXJpdHlJZBI9Cgt3YXRl'
    'cl9kZXB0aBgPIAEoCzIcLmFuZ2xlcnNsb2cuTXVsdGlNZWFzdXJlbWVudFIKd2F0ZXJEZXB0aB'
    'JJChF3YXRlcl90ZW1wZXJhdHVyZRgQIAEoCzIcLmFuZ2xlcnNsb2cuTXVsdGlNZWFzdXJlbWVu'
    'dFIQd2F0ZXJUZW1wZXJhdHVyZRI0CgZsZW5ndGgYESABKAsyHC5hbmdsZXJzbG9nLk11bHRpTW'
    'Vhc3VyZW1lbnRSBmxlbmd0aBI0CgZ3ZWlnaHQYEiABKAsyHC5hbmdsZXJzbG9nLk11bHRpTWVh'
    'c3VyZW1lbnRSBndlaWdodBIaCghxdWFudGl0eRgTIAEoDVIIcXVhbnRpdHkSFAoFbm90ZXMYFC'
    'ABKAlSBW5vdGVzEjYKCmF0bW9zcGhlcmUYFSABKAsyFi5hbmdsZXJzbG9nLkF0bW9zcGhlcmVS'
    'CmF0bW9zcGhlcmUSJAoEdGlkZRgWIAEoCzIQLmFuZ2xlcnNsb2cuVGlkZVIEdGlkZRIbCgl0aW'
    '1lX3pvbmUYFyABKAlSCHRpbWVab25lEikKCGdlYXJfaWRzGBggAygLMg4uYW5nbGVyc2xvZy5J'
    'ZFIHZ2Vhcklkcw==');

@$core.Deprecated('Use dateRangeDescriptor instead')
const DateRange$json = {
  '1': 'DateRange',
  '2': [
    {
      '1': 'period',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.DateRange.Period',
      '10': 'period'
    },
    {'1': 'start_timestamp', '3': 2, '4': 1, '5': 4, '10': 'startTimestamp'},
    {'1': 'end_timestamp', '3': 3, '4': 1, '5': 4, '10': 'endTimestamp'},
    {'1': 'time_zone', '3': 23, '4': 1, '5': 9, '10': 'timeZone'},
  ],
  '4': [DateRange_Period$json],
};

@$core.Deprecated('Use dateRangeDescriptor instead')
const DateRange_Period$json = {
  '1': 'Period',
  '2': [
    {'1': 'allDates', '2': 0},
    {'1': 'today', '2': 1},
    {'1': 'yesterday', '2': 2},
    {'1': 'thisWeek', '2': 3},
    {'1': 'thisMonth', '2': 4},
    {'1': 'thisYear', '2': 5},
    {'1': 'lastWeek', '2': 6},
    {'1': 'lastMonth', '2': 7},
    {'1': 'lastYear', '2': 8},
    {'1': 'last7Days', '2': 9},
    {'1': 'last14Days', '2': 10},
    {'1': 'last30Days', '2': 11},
    {'1': 'last60Days', '2': 12},
    {'1': 'last12Months', '2': 13},
    {'1': 'custom', '2': 14},
  ],
};

/// Descriptor for `DateRange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dateRangeDescriptor = $convert.base64Decode(
    'CglEYXRlUmFuZ2USNAoGcGVyaW9kGAEgASgOMhwuYW5nbGVyc2xvZy5EYXRlUmFuZ2UuUGVyaW'
    '9kUgZwZXJpb2QSJwoPc3RhcnRfdGltZXN0YW1wGAIgASgEUg5zdGFydFRpbWVzdGFtcBIjCg1l'
    'bmRfdGltZXN0YW1wGAMgASgEUgxlbmRUaW1lc3RhbXASGwoJdGltZV96b25lGBcgASgJUgh0aW'
    '1lWm9uZSLjAQoGUGVyaW9kEgwKCGFsbERhdGVzEAASCQoFdG9kYXkQARINCgl5ZXN0ZXJkYXkQ'
    'AhIMCgh0aGlzV2VlaxADEg0KCXRoaXNNb250aBAEEgwKCHRoaXNZZWFyEAUSDAoIbGFzdFdlZW'
    'sQBhINCglsYXN0TW9udGgQBxIMCghsYXN0WWVhchAIEg0KCWxhc3Q3RGF5cxAJEg4KCmxhc3Qx'
    'NERheXMQChIOCgpsYXN0MzBEYXlzEAsSDgoKbGFzdDYwRGF5cxAMEhAKDGxhc3QxMk1vbnRocx'
    'ANEgoKBmN1c3RvbRAO');

@$core.Deprecated('Use bodyOfWaterDescriptor instead')
const BodyOfWater$json = {
  '1': 'BodyOfWater',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `BodyOfWater`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bodyOfWaterDescriptor = $convert.base64Decode(
    'CgtCb2R5T2ZXYXRlchIeCgJpZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSAmlkEhIKBG5hbWUYAi'
    'ABKAlSBG5hbWU=');

@$core.Deprecated('Use fishingSpotDescriptor instead')
const FishingSpot$json = {
  '1': 'FishingSpot',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'lat', '3': 3, '4': 1, '5': 1, '10': 'lat'},
    {'1': 'lng', '3': 4, '4': 1, '5': 1, '10': 'lng'},
    {
      '1': 'body_of_water_id',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'bodyOfWaterId'
    },
    {'1': 'image_name', '3': 6, '4': 1, '5': 9, '10': 'imageName'},
    {'1': 'notes', '3': 7, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `FishingSpot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fishingSpotDescriptor = $convert.base64Decode(
    'CgtGaXNoaW5nU3BvdBIeCgJpZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSAmlkEhIKBG5hbWUYAi'
    'ABKAlSBG5hbWUSEAoDbGF0GAMgASgBUgNsYXQSEAoDbG5nGAQgASgBUgNsbmcSNwoQYm9keV9v'
    'Zl93YXRlcl9pZBgFIAEoCzIOLmFuZ2xlcnNsb2cuSWRSDWJvZHlPZldhdGVySWQSHQoKaW1hZ2'
    'VfbmFtZRgGIAEoCVIJaW1hZ2VOYW1lEhQKBW5vdGVzGAcgASgJUgVub3Rlcw==');

@$core.Deprecated('Use numberFilterDescriptor instead')
const NumberFilter$json = {
  '1': 'NumberFilter',
  '2': [
    {
      '1': 'boundary',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.NumberBoundary',
      '10': 'boundary'
    },
    {
      '1': 'from',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'from'
    },
    {
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
    'CgxOdW1iZXJGaWx0ZXISNgoIYm91bmRhcnkYASABKA4yGi5hbmdsZXJzbG9nLk51bWJlckJvdW'
    '5kYXJ5Ughib3VuZGFyeRIwCgRmcm9tGAIgASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVt'
    'ZW50UgRmcm9tEiwKAnRvGAMgASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50UgJ0bw'
    '==');

@$core.Deprecated('Use speciesDescriptor instead')
const Species$json = {
  '1': 'Species',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Species`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List speciesDescriptor = $convert.base64Decode(
    'CgdTcGVjaWVzEh4KAmlkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFICaWQSEgoEbmFtZRgCIAEoCV'
    'IEbmFtZQ==');

@$core.Deprecated('Use reportDescriptor instead')
const Report$json = {
  '1': 'Report',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.Report.Type',
      '10': 'type'
    },
    {
      '1': 'from_date_range',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.DateRange',
      '10': 'fromDateRange'
    },
    {
      '1': 'to_date_range',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.DateRange',
      '10': 'toDateRange'
    },
    {
      '1': 'baits',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.BaitAttachment',
      '10': 'baits'
    },
    {
      '1': 'fishing_spot_ids',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'fishingSpotIds'
    },
    {
      '1': 'species_ids',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'speciesIds'
    },
    {
      '1': 'angler_ids',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'anglerIds'
    },
    {
      '1': 'method_ids',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'methodIds'
    },
    {
      '1': 'periods',
      '3': 12,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.Period',
      '10': 'periods'
    },
    {
      '1': 'is_favorites_only',
      '3': 13,
      '4': 1,
      '5': 8,
      '10': 'isFavoritesOnly'
    },
    {
      '1': 'is_catch_and_release_only',
      '3': 14,
      '4': 1,
      '5': 8,
      '10': 'isCatchAndReleaseOnly'
    },
    {
      '1': 'seasons',
      '3': 15,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.Season',
      '10': 'seasons'
    },
    {
      '1': 'water_clarity_ids',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'waterClarityIds'
    },
    {
      '1': 'water_depth_filter',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'waterDepthFilter'
    },
    {
      '1': 'water_temperature_filter',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'waterTemperatureFilter'
    },
    {
      '1': 'length_filter',
      '3': 19,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'lengthFilter'
    },
    {
      '1': 'weight_filter',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'weightFilter'
    },
    {
      '1': 'quantity_filter',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'quantityFilter'
    },
    {
      '1': 'air_temperature_filter',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'airTemperatureFilter'
    },
    {
      '1': 'air_pressure_filter',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'airPressureFilter'
    },
    {
      '1': 'air_humidity_filter',
      '3': 24,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'airHumidityFilter'
    },
    {
      '1': 'air_visibility_filter',
      '3': 25,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'airVisibilityFilter'
    },
    {
      '1': 'wind_speed_filter',
      '3': 26,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'windSpeedFilter'
    },
    {
      '1': 'wind_directions',
      '3': 27,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.Direction',
      '10': 'windDirections'
    },
    {
      '1': 'sky_conditions',
      '3': 28,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.SkyCondition',
      '10': 'skyConditions'
    },
    {
      '1': 'moon_phases',
      '3': 29,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.MoonPhase',
      '10': 'moonPhases'
    },
    {
      '1': 'tide_types',
      '3': 30,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.TideType',
      '10': 'tideTypes'
    },
    {
      '1': 'body_of_water_ids',
      '3': 31,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'bodyOfWaterIds'
    },
    {'1': 'time_zone', '3': 32, '4': 1, '5': 9, '10': 'timeZone'},
    {
      '1': 'gear_ids',
      '3': 33,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'gearIds'
    },
  ],
  '4': [Report_Type$json],
};

@$core.Deprecated('Use reportDescriptor instead')
const Report_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'summary', '2': 0},
    {'1': 'comparison', '2': 1},
  ],
};

/// Descriptor for `Report`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reportDescriptor = $convert.base64Decode(
    'CgZSZXBvcnQSHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGAIgASgJUg'
    'RuYW1lEiAKC2Rlc2NyaXB0aW9uGAMgASgJUgtkZXNjcmlwdGlvbhIrCgR0eXBlGAQgASgOMhcu'
    'YW5nbGVyc2xvZy5SZXBvcnQuVHlwZVIEdHlwZRI9Cg9mcm9tX2RhdGVfcmFuZ2UYBSABKAsyFS'
    '5hbmdsZXJzbG9nLkRhdGVSYW5nZVINZnJvbURhdGVSYW5nZRI5Cg10b19kYXRlX3JhbmdlGAYg'
    'ASgLMhUuYW5nbGVyc2xvZy5EYXRlUmFuZ2VSC3RvRGF0ZVJhbmdlEjAKBWJhaXRzGAcgAygLMh'
    'ouYW5nbGVyc2xvZy5CYWl0QXR0YWNobWVudFIFYmFpdHMSOAoQZmlzaGluZ19zcG90X2lkcxgI'
    'IAMoCzIOLmFuZ2xlcnNsb2cuSWRSDmZpc2hpbmdTcG90SWRzEi8KC3NwZWNpZXNfaWRzGAkgAy'
    'gLMg4uYW5nbGVyc2xvZy5JZFIKc3BlY2llc0lkcxItCgphbmdsZXJfaWRzGAogAygLMg4uYW5n'
    'bGVyc2xvZy5JZFIJYW5nbGVySWRzEi0KCm1ldGhvZF9pZHMYCyADKAsyDi5hbmdsZXJzbG9nLk'
    'lkUgltZXRob2RJZHMSLAoHcGVyaW9kcxgMIAMoDjISLmFuZ2xlcnNsb2cuUGVyaW9kUgdwZXJp'
    'b2RzEioKEWlzX2Zhdm9yaXRlc19vbmx5GA0gASgIUg9pc0Zhdm9yaXRlc09ubHkSOAoZaXNfY2'
    'F0Y2hfYW5kX3JlbGVhc2Vfb25seRgOIAEoCFIVaXNDYXRjaEFuZFJlbGVhc2VPbmx5EiwKB3Nl'
    'YXNvbnMYDyADKA4yEi5hbmdsZXJzbG9nLlNlYXNvblIHc2Vhc29ucxI6ChF3YXRlcl9jbGFyaX'
    'R5X2lkcxgQIAMoCzIOLmFuZ2xlcnNsb2cuSWRSD3dhdGVyQ2xhcml0eUlkcxJGChJ3YXRlcl9k'
    'ZXB0aF9maWx0ZXIYESABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIQd2F0ZXJEZXB0aE'
    'ZpbHRlchJSChh3YXRlcl90ZW1wZXJhdHVyZV9maWx0ZXIYEiABKAsyGC5hbmdsZXJzbG9nLk51'
    'bWJlckZpbHRlclIWd2F0ZXJUZW1wZXJhdHVyZUZpbHRlchI9Cg1sZW5ndGhfZmlsdGVyGBMgAS'
    'gLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSDGxlbmd0aEZpbHRlchI9Cg13ZWlnaHRfZmls'
    'dGVyGBQgASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSDHdlaWdodEZpbHRlchJBCg9xdW'
    'FudGl0eV9maWx0ZXIYFSABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIOcXVhbnRpdHlG'
    'aWx0ZXISTgoWYWlyX3RlbXBlcmF0dXJlX2ZpbHRlchgWIAEoCzIYLmFuZ2xlcnNsb2cuTnVtYm'
    'VyRmlsdGVyUhRhaXJUZW1wZXJhdHVyZUZpbHRlchJIChNhaXJfcHJlc3N1cmVfZmlsdGVyGBcg'
    'ASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSEWFpclByZXNzdXJlRmlsdGVyEkgKE2Fpcl'
    '9odW1pZGl0eV9maWx0ZXIYGCABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIRYWlySHVt'
    'aWRpdHlGaWx0ZXISTAoVYWlyX3Zpc2liaWxpdHlfZmlsdGVyGBkgASgLMhguYW5nbGVyc2xvZy'
    '5OdW1iZXJGaWx0ZXJSE2FpclZpc2liaWxpdHlGaWx0ZXISRAoRd2luZF9zcGVlZF9maWx0ZXIY'
    'GiABKAsyGC5hbmdsZXJzbG9nLk51bWJlckZpbHRlclIPd2luZFNwZWVkRmlsdGVyEj4KD3dpbm'
    'RfZGlyZWN0aW9ucxgbIAMoDjIVLmFuZ2xlcnNsb2cuRGlyZWN0aW9uUg53aW5kRGlyZWN0aW9u'
    'cxI/Cg5za3lfY29uZGl0aW9ucxgcIAMoDjIYLmFuZ2xlcnNsb2cuU2t5Q29uZGl0aW9uUg1za3'
    'lDb25kaXRpb25zEjYKC21vb25fcGhhc2VzGB0gAygOMhUuYW5nbGVyc2xvZy5Nb29uUGhhc2VS'
    'Cm1vb25QaGFzZXMSMwoKdGlkZV90eXBlcxgeIAMoDjIULmFuZ2xlcnNsb2cuVGlkZVR5cGVSCX'
    'RpZGVUeXBlcxI5ChFib2R5X29mX3dhdGVyX2lkcxgfIAMoCzIOLmFuZ2xlcnNsb2cuSWRSDmJv'
    'ZHlPZldhdGVySWRzEhsKCXRpbWVfem9uZRggIAEoCVIIdGltZVpvbmUSKQoIZ2Vhcl9pZHMYIS'
    'ADKAsyDi5hbmdsZXJzbG9nLklkUgdnZWFySWRzIiMKBFR5cGUSCwoHc3VtbWFyeRAAEg4KCmNv'
    'bXBhcmlzb24QAQ==');

@$core.Deprecated('Use anglerDescriptor instead')
const Angler$json = {
  '1': 'Angler',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Angler`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List anglerDescriptor = $convert.base64Decode(
    'CgZBbmdsZXISHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGAIgASgJUg'
    'RuYW1l');

@$core.Deprecated('Use methodDescriptor instead')
const Method$json = {
  '1': 'Method',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Method`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List methodDescriptor = $convert.base64Decode(
    'CgZNZXRob2QSHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGAIgASgJUg'
    'RuYW1l');

@$core.Deprecated('Use waterClarityDescriptor instead')
const WaterClarity$json = {
  '1': 'WaterClarity',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `WaterClarity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List waterClarityDescriptor = $convert.base64Decode(
    'CgxXYXRlckNsYXJpdHkSHgoCaWQYASABKAsyDi5hbmdsZXJzbG9nLklkUgJpZBISCgRuYW1lGA'
    'IgASgJUgRuYW1l');

@$core.Deprecated('Use tripDescriptor instead')
const Trip$json = {
  '1': 'Trip',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'start_timestamp', '3': 3, '4': 1, '5': 4, '10': 'startTimestamp'},
    {'1': 'end_timestamp', '3': 4, '4': 1, '5': 4, '10': 'endTimestamp'},
    {'1': 'image_names', '3': 5, '4': 3, '5': 9, '10': 'imageNames'},
    {
      '1': 'catch_ids',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'catchIds'
    },
    {
      '1': 'body_of_water_ids',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'bodyOfWaterIds'
    },
    {
      '1': 'catches_per_fishing_spot',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Trip.CatchesPerEntity',
      '10': 'catchesPerFishingSpot'
    },
    {
      '1': 'catches_per_angler',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Trip.CatchesPerEntity',
      '10': 'catchesPerAngler'
    },
    {
      '1': 'catches_per_species',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Trip.CatchesPerEntity',
      '10': 'catchesPerSpecies'
    },
    {
      '1': 'catches_per_bait',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Trip.CatchesPerBait',
      '10': 'catchesPerBait'
    },
    {
      '1': 'custom_entity_values',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CustomEntityValue',
      '10': 'customEntityValues'
    },
    {'1': 'notes', '3': 13, '4': 1, '5': 9, '10': 'notes'},
    {
      '1': 'atmosphere',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Atmosphere',
      '10': 'atmosphere'
    },
    {'1': 'time_zone', '3': 15, '4': 1, '5': 9, '10': 'timeZone'},
    {
      '1': 'gps_trail_ids',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'gpsTrailIds'
    },
  ],
  '3': [Trip_CatchesPerEntity$json, Trip_CatchesPerBait$json],
};

@$core.Deprecated('Use tripDescriptor instead')
const Trip_CatchesPerEntity$json = {
  '1': 'CatchesPerEntity',
  '2': [
    {
      '1': 'entity_id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'entityId'
    },
    {'1': 'value', '3': 2, '4': 1, '5': 13, '10': 'value'},
  ],
};

@$core.Deprecated('Use tripDescriptor instead')
const Trip_CatchesPerBait$json = {
  '1': 'CatchesPerBait',
  '2': [
    {
      '1': 'attachment',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.BaitAttachment',
      '10': 'attachment'
    },
    {'1': 'value', '3': 2, '4': 1, '5': 13, '10': 'value'},
  ],
};

/// Descriptor for `Trip`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tripDescriptor = $convert.base64Decode(
    'CgRUcmlwEh4KAmlkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFICaWQSEgoEbmFtZRgCIAEoCVIEbm'
    'FtZRInCg9zdGFydF90aW1lc3RhbXAYAyABKARSDnN0YXJ0VGltZXN0YW1wEiMKDWVuZF90aW1l'
    'c3RhbXAYBCABKARSDGVuZFRpbWVzdGFtcBIfCgtpbWFnZV9uYW1lcxgFIAMoCVIKaW1hZ2VOYW'
    '1lcxIrCgljYXRjaF9pZHMYBiADKAsyDi5hbmdsZXJzbG9nLklkUghjYXRjaElkcxI5ChFib2R5'
    'X29mX3dhdGVyX2lkcxgHIAMoCzIOLmFuZ2xlcnNsb2cuSWRSDmJvZHlPZldhdGVySWRzEloKGG'
    'NhdGNoZXNfcGVyX2Zpc2hpbmdfc3BvdBgIIAMoCzIhLmFuZ2xlcnNsb2cuVHJpcC5DYXRjaGVz'
    'UGVyRW50aXR5UhVjYXRjaGVzUGVyRmlzaGluZ1Nwb3QSTwoSY2F0Y2hlc19wZXJfYW5nbGVyGA'
    'kgAygLMiEuYW5nbGVyc2xvZy5UcmlwLkNhdGNoZXNQZXJFbnRpdHlSEGNhdGNoZXNQZXJBbmds'
    'ZXISUQoTY2F0Y2hlc19wZXJfc3BlY2llcxgKIAMoCzIhLmFuZ2xlcnNsb2cuVHJpcC5DYXRjaG'
    'VzUGVyRW50aXR5UhFjYXRjaGVzUGVyU3BlY2llcxJJChBjYXRjaGVzX3Blcl9iYWl0GAsgAygL'
    'Mh8uYW5nbGVyc2xvZy5UcmlwLkNhdGNoZXNQZXJCYWl0Ug5jYXRjaGVzUGVyQmFpdBJPChRjdX'
    'N0b21fZW50aXR5X3ZhbHVlcxgMIAMoCzIdLmFuZ2xlcnNsb2cuQ3VzdG9tRW50aXR5VmFsdWVS'
    'EmN1c3RvbUVudGl0eVZhbHVlcxIUCgVub3RlcxgNIAEoCVIFbm90ZXMSNgoKYXRtb3NwaGVyZR'
    'gOIAEoCzIWLmFuZ2xlcnNsb2cuQXRtb3NwaGVyZVIKYXRtb3NwaGVyZRIbCgl0aW1lX3pvbmUY'
    'DyABKAlSCHRpbWVab25lEjIKDWdwc190cmFpbF9pZHMYECADKAsyDi5hbmdsZXJzbG9nLklkUg'
    'tncHNUcmFpbElkcxpVChBDYXRjaGVzUGVyRW50aXR5EisKCWVudGl0eV9pZBgBIAEoCzIOLmFu'
    'Z2xlcnNsb2cuSWRSCGVudGl0eUlkEhQKBXZhbHVlGAIgASgNUgV2YWx1ZRpiCg5DYXRjaGVzUG'
    'VyQmFpdBI6CgphdHRhY2htZW50GAEgASgLMhouYW5nbGVyc2xvZy5CYWl0QXR0YWNobWVudFIK'
    'YXR0YWNobWVudBIUCgV2YWx1ZRgCIAEoDVIFdmFsdWU=');

@$core.Deprecated('Use measurementDescriptor instead')
const Measurement$json = {
  '1': 'Measurement',
  '2': [
    {
      '1': 'unit',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.Unit',
      '10': 'unit'
    },
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
};

/// Descriptor for `Measurement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List measurementDescriptor = $convert.base64Decode(
    'CgtNZWFzdXJlbWVudBIkCgR1bml0GAEgASgOMhAuYW5nbGVyc2xvZy5Vbml0UgR1bml0EhQKBX'
    'ZhbHVlGAIgASgBUgV2YWx1ZQ==');

@$core.Deprecated('Use multiMeasurementDescriptor instead')
const MultiMeasurement$json = {
  '1': 'MultiMeasurement',
  '2': [
    {
      '1': 'system',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.MeasurementSystem',
      '10': 'system'
    },
    {
      '1': 'main_value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Measurement',
      '10': 'mainValue'
    },
    {
      '1': 'fraction_value',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Measurement',
      '10': 'fractionValue'
    },
    {'1': 'is_negative', '3': 4, '4': 1, '5': 8, '10': 'isNegative'},
  ],
};

/// Descriptor for `MultiMeasurement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List multiMeasurementDescriptor = $convert.base64Decode(
    'ChBNdWx0aU1lYXN1cmVtZW50EjUKBnN5c3RlbRgBIAEoDjIdLmFuZ2xlcnNsb2cuTWVhc3VyZW'
    '1lbnRTeXN0ZW1SBnN5c3RlbRI2CgptYWluX3ZhbHVlGAIgASgLMhcuYW5nbGVyc2xvZy5NZWFz'
    'dXJlbWVudFIJbWFpblZhbHVlEj4KDmZyYWN0aW9uX3ZhbHVlGAMgASgLMhcuYW5nbGVyc2xvZy'
    '5NZWFzdXJlbWVudFINZnJhY3Rpb25WYWx1ZRIfCgtpc19uZWdhdGl2ZRgEIAEoCFIKaXNOZWdh'
    'dGl2ZQ==');

@$core.Deprecated('Use tideDescriptor instead')
const Tide$json = {
  '1': 'Tide',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.TideType',
      '10': 'type'
    },
    {
      '1': 'first_low_timestamp',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'firstLowTimestamp'
    },
    {
      '1': 'first_high_timestamp',
      '3': 3,
      '4': 1,
      '5': 4,
      '10': 'firstHighTimestamp'
    },
    {'1': 'time_zone', '3': 4, '4': 1, '5': 9, '10': 'timeZone'},
    {
      '1': 'height',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Tide.Height',
      '10': 'height'
    },
    {
      '1': 'days_heights',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Tide.Height',
      '10': 'daysHeights'
    },
    {
      '1': 'second_low_timestamp',
      '3': 7,
      '4': 1,
      '5': 4,
      '10': 'secondLowTimestamp'
    },
    {
      '1': 'second_high_timestamp',
      '3': 8,
      '4': 1,
      '5': 4,
      '10': 'secondHighTimestamp'
    },
  ],
  '3': [Tide_Height$json],
};

@$core.Deprecated('Use tideDescriptor instead')
const Tide_Height$json = {
  '1': 'Height',
  '2': [
    {'1': 'timestamp', '3': 1, '4': 1, '5': 4, '10': 'timestamp'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
};

/// Descriptor for `Tide`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tideDescriptor = $convert.base64Decode(
    'CgRUaWRlEigKBHR5cGUYASABKA4yFC5hbmdsZXJzbG9nLlRpZGVUeXBlUgR0eXBlEi4KE2Zpcn'
    'N0X2xvd190aW1lc3RhbXAYAiABKARSEWZpcnN0TG93VGltZXN0YW1wEjAKFGZpcnN0X2hpZ2hf'
    'dGltZXN0YW1wGAMgASgEUhJmaXJzdEhpZ2hUaW1lc3RhbXASGwoJdGltZV96b25lGAQgASgJUg'
    'h0aW1lWm9uZRIvCgZoZWlnaHQYBSABKAsyFy5hbmdsZXJzbG9nLlRpZGUuSGVpZ2h0UgZoZWln'
    'aHQSOgoMZGF5c19oZWlnaHRzGAYgAygLMhcuYW5nbGVyc2xvZy5UaWRlLkhlaWdodFILZGF5c0'
    'hlaWdodHMSMAoUc2Vjb25kX2xvd190aW1lc3RhbXAYByABKARSEnNlY29uZExvd1RpbWVzdGFt'
    'cBIyChVzZWNvbmRfaGlnaF90aW1lc3RhbXAYCCABKARSE3NlY29uZEhpZ2hUaW1lc3RhbXAaPA'
    'oGSGVpZ2h0EhwKCXRpbWVzdGFtcBgBIAEoBFIJdGltZXN0YW1wEhQKBXZhbHVlGAIgASgBUgV2'
    'YWx1ZQ==');

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions$json = {
  '1': 'CatchFilterOptions',
  '2': [
    {
      '1': 'order',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.CatchFilterOptions.Order',
      '10': 'order'
    },
    {
      '1': 'current_timestamp',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'currentTimestamp'
    },
    {'1': 'current_time_zone', '3': 3, '4': 1, '5': 9, '10': 'currentTimeZone'},
    {
      '1': 'all_anglers',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchFilterOptions.AllAnglersEntry',
      '10': 'allAnglers'
    },
    {
      '1': 'all_baits',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchFilterOptions.AllBaitsEntry',
      '10': 'allBaits'
    },
    {
      '1': 'all_bodies_of_water',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchFilterOptions.AllBodiesOfWaterEntry',
      '10': 'allBodiesOfWater'
    },
    {
      '1': 'all_catches',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchFilterOptions.AllCatchesEntry',
      '10': 'allCatches'
    },
    {
      '1': 'all_fishing_spots',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchFilterOptions.AllFishingSpotsEntry',
      '10': 'allFishingSpots'
    },
    {
      '1': 'all_methods',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchFilterOptions.AllMethodsEntry',
      '10': 'allMethods'
    },
    {
      '1': 'all_species',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchFilterOptions.AllSpeciesEntry',
      '10': 'allSpecies'
    },
    {
      '1': 'all_water_clarities',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchFilterOptions.AllWaterClaritiesEntry',
      '10': 'allWaterClarities'
    },
    {
      '1': 'is_catch_and_release_only',
      '3': 12,
      '4': 1,
      '5': 8,
      '10': 'isCatchAndReleaseOnly'
    },
    {
      '1': 'is_favorites_only',
      '3': 13,
      '4': 1,
      '5': 8,
      '10': 'isFavoritesOnly'
    },
    {
      '1': 'date_ranges',
      '3': 14,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.DateRange',
      '10': 'dateRanges'
    },
    {
      '1': 'baits',
      '3': 15,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.BaitAttachment',
      '10': 'baits'
    },
    {
      '1': 'catch_ids',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'catchIds'
    },
    {
      '1': 'angler_ids',
      '3': 17,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'anglerIds'
    },
    {
      '1': 'fishing_spot_ids',
      '3': 18,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'fishingSpotIds'
    },
    {
      '1': 'body_of_water_ids',
      '3': 19,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'bodyOfWaterIds'
    },
    {
      '1': 'method_ids',
      '3': 20,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'methodIds'
    },
    {
      '1': 'species_ids',
      '3': 21,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'speciesIds'
    },
    {
      '1': 'water_clarity_ids',
      '3': 22,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'waterClarityIds'
    },
    {
      '1': 'periods',
      '3': 23,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.Period',
      '10': 'periods'
    },
    {
      '1': 'seasons',
      '3': 24,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.Season',
      '10': 'seasons'
    },
    {
      '1': 'wind_directions',
      '3': 25,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.Direction',
      '10': 'windDirections'
    },
    {
      '1': 'sky_conditions',
      '3': 26,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.SkyCondition',
      '10': 'skyConditions'
    },
    {
      '1': 'moon_phases',
      '3': 27,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.MoonPhase',
      '10': 'moonPhases'
    },
    {
      '1': 'tide_types',
      '3': 28,
      '4': 3,
      '5': 14,
      '6': '.anglerslog.TideType',
      '10': 'tideTypes'
    },
    {
      '1': 'water_depth_filter',
      '3': 29,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'waterDepthFilter'
    },
    {
      '1': 'water_temperature_filter',
      '3': 30,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'waterTemperatureFilter'
    },
    {
      '1': 'length_filter',
      '3': 31,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'lengthFilter'
    },
    {
      '1': 'weight_filter',
      '3': 32,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'weightFilter'
    },
    {
      '1': 'quantity_filter',
      '3': 33,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'quantityFilter'
    },
    {
      '1': 'air_temperature_filter',
      '3': 34,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'airTemperatureFilter'
    },
    {
      '1': 'air_pressure_filter',
      '3': 35,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'airPressureFilter'
    },
    {
      '1': 'air_humidity_filter',
      '3': 36,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'airHumidityFilter'
    },
    {
      '1': 'air_visibility_filter',
      '3': 37,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'airVisibilityFilter'
    },
    {
      '1': 'wind_speed_filter',
      '3': 38,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.NumberFilter',
      '10': 'windSpeedFilter'
    },
    {'1': 'hour', '3': 39, '4': 1, '5': 5, '10': 'hour'},
    {'1': 'month', '3': 40, '4': 1, '5': 5, '10': 'month'},
    {'1': 'include_anglers', '3': 41, '4': 1, '5': 8, '10': 'includeAnglers'},
    {'1': 'include_baits', '3': 42, '4': 1, '5': 8, '10': 'includeBaits'},
    {
      '1': 'include_bodies_of_water',
      '3': 43,
      '4': 1,
      '5': 8,
      '10': 'includeBodiesOfWater'
    },
    {'1': 'include_methods', '3': 44, '4': 1, '5': 8, '10': 'includeMethods'},
    {
      '1': 'include_fishing_spots',
      '3': 45,
      '4': 1,
      '5': 8,
      '10': 'includeFishingSpots'
    },
    {
      '1': 'include_moon_phases',
      '3': 46,
      '4': 1,
      '5': 8,
      '10': 'includeMoonPhases'
    },
    {'1': 'include_seasons', '3': 47, '4': 1, '5': 8, '10': 'includeSeasons'},
    {'1': 'include_species', '3': 48, '4': 1, '5': 8, '10': 'includeSpecies'},
    {
      '1': 'include_tide_types',
      '3': 49,
      '4': 1,
      '5': 8,
      '10': 'includeTideTypes'
    },
    {'1': 'include_periods', '3': 50, '4': 1, '5': 8, '10': 'includePeriods'},
    {
      '1': 'include_water_clarities',
      '3': 51,
      '4': 1,
      '5': 8,
      '10': 'includeWaterClarities'
    },
    {
      '1': 'all_gear',
      '3': 52,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchFilterOptions.AllGearEntry',
      '10': 'allGear'
    },
    {
      '1': 'gear_ids',
      '3': 53,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'gearIds'
    },
    {'1': 'include_gear', '3': 54, '4': 1, '5': 8, '10': 'includeGear'},
  ],
  '3': [
    CatchFilterOptions_AllAnglersEntry$json,
    CatchFilterOptions_AllBaitsEntry$json,
    CatchFilterOptions_AllBodiesOfWaterEntry$json,
    CatchFilterOptions_AllCatchesEntry$json,
    CatchFilterOptions_AllFishingSpotsEntry$json,
    CatchFilterOptions_AllMethodsEntry$json,
    CatchFilterOptions_AllSpeciesEntry$json,
    CatchFilterOptions_AllWaterClaritiesEntry$json,
    CatchFilterOptions_AllGearEntry$json
  ],
  '4': [CatchFilterOptions_Order$json],
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_AllAnglersEntry$json = {
  '1': 'AllAnglersEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Angler',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_AllBaitsEntry$json = {
  '1': 'AllBaitsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Bait',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_AllBodiesOfWaterEntry$json = {
  '1': 'AllBodiesOfWaterEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.BodyOfWater',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_AllCatchesEntry$json = {
  '1': 'AllCatchesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Catch',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_AllFishingSpotsEntry$json = {
  '1': 'AllFishingSpotsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.FishingSpot',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_AllMethodsEntry$json = {
  '1': 'AllMethodsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Method',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_AllSpeciesEntry$json = {
  '1': 'AllSpeciesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Species',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_AllWaterClaritiesEntry$json = {
  '1': 'AllWaterClaritiesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.WaterClarity',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_AllGearEntry$json = {
  '1': 'AllGearEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Gear',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions_Order$json = {
  '1': 'Order',
  '2': [
    {'1': 'unknown', '2': 0},
    {'1': 'newest_to_oldest', '2': 1},
    {'1': 'heaviest_to_lightest', '2': 2},
    {'1': 'longest_to_shortest', '2': 3},
  ],
};

/// Descriptor for `CatchFilterOptions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catchFilterOptionsDescriptor = $convert.base64Decode(
    'ChJDYXRjaEZpbHRlck9wdGlvbnMSOgoFb3JkZXIYASABKA4yJC5hbmdsZXJzbG9nLkNhdGNoRm'
    'lsdGVyT3B0aW9ucy5PcmRlclIFb3JkZXISKwoRY3VycmVudF90aW1lc3RhbXAYAiABKARSEGN1'
    'cnJlbnRUaW1lc3RhbXASKgoRY3VycmVudF90aW1lX3pvbmUYAyABKAlSD2N1cnJlbnRUaW1lWm'
    '9uZRJPCgthbGxfYW5nbGVycxgEIAMoCzIuLmFuZ2xlcnNsb2cuQ2F0Y2hGaWx0ZXJPcHRpb25z'
    'LkFsbEFuZ2xlcnNFbnRyeVIKYWxsQW5nbGVycxJJCglhbGxfYmFpdHMYBSADKAsyLC5hbmdsZX'
    'JzbG9nLkNhdGNoRmlsdGVyT3B0aW9ucy5BbGxCYWl0c0VudHJ5UghhbGxCYWl0cxJjChNhbGxf'
    'Ym9kaWVzX29mX3dhdGVyGAYgAygLMjQuYW5nbGVyc2xvZy5DYXRjaEZpbHRlck9wdGlvbnMuQW'
    'xsQm9kaWVzT2ZXYXRlckVudHJ5UhBhbGxCb2RpZXNPZldhdGVyEk8KC2FsbF9jYXRjaGVzGAcg'
    'AygLMi4uYW5nbGVyc2xvZy5DYXRjaEZpbHRlck9wdGlvbnMuQWxsQ2F0Y2hlc0VudHJ5UgphbG'
    'xDYXRjaGVzEl8KEWFsbF9maXNoaW5nX3Nwb3RzGAggAygLMjMuYW5nbGVyc2xvZy5DYXRjaEZp'
    'bHRlck9wdGlvbnMuQWxsRmlzaGluZ1Nwb3RzRW50cnlSD2FsbEZpc2hpbmdTcG90cxJPCgthbG'
    'xfbWV0aG9kcxgJIAMoCzIuLmFuZ2xlcnNsb2cuQ2F0Y2hGaWx0ZXJPcHRpb25zLkFsbE1ldGhv'
    'ZHNFbnRyeVIKYWxsTWV0aG9kcxJPCgthbGxfc3BlY2llcxgKIAMoCzIuLmFuZ2xlcnNsb2cuQ2'
    'F0Y2hGaWx0ZXJPcHRpb25zLkFsbFNwZWNpZXNFbnRyeVIKYWxsU3BlY2llcxJlChNhbGxfd2F0'
    'ZXJfY2xhcml0aWVzGAsgAygLMjUuYW5nbGVyc2xvZy5DYXRjaEZpbHRlck9wdGlvbnMuQWxsV2'
    'F0ZXJDbGFyaXRpZXNFbnRyeVIRYWxsV2F0ZXJDbGFyaXRpZXMSOAoZaXNfY2F0Y2hfYW5kX3Jl'
    'bGVhc2Vfb25seRgMIAEoCFIVaXNDYXRjaEFuZFJlbGVhc2VPbmx5EioKEWlzX2Zhdm9yaXRlc1'
    '9vbmx5GA0gASgIUg9pc0Zhdm9yaXRlc09ubHkSNgoLZGF0ZV9yYW5nZXMYDiADKAsyFS5hbmds'
    'ZXJzbG9nLkRhdGVSYW5nZVIKZGF0ZVJhbmdlcxIwCgViYWl0cxgPIAMoCzIaLmFuZ2xlcnNsb2'
    'cuQmFpdEF0dGFjaG1lbnRSBWJhaXRzEisKCWNhdGNoX2lkcxgQIAMoCzIOLmFuZ2xlcnNsb2cu'
    'SWRSCGNhdGNoSWRzEi0KCmFuZ2xlcl9pZHMYESADKAsyDi5hbmdsZXJzbG9nLklkUglhbmdsZX'
    'JJZHMSOAoQZmlzaGluZ19zcG90X2lkcxgSIAMoCzIOLmFuZ2xlcnNsb2cuSWRSDmZpc2hpbmdT'
    'cG90SWRzEjkKEWJvZHlfb2Zfd2F0ZXJfaWRzGBMgAygLMg4uYW5nbGVyc2xvZy5JZFIOYm9keU'
    '9mV2F0ZXJJZHMSLQoKbWV0aG9kX2lkcxgUIAMoCzIOLmFuZ2xlcnNsb2cuSWRSCW1ldGhvZElk'
    'cxIvCgtzcGVjaWVzX2lkcxgVIAMoCzIOLmFuZ2xlcnNsb2cuSWRSCnNwZWNpZXNJZHMSOgoRd2'
    'F0ZXJfY2xhcml0eV9pZHMYFiADKAsyDi5hbmdsZXJzbG9nLklkUg93YXRlckNsYXJpdHlJZHMS'
    'LAoHcGVyaW9kcxgXIAMoDjISLmFuZ2xlcnNsb2cuUGVyaW9kUgdwZXJpb2RzEiwKB3NlYXNvbn'
    'MYGCADKA4yEi5hbmdsZXJzbG9nLlNlYXNvblIHc2Vhc29ucxI+Cg93aW5kX2RpcmVjdGlvbnMY'
    'GSADKA4yFS5hbmdsZXJzbG9nLkRpcmVjdGlvblIOd2luZERpcmVjdGlvbnMSPwoOc2t5X2Nvbm'
    'RpdGlvbnMYGiADKA4yGC5hbmdsZXJzbG9nLlNreUNvbmRpdGlvblINc2t5Q29uZGl0aW9ucxI2'
    'Cgttb29uX3BoYXNlcxgbIAMoDjIVLmFuZ2xlcnNsb2cuTW9vblBoYXNlUgptb29uUGhhc2VzEj'
    'MKCnRpZGVfdHlwZXMYHCADKA4yFC5hbmdsZXJzbG9nLlRpZGVUeXBlUgl0aWRlVHlwZXMSRgoS'
    'd2F0ZXJfZGVwdGhfZmlsdGVyGB0gASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSEHdhdG'
    'VyRGVwdGhGaWx0ZXISUgoYd2F0ZXJfdGVtcGVyYXR1cmVfZmlsdGVyGB4gASgLMhguYW5nbGVy'
    'c2xvZy5OdW1iZXJGaWx0ZXJSFndhdGVyVGVtcGVyYXR1cmVGaWx0ZXISPQoNbGVuZ3RoX2ZpbH'
    'RlchgfIAEoCzIYLmFuZ2xlcnNsb2cuTnVtYmVyRmlsdGVyUgxsZW5ndGhGaWx0ZXISPQoNd2Vp'
    'Z2h0X2ZpbHRlchggIAEoCzIYLmFuZ2xlcnNsb2cuTnVtYmVyRmlsdGVyUgx3ZWlnaHRGaWx0ZX'
    'ISQQoPcXVhbnRpdHlfZmlsdGVyGCEgASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSDnF1'
    'YW50aXR5RmlsdGVyEk4KFmFpcl90ZW1wZXJhdHVyZV9maWx0ZXIYIiABKAsyGC5hbmdsZXJzbG'
    '9nLk51bWJlckZpbHRlclIUYWlyVGVtcGVyYXR1cmVGaWx0ZXISSAoTYWlyX3ByZXNzdXJlX2Zp'
    'bHRlchgjIAEoCzIYLmFuZ2xlcnNsb2cuTnVtYmVyRmlsdGVyUhFhaXJQcmVzc3VyZUZpbHRlch'
    'JIChNhaXJfaHVtaWRpdHlfZmlsdGVyGCQgASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJS'
    'EWFpckh1bWlkaXR5RmlsdGVyEkwKFWFpcl92aXNpYmlsaXR5X2ZpbHRlchglIAEoCzIYLmFuZ2'
    'xlcnNsb2cuTnVtYmVyRmlsdGVyUhNhaXJWaXNpYmlsaXR5RmlsdGVyEkQKEXdpbmRfc3BlZWRf'
    'ZmlsdGVyGCYgASgLMhguYW5nbGVyc2xvZy5OdW1iZXJGaWx0ZXJSD3dpbmRTcGVlZEZpbHRlch'
    'ISCgRob3VyGCcgASgFUgRob3VyEhQKBW1vbnRoGCggASgFUgVtb250aBInCg9pbmNsdWRlX2Fu'
    'Z2xlcnMYKSABKAhSDmluY2x1ZGVBbmdsZXJzEiMKDWluY2x1ZGVfYmFpdHMYKiABKAhSDGluY2'
    'x1ZGVCYWl0cxI1ChdpbmNsdWRlX2JvZGllc19vZl93YXRlchgrIAEoCFIUaW5jbHVkZUJvZGll'
    'c09mV2F0ZXISJwoPaW5jbHVkZV9tZXRob2RzGCwgASgIUg5pbmNsdWRlTWV0aG9kcxIyChVpbm'
    'NsdWRlX2Zpc2hpbmdfc3BvdHMYLSABKAhSE2luY2x1ZGVGaXNoaW5nU3BvdHMSLgoTaW5jbHVk'
    'ZV9tb29uX3BoYXNlcxguIAEoCFIRaW5jbHVkZU1vb25QaGFzZXMSJwoPaW5jbHVkZV9zZWFzb2'
    '5zGC8gASgIUg5pbmNsdWRlU2Vhc29ucxInCg9pbmNsdWRlX3NwZWNpZXMYMCABKAhSDmluY2x1'
    'ZGVTcGVjaWVzEiwKEmluY2x1ZGVfdGlkZV90eXBlcxgxIAEoCFIQaW5jbHVkZVRpZGVUeXBlcx'
    'InCg9pbmNsdWRlX3BlcmlvZHMYMiABKAhSDmluY2x1ZGVQZXJpb2RzEjYKF2luY2x1ZGVfd2F0'
    'ZXJfY2xhcml0aWVzGDMgASgIUhVpbmNsdWRlV2F0ZXJDbGFyaXRpZXMSRgoIYWxsX2dlYXIYNC'
    'ADKAsyKy5hbmdsZXJzbG9nLkNhdGNoRmlsdGVyT3B0aW9ucy5BbGxHZWFyRW50cnlSB2FsbEdl'
    'YXISKQoIZ2Vhcl9pZHMYNSADKAsyDi5hbmdsZXJzbG9nLklkUgdnZWFySWRzEiEKDGluY2x1ZG'
    'VfZ2Vhchg2IAEoCFILaW5jbHVkZUdlYXIaUQoPQWxsQW5nbGVyc0VudHJ5EhAKA2tleRgBIAEo'
    'CVIDa2V5EigKBXZhbHVlGAIgASgLMhIuYW5nbGVyc2xvZy5BbmdsZXJSBXZhbHVlOgI4ARpNCg'
    '1BbGxCYWl0c0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EiYKBXZhbHVlGAIgASgLMhAuYW5nbGVy'
    'c2xvZy5CYWl0UgV2YWx1ZToCOAEaXAoVQWxsQm9kaWVzT2ZXYXRlckVudHJ5EhAKA2tleRgBIA'
    'EoCVIDa2V5Ei0KBXZhbHVlGAIgASgLMhcuYW5nbGVyc2xvZy5Cb2R5T2ZXYXRlclIFdmFsdWU6'
    'AjgBGlAKD0FsbENhdGNoZXNFbnRyeRIQCgNrZXkYASABKAlSA2tleRInCgV2YWx1ZRgCIAEoCz'
    'IRLmFuZ2xlcnNsb2cuQ2F0Y2hSBXZhbHVlOgI4ARpbChRBbGxGaXNoaW5nU3BvdHNFbnRyeRIQ'
    'CgNrZXkYASABKAlSA2tleRItCgV2YWx1ZRgCIAEoCzIXLmFuZ2xlcnNsb2cuRmlzaGluZ1Nwb3'
    'RSBXZhbHVlOgI4ARpRCg9BbGxNZXRob2RzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSKAoFdmFs'
    'dWUYAiABKAsyEi5hbmdsZXJzbG9nLk1ldGhvZFIFdmFsdWU6AjgBGlIKD0FsbFNwZWNpZXNFbn'
    'RyeRIQCgNrZXkYASABKAlSA2tleRIpCgV2YWx1ZRgCIAEoCzITLmFuZ2xlcnNsb2cuU3BlY2ll'
    'c1IFdmFsdWU6AjgBGl4KFkFsbFdhdGVyQ2xhcml0aWVzRW50cnkSEAoDa2V5GAEgASgJUgNrZX'
    'kSLgoFdmFsdWUYAiABKAsyGC5hbmdsZXJzbG9nLldhdGVyQ2xhcml0eVIFdmFsdWU6AjgBGkwK'
    'DEFsbEdlYXJFbnRyeRIQCgNrZXkYASABKAlSA2tleRImCgV2YWx1ZRgCIAEoCzIQLmFuZ2xlcn'
    'Nsb2cuR2VhclIFdmFsdWU6AjgBIl0KBU9yZGVyEgsKB3Vua25vd24QABIUChBuZXdlc3RfdG9f'
    'b2xkZXN0EAESGAoUaGVhdmllc3RfdG9fbGlnaHRlc3QQAhIXChNsb25nZXN0X3RvX3Nob3J0ZX'
    'N0EAM=');

@$core.Deprecated('Use catchReportDescriptor instead')
const CatchReport$json = {
  '1': 'CatchReport',
  '2': [
    {
      '1': 'models',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel',
      '10': 'models'
    },
    {
      '1': 'ms_since_last_catch',
      '3': 2,
      '4': 1,
      '5': 4,
      '10': 'msSinceLastCatch'
    },
    {
      '1': 'last_catch',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Catch',
      '10': 'lastCatch'
    },
    {'1': 'contains_now', '3': 6, '4': 1, '5': 8, '10': 'containsNow'},
  ],
};

/// Descriptor for `CatchReport`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catchReportDescriptor = $convert.base64Decode(
    'CgtDYXRjaFJlcG9ydBI0CgZtb2RlbHMYASADKAsyHC5hbmdsZXJzbG9nLkNhdGNoUmVwb3J0TW'
    '9kZWxSBm1vZGVscxItChNtc19zaW5jZV9sYXN0X2NhdGNoGAIgASgEUhBtc1NpbmNlTGFzdENh'
    'dGNoEjAKCmxhc3RfY2F0Y2gYAyABKAsyES5hbmdsZXJzbG9nLkNhdGNoUglsYXN0Q2F0Y2gSIQ'
    'oMY29udGFpbnNfbm93GAYgASgIUgtjb250YWluc05vdw==');

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel$json = {
  '1': 'CatchReportModel',
  '2': [
    {
      '1': 'date_range',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.DateRange',
      '10': 'dateRange'
    },
    {
      '1': 'catch_ids',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'catchIds'
    },
    {
      '1': 'per_hour',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerHourEntry',
      '10': 'perHour'
    },
    {
      '1': 'per_month',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerMonthEntry',
      '10': 'perMonth'
    },
    {
      '1': 'per_moon_phase',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerMoonPhaseEntry',
      '10': 'perMoonPhase'
    },
    {
      '1': 'per_period',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerPeriodEntry',
      '10': 'perPeriod'
    },
    {
      '1': 'per_season',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerSeasonEntry',
      '10': 'perSeason'
    },
    {
      '1': 'per_tide_type',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerTideTypeEntry',
      '10': 'perTideType'
    },
    {
      '1': 'per_angler',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerAnglerEntry',
      '10': 'perAngler'
    },
    {
      '1': 'per_body_of_water',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerBodyOfWaterEntry',
      '10': 'perBodyOfWater'
    },
    {
      '1': 'per_method',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerMethodEntry',
      '10': 'perMethod'
    },
    {
      '1': 'per_fishing_spot',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerFishingSpotEntry',
      '10': 'perFishingSpot'
    },
    {
      '1': 'per_species',
      '3': 13,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerSpeciesEntry',
      '10': 'perSpecies'
    },
    {
      '1': 'per_water_clarity',
      '3': 14,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerWaterClarityEntry',
      '10': 'perWaterClarity'
    },
    {
      '1': 'per_bait',
      '3': 15,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerBaitEntry',
      '10': 'perBait'
    },
    {
      '1': 'per_gear',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CatchReportModel.PerGearEntry',
      '10': 'perGear'
    },
  ],
  '3': [
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
    CatchReportModel_PerBaitEntry$json,
    CatchReportModel_PerGearEntry$json
  ],
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerHourEntry$json = {
  '1': 'PerHourEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerMonthEntry$json = {
  '1': 'PerMonthEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerMoonPhaseEntry$json = {
  '1': 'PerMoonPhaseEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerPeriodEntry$json = {
  '1': 'PerPeriodEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerSeasonEntry$json = {
  '1': 'PerSeasonEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerTideTypeEntry$json = {
  '1': 'PerTideTypeEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 5, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerAnglerEntry$json = {
  '1': 'PerAnglerEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerBodyOfWaterEntry$json = {
  '1': 'PerBodyOfWaterEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerMethodEntry$json = {
  '1': 'PerMethodEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerFishingSpotEntry$json = {
  '1': 'PerFishingSpotEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerSpeciesEntry$json = {
  '1': 'PerSpeciesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerWaterClarityEntry$json = {
  '1': 'PerWaterClarityEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerBaitEntry$json = {
  '1': 'PerBaitEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel_PerGearEntry$json = {
  '1': 'PerGearEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 5, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `CatchReportModel`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catchReportModelDescriptor = $convert.base64Decode(
    'ChBDYXRjaFJlcG9ydE1vZGVsEjQKCmRhdGVfcmFuZ2UYASABKAsyFS5hbmdsZXJzbG9nLkRhdG'
    'VSYW5nZVIJZGF0ZVJhbmdlEisKCWNhdGNoX2lkcxgCIAMoCzIOLmFuZ2xlcnNsb2cuSWRSCGNh'
    'dGNoSWRzEkQKCHBlcl9ob3VyGAMgAygLMikuYW5nbGVyc2xvZy5DYXRjaFJlcG9ydE1vZGVsLl'
    'BlckhvdXJFbnRyeVIHcGVySG91chJHCglwZXJfbW9udGgYBCADKAsyKi5hbmdsZXJzbG9nLkNh'
    'dGNoUmVwb3J0TW9kZWwuUGVyTW9udGhFbnRyeVIIcGVyTW9udGgSVAoOcGVyX21vb25fcGhhc2'
    'UYBSADKAsyLi5hbmdsZXJzbG9nLkNhdGNoUmVwb3J0TW9kZWwuUGVyTW9vblBoYXNlRW50cnlS'
    'DHBlck1vb25QaGFzZRJKCgpwZXJfcGVyaW9kGAYgAygLMisuYW5nbGVyc2xvZy5DYXRjaFJlcG'
    '9ydE1vZGVsLlBlclBlcmlvZEVudHJ5UglwZXJQZXJpb2QSSgoKcGVyX3NlYXNvbhgHIAMoCzIr'
    'LmFuZ2xlcnNsb2cuQ2F0Y2hSZXBvcnRNb2RlbC5QZXJTZWFzb25FbnRyeVIJcGVyU2Vhc29uEl'
    'EKDXBlcl90aWRlX3R5cGUYCCADKAsyLS5hbmdsZXJzbG9nLkNhdGNoUmVwb3J0TW9kZWwuUGVy'
    'VGlkZVR5cGVFbnRyeVILcGVyVGlkZVR5cGUSSgoKcGVyX2FuZ2xlchgJIAMoCzIrLmFuZ2xlcn'
    'Nsb2cuQ2F0Y2hSZXBvcnRNb2RlbC5QZXJBbmdsZXJFbnRyeVIJcGVyQW5nbGVyElsKEXBlcl9i'
    'b2R5X29mX3dhdGVyGAogAygLMjAuYW5nbGVyc2xvZy5DYXRjaFJlcG9ydE1vZGVsLlBlckJvZH'
    'lPZldhdGVyRW50cnlSDnBlckJvZHlPZldhdGVyEkoKCnBlcl9tZXRob2QYCyADKAsyKy5hbmds'
    'ZXJzbG9nLkNhdGNoUmVwb3J0TW9kZWwuUGVyTWV0aG9kRW50cnlSCXBlck1ldGhvZBJaChBwZX'
    'JfZmlzaGluZ19zcG90GAwgAygLMjAuYW5nbGVyc2xvZy5DYXRjaFJlcG9ydE1vZGVsLlBlckZp'
    'c2hpbmdTcG90RW50cnlSDnBlckZpc2hpbmdTcG90Ek0KC3Blcl9zcGVjaWVzGA0gAygLMiwuYW'
    '5nbGVyc2xvZy5DYXRjaFJlcG9ydE1vZGVsLlBlclNwZWNpZXNFbnRyeVIKcGVyU3BlY2llcxJd'
    'ChFwZXJfd2F0ZXJfY2xhcml0eRgOIAMoCzIxLmFuZ2xlcnNsb2cuQ2F0Y2hSZXBvcnRNb2RlbC'
    '5QZXJXYXRlckNsYXJpdHlFbnRyeVIPcGVyV2F0ZXJDbGFyaXR5EkQKCHBlcl9iYWl0GA8gAygL'
    'MikuYW5nbGVyc2xvZy5DYXRjaFJlcG9ydE1vZGVsLlBlckJhaXRFbnRyeVIHcGVyQmFpdBJECg'
    'hwZXJfZ2VhchgQIAMoCzIpLmFuZ2xlcnNsb2cuQ2F0Y2hSZXBvcnRNb2RlbC5QZXJHZWFyRW50'
    'cnlSB3BlckdlYXIaOgoMUGVySG91ckVudHJ5EhAKA2tleRgBIAEoBVIDa2V5EhQKBXZhbHVlGA'
    'IgASgFUgV2YWx1ZToCOAEaOwoNUGVyTW9udGhFbnRyeRIQCgNrZXkYASABKAVSA2tleRIUCgV2'
    'YWx1ZRgCIAEoBVIFdmFsdWU6AjgBGj8KEVBlck1vb25QaGFzZUVudHJ5EhAKA2tleRgBIAEoBV'
    'IDa2V5EhQKBXZhbHVlGAIgASgFUgV2YWx1ZToCOAEaPAoOUGVyUGVyaW9kRW50cnkSEAoDa2V5'
    'GAEgASgFUgNrZXkSFAoFdmFsdWUYAiABKAVSBXZhbHVlOgI4ARo8Cg5QZXJTZWFzb25FbnRyeR'
    'IQCgNrZXkYASABKAVSA2tleRIUCgV2YWx1ZRgCIAEoBVIFdmFsdWU6AjgBGj4KEFBlclRpZGVU'
    'eXBlRW50cnkSEAoDa2V5GAEgASgFUgNrZXkSFAoFdmFsdWUYAiABKAVSBXZhbHVlOgI4ARo8Cg'
    '5QZXJBbmdsZXJFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoBVIFdmFsdWU6'
    'AjgBGkEKE1BlckJvZHlPZldhdGVyRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAi'
    'ABKAVSBXZhbHVlOgI4ARo8Cg5QZXJNZXRob2RFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2'
    'YWx1ZRgCIAEoBVIFdmFsdWU6AjgBGkEKE1BlckZpc2hpbmdTcG90RW50cnkSEAoDa2V5GAEgAS'
    'gJUgNrZXkSFAoFdmFsdWUYAiABKAVSBXZhbHVlOgI4ARo9Cg9QZXJTcGVjaWVzRW50cnkSEAoD'
    'a2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAVSBXZhbHVlOgI4ARpCChRQZXJXYXRlckNsYX'
    'JpdHlFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoBVIFdmFsdWU6AjgBGjoK'
    'DFBlckJhaXRFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoBVIFdmFsdWU6Aj'
    'gBGjoKDFBlckdlYXJFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoBVIFdmFs'
    'dWU6AjgB');

@$core.Deprecated('Use tripFilterOptionsDescriptor instead')
const TripFilterOptions$json = {
  '1': 'TripFilterOptions',
  '2': [
    {
      '1': 'current_timestamp',
      '3': 1,
      '4': 1,
      '5': 4,
      '10': 'currentTimestamp'
    },
    {'1': 'current_time_zone', '3': 2, '4': 1, '5': 9, '10': 'currentTimeZone'},
    {
      '1': 'all_catches',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.TripFilterOptions.AllCatchesEntry',
      '10': 'allCatches'
    },
    {
      '1': 'all_trips',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.TripFilterOptions.AllTripsEntry',
      '10': 'allTrips'
    },
    {
      '1': 'catch_weight_system',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.MeasurementSystem',
      '10': 'catchWeightSystem'
    },
    {
      '1': 'catch_length_system',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.MeasurementSystem',
      '10': 'catchLengthSystem'
    },
    {
      '1': 'date_range',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.DateRange',
      '10': 'dateRange'
    },
    {
      '1': 'trip_ids',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Id',
      '10': 'tripIds'
    },
  ],
  '3': [
    TripFilterOptions_AllCatchesEntry$json,
    TripFilterOptions_AllTripsEntry$json
  ],
};

@$core.Deprecated('Use tripFilterOptionsDescriptor instead')
const TripFilterOptions_AllCatchesEntry$json = {
  '1': 'AllCatchesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Catch',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use tripFilterOptionsDescriptor instead')
const TripFilterOptions_AllTripsEntry$json = {
  '1': 'AllTripsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {
      '1': 'value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Trip',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `TripFilterOptions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tripFilterOptionsDescriptor = $convert.base64Decode(
    'ChFUcmlwRmlsdGVyT3B0aW9ucxIrChFjdXJyZW50X3RpbWVzdGFtcBgBIAEoBFIQY3VycmVudF'
    'RpbWVzdGFtcBIqChFjdXJyZW50X3RpbWVfem9uZRgCIAEoCVIPY3VycmVudFRpbWVab25lEk4K'
    'C2FsbF9jYXRjaGVzGAMgAygLMi0uYW5nbGVyc2xvZy5UcmlwRmlsdGVyT3B0aW9ucy5BbGxDYX'
    'RjaGVzRW50cnlSCmFsbENhdGNoZXMSSAoJYWxsX3RyaXBzGAQgAygLMisuYW5nbGVyc2xvZy5U'
    'cmlwRmlsdGVyT3B0aW9ucy5BbGxUcmlwc0VudHJ5UghhbGxUcmlwcxJNChNjYXRjaF93ZWlnaH'
    'Rfc3lzdGVtGAUgASgOMh0uYW5nbGVyc2xvZy5NZWFzdXJlbWVudFN5c3RlbVIRY2F0Y2hXZWln'
    'aHRTeXN0ZW0STQoTY2F0Y2hfbGVuZ3RoX3N5c3RlbRgGIAEoDjIdLmFuZ2xlcnNsb2cuTWVhc3'
    'VyZW1lbnRTeXN0ZW1SEWNhdGNoTGVuZ3RoU3lzdGVtEjQKCmRhdGVfcmFuZ2UYByABKAsyFS5h'
    'bmdsZXJzbG9nLkRhdGVSYW5nZVIJZGF0ZVJhbmdlEikKCHRyaXBfaWRzGAggAygLMg4uYW5nbG'
    'Vyc2xvZy5JZFIHdHJpcElkcxpQCg9BbGxDYXRjaGVzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkS'
    'JwoFdmFsdWUYAiABKAsyES5hbmdsZXJzbG9nLkNhdGNoUgV2YWx1ZToCOAEaTQoNQWxsVHJpcH'
    'NFbnRyeRIQCgNrZXkYASABKAlSA2tleRImCgV2YWx1ZRgCIAEoCzIQLmFuZ2xlcnNsb2cuVHJp'
    'cFIFdmFsdWU6AjgB');

@$core.Deprecated('Use tripReportDescriptor instead')
const TripReport$json = {
  '1': 'TripReport',
  '2': [
    {
      '1': 'date_range',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.DateRange',
      '10': 'dateRange'
    },
    {
      '1': 'trips',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.Trip',
      '10': 'trips'
    },
    {'1': 'total_ms', '3': 3, '4': 1, '5': 4, '10': 'totalMs'},
    {
      '1': 'longest_trip',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Trip',
      '10': 'longestTrip'
    },
    {
      '1': 'last_trip',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Trip',
      '10': 'lastTrip'
    },
    {
      '1': 'ms_since_last_trip',
      '3': 6,
      '4': 1,
      '5': 4,
      '10': 'msSinceLastTrip'
    },
    {'1': 'containsNow', '3': 7, '4': 1, '5': 8, '10': 'containsNow'},
    {
      '1': 'average_catches_per_trip',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'averageCatchesPerTrip'
    },
    {
      '1': 'average_catches_per_hour',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'averageCatchesPerHour'
    },
    {
      '1': 'average_ms_between_catches',
      '3': 10,
      '4': 1,
      '5': 4,
      '10': 'averageMsBetweenCatches'
    },
    {'1': 'average_trip_ms', '3': 11, '4': 1, '5': 4, '10': 'averageTripMs'},
    {
      '1': 'average_ms_between_trips',
      '3': 12,
      '4': 1,
      '5': 4,
      '10': 'averageMsBetweenTrips'
    },
    {
      '1': 'average_weight_per_trip',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'averageWeightPerTrip'
    },
    {
      '1': 'most_weight_in_single_trip',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'mostWeightInSingleTrip'
    },
    {
      '1': 'most_weight_trip',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.Trip',
      '10': 'mostWeightTrip'
    },
    {
      '1': 'average_length_per_trip',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'averageLengthPerTrip'
    },
    {
      '1': 'most_length_in_single_trip',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'mostLengthInSingleTrip'
    },
    {
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
    'CgpUcmlwUmVwb3J0EjQKCmRhdGVfcmFuZ2UYASABKAsyFS5hbmdsZXJzbG9nLkRhdGVSYW5nZV'
    'IJZGF0ZVJhbmdlEiYKBXRyaXBzGAIgAygLMhAuYW5nbGVyc2xvZy5UcmlwUgV0cmlwcxIZCgh0'
    'b3RhbF9tcxgDIAEoBFIHdG90YWxNcxIzCgxsb25nZXN0X3RyaXAYBCABKAsyEC5hbmdsZXJzbG'
    '9nLlRyaXBSC2xvbmdlc3RUcmlwEi0KCWxhc3RfdHJpcBgFIAEoCzIQLmFuZ2xlcnNsb2cuVHJp'
    'cFIIbGFzdFRyaXASKwoSbXNfc2luY2VfbGFzdF90cmlwGAYgASgEUg9tc1NpbmNlTGFzdFRyaX'
    'ASIAoLY29udGFpbnNOb3cYByABKAhSC2NvbnRhaW5zTm93EjcKGGF2ZXJhZ2VfY2F0Y2hlc19w'
    'ZXJfdHJpcBgIIAEoAVIVYXZlcmFnZUNhdGNoZXNQZXJUcmlwEjcKGGF2ZXJhZ2VfY2F0Y2hlc1'
    '9wZXJfaG91chgJIAEoAVIVYXZlcmFnZUNhdGNoZXNQZXJIb3VyEjsKGmF2ZXJhZ2VfbXNfYmV0'
    'd2Vlbl9jYXRjaGVzGAogASgEUhdhdmVyYWdlTXNCZXR3ZWVuQ2F0Y2hlcxImCg9hdmVyYWdlX3'
    'RyaXBfbXMYCyABKARSDWF2ZXJhZ2VUcmlwTXMSNwoYYXZlcmFnZV9tc19iZXR3ZWVuX3RyaXBz'
    'GAwgASgEUhVhdmVyYWdlTXNCZXR3ZWVuVHJpcHMSUwoXYXZlcmFnZV93ZWlnaHRfcGVyX3RyaX'
    'AYDSABKAsyHC5hbmdsZXJzbG9nLk11bHRpTWVhc3VyZW1lbnRSFGF2ZXJhZ2VXZWlnaHRQZXJU'
    'cmlwElgKGm1vc3Rfd2VpZ2h0X2luX3NpbmdsZV90cmlwGA4gASgLMhwuYW5nbGVyc2xvZy5NdW'
    'x0aU1lYXN1cmVtZW50UhZtb3N0V2VpZ2h0SW5TaW5nbGVUcmlwEjoKEG1vc3Rfd2VpZ2h0X3Ry'
    'aXAYDyABKAsyEC5hbmdsZXJzbG9nLlRyaXBSDm1vc3RXZWlnaHRUcmlwElMKF2F2ZXJhZ2VfbG'
    'VuZ3RoX3Blcl90cmlwGBAgASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50UhRhdmVy'
    'YWdlTGVuZ3RoUGVyVHJpcBJYChptb3N0X2xlbmd0aF9pbl9zaW5nbGVfdHJpcBgRIAEoCzIcLm'
    'FuZ2xlcnNsb2cuTXVsdGlNZWFzdXJlbWVudFIWbW9zdExlbmd0aEluU2luZ2xlVHJpcBI6ChBt'
    'b3N0X2xlbmd0aF90cmlwGBIgASgLMhAuYW5nbGVyc2xvZy5UcmlwUg5tb3N0TGVuZ3RoVHJpcA'
    '==');

@$core.Deprecated('Use gpsTrailPointDescriptor instead')
const GpsTrailPoint$json = {
  '1': 'GpsTrailPoint',
  '2': [
    {'1': 'timestamp', '3': 1, '4': 1, '5': 4, '10': 'timestamp'},
    {'1': 'lat', '3': 2, '4': 1, '5': 1, '10': 'lat'},
    {'1': 'lng', '3': 3, '4': 1, '5': 1, '10': 'lng'},
    {'1': 'heading', '3': 4, '4': 1, '5': 1, '10': 'heading'},
  ],
};

/// Descriptor for `GpsTrailPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gpsTrailPointDescriptor = $convert.base64Decode(
    'Cg1HcHNUcmFpbFBvaW50EhwKCXRpbWVzdGFtcBgBIAEoBFIJdGltZXN0YW1wEhAKA2xhdBgCIA'
    'EoAVIDbGF0EhAKA2xuZxgDIAEoAVIDbG5nEhgKB2hlYWRpbmcYBCABKAFSB2hlYWRpbmc=');

@$core.Deprecated('Use gpsTrailDescriptor instead')
const GpsTrail$json = {
  '1': 'GpsTrail',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    {'1': 'start_timestamp', '3': 2, '4': 1, '5': 4, '10': 'startTimestamp'},
    {'1': 'end_timestamp', '3': 3, '4': 1, '5': 4, '10': 'endTimestamp'},
    {'1': 'time_zone', '3': 4, '4': 1, '5': 9, '10': 'timeZone'},
    {
      '1': 'points',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.GpsTrailPoint',
      '10': 'points'
    },
    {
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
    'CghHcHNUcmFpbBIeCgJpZBgBIAEoCzIOLmFuZ2xlcnNsb2cuSWRSAmlkEicKD3N0YXJ0X3RpbW'
    'VzdGFtcBgCIAEoBFIOc3RhcnRUaW1lc3RhbXASIwoNZW5kX3RpbWVzdGFtcBgDIAEoBFIMZW5k'
    'VGltZXN0YW1wEhsKCXRpbWVfem9uZRgEIAEoCVIIdGltZVpvbmUSMQoGcG9pbnRzGAUgAygLMh'
    'kuYW5nbGVyc2xvZy5HcHNUcmFpbFBvaW50UgZwb2ludHMSNwoQYm9keV9vZl93YXRlcl9pZBgG'
    'IAEoCzIOLmFuZ2xlcnNsb2cuSWRSDWJvZHlPZldhdGVySWQ=');

@$core.Deprecated('Use gearDescriptor instead')
const Gear$json = {
  '1': 'Gear',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglerslog.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'image_name', '3': 3, '4': 1, '5': 9, '10': 'imageName'},
    {'1': 'rod_make_model', '3': 4, '4': 1, '5': 9, '10': 'rodMakeModel'},
    {'1': 'rod_serial_number', '3': 5, '4': 1, '5': 9, '10': 'rodSerialNumber'},
    {
      '1': 'rod_length',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'rodLength'
    },
    {
      '1': 'rod_action',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.RodAction',
      '10': 'rodAction'
    },
    {
      '1': 'rod_power',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.anglerslog.RodPower',
      '10': 'rodPower'
    },
    {'1': 'reel_make_model', '3': 9, '4': 1, '5': 9, '10': 'reelMakeModel'},
    {
      '1': 'reel_serial_number',
      '3': 10,
      '4': 1,
      '5': 9,
      '10': 'reelSerialNumber'
    },
    {'1': 'reel_size', '3': 11, '4': 1, '5': 9, '10': 'reelSize'},
    {'1': 'line_make_model', '3': 12, '4': 1, '5': 9, '10': 'lineMakeModel'},
    {
      '1': 'line_rating',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'lineRating'
    },
    {'1': 'line_color', '3': 14, '4': 1, '5': 9, '10': 'lineColor'},
    {
      '1': 'leader_length',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'leaderLength'
    },
    {
      '1': 'leader_rating',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'leaderRating'
    },
    {
      '1': 'tippet_length',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'tippetLength'
    },
    {
      '1': 'tippet_rating',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'tippetRating'
    },
    {'1': 'hook_make_model', '3': 19, '4': 1, '5': 9, '10': 'hookMakeModel'},
    {
      '1': 'hook_size',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.anglerslog.MultiMeasurement',
      '10': 'hookSize'
    },
    {
      '1': 'custom_entity_values',
      '3': 21,
      '4': 3,
      '5': 11,
      '6': '.anglerslog.CustomEntityValue',
      '10': 'customEntityValues'
    },
  ],
};

/// Descriptor for `Gear`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gearDescriptor = $convert.base64Decode(
    'CgRHZWFyEh4KAmlkGAEgASgLMg4uYW5nbGVyc2xvZy5JZFICaWQSEgoEbmFtZRgCIAEoCVIEbm'
    'FtZRIdCgppbWFnZV9uYW1lGAMgASgJUglpbWFnZU5hbWUSJAoOcm9kX21ha2VfbW9kZWwYBCAB'
    'KAlSDHJvZE1ha2VNb2RlbBIqChFyb2Rfc2VyaWFsX251bWJlchgFIAEoCVIPcm9kU2VyaWFsTn'
    'VtYmVyEjsKCnJvZF9sZW5ndGgYBiABKAsyHC5hbmdsZXJzbG9nLk11bHRpTWVhc3VyZW1lbnRS'
    'CXJvZExlbmd0aBI0Cgpyb2RfYWN0aW9uGAcgASgOMhUuYW5nbGVyc2xvZy5Sb2RBY3Rpb25SCX'
    'JvZEFjdGlvbhIxCglyb2RfcG93ZXIYCCABKA4yFC5hbmdsZXJzbG9nLlJvZFBvd2VyUghyb2RQ'
    'b3dlchImCg9yZWVsX21ha2VfbW9kZWwYCSABKAlSDXJlZWxNYWtlTW9kZWwSLAoScmVlbF9zZX'
    'JpYWxfbnVtYmVyGAogASgJUhByZWVsU2VyaWFsTnVtYmVyEhsKCXJlZWxfc2l6ZRgLIAEoCVII'
    'cmVlbFNpemUSJgoPbGluZV9tYWtlX21vZGVsGAwgASgJUg1saW5lTWFrZU1vZGVsEj0KC2xpbm'
    'VfcmF0aW5nGA0gASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50UgpsaW5lUmF0aW5n'
    'Eh0KCmxpbmVfY29sb3IYDiABKAlSCWxpbmVDb2xvchJBCg1sZWFkZXJfbGVuZ3RoGA8gASgLMh'
    'wuYW5nbGVyc2xvZy5NdWx0aU1lYXN1cmVtZW50UgxsZWFkZXJMZW5ndGgSQQoNbGVhZGVyX3Jh'
    'dGluZxgQIAEoCzIcLmFuZ2xlcnNsb2cuTXVsdGlNZWFzdXJlbWVudFIMbGVhZGVyUmF0aW5nEk'
    'EKDXRpcHBldF9sZW5ndGgYESABKAsyHC5hbmdsZXJzbG9nLk11bHRpTWVhc3VyZW1lbnRSDHRp'
    'cHBldExlbmd0aBJBCg10aXBwZXRfcmF0aW5nGBIgASgLMhwuYW5nbGVyc2xvZy5NdWx0aU1lYX'
    'N1cmVtZW50Ugx0aXBwZXRSYXRpbmcSJgoPaG9va19tYWtlX21vZGVsGBMgASgJUg1ob29rTWFr'
    'ZU1vZGVsEjkKCWhvb2tfc2l6ZRgUIAEoCzIcLmFuZ2xlcnNsb2cuTXVsdGlNZWFzdXJlbWVudF'
    'IIaG9va1NpemUSTwoUY3VzdG9tX2VudGl0eV92YWx1ZXMYFSADKAsyHS5hbmdsZXJzbG9nLkN1'
    'c3RvbUVudGl0eVZhbHVlUhJjdXN0b21FbnRpdHlWYWx1ZXM=');

// ignore_for_file: undefined_named_parameter,no_leading_underscores_for_local_identifiers
