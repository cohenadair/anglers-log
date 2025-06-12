//
//  Generated code. Do not modify.
//  source: userpolls.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use optionDescriptor instead')
const Option$json = {
  '1': 'Option',
  '2': [
    {'1': 'vote_count', '3': 1, '4': 1, '5': 5, '10': 'voteCount'},
    {
      '1': 'localizations',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.userpolls.Option.LocalizationsEntry',
      '10': 'localizations'
    },
  ],
  '3': [Option_LocalizationsEntry$json],
};

@$core.Deprecated('Use optionDescriptor instead')
const Option_LocalizationsEntry$json = {
  '1': 'LocalizationsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Option`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List optionDescriptor = $convert.base64Decode(
    'CgZPcHRpb24SHQoKdm90ZV9jb3VudBgBIAEoBVIJdm90ZUNvdW50EkoKDWxvY2FsaXphdGlvbn'
    'MYAiADKAsyJC51c2VycG9sbHMuT3B0aW9uLkxvY2FsaXphdGlvbnNFbnRyeVINbG9jYWxpemF0'
    'aW9ucxpAChJMb2NhbGl6YXRpb25zRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAi'
    'ABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use pollDescriptor instead')
const Poll$json = {
  '1': 'Poll',
  '2': [
    {
      '1': 'updated_at_timestamp',
      '3': 1,
      '4': 1,
      '5': 4,
      '10': 'updatedAtTimestamp'
    },
    {
      '1': 'coming_soon',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.userpolls.Poll.ComingSoonEntry',
      '10': 'comingSoon'
    },
    {
      '1': 'options',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.userpolls.Option',
      '10': 'options'
    },
  ],
  '3': [Poll_ComingSoonEntry$json],
};

@$core.Deprecated('Use pollDescriptor instead')
const Poll_ComingSoonEntry$json = {
  '1': 'ComingSoonEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Poll`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pollDescriptor = $convert.base64Decode(
    'CgRQb2xsEjAKFHVwZGF0ZWRfYXRfdGltZXN0YW1wGAEgASgEUhJ1cGRhdGVkQXRUaW1lc3RhbX'
    'ASQAoLY29taW5nX3Nvb24YAiADKAsyHy51c2VycG9sbHMuUG9sbC5Db21pbmdTb29uRW50cnlS'
    'CmNvbWluZ1Nvb24SKwoHb3B0aW9ucxgDIAMoCzIRLnVzZXJwb2xscy5PcHRpb25SB29wdGlvbn'
    'MaPQoPQ29taW5nU29vbkVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2'
    'YWx1ZToCOAE=');

@$core.Deprecated('Use pollsDescriptor instead')
const Polls$json = {
  '1': 'Polls',
  '2': [
    {
      '1': 'free',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.userpolls.Poll',
      '10': 'free'
    },
    {'1': 'pro', '3': 2, '4': 1, '5': 11, '6': '.userpolls.Poll', '10': 'pro'},
  ],
};

/// Descriptor for `Polls`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pollsDescriptor = $convert.base64Decode(
    'CgVQb2xscxIjCgRmcmVlGAEgASgLMg8udXNlcnBvbGxzLlBvbGxSBGZyZWUSIQoDcHJvGAIgAS'
    'gLMg8udXNlcnBvbGxzLlBvbGxSA3Bybw==');

// ignore_for_file: undefined_named_parameter,no_leading_underscores_for_local_identifiers
