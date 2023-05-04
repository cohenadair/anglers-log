import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../res/gen/custom_icons.dart';
import '../res/style.dart';
import '../utils/protobuf_utils.dart';
import 'multi_measurement_input.dart';
import 'widget.dart';

class AtmosphereWrap extends StatelessWidget {
  final Atmosphere atmosphere;

  const AtmosphereWrap(this.atmosphere);

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];

    if (atmosphere.hasTemperature() || atmosphere.skyConditions.isNotEmpty) {
      var skyConditions =
          SkyConditions.displayNameForList(context, atmosphere.skyConditions);

      var title = skyConditions;
      var subtitle = "";

      if (atmosphere.hasTemperature()) {
        title = atmosphere.temperature.displayValue(
          context,
          mainDecimalPlaces: MultiMeasurementInputSpec.airTemperature(context)
              .mainValueDecimalPlaces
              ?.call(context),
        );
        subtitle = skyConditions;
      }

      children.add(_Item(
        icon: Icons.cloud,
        title: title,
        subtitle: subtitle,
      ));
    }

    if (atmosphere.hasWindSpeed()) {
      children.add(_Item(
        icon: Icons.air,
        title: atmosphere.windSpeed.displayValue(
          context,
          mainDecimalPlaces: MultiMeasurementInputSpec.windSpeed(context)
              .mainValueDecimalPlaces
              ?.call(context),
        ),
        subtitle: atmosphere.hasWindDirection()
            ? atmosphere.windDirection.displayName(context)
            : Strings.of(context).atmosphereInputWind,
      ));
    }

    if (atmosphere.hasPressure()) {
      children.add(_Item(
        icon: Icons.speed,
        title: atmosphere.pressure.displayValue(
          context,
          mainDecimalPlaces: MultiMeasurementInputSpec.airPressure(context)
              .mainValueDecimalPlaces
              ?.call(context),
        ),
        subtitle: Strings.of(context).atmosphereInputPressure,
      ));
    }

    if (atmosphere.hasVisibility()) {
      children.add(_Item(
        icon: Icons.visibility,
        title: atmosphere.visibility.displayValue(
          context,
          mainDecimalPlaces: MultiMeasurementInputSpec.airVisibility(context)
              .mainValueDecimalPlaces
              ?.call(context),
        ),
        subtitle: Strings.of(context).atmosphereInputVisibility,
      ));
    }

    if (atmosphere.hasHumidity()) {
      children.add(_Item(
        icon: CustomIcons.humidity,
        title: atmosphere.humidity.displayValue(
          context,
          mainDecimalPlaces: MultiMeasurementInputSpec.airHumidity(context)
              .mainValueDecimalPlaces
              ?.call(context),
        ),
        subtitle: Strings.of(context).atmosphereInputHumidity,
      ));
    }

    if (atmosphere.hasSunriseTimestamp()) {
      children.add(_Item(
        icon: CustomIcons.sunrise,
        title: atmosphere.displaySunriseTimestamp(context),
        subtitle: Strings.of(context).atmosphereInputSunrise,
      ));
    }

    if (atmosphere.hasSunsetTimestamp()) {
      children.add(_Item(
        icon: CustomIcons.sunset,
        title: atmosphere.displaySunsetTimestamp(context),
        subtitle: Strings.of(context).atmosphereInputSunset,
      ));
    }

    if (atmosphere.hasMoonPhase()) {
      children.add(_Item(
        icon: Icons.nightlight,
        title: atmosphere.moonPhase.displayName(context),
        subtitle: Strings.of(context).atmosphereInputMoon,
      ));
    }

    return Wrap(
      spacing: paddingDefault,
      runSpacing: paddingDefault,
      children: children,
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  _Item({
    required this.icon,
    required this.title,
    this.subtitle,
  }) : assert(isNotEmpty(title));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultColorIcon(icon),
        Text(
          title,
          textAlign: TextAlign.center,
          overflow: TextOverflow.visible,
        ),
        isEmpty(subtitle)
            ? const Empty()
            : Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: styleSubtitle(context),
                overflow: TextOverflow.visible,
              ),
      ],
    );
  }
}
