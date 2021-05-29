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
        defaultOrMaker: CustomEntity_Type.boolean,
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
    ..aOM<Id>(
        1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'id',
        subBuilder: Id.create)
    ..a<$fixnum.Int64>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'timestamp',
        $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<Id>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'baitId', subBuilder: Id.create)
    ..aOM<Id>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fishingSpotId', subBuilder: Id.create)
    ..aOM<Id>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'speciesId', subBuilder: Id.create)
    ..pPS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'imageNames')
    ..pc<CustomEntityValue>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'customEntityValues', $pb.PbFieldType.PM, subBuilder: CustomEntityValue.create)
    ..aOM<Id>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'anglerId', subBuilder: Id.create)
    ..pc<Id>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'methodIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..e<Period>(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'period', $pb.PbFieldType.OE, defaultOrMaker: Period.period_all, valueOf: Period.valueOf, enumValues: Period.values)
    ..aOB(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'isFavorite')
    ..aOB(12, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'wasCatchAndRelease')
    ..e<Season>(13, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'season', $pb.PbFieldType.OE, defaultOrMaker: Season.season_all, valueOf: Season.valueOf, enumValues: Season.values)
    ..aOM<Id>(14, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'waterClarityId', subBuilder: Id.create)
    ..aOM<MultiMeasurement>(15, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'waterDepth', subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(16, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'waterTemperature', subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(17, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'length', subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(18, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'weight', subBuilder: MultiMeasurement.create)
    ..a<$core.int>(19, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'quantity', $pb.PbFieldType.OU3)
    ..aOS(20, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'notes')
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
    Period? period,
    $core.bool? isFavorite,
    $core.bool? wasCatchAndRelease,
    Season? season,
    Id? waterClarityId,
    MultiMeasurement? waterDepth,
    MultiMeasurement? waterTemperature,
    MultiMeasurement? length,
    MultiMeasurement? weight,
    $core.int? quantity,
    $core.String? notes,
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
    if (period != null) {
      _result.period = period;
    }
    if (isFavorite != null) {
      _result.isFavorite = isFavorite;
    }
    if (wasCatchAndRelease != null) {
      _result.wasCatchAndRelease = wasCatchAndRelease;
    }
    if (season != null) {
      _result.season = season;
    }
    if (waterClarityId != null) {
      _result.waterClarityId = waterClarityId;
    }
    if (waterDepth != null) {
      _result.waterDepth = waterDepth;
    }
    if (waterTemperature != null) {
      _result.waterTemperature = waterTemperature;
    }
    if (length != null) {
      _result.length = length;
    }
    if (weight != null) {
      _result.weight = weight;
    }
    if (quantity != null) {
      _result.quantity = quantity;
    }
    if (notes != null) {
      _result.notes = notes;
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

  @$pb.TagNumber(10)
  Period get period => $_getN(9);
  @$pb.TagNumber(10)
  set period(Period v) {
    setField(10, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasPeriod() => $_has(9);
  @$pb.TagNumber(10)
  void clearPeriod() => clearField(10);

  @$pb.TagNumber(11)
  $core.bool get isFavorite => $_getBF(10);
  @$pb.TagNumber(11)
  set isFavorite($core.bool v) {
    $_setBool(10, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasIsFavorite() => $_has(10);
  @$pb.TagNumber(11)
  void clearIsFavorite() => clearField(11);

  @$pb.TagNumber(12)
  $core.bool get wasCatchAndRelease => $_getBF(11);
  @$pb.TagNumber(12)
  set wasCatchAndRelease($core.bool v) {
    $_setBool(11, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasWasCatchAndRelease() => $_has(11);
  @$pb.TagNumber(12)
  void clearWasCatchAndRelease() => clearField(12);

  @$pb.TagNumber(13)
  Season get season => $_getN(12);
  @$pb.TagNumber(13)
  set season(Season v) {
    setField(13, v);
  }

  @$pb.TagNumber(13)
  $core.bool hasSeason() => $_has(12);
  @$pb.TagNumber(13)
  void clearSeason() => clearField(13);

  @$pb.TagNumber(14)
  Id get waterClarityId => $_getN(13);
  @$pb.TagNumber(14)
  set waterClarityId(Id v) {
    setField(14, v);
  }

  @$pb.TagNumber(14)
  $core.bool hasWaterClarityId() => $_has(13);
  @$pb.TagNumber(14)
  void clearWaterClarityId() => clearField(14);
  @$pb.TagNumber(14)
  Id ensureWaterClarityId() => $_ensure(13);

  @$pb.TagNumber(15)
  MultiMeasurement get waterDepth => $_getN(14);
  @$pb.TagNumber(15)
  set waterDepth(MultiMeasurement v) {
    setField(15, v);
  }

  @$pb.TagNumber(15)
  $core.bool hasWaterDepth() => $_has(14);
  @$pb.TagNumber(15)
  void clearWaterDepth() => clearField(15);
  @$pb.TagNumber(15)
  MultiMeasurement ensureWaterDepth() => $_ensure(14);

  @$pb.TagNumber(16)
  MultiMeasurement get waterTemperature => $_getN(15);
  @$pb.TagNumber(16)
  set waterTemperature(MultiMeasurement v) {
    setField(16, v);
  }

  @$pb.TagNumber(16)
  $core.bool hasWaterTemperature() => $_has(15);
  @$pb.TagNumber(16)
  void clearWaterTemperature() => clearField(16);
  @$pb.TagNumber(16)
  MultiMeasurement ensureWaterTemperature() => $_ensure(15);

  @$pb.TagNumber(17)
  MultiMeasurement get length => $_getN(16);
  @$pb.TagNumber(17)
  set length(MultiMeasurement v) {
    setField(17, v);
  }

  @$pb.TagNumber(17)
  $core.bool hasLength() => $_has(16);
  @$pb.TagNumber(17)
  void clearLength() => clearField(17);
  @$pb.TagNumber(17)
  MultiMeasurement ensureLength() => $_ensure(16);

  @$pb.TagNumber(18)
  MultiMeasurement get weight => $_getN(17);
  @$pb.TagNumber(18)
  set weight(MultiMeasurement v) {
    setField(18, v);
  }

  @$pb.TagNumber(18)
  $core.bool hasWeight() => $_has(17);
  @$pb.TagNumber(18)
  void clearWeight() => clearField(18);
  @$pb.TagNumber(18)
  MultiMeasurement ensureWeight() => $_ensure(17);

  @$pb.TagNumber(19)
  $core.int get quantity => $_getIZ(18);
  @$pb.TagNumber(19)
  set quantity($core.int v) {
    $_setUnsignedInt32(18, v);
  }

  @$pb.TagNumber(19)
  $core.bool hasQuantity() => $_has(18);
  @$pb.TagNumber(19)
  void clearQuantity() => clearField(19);

  @$pb.TagNumber(20)
  $core.String get notes => $_getSZ(19);
  @$pb.TagNumber(20)
  set notes($core.String v) {
    $_setString(19, v);
  }

  @$pb.TagNumber(20)
  $core.bool hasNotes() => $_has(19);
  @$pb.TagNumber(20)
  void clearNotes() => clearField(20);
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

class NumberFilter extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'NumberFilter',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'anglerslog'),
      createEmptyInstance: create)
    ..e<NumberBoundary>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'boundary', $pb.PbFieldType.OE,
        defaultOrMaker: NumberBoundary.number_boundary_any,
        valueOf: NumberBoundary.valueOf,
        enumValues: NumberBoundary.values)
    ..aOM<MultiMeasurement>(
        2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'from',
        subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(
        3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'to',
        subBuilder: MultiMeasurement.create)
    ..hasRequiredFields = false;

  NumberFilter._() : super();
  factory NumberFilter({
    NumberBoundary? boundary,
    MultiMeasurement? from,
    MultiMeasurement? to,
  }) {
    final _result = create();
    if (boundary != null) {
      _result.boundary = boundary;
    }
    if (from != null) {
      _result.from = from;
    }
    if (to != null) {
      _result.to = to;
    }
    return _result;
  }
  factory NumberFilter.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory NumberFilter.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  NumberFilter clone() => NumberFilter()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  NumberFilter copyWith(void Function(NumberFilter) updates) =>
      super.copyWith((message) => updates(message as NumberFilter))
          as NumberFilter; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static NumberFilter create() => NumberFilter._();
  NumberFilter createEmptyInstance() => create();
  static $pb.PbList<NumberFilter> createRepeated() =>
      $pb.PbList<NumberFilter>();
  @$core.pragma('dart2js:noInline')
  static NumberFilter getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NumberFilter>(create);
  static NumberFilter? _defaultInstance;

  @$pb.TagNumber(1)
  NumberBoundary get boundary => $_getN(0);
  @$pb.TagNumber(1)
  set boundary(NumberBoundary v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasBoundary() => $_has(0);
  @$pb.TagNumber(1)
  void clearBoundary() => clearField(1);

  @$pb.TagNumber(2)
  MultiMeasurement get from => $_getN(1);
  @$pb.TagNumber(2)
  set from(MultiMeasurement v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasFrom() => $_has(1);
  @$pb.TagNumber(2)
  void clearFrom() => clearField(2);
  @$pb.TagNumber(2)
  MultiMeasurement ensureFrom() => $_ensure(1);

  @$pb.TagNumber(3)
  MultiMeasurement get to => $_getN(2);
  @$pb.TagNumber(3)
  set to(MultiMeasurement v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasTo() => $_has(2);
  @$pb.TagNumber(3)
  void clearTo() => clearField(3);
  @$pb.TagNumber(3)
  MultiMeasurement ensureTo() => $_ensure(2);
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

class Report extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Report',
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
    ..e<Report_Type>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: Report_Type.summary,
        valueOf: Report_Type.valueOf,
        enumValues: Report_Type.values)
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fromDisplayDateRangeId')
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'toDisplayDateRangeId')
    ..a<$fixnum.Int64>(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fromStartTimestamp', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'toStartTimestamp', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fromEndTimestamp', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'toEndTimestamp', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..pc<Id>(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'baitIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..pc<Id>(12, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fishingSpotIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..pc<Id>(13, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'speciesIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..pc<Id>(14, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'anglerIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..pc<Id>(15, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'methodIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..pc<Period>(16, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'periods', $pb.PbFieldType.PE, valueOf: Period.valueOf, enumValues: Period.values)
    ..aOB(17, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'isFavoritesOnly')
    ..aOB(18, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'isCatchAndReleaseOnly')
    ..pc<Season>(19, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'seasons', $pb.PbFieldType.PE, valueOf: Season.valueOf, enumValues: Season.values)
    ..pc<Id>(20, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'waterClarityIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..aOM<NumberFilter>(21, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'waterDepthFilter', subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(22, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'waterTemperatureFilter', subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(23, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'lengthFilter', subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(24, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'weightFilter', subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(25, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'quantityFilter', subBuilder: NumberFilter.create)
    ..hasRequiredFields = false;

  Report._() : super();
  factory Report({
    Id? id,
    $core.String? name,
    $core.String? description,
    Report_Type? type,
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
    $core.Iterable<Period>? periods,
    $core.bool? isFavoritesOnly,
    $core.bool? isCatchAndReleaseOnly,
    $core.Iterable<Season>? seasons,
    $core.Iterable<Id>? waterClarityIds,
    NumberFilter? waterDepthFilter,
    NumberFilter? waterTemperatureFilter,
    NumberFilter? lengthFilter,
    NumberFilter? weightFilter,
    NumberFilter? quantityFilter,
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
    if (periods != null) {
      _result.periods.addAll(periods);
    }
    if (isFavoritesOnly != null) {
      _result.isFavoritesOnly = isFavoritesOnly;
    }
    if (isCatchAndReleaseOnly != null) {
      _result.isCatchAndReleaseOnly = isCatchAndReleaseOnly;
    }
    if (seasons != null) {
      _result.seasons.addAll(seasons);
    }
    if (waterClarityIds != null) {
      _result.waterClarityIds.addAll(waterClarityIds);
    }
    if (waterDepthFilter != null) {
      _result.waterDepthFilter = waterDepthFilter;
    }
    if (waterTemperatureFilter != null) {
      _result.waterTemperatureFilter = waterTemperatureFilter;
    }
    if (lengthFilter != null) {
      _result.lengthFilter = lengthFilter;
    }
    if (weightFilter != null) {
      _result.weightFilter = weightFilter;
    }
    if (quantityFilter != null) {
      _result.quantityFilter = quantityFilter;
    }
    return _result;
  }
  factory Report.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Report.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Report clone() => Report()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Report copyWith(void Function(Report) updates) =>
      super.copyWith((message) => updates(message as Report))
          as Report; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Report create() => Report._();
  Report createEmptyInstance() => create();
  static $pb.PbList<Report> createRepeated() => $pb.PbList<Report>();
  @$core.pragma('dart2js:noInline')
  static Report getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Report>(create);
  static Report? _defaultInstance;

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
  Report_Type get type => $_getN(3);
  @$pb.TagNumber(4)
  set type(Report_Type v) {
    setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get fromDisplayDateRangeId => $_getSZ(4);
  @$pb.TagNumber(5)
  set fromDisplayDateRangeId($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasFromDisplayDateRangeId() => $_has(4);
  @$pb.TagNumber(5)
  void clearFromDisplayDateRangeId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get toDisplayDateRangeId => $_getSZ(5);
  @$pb.TagNumber(6)
  set toDisplayDateRangeId($core.String v) {
    $_setString(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasToDisplayDateRangeId() => $_has(5);
  @$pb.TagNumber(6)
  void clearToDisplayDateRangeId() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get fromStartTimestamp => $_getI64(6);
  @$pb.TagNumber(7)
  set fromStartTimestamp($fixnum.Int64 v) {
    $_setInt64(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasFromStartTimestamp() => $_has(6);
  @$pb.TagNumber(7)
  void clearFromStartTimestamp() => clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get toStartTimestamp => $_getI64(7);
  @$pb.TagNumber(8)
  set toStartTimestamp($fixnum.Int64 v) {
    $_setInt64(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasToStartTimestamp() => $_has(7);
  @$pb.TagNumber(8)
  void clearToStartTimestamp() => clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get fromEndTimestamp => $_getI64(8);
  @$pb.TagNumber(9)
  set fromEndTimestamp($fixnum.Int64 v) {
    $_setInt64(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasFromEndTimestamp() => $_has(8);
  @$pb.TagNumber(9)
  void clearFromEndTimestamp() => clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get toEndTimestamp => $_getI64(9);
  @$pb.TagNumber(10)
  set toEndTimestamp($fixnum.Int64 v) {
    $_setInt64(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasToEndTimestamp() => $_has(9);
  @$pb.TagNumber(10)
  void clearToEndTimestamp() => clearField(10);

  @$pb.TagNumber(11)
  $core.List<Id> get baitIds => $_getList(10);

  @$pb.TagNumber(12)
  $core.List<Id> get fishingSpotIds => $_getList(11);

  @$pb.TagNumber(13)
  $core.List<Id> get speciesIds => $_getList(12);

  @$pb.TagNumber(14)
  $core.List<Id> get anglerIds => $_getList(13);

  @$pb.TagNumber(15)
  $core.List<Id> get methodIds => $_getList(14);

  @$pb.TagNumber(16)
  $core.List<Period> get periods => $_getList(15);

  @$pb.TagNumber(17)
  $core.bool get isFavoritesOnly => $_getBF(16);
  @$pb.TagNumber(17)
  set isFavoritesOnly($core.bool v) {
    $_setBool(16, v);
  }

  @$pb.TagNumber(17)
  $core.bool hasIsFavoritesOnly() => $_has(16);
  @$pb.TagNumber(17)
  void clearIsFavoritesOnly() => clearField(17);

  @$pb.TagNumber(18)
  $core.bool get isCatchAndReleaseOnly => $_getBF(17);
  @$pb.TagNumber(18)
  set isCatchAndReleaseOnly($core.bool v) {
    $_setBool(17, v);
  }

  @$pb.TagNumber(18)
  $core.bool hasIsCatchAndReleaseOnly() => $_has(17);
  @$pb.TagNumber(18)
  void clearIsCatchAndReleaseOnly() => clearField(18);

  @$pb.TagNumber(19)
  $core.List<Season> get seasons => $_getList(18);

  @$pb.TagNumber(20)
  $core.List<Id> get waterClarityIds => $_getList(19);

  @$pb.TagNumber(21)
  NumberFilter get waterDepthFilter => $_getN(20);
  @$pb.TagNumber(21)
  set waterDepthFilter(NumberFilter v) {
    setField(21, v);
  }

  @$pb.TagNumber(21)
  $core.bool hasWaterDepthFilter() => $_has(20);
  @$pb.TagNumber(21)
  void clearWaterDepthFilter() => clearField(21);
  @$pb.TagNumber(21)
  NumberFilter ensureWaterDepthFilter() => $_ensure(20);

  @$pb.TagNumber(22)
  NumberFilter get waterTemperatureFilter => $_getN(21);
  @$pb.TagNumber(22)
  set waterTemperatureFilter(NumberFilter v) {
    setField(22, v);
  }

  @$pb.TagNumber(22)
  $core.bool hasWaterTemperatureFilter() => $_has(21);
  @$pb.TagNumber(22)
  void clearWaterTemperatureFilter() => clearField(22);
  @$pb.TagNumber(22)
  NumberFilter ensureWaterTemperatureFilter() => $_ensure(21);

  @$pb.TagNumber(23)
  NumberFilter get lengthFilter => $_getN(22);
  @$pb.TagNumber(23)
  set lengthFilter(NumberFilter v) {
    setField(23, v);
  }

  @$pb.TagNumber(23)
  $core.bool hasLengthFilter() => $_has(22);
  @$pb.TagNumber(23)
  void clearLengthFilter() => clearField(23);
  @$pb.TagNumber(23)
  NumberFilter ensureLengthFilter() => $_ensure(22);

  @$pb.TagNumber(24)
  NumberFilter get weightFilter => $_getN(23);
  @$pb.TagNumber(24)
  set weightFilter(NumberFilter v) {
    setField(24, v);
  }

  @$pb.TagNumber(24)
  $core.bool hasWeightFilter() => $_has(23);
  @$pb.TagNumber(24)
  void clearWeightFilter() => clearField(24);
  @$pb.TagNumber(24)
  NumberFilter ensureWeightFilter() => $_ensure(23);

  @$pb.TagNumber(25)
  NumberFilter get quantityFilter => $_getN(24);
  @$pb.TagNumber(25)
  set quantityFilter(NumberFilter v) {
    setField(25, v);
  }

  @$pb.TagNumber(25)
  $core.bool hasQuantityFilter() => $_has(24);
  @$pb.TagNumber(25)
  void clearQuantityFilter() => clearField(25);
  @$pb.TagNumber(25)
  NumberFilter ensureQuantityFilter() => $_ensure(24);
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

class WaterClarity extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'WaterClarity',
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

  WaterClarity._() : super();
  factory WaterClarity({
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
  factory WaterClarity.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory WaterClarity.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  WaterClarity clone() => WaterClarity()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  WaterClarity copyWith(void Function(WaterClarity) updates) =>
      super.copyWith((message) => updates(message as WaterClarity))
          as WaterClarity; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static WaterClarity create() => WaterClarity._();
  WaterClarity createEmptyInstance() => create();
  static $pb.PbList<WaterClarity> createRepeated() =>
      $pb.PbList<WaterClarity>();
  @$core.pragma('dart2js:noInline')
  static WaterClarity getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WaterClarity>(create);
  static WaterClarity? _defaultInstance;

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

class Measurement extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'Measurement',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'anglerslog'),
      createEmptyInstance: create)
    ..e<Unit>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'unit',
        $pb.PbFieldType.OE,
        defaultOrMaker: Unit.feet,
        valueOf: Unit.valueOf,
        enumValues: Unit.values)
    ..a<$core.double>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'value',
        $pb.PbFieldType.OD)
    ..hasRequiredFields = false;

  Measurement._() : super();
  factory Measurement({
    Unit? unit,
    $core.double? value,
  }) {
    final _result = create();
    if (unit != null) {
      _result.unit = unit;
    }
    if (value != null) {
      _result.value = value;
    }
    return _result;
  }
  factory Measurement.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Measurement.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Measurement clone() => Measurement()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Measurement copyWith(void Function(Measurement) updates) =>
      super.copyWith((message) => updates(message as Measurement))
          as Measurement; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Measurement create() => Measurement._();
  Measurement createEmptyInstance() => create();
  static $pb.PbList<Measurement> createRepeated() => $pb.PbList<Measurement>();
  @$core.pragma('dart2js:noInline')
  static Measurement getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Measurement>(create);
  static Measurement? _defaultInstance;

  @$pb.TagNumber(1)
  Unit get unit => $_getN(0);
  @$pb.TagNumber(1)
  set unit(Unit v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasUnit() => $_has(0);
  @$pb.TagNumber(1)
  void clearUnit() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($core.double v) {
    $_setDouble(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => clearField(2);
}

class MultiMeasurement extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'MultiMeasurement',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'anglerslog'),
      createEmptyInstance: create)
    ..e<MeasurementSystem>(
        1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'system', $pb.PbFieldType.OE,
        defaultOrMaker: MeasurementSystem.imperial_whole,
        valueOf: MeasurementSystem.valueOf,
        enumValues: MeasurementSystem.values)
    ..aOM<Measurement>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'mainValue',
        protoName: 'mainValue', subBuilder: Measurement.create)
    ..aOM<Measurement>(
        3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'fractionValue',
        protoName: 'fractionValue', subBuilder: Measurement.create)
    ..hasRequiredFields = false;

  MultiMeasurement._() : super();
  factory MultiMeasurement({
    MeasurementSystem? system,
    Measurement? mainValue,
    Measurement? fractionValue,
  }) {
    final _result = create();
    if (system != null) {
      _result.system = system;
    }
    if (mainValue != null) {
      _result.mainValue = mainValue;
    }
    if (fractionValue != null) {
      _result.fractionValue = fractionValue;
    }
    return _result;
  }
  factory MultiMeasurement.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory MultiMeasurement.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  MultiMeasurement clone() => MultiMeasurement()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  MultiMeasurement copyWith(void Function(MultiMeasurement) updates) =>
      super.copyWith((message) => updates(message as MultiMeasurement))
          as MultiMeasurement; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static MultiMeasurement create() => MultiMeasurement._();
  MultiMeasurement createEmptyInstance() => create();
  static $pb.PbList<MultiMeasurement> createRepeated() =>
      $pb.PbList<MultiMeasurement>();
  @$core.pragma('dart2js:noInline')
  static MultiMeasurement getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MultiMeasurement>(create);
  static MultiMeasurement? _defaultInstance;

  @$pb.TagNumber(1)
  MeasurementSystem get system => $_getN(0);
  @$pb.TagNumber(1)
  set system(MeasurementSystem v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSystem() => $_has(0);
  @$pb.TagNumber(1)
  void clearSystem() => clearField(1);

  @$pb.TagNumber(2)
  Measurement get mainValue => $_getN(1);
  @$pb.TagNumber(2)
  set mainValue(Measurement v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasMainValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearMainValue() => clearField(2);
  @$pb.TagNumber(2)
  Measurement ensureMainValue() => $_ensure(1);

  @$pb.TagNumber(3)
  Measurement get fractionValue => $_getN(2);
  @$pb.TagNumber(3)
  set fractionValue(Measurement v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasFractionValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearFractionValue() => clearField(3);
  @$pb.TagNumber(3)
  Measurement ensureFractionValue() => $_ensure(2);
}

// ignore_for_file: constant_identifier_names,lines_longer_than_80_chars,directives_ordering,prefer_mixin,implementation_imports
