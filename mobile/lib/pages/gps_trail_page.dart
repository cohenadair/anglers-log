import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:quiver/strings.dart';

import '../location_monitor.dart';
import '../model/gen/anglerslog.pb.dart';
import '../widgets/default_mapbox_map.dart';
import '../widgets/widget.dart';
import 'details_map_page.dart';

class GpsTrailPage extends StatefulWidget {
  final GpsTrail trail;

  const GpsTrailPage(this.trail);

  @override
  State<GpsTrailPage> createState() => _GpsTrailPageState();
}

class _GpsTrailPageState extends State<GpsTrailPage> {
  MapboxMapController? _mapController;

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);

  TimeManager get _timeManager => TimeManager.of(context);

  GpsTrail get _trail => widget.trail;

  @override
  Widget build(BuildContext context) {
    return DetailsMapPage(
      controller: _mapController,
      map: _buildMap(),
      details: _buildDetails(),
    );
  }

  DefaultMapboxMap _buildMap() {
    return DefaultMapboxMap(
      startPosition: _trail.center ??
          _locationMonitor.currentLocation ??
          const LatLng(0, 0),
      onMapCreated: (controller) {
        _mapController = controller;
      },
      onStyleLoadedCallback: () {
        // TODO: Add trail points
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