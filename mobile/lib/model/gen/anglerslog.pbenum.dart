///
//  Generated code. Do not modify.
//  source: anglerslog.proto
//
// @dart = 2.3
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class CustomEntity_Type extends $pb.ProtobufEnum {
  static const CustomEntity_Type BOOL = CustomEntity_Type._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'BOOL');
  static const CustomEntity_Type NUMBER = CustomEntity_Type._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'NUMBER');
  static const CustomEntity_Type TEXT = CustomEntity_Type._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'TEXT');

  static const $core.List<CustomEntity_Type> values = <CustomEntity_Type>[
    BOOL,
    NUMBER,
    TEXT,
  ];

  static final $core.Map<$core.int, CustomEntity_Type> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static CustomEntity_Type valueOf($core.int value) => _byValue[value];

  const CustomEntity_Type._($core.int v, $core.String n) : super(v, n);
}

// ignore_for_file: constant_identifier_names,lines_longer_than_80_chars,directives_ordering,unnecessary_const,prefer_mixin,implementation_imports
