//
//  Generated code. Do not modify.
//  source: anglerslog.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'anglerslog.pbenum.dart';

export 'anglerslog.pbenum.dart';

/// A unique ID. An Id is a wrapper for UUID string representation of protobuf bytes type that can
/// be used as keys in a map. The Dart type for protobuf bytes is a List<int>, and [List==] does
/// not do a deep comparison of its elements. An [Id] message wrapper here is purely for semantics
/// to differentiate between a "string" and a "string that is an ID".
class Id extends $pb.GeneratedMessage {
  factory Id({
    $core.String? uuid,
  }) {
    final $result = create();
    if (uuid != null) {
      $result.uuid = uuid;
    }
    return $result;
  }
  Id._() : super();
  factory Id.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Id.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Id',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'uuid')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Id clone() => Id()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Id copyWith(void Function(Id) updates) =>
      super.copyWith((message) => updates(message as Id)) as Id;

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

class Atmosphere extends $pb.GeneratedMessage {
  factory Atmosphere({
    Measurement? temperatureDeprecated,
    $core.Iterable<SkyCondition>? skyConditions,
    Measurement? windSpeedDeprecated,
    Direction? windDirection,
    Measurement? pressureDeprecated,
    Measurement? humidityDeprecated,
    Measurement? visibilityDeprecated,
    MoonPhase? moonPhase,
    $fixnum.Int64? sunriseTimestamp,
    $fixnum.Int64? sunsetTimestamp,
    $core.String? timeZone,
    MultiMeasurement? temperature,
    MultiMeasurement? windSpeed,
    MultiMeasurement? pressure,
    MultiMeasurement? humidity,
    MultiMeasurement? visibility,
  }) {
    final $result = create();
    if (temperatureDeprecated != null) {
      $result.temperatureDeprecated = temperatureDeprecated;
    }
    if (skyConditions != null) {
      $result.skyConditions.addAll(skyConditions);
    }
    if (windSpeedDeprecated != null) {
      $result.windSpeedDeprecated = windSpeedDeprecated;
    }
    if (windDirection != null) {
      $result.windDirection = windDirection;
    }
    if (pressureDeprecated != null) {
      $result.pressureDeprecated = pressureDeprecated;
    }
    if (humidityDeprecated != null) {
      $result.humidityDeprecated = humidityDeprecated;
    }
    if (visibilityDeprecated != null) {
      $result.visibilityDeprecated = visibilityDeprecated;
    }
    if (moonPhase != null) {
      $result.moonPhase = moonPhase;
    }
    if (sunriseTimestamp != null) {
      $result.sunriseTimestamp = sunriseTimestamp;
    }
    if (sunsetTimestamp != null) {
      $result.sunsetTimestamp = sunsetTimestamp;
    }
    if (timeZone != null) {
      $result.timeZone = timeZone;
    }
    if (temperature != null) {
      $result.temperature = temperature;
    }
    if (windSpeed != null) {
      $result.windSpeed = windSpeed;
    }
    if (pressure != null) {
      $result.pressure = pressure;
    }
    if (humidity != null) {
      $result.humidity = humidity;
    }
    if (visibility != null) {
      $result.visibility = visibility;
    }
    return $result;
  }
  Atmosphere._() : super();
  factory Atmosphere.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Atmosphere.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Atmosphere',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Measurement>(1, _omitFieldNames ? '' : 'temperatureDeprecated',
        subBuilder: Measurement.create)
    ..pc<SkyCondition>(
        2, _omitFieldNames ? '' : 'skyConditions', $pb.PbFieldType.KE,
        valueOf: SkyCondition.valueOf,
        enumValues: SkyCondition.values,
        defaultEnumValue: SkyCondition.sky_condition_all)
    ..aOM<Measurement>(3, _omitFieldNames ? '' : 'windSpeedDeprecated',
        subBuilder: Measurement.create)
    ..e<Direction>(
        4, _omitFieldNames ? '' : 'windDirection', $pb.PbFieldType.OE,
        defaultOrMaker: Direction.direction_all,
        valueOf: Direction.valueOf,
        enumValues: Direction.values)
    ..aOM<Measurement>(5, _omitFieldNames ? '' : 'pressureDeprecated',
        subBuilder: Measurement.create)
    ..aOM<Measurement>(6, _omitFieldNames ? '' : 'humidityDeprecated',
        subBuilder: Measurement.create)
    ..aOM<Measurement>(7, _omitFieldNames ? '' : 'visibilityDeprecated',
        subBuilder: Measurement.create)
    ..e<MoonPhase>(8, _omitFieldNames ? '' : 'moonPhase', $pb.PbFieldType.OE,
        defaultOrMaker: MoonPhase.moon_phase_all,
        valueOf: MoonPhase.valueOf,
        enumValues: MoonPhase.values)
    ..a<$fixnum.Int64>(
        9, _omitFieldNames ? '' : 'sunriseTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        10, _omitFieldNames ? '' : 'sunsetTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(11, _omitFieldNames ? '' : 'timeZone')
    ..aOM<MultiMeasurement>(12, _omitFieldNames ? '' : 'temperature',
        subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(13, _omitFieldNames ? '' : 'windSpeed',
        subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(14, _omitFieldNames ? '' : 'pressure',
        subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(15, _omitFieldNames ? '' : 'humidity',
        subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(16, _omitFieldNames ? '' : 'visibility',
        subBuilder: MultiMeasurement.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Atmosphere clone() => Atmosphere()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Atmosphere copyWith(void Function(Atmosphere) updates) =>
      super.copyWith((message) => updates(message as Atmosphere)) as Atmosphere;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Atmosphere create() => Atmosphere._();
  Atmosphere createEmptyInstance() => create();
  static $pb.PbList<Atmosphere> createRepeated() => $pb.PbList<Atmosphere>();
  @$core.pragma('dart2js:noInline')
  static Atmosphere getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Atmosphere>(create);
  static Atmosphere? _defaultInstance;

  @$pb.TagNumber(1)
  Measurement get temperatureDeprecated => $_getN(0);
  @$pb.TagNumber(1)
  set temperatureDeprecated(Measurement v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTemperatureDeprecated() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemperatureDeprecated() => clearField(1);
  @$pb.TagNumber(1)
  Measurement ensureTemperatureDeprecated() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<SkyCondition> get skyConditions => $_getList(1);

  @$pb.TagNumber(3)
  Measurement get windSpeedDeprecated => $_getN(2);
  @$pb.TagNumber(3)
  set windSpeedDeprecated(Measurement v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasWindSpeedDeprecated() => $_has(2);
  @$pb.TagNumber(3)
  void clearWindSpeedDeprecated() => clearField(3);
  @$pb.TagNumber(3)
  Measurement ensureWindSpeedDeprecated() => $_ensure(2);

  @$pb.TagNumber(4)
  Direction get windDirection => $_getN(3);
  @$pb.TagNumber(4)
  set windDirection(Direction v) {
    setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasWindDirection() => $_has(3);
  @$pb.TagNumber(4)
  void clearWindDirection() => clearField(4);

  @$pb.TagNumber(5)
  Measurement get pressureDeprecated => $_getN(4);
  @$pb.TagNumber(5)
  set pressureDeprecated(Measurement v) {
    setField(5, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasPressureDeprecated() => $_has(4);
  @$pb.TagNumber(5)
  void clearPressureDeprecated() => clearField(5);
  @$pb.TagNumber(5)
  Measurement ensurePressureDeprecated() => $_ensure(4);

  @$pb.TagNumber(6)
  Measurement get humidityDeprecated => $_getN(5);
  @$pb.TagNumber(6)
  set humidityDeprecated(Measurement v) {
    setField(6, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasHumidityDeprecated() => $_has(5);
  @$pb.TagNumber(6)
  void clearHumidityDeprecated() => clearField(6);
  @$pb.TagNumber(6)
  Measurement ensureHumidityDeprecated() => $_ensure(5);

  @$pb.TagNumber(7)
  Measurement get visibilityDeprecated => $_getN(6);
  @$pb.TagNumber(7)
  set visibilityDeprecated(Measurement v) {
    setField(7, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasVisibilityDeprecated() => $_has(6);
  @$pb.TagNumber(7)
  void clearVisibilityDeprecated() => clearField(7);
  @$pb.TagNumber(7)
  Measurement ensureVisibilityDeprecated() => $_ensure(6);

  @$pb.TagNumber(8)
  MoonPhase get moonPhase => $_getN(7);
  @$pb.TagNumber(8)
  set moonPhase(MoonPhase v) {
    setField(8, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasMoonPhase() => $_has(7);
  @$pb.TagNumber(8)
  void clearMoonPhase() => clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get sunriseTimestamp => $_getI64(8);
  @$pb.TagNumber(9)
  set sunriseTimestamp($fixnum.Int64 v) {
    $_setInt64(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasSunriseTimestamp() => $_has(8);
  @$pb.TagNumber(9)
  void clearSunriseTimestamp() => clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get sunsetTimestamp => $_getI64(9);
  @$pb.TagNumber(10)
  set sunsetTimestamp($fixnum.Int64 v) {
    $_setInt64(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasSunsetTimestamp() => $_has(9);
  @$pb.TagNumber(10)
  void clearSunsetTimestamp() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get timeZone => $_getSZ(10);
  @$pb.TagNumber(11)
  set timeZone($core.String v) {
    $_setString(10, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasTimeZone() => $_has(10);
  @$pb.TagNumber(11)
  void clearTimeZone() => clearField(11);

  @$pb.TagNumber(12)
  MultiMeasurement get temperature => $_getN(11);
  @$pb.TagNumber(12)
  set temperature(MultiMeasurement v) {
    setField(12, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasTemperature() => $_has(11);
  @$pb.TagNumber(12)
  void clearTemperature() => clearField(12);
  @$pb.TagNumber(12)
  MultiMeasurement ensureTemperature() => $_ensure(11);

  @$pb.TagNumber(13)
  MultiMeasurement get windSpeed => $_getN(12);
  @$pb.TagNumber(13)
  set windSpeed(MultiMeasurement v) {
    setField(13, v);
  }

  @$pb.TagNumber(13)
  $core.bool hasWindSpeed() => $_has(12);
  @$pb.TagNumber(13)
  void clearWindSpeed() => clearField(13);
  @$pb.TagNumber(13)
  MultiMeasurement ensureWindSpeed() => $_ensure(12);

  @$pb.TagNumber(14)
  MultiMeasurement get pressure => $_getN(13);
  @$pb.TagNumber(14)
  set pressure(MultiMeasurement v) {
    setField(14, v);
  }

  @$pb.TagNumber(14)
  $core.bool hasPressure() => $_has(13);
  @$pb.TagNumber(14)
  void clearPressure() => clearField(14);
  @$pb.TagNumber(14)
  MultiMeasurement ensurePressure() => $_ensure(13);

  @$pb.TagNumber(15)
  MultiMeasurement get humidity => $_getN(14);
  @$pb.TagNumber(15)
  set humidity(MultiMeasurement v) {
    setField(15, v);
  }

  @$pb.TagNumber(15)
  $core.bool hasHumidity() => $_has(14);
  @$pb.TagNumber(15)
  void clearHumidity() => clearField(15);
  @$pb.TagNumber(15)
  MultiMeasurement ensureHumidity() => $_ensure(14);

  @$pb.TagNumber(16)
  MultiMeasurement get visibility => $_getN(15);
  @$pb.TagNumber(16)
  set visibility(MultiMeasurement v) {
    setField(16, v);
  }

  @$pb.TagNumber(16)
  $core.bool hasVisibility() => $_has(15);
  @$pb.TagNumber(16)
  void clearVisibility() => clearField(16);
  @$pb.TagNumber(16)
  MultiMeasurement ensureVisibility() => $_ensure(15);
}

class CustomEntity extends $pb.GeneratedMessage {
  factory CustomEntity({
    Id? id,
    $core.String? name,
    $core.String? description,
    CustomEntity_Type? type,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (type != null) {
      $result.type = type;
    }
    return $result;
  }
  CustomEntity._() : super();
  factory CustomEntity.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory CustomEntity.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CustomEntity',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'id', subBuilder: Id.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..e<CustomEntity_Type>(4, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: CustomEntity_Type.boolean,
        valueOf: CustomEntity_Type.valueOf,
        enumValues: CustomEntity_Type.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  CustomEntity clone() => CustomEntity()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  CustomEntity copyWith(void Function(CustomEntity) updates) =>
      super.copyWith((message) => updates(message as CustomEntity))
          as CustomEntity;

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
  factory CustomEntityValue({
    Id? customEntityId,
    $core.String? value,
  }) {
    final $result = create();
    if (customEntityId != null) {
      $result.customEntityId = customEntityId;
    }
    if (value != null) {
      $result.value = value;
    }
    return $result;
  }
  CustomEntityValue._() : super();
  factory CustomEntityValue.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory CustomEntityValue.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CustomEntityValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'customEntityId', subBuilder: Id.create)
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  CustomEntityValue clone() => CustomEntityValue()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  CustomEntityValue copyWith(void Function(CustomEntityValue) updates) =>
      super.copyWith((message) => updates(message as CustomEntityValue))
          as CustomEntityValue;

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
  factory Bait({
    Id? id,
    $core.String? name,
    Id? baitCategoryId,
    $core.String? imageName,
    Bait_Type? type,
    $core.Iterable<BaitVariant>? variants,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (baitCategoryId != null) {
      $result.baitCategoryId = baitCategoryId;
    }
    if (imageName != null) {
      $result.imageName = imageName;
    }
    if (type != null) {
      $result.type = type;
    }
    if (variants != null) {
      $result.variants.addAll(variants);
    }
    return $result;
  }
  Bait._() : super();
  factory Bait.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Bait.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Bait',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'id', subBuilder: Id.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOM<Id>(3, _omitFieldNames ? '' : 'baitCategoryId', subBuilder: Id.create)
    ..aOS(4, _omitFieldNames ? '' : 'imageName')
    ..e<Bait_Type>(5, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: Bait_Type.artificial,
        valueOf: Bait_Type.valueOf,
        enumValues: Bait_Type.values)
    ..pc<BaitVariant>(6, _omitFieldNames ? '' : 'variants', $pb.PbFieldType.PM,
        subBuilder: BaitVariant.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Bait clone() => Bait()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Bait copyWith(void Function(Bait) updates) =>
      super.copyWith((message) => updates(message as Bait)) as Bait;

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
  $core.String get imageName => $_getSZ(3);
  @$pb.TagNumber(4)
  set imageName($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasImageName() => $_has(3);
  @$pb.TagNumber(4)
  void clearImageName() => clearField(4);

  @$pb.TagNumber(5)
  Bait_Type get type => $_getN(4);
  @$pb.TagNumber(5)
  set type(Bait_Type v) {
    setField(5, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasType() => $_has(4);
  @$pb.TagNumber(5)
  void clearType() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<BaitVariant> get variants => $_getList(5);
}

class BaitVariant extends $pb.GeneratedMessage {
  factory BaitVariant({
    Id? id,
    Id? baseId,
    $core.String? color,
    $core.String? modelNumber,
    $core.String? size,
    MultiMeasurement? minDiveDepth,
    MultiMeasurement? maxDiveDepth,
    $core.String? description,
    $core.Iterable<CustomEntityValue>? customEntityValues,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (baseId != null) {
      $result.baseId = baseId;
    }
    if (color != null) {
      $result.color = color;
    }
    if (modelNumber != null) {
      $result.modelNumber = modelNumber;
    }
    if (size != null) {
      $result.size = size;
    }
    if (minDiveDepth != null) {
      $result.minDiveDepth = minDiveDepth;
    }
    if (maxDiveDepth != null) {
      $result.maxDiveDepth = maxDiveDepth;
    }
    if (description != null) {
      $result.description = description;
    }
    if (customEntityValues != null) {
      $result.customEntityValues.addAll(customEntityValues);
    }
    return $result;
  }
  BaitVariant._() : super();
  factory BaitVariant.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory BaitVariant.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BaitVariant',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'id', subBuilder: Id.create)
    ..aOM<Id>(2, _omitFieldNames ? '' : 'baseId', subBuilder: Id.create)
    ..aOS(3, _omitFieldNames ? '' : 'color')
    ..aOS(4, _omitFieldNames ? '' : 'modelNumber')
    ..aOS(5, _omitFieldNames ? '' : 'size')
    ..aOM<MultiMeasurement>(6, _omitFieldNames ? '' : 'minDiveDepth',
        subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(7, _omitFieldNames ? '' : 'maxDiveDepth',
        subBuilder: MultiMeasurement.create)
    ..aOS(8, _omitFieldNames ? '' : 'description')
    ..pc<CustomEntityValue>(
        9, _omitFieldNames ? '' : 'customEntityValues', $pb.PbFieldType.PM,
        subBuilder: CustomEntityValue.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  BaitVariant clone() => BaitVariant()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  BaitVariant copyWith(void Function(BaitVariant) updates) =>
      super.copyWith((message) => updates(message as BaitVariant))
          as BaitVariant;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BaitVariant create() => BaitVariant._();
  BaitVariant createEmptyInstance() => create();
  static $pb.PbList<BaitVariant> createRepeated() => $pb.PbList<BaitVariant>();
  @$core.pragma('dart2js:noInline')
  static BaitVariant getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BaitVariant>(create);
  static BaitVariant? _defaultInstance;

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
  Id get baseId => $_getN(1);
  @$pb.TagNumber(2)
  set baseId(Id v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasBaseId() => $_has(1);
  @$pb.TagNumber(2)
  void clearBaseId() => clearField(2);
  @$pb.TagNumber(2)
  Id ensureBaseId() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get color => $_getSZ(2);
  @$pb.TagNumber(3)
  set color($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasColor() => $_has(2);
  @$pb.TagNumber(3)
  void clearColor() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get modelNumber => $_getSZ(3);
  @$pb.TagNumber(4)
  set modelNumber($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasModelNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearModelNumber() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get size => $_getSZ(4);
  @$pb.TagNumber(5)
  set size($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearSize() => clearField(5);

  @$pb.TagNumber(6)
  MultiMeasurement get minDiveDepth => $_getN(5);
  @$pb.TagNumber(6)
  set minDiveDepth(MultiMeasurement v) {
    setField(6, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasMinDiveDepth() => $_has(5);
  @$pb.TagNumber(6)
  void clearMinDiveDepth() => clearField(6);
  @$pb.TagNumber(6)
  MultiMeasurement ensureMinDiveDepth() => $_ensure(5);

  @$pb.TagNumber(7)
  MultiMeasurement get maxDiveDepth => $_getN(6);
  @$pb.TagNumber(7)
  set maxDiveDepth(MultiMeasurement v) {
    setField(7, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasMaxDiveDepth() => $_has(6);
  @$pb.TagNumber(7)
  void clearMaxDiveDepth() => clearField(7);
  @$pb.TagNumber(7)
  MultiMeasurement ensureMaxDiveDepth() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.String get description => $_getSZ(7);
  @$pb.TagNumber(8)
  set description($core.String v) {
    $_setString(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasDescription() => $_has(7);
  @$pb.TagNumber(8)
  void clearDescription() => clearField(8);

  @$pb.TagNumber(9)
  $core.List<CustomEntityValue> get customEntityValues => $_getList(8);
}

/// A "picked bait" is a Bait or Bait/BaitVariant combination that has been attached to another
/// entity, such as a Catch or Report.
class BaitAttachment extends $pb.GeneratedMessage {
  factory BaitAttachment({
    Id? baitId,
    Id? variantId,
  }) {
    final $result = create();
    if (baitId != null) {
      $result.baitId = baitId;
    }
    if (variantId != null) {
      $result.variantId = variantId;
    }
    return $result;
  }
  BaitAttachment._() : super();
  factory BaitAttachment.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory BaitAttachment.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BaitAttachment',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'baitId', subBuilder: Id.create)
    ..aOM<Id>(2, _omitFieldNames ? '' : 'variantId', subBuilder: Id.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  BaitAttachment clone() => BaitAttachment()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  BaitAttachment copyWith(void Function(BaitAttachment) updates) =>
      super.copyWith((message) => updates(message as BaitAttachment))
          as BaitAttachment;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BaitAttachment create() => BaitAttachment._();
  BaitAttachment createEmptyInstance() => create();
  static $pb.PbList<BaitAttachment> createRepeated() =>
      $pb.PbList<BaitAttachment>();
  @$core.pragma('dart2js:noInline')
  static BaitAttachment getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BaitAttachment>(create);
  static BaitAttachment? _defaultInstance;

  @$pb.TagNumber(1)
  Id get baitId => $_getN(0);
  @$pb.TagNumber(1)
  set baitId(Id v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasBaitId() => $_has(0);
  @$pb.TagNumber(1)
  void clearBaitId() => clearField(1);
  @$pb.TagNumber(1)
  Id ensureBaitId() => $_ensure(0);

  @$pb.TagNumber(2)
  Id get variantId => $_getN(1);
  @$pb.TagNumber(2)
  set variantId(Id v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasVariantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearVariantId() => clearField(2);
  @$pb.TagNumber(2)
  Id ensureVariantId() => $_ensure(1);
}

class BaitCategory extends $pb.GeneratedMessage {
  factory BaitCategory({
    Id? id,
    $core.String? name,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    return $result;
  }
  BaitCategory._() : super();
  factory BaitCategory.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory BaitCategory.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BaitCategory',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'id', subBuilder: Id.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  BaitCategory clone() => BaitCategory()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  BaitCategory copyWith(void Function(BaitCategory) updates) =>
      super.copyWith((message) => updates(message as BaitCategory))
          as BaitCategory;

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
  factory Catch({
    Id? id,
    $fixnum.Int64? timestamp,
    $core.Iterable<BaitAttachment>? baits,
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
    Atmosphere? atmosphere,
    Tide? tide,
    $core.String? timeZone,
    $core.Iterable<Id>? gearIds,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (baits != null) {
      $result.baits.addAll(baits);
    }
    if (fishingSpotId != null) {
      $result.fishingSpotId = fishingSpotId;
    }
    if (speciesId != null) {
      $result.speciesId = speciesId;
    }
    if (imageNames != null) {
      $result.imageNames.addAll(imageNames);
    }
    if (customEntityValues != null) {
      $result.customEntityValues.addAll(customEntityValues);
    }
    if (anglerId != null) {
      $result.anglerId = anglerId;
    }
    if (methodIds != null) {
      $result.methodIds.addAll(methodIds);
    }
    if (period != null) {
      $result.period = period;
    }
    if (isFavorite != null) {
      $result.isFavorite = isFavorite;
    }
    if (wasCatchAndRelease != null) {
      $result.wasCatchAndRelease = wasCatchAndRelease;
    }
    if (season != null) {
      $result.season = season;
    }
    if (waterClarityId != null) {
      $result.waterClarityId = waterClarityId;
    }
    if (waterDepth != null) {
      $result.waterDepth = waterDepth;
    }
    if (waterTemperature != null) {
      $result.waterTemperature = waterTemperature;
    }
    if (length != null) {
      $result.length = length;
    }
    if (weight != null) {
      $result.weight = weight;
    }
    if (quantity != null) {
      $result.quantity = quantity;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    if (atmosphere != null) {
      $result.atmosphere = atmosphere;
    }
    if (tide != null) {
      $result.tide = tide;
    }
    if (timeZone != null) {
      $result.timeZone = timeZone;
    }
    if (gearIds != null) {
      $result.gearIds.addAll(gearIds);
    }
    return $result;
  }
  Catch._() : super();
  factory Catch.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Catch.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Catch',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'id', subBuilder: Id.create)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pc<BaitAttachment>(3, _omitFieldNames ? '' : 'baits', $pb.PbFieldType.PM,
        subBuilder: BaitAttachment.create)
    ..aOM<Id>(4, _omitFieldNames ? '' : 'fishingSpotId', subBuilder: Id.create)
    ..aOM<Id>(5, _omitFieldNames ? '' : 'speciesId', subBuilder: Id.create)
    ..pPS(6, _omitFieldNames ? '' : 'imageNames')
    ..pc<CustomEntityValue>(
        7, _omitFieldNames ? '' : 'customEntityValues', $pb.PbFieldType.PM,
        subBuilder: CustomEntityValue.create)
    ..aOM<Id>(8, _omitFieldNames ? '' : 'anglerId', subBuilder: Id.create)
    ..pc<Id>(9, _omitFieldNames ? '' : 'methodIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..e<Period>(10, _omitFieldNames ? '' : 'period', $pb.PbFieldType.OE,
        defaultOrMaker: Period.period_all,
        valueOf: Period.valueOf,
        enumValues: Period.values)
    ..aOB(11, _omitFieldNames ? '' : 'isFavorite')
    ..aOB(12, _omitFieldNames ? '' : 'wasCatchAndRelease')
    ..e<Season>(13, _omitFieldNames ? '' : 'season', $pb.PbFieldType.OE,
        defaultOrMaker: Season.season_all,
        valueOf: Season.valueOf,
        enumValues: Season.values)
    ..aOM<Id>(14, _omitFieldNames ? '' : 'waterClarityId',
        subBuilder: Id.create)
    ..aOM<MultiMeasurement>(15, _omitFieldNames ? '' : 'waterDepth',
        subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(16, _omitFieldNames ? '' : 'waterTemperature',
        subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(17, _omitFieldNames ? '' : 'length',
        subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(18, _omitFieldNames ? '' : 'weight',
        subBuilder: MultiMeasurement.create)
    ..a<$core.int>(19, _omitFieldNames ? '' : 'quantity', $pb.PbFieldType.OU3)
    ..aOS(20, _omitFieldNames ? '' : 'notes')
    ..aOM<Atmosphere>(21, _omitFieldNames ? '' : 'atmosphere',
        subBuilder: Atmosphere.create)
    ..aOM<Tide>(22, _omitFieldNames ? '' : 'tide', subBuilder: Tide.create)
    ..aOS(23, _omitFieldNames ? '' : 'timeZone')
    ..pc<Id>(24, _omitFieldNames ? '' : 'gearIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Catch clone() => Catch()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Catch copyWith(void Function(Catch) updates) =>
      super.copyWith((message) => updates(message as Catch)) as Catch;

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
  $core.List<BaitAttachment> get baits => $_getList(2);

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

  @$pb.TagNumber(21)
  Atmosphere get atmosphere => $_getN(20);
  @$pb.TagNumber(21)
  set atmosphere(Atmosphere v) {
    setField(21, v);
  }

  @$pb.TagNumber(21)
  $core.bool hasAtmosphere() => $_has(20);
  @$pb.TagNumber(21)
  void clearAtmosphere() => clearField(21);
  @$pb.TagNumber(21)
  Atmosphere ensureAtmosphere() => $_ensure(20);

  @$pb.TagNumber(22)
  Tide get tide => $_getN(21);
  @$pb.TagNumber(22)
  set tide(Tide v) {
    setField(22, v);
  }

  @$pb.TagNumber(22)
  $core.bool hasTide() => $_has(21);
  @$pb.TagNumber(22)
  void clearTide() => clearField(22);
  @$pb.TagNumber(22)
  Tide ensureTide() => $_ensure(21);

  @$pb.TagNumber(23)
  $core.String get timeZone => $_getSZ(22);
  @$pb.TagNumber(23)
  set timeZone($core.String v) {
    $_setString(22, v);
  }

  @$pb.TagNumber(23)
  $core.bool hasTimeZone() => $_has(22);
  @$pb.TagNumber(23)
  void clearTimeZone() => clearField(23);

  @$pb.TagNumber(24)
  $core.List<Id> get gearIds => $_getList(23);
}

class DateRange extends $pb.GeneratedMessage {
  factory DateRange({
    DateRange_Period? period,
    $fixnum.Int64? startTimestamp,
    $fixnum.Int64? endTimestamp,
    $core.String? timeZone,
  }) {
    final $result = create();
    if (period != null) {
      $result.period = period;
    }
    if (startTimestamp != null) {
      $result.startTimestamp = startTimestamp;
    }
    if (endTimestamp != null) {
      $result.endTimestamp = endTimestamp;
    }
    if (timeZone != null) {
      $result.timeZone = timeZone;
    }
    return $result;
  }
  DateRange._() : super();
  factory DateRange.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory DateRange.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DateRange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..e<DateRange_Period>(
        1, _omitFieldNames ? '' : 'period', $pb.PbFieldType.OE,
        defaultOrMaker: DateRange_Period.allDates,
        valueOf: DateRange_Period.valueOf,
        enumValues: DateRange_Period.values)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'startTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'endTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(23, _omitFieldNames ? '' : 'timeZone')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  DateRange clone() => DateRange()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  DateRange copyWith(void Function(DateRange) updates) =>
      super.copyWith((message) => updates(message as DateRange)) as DateRange;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DateRange create() => DateRange._();
  DateRange createEmptyInstance() => create();
  static $pb.PbList<DateRange> createRepeated() => $pb.PbList<DateRange>();
  @$core.pragma('dart2js:noInline')
  static DateRange getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DateRange>(create);
  static DateRange? _defaultInstance;

  @$pb.TagNumber(1)
  DateRange_Period get period => $_getN(0);
  @$pb.TagNumber(1)
  set period(DateRange_Period v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasPeriod() => $_has(0);
  @$pb.TagNumber(1)
  void clearPeriod() => clearField(1);

  /// Should only be set for Period.custom.
  @$pb.TagNumber(2)
  $fixnum.Int64 get startTimestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set startTimestamp($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasStartTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTimestamp() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get endTimestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set endTimestamp($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasEndTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndTimestamp() => clearField(3);

  @$pb.TagNumber(23)
  $core.String get timeZone => $_getSZ(3);
  @$pb.TagNumber(23)
  set timeZone($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(23)
  $core.bool hasTimeZone() => $_has(3);
  @$pb.TagNumber(23)
  void clearTimeZone() => clearField(23);
}

class BodyOfWater extends $pb.GeneratedMessage {
  factory BodyOfWater({
    Id? id,
    $core.String? name,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    return $result;
  }
  BodyOfWater._() : super();
  factory BodyOfWater.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory BodyOfWater.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BodyOfWater',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'id', subBuilder: Id.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  BodyOfWater clone() => BodyOfWater()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  BodyOfWater copyWith(void Function(BodyOfWater) updates) =>
      super.copyWith((message) => updates(message as BodyOfWater))
          as BodyOfWater;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BodyOfWater create() => BodyOfWater._();
  BodyOfWater createEmptyInstance() => create();
  static $pb.PbList<BodyOfWater> createRepeated() => $pb.PbList<BodyOfWater>();
  @$core.pragma('dart2js:noInline')
  static BodyOfWater getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BodyOfWater>(create);
  static BodyOfWater? _defaultInstance;

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

class FishingSpot extends $pb.GeneratedMessage {
  factory FishingSpot({
    Id? id,
    $core.String? name,
    $core.double? lat,
    $core.double? lng,
    Id? bodyOfWaterId,
    $core.String? imageName,
    $core.String? notes,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (lat != null) {
      $result.lat = lat;
    }
    if (lng != null) {
      $result.lng = lng;
    }
    if (bodyOfWaterId != null) {
      $result.bodyOfWaterId = bodyOfWaterId;
    }
    if (imageName != null) {
      $result.imageName = imageName;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    return $result;
  }
  FishingSpot._() : super();
  factory FishingSpot.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory FishingSpot.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FishingSpot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'id', subBuilder: Id.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'lat', $pb.PbFieldType.OD)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'lng', $pb.PbFieldType.OD)
    ..aOM<Id>(5, _omitFieldNames ? '' : 'bodyOfWaterId', subBuilder: Id.create)
    ..aOS(6, _omitFieldNames ? '' : 'imageName')
    ..aOS(7, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  FishingSpot clone() => FishingSpot()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  FishingSpot copyWith(void Function(FishingSpot) updates) =>
      super.copyWith((message) => updates(message as FishingSpot))
          as FishingSpot;

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

  @$pb.TagNumber(5)
  Id get bodyOfWaterId => $_getN(4);
  @$pb.TagNumber(5)
  set bodyOfWaterId(Id v) {
    setField(5, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasBodyOfWaterId() => $_has(4);
  @$pb.TagNumber(5)
  void clearBodyOfWaterId() => clearField(5);
  @$pb.TagNumber(5)
  Id ensureBodyOfWaterId() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get imageName => $_getSZ(5);
  @$pb.TagNumber(6)
  set imageName($core.String v) {
    $_setString(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasImageName() => $_has(5);
  @$pb.TagNumber(6)
  void clearImageName() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get notes => $_getSZ(6);
  @$pb.TagNumber(7)
  set notes($core.String v) {
    $_setString(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasNotes() => $_has(6);
  @$pb.TagNumber(7)
  void clearNotes() => clearField(7);
}

class NumberFilter extends $pb.GeneratedMessage {
  factory NumberFilter({
    NumberBoundary? boundary,
    MultiMeasurement? from,
    MultiMeasurement? to,
  }) {
    final $result = create();
    if (boundary != null) {
      $result.boundary = boundary;
    }
    if (from != null) {
      $result.from = from;
    }
    if (to != null) {
      $result.to = to;
    }
    return $result;
  }
  NumberFilter._() : super();
  factory NumberFilter.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory NumberFilter.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NumberFilter',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..e<NumberBoundary>(
        1, _omitFieldNames ? '' : 'boundary', $pb.PbFieldType.OE,
        defaultOrMaker: NumberBoundary.number_boundary_any,
        valueOf: NumberBoundary.valueOf,
        enumValues: NumberBoundary.values)
    ..aOM<MultiMeasurement>(2, _omitFieldNames ? '' : 'from',
        subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(3, _omitFieldNames ? '' : 'to',
        subBuilder: MultiMeasurement.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  NumberFilter clone() => NumberFilter()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  NumberFilter copyWith(void Function(NumberFilter) updates) =>
      super.copyWith((message) => updates(message as NumberFilter))
          as NumberFilter;

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
  factory Species({
    Id? id,
    $core.String? name,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    return $result;
  }
  Species._() : super();
  factory Species.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Species.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Species',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'id', subBuilder: Id.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Species clone() => Species()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Species copyWith(void Function(Species) updates) =>
      super.copyWith((message) => updates(message as Species)) as Species;

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
  factory Report({
    Id? id,
    $core.String? name,
    $core.String? description,
    Report_Type? type,
    DateRange? fromDateRange,
    DateRange? toDateRange,
    $core.Iterable<BaitAttachment>? baits,
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
    NumberFilter? airTemperatureFilter,
    NumberFilter? airPressureFilter,
    NumberFilter? airHumidityFilter,
    NumberFilter? airVisibilityFilter,
    NumberFilter? windSpeedFilter,
    $core.Iterable<Direction>? windDirections,
    $core.Iterable<SkyCondition>? skyConditions,
    $core.Iterable<MoonPhase>? moonPhases,
    $core.Iterable<TideType>? tideTypes,
    $core.Iterable<Id>? bodyOfWaterIds,
    $core.String? timeZone,
    $core.Iterable<Id>? gearIds,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (description != null) {
      $result.description = description;
    }
    if (type != null) {
      $result.type = type;
    }
    if (fromDateRange != null) {
      $result.fromDateRange = fromDateRange;
    }
    if (toDateRange != null) {
      $result.toDateRange = toDateRange;
    }
    if (baits != null) {
      $result.baits.addAll(baits);
    }
    if (fishingSpotIds != null) {
      $result.fishingSpotIds.addAll(fishingSpotIds);
    }
    if (speciesIds != null) {
      $result.speciesIds.addAll(speciesIds);
    }
    if (anglerIds != null) {
      $result.anglerIds.addAll(anglerIds);
    }
    if (methodIds != null) {
      $result.methodIds.addAll(methodIds);
    }
    if (periods != null) {
      $result.periods.addAll(periods);
    }
    if (isFavoritesOnly != null) {
      $result.isFavoritesOnly = isFavoritesOnly;
    }
    if (isCatchAndReleaseOnly != null) {
      $result.isCatchAndReleaseOnly = isCatchAndReleaseOnly;
    }
    if (seasons != null) {
      $result.seasons.addAll(seasons);
    }
    if (waterClarityIds != null) {
      $result.waterClarityIds.addAll(waterClarityIds);
    }
    if (waterDepthFilter != null) {
      $result.waterDepthFilter = waterDepthFilter;
    }
    if (waterTemperatureFilter != null) {
      $result.waterTemperatureFilter = waterTemperatureFilter;
    }
    if (lengthFilter != null) {
      $result.lengthFilter = lengthFilter;
    }
    if (weightFilter != null) {
      $result.weightFilter = weightFilter;
    }
    if (quantityFilter != null) {
      $result.quantityFilter = quantityFilter;
    }
    if (airTemperatureFilter != null) {
      $result.airTemperatureFilter = airTemperatureFilter;
    }
    if (airPressureFilter != null) {
      $result.airPressureFilter = airPressureFilter;
    }
    if (airHumidityFilter != null) {
      $result.airHumidityFilter = airHumidityFilter;
    }
    if (airVisibilityFilter != null) {
      $result.airVisibilityFilter = airVisibilityFilter;
    }
    if (windSpeedFilter != null) {
      $result.windSpeedFilter = windSpeedFilter;
    }
    if (windDirections != null) {
      $result.windDirections.addAll(windDirections);
    }
    if (skyConditions != null) {
      $result.skyConditions.addAll(skyConditions);
    }
    if (moonPhases != null) {
      $result.moonPhases.addAll(moonPhases);
    }
    if (tideTypes != null) {
      $result.tideTypes.addAll(tideTypes);
    }
    if (bodyOfWaterIds != null) {
      $result.bodyOfWaterIds.addAll(bodyOfWaterIds);
    }
    if (timeZone != null) {
      $result.timeZone = timeZone;
    }
    if (gearIds != null) {
      $result.gearIds.addAll(gearIds);
    }
    return $result;
  }
  Report._() : super();
  factory Report.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Report.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Report',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'id', subBuilder: Id.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..e<Report_Type>(4, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: Report_Type.summary,
        valueOf: Report_Type.valueOf,
        enumValues: Report_Type.values)
    ..aOM<DateRange>(5, _omitFieldNames ? '' : 'fromDateRange',
        subBuilder: DateRange.create)
    ..aOM<DateRange>(6, _omitFieldNames ? '' : 'toDateRange',
        subBuilder: DateRange.create)
    ..pc<BaitAttachment>(7, _omitFieldNames ? '' : 'baits', $pb.PbFieldType.PM,
        subBuilder: BaitAttachment.create)
    ..pc<Id>(8, _omitFieldNames ? '' : 'fishingSpotIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..pc<Id>(9, _omitFieldNames ? '' : 'speciesIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..pc<Id>(10, _omitFieldNames ? '' : 'anglerIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..pc<Id>(11, _omitFieldNames ? '' : 'methodIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..pc<Period>(12, _omitFieldNames ? '' : 'periods', $pb.PbFieldType.KE,
        valueOf: Period.valueOf,
        enumValues: Period.values,
        defaultEnumValue: Period.period_all)
    ..aOB(13, _omitFieldNames ? '' : 'isFavoritesOnly')
    ..aOB(14, _omitFieldNames ? '' : 'isCatchAndReleaseOnly')
    ..pc<Season>(15, _omitFieldNames ? '' : 'seasons', $pb.PbFieldType.KE,
        valueOf: Season.valueOf,
        enumValues: Season.values,
        defaultEnumValue: Season.season_all)
    ..pc<Id>(16, _omitFieldNames ? '' : 'waterClarityIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..aOM<NumberFilter>(17, _omitFieldNames ? '' : 'waterDepthFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(18, _omitFieldNames ? '' : 'waterTemperatureFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(19, _omitFieldNames ? '' : 'lengthFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(20, _omitFieldNames ? '' : 'weightFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(21, _omitFieldNames ? '' : 'quantityFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(22, _omitFieldNames ? '' : 'airTemperatureFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(23, _omitFieldNames ? '' : 'airPressureFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(24, _omitFieldNames ? '' : 'airHumidityFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(25, _omitFieldNames ? '' : 'airVisibilityFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(26, _omitFieldNames ? '' : 'windSpeedFilter',
        subBuilder: NumberFilter.create)
    ..pc<Direction>(
        27, _omitFieldNames ? '' : 'windDirections', $pb.PbFieldType.KE,
        valueOf: Direction.valueOf,
        enumValues: Direction.values,
        defaultEnumValue: Direction.direction_all)
    ..pc<SkyCondition>(
        28, _omitFieldNames ? '' : 'skyConditions', $pb.PbFieldType.KE,
        valueOf: SkyCondition.valueOf,
        enumValues: SkyCondition.values,
        defaultEnumValue: SkyCondition.sky_condition_all)
    ..pc<MoonPhase>(29, _omitFieldNames ? '' : 'moonPhases', $pb.PbFieldType.KE,
        valueOf: MoonPhase.valueOf,
        enumValues: MoonPhase.values,
        defaultEnumValue: MoonPhase.moon_phase_all)
    ..pc<TideType>(30, _omitFieldNames ? '' : 'tideTypes', $pb.PbFieldType.KE,
        valueOf: TideType.valueOf,
        enumValues: TideType.values,
        defaultEnumValue: TideType.tide_type_all)
    ..pc<Id>(31, _omitFieldNames ? '' : 'bodyOfWaterIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..aOS(32, _omitFieldNames ? '' : 'timeZone')
    ..pc<Id>(33, _omitFieldNames ? '' : 'gearIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Report clone() => Report()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Report copyWith(void Function(Report) updates) =>
      super.copyWith((message) => updates(message as Report)) as Report;

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
  DateRange get fromDateRange => $_getN(4);
  @$pb.TagNumber(5)
  set fromDateRange(DateRange v) {
    setField(5, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasFromDateRange() => $_has(4);
  @$pb.TagNumber(5)
  void clearFromDateRange() => clearField(5);
  @$pb.TagNumber(5)
  DateRange ensureFromDateRange() => $_ensure(4);

  @$pb.TagNumber(6)
  DateRange get toDateRange => $_getN(5);
  @$pb.TagNumber(6)
  set toDateRange(DateRange v) {
    setField(6, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasToDateRange() => $_has(5);
  @$pb.TagNumber(6)
  void clearToDateRange() => clearField(6);
  @$pb.TagNumber(6)
  DateRange ensureToDateRange() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.List<BaitAttachment> get baits => $_getList(6);

  @$pb.TagNumber(8)
  $core.List<Id> get fishingSpotIds => $_getList(7);

  @$pb.TagNumber(9)
  $core.List<Id> get speciesIds => $_getList(8);

  @$pb.TagNumber(10)
  $core.List<Id> get anglerIds => $_getList(9);

  @$pb.TagNumber(11)
  $core.List<Id> get methodIds => $_getList(10);

  @$pb.TagNumber(12)
  $core.List<Period> get periods => $_getList(11);

  @$pb.TagNumber(13)
  $core.bool get isFavoritesOnly => $_getBF(12);
  @$pb.TagNumber(13)
  set isFavoritesOnly($core.bool v) {
    $_setBool(12, v);
  }

  @$pb.TagNumber(13)
  $core.bool hasIsFavoritesOnly() => $_has(12);
  @$pb.TagNumber(13)
  void clearIsFavoritesOnly() => clearField(13);

  @$pb.TagNumber(14)
  $core.bool get isCatchAndReleaseOnly => $_getBF(13);
  @$pb.TagNumber(14)
  set isCatchAndReleaseOnly($core.bool v) {
    $_setBool(13, v);
  }

  @$pb.TagNumber(14)
  $core.bool hasIsCatchAndReleaseOnly() => $_has(13);
  @$pb.TagNumber(14)
  void clearIsCatchAndReleaseOnly() => clearField(14);

  @$pb.TagNumber(15)
  $core.List<Season> get seasons => $_getList(14);

  @$pb.TagNumber(16)
  $core.List<Id> get waterClarityIds => $_getList(15);

  @$pb.TagNumber(17)
  NumberFilter get waterDepthFilter => $_getN(16);
  @$pb.TagNumber(17)
  set waterDepthFilter(NumberFilter v) {
    setField(17, v);
  }

  @$pb.TagNumber(17)
  $core.bool hasWaterDepthFilter() => $_has(16);
  @$pb.TagNumber(17)
  void clearWaterDepthFilter() => clearField(17);
  @$pb.TagNumber(17)
  NumberFilter ensureWaterDepthFilter() => $_ensure(16);

  @$pb.TagNumber(18)
  NumberFilter get waterTemperatureFilter => $_getN(17);
  @$pb.TagNumber(18)
  set waterTemperatureFilter(NumberFilter v) {
    setField(18, v);
  }

  @$pb.TagNumber(18)
  $core.bool hasWaterTemperatureFilter() => $_has(17);
  @$pb.TagNumber(18)
  void clearWaterTemperatureFilter() => clearField(18);
  @$pb.TagNumber(18)
  NumberFilter ensureWaterTemperatureFilter() => $_ensure(17);

  @$pb.TagNumber(19)
  NumberFilter get lengthFilter => $_getN(18);
  @$pb.TagNumber(19)
  set lengthFilter(NumberFilter v) {
    setField(19, v);
  }

  @$pb.TagNumber(19)
  $core.bool hasLengthFilter() => $_has(18);
  @$pb.TagNumber(19)
  void clearLengthFilter() => clearField(19);
  @$pb.TagNumber(19)
  NumberFilter ensureLengthFilter() => $_ensure(18);

  @$pb.TagNumber(20)
  NumberFilter get weightFilter => $_getN(19);
  @$pb.TagNumber(20)
  set weightFilter(NumberFilter v) {
    setField(20, v);
  }

  @$pb.TagNumber(20)
  $core.bool hasWeightFilter() => $_has(19);
  @$pb.TagNumber(20)
  void clearWeightFilter() => clearField(20);
  @$pb.TagNumber(20)
  NumberFilter ensureWeightFilter() => $_ensure(19);

  @$pb.TagNumber(21)
  NumberFilter get quantityFilter => $_getN(20);
  @$pb.TagNumber(21)
  set quantityFilter(NumberFilter v) {
    setField(21, v);
  }

  @$pb.TagNumber(21)
  $core.bool hasQuantityFilter() => $_has(20);
  @$pb.TagNumber(21)
  void clearQuantityFilter() => clearField(21);
  @$pb.TagNumber(21)
  NumberFilter ensureQuantityFilter() => $_ensure(20);

  @$pb.TagNumber(22)
  NumberFilter get airTemperatureFilter => $_getN(21);
  @$pb.TagNumber(22)
  set airTemperatureFilter(NumberFilter v) {
    setField(22, v);
  }

  @$pb.TagNumber(22)
  $core.bool hasAirTemperatureFilter() => $_has(21);
  @$pb.TagNumber(22)
  void clearAirTemperatureFilter() => clearField(22);
  @$pb.TagNumber(22)
  NumberFilter ensureAirTemperatureFilter() => $_ensure(21);

  @$pb.TagNumber(23)
  NumberFilter get airPressureFilter => $_getN(22);
  @$pb.TagNumber(23)
  set airPressureFilter(NumberFilter v) {
    setField(23, v);
  }

  @$pb.TagNumber(23)
  $core.bool hasAirPressureFilter() => $_has(22);
  @$pb.TagNumber(23)
  void clearAirPressureFilter() => clearField(23);
  @$pb.TagNumber(23)
  NumberFilter ensureAirPressureFilter() => $_ensure(22);

  @$pb.TagNumber(24)
  NumberFilter get airHumidityFilter => $_getN(23);
  @$pb.TagNumber(24)
  set airHumidityFilter(NumberFilter v) {
    setField(24, v);
  }

  @$pb.TagNumber(24)
  $core.bool hasAirHumidityFilter() => $_has(23);
  @$pb.TagNumber(24)
  void clearAirHumidityFilter() => clearField(24);
  @$pb.TagNumber(24)
  NumberFilter ensureAirHumidityFilter() => $_ensure(23);

  @$pb.TagNumber(25)
  NumberFilter get airVisibilityFilter => $_getN(24);
  @$pb.TagNumber(25)
  set airVisibilityFilter(NumberFilter v) {
    setField(25, v);
  }

  @$pb.TagNumber(25)
  $core.bool hasAirVisibilityFilter() => $_has(24);
  @$pb.TagNumber(25)
  void clearAirVisibilityFilter() => clearField(25);
  @$pb.TagNumber(25)
  NumberFilter ensureAirVisibilityFilter() => $_ensure(24);

  @$pb.TagNumber(26)
  NumberFilter get windSpeedFilter => $_getN(25);
  @$pb.TagNumber(26)
  set windSpeedFilter(NumberFilter v) {
    setField(26, v);
  }

  @$pb.TagNumber(26)
  $core.bool hasWindSpeedFilter() => $_has(25);
  @$pb.TagNumber(26)
  void clearWindSpeedFilter() => clearField(26);
  @$pb.TagNumber(26)
  NumberFilter ensureWindSpeedFilter() => $_ensure(25);

  @$pb.TagNumber(27)
  $core.List<Direction> get windDirections => $_getList(26);

  @$pb.TagNumber(28)
  $core.List<SkyCondition> get skyConditions => $_getList(27);

  @$pb.TagNumber(29)
  $core.List<MoonPhase> get moonPhases => $_getList(28);

  @$pb.TagNumber(30)
  $core.List<TideType> get tideTypes => $_getList(29);

  @$pb.TagNumber(31)
  $core.List<Id> get bodyOfWaterIds => $_getList(30);

  @$pb.TagNumber(32)
  $core.String get timeZone => $_getSZ(31);
  @$pb.TagNumber(32)
  set timeZone($core.String v) {
    $_setString(31, v);
  }

  @$pb.TagNumber(32)
  $core.bool hasTimeZone() => $_has(31);
  @$pb.TagNumber(32)
  void clearTimeZone() => clearField(32);

  @$pb.TagNumber(33)
  $core.List<Id> get gearIds => $_getList(32);
}

class Angler extends $pb.GeneratedMessage {
  factory Angler({
    Id? id,
    $core.String? name,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    return $result;
  }
  Angler._() : super();
  factory Angler.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Angler.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Angler',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'id', subBuilder: Id.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Angler clone() => Angler()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Angler copyWith(void Function(Angler) updates) =>
      super.copyWith((message) => updates(message as Angler)) as Angler;

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
  factory Method({
    Id? id,
    $core.String? name,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    return $result;
  }
  Method._() : super();
  factory Method.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Method.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Method',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'id', subBuilder: Id.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Method clone() => Method()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Method copyWith(void Function(Method) updates) =>
      super.copyWith((message) => updates(message as Method)) as Method;

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
  factory WaterClarity({
    Id? id,
    $core.String? name,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    return $result;
  }
  WaterClarity._() : super();
  factory WaterClarity.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory WaterClarity.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WaterClarity',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'id', subBuilder: Id.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  WaterClarity clone() => WaterClarity()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  WaterClarity copyWith(void Function(WaterClarity) updates) =>
      super.copyWith((message) => updates(message as WaterClarity))
          as WaterClarity;

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

class Trip_CatchesPerEntity extends $pb.GeneratedMessage {
  factory Trip_CatchesPerEntity({
    Id? entityId,
    $core.int? value,
  }) {
    final $result = create();
    if (entityId != null) {
      $result.entityId = entityId;
    }
    if (value != null) {
      $result.value = value;
    }
    return $result;
  }
  Trip_CatchesPerEntity._() : super();
  factory Trip_CatchesPerEntity.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Trip_CatchesPerEntity.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Trip.CatchesPerEntity',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'entityId', subBuilder: Id.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'value', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Trip_CatchesPerEntity clone() =>
      Trip_CatchesPerEntity()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Trip_CatchesPerEntity copyWith(
          void Function(Trip_CatchesPerEntity) updates) =>
      super.copyWith((message) => updates(message as Trip_CatchesPerEntity))
          as Trip_CatchesPerEntity;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Trip_CatchesPerEntity create() => Trip_CatchesPerEntity._();
  Trip_CatchesPerEntity createEmptyInstance() => create();
  static $pb.PbList<Trip_CatchesPerEntity> createRepeated() =>
      $pb.PbList<Trip_CatchesPerEntity>();
  @$core.pragma('dart2js:noInline')
  static Trip_CatchesPerEntity getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Trip_CatchesPerEntity>(create);
  static Trip_CatchesPerEntity? _defaultInstance;

  @$pb.TagNumber(1)
  Id get entityId => $_getN(0);
  @$pb.TagNumber(1)
  set entityId(Id v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasEntityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntityId() => clearField(1);
  @$pb.TagNumber(1)
  Id ensureEntityId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get value => $_getIZ(1);
  @$pb.TagNumber(2)
  set value($core.int v) {
    $_setUnsignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => clearField(2);
}

class Trip_CatchesPerBait extends $pb.GeneratedMessage {
  factory Trip_CatchesPerBait({
    BaitAttachment? attachment,
    $core.int? value,
  }) {
    final $result = create();
    if (attachment != null) {
      $result.attachment = attachment;
    }
    if (value != null) {
      $result.value = value;
    }
    return $result;
  }
  Trip_CatchesPerBait._() : super();
  factory Trip_CatchesPerBait.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Trip_CatchesPerBait.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Trip.CatchesPerBait',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<BaitAttachment>(1, _omitFieldNames ? '' : 'attachment',
        subBuilder: BaitAttachment.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'value', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Trip_CatchesPerBait clone() => Trip_CatchesPerBait()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Trip_CatchesPerBait copyWith(void Function(Trip_CatchesPerBait) updates) =>
      super.copyWith((message) => updates(message as Trip_CatchesPerBait))
          as Trip_CatchesPerBait;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Trip_CatchesPerBait create() => Trip_CatchesPerBait._();
  Trip_CatchesPerBait createEmptyInstance() => create();
  static $pb.PbList<Trip_CatchesPerBait> createRepeated() =>
      $pb.PbList<Trip_CatchesPerBait>();
  @$core.pragma('dart2js:noInline')
  static Trip_CatchesPerBait getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Trip_CatchesPerBait>(create);
  static Trip_CatchesPerBait? _defaultInstance;

  @$pb.TagNumber(1)
  BaitAttachment get attachment => $_getN(0);
  @$pb.TagNumber(1)
  set attachment(BaitAttachment v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasAttachment() => $_has(0);
  @$pb.TagNumber(1)
  void clearAttachment() => clearField(1);
  @$pb.TagNumber(1)
  BaitAttachment ensureAttachment() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get value => $_getIZ(1);
  @$pb.TagNumber(2)
  set value($core.int v) {
    $_setUnsignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => clearField(2);
}

class Trip extends $pb.GeneratedMessage {
  factory Trip({
    Id? id,
    $core.String? name,
    $fixnum.Int64? startTimestamp,
    $fixnum.Int64? endTimestamp,
    $core.Iterable<$core.String>? imageNames,
    $core.Iterable<Id>? catchIds,
    $core.Iterable<Id>? bodyOfWaterIds,
    $core.Iterable<Trip_CatchesPerEntity>? catchesPerFishingSpot,
    $core.Iterable<Trip_CatchesPerEntity>? catchesPerAngler,
    $core.Iterable<Trip_CatchesPerEntity>? catchesPerSpecies,
    $core.Iterable<Trip_CatchesPerBait>? catchesPerBait,
    $core.Iterable<CustomEntityValue>? customEntityValues,
    $core.String? notes,
    Atmosphere? atmosphere,
    $core.String? timeZone,
    $core.Iterable<Id>? gpsTrailIds,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (startTimestamp != null) {
      $result.startTimestamp = startTimestamp;
    }
    if (endTimestamp != null) {
      $result.endTimestamp = endTimestamp;
    }
    if (imageNames != null) {
      $result.imageNames.addAll(imageNames);
    }
    if (catchIds != null) {
      $result.catchIds.addAll(catchIds);
    }
    if (bodyOfWaterIds != null) {
      $result.bodyOfWaterIds.addAll(bodyOfWaterIds);
    }
    if (catchesPerFishingSpot != null) {
      $result.catchesPerFishingSpot.addAll(catchesPerFishingSpot);
    }
    if (catchesPerAngler != null) {
      $result.catchesPerAngler.addAll(catchesPerAngler);
    }
    if (catchesPerSpecies != null) {
      $result.catchesPerSpecies.addAll(catchesPerSpecies);
    }
    if (catchesPerBait != null) {
      $result.catchesPerBait.addAll(catchesPerBait);
    }
    if (customEntityValues != null) {
      $result.customEntityValues.addAll(customEntityValues);
    }
    if (notes != null) {
      $result.notes = notes;
    }
    if (atmosphere != null) {
      $result.atmosphere = atmosphere;
    }
    if (timeZone != null) {
      $result.timeZone = timeZone;
    }
    if (gpsTrailIds != null) {
      $result.gpsTrailIds.addAll(gpsTrailIds);
    }
    return $result;
  }
  Trip._() : super();
  factory Trip.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Trip.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Trip',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'id', subBuilder: Id.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'startTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'endTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPS(5, _omitFieldNames ? '' : 'imageNames')
    ..pc<Id>(6, _omitFieldNames ? '' : 'catchIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..pc<Id>(7, _omitFieldNames ? '' : 'bodyOfWaterIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..pc<Trip_CatchesPerEntity>(
        8, _omitFieldNames ? '' : 'catchesPerFishingSpot', $pb.PbFieldType.PM,
        subBuilder: Trip_CatchesPerEntity.create)
    ..pc<Trip_CatchesPerEntity>(
        9, _omitFieldNames ? '' : 'catchesPerAngler', $pb.PbFieldType.PM,
        subBuilder: Trip_CatchesPerEntity.create)
    ..pc<Trip_CatchesPerEntity>(
        10, _omitFieldNames ? '' : 'catchesPerSpecies', $pb.PbFieldType.PM,
        subBuilder: Trip_CatchesPerEntity.create)
    ..pc<Trip_CatchesPerBait>(
        11, _omitFieldNames ? '' : 'catchesPerBait', $pb.PbFieldType.PM,
        subBuilder: Trip_CatchesPerBait.create)
    ..pc<CustomEntityValue>(
        12, _omitFieldNames ? '' : 'customEntityValues', $pb.PbFieldType.PM,
        subBuilder: CustomEntityValue.create)
    ..aOS(13, _omitFieldNames ? '' : 'notes')
    ..aOM<Atmosphere>(14, _omitFieldNames ? '' : 'atmosphere',
        subBuilder: Atmosphere.create)
    ..aOS(15, _omitFieldNames ? '' : 'timeZone')
    ..pc<Id>(16, _omitFieldNames ? '' : 'gpsTrailIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Trip clone() => Trip()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Trip copyWith(void Function(Trip) updates) =>
      super.copyWith((message) => updates(message as Trip)) as Trip;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Trip create() => Trip._();
  Trip createEmptyInstance() => create();
  static $pb.PbList<Trip> createRepeated() => $pb.PbList<Trip>();
  @$core.pragma('dart2js:noInline')
  static Trip getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Trip>(create);
  static Trip? _defaultInstance;

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
  $fixnum.Int64 get startTimestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set startTimestamp($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasStartTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearStartTimestamp() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get endTimestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set endTimestamp($fixnum.Int64 v) {
    $_setInt64(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasEndTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearEndTimestamp() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.String> get imageNames => $_getList(4);

  @$pb.TagNumber(6)
  $core.List<Id> get catchIds => $_getList(5);

  @$pb.TagNumber(7)
  $core.List<Id> get bodyOfWaterIds => $_getList(6);

  @$pb.TagNumber(8)
  $core.List<Trip_CatchesPerEntity> get catchesPerFishingSpot => $_getList(7);

  @$pb.TagNumber(9)
  $core.List<Trip_CatchesPerEntity> get catchesPerAngler => $_getList(8);

  @$pb.TagNumber(10)
  $core.List<Trip_CatchesPerEntity> get catchesPerSpecies => $_getList(9);

  @$pb.TagNumber(11)
  $core.List<Trip_CatchesPerBait> get catchesPerBait => $_getList(10);

  @$pb.TagNumber(12)
  $core.List<CustomEntityValue> get customEntityValues => $_getList(11);

  @$pb.TagNumber(13)
  $core.String get notes => $_getSZ(12);
  @$pb.TagNumber(13)
  set notes($core.String v) {
    $_setString(12, v);
  }

  @$pb.TagNumber(13)
  $core.bool hasNotes() => $_has(12);
  @$pb.TagNumber(13)
  void clearNotes() => clearField(13);

  @$pb.TagNumber(14)
  Atmosphere get atmosphere => $_getN(13);
  @$pb.TagNumber(14)
  set atmosphere(Atmosphere v) {
    setField(14, v);
  }

  @$pb.TagNumber(14)
  $core.bool hasAtmosphere() => $_has(13);
  @$pb.TagNumber(14)
  void clearAtmosphere() => clearField(14);
  @$pb.TagNumber(14)
  Atmosphere ensureAtmosphere() => $_ensure(13);

  @$pb.TagNumber(15)
  $core.String get timeZone => $_getSZ(14);
  @$pb.TagNumber(15)
  set timeZone($core.String v) {
    $_setString(14, v);
  }

  @$pb.TagNumber(15)
  $core.bool hasTimeZone() => $_has(14);
  @$pb.TagNumber(15)
  void clearTimeZone() => clearField(15);

  @$pb.TagNumber(16)
  $core.List<Id> get gpsTrailIds => $_getList(15);
}

class Measurement extends $pb.GeneratedMessage {
  factory Measurement({
    Unit? unit,
    $core.double? value,
  }) {
    final $result = create();
    if (unit != null) {
      $result.unit = unit;
    }
    if (value != null) {
      $result.value = value;
    }
    return $result;
  }
  Measurement._() : super();
  factory Measurement.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Measurement.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Measurement',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..e<Unit>(1, _omitFieldNames ? '' : 'unit', $pb.PbFieldType.OE,
        defaultOrMaker: Unit.feet,
        valueOf: Unit.valueOf,
        enumValues: Unit.values)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'value', $pb.PbFieldType.OD)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Measurement clone() => Measurement()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Measurement copyWith(void Function(Measurement) updates) =>
      super.copyWith((message) => updates(message as Measurement))
          as Measurement;

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

/// A more accurate version of Measurement to be used with fractional
/// values allowed by the imperial measurement system, such as pounds
/// (mainValue) and ounces (fractionValue).
class MultiMeasurement extends $pb.GeneratedMessage {
  factory MultiMeasurement({
    MeasurementSystem? system,
    Measurement? mainValue,
    Measurement? fractionValue,
    $core.bool? isNegative,
  }) {
    final $result = create();
    if (system != null) {
      $result.system = system;
    }
    if (mainValue != null) {
      $result.mainValue = mainValue;
    }
    if (fractionValue != null) {
      $result.fractionValue = fractionValue;
    }
    if (isNegative != null) {
      $result.isNegative = isNegative;
    }
    return $result;
  }
  MultiMeasurement._() : super();
  factory MultiMeasurement.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory MultiMeasurement.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MultiMeasurement',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..e<MeasurementSystem>(
        1, _omitFieldNames ? '' : 'system', $pb.PbFieldType.OE,
        defaultOrMaker: MeasurementSystem.imperial_whole,
        valueOf: MeasurementSystem.valueOf,
        enumValues: MeasurementSystem.values)
    ..aOM<Measurement>(2, _omitFieldNames ? '' : 'mainValue',
        subBuilder: Measurement.create)
    ..aOM<Measurement>(3, _omitFieldNames ? '' : 'fractionValue',
        subBuilder: Measurement.create)
    ..aOB(4, _omitFieldNames ? '' : 'isNegative')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  MultiMeasurement clone() => MultiMeasurement()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  MultiMeasurement copyWith(void Function(MultiMeasurement) updates) =>
      super.copyWith((message) => updates(message as MultiMeasurement))
          as MultiMeasurement;

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

  /// This is used for a special case for imperial whole system where
  /// the value is between 0 and -1. For example, tide heights.
  @$pb.TagNumber(4)
  $core.bool get isNegative => $_getBF(3);
  @$pb.TagNumber(4)
  set isNegative($core.bool v) {
    $_setBool(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasIsNegative() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsNegative() => clearField(4);
}

class Tide_Height extends $pb.GeneratedMessage {
  factory Tide_Height({
    $fixnum.Int64? timestamp,
    $core.double? value,
  }) {
    final $result = create();
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (value != null) {
      $result.value = value;
    }
    return $result;
  }
  Tide_Height._() : super();
  factory Tide_Height.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Tide_Height.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Tide.Height',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'value', $pb.PbFieldType.OD)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Tide_Height clone() => Tide_Height()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Tide_Height copyWith(void Function(Tide_Height) updates) =>
      super.copyWith((message) => updates(message as Tide_Height))
          as Tide_Height;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tide_Height create() => Tide_Height._();
  Tide_Height createEmptyInstance() => create();
  static $pb.PbList<Tide_Height> createRepeated() => $pb.PbList<Tide_Height>();
  @$core.pragma('dart2js:noInline')
  static Tide_Height getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Tide_Height>(create);
  static Tide_Height? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get timestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set timestamp($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => clearField(1);

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

class Tide extends $pb.GeneratedMessage {
  factory Tide({
    TideType? type,
    $fixnum.Int64? firstLowTimestamp,
    $fixnum.Int64? firstHighTimestamp,
    $core.String? timeZone,
    Tide_Height? height,
    $core.Iterable<Tide_Height>? daysHeights,
    $fixnum.Int64? secondLowTimestamp,
    $fixnum.Int64? secondHighTimestamp,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (firstLowTimestamp != null) {
      $result.firstLowTimestamp = firstLowTimestamp;
    }
    if (firstHighTimestamp != null) {
      $result.firstHighTimestamp = firstHighTimestamp;
    }
    if (timeZone != null) {
      $result.timeZone = timeZone;
    }
    if (height != null) {
      $result.height = height;
    }
    if (daysHeights != null) {
      $result.daysHeights.addAll(daysHeights);
    }
    if (secondLowTimestamp != null) {
      $result.secondLowTimestamp = secondLowTimestamp;
    }
    if (secondHighTimestamp != null) {
      $result.secondHighTimestamp = secondHighTimestamp;
    }
    return $result;
  }
  Tide._() : super();
  factory Tide.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Tide.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Tide',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..e<TideType>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: TideType.tide_type_all,
        valueOf: TideType.valueOf,
        enumValues: TideType.values)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'firstLowTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'firstHighTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, _omitFieldNames ? '' : 'timeZone')
    ..aOM<Tide_Height>(5, _omitFieldNames ? '' : 'height',
        subBuilder: Tide_Height.create)
    ..pc<Tide_Height>(
        6, _omitFieldNames ? '' : 'daysHeights', $pb.PbFieldType.PM,
        subBuilder: Tide_Height.create)
    ..a<$fixnum.Int64>(
        7, _omitFieldNames ? '' : 'secondLowTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        8, _omitFieldNames ? '' : 'secondHighTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Tide clone() => Tide()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Tide copyWith(void Function(Tide) updates) =>
      super.copyWith((message) => updates(message as Tide)) as Tide;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tide create() => Tide._();
  Tide createEmptyInstance() => create();
  static $pb.PbList<Tide> createRepeated() => $pb.PbList<Tide>();
  @$core.pragma('dart2js:noInline')
  static Tide getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Tide>(create);
  static Tide? _defaultInstance;

  @$pb.TagNumber(1)
  TideType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(TideType v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get firstLowTimestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set firstLowTimestamp($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasFirstLowTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearFirstLowTimestamp() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get firstHighTimestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set firstHighTimestamp($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasFirstHighTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearFirstHighTimestamp() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get timeZone => $_getSZ(3);
  @$pb.TagNumber(4)
  set timeZone($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasTimeZone() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimeZone() => clearField(4);

  @$pb.TagNumber(5)
  Tide_Height get height => $_getN(4);
  @$pb.TagNumber(5)
  set height(Tide_Height v) {
    setField(5, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearHeight() => clearField(5);
  @$pb.TagNumber(5)
  Tide_Height ensureHeight() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.List<Tide_Height> get daysHeights => $_getList(5);

  /// There can be up to two low/high times per day.
  @$pb.TagNumber(7)
  $fixnum.Int64 get secondLowTimestamp => $_getI64(6);
  @$pb.TagNumber(7)
  set secondLowTimestamp($fixnum.Int64 v) {
    $_setInt64(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasSecondLowTimestamp() => $_has(6);
  @$pb.TagNumber(7)
  void clearSecondLowTimestamp() => clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get secondHighTimestamp => $_getI64(7);
  @$pb.TagNumber(8)
  set secondHighTimestamp($fixnum.Int64 v) {
    $_setInt64(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasSecondHighTimestamp() => $_has(7);
  @$pb.TagNumber(8)
  void clearSecondHighTimestamp() => clearField(8);
}

/// A message that contains everything needed to filter catches and/or
/// generate reports on a separate dart Isolate.
class CatchFilterOptions extends $pb.GeneratedMessage {
  factory CatchFilterOptions({
    CatchFilterOptions_Order? order,
    $fixnum.Int64? currentTimestamp,
    $core.String? currentTimeZone,
    $core.Map<$core.String, Angler>? allAnglers,
    $core.Map<$core.String, Bait>? allBaits,
    $core.Map<$core.String, BodyOfWater>? allBodiesOfWater,
    $core.Map<$core.String, Catch>? allCatches,
    $core.Map<$core.String, FishingSpot>? allFishingSpots,
    $core.Map<$core.String, Method>? allMethods,
    $core.Map<$core.String, Species>? allSpecies,
    $core.Map<$core.String, WaterClarity>? allWaterClarities,
    $core.bool? isCatchAndReleaseOnly,
    $core.bool? isFavoritesOnly,
    $core.Iterable<DateRange>? dateRanges,
    $core.Iterable<BaitAttachment>? baits,
    $core.Iterable<Id>? catchIds,
    $core.Iterable<Id>? anglerIds,
    $core.Iterable<Id>? fishingSpotIds,
    $core.Iterable<Id>? bodyOfWaterIds,
    $core.Iterable<Id>? methodIds,
    $core.Iterable<Id>? speciesIds,
    $core.Iterable<Id>? waterClarityIds,
    $core.Iterable<Period>? periods,
    $core.Iterable<Season>? seasons,
    $core.Iterable<Direction>? windDirections,
    $core.Iterable<SkyCondition>? skyConditions,
    $core.Iterable<MoonPhase>? moonPhases,
    $core.Iterable<TideType>? tideTypes,
    NumberFilter? waterDepthFilter,
    NumberFilter? waterTemperatureFilter,
    NumberFilter? lengthFilter,
    NumberFilter? weightFilter,
    NumberFilter? quantityFilter,
    NumberFilter? airTemperatureFilter,
    NumberFilter? airPressureFilter,
    NumberFilter? airHumidityFilter,
    NumberFilter? airVisibilityFilter,
    NumberFilter? windSpeedFilter,
    $core.int? hour,
    $core.int? month,
    $core.bool? includeAnglers,
    $core.bool? includeBaits,
    $core.bool? includeBodiesOfWater,
    $core.bool? includeMethods,
    $core.bool? includeFishingSpots,
    $core.bool? includeMoonPhases,
    $core.bool? includeSeasons,
    $core.bool? includeSpecies,
    $core.bool? includeTideTypes,
    $core.bool? includePeriods,
    $core.bool? includeWaterClarities,
    $core.Map<$core.String, Gear>? allGear,
    $core.Iterable<Id>? gearIds,
    $core.bool? includeGear,
  }) {
    final $result = create();
    if (order != null) {
      $result.order = order;
    }
    if (currentTimestamp != null) {
      $result.currentTimestamp = currentTimestamp;
    }
    if (currentTimeZone != null) {
      $result.currentTimeZone = currentTimeZone;
    }
    if (allAnglers != null) {
      $result.allAnglers.addAll(allAnglers);
    }
    if (allBaits != null) {
      $result.allBaits.addAll(allBaits);
    }
    if (allBodiesOfWater != null) {
      $result.allBodiesOfWater.addAll(allBodiesOfWater);
    }
    if (allCatches != null) {
      $result.allCatches.addAll(allCatches);
    }
    if (allFishingSpots != null) {
      $result.allFishingSpots.addAll(allFishingSpots);
    }
    if (allMethods != null) {
      $result.allMethods.addAll(allMethods);
    }
    if (allSpecies != null) {
      $result.allSpecies.addAll(allSpecies);
    }
    if (allWaterClarities != null) {
      $result.allWaterClarities.addAll(allWaterClarities);
    }
    if (isCatchAndReleaseOnly != null) {
      $result.isCatchAndReleaseOnly = isCatchAndReleaseOnly;
    }
    if (isFavoritesOnly != null) {
      $result.isFavoritesOnly = isFavoritesOnly;
    }
    if (dateRanges != null) {
      $result.dateRanges.addAll(dateRanges);
    }
    if (baits != null) {
      $result.baits.addAll(baits);
    }
    if (catchIds != null) {
      $result.catchIds.addAll(catchIds);
    }
    if (anglerIds != null) {
      $result.anglerIds.addAll(anglerIds);
    }
    if (fishingSpotIds != null) {
      $result.fishingSpotIds.addAll(fishingSpotIds);
    }
    if (bodyOfWaterIds != null) {
      $result.bodyOfWaterIds.addAll(bodyOfWaterIds);
    }
    if (methodIds != null) {
      $result.methodIds.addAll(methodIds);
    }
    if (speciesIds != null) {
      $result.speciesIds.addAll(speciesIds);
    }
    if (waterClarityIds != null) {
      $result.waterClarityIds.addAll(waterClarityIds);
    }
    if (periods != null) {
      $result.periods.addAll(periods);
    }
    if (seasons != null) {
      $result.seasons.addAll(seasons);
    }
    if (windDirections != null) {
      $result.windDirections.addAll(windDirections);
    }
    if (skyConditions != null) {
      $result.skyConditions.addAll(skyConditions);
    }
    if (moonPhases != null) {
      $result.moonPhases.addAll(moonPhases);
    }
    if (tideTypes != null) {
      $result.tideTypes.addAll(tideTypes);
    }
    if (waterDepthFilter != null) {
      $result.waterDepthFilter = waterDepthFilter;
    }
    if (waterTemperatureFilter != null) {
      $result.waterTemperatureFilter = waterTemperatureFilter;
    }
    if (lengthFilter != null) {
      $result.lengthFilter = lengthFilter;
    }
    if (weightFilter != null) {
      $result.weightFilter = weightFilter;
    }
    if (quantityFilter != null) {
      $result.quantityFilter = quantityFilter;
    }
    if (airTemperatureFilter != null) {
      $result.airTemperatureFilter = airTemperatureFilter;
    }
    if (airPressureFilter != null) {
      $result.airPressureFilter = airPressureFilter;
    }
    if (airHumidityFilter != null) {
      $result.airHumidityFilter = airHumidityFilter;
    }
    if (airVisibilityFilter != null) {
      $result.airVisibilityFilter = airVisibilityFilter;
    }
    if (windSpeedFilter != null) {
      $result.windSpeedFilter = windSpeedFilter;
    }
    if (hour != null) {
      $result.hour = hour;
    }
    if (month != null) {
      $result.month = month;
    }
    if (includeAnglers != null) {
      $result.includeAnglers = includeAnglers;
    }
    if (includeBaits != null) {
      $result.includeBaits = includeBaits;
    }
    if (includeBodiesOfWater != null) {
      $result.includeBodiesOfWater = includeBodiesOfWater;
    }
    if (includeMethods != null) {
      $result.includeMethods = includeMethods;
    }
    if (includeFishingSpots != null) {
      $result.includeFishingSpots = includeFishingSpots;
    }
    if (includeMoonPhases != null) {
      $result.includeMoonPhases = includeMoonPhases;
    }
    if (includeSeasons != null) {
      $result.includeSeasons = includeSeasons;
    }
    if (includeSpecies != null) {
      $result.includeSpecies = includeSpecies;
    }
    if (includeTideTypes != null) {
      $result.includeTideTypes = includeTideTypes;
    }
    if (includePeriods != null) {
      $result.includePeriods = includePeriods;
    }
    if (includeWaterClarities != null) {
      $result.includeWaterClarities = includeWaterClarities;
    }
    if (allGear != null) {
      $result.allGear.addAll(allGear);
    }
    if (gearIds != null) {
      $result.gearIds.addAll(gearIds);
    }
    if (includeGear != null) {
      $result.includeGear = includeGear;
    }
    return $result;
  }
  CatchFilterOptions._() : super();
  factory CatchFilterOptions.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory CatchFilterOptions.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CatchFilterOptions',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..e<CatchFilterOptions_Order>(
        1, _omitFieldNames ? '' : 'order', $pb.PbFieldType.OE,
        defaultOrMaker: CatchFilterOptions_Order.unknown,
        valueOf: CatchFilterOptions_Order.valueOf,
        enumValues: CatchFilterOptions_Order.values)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'currentTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(3, _omitFieldNames ? '' : 'currentTimeZone')
    ..m<$core.String, Angler>(4, _omitFieldNames ? '' : 'allAnglers',
        entryClassName: 'CatchFilterOptions.AllAnglersEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Angler.create,
        valueDefaultOrMaker: Angler.getDefault,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.String, Bait>(5, _omitFieldNames ? '' : 'allBaits',
        entryClassName: 'CatchFilterOptions.AllBaitsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Bait.create,
        valueDefaultOrMaker: Bait.getDefault,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.String, BodyOfWater>(6, _omitFieldNames ? '' : 'allBodiesOfWater',
        entryClassName: 'CatchFilterOptions.AllBodiesOfWaterEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: BodyOfWater.create,
        valueDefaultOrMaker: BodyOfWater.getDefault,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.String, Catch>(7, _omitFieldNames ? '' : 'allCatches',
        entryClassName: 'CatchFilterOptions.AllCatchesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Catch.create,
        valueDefaultOrMaker: Catch.getDefault,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.String, FishingSpot>(8, _omitFieldNames ? '' : 'allFishingSpots',
        entryClassName: 'CatchFilterOptions.AllFishingSpotsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: FishingSpot.create,
        valueDefaultOrMaker: FishingSpot.getDefault,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.String, Method>(9, _omitFieldNames ? '' : 'allMethods',
        entryClassName: 'CatchFilterOptions.AllMethodsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Method.create,
        valueDefaultOrMaker: Method.getDefault,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.String, Species>(10, _omitFieldNames ? '' : 'allSpecies',
        entryClassName: 'CatchFilterOptions.AllSpeciesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Species.create,
        valueDefaultOrMaker: Species.getDefault,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.String, WaterClarity>(
        11, _omitFieldNames ? '' : 'allWaterClarities',
        entryClassName: 'CatchFilterOptions.AllWaterClaritiesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: WaterClarity.create,
        valueDefaultOrMaker: WaterClarity.getDefault,
        packageName: const $pb.PackageName('anglerslog'))
    ..aOB(12, _omitFieldNames ? '' : 'isCatchAndReleaseOnly')
    ..aOB(13, _omitFieldNames ? '' : 'isFavoritesOnly')
    ..pc<DateRange>(14, _omitFieldNames ? '' : 'dateRanges', $pb.PbFieldType.PM,
        subBuilder: DateRange.create)
    ..pc<BaitAttachment>(15, _omitFieldNames ? '' : 'baits', $pb.PbFieldType.PM,
        subBuilder: BaitAttachment.create)
    ..pc<Id>(16, _omitFieldNames ? '' : 'catchIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..pc<Id>(17, _omitFieldNames ? '' : 'anglerIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..pc<Id>(18, _omitFieldNames ? '' : 'fishingSpotIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..pc<Id>(19, _omitFieldNames ? '' : 'bodyOfWaterIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..pc<Id>(20, _omitFieldNames ? '' : 'methodIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..pc<Id>(21, _omitFieldNames ? '' : 'speciesIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..pc<Id>(22, _omitFieldNames ? '' : 'waterClarityIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..pc<Period>(23, _omitFieldNames ? '' : 'periods', $pb.PbFieldType.KE,
        valueOf: Period.valueOf,
        enumValues: Period.values,
        defaultEnumValue: Period.period_all)
    ..pc<Season>(24, _omitFieldNames ? '' : 'seasons', $pb.PbFieldType.KE,
        valueOf: Season.valueOf,
        enumValues: Season.values,
        defaultEnumValue: Season.season_all)
    ..pc<Direction>(
        25, _omitFieldNames ? '' : 'windDirections', $pb.PbFieldType.KE,
        valueOf: Direction.valueOf,
        enumValues: Direction.values,
        defaultEnumValue: Direction.direction_all)
    ..pc<SkyCondition>(
        26, _omitFieldNames ? '' : 'skyConditions', $pb.PbFieldType.KE,
        valueOf: SkyCondition.valueOf,
        enumValues: SkyCondition.values,
        defaultEnumValue: SkyCondition.sky_condition_all)
    ..pc<MoonPhase>(27, _omitFieldNames ? '' : 'moonPhases', $pb.PbFieldType.KE,
        valueOf: MoonPhase.valueOf,
        enumValues: MoonPhase.values,
        defaultEnumValue: MoonPhase.moon_phase_all)
    ..pc<TideType>(28, _omitFieldNames ? '' : 'tideTypes', $pb.PbFieldType.KE,
        valueOf: TideType.valueOf,
        enumValues: TideType.values,
        defaultEnumValue: TideType.tide_type_all)
    ..aOM<NumberFilter>(29, _omitFieldNames ? '' : 'waterDepthFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(30, _omitFieldNames ? '' : 'waterTemperatureFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(31, _omitFieldNames ? '' : 'lengthFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(32, _omitFieldNames ? '' : 'weightFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(33, _omitFieldNames ? '' : 'quantityFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(34, _omitFieldNames ? '' : 'airTemperatureFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(35, _omitFieldNames ? '' : 'airPressureFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(36, _omitFieldNames ? '' : 'airHumidityFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(37, _omitFieldNames ? '' : 'airVisibilityFilter',
        subBuilder: NumberFilter.create)
    ..aOM<NumberFilter>(38, _omitFieldNames ? '' : 'windSpeedFilter',
        subBuilder: NumberFilter.create)
    ..a<$core.int>(39, _omitFieldNames ? '' : 'hour', $pb.PbFieldType.O3)
    ..a<$core.int>(40, _omitFieldNames ? '' : 'month', $pb.PbFieldType.O3)
    ..aOB(41, _omitFieldNames ? '' : 'includeAnglers')
    ..aOB(42, _omitFieldNames ? '' : 'includeBaits')
    ..aOB(43, _omitFieldNames ? '' : 'includeBodiesOfWater')
    ..aOB(44, _omitFieldNames ? '' : 'includeMethods')
    ..aOB(45, _omitFieldNames ? '' : 'includeFishingSpots')
    ..aOB(46, _omitFieldNames ? '' : 'includeMoonPhases')
    ..aOB(47, _omitFieldNames ? '' : 'includeSeasons')
    ..aOB(48, _omitFieldNames ? '' : 'includeSpecies')
    ..aOB(49, _omitFieldNames ? '' : 'includeTideTypes')
    ..aOB(50, _omitFieldNames ? '' : 'includePeriods')
    ..aOB(51, _omitFieldNames ? '' : 'includeWaterClarities')
    ..m<$core.String, Gear>(52, _omitFieldNames ? '' : 'allGear',
        entryClassName: 'CatchFilterOptions.AllGearEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Gear.create,
        valueDefaultOrMaker: Gear.getDefault,
        packageName: const $pb.PackageName('anglerslog'))
    ..pc<Id>(53, _omitFieldNames ? '' : 'gearIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..aOB(54, _omitFieldNames ? '' : 'includeGear')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  CatchFilterOptions clone() => CatchFilterOptions()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  CatchFilterOptions copyWith(void Function(CatchFilterOptions) updates) =>
      super.copyWith((message) => updates(message as CatchFilterOptions))
          as CatchFilterOptions;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CatchFilterOptions create() => CatchFilterOptions._();
  CatchFilterOptions createEmptyInstance() => create();
  static $pb.PbList<CatchFilterOptions> createRepeated() =>
      $pb.PbList<CatchFilterOptions>();
  @$core.pragma('dart2js:noInline')
  static CatchFilterOptions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CatchFilterOptions>(create);
  static CatchFilterOptions? _defaultInstance;

  @$pb.TagNumber(1)
  CatchFilterOptions_Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(CatchFilterOptions_Order v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get currentTimestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set currentTimestamp($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasCurrentTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearCurrentTimestamp() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get currentTimeZone => $_getSZ(2);
  @$pb.TagNumber(3)
  set currentTimeZone($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasCurrentTimeZone() => $_has(2);
  @$pb.TagNumber(3)
  void clearCurrentTimeZone() => clearField(3);

  /// Entities that need to be copied since BuildContext (i.e. managers)
  /// can't be accessed in Isolates. Use maps in favor of lists for
  /// efficiency.
  @$pb.TagNumber(4)
  $core.Map<$core.String, Angler> get allAnglers => $_getMap(3);

  @$pb.TagNumber(5)
  $core.Map<$core.String, Bait> get allBaits => $_getMap(4);

  @$pb.TagNumber(6)
  $core.Map<$core.String, BodyOfWater> get allBodiesOfWater => $_getMap(5);

  @$pb.TagNumber(7)
  $core.Map<$core.String, Catch> get allCatches => $_getMap(6);

  @$pb.TagNumber(8)
  $core.Map<$core.String, FishingSpot> get allFishingSpots => $_getMap(7);

  @$pb.TagNumber(9)
  $core.Map<$core.String, Method> get allMethods => $_getMap(8);

  @$pb.TagNumber(10)
  $core.Map<$core.String, Species> get allSpecies => $_getMap(9);

  @$pb.TagNumber(11)
  $core.Map<$core.String, WaterClarity> get allWaterClarities => $_getMap(10);

  /// All available filters.
  @$pb.TagNumber(12)
  $core.bool get isCatchAndReleaseOnly => $_getBF(11);
  @$pb.TagNumber(12)
  set isCatchAndReleaseOnly($core.bool v) {
    $_setBool(11, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasIsCatchAndReleaseOnly() => $_has(11);
  @$pb.TagNumber(12)
  void clearIsCatchAndReleaseOnly() => clearField(12);

  @$pb.TagNumber(13)
  $core.bool get isFavoritesOnly => $_getBF(12);
  @$pb.TagNumber(13)
  set isFavoritesOnly($core.bool v) {
    $_setBool(12, v);
  }

  @$pb.TagNumber(13)
  $core.bool hasIsFavoritesOnly() => $_has(12);
  @$pb.TagNumber(13)
  void clearIsFavoritesOnly() => clearField(13);

  @$pb.TagNumber(14)
  $core.List<DateRange> get dateRanges => $_getList(13);

  @$pb.TagNumber(15)
  $core.List<BaitAttachment> get baits => $_getList(14);

  @$pb.TagNumber(16)
  $core.List<Id> get catchIds => $_getList(15);

  @$pb.TagNumber(17)
  $core.List<Id> get anglerIds => $_getList(16);

  @$pb.TagNumber(18)
  $core.List<Id> get fishingSpotIds => $_getList(17);

  @$pb.TagNumber(19)
  $core.List<Id> get bodyOfWaterIds => $_getList(18);

  @$pb.TagNumber(20)
  $core.List<Id> get methodIds => $_getList(19);

  @$pb.TagNumber(21)
  $core.List<Id> get speciesIds => $_getList(20);

  @$pb.TagNumber(22)
  $core.List<Id> get waterClarityIds => $_getList(21);

  @$pb.TagNumber(23)
  $core.List<Period> get periods => $_getList(22);

  @$pb.TagNumber(24)
  $core.List<Season> get seasons => $_getList(23);

  @$pb.TagNumber(25)
  $core.List<Direction> get windDirections => $_getList(24);

  @$pb.TagNumber(26)
  $core.List<SkyCondition> get skyConditions => $_getList(25);

  @$pb.TagNumber(27)
  $core.List<MoonPhase> get moonPhases => $_getList(26);

  @$pb.TagNumber(28)
  $core.List<TideType> get tideTypes => $_getList(27);

  @$pb.TagNumber(29)
  NumberFilter get waterDepthFilter => $_getN(28);
  @$pb.TagNumber(29)
  set waterDepthFilter(NumberFilter v) {
    setField(29, v);
  }

  @$pb.TagNumber(29)
  $core.bool hasWaterDepthFilter() => $_has(28);
  @$pb.TagNumber(29)
  void clearWaterDepthFilter() => clearField(29);
  @$pb.TagNumber(29)
  NumberFilter ensureWaterDepthFilter() => $_ensure(28);

  @$pb.TagNumber(30)
  NumberFilter get waterTemperatureFilter => $_getN(29);
  @$pb.TagNumber(30)
  set waterTemperatureFilter(NumberFilter v) {
    setField(30, v);
  }

  @$pb.TagNumber(30)
  $core.bool hasWaterTemperatureFilter() => $_has(29);
  @$pb.TagNumber(30)
  void clearWaterTemperatureFilter() => clearField(30);
  @$pb.TagNumber(30)
  NumberFilter ensureWaterTemperatureFilter() => $_ensure(29);

  @$pb.TagNumber(31)
  NumberFilter get lengthFilter => $_getN(30);
  @$pb.TagNumber(31)
  set lengthFilter(NumberFilter v) {
    setField(31, v);
  }

  @$pb.TagNumber(31)
  $core.bool hasLengthFilter() => $_has(30);
  @$pb.TagNumber(31)
  void clearLengthFilter() => clearField(31);
  @$pb.TagNumber(31)
  NumberFilter ensureLengthFilter() => $_ensure(30);

  @$pb.TagNumber(32)
  NumberFilter get weightFilter => $_getN(31);
  @$pb.TagNumber(32)
  set weightFilter(NumberFilter v) {
    setField(32, v);
  }

  @$pb.TagNumber(32)
  $core.bool hasWeightFilter() => $_has(31);
  @$pb.TagNumber(32)
  void clearWeightFilter() => clearField(32);
  @$pb.TagNumber(32)
  NumberFilter ensureWeightFilter() => $_ensure(31);

  @$pb.TagNumber(33)
  NumberFilter get quantityFilter => $_getN(32);
  @$pb.TagNumber(33)
  set quantityFilter(NumberFilter v) {
    setField(33, v);
  }

  @$pb.TagNumber(33)
  $core.bool hasQuantityFilter() => $_has(32);
  @$pb.TagNumber(33)
  void clearQuantityFilter() => clearField(33);
  @$pb.TagNumber(33)
  NumberFilter ensureQuantityFilter() => $_ensure(32);

  @$pb.TagNumber(34)
  NumberFilter get airTemperatureFilter => $_getN(33);
  @$pb.TagNumber(34)
  set airTemperatureFilter(NumberFilter v) {
    setField(34, v);
  }

  @$pb.TagNumber(34)
  $core.bool hasAirTemperatureFilter() => $_has(33);
  @$pb.TagNumber(34)
  void clearAirTemperatureFilter() => clearField(34);
  @$pb.TagNumber(34)
  NumberFilter ensureAirTemperatureFilter() => $_ensure(33);

  @$pb.TagNumber(35)
  NumberFilter get airPressureFilter => $_getN(34);
  @$pb.TagNumber(35)
  set airPressureFilter(NumberFilter v) {
    setField(35, v);
  }

  @$pb.TagNumber(35)
  $core.bool hasAirPressureFilter() => $_has(34);
  @$pb.TagNumber(35)
  void clearAirPressureFilter() => clearField(35);
  @$pb.TagNumber(35)
  NumberFilter ensureAirPressureFilter() => $_ensure(34);

  @$pb.TagNumber(36)
  NumberFilter get airHumidityFilter => $_getN(35);
  @$pb.TagNumber(36)
  set airHumidityFilter(NumberFilter v) {
    setField(36, v);
  }

  @$pb.TagNumber(36)
  $core.bool hasAirHumidityFilter() => $_has(35);
  @$pb.TagNumber(36)
  void clearAirHumidityFilter() => clearField(36);
  @$pb.TagNumber(36)
  NumberFilter ensureAirHumidityFilter() => $_ensure(35);

  @$pb.TagNumber(37)
  NumberFilter get airVisibilityFilter => $_getN(36);
  @$pb.TagNumber(37)
  set airVisibilityFilter(NumberFilter v) {
    setField(37, v);
  }

  @$pb.TagNumber(37)
  $core.bool hasAirVisibilityFilter() => $_has(36);
  @$pb.TagNumber(37)
  void clearAirVisibilityFilter() => clearField(37);
  @$pb.TagNumber(37)
  NumberFilter ensureAirVisibilityFilter() => $_ensure(36);

  @$pb.TagNumber(38)
  NumberFilter get windSpeedFilter => $_getN(37);
  @$pb.TagNumber(38)
  set windSpeedFilter(NumberFilter v) {
    setField(38, v);
  }

  @$pb.TagNumber(38)
  $core.bool hasWindSpeedFilter() => $_has(37);
  @$pb.TagNumber(38)
  void clearWindSpeedFilter() => clearField(38);
  @$pb.TagNumber(38)
  NumberFilter ensureWindSpeedFilter() => $_ensure(37);

  @$pb.TagNumber(39)
  $core.int get hour => $_getIZ(38);
  @$pb.TagNumber(39)
  set hour($core.int v) {
    $_setSignedInt32(38, v);
  }

  @$pb.TagNumber(39)
  $core.bool hasHour() => $_has(38);
  @$pb.TagNumber(39)
  void clearHour() => clearField(39);

  @$pb.TagNumber(40)
  $core.int get month => $_getIZ(39);
  @$pb.TagNumber(40)
  set month($core.int v) {
    $_setSignedInt32(39, v);
  }

  @$pb.TagNumber(40)
  $core.bool hasMonth() => $_has(39);
  @$pb.TagNumber(40)
  void clearMonth() => clearField(40);

  /// Whether or not each entity is included in a report.
  /// These should be based on user preferences.
  @$pb.TagNumber(41)
  $core.bool get includeAnglers => $_getBF(40);
  @$pb.TagNumber(41)
  set includeAnglers($core.bool v) {
    $_setBool(40, v);
  }

  @$pb.TagNumber(41)
  $core.bool hasIncludeAnglers() => $_has(40);
  @$pb.TagNumber(41)
  void clearIncludeAnglers() => clearField(41);

  @$pb.TagNumber(42)
  $core.bool get includeBaits => $_getBF(41);
  @$pb.TagNumber(42)
  set includeBaits($core.bool v) {
    $_setBool(41, v);
  }

  @$pb.TagNumber(42)
  $core.bool hasIncludeBaits() => $_has(41);
  @$pb.TagNumber(42)
  void clearIncludeBaits() => clearField(42);

  @$pb.TagNumber(43)
  $core.bool get includeBodiesOfWater => $_getBF(42);
  @$pb.TagNumber(43)
  set includeBodiesOfWater($core.bool v) {
    $_setBool(42, v);
  }

  @$pb.TagNumber(43)
  $core.bool hasIncludeBodiesOfWater() => $_has(42);
  @$pb.TagNumber(43)
  void clearIncludeBodiesOfWater() => clearField(43);

  @$pb.TagNumber(44)
  $core.bool get includeMethods => $_getBF(43);
  @$pb.TagNumber(44)
  set includeMethods($core.bool v) {
    $_setBool(43, v);
  }

  @$pb.TagNumber(44)
  $core.bool hasIncludeMethods() => $_has(43);
  @$pb.TagNumber(44)
  void clearIncludeMethods() => clearField(44);

  @$pb.TagNumber(45)
  $core.bool get includeFishingSpots => $_getBF(44);
  @$pb.TagNumber(45)
  set includeFishingSpots($core.bool v) {
    $_setBool(44, v);
  }

  @$pb.TagNumber(45)
  $core.bool hasIncludeFishingSpots() => $_has(44);
  @$pb.TagNumber(45)
  void clearIncludeFishingSpots() => clearField(45);

  @$pb.TagNumber(46)
  $core.bool get includeMoonPhases => $_getBF(45);
  @$pb.TagNumber(46)
  set includeMoonPhases($core.bool v) {
    $_setBool(45, v);
  }

  @$pb.TagNumber(46)
  $core.bool hasIncludeMoonPhases() => $_has(45);
  @$pb.TagNumber(46)
  void clearIncludeMoonPhases() => clearField(46);

  @$pb.TagNumber(47)
  $core.bool get includeSeasons => $_getBF(46);
  @$pb.TagNumber(47)
  set includeSeasons($core.bool v) {
    $_setBool(46, v);
  }

  @$pb.TagNumber(47)
  $core.bool hasIncludeSeasons() => $_has(46);
  @$pb.TagNumber(47)
  void clearIncludeSeasons() => clearField(47);

  @$pb.TagNumber(48)
  $core.bool get includeSpecies => $_getBF(47);
  @$pb.TagNumber(48)
  set includeSpecies($core.bool v) {
    $_setBool(47, v);
  }

  @$pb.TagNumber(48)
  $core.bool hasIncludeSpecies() => $_has(47);
  @$pb.TagNumber(48)
  void clearIncludeSpecies() => clearField(48);

  @$pb.TagNumber(49)
  $core.bool get includeTideTypes => $_getBF(48);
  @$pb.TagNumber(49)
  set includeTideTypes($core.bool v) {
    $_setBool(48, v);
  }

  @$pb.TagNumber(49)
  $core.bool hasIncludeTideTypes() => $_has(48);
  @$pb.TagNumber(49)
  void clearIncludeTideTypes() => clearField(49);

  @$pb.TagNumber(50)
  $core.bool get includePeriods => $_getBF(49);
  @$pb.TagNumber(50)
  set includePeriods($core.bool v) {
    $_setBool(49, v);
  }

  @$pb.TagNumber(50)
  $core.bool hasIncludePeriods() => $_has(49);
  @$pb.TagNumber(50)
  void clearIncludePeriods() => clearField(50);

  @$pb.TagNumber(51)
  $core.bool get includeWaterClarities => $_getBF(50);
  @$pb.TagNumber(51)
  set includeWaterClarities($core.bool v) {
    $_setBool(50, v);
  }

  @$pb.TagNumber(51)
  $core.bool hasIncludeWaterClarities() => $_has(50);
  @$pb.TagNumber(51)
  void clearIncludeWaterClarities() => clearField(51);

  @$pb.TagNumber(52)
  $core.Map<$core.String, Gear> get allGear => $_getMap(51);

  @$pb.TagNumber(53)
  $core.List<Id> get gearIds => $_getList(52);

  @$pb.TagNumber(54)
  $core.bool get includeGear => $_getBF(53);
  @$pb.TagNumber(54)
  set includeGear($core.bool v) {
    $_setBool(53, v);
  }

  @$pb.TagNumber(54)
  $core.bool hasIncludeGear() => $_has(53);
  @$pb.TagNumber(54)
  void clearIncludeGear() => clearField(54);
}

class CatchReport extends $pb.GeneratedMessage {
  factory CatchReport({
    $core.Iterable<CatchReportModel>? models,
    $fixnum.Int64? msSinceLastCatch,
    Catch? lastCatch,
    $core.bool? containsNow,
  }) {
    final $result = create();
    if (models != null) {
      $result.models.addAll(models);
    }
    if (msSinceLastCatch != null) {
      $result.msSinceLastCatch = msSinceLastCatch;
    }
    if (lastCatch != null) {
      $result.lastCatch = lastCatch;
    }
    if (containsNow != null) {
      $result.containsNow = containsNow;
    }
    return $result;
  }
  CatchReport._() : super();
  factory CatchReport.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory CatchReport.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CatchReport',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..pc<CatchReportModel>(
        1, _omitFieldNames ? '' : 'models', $pb.PbFieldType.PM,
        subBuilder: CatchReportModel.create)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'msSinceLastCatch', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<Catch>(3, _omitFieldNames ? '' : 'lastCatch',
        subBuilder: Catch.create)
    ..aOB(6, _omitFieldNames ? '' : 'containsNow')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  CatchReport clone() => CatchReport()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  CatchReport copyWith(void Function(CatchReport) updates) =>
      super.copyWith((message) => updates(message as CatchReport))
          as CatchReport;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CatchReport create() => CatchReport._();
  CatchReport createEmptyInstance() => create();
  static $pb.PbList<CatchReport> createRepeated() => $pb.PbList<CatchReport>();
  @$core.pragma('dart2js:noInline')
  static CatchReport getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CatchReport>(create);
  static CatchReport? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<CatchReportModel> get models => $_getList(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get msSinceLastCatch => $_getI64(1);
  @$pb.TagNumber(2)
  set msSinceLastCatch($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasMsSinceLastCatch() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsSinceLastCatch() => clearField(2);

  @$pb.TagNumber(3)
  Catch get lastCatch => $_getN(2);
  @$pb.TagNumber(3)
  set lastCatch(Catch v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasLastCatch() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastCatch() => clearField(3);
  @$pb.TagNumber(3)
  Catch ensureLastCatch() => $_ensure(2);

  /// True if one of the date ranges in the report includes the
  /// current time; false otherwise.
  @$pb.TagNumber(6)
  $core.bool get containsNow => $_getBF(3);
  @$pb.TagNumber(6)
  set containsNow($core.bool v) {
    $_setBool(3, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasContainsNow() => $_has(3);
  @$pb.TagNumber(6)
  void clearContainsNow() => clearField(6);
}

class CatchReportModel extends $pb.GeneratedMessage {
  factory CatchReportModel({
    DateRange? dateRange,
    $core.Iterable<Id>? catchIds,
    $core.Map<$core.int, $core.int>? perHour,
    $core.Map<$core.int, $core.int>? perMonth,
    $core.Map<$core.int, $core.int>? perMoonPhase,
    $core.Map<$core.int, $core.int>? perPeriod,
    $core.Map<$core.int, $core.int>? perSeason,
    $core.Map<$core.int, $core.int>? perTideType,
    $core.Map<$core.String, $core.int>? perAngler,
    $core.Map<$core.String, $core.int>? perBodyOfWater,
    $core.Map<$core.String, $core.int>? perMethod,
    $core.Map<$core.String, $core.int>? perFishingSpot,
    $core.Map<$core.String, $core.int>? perSpecies,
    $core.Map<$core.String, $core.int>? perWaterClarity,
    $core.Map<$core.String, $core.int>? perBait,
    $core.Map<$core.String, $core.int>? perGear,
  }) {
    final $result = create();
    if (dateRange != null) {
      $result.dateRange = dateRange;
    }
    if (catchIds != null) {
      $result.catchIds.addAll(catchIds);
    }
    if (perHour != null) {
      $result.perHour.addAll(perHour);
    }
    if (perMonth != null) {
      $result.perMonth.addAll(perMonth);
    }
    if (perMoonPhase != null) {
      $result.perMoonPhase.addAll(perMoonPhase);
    }
    if (perPeriod != null) {
      $result.perPeriod.addAll(perPeriod);
    }
    if (perSeason != null) {
      $result.perSeason.addAll(perSeason);
    }
    if (perTideType != null) {
      $result.perTideType.addAll(perTideType);
    }
    if (perAngler != null) {
      $result.perAngler.addAll(perAngler);
    }
    if (perBodyOfWater != null) {
      $result.perBodyOfWater.addAll(perBodyOfWater);
    }
    if (perMethod != null) {
      $result.perMethod.addAll(perMethod);
    }
    if (perFishingSpot != null) {
      $result.perFishingSpot.addAll(perFishingSpot);
    }
    if (perSpecies != null) {
      $result.perSpecies.addAll(perSpecies);
    }
    if (perWaterClarity != null) {
      $result.perWaterClarity.addAll(perWaterClarity);
    }
    if (perBait != null) {
      $result.perBait.addAll(perBait);
    }
    if (perGear != null) {
      $result.perGear.addAll(perGear);
    }
    return $result;
  }
  CatchReportModel._() : super();
  factory CatchReportModel.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory CatchReportModel.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CatchReportModel',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<DateRange>(1, _omitFieldNames ? '' : 'dateRange',
        subBuilder: DateRange.create)
    ..pc<Id>(2, _omitFieldNames ? '' : 'catchIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..m<$core.int, $core.int>(3, _omitFieldNames ? '' : 'perHour',
        entryClassName: 'CatchReportModel.PerHourEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.int, $core.int>(4, _omitFieldNames ? '' : 'perMonth',
        entryClassName: 'CatchReportModel.PerMonthEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.int, $core.int>(5, _omitFieldNames ? '' : 'perMoonPhase',
        entryClassName: 'CatchReportModel.PerMoonPhaseEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.int, $core.int>(6, _omitFieldNames ? '' : 'perPeriod',
        entryClassName: 'CatchReportModel.PerPeriodEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.int, $core.int>(7, _omitFieldNames ? '' : 'perSeason',
        entryClassName: 'CatchReportModel.PerSeasonEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.int, $core.int>(8, _omitFieldNames ? '' : 'perTideType',
        entryClassName: 'CatchReportModel.PerTideTypeEntry',
        keyFieldType: $pb.PbFieldType.O3,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.String, $core.int>(9, _omitFieldNames ? '' : 'perAngler',
        entryClassName: 'CatchReportModel.PerAnglerEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.String, $core.int>(10, _omitFieldNames ? '' : 'perBodyOfWater',
        entryClassName: 'CatchReportModel.PerBodyOfWaterEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.String, $core.int>(11, _omitFieldNames ? '' : 'perMethod',
        entryClassName: 'CatchReportModel.PerMethodEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.String, $core.int>(12, _omitFieldNames ? '' : 'perFishingSpot',
        entryClassName: 'CatchReportModel.PerFishingSpotEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.String, $core.int>(13, _omitFieldNames ? '' : 'perSpecies',
        entryClassName: 'CatchReportModel.PerSpeciesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.String, $core.int>(14, _omitFieldNames ? '' : 'perWaterClarity',
        entryClassName: 'CatchReportModel.PerWaterClarityEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.String, $core.int>(15, _omitFieldNames ? '' : 'perBait',
        entryClassName: 'CatchReportModel.PerBaitEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.String, $core.int>(16, _omitFieldNames ? '' : 'perGear',
        entryClassName: 'CatchReportModel.PerGearEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O3,
        packageName: const $pb.PackageName('anglerslog'))
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  CatchReportModel clone() => CatchReportModel()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  CatchReportModel copyWith(void Function(CatchReportModel) updates) =>
      super.copyWith((message) => updates(message as CatchReportModel))
          as CatchReportModel;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CatchReportModel create() => CatchReportModel._();
  CatchReportModel createEmptyInstance() => create();
  static $pb.PbList<CatchReportModel> createRepeated() =>
      $pb.PbList<CatchReportModel>();
  @$core.pragma('dart2js:noInline')
  static CatchReportModel getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CatchReportModel>(create);
  static CatchReportModel? _defaultInstance;

  @$pb.TagNumber(1)
  DateRange get dateRange => $_getN(0);
  @$pb.TagNumber(1)
  set dateRange(DateRange v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasDateRange() => $_has(0);
  @$pb.TagNumber(1)
  void clearDateRange() => clearField(1);
  @$pb.TagNumber(1)
  DateRange ensureDateRange() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<Id> get catchIds => $_getList(1);

  /// Hour of day (0-23), and month (1-12) to catch quantity maps.
  @$pb.TagNumber(3)
  $core.Map<$core.int, $core.int> get perHour => $_getMap(2);

  @$pb.TagNumber(4)
  $core.Map<$core.int, $core.int> get perMonth => $_getMap(3);

  /// Enum number to catch quantity maps.
  @$pb.TagNumber(5)
  $core.Map<$core.int, $core.int> get perMoonPhase => $_getMap(4);

  @$pb.TagNumber(6)
  $core.Map<$core.int, $core.int> get perPeriod => $_getMap(5);

  @$pb.TagNumber(7)
  $core.Map<$core.int, $core.int> get perSeason => $_getMap(6);

  @$pb.TagNumber(8)
  $core.Map<$core.int, $core.int> get perTideType => $_getMap(7);

  /// UUID string to catch quantity maps.
  @$pb.TagNumber(9)
  $core.Map<$core.String, $core.int> get perAngler => $_getMap(8);

  @$pb.TagNumber(10)
  $core.Map<$core.String, $core.int> get perBodyOfWater => $_getMap(9);

  @$pb.TagNumber(11)
  $core.Map<$core.String, $core.int> get perMethod => $_getMap(10);

  @$pb.TagNumber(12)
  $core.Map<$core.String, $core.int> get perFishingSpot => $_getMap(11);

  @$pb.TagNumber(13)
  $core.Map<$core.String, $core.int> get perSpecies => $_getMap(12);

  @$pb.TagNumber(14)
  $core.Map<$core.String, $core.int> get perWaterClarity => $_getMap(13);

  /// Baits need to work a little different because they are identified
  /// by BaitAttachment, which have a bait ID and variant ID, so the key
  /// in this map is "<bait ID>.<variant ID>"
  @$pb.TagNumber(15)
  $core.Map<$core.String, $core.int> get perBait => $_getMap(14);

  @$pb.TagNumber(16)
  $core.Map<$core.String, $core.int> get perGear => $_getMap(15);
}

/// A message that contains everything needed to filter trips and/or
/// generate reports on a separate dart Isolate.
class TripFilterOptions extends $pb.GeneratedMessage {
  factory TripFilterOptions({
    $fixnum.Int64? currentTimestamp,
    $core.String? currentTimeZone,
    $core.Map<$core.String, Catch>? allCatches,
    $core.Map<$core.String, Trip>? allTrips,
    MeasurementSystem? catchWeightSystem,
    MeasurementSystem? catchLengthSystem,
    DateRange? dateRange,
    $core.Iterable<Id>? tripIds,
  }) {
    final $result = create();
    if (currentTimestamp != null) {
      $result.currentTimestamp = currentTimestamp;
    }
    if (currentTimeZone != null) {
      $result.currentTimeZone = currentTimeZone;
    }
    if (allCatches != null) {
      $result.allCatches.addAll(allCatches);
    }
    if (allTrips != null) {
      $result.allTrips.addAll(allTrips);
    }
    if (catchWeightSystem != null) {
      $result.catchWeightSystem = catchWeightSystem;
    }
    if (catchLengthSystem != null) {
      $result.catchLengthSystem = catchLengthSystem;
    }
    if (dateRange != null) {
      $result.dateRange = dateRange;
    }
    if (tripIds != null) {
      $result.tripIds.addAll(tripIds);
    }
    return $result;
  }
  TripFilterOptions._() : super();
  factory TripFilterOptions.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory TripFilterOptions.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TripFilterOptions',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'currentTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'currentTimeZone')
    ..m<$core.String, Catch>(3, _omitFieldNames ? '' : 'allCatches',
        entryClassName: 'TripFilterOptions.AllCatchesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Catch.create,
        valueDefaultOrMaker: Catch.getDefault,
        packageName: const $pb.PackageName('anglerslog'))
    ..m<$core.String, Trip>(4, _omitFieldNames ? '' : 'allTrips',
        entryClassName: 'TripFilterOptions.AllTripsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: Trip.create,
        valueDefaultOrMaker: Trip.getDefault,
        packageName: const $pb.PackageName('anglerslog'))
    ..e<MeasurementSystem>(
        5, _omitFieldNames ? '' : 'catchWeightSystem', $pb.PbFieldType.OE,
        defaultOrMaker: MeasurementSystem.imperial_whole,
        valueOf: MeasurementSystem.valueOf,
        enumValues: MeasurementSystem.values)
    ..e<MeasurementSystem>(
        6, _omitFieldNames ? '' : 'catchLengthSystem', $pb.PbFieldType.OE,
        defaultOrMaker: MeasurementSystem.imperial_whole,
        valueOf: MeasurementSystem.valueOf,
        enumValues: MeasurementSystem.values)
    ..aOM<DateRange>(7, _omitFieldNames ? '' : 'dateRange',
        subBuilder: DateRange.create)
    ..pc<Id>(8, _omitFieldNames ? '' : 'tripIds', $pb.PbFieldType.PM,
        subBuilder: Id.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  TripFilterOptions clone() => TripFilterOptions()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  TripFilterOptions copyWith(void Function(TripFilterOptions) updates) =>
      super.copyWith((message) => updates(message as TripFilterOptions))
          as TripFilterOptions;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TripFilterOptions create() => TripFilterOptions._();
  TripFilterOptions createEmptyInstance() => create();
  static $pb.PbList<TripFilterOptions> createRepeated() =>
      $pb.PbList<TripFilterOptions>();
  @$core.pragma('dart2js:noInline')
  static TripFilterOptions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TripFilterOptions>(create);
  static TripFilterOptions? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get currentTimestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set currentTimestamp($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasCurrentTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearCurrentTimestamp() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get currentTimeZone => $_getSZ(1);
  @$pb.TagNumber(2)
  set currentTimeZone($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasCurrentTimeZone() => $_has(1);
  @$pb.TagNumber(2)
  void clearCurrentTimeZone() => clearField(2);

  /// Copy data normally fetches using the current BuildContext, since
  /// BuildContext is not accessible in an Isolate.
  @$pb.TagNumber(3)
  $core.Map<$core.String, Catch> get allCatches => $_getMap(2);

  @$pb.TagNumber(4)
  $core.Map<$core.String, Trip> get allTrips => $_getMap(3);

  @$pb.TagNumber(5)
  MeasurementSystem get catchWeightSystem => $_getN(4);
  @$pb.TagNumber(5)
  set catchWeightSystem(MeasurementSystem v) {
    setField(5, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasCatchWeightSystem() => $_has(4);
  @$pb.TagNumber(5)
  void clearCatchWeightSystem() => clearField(5);

  @$pb.TagNumber(6)
  MeasurementSystem get catchLengthSystem => $_getN(5);
  @$pb.TagNumber(6)
  set catchLengthSystem(MeasurementSystem v) {
    setField(6, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasCatchLengthSystem() => $_has(5);
  @$pb.TagNumber(6)
  void clearCatchLengthSystem() => clearField(6);

  @$pb.TagNumber(7)
  DateRange get dateRange => $_getN(6);
  @$pb.TagNumber(7)
  set dateRange(DateRange v) {
    setField(7, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasDateRange() => $_has(6);
  @$pb.TagNumber(7)
  void clearDateRange() => clearField(7);
  @$pb.TagNumber(7)
  DateRange ensureDateRange() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.List<Id> get tripIds => $_getList(7);
}

class TripReport extends $pb.GeneratedMessage {
  factory TripReport({
    DateRange? dateRange,
    $core.Iterable<Trip>? trips,
    $fixnum.Int64? totalMs,
    Trip? longestTrip,
    Trip? lastTrip,
    $fixnum.Int64? msSinceLastTrip,
    $core.bool? containsNow,
    $core.double? averageCatchesPerTrip,
    $core.double? averageCatchesPerHour,
    $fixnum.Int64? averageMsBetweenCatches,
    $fixnum.Int64? averageTripMs,
    $fixnum.Int64? averageMsBetweenTrips,
    MultiMeasurement? averageWeightPerTrip,
    MultiMeasurement? mostWeightInSingleTrip,
    Trip? mostWeightTrip,
    MultiMeasurement? averageLengthPerTrip,
    MultiMeasurement? mostLengthInSingleTrip,
    Trip? mostLengthTrip,
  }) {
    final $result = create();
    if (dateRange != null) {
      $result.dateRange = dateRange;
    }
    if (trips != null) {
      $result.trips.addAll(trips);
    }
    if (totalMs != null) {
      $result.totalMs = totalMs;
    }
    if (longestTrip != null) {
      $result.longestTrip = longestTrip;
    }
    if (lastTrip != null) {
      $result.lastTrip = lastTrip;
    }
    if (msSinceLastTrip != null) {
      $result.msSinceLastTrip = msSinceLastTrip;
    }
    if (containsNow != null) {
      $result.containsNow = containsNow;
    }
    if (averageCatchesPerTrip != null) {
      $result.averageCatchesPerTrip = averageCatchesPerTrip;
    }
    if (averageCatchesPerHour != null) {
      $result.averageCatchesPerHour = averageCatchesPerHour;
    }
    if (averageMsBetweenCatches != null) {
      $result.averageMsBetweenCatches = averageMsBetweenCatches;
    }
    if (averageTripMs != null) {
      $result.averageTripMs = averageTripMs;
    }
    if (averageMsBetweenTrips != null) {
      $result.averageMsBetweenTrips = averageMsBetweenTrips;
    }
    if (averageWeightPerTrip != null) {
      $result.averageWeightPerTrip = averageWeightPerTrip;
    }
    if (mostWeightInSingleTrip != null) {
      $result.mostWeightInSingleTrip = mostWeightInSingleTrip;
    }
    if (mostWeightTrip != null) {
      $result.mostWeightTrip = mostWeightTrip;
    }
    if (averageLengthPerTrip != null) {
      $result.averageLengthPerTrip = averageLengthPerTrip;
    }
    if (mostLengthInSingleTrip != null) {
      $result.mostLengthInSingleTrip = mostLengthInSingleTrip;
    }
    if (mostLengthTrip != null) {
      $result.mostLengthTrip = mostLengthTrip;
    }
    return $result;
  }
  TripReport._() : super();
  factory TripReport.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory TripReport.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TripReport',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<DateRange>(1, _omitFieldNames ? '' : 'dateRange',
        subBuilder: DateRange.create)
    ..pc<Trip>(2, _omitFieldNames ? '' : 'trips', $pb.PbFieldType.PM,
        subBuilder: Trip.create)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'totalMs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<Trip>(4, _omitFieldNames ? '' : 'longestTrip',
        subBuilder: Trip.create)
    ..aOM<Trip>(5, _omitFieldNames ? '' : 'lastTrip', subBuilder: Trip.create)
    ..a<$fixnum.Int64>(
        6, _omitFieldNames ? '' : 'msSinceLastTrip', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(7, _omitFieldNames ? '' : 'containsNow', protoName: 'containsNow')
    ..a<$core.double>(
        8, _omitFieldNames ? '' : 'averageCatchesPerTrip', $pb.PbFieldType.OD)
    ..a<$core.double>(
        9, _omitFieldNames ? '' : 'averageCatchesPerHour', $pb.PbFieldType.OD)
    ..a<$fixnum.Int64>(10, _omitFieldNames ? '' : 'averageMsBetweenCatches',
        $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        11, _omitFieldNames ? '' : 'averageTripMs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        12, _omitFieldNames ? '' : 'averageMsBetweenTrips', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<MultiMeasurement>(13, _omitFieldNames ? '' : 'averageWeightPerTrip',
        subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(14, _omitFieldNames ? '' : 'mostWeightInSingleTrip',
        subBuilder: MultiMeasurement.create)
    ..aOM<Trip>(15, _omitFieldNames ? '' : 'mostWeightTrip',
        subBuilder: Trip.create)
    ..aOM<MultiMeasurement>(16, _omitFieldNames ? '' : 'averageLengthPerTrip',
        subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(17, _omitFieldNames ? '' : 'mostLengthInSingleTrip',
        subBuilder: MultiMeasurement.create)
    ..aOM<Trip>(18, _omitFieldNames ? '' : 'mostLengthTrip',
        subBuilder: Trip.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  TripReport clone() => TripReport()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  TripReport copyWith(void Function(TripReport) updates) =>
      super.copyWith((message) => updates(message as TripReport)) as TripReport;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TripReport create() => TripReport._();
  TripReport createEmptyInstance() => create();
  static $pb.PbList<TripReport> createRepeated() => $pb.PbList<TripReport>();
  @$core.pragma('dart2js:noInline')
  static TripReport getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TripReport>(create);
  static TripReport? _defaultInstance;

  @$pb.TagNumber(1)
  DateRange get dateRange => $_getN(0);
  @$pb.TagNumber(1)
  set dateRange(DateRange v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasDateRange() => $_has(0);
  @$pb.TagNumber(1)
  void clearDateRange() => clearField(1);
  @$pb.TagNumber(1)
  DateRange ensureDateRange() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<Trip> get trips => $_getList(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get totalMs => $_getI64(2);
  @$pb.TagNumber(3)
  set totalMs($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasTotalMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalMs() => clearField(3);

  @$pb.TagNumber(4)
  Trip get longestTrip => $_getN(3);
  @$pb.TagNumber(4)
  set longestTrip(Trip v) {
    setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasLongestTrip() => $_has(3);
  @$pb.TagNumber(4)
  void clearLongestTrip() => clearField(4);
  @$pb.TagNumber(4)
  Trip ensureLongestTrip() => $_ensure(3);

  @$pb.TagNumber(5)
  Trip get lastTrip => $_getN(4);
  @$pb.TagNumber(5)
  set lastTrip(Trip v) {
    setField(5, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasLastTrip() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastTrip() => clearField(5);
  @$pb.TagNumber(5)
  Trip ensureLastTrip() => $_ensure(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get msSinceLastTrip => $_getI64(5);
  @$pb.TagNumber(6)
  set msSinceLastTrip($fixnum.Int64 v) {
    $_setInt64(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasMsSinceLastTrip() => $_has(5);
  @$pb.TagNumber(6)
  void clearMsSinceLastTrip() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get containsNow => $_getBF(6);
  @$pb.TagNumber(7)
  set containsNow($core.bool v) {
    $_setBool(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasContainsNow() => $_has(6);
  @$pb.TagNumber(7)
  void clearContainsNow() => clearField(7);

  @$pb.TagNumber(8)
  $core.double get averageCatchesPerTrip => $_getN(7);
  @$pb.TagNumber(8)
  set averageCatchesPerTrip($core.double v) {
    $_setDouble(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasAverageCatchesPerTrip() => $_has(7);
  @$pb.TagNumber(8)
  void clearAverageCatchesPerTrip() => clearField(8);

  @$pb.TagNumber(9)
  $core.double get averageCatchesPerHour => $_getN(8);
  @$pb.TagNumber(9)
  set averageCatchesPerHour($core.double v) {
    $_setDouble(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasAverageCatchesPerHour() => $_has(8);
  @$pb.TagNumber(9)
  void clearAverageCatchesPerHour() => clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get averageMsBetweenCatches => $_getI64(9);
  @$pb.TagNumber(10)
  set averageMsBetweenCatches($fixnum.Int64 v) {
    $_setInt64(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasAverageMsBetweenCatches() => $_has(9);
  @$pb.TagNumber(10)
  void clearAverageMsBetweenCatches() => clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get averageTripMs => $_getI64(10);
  @$pb.TagNumber(11)
  set averageTripMs($fixnum.Int64 v) {
    $_setInt64(10, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasAverageTripMs() => $_has(10);
  @$pb.TagNumber(11)
  void clearAverageTripMs() => clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get averageMsBetweenTrips => $_getI64(11);
  @$pb.TagNumber(12)
  set averageMsBetweenTrips($fixnum.Int64 v) {
    $_setInt64(11, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasAverageMsBetweenTrips() => $_has(11);
  @$pb.TagNumber(12)
  void clearAverageMsBetweenTrips() => clearField(12);

  @$pb.TagNumber(13)
  MultiMeasurement get averageWeightPerTrip => $_getN(12);
  @$pb.TagNumber(13)
  set averageWeightPerTrip(MultiMeasurement v) {
    setField(13, v);
  }

  @$pb.TagNumber(13)
  $core.bool hasAverageWeightPerTrip() => $_has(12);
  @$pb.TagNumber(13)
  void clearAverageWeightPerTrip() => clearField(13);
  @$pb.TagNumber(13)
  MultiMeasurement ensureAverageWeightPerTrip() => $_ensure(12);

  @$pb.TagNumber(14)
  MultiMeasurement get mostWeightInSingleTrip => $_getN(13);
  @$pb.TagNumber(14)
  set mostWeightInSingleTrip(MultiMeasurement v) {
    setField(14, v);
  }

  @$pb.TagNumber(14)
  $core.bool hasMostWeightInSingleTrip() => $_has(13);
  @$pb.TagNumber(14)
  void clearMostWeightInSingleTrip() => clearField(14);
  @$pb.TagNumber(14)
  MultiMeasurement ensureMostWeightInSingleTrip() => $_ensure(13);

  @$pb.TagNumber(15)
  Trip get mostWeightTrip => $_getN(14);
  @$pb.TagNumber(15)
  set mostWeightTrip(Trip v) {
    setField(15, v);
  }

  @$pb.TagNumber(15)
  $core.bool hasMostWeightTrip() => $_has(14);
  @$pb.TagNumber(15)
  void clearMostWeightTrip() => clearField(15);
  @$pb.TagNumber(15)
  Trip ensureMostWeightTrip() => $_ensure(14);

  @$pb.TagNumber(16)
  MultiMeasurement get averageLengthPerTrip => $_getN(15);
  @$pb.TagNumber(16)
  set averageLengthPerTrip(MultiMeasurement v) {
    setField(16, v);
  }

  @$pb.TagNumber(16)
  $core.bool hasAverageLengthPerTrip() => $_has(15);
  @$pb.TagNumber(16)
  void clearAverageLengthPerTrip() => clearField(16);
  @$pb.TagNumber(16)
  MultiMeasurement ensureAverageLengthPerTrip() => $_ensure(15);

  @$pb.TagNumber(17)
  MultiMeasurement get mostLengthInSingleTrip => $_getN(16);
  @$pb.TagNumber(17)
  set mostLengthInSingleTrip(MultiMeasurement v) {
    setField(17, v);
  }

  @$pb.TagNumber(17)
  $core.bool hasMostLengthInSingleTrip() => $_has(16);
  @$pb.TagNumber(17)
  void clearMostLengthInSingleTrip() => clearField(17);
  @$pb.TagNumber(17)
  MultiMeasurement ensureMostLengthInSingleTrip() => $_ensure(16);

  @$pb.TagNumber(18)
  Trip get mostLengthTrip => $_getN(17);
  @$pb.TagNumber(18)
  set mostLengthTrip(Trip v) {
    setField(18, v);
  }

  @$pb.TagNumber(18)
  $core.bool hasMostLengthTrip() => $_has(17);
  @$pb.TagNumber(18)
  void clearMostLengthTrip() => clearField(18);
  @$pb.TagNumber(18)
  Trip ensureMostLengthTrip() => $_ensure(17);
}

class GpsTrailPoint extends $pb.GeneratedMessage {
  factory GpsTrailPoint({
    $fixnum.Int64? timestamp,
    $core.double? lat,
    $core.double? lng,
    $core.double? heading,
  }) {
    final $result = create();
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (lat != null) {
      $result.lat = lat;
    }
    if (lng != null) {
      $result.lng = lng;
    }
    if (heading != null) {
      $result.heading = heading;
    }
    return $result;
  }
  GpsTrailPoint._() : super();
  factory GpsTrailPoint.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GpsTrailPoint.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GpsTrailPoint',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'lat', $pb.PbFieldType.OD)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'lng', $pb.PbFieldType.OD)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'heading', $pb.PbFieldType.OD)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GpsTrailPoint clone() => GpsTrailPoint()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GpsTrailPoint copyWith(void Function(GpsTrailPoint) updates) =>
      super.copyWith((message) => updates(message as GpsTrailPoint))
          as GpsTrailPoint;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GpsTrailPoint create() => GpsTrailPoint._();
  GpsTrailPoint createEmptyInstance() => create();
  static $pb.PbList<GpsTrailPoint> createRepeated() =>
      $pb.PbList<GpsTrailPoint>();
  @$core.pragma('dart2js:noInline')
  static GpsTrailPoint getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GpsTrailPoint>(create);
  static GpsTrailPoint? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get timestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set timestamp($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get lat => $_getN(1);
  @$pb.TagNumber(2)
  set lat($core.double v) {
    $_setDouble(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasLat() => $_has(1);
  @$pb.TagNumber(2)
  void clearLat() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get lng => $_getN(2);
  @$pb.TagNumber(3)
  set lng($core.double v) {
    $_setDouble(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasLng() => $_has(2);
  @$pb.TagNumber(3)
  void clearLng() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get heading => $_getN(3);
  @$pb.TagNumber(4)
  set heading($core.double v) {
    $_setDouble(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasHeading() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeading() => clearField(4);
}

class GpsTrail extends $pb.GeneratedMessage {
  factory GpsTrail({
    Id? id,
    $fixnum.Int64? startTimestamp,
    $fixnum.Int64? endTimestamp,
    $core.String? timeZone,
    $core.Iterable<GpsTrailPoint>? points,
    Id? bodyOfWaterId,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (startTimestamp != null) {
      $result.startTimestamp = startTimestamp;
    }
    if (endTimestamp != null) {
      $result.endTimestamp = endTimestamp;
    }
    if (timeZone != null) {
      $result.timeZone = timeZone;
    }
    if (points != null) {
      $result.points.addAll(points);
    }
    if (bodyOfWaterId != null) {
      $result.bodyOfWaterId = bodyOfWaterId;
    }
    return $result;
  }
  GpsTrail._() : super();
  factory GpsTrail.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GpsTrail.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GpsTrail',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'id', subBuilder: Id.create)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'startTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'endTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, _omitFieldNames ? '' : 'timeZone')
    ..pc<GpsTrailPoint>(5, _omitFieldNames ? '' : 'points', $pb.PbFieldType.PM,
        subBuilder: GpsTrailPoint.create)
    ..aOM<Id>(6, _omitFieldNames ? '' : 'bodyOfWaterId', subBuilder: Id.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GpsTrail clone() => GpsTrail()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GpsTrail copyWith(void Function(GpsTrail) updates) =>
      super.copyWith((message) => updates(message as GpsTrail)) as GpsTrail;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GpsTrail create() => GpsTrail._();
  GpsTrail createEmptyInstance() => create();
  static $pb.PbList<GpsTrail> createRepeated() => $pb.PbList<GpsTrail>();
  @$core.pragma('dart2js:noInline')
  static GpsTrail getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GpsTrail>(create);
  static GpsTrail? _defaultInstance;

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
  $fixnum.Int64 get startTimestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set startTimestamp($fixnum.Int64 v) {
    $_setInt64(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasStartTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTimestamp() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get endTimestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set endTimestamp($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasEndTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndTimestamp() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get timeZone => $_getSZ(3);
  @$pb.TagNumber(4)
  set timeZone($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasTimeZone() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimeZone() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<GpsTrailPoint> get points => $_getList(4);

  @$pb.TagNumber(6)
  Id get bodyOfWaterId => $_getN(5);
  @$pb.TagNumber(6)
  set bodyOfWaterId(Id v) {
    setField(6, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasBodyOfWaterId() => $_has(5);
  @$pb.TagNumber(6)
  void clearBodyOfWaterId() => clearField(6);
  @$pb.TagNumber(6)
  Id ensureBodyOfWaterId() => $_ensure(5);
}

class Gear extends $pb.GeneratedMessage {
  factory Gear({
    Id? id,
    $core.String? name,
    $core.String? imageName,
    $core.String? rodMakeModel,
    $core.String? rodSerialNumber,
    MultiMeasurement? rodLength,
    RodAction? rodAction,
    RodPower? rodPower,
    $core.String? reelMakeModel,
    $core.String? reelSerialNumber,
    $core.String? reelSize,
    $core.String? lineMakeModel,
    MultiMeasurement? lineRating,
    $core.String? lineColor,
    MultiMeasurement? leaderLength,
    MultiMeasurement? leaderRating,
    MultiMeasurement? tippetLength,
    MultiMeasurement? tippetRating,
    $core.String? hookMakeModel,
    MultiMeasurement? hookSize,
    $core.Iterable<CustomEntityValue>? customEntityValues,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (imageName != null) {
      $result.imageName = imageName;
    }
    if (rodMakeModel != null) {
      $result.rodMakeModel = rodMakeModel;
    }
    if (rodSerialNumber != null) {
      $result.rodSerialNumber = rodSerialNumber;
    }
    if (rodLength != null) {
      $result.rodLength = rodLength;
    }
    if (rodAction != null) {
      $result.rodAction = rodAction;
    }
    if (rodPower != null) {
      $result.rodPower = rodPower;
    }
    if (reelMakeModel != null) {
      $result.reelMakeModel = reelMakeModel;
    }
    if (reelSerialNumber != null) {
      $result.reelSerialNumber = reelSerialNumber;
    }
    if (reelSize != null) {
      $result.reelSize = reelSize;
    }
    if (lineMakeModel != null) {
      $result.lineMakeModel = lineMakeModel;
    }
    if (lineRating != null) {
      $result.lineRating = lineRating;
    }
    if (lineColor != null) {
      $result.lineColor = lineColor;
    }
    if (leaderLength != null) {
      $result.leaderLength = leaderLength;
    }
    if (leaderRating != null) {
      $result.leaderRating = leaderRating;
    }
    if (tippetLength != null) {
      $result.tippetLength = tippetLength;
    }
    if (tippetRating != null) {
      $result.tippetRating = tippetRating;
    }
    if (hookMakeModel != null) {
      $result.hookMakeModel = hookMakeModel;
    }
    if (hookSize != null) {
      $result.hookSize = hookSize;
    }
    if (customEntityValues != null) {
      $result.customEntityValues.addAll(customEntityValues);
    }
    return $result;
  }
  Gear._() : super();
  factory Gear.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Gear.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Gear',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anglerslog'),
      createEmptyInstance: create)
    ..aOM<Id>(1, _omitFieldNames ? '' : 'id', subBuilder: Id.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'imageName')
    ..aOS(4, _omitFieldNames ? '' : 'rodMakeModel')
    ..aOS(5, _omitFieldNames ? '' : 'rodSerialNumber')
    ..aOM<MultiMeasurement>(6, _omitFieldNames ? '' : 'rodLength',
        subBuilder: MultiMeasurement.create)
    ..e<RodAction>(7, _omitFieldNames ? '' : 'rodAction', $pb.PbFieldType.OE,
        defaultOrMaker: RodAction.rod_action_all,
        valueOf: RodAction.valueOf,
        enumValues: RodAction.values)
    ..e<RodPower>(8, _omitFieldNames ? '' : 'rodPower', $pb.PbFieldType.OE,
        defaultOrMaker: RodPower.rod_power_all,
        valueOf: RodPower.valueOf,
        enumValues: RodPower.values)
    ..aOS(9, _omitFieldNames ? '' : 'reelMakeModel')
    ..aOS(10, _omitFieldNames ? '' : 'reelSerialNumber')
    ..aOS(11, _omitFieldNames ? '' : 'reelSize')
    ..aOS(12, _omitFieldNames ? '' : 'lineMakeModel')
    ..aOM<MultiMeasurement>(13, _omitFieldNames ? '' : 'lineRating',
        subBuilder: MultiMeasurement.create)
    ..aOS(14, _omitFieldNames ? '' : 'lineColor')
    ..aOM<MultiMeasurement>(15, _omitFieldNames ? '' : 'leaderLength',
        subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(16, _omitFieldNames ? '' : 'leaderRating',
        subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(17, _omitFieldNames ? '' : 'tippetLength',
        subBuilder: MultiMeasurement.create)
    ..aOM<MultiMeasurement>(18, _omitFieldNames ? '' : 'tippetRating',
        subBuilder: MultiMeasurement.create)
    ..aOS(19, _omitFieldNames ? '' : 'hookMakeModel')
    ..aOM<MultiMeasurement>(20, _omitFieldNames ? '' : 'hookSize',
        subBuilder: MultiMeasurement.create)
    ..pc<CustomEntityValue>(
        21, _omitFieldNames ? '' : 'customEntityValues', $pb.PbFieldType.PM,
        subBuilder: CustomEntityValue.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Gear clone() => Gear()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Gear copyWith(void Function(Gear) updates) =>
      super.copyWith((message) => updates(message as Gear)) as Gear;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Gear create() => Gear._();
  Gear createEmptyInstance() => create();
  static $pb.PbList<Gear> createRepeated() => $pb.PbList<Gear>();
  @$core.pragma('dart2js:noInline')
  static Gear getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Gear>(create);
  static Gear? _defaultInstance;

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
  $core.String get imageName => $_getSZ(2);
  @$pb.TagNumber(3)
  set imageName($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasImageName() => $_has(2);
  @$pb.TagNumber(3)
  void clearImageName() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get rodMakeModel => $_getSZ(3);
  @$pb.TagNumber(4)
  set rodMakeModel($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasRodMakeModel() => $_has(3);
  @$pb.TagNumber(4)
  void clearRodMakeModel() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get rodSerialNumber => $_getSZ(4);
  @$pb.TagNumber(5)
  set rodSerialNumber($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasRodSerialNumber() => $_has(4);
  @$pb.TagNumber(5)
  void clearRodSerialNumber() => clearField(5);

  @$pb.TagNumber(6)
  MultiMeasurement get rodLength => $_getN(5);
  @$pb.TagNumber(6)
  set rodLength(MultiMeasurement v) {
    setField(6, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasRodLength() => $_has(5);
  @$pb.TagNumber(6)
  void clearRodLength() => clearField(6);
  @$pb.TagNumber(6)
  MultiMeasurement ensureRodLength() => $_ensure(5);

  @$pb.TagNumber(7)
  RodAction get rodAction => $_getN(6);
  @$pb.TagNumber(7)
  set rodAction(RodAction v) {
    setField(7, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasRodAction() => $_has(6);
  @$pb.TagNumber(7)
  void clearRodAction() => clearField(7);

  @$pb.TagNumber(8)
  RodPower get rodPower => $_getN(7);
  @$pb.TagNumber(8)
  set rodPower(RodPower v) {
    setField(8, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasRodPower() => $_has(7);
  @$pb.TagNumber(8)
  void clearRodPower() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get reelMakeModel => $_getSZ(8);
  @$pb.TagNumber(9)
  set reelMakeModel($core.String v) {
    $_setString(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasReelMakeModel() => $_has(8);
  @$pb.TagNumber(9)
  void clearReelMakeModel() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get reelSerialNumber => $_getSZ(9);
  @$pb.TagNumber(10)
  set reelSerialNumber($core.String v) {
    $_setString(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasReelSerialNumber() => $_has(9);
  @$pb.TagNumber(10)
  void clearReelSerialNumber() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get reelSize => $_getSZ(10);
  @$pb.TagNumber(11)
  set reelSize($core.String v) {
    $_setString(10, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasReelSize() => $_has(10);
  @$pb.TagNumber(11)
  void clearReelSize() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get lineMakeModel => $_getSZ(11);
  @$pb.TagNumber(12)
  set lineMakeModel($core.String v) {
    $_setString(11, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasLineMakeModel() => $_has(11);
  @$pb.TagNumber(12)
  void clearLineMakeModel() => clearField(12);

  @$pb.TagNumber(13)
  MultiMeasurement get lineRating => $_getN(12);
  @$pb.TagNumber(13)
  set lineRating(MultiMeasurement v) {
    setField(13, v);
  }

  @$pb.TagNumber(13)
  $core.bool hasLineRating() => $_has(12);
  @$pb.TagNumber(13)
  void clearLineRating() => clearField(13);
  @$pb.TagNumber(13)
  MultiMeasurement ensureLineRating() => $_ensure(12);

  @$pb.TagNumber(14)
  $core.String get lineColor => $_getSZ(13);
  @$pb.TagNumber(14)
  set lineColor($core.String v) {
    $_setString(13, v);
  }

  @$pb.TagNumber(14)
  $core.bool hasLineColor() => $_has(13);
  @$pb.TagNumber(14)
  void clearLineColor() => clearField(14);

  @$pb.TagNumber(15)
  MultiMeasurement get leaderLength => $_getN(14);
  @$pb.TagNumber(15)
  set leaderLength(MultiMeasurement v) {
    setField(15, v);
  }

  @$pb.TagNumber(15)
  $core.bool hasLeaderLength() => $_has(14);
  @$pb.TagNumber(15)
  void clearLeaderLength() => clearField(15);
  @$pb.TagNumber(15)
  MultiMeasurement ensureLeaderLength() => $_ensure(14);

  @$pb.TagNumber(16)
  MultiMeasurement get leaderRating => $_getN(15);
  @$pb.TagNumber(16)
  set leaderRating(MultiMeasurement v) {
    setField(16, v);
  }

  @$pb.TagNumber(16)
  $core.bool hasLeaderRating() => $_has(15);
  @$pb.TagNumber(16)
  void clearLeaderRating() => clearField(16);
  @$pb.TagNumber(16)
  MultiMeasurement ensureLeaderRating() => $_ensure(15);

  @$pb.TagNumber(17)
  MultiMeasurement get tippetLength => $_getN(16);
  @$pb.TagNumber(17)
  set tippetLength(MultiMeasurement v) {
    setField(17, v);
  }

  @$pb.TagNumber(17)
  $core.bool hasTippetLength() => $_has(16);
  @$pb.TagNumber(17)
  void clearTippetLength() => clearField(17);
  @$pb.TagNumber(17)
  MultiMeasurement ensureTippetLength() => $_ensure(16);

  @$pb.TagNumber(18)
  MultiMeasurement get tippetRating => $_getN(17);
  @$pb.TagNumber(18)
  set tippetRating(MultiMeasurement v) {
    setField(18, v);
  }

  @$pb.TagNumber(18)
  $core.bool hasTippetRating() => $_has(17);
  @$pb.TagNumber(18)
  void clearTippetRating() => clearField(18);
  @$pb.TagNumber(18)
  MultiMeasurement ensureTippetRating() => $_ensure(17);

  @$pb.TagNumber(19)
  $core.String get hookMakeModel => $_getSZ(18);
  @$pb.TagNumber(19)
  set hookMakeModel($core.String v) {
    $_setString(18, v);
  }

  @$pb.TagNumber(19)
  $core.bool hasHookMakeModel() => $_has(18);
  @$pb.TagNumber(19)
  void clearHookMakeModel() => clearField(19);

  @$pb.TagNumber(20)
  MultiMeasurement get hookSize => $_getN(19);
  @$pb.TagNumber(20)
  set hookSize(MultiMeasurement v) {
    setField(20, v);
  }

  @$pb.TagNumber(20)
  $core.bool hasHookSize() => $_has(19);
  @$pb.TagNumber(20)
  void clearHookSize() => clearField(20);
  @$pb.TagNumber(20)
  MultiMeasurement ensureHookSize() => $_ensure(19);

  @$pb.TagNumber(21)
  $core.List<CustomEntityValue> get customEntityValues => $_getList(20);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
// ignore_for_file: undefined_named_parameter,no_leading_underscores_for_local_identifiers
