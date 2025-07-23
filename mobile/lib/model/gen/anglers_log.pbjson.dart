// This is a generated file - do not edit.
//
// Generated from anglers_log.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

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
    {'1': 'meters_per_second', '2': 21},
  ],
};

/// Descriptor for `Unit`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List unitDescriptor = $convert.base64Decode(
    'CgRVbml0EggKBGZlZXQQABIKCgZpbmNoZXMQARIKCgZwb3VuZHMQAhIKCgZvdW5jZXMQAxIOCg'
    'pmYWhyZW5oZWl0EAQSCgoGbWV0ZXJzEAUSDwoLY2VudGltZXRlcnMQBhINCglraWxvZ3JhbXMQ'
    'BxILCgdjZWxzaXVzEAgSEgoObWlsZXNfcGVyX2hvdXIQCRIXChNraWxvbWV0ZXJzX3Blcl9ob3'
    'VyEAoSDQoJbWlsbGliYXJzEAsSGgoWcG91bmRzX3Blcl9zcXVhcmVfaW5jaBAMEgkKBW1pbGVz'
    'EA0SDgoKa2lsb21ldGVycxAOEgsKB3BlcmNlbnQQDxITCg9pbmNoX29mX21lcmN1cnkQEBIOCg'
    'pwb3VuZF90ZXN0EBESBQoBeBASEgsKB2hhc2h0YWcQExIJCgVhdWdodBAUEhUKEW1ldGVyc19w'
    'ZXJfc2Vjb25kEBU=');

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
      '6': '.anglers_log.Measurement',
      '8': {'3': true},
      '10': 'temperatureDeprecated',
    },
    {
      '1': 'sky_conditions',
      '3': 2,
      '4': 3,
      '5': 14,
      '6': '.anglers_log.SkyCondition',
      '10': 'skyConditions'
    },
    {
      '1': 'wind_speed_deprecated',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Measurement',
      '8': {'3': true},
      '10': 'windSpeedDeprecated',
    },
    {
      '1': 'wind_direction',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.anglers_log.Direction',
      '10': 'windDirection'
    },
    {
      '1': 'pressure_deprecated',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Measurement',
      '8': {'3': true},
      '10': 'pressureDeprecated',
    },
    {
      '1': 'humidity_deprecated',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Measurement',
      '8': {'3': true},
      '10': 'humidityDeprecated',
    },
    {
      '1': 'visibility_deprecated',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Measurement',
      '8': {'3': true},
      '10': 'visibilityDeprecated',
    },
    {
      '1': 'moon_phase',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.anglers_log.MoonPhase',
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
      '6': '.anglers_log.MultiMeasurement',
      '10': 'temperature'
    },
    {
      '1': 'wind_speed',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'windSpeed'
    },
    {
      '1': 'pressure',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'pressure'
    },
    {
      '1': 'humidity',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'humidity'
    },
    {
      '1': 'visibility',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'visibility'
    },
  ],
};

/// Descriptor for `Atmosphere`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List atmosphereDescriptor = $convert.base64Decode(
    'CgpBdG1vc3BoZXJlElMKFnRlbXBlcmF0dXJlX2RlcHJlY2F0ZWQYASABKAsyGC5hbmdsZXJzX2'
    'xvZy5NZWFzdXJlbWVudEICGAFSFXRlbXBlcmF0dXJlRGVwcmVjYXRlZBJACg5za3lfY29uZGl0'
    'aW9ucxgCIAMoDjIZLmFuZ2xlcnNfbG9nLlNreUNvbmRpdGlvblINc2t5Q29uZGl0aW9ucxJQCh'
    'V3aW5kX3NwZWVkX2RlcHJlY2F0ZWQYAyABKAsyGC5hbmdsZXJzX2xvZy5NZWFzdXJlbWVudEIC'
    'GAFSE3dpbmRTcGVlZERlcHJlY2F0ZWQSPQoOd2luZF9kaXJlY3Rpb24YBCABKA4yFi5hbmdsZX'
    'JzX2xvZy5EaXJlY3Rpb25SDXdpbmREaXJlY3Rpb24STQoTcHJlc3N1cmVfZGVwcmVjYXRlZBgF'
    'IAEoCzIYLmFuZ2xlcnNfbG9nLk1lYXN1cmVtZW50QgIYAVIScHJlc3N1cmVEZXByZWNhdGVkEk'
    '0KE2h1bWlkaXR5X2RlcHJlY2F0ZWQYBiABKAsyGC5hbmdsZXJzX2xvZy5NZWFzdXJlbWVudEIC'
    'GAFSEmh1bWlkaXR5RGVwcmVjYXRlZBJRChV2aXNpYmlsaXR5X2RlcHJlY2F0ZWQYByABKAsyGC'
    '5hbmdsZXJzX2xvZy5NZWFzdXJlbWVudEICGAFSFHZpc2liaWxpdHlEZXByZWNhdGVkEjUKCm1v'
    'b25fcGhhc2UYCCABKA4yFi5hbmdsZXJzX2xvZy5Nb29uUGhhc2VSCW1vb25QaGFzZRIrChFzdW'
    '5yaXNlX3RpbWVzdGFtcBgJIAEoBFIQc3VucmlzZVRpbWVzdGFtcBIpChBzdW5zZXRfdGltZXN0'
    'YW1wGAogASgEUg9zdW5zZXRUaW1lc3RhbXASGwoJdGltZV96b25lGAsgASgJUgh0aW1lWm9uZR'
    'I/Cgt0ZW1wZXJhdHVyZRgMIAEoCzIdLmFuZ2xlcnNfbG9nLk11bHRpTWVhc3VyZW1lbnRSC3Rl'
    'bXBlcmF0dXJlEjwKCndpbmRfc3BlZWQYDSABKAsyHS5hbmdsZXJzX2xvZy5NdWx0aU1lYXN1cm'
    'VtZW50Ugl3aW5kU3BlZWQSOQoIcHJlc3N1cmUYDiABKAsyHS5hbmdsZXJzX2xvZy5NdWx0aU1l'
    'YXN1cmVtZW50UghwcmVzc3VyZRI5CghodW1pZGl0eRgPIAEoCzIdLmFuZ2xlcnNfbG9nLk11bH'
    'RpTWVhc3VyZW1lbnRSCGh1bWlkaXR5Ej0KCnZpc2liaWxpdHkYECABKAsyHS5hbmdsZXJzX2xv'
    'Zy5NdWx0aU1lYXN1cmVtZW50Ugp2aXNpYmlsaXR5');

@$core.Deprecated('Use customEntityDescriptor instead')
const CustomEntity$json = {
  '1': 'CustomEntity',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglers_log.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.anglers_log.CustomEntity.Type',
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
    'CgxDdXN0b21FbnRpdHkSHwoCaWQYASABKAsyDy5hbmdsZXJzX2xvZy5JZFICaWQSEgoEbmFtZR'
    'gCIAEoCVIEbmFtZRIgCgtkZXNjcmlwdGlvbhgDIAEoCVILZGVzY3JpcHRpb24SMgoEdHlwZRgE'
    'IAEoDjIeLmFuZ2xlcnNfbG9nLkN1c3RvbUVudGl0eS5UeXBlUgR0eXBlIikKBFR5cGUSCwoHYm'
    '9vbGVhbhAAEgoKBm51bWJlchABEggKBHRleHQQAg==');

@$core.Deprecated('Use customEntityValueDescriptor instead')
const CustomEntityValue$json = {
  '1': 'CustomEntityValue',
  '2': [
    {
      '1': 'custom_entity_id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'customEntityId'
    },
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `CustomEntityValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List customEntityValueDescriptor = $convert.base64Decode(
    'ChFDdXN0b21FbnRpdHlWYWx1ZRI5ChBjdXN0b21fZW50aXR5X2lkGAEgASgLMg8uYW5nbGVyc1'
    '9sb2cuSWRSDmN1c3RvbUVudGl0eUlkEhQKBXZhbHVlGAIgASgJUgV2YWx1ZQ==');

@$core.Deprecated('Use baitDescriptor instead')
const Bait$json = {
  '1': 'Bait',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglers_log.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'bait_category_id',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'baitCategoryId'
    },
    {'1': 'image_name', '3': 4, '4': 1, '5': 9, '10': 'imageName'},
    {
      '1': 'type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.anglers_log.Bait.Type',
      '10': 'type'
    },
    {
      '1': 'variants',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.BaitVariant',
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
    'CgRCYWl0Eh8KAmlkGAEgASgLMg8uYW5nbGVyc19sb2cuSWRSAmlkEhIKBG5hbWUYAiABKAlSBG'
    '5hbWUSOQoQYmFpdF9jYXRlZ29yeV9pZBgDIAEoCzIPLmFuZ2xlcnNfbG9nLklkUg5iYWl0Q2F0'
    'ZWdvcnlJZBIdCgppbWFnZV9uYW1lGAQgASgJUglpbWFnZU5hbWUSKgoEdHlwZRgFIAEoDjIWLm'
    'FuZ2xlcnNfbG9nLkJhaXQuVHlwZVIEdHlwZRI0Cgh2YXJpYW50cxgGIAMoCzIYLmFuZ2xlcnNf'
    'bG9nLkJhaXRWYXJpYW50Ugh2YXJpYW50cyIqCgRUeXBlEg4KCmFydGlmaWNpYWwQABIICgRyZW'
    'FsEAESCAoEbGl2ZRAC');

@$core.Deprecated('Use baitVariantDescriptor instead')
const BaitVariant$json = {
  '1': 'BaitVariant',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglers_log.Id', '10': 'id'},
    {
      '1': 'base_id',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Id',
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
      '6': '.anglers_log.MultiMeasurement',
      '10': 'minDiveDepth'
    },
    {
      '1': 'max_dive_depth',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'maxDiveDepth'
    },
    {'1': 'description', '3': 8, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'custom_entity_values',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CustomEntityValue',
      '10': 'customEntityValues'
    },
    {'1': 'image_name', '3': 10, '4': 1, '5': 9, '10': 'imageName'},
  ],
};

/// Descriptor for `BaitVariant`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List baitVariantDescriptor = $convert.base64Decode(
    'CgtCYWl0VmFyaWFudBIfCgJpZBgBIAEoCzIPLmFuZ2xlcnNfbG9nLklkUgJpZBIoCgdiYXNlX2'
    'lkGAIgASgLMg8uYW5nbGVyc19sb2cuSWRSBmJhc2VJZBIUCgVjb2xvchgDIAEoCVIFY29sb3IS'
    'IQoMbW9kZWxfbnVtYmVyGAQgASgJUgttb2RlbE51bWJlchISCgRzaXplGAUgASgJUgRzaXplEk'
    'MKDm1pbl9kaXZlX2RlcHRoGAYgASgLMh0uYW5nbGVyc19sb2cuTXVsdGlNZWFzdXJlbWVudFIM'
    'bWluRGl2ZURlcHRoEkMKDm1heF9kaXZlX2RlcHRoGAcgASgLMh0uYW5nbGVyc19sb2cuTXVsdG'
    'lNZWFzdXJlbWVudFIMbWF4RGl2ZURlcHRoEiAKC2Rlc2NyaXB0aW9uGAggASgJUgtkZXNjcmlw'
    'dGlvbhJQChRjdXN0b21fZW50aXR5X3ZhbHVlcxgJIAMoCzIeLmFuZ2xlcnNfbG9nLkN1c3RvbU'
    'VudGl0eVZhbHVlUhJjdXN0b21FbnRpdHlWYWx1ZXMSHQoKaW1hZ2VfbmFtZRgKIAEoCVIJaW1h'
    'Z2VOYW1l');

@$core.Deprecated('Use baitAttachmentDescriptor instead')
const BaitAttachment$json = {
  '1': 'BaitAttachment',
  '2': [
    {
      '1': 'bait_id',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'baitId'
    },
    {
      '1': 'variant_id',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'variantId'
    },
  ],
};

/// Descriptor for `BaitAttachment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List baitAttachmentDescriptor = $convert.base64Decode(
    'Cg5CYWl0QXR0YWNobWVudBIoCgdiYWl0X2lkGAEgASgLMg8uYW5nbGVyc19sb2cuSWRSBmJhaX'
    'RJZBIuCgp2YXJpYW50X2lkGAIgASgLMg8uYW5nbGVyc19sb2cuSWRSCXZhcmlhbnRJZA==');

@$core.Deprecated('Use baitCategoryDescriptor instead')
const BaitCategory$json = {
  '1': 'BaitCategory',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglers_log.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `BaitCategory`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List baitCategoryDescriptor = $convert.base64Decode(
    'CgxCYWl0Q2F0ZWdvcnkSHwoCaWQYASABKAsyDy5hbmdsZXJzX2xvZy5JZFICaWQSEgoEbmFtZR'
    'gCIAEoCVIEbmFtZQ==');

@$core.Deprecated('Use catchDescriptor instead')
const Catch$json = {
  '1': 'Catch',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglers_log.Id', '10': 'id'},
    {'1': 'timestamp', '3': 2, '4': 1, '5': 4, '10': 'timestamp'},
    {
      '1': 'baits',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.BaitAttachment',
      '10': 'baits'
    },
    {
      '1': 'fishing_spot_id',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'fishingSpotId'
    },
    {
      '1': 'species_id',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'speciesId'
    },
    {'1': 'image_names', '3': 6, '4': 3, '5': 9, '10': 'imageNames'},
    {
      '1': 'custom_entity_values',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CustomEntityValue',
      '10': 'customEntityValues'
    },
    {
      '1': 'angler_id',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'anglerId'
    },
    {
      '1': 'method_ids',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'methodIds'
    },
    {
      '1': 'period',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.anglers_log.Period',
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
      '6': '.anglers_log.Season',
      '10': 'season'
    },
    {
      '1': 'water_clarity_id',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'waterClarityId'
    },
    {
      '1': 'water_depth',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'waterDepth'
    },
    {
      '1': 'water_temperature',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'waterTemperature'
    },
    {
      '1': 'length',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'length'
    },
    {
      '1': 'weight',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'weight'
    },
    {'1': 'quantity', '3': 19, '4': 1, '5': 13, '10': 'quantity'},
    {'1': 'notes', '3': 20, '4': 1, '5': 9, '10': 'notes'},
    {
      '1': 'atmosphere',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Atmosphere',
      '10': 'atmosphere'
    },
    {
      '1': 'tide',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Tide',
      '10': 'tide'
    },
    {'1': 'time_zone', '3': 23, '4': 1, '5': 9, '10': 'timeZone'},
    {
      '1': 'gear_ids',
      '3': 24,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'gearIds'
    },
  ],
};

/// Descriptor for `Catch`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catchDescriptor = $convert.base64Decode(
    'CgVDYXRjaBIfCgJpZBgBIAEoCzIPLmFuZ2xlcnNfbG9nLklkUgJpZBIcCgl0aW1lc3RhbXAYAi'
    'ABKARSCXRpbWVzdGFtcBIxCgViYWl0cxgDIAMoCzIbLmFuZ2xlcnNfbG9nLkJhaXRBdHRhY2ht'
    'ZW50UgViYWl0cxI3Cg9maXNoaW5nX3Nwb3RfaWQYBCABKAsyDy5hbmdsZXJzX2xvZy5JZFINZm'
    'lzaGluZ1Nwb3RJZBIuCgpzcGVjaWVzX2lkGAUgASgLMg8uYW5nbGVyc19sb2cuSWRSCXNwZWNp'
    'ZXNJZBIfCgtpbWFnZV9uYW1lcxgGIAMoCVIKaW1hZ2VOYW1lcxJQChRjdXN0b21fZW50aXR5X3'
    'ZhbHVlcxgHIAMoCzIeLmFuZ2xlcnNfbG9nLkN1c3RvbUVudGl0eVZhbHVlUhJjdXN0b21FbnRp'
    'dHlWYWx1ZXMSLAoJYW5nbGVyX2lkGAggASgLMg8uYW5nbGVyc19sb2cuSWRSCGFuZ2xlcklkEi'
    '4KCm1ldGhvZF9pZHMYCSADKAsyDy5hbmdsZXJzX2xvZy5JZFIJbWV0aG9kSWRzEisKBnBlcmlv'
    'ZBgKIAEoDjITLmFuZ2xlcnNfbG9nLlBlcmlvZFIGcGVyaW9kEh8KC2lzX2Zhdm9yaXRlGAsgAS'
    'gIUgppc0Zhdm9yaXRlEjEKFXdhc19jYXRjaF9hbmRfcmVsZWFzZRgMIAEoCFISd2FzQ2F0Y2hB'
    'bmRSZWxlYXNlEisKBnNlYXNvbhgNIAEoDjITLmFuZ2xlcnNfbG9nLlNlYXNvblIGc2Vhc29uEj'
    'kKEHdhdGVyX2NsYXJpdHlfaWQYDiABKAsyDy5hbmdsZXJzX2xvZy5JZFIOd2F0ZXJDbGFyaXR5'
    'SWQSPgoLd2F0ZXJfZGVwdGgYDyABKAsyHS5hbmdsZXJzX2xvZy5NdWx0aU1lYXN1cmVtZW50Ug'
    'p3YXRlckRlcHRoEkoKEXdhdGVyX3RlbXBlcmF0dXJlGBAgASgLMh0uYW5nbGVyc19sb2cuTXVs'
    'dGlNZWFzdXJlbWVudFIQd2F0ZXJUZW1wZXJhdHVyZRI1CgZsZW5ndGgYESABKAsyHS5hbmdsZX'
    'JzX2xvZy5NdWx0aU1lYXN1cmVtZW50UgZsZW5ndGgSNQoGd2VpZ2h0GBIgASgLMh0uYW5nbGVy'
    'c19sb2cuTXVsdGlNZWFzdXJlbWVudFIGd2VpZ2h0EhoKCHF1YW50aXR5GBMgASgNUghxdWFudG'
    'l0eRIUCgVub3RlcxgUIAEoCVIFbm90ZXMSNwoKYXRtb3NwaGVyZRgVIAEoCzIXLmFuZ2xlcnNf'
    'bG9nLkF0bW9zcGhlcmVSCmF0bW9zcGhlcmUSJQoEdGlkZRgWIAEoCzIRLmFuZ2xlcnNfbG9nLl'
    'RpZGVSBHRpZGUSGwoJdGltZV96b25lGBcgASgJUgh0aW1lWm9uZRIqCghnZWFyX2lkcxgYIAMo'
    'CzIPLmFuZ2xlcnNfbG9nLklkUgdnZWFySWRz');

@$core.Deprecated('Use bodyOfWaterDescriptor instead')
const BodyOfWater$json = {
  '1': 'BodyOfWater',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglers_log.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `BodyOfWater`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bodyOfWaterDescriptor = $convert.base64Decode(
    'CgtCb2R5T2ZXYXRlchIfCgJpZBgBIAEoCzIPLmFuZ2xlcnNfbG9nLklkUgJpZBISCgRuYW1lGA'
    'IgASgJUgRuYW1l');

@$core.Deprecated('Use fishingSpotDescriptor instead')
const FishingSpot$json = {
  '1': 'FishingSpot',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglers_log.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'lat', '3': 3, '4': 1, '5': 1, '10': 'lat'},
    {'1': 'lng', '3': 4, '4': 1, '5': 1, '10': 'lng'},
    {
      '1': 'body_of_water_id',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'bodyOfWaterId'
    },
    {'1': 'image_name', '3': 6, '4': 1, '5': 9, '10': 'imageName'},
    {'1': 'notes', '3': 7, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `FishingSpot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fishingSpotDescriptor = $convert.base64Decode(
    'CgtGaXNoaW5nU3BvdBIfCgJpZBgBIAEoCzIPLmFuZ2xlcnNfbG9nLklkUgJpZBISCgRuYW1lGA'
    'IgASgJUgRuYW1lEhAKA2xhdBgDIAEoAVIDbGF0EhAKA2xuZxgEIAEoAVIDbG5nEjgKEGJvZHlf'
    'b2Zfd2F0ZXJfaWQYBSABKAsyDy5hbmdsZXJzX2xvZy5JZFINYm9keU9mV2F0ZXJJZBIdCgppbW'
    'FnZV9uYW1lGAYgASgJUglpbWFnZU5hbWUSFAoFbm90ZXMYByABKAlSBW5vdGVz');

@$core.Deprecated('Use numberFilterDescriptor instead')
const NumberFilter$json = {
  '1': 'NumberFilter',
  '2': [
    {
      '1': 'boundary',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anglers_log.NumberBoundary',
      '10': 'boundary'
    },
    {
      '1': 'from',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'from'
    },
    {
      '1': 'to',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'to'
    },
  ],
};

/// Descriptor for `NumberFilter`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List numberFilterDescriptor = $convert.base64Decode(
    'CgxOdW1iZXJGaWx0ZXISNwoIYm91bmRhcnkYASABKA4yGy5hbmdsZXJzX2xvZy5OdW1iZXJCb3'
    'VuZGFyeVIIYm91bmRhcnkSMQoEZnJvbRgCIAEoCzIdLmFuZ2xlcnNfbG9nLk11bHRpTWVhc3Vy'
    'ZW1lbnRSBGZyb20SLQoCdG8YAyABKAsyHS5hbmdsZXJzX2xvZy5NdWx0aU1lYXN1cmVtZW50Ug'
    'J0bw==');

@$core.Deprecated('Use speciesDescriptor instead')
const Species$json = {
  '1': 'Species',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglers_log.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Species`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List speciesDescriptor = $convert.base64Decode(
    'CgdTcGVjaWVzEh8KAmlkGAEgASgLMg8uYW5nbGVyc19sb2cuSWRSAmlkEhIKBG5hbWUYAiABKA'
    'lSBG5hbWU=');

@$core.Deprecated('Use reportDescriptor instead')
const Report$json = {
  '1': 'Report',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglers_log.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.anglers_log.Report.Type',
      '10': 'type'
    },
    {
      '1': 'from_date_range',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.adair_flutter_lib.DateRange',
      '10': 'fromDateRange'
    },
    {
      '1': 'to_date_range',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.adair_flutter_lib.DateRange',
      '10': 'toDateRange'
    },
    {
      '1': 'baits',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.BaitAttachment',
      '10': 'baits'
    },
    {
      '1': 'fishing_spot_ids',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'fishingSpotIds'
    },
    {
      '1': 'species_ids',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'speciesIds'
    },
    {
      '1': 'angler_ids',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'anglerIds'
    },
    {
      '1': 'method_ids',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'methodIds'
    },
    {
      '1': 'periods',
      '3': 12,
      '4': 3,
      '5': 14,
      '6': '.anglers_log.Period',
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
      '6': '.anglers_log.Season',
      '10': 'seasons'
    },
    {
      '1': 'water_clarity_ids',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'waterClarityIds'
    },
    {
      '1': 'water_depth_filter',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'waterDepthFilter'
    },
    {
      '1': 'water_temperature_filter',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'waterTemperatureFilter'
    },
    {
      '1': 'length_filter',
      '3': 19,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'lengthFilter'
    },
    {
      '1': 'weight_filter',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'weightFilter'
    },
    {
      '1': 'quantity_filter',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'quantityFilter'
    },
    {
      '1': 'air_temperature_filter',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'airTemperatureFilter'
    },
    {
      '1': 'air_pressure_filter',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'airPressureFilter'
    },
    {
      '1': 'air_humidity_filter',
      '3': 24,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'airHumidityFilter'
    },
    {
      '1': 'air_visibility_filter',
      '3': 25,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'airVisibilityFilter'
    },
    {
      '1': 'wind_speed_filter',
      '3': 26,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'windSpeedFilter'
    },
    {
      '1': 'wind_directions',
      '3': 27,
      '4': 3,
      '5': 14,
      '6': '.anglers_log.Direction',
      '10': 'windDirections'
    },
    {
      '1': 'sky_conditions',
      '3': 28,
      '4': 3,
      '5': 14,
      '6': '.anglers_log.SkyCondition',
      '10': 'skyConditions'
    },
    {
      '1': 'moon_phases',
      '3': 29,
      '4': 3,
      '5': 14,
      '6': '.anglers_log.MoonPhase',
      '10': 'moonPhases'
    },
    {
      '1': 'tide_types',
      '3': 30,
      '4': 3,
      '5': 14,
      '6': '.anglers_log.TideType',
      '10': 'tideTypes'
    },
    {
      '1': 'body_of_water_ids',
      '3': 31,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'bodyOfWaterIds'
    },
    {'1': 'time_zone', '3': 32, '4': 1, '5': 9, '10': 'timeZone'},
    {
      '1': 'gear_ids',
      '3': 33,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
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
    'CgZSZXBvcnQSHwoCaWQYASABKAsyDy5hbmdsZXJzX2xvZy5JZFICaWQSEgoEbmFtZRgCIAEoCV'
    'IEbmFtZRIgCgtkZXNjcmlwdGlvbhgDIAEoCVILZGVzY3JpcHRpb24SLAoEdHlwZRgEIAEoDjIY'
    'LmFuZ2xlcnNfbG9nLlJlcG9ydC5UeXBlUgR0eXBlEkQKD2Zyb21fZGF0ZV9yYW5nZRgFIAEoCz'
    'IcLmFkYWlyX2ZsdXR0ZXJfbGliLkRhdGVSYW5nZVINZnJvbURhdGVSYW5nZRJACg10b19kYXRl'
    'X3JhbmdlGAYgASgLMhwuYWRhaXJfZmx1dHRlcl9saWIuRGF0ZVJhbmdlUgt0b0RhdGVSYW5nZR'
    'IxCgViYWl0cxgHIAMoCzIbLmFuZ2xlcnNfbG9nLkJhaXRBdHRhY2htZW50UgViYWl0cxI5ChBm'
    'aXNoaW5nX3Nwb3RfaWRzGAggAygLMg8uYW5nbGVyc19sb2cuSWRSDmZpc2hpbmdTcG90SWRzEj'
    'AKC3NwZWNpZXNfaWRzGAkgAygLMg8uYW5nbGVyc19sb2cuSWRSCnNwZWNpZXNJZHMSLgoKYW5n'
    'bGVyX2lkcxgKIAMoCzIPLmFuZ2xlcnNfbG9nLklkUglhbmdsZXJJZHMSLgoKbWV0aG9kX2lkcx'
    'gLIAMoCzIPLmFuZ2xlcnNfbG9nLklkUgltZXRob2RJZHMSLQoHcGVyaW9kcxgMIAMoDjITLmFu'
    'Z2xlcnNfbG9nLlBlcmlvZFIHcGVyaW9kcxIqChFpc19mYXZvcml0ZXNfb25seRgNIAEoCFIPaX'
    'NGYXZvcml0ZXNPbmx5EjgKGWlzX2NhdGNoX2FuZF9yZWxlYXNlX29ubHkYDiABKAhSFWlzQ2F0'
    'Y2hBbmRSZWxlYXNlT25seRItCgdzZWFzb25zGA8gAygOMhMuYW5nbGVyc19sb2cuU2Vhc29uUg'
    'dzZWFzb25zEjsKEXdhdGVyX2NsYXJpdHlfaWRzGBAgAygLMg8uYW5nbGVyc19sb2cuSWRSD3dh'
    'dGVyQ2xhcml0eUlkcxJHChJ3YXRlcl9kZXB0aF9maWx0ZXIYESABKAsyGS5hbmdsZXJzX2xvZy'
    '5OdW1iZXJGaWx0ZXJSEHdhdGVyRGVwdGhGaWx0ZXISUwoYd2F0ZXJfdGVtcGVyYXR1cmVfZmls'
    'dGVyGBIgASgLMhkuYW5nbGVyc19sb2cuTnVtYmVyRmlsdGVyUhZ3YXRlclRlbXBlcmF0dXJlRm'
    'lsdGVyEj4KDWxlbmd0aF9maWx0ZXIYEyABKAsyGS5hbmdsZXJzX2xvZy5OdW1iZXJGaWx0ZXJS'
    'DGxlbmd0aEZpbHRlchI+Cg13ZWlnaHRfZmlsdGVyGBQgASgLMhkuYW5nbGVyc19sb2cuTnVtYm'
    'VyRmlsdGVyUgx3ZWlnaHRGaWx0ZXISQgoPcXVhbnRpdHlfZmlsdGVyGBUgASgLMhkuYW5nbGVy'
    'c19sb2cuTnVtYmVyRmlsdGVyUg5xdWFudGl0eUZpbHRlchJPChZhaXJfdGVtcGVyYXR1cmVfZm'
    'lsdGVyGBYgASgLMhkuYW5nbGVyc19sb2cuTnVtYmVyRmlsdGVyUhRhaXJUZW1wZXJhdHVyZUZp'
    'bHRlchJJChNhaXJfcHJlc3N1cmVfZmlsdGVyGBcgASgLMhkuYW5nbGVyc19sb2cuTnVtYmVyRm'
    'lsdGVyUhFhaXJQcmVzc3VyZUZpbHRlchJJChNhaXJfaHVtaWRpdHlfZmlsdGVyGBggASgLMhku'
    'YW5nbGVyc19sb2cuTnVtYmVyRmlsdGVyUhFhaXJIdW1pZGl0eUZpbHRlchJNChVhaXJfdmlzaW'
    'JpbGl0eV9maWx0ZXIYGSABKAsyGS5hbmdsZXJzX2xvZy5OdW1iZXJGaWx0ZXJSE2FpclZpc2li'
    'aWxpdHlGaWx0ZXISRQoRd2luZF9zcGVlZF9maWx0ZXIYGiABKAsyGS5hbmdsZXJzX2xvZy5OdW'
    '1iZXJGaWx0ZXJSD3dpbmRTcGVlZEZpbHRlchI/Cg93aW5kX2RpcmVjdGlvbnMYGyADKA4yFi5h'
    'bmdsZXJzX2xvZy5EaXJlY3Rpb25SDndpbmREaXJlY3Rpb25zEkAKDnNreV9jb25kaXRpb25zGB'
    'wgAygOMhkuYW5nbGVyc19sb2cuU2t5Q29uZGl0aW9uUg1za3lDb25kaXRpb25zEjcKC21vb25f'
    'cGhhc2VzGB0gAygOMhYuYW5nbGVyc19sb2cuTW9vblBoYXNlUgptb29uUGhhc2VzEjQKCnRpZG'
    'VfdHlwZXMYHiADKA4yFS5hbmdsZXJzX2xvZy5UaWRlVHlwZVIJdGlkZVR5cGVzEjoKEWJvZHlf'
    'b2Zfd2F0ZXJfaWRzGB8gAygLMg8uYW5nbGVyc19sb2cuSWRSDmJvZHlPZldhdGVySWRzEhsKCX'
    'RpbWVfem9uZRggIAEoCVIIdGltZVpvbmUSKgoIZ2Vhcl9pZHMYISADKAsyDy5hbmdsZXJzX2xv'
    'Zy5JZFIHZ2VhcklkcyIjCgRUeXBlEgsKB3N1bW1hcnkQABIOCgpjb21wYXJpc29uEAE=');

@$core.Deprecated('Use anglerDescriptor instead')
const Angler$json = {
  '1': 'Angler',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglers_log.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Angler`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List anglerDescriptor = $convert.base64Decode(
    'CgZBbmdsZXISHwoCaWQYASABKAsyDy5hbmdsZXJzX2xvZy5JZFICaWQSEgoEbmFtZRgCIAEoCV'
    'IEbmFtZQ==');

@$core.Deprecated('Use methodDescriptor instead')
const Method$json = {
  '1': 'Method',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglers_log.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Method`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List methodDescriptor = $convert.base64Decode(
    'CgZNZXRob2QSHwoCaWQYASABKAsyDy5hbmdsZXJzX2xvZy5JZFICaWQSEgoEbmFtZRgCIAEoCV'
    'IEbmFtZQ==');

@$core.Deprecated('Use waterClarityDescriptor instead')
const WaterClarity$json = {
  '1': 'WaterClarity',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglers_log.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `WaterClarity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List waterClarityDescriptor = $convert.base64Decode(
    'CgxXYXRlckNsYXJpdHkSHwoCaWQYASABKAsyDy5hbmdsZXJzX2xvZy5JZFICaWQSEgoEbmFtZR'
    'gCIAEoCVIEbmFtZQ==');

@$core.Deprecated('Use tripDescriptor instead')
const Trip$json = {
  '1': 'Trip',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglers_log.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'start_timestamp', '3': 3, '4': 1, '5': 4, '10': 'startTimestamp'},
    {'1': 'end_timestamp', '3': 4, '4': 1, '5': 4, '10': 'endTimestamp'},
    {'1': 'image_names', '3': 5, '4': 3, '5': 9, '10': 'imageNames'},
    {
      '1': 'catch_ids',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'catchIds'
    },
    {
      '1': 'body_of_water_ids',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'bodyOfWaterIds'
    },
    {
      '1': 'catches_per_fishing_spot',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Trip.CatchesPerEntity',
      '10': 'catchesPerFishingSpot'
    },
    {
      '1': 'catches_per_angler',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Trip.CatchesPerEntity',
      '10': 'catchesPerAngler'
    },
    {
      '1': 'catches_per_species',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Trip.CatchesPerEntity',
      '10': 'catchesPerSpecies'
    },
    {
      '1': 'catches_per_bait',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Trip.CatchesPerBait',
      '10': 'catchesPerBait'
    },
    {
      '1': 'custom_entity_values',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CustomEntityValue',
      '10': 'customEntityValues'
    },
    {'1': 'notes', '3': 13, '4': 1, '5': 9, '10': 'notes'},
    {
      '1': 'atmosphere',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Atmosphere',
      '10': 'atmosphere'
    },
    {'1': 'time_zone', '3': 15, '4': 1, '5': 9, '10': 'timeZone'},
    {
      '1': 'gps_trail_ids',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'gpsTrailIds'
    },
    {
      '1': 'water_clarity_id',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'waterClarityId'
    },
    {
      '1': 'water_depth',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'waterDepth'
    },
    {
      '1': 'water_temperature',
      '3': 19,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'waterTemperature'
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
      '6': '.anglers_log.Id',
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
      '6': '.anglers_log.BaitAttachment',
      '10': 'attachment'
    },
    {'1': 'value', '3': 2, '4': 1, '5': 13, '10': 'value'},
  ],
};

/// Descriptor for `Trip`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tripDescriptor = $convert.base64Decode(
    'CgRUcmlwEh8KAmlkGAEgASgLMg8uYW5nbGVyc19sb2cuSWRSAmlkEhIKBG5hbWUYAiABKAlSBG'
    '5hbWUSJwoPc3RhcnRfdGltZXN0YW1wGAMgASgEUg5zdGFydFRpbWVzdGFtcBIjCg1lbmRfdGlt'
    'ZXN0YW1wGAQgASgEUgxlbmRUaW1lc3RhbXASHwoLaW1hZ2VfbmFtZXMYBSADKAlSCmltYWdlTm'
    'FtZXMSLAoJY2F0Y2hfaWRzGAYgAygLMg8uYW5nbGVyc19sb2cuSWRSCGNhdGNoSWRzEjoKEWJv'
    'ZHlfb2Zfd2F0ZXJfaWRzGAcgAygLMg8uYW5nbGVyc19sb2cuSWRSDmJvZHlPZldhdGVySWRzEl'
    'sKGGNhdGNoZXNfcGVyX2Zpc2hpbmdfc3BvdBgIIAMoCzIiLmFuZ2xlcnNfbG9nLlRyaXAuQ2F0'
    'Y2hlc1BlckVudGl0eVIVY2F0Y2hlc1BlckZpc2hpbmdTcG90ElAKEmNhdGNoZXNfcGVyX2FuZ2'
    'xlchgJIAMoCzIiLmFuZ2xlcnNfbG9nLlRyaXAuQ2F0Y2hlc1BlckVudGl0eVIQY2F0Y2hlc1Bl'
    'ckFuZ2xlchJSChNjYXRjaGVzX3Blcl9zcGVjaWVzGAogAygLMiIuYW5nbGVyc19sb2cuVHJpcC'
    '5DYXRjaGVzUGVyRW50aXR5UhFjYXRjaGVzUGVyU3BlY2llcxJKChBjYXRjaGVzX3Blcl9iYWl0'
    'GAsgAygLMiAuYW5nbGVyc19sb2cuVHJpcC5DYXRjaGVzUGVyQmFpdFIOY2F0Y2hlc1BlckJhaX'
    'QSUAoUY3VzdG9tX2VudGl0eV92YWx1ZXMYDCADKAsyHi5hbmdsZXJzX2xvZy5DdXN0b21FbnRp'
    'dHlWYWx1ZVISY3VzdG9tRW50aXR5VmFsdWVzEhQKBW5vdGVzGA0gASgJUgVub3RlcxI3CgphdG'
    '1vc3BoZXJlGA4gASgLMhcuYW5nbGVyc19sb2cuQXRtb3NwaGVyZVIKYXRtb3NwaGVyZRIbCgl0'
    'aW1lX3pvbmUYDyABKAlSCHRpbWVab25lEjMKDWdwc190cmFpbF9pZHMYECADKAsyDy5hbmdsZX'
    'JzX2xvZy5JZFILZ3BzVHJhaWxJZHMSOQoQd2F0ZXJfY2xhcml0eV9pZBgRIAEoCzIPLmFuZ2xl'
    'cnNfbG9nLklkUg53YXRlckNsYXJpdHlJZBI+Cgt3YXRlcl9kZXB0aBgSIAEoCzIdLmFuZ2xlcn'
    'NfbG9nLk11bHRpTWVhc3VyZW1lbnRSCndhdGVyRGVwdGgSSgoRd2F0ZXJfdGVtcGVyYXR1cmUY'
    'EyABKAsyHS5hbmdsZXJzX2xvZy5NdWx0aU1lYXN1cmVtZW50UhB3YXRlclRlbXBlcmF0dXJlGl'
    'YKEENhdGNoZXNQZXJFbnRpdHkSLAoJZW50aXR5X2lkGAEgASgLMg8uYW5nbGVyc19sb2cuSWRS'
    'CGVudGl0eUlkEhQKBXZhbHVlGAIgASgNUgV2YWx1ZRpjCg5DYXRjaGVzUGVyQmFpdBI7CgphdH'
    'RhY2htZW50GAEgASgLMhsuYW5nbGVyc19sb2cuQmFpdEF0dGFjaG1lbnRSCmF0dGFjaG1lbnQS'
    'FAoFdmFsdWUYAiABKA1SBXZhbHVl');

@$core.Deprecated('Use measurementDescriptor instead')
const Measurement$json = {
  '1': 'Measurement',
  '2': [
    {
      '1': 'unit',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anglers_log.Unit',
      '10': 'unit'
    },
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
};

/// Descriptor for `Measurement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List measurementDescriptor = $convert.base64Decode(
    'CgtNZWFzdXJlbWVudBIlCgR1bml0GAEgASgOMhEuYW5nbGVyc19sb2cuVW5pdFIEdW5pdBIUCg'
    'V2YWx1ZRgCIAEoAVIFdmFsdWU=');

@$core.Deprecated('Use multiMeasurementDescriptor instead')
const MultiMeasurement$json = {
  '1': 'MultiMeasurement',
  '2': [
    {
      '1': 'system',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anglers_log.MeasurementSystem',
      '10': 'system'
    },
    {
      '1': 'main_value',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Measurement',
      '10': 'mainValue'
    },
    {
      '1': 'fraction_value',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Measurement',
      '10': 'fractionValue'
    },
    {'1': 'is_negative', '3': 4, '4': 1, '5': 8, '10': 'isNegative'},
  ],
};

/// Descriptor for `MultiMeasurement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List multiMeasurementDescriptor = $convert.base64Decode(
    'ChBNdWx0aU1lYXN1cmVtZW50EjYKBnN5c3RlbRgBIAEoDjIeLmFuZ2xlcnNfbG9nLk1lYXN1cm'
    'VtZW50U3lzdGVtUgZzeXN0ZW0SNwoKbWFpbl92YWx1ZRgCIAEoCzIYLmFuZ2xlcnNfbG9nLk1l'
    'YXN1cmVtZW50UgltYWluVmFsdWUSPwoOZnJhY3Rpb25fdmFsdWUYAyABKAsyGC5hbmdsZXJzX2'
    'xvZy5NZWFzdXJlbWVudFINZnJhY3Rpb25WYWx1ZRIfCgtpc19uZWdhdGl2ZRgEIAEoCFIKaXNO'
    'ZWdhdGl2ZQ==');

@$core.Deprecated('Use tideDescriptor instead')
const Tide$json = {
  '1': 'Tide',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anglers_log.TideType',
      '10': 'type'
    },
    {
      '1': 'first_low_timestamp',
      '3': 2,
      '4': 1,
      '5': 4,
      '8': {'3': true},
      '10': 'firstLowTimestamp',
    },
    {
      '1': 'first_high_timestamp',
      '3': 3,
      '4': 1,
      '5': 4,
      '8': {'3': true},
      '10': 'firstHighTimestamp',
    },
    {'1': 'time_zone', '3': 4, '4': 1, '5': 9, '10': 'timeZone'},
    {
      '1': 'height',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Tide.Height',
      '10': 'height'
    },
    {
      '1': 'days_heights',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Tide.Height',
      '10': 'daysHeights'
    },
    {
      '1': 'second_low_timestamp',
      '3': 7,
      '4': 1,
      '5': 4,
      '8': {'3': true},
      '10': 'secondLowTimestamp',
    },
    {
      '1': 'second_high_timestamp',
      '3': 8,
      '4': 1,
      '5': 4,
      '8': {'3': true},
      '10': 'secondHighTimestamp',
    },
    {
      '1': 'first_low_height',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Tide.Height',
      '10': 'firstLowHeight'
    },
    {
      '1': 'first_high_height',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Tide.Height',
      '10': 'firstHighHeight'
    },
    {
      '1': 'second_low_height',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Tide.Height',
      '10': 'secondLowHeight'
    },
    {
      '1': 'second_high_height',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Tide.Height',
      '10': 'secondHighHeight'
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
    'CgRUaWRlEikKBHR5cGUYASABKA4yFS5hbmdsZXJzX2xvZy5UaWRlVHlwZVIEdHlwZRIyChNmaX'
    'JzdF9sb3dfdGltZXN0YW1wGAIgASgEQgIYAVIRZmlyc3RMb3dUaW1lc3RhbXASNAoUZmlyc3Rf'
    'aGlnaF90aW1lc3RhbXAYAyABKARCAhgBUhJmaXJzdEhpZ2hUaW1lc3RhbXASGwoJdGltZV96b2'
    '5lGAQgASgJUgh0aW1lWm9uZRIwCgZoZWlnaHQYBSABKAsyGC5hbmdsZXJzX2xvZy5UaWRlLkhl'
    'aWdodFIGaGVpZ2h0EjsKDGRheXNfaGVpZ2h0cxgGIAMoCzIYLmFuZ2xlcnNfbG9nLlRpZGUuSG'
    'VpZ2h0UgtkYXlzSGVpZ2h0cxI0ChRzZWNvbmRfbG93X3RpbWVzdGFtcBgHIAEoBEICGAFSEnNl'
    'Y29uZExvd1RpbWVzdGFtcBI2ChVzZWNvbmRfaGlnaF90aW1lc3RhbXAYCCABKARCAhgBUhNzZW'
    'NvbmRIaWdoVGltZXN0YW1wEkIKEGZpcnN0X2xvd19oZWlnaHQYCSABKAsyGC5hbmdsZXJzX2xv'
    'Zy5UaWRlLkhlaWdodFIOZmlyc3RMb3dIZWlnaHQSRAoRZmlyc3RfaGlnaF9oZWlnaHQYCiABKA'
    'syGC5hbmdsZXJzX2xvZy5UaWRlLkhlaWdodFIPZmlyc3RIaWdoSGVpZ2h0EkQKEXNlY29uZF9s'
    'b3dfaGVpZ2h0GAsgASgLMhguYW5nbGVyc19sb2cuVGlkZS5IZWlnaHRSD3NlY29uZExvd0hlaW'
    'dodBJGChJzZWNvbmRfaGlnaF9oZWlnaHQYDCABKAsyGC5hbmdsZXJzX2xvZy5UaWRlLkhlaWdo'
    'dFIQc2Vjb25kSGlnaEhlaWdodBo8CgZIZWlnaHQSHAoJdGltZXN0YW1wGAEgASgEUgl0aW1lc3'
    'RhbXASFAoFdmFsdWUYAiABKAFSBXZhbHVl');

@$core.Deprecated('Use catchFilterOptionsDescriptor instead')
const CatchFilterOptions$json = {
  '1': 'CatchFilterOptions',
  '2': [
    {
      '1': 'order',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anglers_log.CatchFilterOptions.Order',
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
      '6': '.anglers_log.CatchFilterOptions.AllAnglersEntry',
      '10': 'allAnglers'
    },
    {
      '1': 'all_baits',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchFilterOptions.AllBaitsEntry',
      '10': 'allBaits'
    },
    {
      '1': 'all_bodies_of_water',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchFilterOptions.AllBodiesOfWaterEntry',
      '10': 'allBodiesOfWater'
    },
    {
      '1': 'all_catches',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchFilterOptions.AllCatchesEntry',
      '10': 'allCatches'
    },
    {
      '1': 'all_fishing_spots',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchFilterOptions.AllFishingSpotsEntry',
      '10': 'allFishingSpots'
    },
    {
      '1': 'all_methods',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchFilterOptions.AllMethodsEntry',
      '10': 'allMethods'
    },
    {
      '1': 'all_species',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchFilterOptions.AllSpeciesEntry',
      '10': 'allSpecies'
    },
    {
      '1': 'all_water_clarities',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchFilterOptions.AllWaterClaritiesEntry',
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
      '6': '.adair_flutter_lib.DateRange',
      '10': 'dateRanges'
    },
    {
      '1': 'baits',
      '3': 15,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.BaitAttachment',
      '10': 'baits'
    },
    {
      '1': 'catch_ids',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'catchIds'
    },
    {
      '1': 'angler_ids',
      '3': 17,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'anglerIds'
    },
    {
      '1': 'fishing_spot_ids',
      '3': 18,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'fishingSpotIds'
    },
    {
      '1': 'body_of_water_ids',
      '3': 19,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'bodyOfWaterIds'
    },
    {
      '1': 'method_ids',
      '3': 20,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'methodIds'
    },
    {
      '1': 'species_ids',
      '3': 21,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'speciesIds'
    },
    {
      '1': 'water_clarity_ids',
      '3': 22,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'waterClarityIds'
    },
    {
      '1': 'periods',
      '3': 23,
      '4': 3,
      '5': 14,
      '6': '.anglers_log.Period',
      '10': 'periods'
    },
    {
      '1': 'seasons',
      '3': 24,
      '4': 3,
      '5': 14,
      '6': '.anglers_log.Season',
      '10': 'seasons'
    },
    {
      '1': 'wind_directions',
      '3': 25,
      '4': 3,
      '5': 14,
      '6': '.anglers_log.Direction',
      '10': 'windDirections'
    },
    {
      '1': 'sky_conditions',
      '3': 26,
      '4': 3,
      '5': 14,
      '6': '.anglers_log.SkyCondition',
      '10': 'skyConditions'
    },
    {
      '1': 'moon_phases',
      '3': 27,
      '4': 3,
      '5': 14,
      '6': '.anglers_log.MoonPhase',
      '10': 'moonPhases'
    },
    {
      '1': 'tide_types',
      '3': 28,
      '4': 3,
      '5': 14,
      '6': '.anglers_log.TideType',
      '10': 'tideTypes'
    },
    {
      '1': 'water_depth_filter',
      '3': 29,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'waterDepthFilter'
    },
    {
      '1': 'water_temperature_filter',
      '3': 30,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'waterTemperatureFilter'
    },
    {
      '1': 'length_filter',
      '3': 31,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'lengthFilter'
    },
    {
      '1': 'weight_filter',
      '3': 32,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'weightFilter'
    },
    {
      '1': 'quantity_filter',
      '3': 33,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'quantityFilter'
    },
    {
      '1': 'air_temperature_filter',
      '3': 34,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'airTemperatureFilter'
    },
    {
      '1': 'air_pressure_filter',
      '3': 35,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'airPressureFilter'
    },
    {
      '1': 'air_humidity_filter',
      '3': 36,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'airHumidityFilter'
    },
    {
      '1': 'air_visibility_filter',
      '3': 37,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
      '10': 'airVisibilityFilter'
    },
    {
      '1': 'wind_speed_filter',
      '3': 38,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.NumberFilter',
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
      '6': '.anglers_log.CatchFilterOptions.AllGearEntry',
      '10': 'allGear'
    },
    {
      '1': 'gear_ids',
      '3': 53,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
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
      '6': '.anglers_log.Angler',
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
      '6': '.anglers_log.Bait',
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
      '6': '.anglers_log.BodyOfWater',
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
      '6': '.anglers_log.Catch',
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
      '6': '.anglers_log.FishingSpot',
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
      '6': '.anglers_log.Method',
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
      '6': '.anglers_log.Species',
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
      '6': '.anglers_log.WaterClarity',
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
      '6': '.anglers_log.Gear',
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
    'ChJDYXRjaEZpbHRlck9wdGlvbnMSOwoFb3JkZXIYASABKA4yJS5hbmdsZXJzX2xvZy5DYXRjaE'
    'ZpbHRlck9wdGlvbnMuT3JkZXJSBW9yZGVyEisKEWN1cnJlbnRfdGltZXN0YW1wGAIgASgEUhBj'
    'dXJyZW50VGltZXN0YW1wEioKEWN1cnJlbnRfdGltZV96b25lGAMgASgJUg9jdXJyZW50VGltZV'
    'pvbmUSUAoLYWxsX2FuZ2xlcnMYBCADKAsyLy5hbmdsZXJzX2xvZy5DYXRjaEZpbHRlck9wdGlv'
    'bnMuQWxsQW5nbGVyc0VudHJ5UgphbGxBbmdsZXJzEkoKCWFsbF9iYWl0cxgFIAMoCzItLmFuZ2'
    'xlcnNfbG9nLkNhdGNoRmlsdGVyT3B0aW9ucy5BbGxCYWl0c0VudHJ5UghhbGxCYWl0cxJkChNh'
    'bGxfYm9kaWVzX29mX3dhdGVyGAYgAygLMjUuYW5nbGVyc19sb2cuQ2F0Y2hGaWx0ZXJPcHRpb2'
    '5zLkFsbEJvZGllc09mV2F0ZXJFbnRyeVIQYWxsQm9kaWVzT2ZXYXRlchJQCgthbGxfY2F0Y2hl'
    'cxgHIAMoCzIvLmFuZ2xlcnNfbG9nLkNhdGNoRmlsdGVyT3B0aW9ucy5BbGxDYXRjaGVzRW50cn'
    'lSCmFsbENhdGNoZXMSYAoRYWxsX2Zpc2hpbmdfc3BvdHMYCCADKAsyNC5hbmdsZXJzX2xvZy5D'
    'YXRjaEZpbHRlck9wdGlvbnMuQWxsRmlzaGluZ1Nwb3RzRW50cnlSD2FsbEZpc2hpbmdTcG90cx'
    'JQCgthbGxfbWV0aG9kcxgJIAMoCzIvLmFuZ2xlcnNfbG9nLkNhdGNoRmlsdGVyT3B0aW9ucy5B'
    'bGxNZXRob2RzRW50cnlSCmFsbE1ldGhvZHMSUAoLYWxsX3NwZWNpZXMYCiADKAsyLy5hbmdsZX'
    'JzX2xvZy5DYXRjaEZpbHRlck9wdGlvbnMuQWxsU3BlY2llc0VudHJ5UgphbGxTcGVjaWVzEmYK'
    'E2FsbF93YXRlcl9jbGFyaXRpZXMYCyADKAsyNi5hbmdsZXJzX2xvZy5DYXRjaEZpbHRlck9wdG'
    'lvbnMuQWxsV2F0ZXJDbGFyaXRpZXNFbnRyeVIRYWxsV2F0ZXJDbGFyaXRpZXMSOAoZaXNfY2F0'
    'Y2hfYW5kX3JlbGVhc2Vfb25seRgMIAEoCFIVaXNDYXRjaEFuZFJlbGVhc2VPbmx5EioKEWlzX2'
    'Zhdm9yaXRlc19vbmx5GA0gASgIUg9pc0Zhdm9yaXRlc09ubHkSPQoLZGF0ZV9yYW5nZXMYDiAD'
    'KAsyHC5hZGFpcl9mbHV0dGVyX2xpYi5EYXRlUmFuZ2VSCmRhdGVSYW5nZXMSMQoFYmFpdHMYDy'
    'ADKAsyGy5hbmdsZXJzX2xvZy5CYWl0QXR0YWNobWVudFIFYmFpdHMSLAoJY2F0Y2hfaWRzGBAg'
    'AygLMg8uYW5nbGVyc19sb2cuSWRSCGNhdGNoSWRzEi4KCmFuZ2xlcl9pZHMYESADKAsyDy5hbm'
    'dsZXJzX2xvZy5JZFIJYW5nbGVySWRzEjkKEGZpc2hpbmdfc3BvdF9pZHMYEiADKAsyDy5hbmds'
    'ZXJzX2xvZy5JZFIOZmlzaGluZ1Nwb3RJZHMSOgoRYm9keV9vZl93YXRlcl9pZHMYEyADKAsyDy'
    '5hbmdsZXJzX2xvZy5JZFIOYm9keU9mV2F0ZXJJZHMSLgoKbWV0aG9kX2lkcxgUIAMoCzIPLmFu'
    'Z2xlcnNfbG9nLklkUgltZXRob2RJZHMSMAoLc3BlY2llc19pZHMYFSADKAsyDy5hbmdsZXJzX2'
    'xvZy5JZFIKc3BlY2llc0lkcxI7ChF3YXRlcl9jbGFyaXR5X2lkcxgWIAMoCzIPLmFuZ2xlcnNf'
    'bG9nLklkUg93YXRlckNsYXJpdHlJZHMSLQoHcGVyaW9kcxgXIAMoDjITLmFuZ2xlcnNfbG9nLl'
    'BlcmlvZFIHcGVyaW9kcxItCgdzZWFzb25zGBggAygOMhMuYW5nbGVyc19sb2cuU2Vhc29uUgdz'
    'ZWFzb25zEj8KD3dpbmRfZGlyZWN0aW9ucxgZIAMoDjIWLmFuZ2xlcnNfbG9nLkRpcmVjdGlvbl'
    'IOd2luZERpcmVjdGlvbnMSQAoOc2t5X2NvbmRpdGlvbnMYGiADKA4yGS5hbmdsZXJzX2xvZy5T'
    'a3lDb25kaXRpb25SDXNreUNvbmRpdGlvbnMSNwoLbW9vbl9waGFzZXMYGyADKA4yFi5hbmdsZX'
    'JzX2xvZy5Nb29uUGhhc2VSCm1vb25QaGFzZXMSNAoKdGlkZV90eXBlcxgcIAMoDjIVLmFuZ2xl'
    'cnNfbG9nLlRpZGVUeXBlUgl0aWRlVHlwZXMSRwoSd2F0ZXJfZGVwdGhfZmlsdGVyGB0gASgLMh'
    'kuYW5nbGVyc19sb2cuTnVtYmVyRmlsdGVyUhB3YXRlckRlcHRoRmlsdGVyElMKGHdhdGVyX3Rl'
    'bXBlcmF0dXJlX2ZpbHRlchgeIAEoCzIZLmFuZ2xlcnNfbG9nLk51bWJlckZpbHRlclIWd2F0ZX'
    'JUZW1wZXJhdHVyZUZpbHRlchI+Cg1sZW5ndGhfZmlsdGVyGB8gASgLMhkuYW5nbGVyc19sb2cu'
    'TnVtYmVyRmlsdGVyUgxsZW5ndGhGaWx0ZXISPgoNd2VpZ2h0X2ZpbHRlchggIAEoCzIZLmFuZ2'
    'xlcnNfbG9nLk51bWJlckZpbHRlclIMd2VpZ2h0RmlsdGVyEkIKD3F1YW50aXR5X2ZpbHRlchgh'
    'IAEoCzIZLmFuZ2xlcnNfbG9nLk51bWJlckZpbHRlclIOcXVhbnRpdHlGaWx0ZXISTwoWYWlyX3'
    'RlbXBlcmF0dXJlX2ZpbHRlchgiIAEoCzIZLmFuZ2xlcnNfbG9nLk51bWJlckZpbHRlclIUYWly'
    'VGVtcGVyYXR1cmVGaWx0ZXISSQoTYWlyX3ByZXNzdXJlX2ZpbHRlchgjIAEoCzIZLmFuZ2xlcn'
    'NfbG9nLk51bWJlckZpbHRlclIRYWlyUHJlc3N1cmVGaWx0ZXISSQoTYWlyX2h1bWlkaXR5X2Zp'
    'bHRlchgkIAEoCzIZLmFuZ2xlcnNfbG9nLk51bWJlckZpbHRlclIRYWlySHVtaWRpdHlGaWx0ZX'
    'ISTQoVYWlyX3Zpc2liaWxpdHlfZmlsdGVyGCUgASgLMhkuYW5nbGVyc19sb2cuTnVtYmVyRmls'
    'dGVyUhNhaXJWaXNpYmlsaXR5RmlsdGVyEkUKEXdpbmRfc3BlZWRfZmlsdGVyGCYgASgLMhkuYW'
    '5nbGVyc19sb2cuTnVtYmVyRmlsdGVyUg93aW5kU3BlZWRGaWx0ZXISEgoEaG91chgnIAEoBVIE'
    'aG91chIUCgVtb250aBgoIAEoBVIFbW9udGgSJwoPaW5jbHVkZV9hbmdsZXJzGCkgASgIUg5pbm'
    'NsdWRlQW5nbGVycxIjCg1pbmNsdWRlX2JhaXRzGCogASgIUgxpbmNsdWRlQmFpdHMSNQoXaW5j'
    'bHVkZV9ib2RpZXNfb2Zfd2F0ZXIYKyABKAhSFGluY2x1ZGVCb2RpZXNPZldhdGVyEicKD2luY2'
    'x1ZGVfbWV0aG9kcxgsIAEoCFIOaW5jbHVkZU1ldGhvZHMSMgoVaW5jbHVkZV9maXNoaW5nX3Nw'
    'b3RzGC0gASgIUhNpbmNsdWRlRmlzaGluZ1Nwb3RzEi4KE2luY2x1ZGVfbW9vbl9waGFzZXMYLi'
    'ABKAhSEWluY2x1ZGVNb29uUGhhc2VzEicKD2luY2x1ZGVfc2Vhc29ucxgvIAEoCFIOaW5jbHVk'
    'ZVNlYXNvbnMSJwoPaW5jbHVkZV9zcGVjaWVzGDAgASgIUg5pbmNsdWRlU3BlY2llcxIsChJpbm'
    'NsdWRlX3RpZGVfdHlwZXMYMSABKAhSEGluY2x1ZGVUaWRlVHlwZXMSJwoPaW5jbHVkZV9wZXJp'
    'b2RzGDIgASgIUg5pbmNsdWRlUGVyaW9kcxI2ChdpbmNsdWRlX3dhdGVyX2NsYXJpdGllcxgzIA'
    'EoCFIVaW5jbHVkZVdhdGVyQ2xhcml0aWVzEkcKCGFsbF9nZWFyGDQgAygLMiwuYW5nbGVyc19s'
    'b2cuQ2F0Y2hGaWx0ZXJPcHRpb25zLkFsbEdlYXJFbnRyeVIHYWxsR2VhchIqCghnZWFyX2lkcx'
    'g1IAMoCzIPLmFuZ2xlcnNfbG9nLklkUgdnZWFySWRzEiEKDGluY2x1ZGVfZ2Vhchg2IAEoCFIL'
    'aW5jbHVkZUdlYXIaUgoPQWxsQW5nbGVyc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EikKBXZhbH'
    'VlGAIgASgLMhMuYW5nbGVyc19sb2cuQW5nbGVyUgV2YWx1ZToCOAEaTgoNQWxsQmFpdHNFbnRy'
    'eRIQCgNrZXkYASABKAlSA2tleRInCgV2YWx1ZRgCIAEoCzIRLmFuZ2xlcnNfbG9nLkJhaXRSBX'
    'ZhbHVlOgI4ARpdChVBbGxCb2RpZXNPZldhdGVyRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSLgoF'
    'dmFsdWUYAiABKAsyGC5hbmdsZXJzX2xvZy5Cb2R5T2ZXYXRlclIFdmFsdWU6AjgBGlEKD0FsbE'
    'NhdGNoZXNFbnRyeRIQCgNrZXkYASABKAlSA2tleRIoCgV2YWx1ZRgCIAEoCzISLmFuZ2xlcnNf'
    'bG9nLkNhdGNoUgV2YWx1ZToCOAEaXAoUQWxsRmlzaGluZ1Nwb3RzRW50cnkSEAoDa2V5GAEgAS'
    'gJUgNrZXkSLgoFdmFsdWUYAiABKAsyGC5hbmdsZXJzX2xvZy5GaXNoaW5nU3BvdFIFdmFsdWU6'
    'AjgBGlIKD0FsbE1ldGhvZHNFbnRyeRIQCgNrZXkYASABKAlSA2tleRIpCgV2YWx1ZRgCIAEoCz'
    'ITLmFuZ2xlcnNfbG9nLk1ldGhvZFIFdmFsdWU6AjgBGlMKD0FsbFNwZWNpZXNFbnRyeRIQCgNr'
    'ZXkYASABKAlSA2tleRIqCgV2YWx1ZRgCIAEoCzIULmFuZ2xlcnNfbG9nLlNwZWNpZXNSBXZhbH'
    'VlOgI4ARpfChZBbGxXYXRlckNsYXJpdGllc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5Ei8KBXZh'
    'bHVlGAIgASgLMhkuYW5nbGVyc19sb2cuV2F0ZXJDbGFyaXR5UgV2YWx1ZToCOAEaTQoMQWxsR2'
    'VhckVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EicKBXZhbHVlGAIgASgLMhEuYW5nbGVyc19sb2cu'
    'R2VhclIFdmFsdWU6AjgBIl0KBU9yZGVyEgsKB3Vua25vd24QABIUChBuZXdlc3RfdG9fb2xkZX'
    'N0EAESGAoUaGVhdmllc3RfdG9fbGlnaHRlc3QQAhIXChNsb25nZXN0X3RvX3Nob3J0ZXN0EAM=');

@$core.Deprecated('Use catchReportDescriptor instead')
const CatchReport$json = {
  '1': 'CatchReport',
  '2': [
    {
      '1': 'models',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchReportModel',
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
      '6': '.anglers_log.Catch',
      '10': 'lastCatch'
    },
    {
      '1': 'contains_now',
      '3': 6,
      '4': 1,
      '5': 8,
      '8': {'3': true},
      '10': 'containsNow',
    },
  ],
};

/// Descriptor for `CatchReport`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List catchReportDescriptor = $convert.base64Decode(
    'CgtDYXRjaFJlcG9ydBI1CgZtb2RlbHMYASADKAsyHS5hbmdsZXJzX2xvZy5DYXRjaFJlcG9ydE'
    '1vZGVsUgZtb2RlbHMSLQoTbXNfc2luY2VfbGFzdF9jYXRjaBgCIAEoBFIQbXNTaW5jZUxhc3RD'
    'YXRjaBIxCgpsYXN0X2NhdGNoGAMgASgLMhIuYW5nbGVyc19sb2cuQ2F0Y2hSCWxhc3RDYXRjaB'
    'IlCgxjb250YWluc19ub3cYBiABKAhCAhgBUgtjb250YWluc05vdw==');

@$core.Deprecated('Use catchReportModelDescriptor instead')
const CatchReportModel$json = {
  '1': 'CatchReportModel',
  '2': [
    {
      '1': 'date_range',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.adair_flutter_lib.DateRange',
      '10': 'dateRange'
    },
    {
      '1': 'catch_ids',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'catchIds'
    },
    {
      '1': 'per_hour',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchReportModel.PerHourEntry',
      '10': 'perHour'
    },
    {
      '1': 'per_month',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchReportModel.PerMonthEntry',
      '10': 'perMonth'
    },
    {
      '1': 'per_moon_phase',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchReportModel.PerMoonPhaseEntry',
      '10': 'perMoonPhase'
    },
    {
      '1': 'per_period',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchReportModel.PerPeriodEntry',
      '10': 'perPeriod'
    },
    {
      '1': 'per_season',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchReportModel.PerSeasonEntry',
      '10': 'perSeason'
    },
    {
      '1': 'per_tide_type',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchReportModel.PerTideTypeEntry',
      '10': 'perTideType'
    },
    {
      '1': 'per_angler',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchReportModel.PerAnglerEntry',
      '10': 'perAngler'
    },
    {
      '1': 'per_body_of_water',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchReportModel.PerBodyOfWaterEntry',
      '10': 'perBodyOfWater'
    },
    {
      '1': 'per_method',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchReportModel.PerMethodEntry',
      '10': 'perMethod'
    },
    {
      '1': 'per_fishing_spot',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchReportModel.PerFishingSpotEntry',
      '10': 'perFishingSpot'
    },
    {
      '1': 'per_species',
      '3': 13,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchReportModel.PerSpeciesEntry',
      '10': 'perSpecies'
    },
    {
      '1': 'per_water_clarity',
      '3': 14,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchReportModel.PerWaterClarityEntry',
      '10': 'perWaterClarity'
    },
    {
      '1': 'per_bait',
      '3': 15,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchReportModel.PerBaitEntry',
      '10': 'perBait'
    },
    {
      '1': 'per_gear',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CatchReportModel.PerGearEntry',
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
    'ChBDYXRjaFJlcG9ydE1vZGVsEjsKCmRhdGVfcmFuZ2UYASABKAsyHC5hZGFpcl9mbHV0dGVyX2'
    'xpYi5EYXRlUmFuZ2VSCWRhdGVSYW5nZRIsCgljYXRjaF9pZHMYAiADKAsyDy5hbmdsZXJzX2xv'
    'Zy5JZFIIY2F0Y2hJZHMSRQoIcGVyX2hvdXIYAyADKAsyKi5hbmdsZXJzX2xvZy5DYXRjaFJlcG'
    '9ydE1vZGVsLlBlckhvdXJFbnRyeVIHcGVySG91chJICglwZXJfbW9udGgYBCADKAsyKy5hbmds'
    'ZXJzX2xvZy5DYXRjaFJlcG9ydE1vZGVsLlBlck1vbnRoRW50cnlSCHBlck1vbnRoElUKDnBlcl'
    '9tb29uX3BoYXNlGAUgAygLMi8uYW5nbGVyc19sb2cuQ2F0Y2hSZXBvcnRNb2RlbC5QZXJNb29u'
    'UGhhc2VFbnRyeVIMcGVyTW9vblBoYXNlEksKCnBlcl9wZXJpb2QYBiADKAsyLC5hbmdsZXJzX2'
    'xvZy5DYXRjaFJlcG9ydE1vZGVsLlBlclBlcmlvZEVudHJ5UglwZXJQZXJpb2QSSwoKcGVyX3Nl'
    'YXNvbhgHIAMoCzIsLmFuZ2xlcnNfbG9nLkNhdGNoUmVwb3J0TW9kZWwuUGVyU2Vhc29uRW50cn'
    'lSCXBlclNlYXNvbhJSCg1wZXJfdGlkZV90eXBlGAggAygLMi4uYW5nbGVyc19sb2cuQ2F0Y2hS'
    'ZXBvcnRNb2RlbC5QZXJUaWRlVHlwZUVudHJ5UgtwZXJUaWRlVHlwZRJLCgpwZXJfYW5nbGVyGA'
    'kgAygLMiwuYW5nbGVyc19sb2cuQ2F0Y2hSZXBvcnRNb2RlbC5QZXJBbmdsZXJFbnRyeVIJcGVy'
    'QW5nbGVyElwKEXBlcl9ib2R5X29mX3dhdGVyGAogAygLMjEuYW5nbGVyc19sb2cuQ2F0Y2hSZX'
    'BvcnRNb2RlbC5QZXJCb2R5T2ZXYXRlckVudHJ5Ug5wZXJCb2R5T2ZXYXRlchJLCgpwZXJfbWV0'
    'aG9kGAsgAygLMiwuYW5nbGVyc19sb2cuQ2F0Y2hSZXBvcnRNb2RlbC5QZXJNZXRob2RFbnRyeV'
    'IJcGVyTWV0aG9kElsKEHBlcl9maXNoaW5nX3Nwb3QYDCADKAsyMS5hbmdsZXJzX2xvZy5DYXRj'
    'aFJlcG9ydE1vZGVsLlBlckZpc2hpbmdTcG90RW50cnlSDnBlckZpc2hpbmdTcG90Ek4KC3Blcl'
    '9zcGVjaWVzGA0gAygLMi0uYW5nbGVyc19sb2cuQ2F0Y2hSZXBvcnRNb2RlbC5QZXJTcGVjaWVz'
    'RW50cnlSCnBlclNwZWNpZXMSXgoRcGVyX3dhdGVyX2NsYXJpdHkYDiADKAsyMi5hbmdsZXJzX2'
    'xvZy5DYXRjaFJlcG9ydE1vZGVsLlBlcldhdGVyQ2xhcml0eUVudHJ5Ug9wZXJXYXRlckNsYXJp'
    'dHkSRQoIcGVyX2JhaXQYDyADKAsyKi5hbmdsZXJzX2xvZy5DYXRjaFJlcG9ydE1vZGVsLlBlck'
    'JhaXRFbnRyeVIHcGVyQmFpdBJFCghwZXJfZ2VhchgQIAMoCzIqLmFuZ2xlcnNfbG9nLkNhdGNo'
    'UmVwb3J0TW9kZWwuUGVyR2VhckVudHJ5UgdwZXJHZWFyGjoKDFBlckhvdXJFbnRyeRIQCgNrZX'
    'kYASABKAVSA2tleRIUCgV2YWx1ZRgCIAEoBVIFdmFsdWU6AjgBGjsKDVBlck1vbnRoRW50cnkS'
    'EAoDa2V5GAEgASgFUgNrZXkSFAoFdmFsdWUYAiABKAVSBXZhbHVlOgI4ARo/ChFQZXJNb29uUG'
    'hhc2VFbnRyeRIQCgNrZXkYASABKAVSA2tleRIUCgV2YWx1ZRgCIAEoBVIFdmFsdWU6AjgBGjwK'
    'DlBlclBlcmlvZEVudHJ5EhAKA2tleRgBIAEoBVIDa2V5EhQKBXZhbHVlGAIgASgFUgV2YWx1ZT'
    'oCOAEaPAoOUGVyU2Vhc29uRW50cnkSEAoDa2V5GAEgASgFUgNrZXkSFAoFdmFsdWUYAiABKAVS'
    'BXZhbHVlOgI4ARo+ChBQZXJUaWRlVHlwZUVudHJ5EhAKA2tleRgBIAEoBVIDa2V5EhQKBXZhbH'
    'VlGAIgASgFUgV2YWx1ZToCOAEaPAoOUGVyQW5nbGVyRW50cnkSEAoDa2V5GAEgASgJUgNrZXkS'
    'FAoFdmFsdWUYAiABKAVSBXZhbHVlOgI4ARpBChNQZXJCb2R5T2ZXYXRlckVudHJ5EhAKA2tleR'
    'gBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgFUgV2YWx1ZToCOAEaPAoOUGVyTWV0aG9kRW50cnkS'
    'EAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAVSBXZhbHVlOgI4ARpBChNQZXJGaXNoaW'
    '5nU3BvdEVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgFUgV2YWx1ZToCOAEa'
    'PQoPUGVyU3BlY2llc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgFUgV2YW'
    'x1ZToCOAEaQgoUUGVyV2F0ZXJDbGFyaXR5RW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFs'
    'dWUYAiABKAVSBXZhbHVlOgI4ARo6CgxQZXJCYWl0RW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFA'
    'oFdmFsdWUYAiABKAVSBXZhbHVlOgI4ARo6CgxQZXJHZWFyRW50cnkSEAoDa2V5GAEgASgJUgNr'
    'ZXkSFAoFdmFsdWUYAiABKAVSBXZhbHVlOgI4AQ==');

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
      '6': '.anglers_log.TripFilterOptions.AllCatchesEntry',
      '10': 'allCatches'
    },
    {
      '1': 'all_trips',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.TripFilterOptions.AllTripsEntry',
      '10': 'allTrips'
    },
    {
      '1': 'catch_weight_system',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.anglers_log.MeasurementSystem',
      '10': 'catchWeightSystem'
    },
    {
      '1': 'catch_length_system',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.anglers_log.MeasurementSystem',
      '10': 'catchLengthSystem'
    },
    {
      '1': 'date_range',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.adair_flutter_lib.DateRange',
      '10': 'dateRange'
    },
    {
      '1': 'trip_ids',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Id',
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
      '6': '.anglers_log.Catch',
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
      '6': '.anglers_log.Trip',
      '10': 'value'
    },
  ],
  '7': {'7': true},
};

/// Descriptor for `TripFilterOptions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tripFilterOptionsDescriptor = $convert.base64Decode(
    'ChFUcmlwRmlsdGVyT3B0aW9ucxIrChFjdXJyZW50X3RpbWVzdGFtcBgBIAEoBFIQY3VycmVudF'
    'RpbWVzdGFtcBIqChFjdXJyZW50X3RpbWVfem9uZRgCIAEoCVIPY3VycmVudFRpbWVab25lEk8K'
    'C2FsbF9jYXRjaGVzGAMgAygLMi4uYW5nbGVyc19sb2cuVHJpcEZpbHRlck9wdGlvbnMuQWxsQ2'
    'F0Y2hlc0VudHJ5UgphbGxDYXRjaGVzEkkKCWFsbF90cmlwcxgEIAMoCzIsLmFuZ2xlcnNfbG9n'
    'LlRyaXBGaWx0ZXJPcHRpb25zLkFsbFRyaXBzRW50cnlSCGFsbFRyaXBzEk4KE2NhdGNoX3dlaW'
    'dodF9zeXN0ZW0YBSABKA4yHi5hbmdsZXJzX2xvZy5NZWFzdXJlbWVudFN5c3RlbVIRY2F0Y2hX'
    'ZWlnaHRTeXN0ZW0STgoTY2F0Y2hfbGVuZ3RoX3N5c3RlbRgGIAEoDjIeLmFuZ2xlcnNfbG9nLk'
    '1lYXN1cmVtZW50U3lzdGVtUhFjYXRjaExlbmd0aFN5c3RlbRI7CgpkYXRlX3JhbmdlGAcgASgL'
    'MhwuYWRhaXJfZmx1dHRlcl9saWIuRGF0ZVJhbmdlUglkYXRlUmFuZ2USKgoIdHJpcF9pZHMYCC'
    'ADKAsyDy5hbmdsZXJzX2xvZy5JZFIHdHJpcElkcxpRCg9BbGxDYXRjaGVzRW50cnkSEAoDa2V5'
    'GAEgASgJUgNrZXkSKAoFdmFsdWUYAiABKAsyEi5hbmdsZXJzX2xvZy5DYXRjaFIFdmFsdWU6Aj'
    'gBGk4KDUFsbFRyaXBzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSJwoFdmFsdWUYAiABKAsyES5h'
    'bmdsZXJzX2xvZy5UcmlwUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use tripReportDescriptor instead')
const TripReport$json = {
  '1': 'TripReport',
  '2': [
    {
      '1': 'date_range',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.adair_flutter_lib.DateRange',
      '10': 'dateRange'
    },
    {
      '1': 'trips',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.Trip',
      '10': 'trips'
    },
    {'1': 'total_ms', '3': 3, '4': 1, '5': 4, '10': 'totalMs'},
    {
      '1': 'longest_trip',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Trip',
      '10': 'longestTrip'
    },
    {
      '1': 'last_trip',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Trip',
      '10': 'lastTrip'
    },
    {
      '1': 'ms_since_last_trip',
      '3': 6,
      '4': 1,
      '5': 4,
      '10': 'msSinceLastTrip'
    },
    {
      '1': 'contains_now',
      '3': 7,
      '4': 1,
      '5': 8,
      '8': {'3': true},
      '10': 'containsNow',
    },
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
      '6': '.anglers_log.MultiMeasurement',
      '10': 'averageWeightPerTrip'
    },
    {
      '1': 'most_weight_in_single_trip',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'mostWeightInSingleTrip'
    },
    {
      '1': 'most_weight_trip',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Trip',
      '10': 'mostWeightTrip'
    },
    {
      '1': 'average_length_per_trip',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'averageLengthPerTrip'
    },
    {
      '1': 'most_length_in_single_trip',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'mostLengthInSingleTrip'
    },
    {
      '1': 'most_length_trip',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Trip',
      '10': 'mostLengthTrip'
    },
  ],
};

/// Descriptor for `TripReport`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tripReportDescriptor = $convert.base64Decode(
    'CgpUcmlwUmVwb3J0EjsKCmRhdGVfcmFuZ2UYASABKAsyHC5hZGFpcl9mbHV0dGVyX2xpYi5EYX'
    'RlUmFuZ2VSCWRhdGVSYW5nZRInCgV0cmlwcxgCIAMoCzIRLmFuZ2xlcnNfbG9nLlRyaXBSBXRy'
    'aXBzEhkKCHRvdGFsX21zGAMgASgEUgd0b3RhbE1zEjQKDGxvbmdlc3RfdHJpcBgEIAEoCzIRLm'
    'FuZ2xlcnNfbG9nLlRyaXBSC2xvbmdlc3RUcmlwEi4KCWxhc3RfdHJpcBgFIAEoCzIRLmFuZ2xl'
    'cnNfbG9nLlRyaXBSCGxhc3RUcmlwEisKEm1zX3NpbmNlX2xhc3RfdHJpcBgGIAEoBFIPbXNTaW'
    '5jZUxhc3RUcmlwEiUKDGNvbnRhaW5zX25vdxgHIAEoCEICGAFSC2NvbnRhaW5zTm93EjcKGGF2'
    'ZXJhZ2VfY2F0Y2hlc19wZXJfdHJpcBgIIAEoAVIVYXZlcmFnZUNhdGNoZXNQZXJUcmlwEjcKGG'
    'F2ZXJhZ2VfY2F0Y2hlc19wZXJfaG91chgJIAEoAVIVYXZlcmFnZUNhdGNoZXNQZXJIb3VyEjsK'
    'GmF2ZXJhZ2VfbXNfYmV0d2Vlbl9jYXRjaGVzGAogASgEUhdhdmVyYWdlTXNCZXR3ZWVuQ2F0Y2'
    'hlcxImCg9hdmVyYWdlX3RyaXBfbXMYCyABKARSDWF2ZXJhZ2VUcmlwTXMSNwoYYXZlcmFnZV9t'
    'c19iZXR3ZWVuX3RyaXBzGAwgASgEUhVhdmVyYWdlTXNCZXR3ZWVuVHJpcHMSVAoXYXZlcmFnZV'
    '93ZWlnaHRfcGVyX3RyaXAYDSABKAsyHS5hbmdsZXJzX2xvZy5NdWx0aU1lYXN1cmVtZW50UhRh'
    'dmVyYWdlV2VpZ2h0UGVyVHJpcBJZChptb3N0X3dlaWdodF9pbl9zaW5nbGVfdHJpcBgOIAEoCz'
    'IdLmFuZ2xlcnNfbG9nLk11bHRpTWVhc3VyZW1lbnRSFm1vc3RXZWlnaHRJblNpbmdsZVRyaXAS'
    'OwoQbW9zdF93ZWlnaHRfdHJpcBgPIAEoCzIRLmFuZ2xlcnNfbG9nLlRyaXBSDm1vc3RXZWlnaH'
    'RUcmlwElQKF2F2ZXJhZ2VfbGVuZ3RoX3Blcl90cmlwGBAgASgLMh0uYW5nbGVyc19sb2cuTXVs'
    'dGlNZWFzdXJlbWVudFIUYXZlcmFnZUxlbmd0aFBlclRyaXASWQoabW9zdF9sZW5ndGhfaW5fc2'
    'luZ2xlX3RyaXAYESABKAsyHS5hbmdsZXJzX2xvZy5NdWx0aU1lYXN1cmVtZW50UhZtb3N0TGVu'
    'Z3RoSW5TaW5nbGVUcmlwEjsKEG1vc3RfbGVuZ3RoX3RyaXAYEiABKAsyES5hbmdsZXJzX2xvZy'
    '5UcmlwUg5tb3N0TGVuZ3RoVHJpcA==');

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
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglers_log.Id', '10': 'id'},
    {'1': 'start_timestamp', '3': 2, '4': 1, '5': 4, '10': 'startTimestamp'},
    {'1': 'end_timestamp', '3': 3, '4': 1, '5': 4, '10': 'endTimestamp'},
    {'1': 'time_zone', '3': 4, '4': 1, '5': 9, '10': 'timeZone'},
    {
      '1': 'points',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.GpsTrailPoint',
      '10': 'points'
    },
    {
      '1': 'body_of_water_id',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.Id',
      '10': 'bodyOfWaterId'
    },
  ],
};

/// Descriptor for `GpsTrail`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gpsTrailDescriptor = $convert.base64Decode(
    'CghHcHNUcmFpbBIfCgJpZBgBIAEoCzIPLmFuZ2xlcnNfbG9nLklkUgJpZBInCg9zdGFydF90aW'
    '1lc3RhbXAYAiABKARSDnN0YXJ0VGltZXN0YW1wEiMKDWVuZF90aW1lc3RhbXAYAyABKARSDGVu'
    'ZFRpbWVzdGFtcBIbCgl0aW1lX3pvbmUYBCABKAlSCHRpbWVab25lEjIKBnBvaW50cxgFIAMoCz'
    'IaLmFuZ2xlcnNfbG9nLkdwc1RyYWlsUG9pbnRSBnBvaW50cxI4ChBib2R5X29mX3dhdGVyX2lk'
    'GAYgASgLMg8uYW5nbGVyc19sb2cuSWRSDWJvZHlPZldhdGVySWQ=');

@$core.Deprecated('Use gearDescriptor instead')
const Gear$json = {
  '1': 'Gear',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.anglers_log.Id', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'image_name', '3': 3, '4': 1, '5': 9, '10': 'imageName'},
    {'1': 'rod_make_model', '3': 4, '4': 1, '5': 9, '10': 'rodMakeModel'},
    {'1': 'rod_serial_number', '3': 5, '4': 1, '5': 9, '10': 'rodSerialNumber'},
    {
      '1': 'rod_length',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'rodLength'
    },
    {
      '1': 'rod_action',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.anglers_log.RodAction',
      '10': 'rodAction'
    },
    {
      '1': 'rod_power',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.anglers_log.RodPower',
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
      '6': '.anglers_log.MultiMeasurement',
      '10': 'lineRating'
    },
    {'1': 'line_color', '3': 14, '4': 1, '5': 9, '10': 'lineColor'},
    {
      '1': 'leader_length',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'leaderLength'
    },
    {
      '1': 'leader_rating',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'leaderRating'
    },
    {
      '1': 'tippet_length',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'tippetLength'
    },
    {
      '1': 'tippet_rating',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'tippetRating'
    },
    {'1': 'hook_make_model', '3': 19, '4': 1, '5': 9, '10': 'hookMakeModel'},
    {
      '1': 'hook_size',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.anglers_log.MultiMeasurement',
      '10': 'hookSize'
    },
    {
      '1': 'custom_entity_values',
      '3': 21,
      '4': 3,
      '5': 11,
      '6': '.anglers_log.CustomEntityValue',
      '10': 'customEntityValues'
    },
  ],
};

/// Descriptor for `Gear`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gearDescriptor = $convert.base64Decode(
    'CgRHZWFyEh8KAmlkGAEgASgLMg8uYW5nbGVyc19sb2cuSWRSAmlkEhIKBG5hbWUYAiABKAlSBG'
    '5hbWUSHQoKaW1hZ2VfbmFtZRgDIAEoCVIJaW1hZ2VOYW1lEiQKDnJvZF9tYWtlX21vZGVsGAQg'
    'ASgJUgxyb2RNYWtlTW9kZWwSKgoRcm9kX3NlcmlhbF9udW1iZXIYBSABKAlSD3JvZFNlcmlhbE'
    '51bWJlchI8Cgpyb2RfbGVuZ3RoGAYgASgLMh0uYW5nbGVyc19sb2cuTXVsdGlNZWFzdXJlbWVu'
    'dFIJcm9kTGVuZ3RoEjUKCnJvZF9hY3Rpb24YByABKA4yFi5hbmdsZXJzX2xvZy5Sb2RBY3Rpb2'
    '5SCXJvZEFjdGlvbhIyCglyb2RfcG93ZXIYCCABKA4yFS5hbmdsZXJzX2xvZy5Sb2RQb3dlclII'
    'cm9kUG93ZXISJgoPcmVlbF9tYWtlX21vZGVsGAkgASgJUg1yZWVsTWFrZU1vZGVsEiwKEnJlZW'
    'xfc2VyaWFsX251bWJlchgKIAEoCVIQcmVlbFNlcmlhbE51bWJlchIbCglyZWVsX3NpemUYCyAB'
    'KAlSCHJlZWxTaXplEiYKD2xpbmVfbWFrZV9tb2RlbBgMIAEoCVINbGluZU1ha2VNb2RlbBI+Cg'
    'tsaW5lX3JhdGluZxgNIAEoCzIdLmFuZ2xlcnNfbG9nLk11bHRpTWVhc3VyZW1lbnRSCmxpbmVS'
    'YXRpbmcSHQoKbGluZV9jb2xvchgOIAEoCVIJbGluZUNvbG9yEkIKDWxlYWRlcl9sZW5ndGgYDy'
    'ABKAsyHS5hbmdsZXJzX2xvZy5NdWx0aU1lYXN1cmVtZW50UgxsZWFkZXJMZW5ndGgSQgoNbGVh'
    'ZGVyX3JhdGluZxgQIAEoCzIdLmFuZ2xlcnNfbG9nLk11bHRpTWVhc3VyZW1lbnRSDGxlYWRlcl'
    'JhdGluZxJCCg10aXBwZXRfbGVuZ3RoGBEgASgLMh0uYW5nbGVyc19sb2cuTXVsdGlNZWFzdXJl'
    'bWVudFIMdGlwcGV0TGVuZ3RoEkIKDXRpcHBldF9yYXRpbmcYEiABKAsyHS5hbmdsZXJzX2xvZy'
    '5NdWx0aU1lYXN1cmVtZW50Ugx0aXBwZXRSYXRpbmcSJgoPaG9va19tYWtlX21vZGVsGBMgASgJ'
    'Ug1ob29rTWFrZU1vZGVsEjoKCWhvb2tfc2l6ZRgUIAEoCzIdLmFuZ2xlcnNfbG9nLk11bHRpTW'
    'Vhc3VyZW1lbnRSCGhvb2tTaXplElAKFGN1c3RvbV9lbnRpdHlfdmFsdWVzGBUgAygLMh4uYW5n'
    'bGVyc19sb2cuQ3VzdG9tRW50aXR5VmFsdWVSEmN1c3RvbUVudGl0eVZhbHVlcw==');
