///
//  Generated code. Do not modify.
//  source: anglerslog.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'anglerslog.pbenum.dart';

export 'anglerslog.pbenum.dart';

class Id extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'Id',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'anglerslog'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'uuid')
    ..hasRequiredFields = false;

  Id._() : super();
  factory Id({
    $core.String? uuid,
  }) {
    final _result = create();
    if (uuid != null) {
      _result.uuid = uuid;
    }
    return _result;
  }
  factory Id.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Id.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Id clone() => Id()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Id copyWith(void Function(Id) updates) =>
      super.copyWith((message) => updates(message as Id))
          as Id; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Id create() => Id._();
  Id createEmptyInstance() => create();
  static $pb.PbList<Id> createRepeated() => $pb.PbList<Id>();
  @$core.pragma('dart2js:noInline')
  static Id getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Id>(create);
  static Id? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get uuid => $_getSZ(0);
  @$pb.TagNumber(1)
  set uuid($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasUuid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUuid() => clearField(1);
}

class CustomEntity extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'CustomEntity',
      package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id',
        subBuilder: Id.create)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'name')
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'description')
    ..e<CustomEntity_Type>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: CustomEntity_Type.BOOL,
        valueOf: CustomEntity_Type.valueOf,
        enumValues: CustomEntity_Type.values)
    ..hasRequiredFields = false;

  CustomEntity._() : super();
  factory CustomEntity({
    Id? id,
    $core.String? name,
    $core.String? description,
    CustomEntity_Type? type,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (name != null) {
      _result.name = name;
    }
    if (description != null) {
      _result.description = description;
    }
    if (type != null) {
      _result.type = type;
    }
    return _result;
  }
  factory CustomEntity.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory CustomEntity.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  CustomEntity clone() => CustomEntity()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  CustomEntity copyWith(void Function(CustomEntity) updates) =>
      super.copyWith((message) => updates(message as CustomEntity))
          as CustomEntity; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CustomEntity create() => CustomEntity._();
  CustomEntity createEmptyInstance() => create();
  static $pb.PbList<CustomEntity> createRepeated() =>
      $pb.PbList<CustomEntity>();
  @$core.pragma('dart2js:noInline')
  static CustomEntity getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CustomEntity>(create);
  static CustomEntity? _defaultInstance;

  @$pb.TagNumber(1)
  Id get id => $_getN(0);
  @$pb.TagNumber(1)
  set id(Id v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
  @$pb.TagNumber(1)
  Id ensureId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => clearField(3);

  @$pb.TagNumber(4)
  CustomEntity_Type get type => $_getN(3);
  @$pb.TagNumber(4)
  set type(CustomEntity_Type v) {
    setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => clearField(4);
}

class CustomEntityValue extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'CustomEntityValue',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'customEntityId',
        subBuilder: Id.create)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'value')
    ..hasRequiredFields = false;

  CustomEntityValue._() : super();
  factory CustomEntityValue({
    Id? customEntityId,
    $core.String? value,
  }) {
    final _result = create();
    if (customEntityId != null) {
      _result.customEntityId = customEntityId;
    }
    if (value != null) {
      _result.value = value;
    }
    return _result;
  }
  factory CustomEntityValue.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory CustomEntityValue.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  CustomEntityValue clone() => CustomEntityValue()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  CustomEntityValue copyWith(void Function(CustomEntityValue) updates) =>
      super.copyWith((message) => updates(message as CustomEntityValue))
          as CustomEntityValue; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CustomEntityValue create() => CustomEntityValue._();
  CustomEntityValue createEmptyInstance() => create();
  static $pb.PbList<CustomEntityValue> createRepeated() =>
      $pb.PbList<CustomEntityValue>();
  @$core.pragma('dart2js:noInline')
  static CustomEntityValue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CustomEntityValue>(create);
  static CustomEntityValue? _defaultInstance;

  @$pb.TagNumber(1)
  Id get customEntityId => $_getN(0);
  @$pb.TagNumber(1)
  set customEntityId(Id v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasCustomEntityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCustomEntityId() => clearField(1);
  @$pb.TagNumber(1)
  Id ensureCustomEntityId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => clearField(2);
}

class Bait extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Bait',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id',
        subBuilder: Id.create)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'name')
    ..aOM<Id>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'baitCategoryId',
        subBuilder: Id.create)
    ..pc<CustomEntityValue>(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'customEntityValues',
        $pb.PbFieldType.PM,
        subBuilder: CustomEntityValue.create)
    ..hasRequiredFields = false;

  Bait._() : super();
  factory Bait({
    Id? id,
    $core.String? name,
    Id? baitCategoryId,
    $core.Iterable<CustomEntityValue>? customEntityValues,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (name != null) {
      _result.name = name;
    }
    if (baitCategoryId != null) {
      _result.baitCategoryId = baitCategoryId;
    }
    if (customEntityValues != null) {
      _result.customEntityValues.addAll(customEntityValues);
    }
    return _result;
  }
  factory Bait.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Bait.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Bait clone() => Bait()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Bait copyWith(void Function(Bait) updates) =>
      super.copyWith((message) => updates(message as Bait))
          as Bait; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Bait create() => Bait._();
  Bait createEmptyInstance() => create();
  static $pb.PbList<Bait> createRepeated() => $pb.PbList<Bait>();
  @$core.pragma('dart2js:noInline')
  static Bait getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Bait>(create);
  static Bait? _defaultInstance;

  @$pb.TagNumber(1)
  Id get id => $_getN(0);
  @$pb.TagNumber(1)
  set id(Id v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
  @$pb.TagNumber(1)
  Id ensureId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  Id get baitCategoryId => $_getN(2);
  @$pb.TagNumber(3)
  set baitCategoryId(Id v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasBaitCategoryId() => $_has(2);
  @$pb.TagNumber(3)
  void clearBaitCategoryId() => clearField(3);
  @$pb.TagNumber(3)
  Id ensureBaitCategoryId() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.List<CustomEntityValue> get customEntityValues => $_getList(3);
}

class BaitCategory extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'BaitCategory',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'id',
        subBuilder: Id.create)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'name')
    ..hasRequiredFields = false;

  BaitCategory._() : super();
  factory BaitCategory({
    Id? id,
    $core.String? name,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (name != null) {
      _result.name = name;
    }
    return _result;
  }
  factory BaitCategory.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory BaitCategory.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  BaitCategory clone() => BaitCategory()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  BaitCategory copyWith(void Function(BaitCategory) updates) =>
      super.copyWith((message) => updates(message as BaitCategory))
          as BaitCategory; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static BaitCategory create() => BaitCategory._();
  BaitCategory createEmptyInstance() => create();
  static $pb.PbList<BaitCategory> createRepeated() =>
      $pb.PbList<BaitCategory>();
  @$core.pragma('dart2js:noInline')
  static BaitCategory getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BaitCategory>(create);
  static BaitCategory? _defaultInstance;

  @$pb.TagNumber(1)
  Id get id => $_getN(0);
  @$pb.TagNumber(1)
  set id(Id v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
  @$pb.TagNumber(1)
  Id ensureId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);
}

class Catch extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'Catch',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id',
        subBuilder: Id.create)
    ..a<$fixnum.Int64>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'timestamp',
        $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<Id>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'baitId', subBuilder: Id.create)
    ..aOM<Id>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fishingSpotId', subBuilder: Id.create)
    ..aOM<Id>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'speciesId', subBuilder: Id.create)
    ..pPS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'imageNames')
    ..pc<CustomEntityValue>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'customEntityValues', $pb.PbFieldType.PM, subBuilder: CustomEntityValue.create)
    ..aOM<Id>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'anglerId', subBuilder: Id.create)
    ..pc<Id>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'methodIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..hasRequiredFields = false;

  Catch._() : super();
  factory Catch({
    Id? id,
    $fixnum.Int64? timestamp,
    Id? baitId,
    Id? fishingSpotId,
    Id? speciesId,
    $core.Iterable<$core.String>? imageNames,
    $core.Iterable<CustomEntityValue>? customEntityValues,
    Id? anglerId,
    $core.Iterable<Id>? methodIds,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (timestamp != null) {
      _result.timestamp = timestamp;
    }
    if (baitId != null) {
      _result.baitId = baitId;
    }
    if (fishingSpotId != null) {
      _result.fishingSpotId = fishingSpotId;
    }
    if (speciesId != null) {
      _result.speciesId = speciesId;
    }
    if (imageNames != null) {
      _result.imageNames.addAll(imageNames);
    }
    if (customEntityValues != null) {
      _result.customEntityValues.addAll(customEntityValues);
    }
    if (anglerId != null) {
      _result.anglerId = anglerId;
    }
    if (methodIds != null) {
      _result.methodIds.addAll(methodIds);
    }
    return _result;
  }
  factory Catch.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Catch.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Catch clone() => Catch()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Catch copyWith(void Function(Catch) updates) =>
      super.copyWith((message) => updates(message as Catch))
          as Catch; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Catch create() => Catch._();
  Catch createEmptyInstance() => create();
  static $pb.PbList<Catch> createRepeated() => $pb.PbList<Catch>();
  @$core.pragma('dart2js:noInline')
  static Catch getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Catch>(create);
  static Catch? _defaultInstance;

  @$pb.TagNumber(1)
  Id get id => $_getN(0);
  @$pb.TagNumber(1)
  set id(Id v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
  @$pb.TagNumber(1)
  Id ensureId() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get timestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set timestamp($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => clearField(2);

  @$pb.TagNumber(3)
  Id get baitId => $_getN(2);
  @$pb.TagNumber(3)
  set baitId(Id v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasBaitId() => $_has(2);
  @$pb.TagNumber(3)
  void clearBaitId() => clearField(3);
  @$pb.TagNumber(3)
  Id ensureBaitId() => $_ensure(2);

  @$pb.TagNumber(4)
  Id get fishingSpotId => $_getN(3);
  @$pb.TagNumber(4)
  set fishingSpotId(Id v) {
    setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasFishingSpotId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFishingSpotId() => clearField(4);
  @$pb.TagNumber(4)
  Id ensureFishingSpotId() => $_ensure(3);

  @$pb.TagNumber(5)
  Id get speciesId => $_getN(4);
  @$pb.TagNumber(5)
  set speciesId(Id v) {
    setField(5, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasSpeciesId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSpeciesId() => clearField(5);
  @$pb.TagNumber(5)
  Id ensureSpeciesId() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.List<$core.String> get imageNames => $_getList(5);

  @$pb.TagNumber(7)
  $core.List<CustomEntityValue> get customEntityValues => $_getList(6);

  @$pb.TagNumber(8)
  Id get anglerId => $_getN(7);
  @$pb.TagNumber(8)
  set anglerId(Id v) {
    setField(8, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasAnglerId() => $_has(7);
  @$pb.TagNumber(8)
  void clearAnglerId() => clearField(8);
  @$pb.TagNumber(8)
  Id ensureAnglerId() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.List<Id> get methodIds => $_getList(8);
}

class FishingSpot extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'FishingSpot',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(
        1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id',
        subBuilder: Id.create)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'name')
    ..a<$core.double>(
        3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'lat', $pb.PbFieldType.OD)
    ..a<$core.double>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'lng', $pb.PbFieldType.OD)
    ..hasRequiredFields = false;

  FishingSpot._() : super();
  factory FishingSpot({
    Id? id,
    $core.String? name,
    $core.double? lat,
    $core.double? lng,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (name != null) {
      _result.name = name;
    }
    if (lat != null) {
      _result.lat = lat;
    }
    if (lng != null) {
      _result.lng = lng;
    }
    return _result;
  }
  factory FishingSpot.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory FishingSpot.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  FishingSpot clone() => FishingSpot()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  FishingSpot copyWith(void Function(FishingSpot) updates) =>
      super.copyWith((message) => updates(message as FishingSpot))
          as FishingSpot; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static FishingSpot create() => FishingSpot._();
  FishingSpot createEmptyInstance() => create();
  static $pb.PbList<FishingSpot> createRepeated() => $pb.PbList<FishingSpot>();
  @$core.pragma('dart2js:noInline')
  static FishingSpot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FishingSpot>(create);
  static FishingSpot? _defaultInstance;

  @$pb.TagNumber(1)
  Id get id => $_getN(0);
  @$pb.TagNumber(1)
  set id(Id v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
  @$pb.TagNumber(1)
  Id ensureId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get lat => $_getN(2);
  @$pb.TagNumber(3)
  set lat($core.double v) {
    $_setDouble(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasLat() => $_has(2);
  @$pb.TagNumber(3)
  void clearLat() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get lng => $_getN(3);
  @$pb.TagNumber(4)
  set lng($core.double v) {
    $_setDouble(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasLng() => $_has(3);
  @$pb.TagNumber(4)
  void clearLng() => clearField(4);
}

class Species extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'Species',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'id',
        subBuilder: Id.create)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'name')
    ..hasRequiredFields = false;

  Species._() : super();
  factory Species({
    Id? id,
    $core.String? name,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (name != null) {
      _result.name = name;
    }
    return _result;
  }
  factory Species.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Species.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Species clone() => Species()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Species copyWith(void Function(Species) updates) =>
      super.copyWith((message) => updates(message as Species))
          as Species; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Species create() => Species._();
  Species createEmptyInstance() => create();
  static $pb.PbList<Species> createRepeated() => $pb.PbList<Species>();
  @$core.pragma('dart2js:noInline')
  static Species getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Species>(create);
  static Species? _defaultInstance;

  @$pb.TagNumber(1)
  Id get id => $_getN(0);
  @$pb.TagNumber(1)
  set id(Id v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
  @$pb.TagNumber(1)
  Id ensureId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);
}

class SummaryReport extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SummaryReport',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id',
        subBuilder: Id.create)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'name')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'description')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'displayDateRangeId')
    ..a<$fixnum.Int64>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'startTimestamp', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'endTimestamp', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..pc<Id>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'baitIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..pc<Id>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fishingSpotIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..pc<Id>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'speciesIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..pc<Id>(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'anglerIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..pc<Id>(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'methodIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..hasRequiredFields = false;

  SummaryReport._() : super();
  factory SummaryReport({
    Id? id,
    $core.String? name,
    $core.String? description,
    $core.String? displayDateRangeId,
    $fixnum.Int64? startTimestamp,
    $fixnum.Int64? endTimestamp,
    $core.Iterable<Id>? baitIds,
    $core.Iterable<Id>? fishingSpotIds,
    $core.Iterable<Id>? speciesIds,
    $core.Iterable<Id>? anglerIds,
    $core.Iterable<Id>? methodIds,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (name != null) {
      _result.name = name;
    }
    if (description != null) {
      _result.description = description;
    }
    if (displayDateRangeId != null) {
      _result.displayDateRangeId = displayDateRangeId;
    }
    if (startTimestamp != null) {
      _result.startTimestamp = startTimestamp;
    }
    if (endTimestamp != null) {
      _result.endTimestamp = endTimestamp;
    }
    if (baitIds != null) {
      _result.baitIds.addAll(baitIds);
    }
    if (fishingSpotIds != null) {
      _result.fishingSpotIds.addAll(fishingSpotIds);
    }
    if (speciesIds != null) {
      _result.speciesIds.addAll(speciesIds);
    }
    if (anglerIds != null) {
      _result.anglerIds.addAll(anglerIds);
    }
    if (methodIds != null) {
      _result.methodIds.addAll(methodIds);
    }
    return _result;
  }
  factory SummaryReport.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SummaryReport.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SummaryReport clone() => SummaryReport()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SummaryReport copyWith(void Function(SummaryReport) updates) =>
      super.copyWith((message) => updates(message as SummaryReport))
          as SummaryReport; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SummaryReport create() => SummaryReport._();
  SummaryReport createEmptyInstance() => create();
  static $pb.PbList<SummaryReport> createRepeated() =>
      $pb.PbList<SummaryReport>();
  @$core.pragma('dart2js:noInline')
  static SummaryReport getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SummaryReport>(create);
  static SummaryReport? _defaultInstance;

  @$pb.TagNumber(1)
  Id get id => $_getN(0);
  @$pb.TagNumber(1)
  set id(Id v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
  @$pb.TagNumber(1)
  Id ensureId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get displayDateRangeId => $_getSZ(3);
  @$pb.TagNumber(4)
  set displayDateRangeId($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasDisplayDateRangeId() => $_has(3);
  @$pb.TagNumber(4)
  void clearDisplayDateRangeId() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get startTimestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set startTimestamp($fixnum.Int64 v) {
    $_setInt64(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasStartTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearStartTimestamp() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get endTimestamp => $_getI64(5);
  @$pb.TagNumber(6)
  set endTimestamp($fixnum.Int64 v) {
    $_setInt64(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasEndTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearEndTimestamp() => clearField(6);

  @$pb.TagNumber(7)
  $core.List<Id> get baitIds => $_getList(6);

  @$pb.TagNumber(8)
  $core.List<Id> get fishingSpotIds => $_getList(7);

  @$pb.TagNumber(9)
  $core.List<Id> get speciesIds => $_getList(8);

  @$pb.TagNumber(10)
  $core.List<Id> get anglerIds => $_getList(9);

  @$pb.TagNumber(11)
  $core.List<Id> get methodIds => $_getList(10);
}

class ComparisonReport extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'ComparisonReport',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id',
        subBuilder: Id.create)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'name')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'description')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fromDisplayDateRangeId')
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'toDisplayDateRangeId')
    ..a<$fixnum.Int64>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fromStartTimestamp', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'toStartTimestamp', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fromEndTimestamp', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'toEndTimestamp', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..pc<Id>(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'baitIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..pc<Id>(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fishingSpotIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..pc<Id>(12, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'speciesIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..pc<Id>(13, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'anglerIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..pc<Id>(14, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'methodIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..hasRequiredFields = false;

  ComparisonReport._() : super();
  factory ComparisonReport({
    Id? id,
    $core.String? name,
    $core.String? description,
    $core.String? fromDisplayDateRangeId,
    $core.String? toDisplayDateRangeId,
    $fixnum.Int64? fromStartTimestamp,
    $fixnum.Int64? toStartTimestamp,
    $fixnum.Int64? fromEndTimestamp,
    $fixnum.Int64? toEndTimestamp,
    $core.Iterable<Id>? baitIds,
    $core.Iterable<Id>? fishingSpotIds,
    $core.Iterable<Id>? speciesIds,
    $core.Iterable<Id>? anglerIds,
    $core.Iterable<Id>? methodIds,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (name != null) {
      _result.name = name;
    }
    if (description != null) {
      _result.description = description;
    }
    if (fromDisplayDateRangeId != null) {
      _result.fromDisplayDateRangeId = fromDisplayDateRangeId;
    }
    if (toDisplayDateRangeId != null) {
      _result.toDisplayDateRangeId = toDisplayDateRangeId;
    }
    if (fromStartTimestamp != null) {
      _result.fromStartTimestamp = fromStartTimestamp;
    }
    if (toStartTimestamp != null) {
      _result.toStartTimestamp = toStartTimestamp;
    }
    if (fromEndTimestamp != null) {
      _result.fromEndTimestamp = fromEndTimestamp;
    }
    if (toEndTimestamp != null) {
      _result.toEndTimestamp = toEndTimestamp;
    }
    if (baitIds != null) {
      _result.baitIds.addAll(baitIds);
    }
    if (fishingSpotIds != null) {
      _result.fishingSpotIds.addAll(fishingSpotIds);
    }
    if (speciesIds != null) {
      _result.speciesIds.addAll(speciesIds);
    }
    if (anglerIds != null) {
      _result.anglerIds.addAll(anglerIds);
    }
    if (methodIds != null) {
      _result.methodIds.addAll(methodIds);
    }
    return _result;
  }
  factory ComparisonReport.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ComparisonReport.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ComparisonReport clone() => ComparisonReport()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ComparisonReport copyWith(void Function(ComparisonReport) updates) =>
      super.copyWith((message) => updates(message as ComparisonReport))
          as ComparisonReport; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ComparisonReport create() => ComparisonReport._();
  ComparisonReport createEmptyInstance() => create();
  static $pb.PbList<ComparisonReport> createRepeated() =>
      $pb.PbList<ComparisonReport>();
  @$core.pragma('dart2js:noInline')
  static ComparisonReport getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ComparisonReport>(create);
  static ComparisonReport? _defaultInstance;

  @$pb.TagNumber(1)
  Id get id => $_getN(0);
  @$pb.TagNumber(1)
  set id(Id v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
  @$pb.TagNumber(1)
  Id ensureId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get fromDisplayDateRangeId => $_getSZ(3);
  @$pb.TagNumber(4)
  set fromDisplayDateRangeId($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasFromDisplayDateRangeId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFromDisplayDateRangeId() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get toDisplayDateRangeId => $_getSZ(4);
  @$pb.TagNumber(5)
  set toDisplayDateRangeId($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasToDisplayDateRangeId() => $_has(4);
  @$pb.TagNumber(5)
  void clearToDisplayDateRangeId() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get fromStartTimestamp => $_getI64(5);
  @$pb.TagNumber(6)
  set fromStartTimestamp($fixnum.Int64 v) {
    $_setInt64(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasFromStartTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearFromStartTimestamp() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get toStartTimestamp => $_getI64(6);
  @$pb.TagNumber(7)
  set toStartTimestamp($fixnum.Int64 v) {
    $_setInt64(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasToStartTimestamp() => $_has(6);
  @$pb.TagNumber(7)
  void clearToStartTimestamp() => clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get fromEndTimestamp => $_getI64(7);
  @$pb.TagNumber(8)
  set fromEndTimestamp($fixnum.Int64 v) {
    $_setInt64(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasFromEndTimestamp() => $_has(7);
  @$pb.TagNumber(8)
  void clearFromEndTimestamp() => clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get toEndTimestamp => $_getI64(8);
  @$pb.TagNumber(9)
  set toEndTimestamp($fixnum.Int64 v) {
    $_setInt64(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasToEndTimestamp() => $_has(8);
  @$pb.TagNumber(9)
  void clearToEndTimestamp() => clearField(9);

  @$pb.TagNumber(10)
  $core.List<Id> get baitIds => $_getList(9);

  @$pb.TagNumber(11)
  $core.List<Id> get fishingSpotIds => $_getList(10);

  @$pb.TagNumber(12)
  $core.List<Id> get speciesIds => $_getList(11);

  @$pb.TagNumber(13)
  $core.List<Id> get anglerIds => $_getList(12);

  @$pb.TagNumber(14)
  $core.List<Id> get methodIds => $_getList(13);
}

class Angler extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'Angler',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'id',
        subBuilder: Id.create)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'name')
    ..hasRequiredFields = false;

  Angler._() : super();
  factory Angler({
    Id? id,
    $core.String? name,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (name != null) {
      _result.name = name;
    }
    return _result;
  }
  factory Angler.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Angler.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Angler clone() => Angler()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Angler copyWith(void Function(Angler) updates) =>
      super.copyWith((message) => updates(message as Angler))
          as Angler; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Angler create() => Angler._();
  Angler createEmptyInstance() => create();
  static $pb.PbList<Angler> createRepeated() => $pb.PbList<Angler>();
  @$core.pragma('dart2js:noInline')
  static Angler getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Angler>(create);
  static Angler? _defaultInstance;

  @$pb.TagNumber(1)
  Id get id => $_getN(0);
  @$pb.TagNumber(1)
  set id(Id v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
  @$pb.TagNumber(1)
  Id ensureId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);
}

class Method extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'Method',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'id',
        subBuilder: Id.create)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'name')
    ..hasRequiredFields = false;

  Method._() : super();
  factory Method({
    Id? id,
    $core.String? name,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (name != null) {
      _result.name = name;
    }
    return _result;
  }
  factory Method.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Method.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Method clone() => Method()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Method copyWith(void Function(Method) updates) =>
      super.copyWith((message) => updates(message as Method))
          as Method; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Method create() => Method._();
  Method createEmptyInstance() => create();
  static $pb.PbList<Method> createRepeated() => $pb.PbList<Method>();
  @$core.pragma('dart2js:noInline')
  static Method getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Method>(create);
  static Method? _defaultInstance;

  @$pb.TagNumber(1)
  Id get id => $_getN(0);
  @$pb.TagNumber(1)
  set id(Id v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
  @$pb.TagNumber(1)
  Id ensureId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);
}

// ignore_for_file: constant_identifier_names,lines_longer_than_80_chars,directives_ordering,prefer_mixin,implementation_imports
