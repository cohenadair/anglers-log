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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Option extends $pb.GeneratedMessage {
  factory Option({
    $core.int? voteCount,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? localizations,
  }) {
    final result = create();
    if (voteCount != null) result.voteCount = voteCount;
    if (localizations != null) result.localizations.addEntries(localizations);
    return result;
  }

  Option._();

  factory Option.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Option.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Option',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'userpolls'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'voteCount', $pb.PbFieldType.O3)
    ..m<$core.String, $core.String>(2, _omitFieldNames ? '' : 'localizations',
        entryClassName: 'Option.LocalizationsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('userpolls'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Option clone() => Option()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Option copyWith(void Function(Option) updates) =>
      super.copyWith((message) => updates(message as Option)) as Option;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Option create() => Option._();
  @$core.override
  Option createEmptyInstance() => create();
  static $pb.PbList<Option> createRepeated() => $pb.PbList<Option>();
  @$core.pragma('dart2js:noInline')
  static Option getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Option>(create);
  static Option? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get voteCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set voteCount($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVoteCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearVoteCount() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, $core.String> get localizations => $_getMap(1);
}

class Poll extends $pb.GeneratedMessage {
  factory Poll({
    $fixnum.Int64? updatedAtTimestamp,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? comingSoon,
    $core.Iterable<Option>? options,
  }) {
    final result = create();
    if (updatedAtTimestamp != null)
      result.updatedAtTimestamp = updatedAtTimestamp;
    if (comingSoon != null) result.comingSoon.addEntries(comingSoon);
    if (options != null) result.options.addAll(options);
    return result;
  }

  Poll._();

  factory Poll.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Poll.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Poll',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'userpolls'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'updatedAtTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..m<$core.String, $core.String>(2, _omitFieldNames ? '' : 'comingSoon',
        entryClassName: 'Poll.ComingSoonEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('userpolls'))
    ..pc<Option>(3, _omitFieldNames ? '' : 'options', $pb.PbFieldType.PM,
        subBuilder: Option.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Poll clone() => Poll()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Poll copyWith(void Function(Poll) updates) =>
      super.copyWith((message) => updates(message as Poll)) as Poll;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Poll create() => Poll._();
  @$core.override
  Poll createEmptyInstance() => create();
  static $pb.PbList<Poll> createRepeated() => $pb.PbList<Poll>();
  @$core.pragma('dart2js:noInline')
  static Poll getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Poll>(create);
  static Poll? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get updatedAtTimestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set updatedAtTimestamp($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUpdatedAtTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearUpdatedAtTimestamp() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, $core.String> get comingSoon => $_getMap(1);

  @$pb.TagNumber(3)
  $pb.PbList<Option> get options => $_getList(2);
}

class Polls extends $pb.GeneratedMessage {
  factory Polls({
    Poll? free,
    Poll? pro,
  }) {
    final result = create();
    if (free != null) result.free = free;
    if (pro != null) result.pro = pro;
    return result;
  }

  Polls._();

  factory Polls.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Polls.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Polls',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'userpolls'),
      createEmptyInstance: create)
    ..aOM<Poll>(1, _omitFieldNames ? '' : 'free', subBuilder: Poll.create)
    ..aOM<Poll>(2, _omitFieldNames ? '' : 'pro', subBuilder: Poll.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Polls clone() => Polls()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Polls copyWith(void Function(Polls) updates) =>
      super.copyWith((message) => updates(message as Polls)) as Polls;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Polls create() => Polls._();
  @$core.override
  Polls createEmptyInstance() => create();
  static $pb.PbList<Polls> createRepeated() => $pb.PbList<Polls>();
  @$core.pragma('dart2js:noInline')
  static Polls getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Polls>(create);
  static Polls? _defaultInstance;

  @$pb.TagNumber(1)
  Poll get free => $_getN(0);
  @$pb.TagNumber(1)
  set free(Poll value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFree() => $_has(0);
  @$pb.TagNumber(1)
  void clearFree() => $_clearField(1);
  @$pb.TagNumber(1)
  Poll ensureFree() => $_ensure(0);

  @$pb.TagNumber(2)
  Poll get pro => $_getN(1);
  @$pb.TagNumber(2)
  set pro(Poll value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPro() => $_has(1);
  @$pb.TagNumber(2)
  void clearPro() => $_clearField(2);
  @$pb.TagNumber(2)
  Poll ensurePro() => $_ensure(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
// ignore_for_file: undefined_named_parameter,no_leading_underscores_for_local_identifiers
