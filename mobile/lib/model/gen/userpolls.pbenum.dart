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

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Poll_Type extends $pb.ProtobufEnum {
  static const Poll_Type unknown =
      Poll_Type._(0, _omitEnumNames ? '' : 'unknown');
  static const Poll_Type free = Poll_Type._(1, _omitEnumNames ? '' : 'free');
  static const Poll_Type pro = Poll_Type._(2, _omitEnumNames ? '' : 'pro');

  static const $core.List<Poll_Type> values = <Poll_Type>[
    unknown,
    free,
    pro,
  ];

  static final $core.List<Poll_Type?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Poll_Type? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Poll_Type._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
// ignore_for_file: undefined_named_parameter,no_leading_underscores_for_local_identifiers
// ignore_for_file: undefined_named_parameter,no_leading_underscores_for_local_identifiers
// ignore_for_file: undefined_named_parameter,no_leading_underscores_for_local_identifiers
// ignore_for_file: undefined_named_parameter,no_leading_underscores_for_local_identifiers
// ignore_for_file: undefined_named_parameter,no_leading_underscores_for_local_identifiers
// ignore_for_file: undefined_named_parameter,no_leading_underscores_for_local_identifiers
// ignore_for_file: undefined_named_parameter,no_leading_underscores_for_local_identifiers
