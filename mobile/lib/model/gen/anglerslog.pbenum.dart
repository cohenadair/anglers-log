///
//  Generated code. Do not modify.
//  source: anglerslog.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class Period extends $pb.ProtobufEnum {
  static const Period all = Period._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'all');
  static const Period none = Period._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'none');
  static const Period dawn = Period._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'dawn');
  static const Period morning = Period._(
      3,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'morning');
  static const Period midday = Period._(
      4,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'midday');
  static const Period afternoon = Period._(
      5,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'afternoon');
  static const Period dusk = Period._(
      6,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'dusk');
  static const Period night = Period._(
      7,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'night');

  static const $core.List<Period> values = <Period>[
    all,
    none,
    dawn,
    morning,
    midday,
    afternoon,
    dusk,
    night,
  ];

  static final $core.Map<$core.int, Period> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Period? valueOf($core.int value) => _byValue[value];

  const Period._($core.int v, $core.String n) : super(v, n);
}

class CustomEntity_Type extends $pb.ProtobufEnum {
  static const CustomEntity_Type boolean = CustomEntity_Type._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'boolean');
  static const CustomEntity_Type number = CustomEntity_Type._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'number');
  static const CustomEntity_Type text = CustomEntity_Type._(
      2,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'text');

  static const $core.List<CustomEntity_Type> values = <CustomEntity_Type>[
    boolean,
    number,
    text,
  ];

  static final $core.Map<$core.int, CustomEntity_Type> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static CustomEntity_Type? valueOf($core.int value) => _byValue[value];

  const CustomEntity_Type._($core.int v, $core.String n) : super(v, n);
}

class Report_Type extends $pb.ProtobufEnum {
  static const Report_Type summary = Report_Type._(
      0,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'summary');
  static const Report_Type comparison = Report_Type._(
      1,
      const $core.bool.fromEnvironment('protobuf.omit_enum_names')
          ? ''
          : 'comparison');

  static const $core.List<Report_Type> values = <Report_Type>[
    summary,
    comparison,
  ];

  static final $core.Map<$core.int, Report_Type> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Report_Type? valueOf($core.int value) => _byValue[value];

  const Report_Type._($core.int v, $core.String n) : super(v, n);
}

// ignore_for_file: constant_identifier_names,lines_longer_than_80_chars,directives_ordering,prefer_mixin,implementation_imports
