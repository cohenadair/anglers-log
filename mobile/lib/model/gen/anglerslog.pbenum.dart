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

import 'package:protobuf/protobuf.dart' as $pb;

class Direction extends $pb.ProtobufEnum {
  static const Direction direction_all =
      Direction._(0, _omitEnumNames ? '' : 'direction_all');
  static const Direction direction_none =
      Direction._(1, _omitEnumNames ? '' : 'direction_none');
  static const Direction north = Direction._(2, _omitEnumNames ? '' : 'north');
  static const Direction north_east =
      Direction._(3, _omitEnumNames ? '' : 'north_east');
  static const Direction east = Direction._(4, _omitEnumNames ? '' : 'east');
  static const Direction south_east =
      Direction._(5, _omitEnumNames ? '' : 'south_east');
  static const Direction south = Direction._(6, _omitEnumNames ? '' : 'south');
  static const Direction south_west =
      Direction._(7, _omitEnumNames ? '' : 'south_west');
  static const Direction west = Direction._(8, _omitEnumNames ? '' : 'west');
  static const Direction north_west =
      Direction._(9, _omitEnumNames ? '' : 'north_west');

  static const $core.List<Direction> values = <Direction>[
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

  static final $core.Map<$core.int, Direction> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Direction? valueOf($core.int value) => _byValue[value];

  const Direction._($core.int v, $core.String n) : super(v, n);
}

class MeasurementSystem extends $pb.ProtobufEnum {
  static const MeasurementSystem imperial_whole =
      MeasurementSystem._(0, _omitEnumNames ? '' : 'imperial_whole');
  static const MeasurementSystem imperial_decimal =
      MeasurementSystem._(1, _omitEnumNames ? '' : 'imperial_decimal');
  static const MeasurementSystem metric =
      MeasurementSystem._(2, _omitEnumNames ? '' : 'metric');

  static const $core.List<MeasurementSystem> values = <MeasurementSystem>[
    imperial_whole,
    imperial_decimal,
    metric,
  ];

  static final $core.Map<$core.int, MeasurementSystem> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static MeasurementSystem? valueOf($core.int value) => _byValue[value];

  const MeasurementSystem._($core.int v, $core.String n) : super(v, n);
}

class MoonPhase extends $pb.ProtobufEnum {
  static const MoonPhase moon_phase_all =
      MoonPhase._(0, _omitEnumNames ? '' : 'moon_phase_all');
  static const MoonPhase moon_phase_none =
      MoonPhase._(1, _omitEnumNames ? '' : 'moon_phase_none');
  static const MoonPhase new_ = MoonPhase._(2, _omitEnumNames ? '' : 'new');
  static const MoonPhase waxing_crescent =
      MoonPhase._(3, _omitEnumNames ? '' : 'waxing_crescent');
  static const MoonPhase first_quarter =
      MoonPhase._(4, _omitEnumNames ? '' : 'first_quarter');
  static const MoonPhase waxing_gibbous =
      MoonPhase._(5, _omitEnumNames ? '' : 'waxing_gibbous');
  static const MoonPhase full = MoonPhase._(6, _omitEnumNames ? '' : 'full');
  static const MoonPhase waning_gibbous =
      MoonPhase._(7, _omitEnumNames ? '' : 'waning_gibbous');
  static const MoonPhase last_quarter =
      MoonPhase._(8, _omitEnumNames ? '' : 'last_quarter');
  static const MoonPhase waning_crescent =
      MoonPhase._(9, _omitEnumNames ? '' : 'waning_crescent');

  static const $core.List<MoonPhase> values = <MoonPhase>[
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

  static final $core.Map<$core.int, MoonPhase> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static MoonPhase? valueOf($core.int value) => _byValue[value];

  const MoonPhase._($core.int v, $core.String n) : super(v, n);
}

class NumberBoundary extends $pb.ProtobufEnum {
  static const NumberBoundary number_boundary_any =
      NumberBoundary._(0, _omitEnumNames ? '' : 'number_boundary_any');
  static const NumberBoundary less_than =
      NumberBoundary._(1, _omitEnumNames ? '' : 'less_than');
  static const NumberBoundary less_than_or_equal_to =
      NumberBoundary._(2, _omitEnumNames ? '' : 'less_than_or_equal_to');
  static const NumberBoundary equal_to =
      NumberBoundary._(3, _omitEnumNames ? '' : 'equal_to');
  static const NumberBoundary greater_than =
      NumberBoundary._(4, _omitEnumNames ? '' : 'greater_than');
  static const NumberBoundary greater_than_or_equal_to =
      NumberBoundary._(5, _omitEnumNames ? '' : 'greater_than_or_equal_to');
  static const NumberBoundary range =
      NumberBoundary._(6, _omitEnumNames ? '' : 'range');

  static const $core.List<NumberBoundary> values = <NumberBoundary>[
    number_boundary_any,
    less_than,
    less_than_or_equal_to,
    equal_to,
    greater_than,
    greater_than_or_equal_to,
    range,
  ];

  static final $core.Map<$core.int, NumberBoundary> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static NumberBoundary? valueOf($core.int value) => _byValue[value];

  const NumberBoundary._($core.int v, $core.String n) : super(v, n);
}

class Period extends $pb.ProtobufEnum {
  static const Period period_all =
      Period._(0, _omitEnumNames ? '' : 'period_all');
  static const Period period_none =
      Period._(1, _omitEnumNames ? '' : 'period_none');
  static const Period dawn = Period._(2, _omitEnumNames ? '' : 'dawn');
  static const Period morning = Period._(3, _omitEnumNames ? '' : 'morning');
  static const Period midday = Period._(4, _omitEnumNames ? '' : 'midday');
  static const Period afternoon =
      Period._(5, _omitEnumNames ? '' : 'afternoon');
  static const Period dusk = Period._(6, _omitEnumNames ? '' : 'dusk');
  static const Period night = Period._(7, _omitEnumNames ? '' : 'night');
  static const Period evening = Period._(8, _omitEnumNames ? '' : 'evening');

  static const $core.List<Period> values = <Period>[
    period_all,
    period_none,
    dawn,
    morning,
    midday,
    afternoon,
    dusk,
    night,
    evening,
  ];

  static final $core.Map<$core.int, Period> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Period? valueOf($core.int value) => _byValue[value];

  const Period._($core.int v, $core.String n) : super(v, n);
}

class Season extends $pb.ProtobufEnum {
  static const Season season_all =
      Season._(0, _omitEnumNames ? '' : 'season_all');
  static const Season season_none =
      Season._(1, _omitEnumNames ? '' : 'season_none');
  static const Season winter = Season._(2, _omitEnumNames ? '' : 'winter');
  static const Season spring = Season._(3, _omitEnumNames ? '' : 'spring');
  static const Season summer = Season._(4, _omitEnumNames ? '' : 'summer');
  static const Season autumn = Season._(5, _omitEnumNames ? '' : 'autumn');

  static const $core.List<Season> values = <Season>[
    season_all,
    season_none,
    winter,
    spring,
    summer,
    autumn,
  ];

  static final $core.Map<$core.int, Season> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Season? valueOf($core.int value) => _byValue[value];

  const Season._($core.int v, $core.String n) : super(v, n);
}

class SkyCondition extends $pb.ProtobufEnum {
  static const SkyCondition sky_condition_all =
      SkyCondition._(0, _omitEnumNames ? '' : 'sky_condition_all');
  static const SkyCondition sky_condition_none =
      SkyCondition._(1, _omitEnumNames ? '' : 'sky_condition_none');
  static const SkyCondition snow =
      SkyCondition._(2, _omitEnumNames ? '' : 'snow');
  static const SkyCondition drizzle =
      SkyCondition._(3, _omitEnumNames ? '' : 'drizzle');
  static const SkyCondition dust =
      SkyCondition._(4, _omitEnumNames ? '' : 'dust');
  static const SkyCondition fog =
      SkyCondition._(5, _omitEnumNames ? '' : 'fog');
  static const SkyCondition rain =
      SkyCondition._(6, _omitEnumNames ? '' : 'rain');
  static const SkyCondition tornado =
      SkyCondition._(7, _omitEnumNames ? '' : 'tornado');
  static const SkyCondition hail =
      SkyCondition._(8, _omitEnumNames ? '' : 'hail');
  static const SkyCondition ice =
      SkyCondition._(9, _omitEnumNames ? '' : 'ice');
  static const SkyCondition storm =
      SkyCondition._(10, _omitEnumNames ? '' : 'storm');
  static const SkyCondition mist =
      SkyCondition._(11, _omitEnumNames ? '' : 'mist');
  static const SkyCondition smoke =
      SkyCondition._(12, _omitEnumNames ? '' : 'smoke');
  static const SkyCondition overcast =
      SkyCondition._(13, _omitEnumNames ? '' : 'overcast');
  static const SkyCondition cloudy =
      SkyCondition._(14, _omitEnumNames ? '' : 'cloudy');
  static const SkyCondition clear =
      SkyCondition._(15, _omitEnumNames ? '' : 'clear');
  static const SkyCondition sunny =
      SkyCondition._(16, _omitEnumNames ? '' : 'sunny');

  static const $core.List<SkyCondition> values = <SkyCondition>[
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
    sunny,
  ];

  static final $core.Map<$core.int, SkyCondition> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static SkyCondition? valueOf($core.int value) => _byValue[value];

  const SkyCondition._($core.int v, $core.String n) : super(v, n);
}

class TideType extends $pb.ProtobufEnum {
  static const TideType tide_type_all =
      TideType._(0, _omitEnumNames ? '' : 'tide_type_all');
  static const TideType tide_type_none =
      TideType._(1, _omitEnumNames ? '' : 'tide_type_none');
  static const TideType low = TideType._(2, _omitEnumNames ? '' : 'low');
  static const TideType outgoing =
      TideType._(3, _omitEnumNames ? '' : 'outgoing');
  static const TideType high = TideType._(4, _omitEnumNames ? '' : 'high');
  static const TideType slack = TideType._(5, _omitEnumNames ? '' : 'slack');
  static const TideType incoming =
      TideType._(6, _omitEnumNames ? '' : 'incoming');

  static const $core.List<TideType> values = <TideType>[
    tide_type_all,
    tide_type_none,
    low,
    outgoing,
    high,
    slack,
    incoming,
  ];

  static final $core.Map<$core.int, TideType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static TideType? valueOf($core.int value) => _byValue[value];

  const TideType._($core.int v, $core.String n) : super(v, n);
}

class Unit extends $pb.ProtobufEnum {
  static const Unit feet = Unit._(0, _omitEnumNames ? '' : 'feet');
  static const Unit inches = Unit._(1, _omitEnumNames ? '' : 'inches');
  static const Unit pounds = Unit._(2, _omitEnumNames ? '' : 'pounds');
  static const Unit ounces = Unit._(3, _omitEnumNames ? '' : 'ounces');
  static const Unit fahrenheit = Unit._(4, _omitEnumNames ? '' : 'fahrenheit');
  static const Unit meters = Unit._(5, _omitEnumNames ? '' : 'meters');
  static const Unit centimeters =
      Unit._(6, _omitEnumNames ? '' : 'centimeters');
  static const Unit kilograms = Unit._(7, _omitEnumNames ? '' : 'kilograms');
  static const Unit celsius = Unit._(8, _omitEnumNames ? '' : 'celsius');
  static const Unit miles_per_hour =
      Unit._(9, _omitEnumNames ? '' : 'miles_per_hour');
  static const Unit kilometers_per_hour =
      Unit._(10, _omitEnumNames ? '' : 'kilometers_per_hour');
  static const Unit millibars = Unit._(11, _omitEnumNames ? '' : 'millibars');
  static const Unit pounds_per_square_inch =
      Unit._(12, _omitEnumNames ? '' : 'pounds_per_square_inch');
  static const Unit miles = Unit._(13, _omitEnumNames ? '' : 'miles');
  static const Unit kilometers = Unit._(14, _omitEnumNames ? '' : 'kilometers');
  static const Unit percent = Unit._(15, _omitEnumNames ? '' : 'percent');
  static const Unit inch_of_mercury =
      Unit._(16, _omitEnumNames ? '' : 'inch_of_mercury');
  static const Unit pound_test = Unit._(17, _omitEnumNames ? '' : 'pound_test');
  static const Unit x = Unit._(18, _omitEnumNames ? '' : 'x');
  static const Unit hashtag = Unit._(19, _omitEnumNames ? '' : 'hashtag');
  static const Unit aught = Unit._(20, _omitEnumNames ? '' : 'aught');

  static const $core.List<Unit> values = <Unit>[
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
    inch_of_mercury,
    pound_test,
    x,
    hashtag,
    aught,
  ];

  static final $core.Map<$core.int, Unit> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Unit? valueOf($core.int value) => _byValue[value];

  const Unit._($core.int v, $core.String n) : super(v, n);
}

class RodAction extends $pb.ProtobufEnum {
  static const RodAction rod_action_all =
      RodAction._(0, _omitEnumNames ? '' : 'rod_action_all');
  static const RodAction rod_action_none =
      RodAction._(1, _omitEnumNames ? '' : 'rod_action_none');
  static const RodAction x_fast =
      RodAction._(2, _omitEnumNames ? '' : 'x_fast');
  static const RodAction fast = RodAction._(3, _omitEnumNames ? '' : 'fast');
  static const RodAction moderate_fast =
      RodAction._(4, _omitEnumNames ? '' : 'moderate_fast');
  static const RodAction moderate =
      RodAction._(5, _omitEnumNames ? '' : 'moderate');
  static const RodAction slow = RodAction._(6, _omitEnumNames ? '' : 'slow');

  static const $core.List<RodAction> values = <RodAction>[
    rod_action_all,
    rod_action_none,
    x_fast,
    fast,
    moderate_fast,
    moderate,
    slow,
  ];

  static final $core.Map<$core.int, RodAction> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static RodAction? valueOf($core.int value) => _byValue[value];

  const RodAction._($core.int v, $core.String n) : super(v, n);
}

class RodPower extends $pb.ProtobufEnum {
  static const RodPower rod_power_all =
      RodPower._(0, _omitEnumNames ? '' : 'rod_power_all');
  static const RodPower rod_power_none =
      RodPower._(1, _omitEnumNames ? '' : 'rod_power_none');
  static const RodPower ultralight =
      RodPower._(2, _omitEnumNames ? '' : 'ultralight');
  static const RodPower light = RodPower._(3, _omitEnumNames ? '' : 'light');
  static const RodPower medium_light =
      RodPower._(4, _omitEnumNames ? '' : 'medium_light');
  static const RodPower medium = RodPower._(5, _omitEnumNames ? '' : 'medium');
  static const RodPower medium_heavy =
      RodPower._(6, _omitEnumNames ? '' : 'medium_heavy');
  static const RodPower heavy = RodPower._(7, _omitEnumNames ? '' : 'heavy');
  static const RodPower x_heavy =
      RodPower._(8, _omitEnumNames ? '' : 'x_heavy');
  static const RodPower xx_heavy =
      RodPower._(9, _omitEnumNames ? '' : 'xx_heavy');
  static const RodPower xxx_heavy =
      RodPower._(10, _omitEnumNames ? '' : 'xxx_heavy');

  static const $core.List<RodPower> values = <RodPower>[
    rod_power_all,
    rod_power_none,
    ultralight,
    light,
    medium_light,
    medium,
    medium_heavy,
    heavy,
    x_heavy,
    xx_heavy,
    xxx_heavy,
  ];

  static final $core.Map<$core.int, RodPower> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static RodPower? valueOf($core.int value) => _byValue[value];

  const RodPower._($core.int v, $core.String n) : super(v, n);
}

class CustomEntity_Type extends $pb.ProtobufEnum {
  static const CustomEntity_Type boolean =
      CustomEntity_Type._(0, _omitEnumNames ? '' : 'boolean');
  static const CustomEntity_Type number =
      CustomEntity_Type._(1, _omitEnumNames ? '' : 'number');
  static const CustomEntity_Type text =
      CustomEntity_Type._(2, _omitEnumNames ? '' : 'text');

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

class Bait_Type extends $pb.ProtobufEnum {
  static const Bait_Type artificial =
      Bait_Type._(0, _omitEnumNames ? '' : 'artificial');
  static const Bait_Type real = Bait_Type._(1, _omitEnumNames ? '' : 'real');
  static const Bait_Type live = Bait_Type._(2, _omitEnumNames ? '' : 'live');

  static const $core.List<Bait_Type> values = <Bait_Type>[
    artificial,
    real,
    live,
  ];

  static final $core.Map<$core.int, Bait_Type> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Bait_Type? valueOf($core.int value) => _byValue[value];

  const Bait_Type._($core.int v, $core.String n) : super(v, n);
}

class DateRange_Period extends $pb.ProtobufEnum {
  static const DateRange_Period allDates =
      DateRange_Period._(0, _omitEnumNames ? '' : 'allDates');
  static const DateRange_Period today =
      DateRange_Period._(1, _omitEnumNames ? '' : 'today');
  static const DateRange_Period yesterday =
      DateRange_Period._(2, _omitEnumNames ? '' : 'yesterday');
  static const DateRange_Period thisWeek =
      DateRange_Period._(3, _omitEnumNames ? '' : 'thisWeek');
  static const DateRange_Period thisMonth =
      DateRange_Period._(4, _omitEnumNames ? '' : 'thisMonth');
  static const DateRange_Period thisYear =
      DateRange_Period._(5, _omitEnumNames ? '' : 'thisYear');
  static const DateRange_Period lastWeek =
      DateRange_Period._(6, _omitEnumNames ? '' : 'lastWeek');
  static const DateRange_Period lastMonth =
      DateRange_Period._(7, _omitEnumNames ? '' : 'lastMonth');
  static const DateRange_Period lastYear =
      DateRange_Period._(8, _omitEnumNames ? '' : 'lastYear');
  static const DateRange_Period last7Days =
      DateRange_Period._(9, _omitEnumNames ? '' : 'last7Days');
  static const DateRange_Period last14Days =
      DateRange_Period._(10, _omitEnumNames ? '' : 'last14Days');
  static const DateRange_Period last30Days =
      DateRange_Period._(11, _omitEnumNames ? '' : 'last30Days');
  static const DateRange_Period last60Days =
      DateRange_Period._(12, _omitEnumNames ? '' : 'last60Days');
  static const DateRange_Period last12Months =
      DateRange_Period._(13, _omitEnumNames ? '' : 'last12Months');
  static const DateRange_Period custom =
      DateRange_Period._(14, _omitEnumNames ? '' : 'custom');

  static const $core.List<DateRange_Period> values = <DateRange_Period>[
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

  static final $core.Map<$core.int, DateRange_Period> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static DateRange_Period? valueOf($core.int value) => _byValue[value];

  const DateRange_Period._($core.int v, $core.String n) : super(v, n);
}

class Report_Type extends $pb.ProtobufEnum {
  static const Report_Type summary =
      Report_Type._(0, _omitEnumNames ? '' : 'summary');
  static const Report_Type comparison =
      Report_Type._(1, _omitEnumNames ? '' : 'comparison');

  static const $core.List<Report_Type> values = <Report_Type>[
    summary,
    comparison,
  ];

  static final $core.Map<$core.int, Report_Type> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static Report_Type? valueOf($core.int value) => _byValue[value];

  const Report_Type._($core.int v, $core.String n) : super(v, n);
}

class CatchFilterOptions_Order extends $pb.ProtobufEnum {
  static const CatchFilterOptions_Order unknown =
      CatchFilterOptions_Order._(0, _omitEnumNames ? '' : 'unknown');
  static const CatchFilterOptions_Order newest_to_oldest =
      CatchFilterOptions_Order._(1, _omitEnumNames ? '' : 'newest_to_oldest');
  static const CatchFilterOptions_Order heaviest_to_lightest =
      CatchFilterOptions_Order._(
          2, _omitEnumNames ? '' : 'heaviest_to_lightest');
  static const CatchFilterOptions_Order longest_to_shortest =
      CatchFilterOptions_Order._(
          3, _omitEnumNames ? '' : 'longest_to_shortest');

  static const $core.List<CatchFilterOptions_Order> values =
      <CatchFilterOptions_Order>[
    unknown,
    newest_to_oldest,
    heaviest_to_lightest,
    longest_to_shortest,
  ];

  static final $core.Map<$core.int, CatchFilterOptions_Order> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static CatchFilterOptions_Order? valueOf($core.int value) => _byValue[value];

  const CatchFilterOptions_Order._($core.int v, $core.String n) : super(v, n);
}

const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
// ignore_for_file: undefined_named_parameter,no_leading_underscores_for_local_identifiers
