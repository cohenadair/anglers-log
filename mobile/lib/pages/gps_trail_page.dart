import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:quiver/strings.dart';

import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../widgets/default_mapbox_map.dart';
import '../widgets/widget.dart';
import 'catch_page.dart';
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

  final _log = const Log("GpsTrailPage");

  MapboxMapController? _mapController;
  GpsMapTrail? _gpsMapTrail;

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  CatchManager get _catchManager => CatchManager.of(context);

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
      onMapCreated: (controller) {
        _mapController = controller;
        _gpsMapTrail = GpsMapTrail(_mapController, _onTapCatch);
      },
      onStyleLoadedCallback: () async {
        await _gpsMapTrail?.draw(context, _trail, includeCatches: true);
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

  void _onTapCatch(Id id) {
    var cat = _catchManager.entity(id);
    if (cat == null) {
      _log.w("Cannot show catch that doesn't exist");
      return;
    }

    push(context, CatchPage(cat));
  }
}
