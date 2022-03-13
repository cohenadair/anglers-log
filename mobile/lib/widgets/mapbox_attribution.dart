import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import 'package:mobile/wrappers/url_launcher_wrapper.dart';

import 'bottom_sheet_picker.dart';
import 'button.dart';
import 'checkbox_input.dart';
import 'our_bottom_sheet.dart';

@immutable
class MapboxTelemetry {
  final bool isEnabled;
  final void Function(bool) onTogged;

  const MapboxTelemetry({
    required this.isEnabled,
    required this.onTogged,
  });
}

class MapboxAttribution extends StatelessWidget {
  static const _urlMapbox = "https://www.mapbox.com/about/maps/";
  static const _urlOpenStreetMap = "http://www.openstreetmap.org/copyright";
  static const _urlImproveThisMap = "https://www.mapbox.com/map-feedback/";
  static const _urlMaxar = "https://www.maxar.com/";

  static const _size = Size(85, 20);

  final MapType mapType;
  final MapboxTelemetry? telemetry;

  const MapboxAttribution({
    required this.mapType,
    this.telemetry,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: _size.width,
          height: _size.height,
          child: SvgPicture.asset(
            "assets/mapbox-logo.svg",
            color: mapIconColor(mapType),
          ),
        ),
        MinimumIconButton(
          icon: Icons.info_outline,
          onTap: () => showOurBottomSheet(
            context,
            _buildPicker,
          ),
        ),
      ],
    );
  }

  BottomSheetPicker _buildPicker(BuildContext context) {
    return BottomSheetPicker<String>(
      title: IoWrapper.of(context).isAndroid
          ? Strings.of(context).mapAttributionTitleAndroid
          : Strings.of(context).mapAttributionTitleApple,
      itemStyle: styleHyperlink(context),
      items: {
        Strings.of(context).mapAttributionMapbox: _urlMapbox,
        Strings.of(context).mapAttributionOpenStreetMap: _urlOpenStreetMap,
        Strings.of(context).mapAttributionImproveThisMap: _urlImproveThisMap,
        Strings.of(context).mapAttributionMaxar: _urlMaxar,
      },
      onPicked: (url) => UrlLauncherWrapper.of(context).launch(url!),
      footer: telemetry == null
          ? const VerticalSpace(paddingDefault)
          : CheckboxInput(
              label: Strings.of(context).mapAttributionTelemetryTitle,
              description:
                  Strings.of(context).mapAttributionTelemetryDescription,
              value: telemetry!.isEnabled,
              onChanged: telemetry!.onTogged,
            ),
    );
  }
}
