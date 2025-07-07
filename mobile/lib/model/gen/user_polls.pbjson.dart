//
//  Generated code. Do not modify.
//  source: user_polls.proto
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
      '6': '.user_polls.Option.LocalizationsEntry',
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
    'CgZPcHRpb24SHQoKdm90ZV9jb3VudBgBIAEoBVIJdm90ZUNvdW50EksKDWxvY2FsaXphdGlvbn'
    'MYAiADKAsyJS51c2VyX3BvbGxzLk9wdGlvbi5Mb2NhbGl6YXRpb25zRW50cnlSDWxvY2FsaXph'
    'dGlvbnMaQAoSTG9jYWxpemF0aW9uc0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGA'
    'IgASgJUgV2YWx1ZToCOAE=');

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
      '6': '.user_polls.Poll.ComingSoonEntry',
      '10': 'comingSoon'
    },
    {
      '1': 'options',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.user_polls.Option',
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
    'ASQQoLY29taW5nX3Nvb24YAiADKAsyIC51c2VyX3BvbGxzLlBvbGwuQ29taW5nU29vbkVudHJ5'
    'Ugpjb21pbmdTb29uEiwKB29wdGlvbnMYAyADKAsyEi51c2VyX3BvbGxzLk9wdGlvblIHb3B0aW'
    '9ucxo9Cg9Db21pbmdTb29uRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlS'
    'BXZhbHVlOgI4AQ==');

@$core.Deprecated('Use pollsDescriptor instead')
const Polls$json = {
  '1': 'Polls',
  '2': [
    {
      '1': 'free',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.user_polls.Poll',
      '10': 'free'
    },
    {'1': 'pro', '3': 2, '4': 1, '5': 11, '6': '.user_polls.Poll', '10': 'pro'},
  ],
};

/// Descriptor for `Polls`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pollsDescriptor = $convert.base64Decode(
    'CgVQb2xscxIkCgRmcmVlGAEgASgLMhAudXNlcl9wb2xscy5Qb2xsUgRmcmVlEiIKA3BybxgCIA'
    'EoCzIQLnVzZXJfcG9sbHMuUG9sbFIDcHJv');
