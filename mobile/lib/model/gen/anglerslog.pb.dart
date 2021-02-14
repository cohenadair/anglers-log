///
//  Generated code. Do not modify.
//  source: anglerslog.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

import 'anglerslog.pbenum.dart';

export 'anglerslog.pbenum.dart';

class Id extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Id',
      package: const $pb.PackageName('anglerslog'), createEmptyInstance: create)
    ..aOS(1, 'uuid')
    ..hasRequiredFields = false;

  Id._() : super();
  factory Id() => create();
  factory Id.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Id.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  Id clone() => Id()..mergeFromMessage(this);
  Id copyWith(void Function(Id) updates) =>
      super.copyWith((message) => updates(message as Id));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Id create() => Id._();
  Id createEmptyInstance() => create();
  static $pb.PbList<Id> createRepeated() => $pb.PbList<Id>();
  @$core.pragma('dart2js:noInline')
  static Id getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Id>(create);
  static Id _defaultInstance;

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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('CustomEntity',
      package: const $pb.PackageName('anglerslog'), createEmptyInstance: create)
    ..aOM<Id>(1, 'id', subBuilder: Id.create)
    ..aOS(2, 'name')
    ..aOS(3, 'description')
    ..e<CustomEntity_Type>(4, 'type', $pb.PbFieldType.OE,
        defaultOrMaker: CustomEntity_Type.BOOL,
        valueOf: CustomEntity_Type.valueOf,
        enumValues: CustomEntity_Type.values)
    ..hasRequiredFields = false;

  CustomEntity._() : super();
  factory CustomEntity() => create();
  factory CustomEntity.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory CustomEntity.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  CustomEntity clone() => CustomEntity()..mergeFromMessage(this);
  CustomEntity copyWith(void Function(CustomEntity) updates) =>
      super.copyWith((message) => updates(message as CustomEntity));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CustomEntity create() => CustomEntity._();
  CustomEntity createEmptyInstance() => create();
  static $pb.PbList<CustomEntity> createRepeated() =>
      $pb.PbList<CustomEntity>();
  @$core.pragma('dart2js:noInline')
  static CustomEntity getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CustomEntity>(create);
  static CustomEntity _defaultInstance;

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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('CustomEntityValue',
      package: const $pb.PackageName('anglerslog'), createEmptyInstance: create)
    ..aOM<Id>(1, 'customEntityId', subBuilder: Id.create)
    ..aOS(2, 'value')
    ..hasRequiredFields = false;

  CustomEntityValue._() : super();
  factory CustomEntityValue() => create();
  factory CustomEntityValue.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory CustomEntityValue.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  CustomEntityValue clone() => CustomEntityValue()..mergeFromMessage(this);
  CustomEntityValue copyWith(void Function(CustomEntityValue) updates) =>
      super.copyWith((message) => updates(message as CustomEntityValue));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CustomEntityValue create() => CustomEntityValue._();
  CustomEntityValue createEmptyInstance() => create();
  static $pb.PbList<CustomEntityValue> createRepeated() =>
      $pb.PbList<CustomEntityValue>();
  @$core.pragma('dart2js:noInline')
  static CustomEntityValue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CustomEntityValue>(create);
  static CustomEntityValue _defaultInstance;

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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Bait',
      package: const $pb.PackageName('anglerslog'), createEmptyInstance: create)
    ..aOM<Id>(1, 'id', subBuilder: Id.create)
    ..aOS(2, 'name')
    ..aOM<Id>(3, 'baitCategoryId', subBuilder: Id.create)
    ..pc<CustomEntityValue>(4, 'customEntityValues', $pb.PbFieldType.PM,
        subBuilder: CustomEntityValue.create)
    ..hasRequiredFields = false;

  Bait._() : super();
  factory Bait() => create();
  factory Bait.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Bait.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  Bait clone() => Bait()..mergeFromMessage(this);
  Bait copyWith(void Function(Bait) updates) =>
      super.copyWith((message) => updates(message as Bait));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Bait create() => Bait._();
  Bait createEmptyInstance() => create();
  static $pb.PbList<Bait> createRepeated() => $pb.PbList<Bait>();
  @$core.pragma('dart2js:noInline')
  static Bait getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Bait>(create);
  static Bait _defaultInstance;

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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('BaitCategory',
      package: const $pb.PackageName('anglerslog'), createEmptyInstance: create)
    ..aOM<Id>(1, 'id', subBuilder: Id.create)
    ..aOS(2, 'name')
    ..hasRequiredFields = false;

  BaitCategory._() : super();
  factory BaitCategory() => create();
  factory BaitCategory.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory BaitCategory.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  BaitCategory clone() => BaitCategory()..mergeFromMessage(this);
  BaitCategory copyWith(void Function(BaitCategory) updates) =>
      super.copyWith((message) => updates(message as BaitCategory));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static BaitCategory create() => BaitCategory._();
  BaitCategory createEmptyInstance() => create();
  static $pb.PbList<BaitCategory> createRepeated() =>
      $pb.PbList<BaitCategory>();
  @$core.pragma('dart2js:noInline')
  static BaitCategory getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BaitCategory>(create);
  static BaitCategory _defaultInstance;

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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Catch',
      package: const $pb.PackageName('anglerslog'), createEmptyInstance: create)
    ..aOM<Id>(1, 'id', subBuilder: Id.create)
    ..a<Int64>(2, 'timestamp', $pb.PbFieldType.OU6, defaultOrMaker: Int64.ZERO)
    ..aOM<Id>(3, 'baitId', subBuilder: Id.create)
    ..aOM<Id>(4, 'fishingSpotId', subBuilder: Id.create)
    ..aOM<Id>(5, 'speciesId', subBuilder: Id.create)
    ..pPS(6, 'imageNames')
    ..pc<CustomEntityValue>(7, 'customEntityValues', $pb.PbFieldType.PM,
        subBuilder: CustomEntityValue.create)
    ..hasRequiredFields = false;

  Catch._() : super();
  factory Catch() => create();
  factory Catch.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Catch.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  Catch clone() => Catch()..mergeFromMessage(this);
  Catch copyWith(void Function(Catch) updates) =>
      super.copyWith((message) => updates(message as Catch));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Catch create() => Catch._();
  Catch createEmptyInstance() => create();
  static $pb.PbList<Catch> createRepeated() => $pb.PbList<Catch>();
  @$core.pragma('dart2js:noInline')
  static Catch getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Catch>(create);
  static Catch _defaultInstance;

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
  Int64 get timestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set timestamp(Int64 v) {
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
}

class FishingSpot extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('FishingSpot',
      package: const $pb.PackageName('anglerslog'), createEmptyInstance: create)
    ..aOM<Id>(1, 'id', subBuilder: Id.create)
    ..aOS(2, 'name')
    ..a<$core.double>(3, 'lat', $pb.PbFieldType.OD)
    ..a<$core.double>(4, 'lng', $pb.PbFieldType.OD)
    ..hasRequiredFields = false;

  FishingSpot._() : super();
  factory FishingSpot() => create();
  factory FishingSpot.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory FishingSpot.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  FishingSpot clone() => FishingSpot()..mergeFromMessage(this);
  FishingSpot copyWith(void Function(FishingSpot) updates) =>
      super.copyWith((message) => updates(message as FishingSpot));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static FishingSpot create() => FishingSpot._();
  FishingSpot createEmptyInstance() => create();
  static $pb.PbList<FishingSpot> createRepeated() => $pb.PbList<FishingSpot>();
  @$core.pragma('dart2js:noInline')
  static FishingSpot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FishingSpot>(create);
  static FishingSpot _defaultInstance;

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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Species',
      package: const $pb.PackageName('anglerslog'), createEmptyInstance: create)
    ..aOM<Id>(1, 'id', subBuilder: Id.create)
    ..aOS(2, 'name')
    ..hasRequiredFields = false;

  Species._() : super();
  factory Species() => create();
  factory Species.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Species.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  Species clone() => Species()..mergeFromMessage(this);
  Species copyWith(void Function(Species) updates) =>
      super.copyWith((message) => updates(message as Species));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Species create() => Species._();
  Species createEmptyInstance() => create();
  static $pb.PbList<Species> createRepeated() => $pb.PbList<Species>();
  @$core.pragma('dart2js:noInline')
  static Species getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Species>(create);
  static Species _defaultInstance;

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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SummaryReport',
      package: const $pb.PackageName('anglerslog'), createEmptyInstance: create)
    ..aOM<Id>(1, 'id', subBuilder: Id.create)
    ..aOS(2, 'name')
    ..aOS(3, 'description')
    ..aOS(4, 'displayDateRangeId')
    ..a<Int64>(5, 'startTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: Int64.ZERO)
    ..a<Int64>(6, 'endTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: Int64.ZERO)
    ..pc<Id>(7, 'baitIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..pc<Id>(8, 'fishingSpotIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..pc<Id>(9, 'speciesIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..hasRequiredFields = false;

  SummaryReport._() : super();
  factory SummaryReport() => create();
  factory SummaryReport.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SummaryReport.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  SummaryReport clone() => SummaryReport()..mergeFromMessage(this);
  SummaryReport copyWith(void Function(SummaryReport) updates) =>
      super.copyWith((message) => updates(message as SummaryReport));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SummaryReport create() => SummaryReport._();
  SummaryReport createEmptyInstance() => create();
  static $pb.PbList<SummaryReport> createRepeated() =>
      $pb.PbList<SummaryReport>();
  @$core.pragma('dart2js:noInline')
  static SummaryReport getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SummaryReport>(create);
  static SummaryReport _defaultInstance;

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
  Int64 get startTimestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set startTimestamp(Int64 v) {
    $_setInt64(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasStartTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearStartTimestamp() => clearField(5);

  @$pb.TagNumber(6)
  Int64 get endTimestamp => $_getI64(5);
  @$pb.TagNumber(6)
  set endTimestamp(Int64 v) {
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
}

class ComparisonReport extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ComparisonReport',
      package: const $pb.PackageName('anglerslog'), createEmptyInstance: create)
    ..aOM<Id>(1, 'id', subBuilder: Id.create)
    ..aOS(2, 'name')
    ..aOS(3, 'description')
    ..aOS(4, 'fromDisplayDateRangeId')
    ..aOS(5, 'toDisplayDateRangeId')
    ..a<Int64>(6, 'fromStartTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: Int64.ZERO)
    ..a<Int64>(7, 'toStartTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: Int64.ZERO)
    ..a<Int64>(8, 'fromEndTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: Int64.ZERO)
    ..a<Int64>(9, 'toEndTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: Int64.ZERO)
    ..pc<Id>(10, 'baitIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..pc<Id>(11, 'fishingSpotIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..pc<Id>(12, 'speciesIds', $pb.PbFieldType.PM, subBuilder: Id.create)
    ..hasRequiredFields = false;

  ComparisonReport._() : super();
  factory ComparisonReport() => create();
  factory ComparisonReport.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ComparisonReport.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  ComparisonReport clone() => ComparisonReport()..mergeFromMessage(this);
  ComparisonReport copyWith(void Function(ComparisonReport) updates) =>
      super.copyWith((message) => updates(message as ComparisonReport));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ComparisonReport create() => ComparisonReport._();
  ComparisonReport createEmptyInstance() => create();
  static $pb.PbList<ComparisonReport> createRepeated() =>
      $pb.PbList<ComparisonReport>();
  @$core.pragma('dart2js:noInline')
  static ComparisonReport getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ComparisonReport>(create);
  static ComparisonReport _defaultInstance;

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
  Int64 get fromStartTimestamp => $_getI64(5);
  @$pb.TagNumber(6)
  set fromStartTimestamp(Int64 v) {
    $_setInt64(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasFromStartTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearFromStartTimestamp() => clearField(6);

  @$pb.TagNumber(7)
  Int64 get toStartTimestamp => $_getI64(6);
  @$pb.TagNumber(7)
  set toStartTimestamp(Int64 v) {
    $_setInt64(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasToStartTimestamp() => $_has(6);
  @$pb.TagNumber(7)
  void clearToStartTimestamp() => clearField(7);

  @$pb.TagNumber(8)
  Int64 get fromEndTimestamp => $_getI64(7);
  @$pb.TagNumber(8)
  set fromEndTimestamp(Int64 v) {
    $_setInt64(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasFromEndTimestamp() => $_has(7);
  @$pb.TagNumber(8)
  void clearFromEndTimestamp() => clearField(8);

  @$pb.TagNumber(9)
  Int64 get toEndTimestamp => $_getI64(8);
  @$pb.TagNumber(9)
  set toEndTimestamp(Int64 v) {
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
}

// ignore_for_file: constant_identifier_names,lines_longer_than_80_chars,directives_ordering,unnecessary_const,prefer_mixin,implementation_imports
