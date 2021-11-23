///
//  Generated code. Do not modify.
//  source: anglerslog.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class Direction extends $pb.ProtobufEnum {
  static const Direction direction_all = Direction._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'direction_all');
  static const Direction direction_none = Direction._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'direction_none');
  static const Direction north = Direction._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'north');
  static const Direction north_east = Direction._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'north_east');
  static const Direction east = Direction._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'east');
  static const Direction south_east = Direction._(5, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'south_east');
  static const Direction south = Direction._(6, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'south');
  static const Direction south_west = Direction._(7, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'south_west');
  static const Direction west = Direction._(8, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'west');
  static const Direction north_west = Direction._(9, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'north_west');

  static const $core.List<Direction> values = <Direction> [
    direction_all,
    direction_none,
    north,
    north_east,
    east,
    south_east,
    south,
    south_west,
    west,
    north_west,
  ];

  static final $core.Map<$core.int, Direction> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Direction? valueOf($core.int value) => _byValue[value];

  const Direction._($core.int v, $core.String n) : super(v, n);
}

class MeasurementSystem extends $pb.ProtobufEnum {
  static const MeasurementSystem imperial_whole = MeasurementSystem._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'imperial_whole');
  static const MeasurementSystem imperial_decimal = MeasurementSystem._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'imperial_decimal');
  static const MeasurementSystem metric = MeasurementSystem._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'metric');

  static const $core.List<MeasurementSystem> values = <MeasurementSystem> [
    imperial_whole,
    imperial_decimal,
    metric,
  ];

  static final $core.Map<$core.int, MeasurementSystem> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MeasurementSystem? valueOf($core.int value) => _byValue[value];

  const MeasurementSystem._($core.int v, $core.String n) : super(v, n);
}

class MoonPhase extends $pb.ProtobufEnum {
  static const MoonPhase moon_phase_all = MoonPhase._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'moon_phase_all');
  static const MoonPhase moon_phase_none = MoonPhase._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'moon_phase_none');
  static const MoonPhase new_ = MoonPhase._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'new');
  static const MoonPhase waxing_crescent = MoonPhase._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'waxing_crescent');
  static const MoonPhase first_quarter = MoonPhase._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'first_quarter');
  static const MoonPhase waxing_gibbous = MoonPhase._(5, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'waxing_gibbous');
  static const MoonPhase full = MoonPhase._(6, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'full');
  static const MoonPhase waning_gibbous = MoonPhase._(7, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'waning_gibbous');
  static const MoonPhase last_quarter = MoonPhase._(8, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'last_quarter');
  static const MoonPhase waning_crescent = MoonPhase._(9, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'waning_crescent');

  static const $core.List<MoonPhase> values = <MoonPhase> [
    moon_phase_all,
    moon_phase_none,
    new_,
    waxing_crescent,
    first_quarter,
    waxing_gibbous,
    full,
    waning_gibbous,
    last_quarter,
    waning_crescent,
  ];

  static final $core.Map<$core.int, MoonPhase> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MoonPhase? valueOf($core.int value) => _byValue[value];

  const MoonPhase._($core.int v, $core.String n) : super(v, n);
}

class NumberBoundary extends $pb.ProtobufEnum {
  static const NumberBoundary number_boundary_any = NumberBoundary._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'number_boundary_any');
  static const NumberBoundary less_than = NumberBoundary._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'less_than');
  static const NumberBoundary less_than_or_equal_to = NumberBoundary._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'less_than_or_equal_to');
  static const NumberBoundary equal_to = NumberBoundary._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'equal_to');
  static const NumberBoundary greater_than = NumberBoundary._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'greater_than');
  static const NumberBoundary greater_than_or_equal_to = NumberBoundary._(5, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'greater_than_or_equal_to');
  static const NumberBoundary range = NumberBoundary._(6, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'range');

  static const $core.List<NumberBoundary> values = <NumberBoundary> [
    number_boundary_any,
    less_than,
    less_than_or_equal_to,
    equal_to,
    greater_than,
    greater_than_or_equal_to,
    range,
  ];

  static final $core.Map<$core.int, NumberBoundary> _byValue = $pb.ProtobufEnum.initByValue(values);
  static NumberBoundary? valueOf($core.int value) => _byValue[value];

  const NumberBoundary._($core.int v, $core.String n) : super(v, n);
}

class Period extends $pb.ProtobufEnum {
  static const Period period_all = Period._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'period_all');
  static const Period period_none = Period._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'period_none');
  static const Period dawn = Period._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'dawn');
  static const Period morning = Period._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'morning');
  static const Period midday = Period._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'midday');
  static const Period afternoon = Period._(5, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'afternoon');
  static const Period dusk = Period._(6, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'dusk');
  static const Period night = Period._(7, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'night');

  static const $core.List<Period> values = <Period> [
    period_all,
    period_none,
    dawn,
    morning,
    midday,
    afternoon,
    dusk,
    night,
  ];

  static final $core.Map<$core.int, Period> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Period? valueOf($core.int value) => _byValue[value];

  const Period._($core.int v, $core.String n) : super(v, n);
}

class Season extends $pb.ProtobufEnum {
  static const Season season_all = Season._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'season_all');
  static const Season season_none = Season._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'season_none');
  static const Season winter = Season._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'winter');
  static const Season spring = Season._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'spring');
  static const Season summer = Season._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'summer');
  static const Season autumn = Season._(5, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'autumn');

  static const $core.List<Season> values = <Season> [
    season_all,
    season_none,
    winter,
    spring,
    summer,
    autumn,
  ];

  static final $core.Map<$core.int, Season> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Season? valueOf($core.int value) => _byValue[value];

  const Season._($core.int v, $core.String n) : super(v, n);
}

class SkyCondition extends $pb.ProtobufEnum {
  static const SkyCondition sky_condition_all = SkyCondition._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'sky_condition_all');
  static const SkyCondition sky_condition_none = SkyCondition._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'sky_condition_none');
  static const SkyCondition snow = SkyCondition._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'snow');
  static const SkyCondition drizzle = SkyCondition._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'drizzle');
  static const SkyCondition dust = SkyCondition._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'dust');
  static const SkyCondition fog = SkyCondition._(5, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'fog');
  static const SkyCondition rain = SkyCondition._(6, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'rain');
  static const SkyCondition tornado = SkyCondition._(7, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'tornado');
  static const SkyCondition hail = SkyCondition._(8, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'hail');
  static const SkyCondition ice = SkyCondition._(9, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'ice');
  static const SkyCondition storm = SkyCondition._(10, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'storm');
  static const SkyCondition mist = SkyCondition._(11, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'mist');
  static const SkyCondition smoke = SkyCondition._(12, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'smoke');
  static const SkyCondition overcast = SkyCondition._(13, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'overcast');
  static const SkyCondition cloudy = SkyCondition._(14, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'cloudy');
  static const SkyCondition clear = SkyCondition._(15, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'clear');

  static const $core.List<SkyCondition> values = <SkyCondition> [
    sky_condition_all,
    sky_condition_none,
    snow,
    drizzle,
    dust,
    fog,
    rain,
    tornado,
    hail,
    ice,
    storm,
    mist,
    smoke,
    overcast,
    cloudy,
    clear,
  ];

  static final $core.Map<$core.int, SkyCondition> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SkyCondition? valueOf($core.int value) => _byValue[value];

  const SkyCondition._($core.int v, $core.String n) : super(v, n);
}

class TideType extends $pb.ProtobufEnum {
  static const TideType tide_type_all = TideType._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'tide_type_all');
  static const TideType tide_type_none = TideType._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'tide_type_none');
  static const TideType low = TideType._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'low');
  static const TideType outgoing = TideType._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'outgoing');
  static const TideType high = TideType._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'high');
  static const TideType slack = TideType._(5, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'slack');
  static const TideType incoming = TideType._(6, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'incoming');

  static const $core.List<TideType> values = <TideType> [
    tide_type_all,
    tide_type_none,
    low,
    outgoing,
    high,
    slack,
    incoming,
  ];

  static final $core.Map<$core.int, TideType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static TideType? valueOf($core.int value) => _byValue[value];

  const TideType._($core.int v, $core.String n) : super(v, n);
}

class Unit extends $pb.ProtobufEnum {
  static const Unit feet = Unit._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'feet');
  static const Unit inches = Unit._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'inches');
  static const Unit pounds = Unit._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'pounds');
  static const Unit ounces = Unit._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'ounces');
  static const Unit fahrenheit = Unit._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'fahrenheit');
  static const Unit meters = Unit._(5, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'meters');
  static const Unit centimeters = Unit._(6, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'centimeters');
  static const Unit kilograms = Unit._(7, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'kilograms');
  static const Unit celsius = Unit._(8, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'celsius');
  static const Unit miles_per_hour = Unit._(9, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'miles_per_hour');
  static const Unit kilometers_per_hour = Unit._(10, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'kilometers_per_hour');
  static const Unit millibars = Unit._(11, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'millibars');
  static const Unit pounds_per_square_inch = Unit._(12, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'pounds_per_square_inch');
  static const Unit miles = Unit._(13, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'miles');
  static const Unit kilometers = Unit._(14, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'kilometers');
  static const Unit percent = Unit._(15, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'percent');

  static const $core.List<Unit> values = <Unit> [
    feet,
    inches,
    pounds,
    ounces,
    fahrenheit,
    meters,
    centimeters,
    kilograms,
    celsius,
    miles_per_hour,
    kilometers_per_hour,
    millibars,
    pounds_per_square_inch,
    miles,
    kilometers,
    percent,
  ];

  static final $core.Map<$core.int, Unit> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Unit? valueOf($core.int value) => _byValue[value];

  const Unit._($core.int v, $core.String n) : super(v, n);
}

class CustomEntity_Type extends $pb.ProtobufEnum {
  static const CustomEntity_Type boolean = CustomEntity_Type._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'boolean');
  static const CustomEntity_Type number = CustomEntity_Type._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'number');
  static const CustomEntity_Type text = CustomEntity_Type._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'text');

  static const $core.List<CustomEntity_Type> values = <CustomEntity_Type> [
    boolean,
    number,
    text,
  ];

  static final $core.Map<$core.int, CustomEntity_Type> _byValue = $pb.ProtobufEnum.initByValue(values);
  static CustomEntity_Type? valueOf($core.int value) => _byValue[value];

  const CustomEntity_Type._($core.int v, $core.String n) : super(v, n);
}

class Bait_Type extends $pb.ProtobufEnum {
  static const Bait_Type artificial = Bait_Type._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'artificial');
  static const Bait_Type real = Bait_Type._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'real');
  static const Bait_Type live = Bait_Type._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'live');

  static const $core.List<Bait_Type> values = <Bait_Type> [
    artificial,
    real,
    live,
  ];

  static final $core.Map<$core.int, Bait_Type> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Bait_Type? valueOf($core.int value) => _byValue[value];

  const Bait_Type._($core.int v, $core.String n) : super(v, n);
}

class DateRange_Period extends $pb.ProtobufEnum {
  static const DateRange_Period allDates = DateRange_Period._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'allDates');
  static const DateRange_Period today = DateRange_Period._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'today');
  static const DateRange_Period yesterday = DateRange_Period._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'yesterday');
  static const DateRange_Period thisWeek = DateRange_Period._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'thisWeek');
  static const DateRange_Period thisMonth = DateRange_Period._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'thisMonth');
  static const DateRange_Period thisYear = DateRange_Period._(5, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'thisYear');
  static const DateRange_Period lastWeek = DateRange_Period._(6, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'lastWeek');
  static const DateRange_Period lastMonth = DateRange_Period._(7, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'lastMonth');
  static const DateRange_Period lastYear = DateRange_Period._(8, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'lastYear');
  static const DateRange_Period last7Days = DateRange_Period._(9, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'last7Days');
  static const DateRange_Period last14Days = DateRange_Period._(10, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'last14Days');
  static const DateRange_Period last30Days = DateRange_Period._(11, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'last30Days');
  static const DateRange_Period last60Days = DateRange_Period._(12, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'last60Days');
  static const DateRange_Period last12Months = DateRange_Period._(13, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'last12Months');
  static const DateRange_Period custom = DateRange_Period._(14, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'custom');

  static const $core.List<DateRange_Period> values = <DateRange_Period> [
    allDates,
    today,
    yesterday,
    thisWeek,
    thisMonth,
    thisYear,
    lastWeek,
    lastMonth,
    lastYear,
    last7Days,
    last14Days,
    last30Days,
    last60Days,
    last12Months,
    custom,
  ];

  static final $core.Map<$core.int, DateRange_Period> _byValue = $pb.ProtobufEnum.initByValue(values);
  static DateRange_Period? valueOf($core.int value) => _byValue[value];

  const DateRange_Period._($core.int v, $core.String n) : super(v, n);
}

class Report_Type extends $pb.ProtobufEnum {
  static const Report_Type summary = Report_Type._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'summary');
  static const Report_Type comparison = Report_Type._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'comparison');
  static const Report_Type catch_summary = Report_Type._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'catch_summary');
  static const Report_Type species_summary = Report_Type._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'species_summary');
  static const Report_Type fishing_spot_summary = Report_Type._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'fishing_spot_summary');
  static const Report_Type bait_summary = Report_Type._(5, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'bait_summary');
  static const Report_Type moon_phase_summary = Report_Type._(6, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'moon_phase_summary');
  static const Report_Type tide_summary = Report_Type._(7, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'tide_summary');
  static const Report_Type angler_summary = Report_Type._(8, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'angler_summary');
  static const Report_Type body_of_water_summary = Report_Type._(9, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'body_of_water_summary');
  static const Report_Type method_summary = Report_Type._(10, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'method_summary');
  static const Report_Type period_summary = Report_Type._(11, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'period_summary');
  static const Report_Type season_summary = Report_Type._(12, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'season_summary');
  static const Report_Type water_clarity_summary = Report_Type._(13, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'water_clarity_summary');
  static const Report_Type trip_summary = Report_Type._(14, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'trip_summary');
  static const Report_Type personal_bests = Report_Type._(15, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'personal_bests');

  static const $core.List<Report_Type> values = <Report_Type> [
    summary,
    comparison,
    catch_summary,
    species_summary,
    fishing_spot_summary,
    bait_summary,
    moon_phase_summary,
    tide_summary,
    angler_summary,
    body_of_water_summary,
    method_summary,
    period_summary,
    season_summary,
    water_clarity_summary,
    trip_summary,
    personal_bests,
  ];

  static final $core.Map<$core.int, Report_Type> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Report_Type? valueOf($core.int value) => _byValue[value];

  const Report_Type._($core.int v, $core.String n) : super(v, n);
}

// ignore_for_file: undefined_named_parameter,constant_identifier_names
