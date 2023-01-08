import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:quiver/strings.dart';

import '../model/gen/anglerslog.pb.dart';
import '../widgets/default_mapbox_map.dart';
import '../widgets/widget.dart';
import 'details_map_page.dart';

class GpsTrailPage extends StatefulWidget {
  final GpsTrail trail;
  final bool isPresented;

  const GpsTrailPage(
    this.trail, {
    this.isPresented = false,
  });

  @override
  State<GpsTrailPage> createState() => _GpsTrailPageState();
}

class _GpsTrailPageState extends State<GpsTrailPage> {
  static const mapZoomStart = 16.5;

  MapboxMapController? _mapController;

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  TimeManager get _timeManager => TimeManager.of(context);

  GpsTrail get _trail => widget.trail;

  @override
  Widget build(BuildContext context) {
    return DetailsMapPage(
      controller: _mapController,
      map: _buildMap(),
      details: _buildDetails(),
      isPresented: widget.isPresented,
    );
  }

  DefaultMapboxMap _buildMap() {
    return DefaultMapboxMap(
      startPosition: _trail.center,
      startZoom: mapZoomStart,
      onMapCreated: (controller) => _mapController = controller,
      onStyleLoadedCallback: () async {
        await GpsMapTrail(_mapController).draw(context, _trail);
        await _mapController?.animateToBounds(_trail.mapBounds);
      },
    );
  }

  Widget _buildDetails() {
    var bodyOfWaterName =
        _bodyOfWaterManager.displayNameFromId(context, _trail.bodyOfWaterId);
    var bodyOfWaterWidget = EmptyOr(
      isShowing: isNotEmpty(bodyOfWaterName),
      childBuilder: (context) => Text(
        bodyOfWaterName!,
        style: stylePrimary(context),
      ),
    );

    var timestampWidget = Text(
      _trail.elapsedDisplayValue(context) ?? _trail.startDisplayValue(context),
      style: isEmpty(bodyOfWaterName)
          ? stylePrimary(context)
          : styleSubtitle(context),
    );

    var inProgressWidget = EmptyOr(
      isShowing: _trail.isInProgress,
      childBuilder: (context) => Text(
        Strings.of(context).gpsTrailListPageInProgress,
        style: styleSuccess(context)
            .copyWith(fontSize: styleSubtitle(context).fontSize),
      ),
    );

    var endTimestamp = _trail.hasEndTimestamp()
        ? _trail.endTimestamp.toInt()
        : _timeManager.currentTimestamp;
    var durationWidget = Text(
      formatDuration(
        context: context,
        millisecondsDuration: endTimestamp - _trail.startTimestamp.toInt(),
        condensed: true,
      ),
      style: styleSubtitle(context),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wrap in Row to fill screen width.
        bodyOfWaterWidget,
        timestampWidget,
        inProgressWidget,
        durationWidget,
      ],
    );
  }
}
