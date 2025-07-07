import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:quiver/strings.dart';

import '../log.dart';
import '../model/gen/anglers_log.pb.dart';
import '../utils/string_utils.dart';
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
    // Stash value here to avoid async gap warning.
    // Divide by 2 because the padding doesn't need to be quite so large for
    // GPS trails.
    var screenHeight = MediaQuery.of(context).size.height / 2;

    return DefaultMapboxMap(
      startPosition: _trail.center,
      startZoom: mapZoomStart,
      onMapCreated: (controller) {
        _mapController = controller;
        _gpsMapTrail = GpsMapTrail(_mapController, _onTapCatch);
      },
      onStyleLoadedCallback: () async {
        await _gpsMapTrail?.draw(context, _trail, includeCatches: true);
        // For whatever reason, sometimes the animateToBounds call doesn't work,
        // so add a small delay to increase the changes of it working. Not an
        // ideal solution, but the UX is nice and it has worked in all my
        // testing.
        await Future.delayed(
          const Duration(seconds: 1),
          () async => await _mapController?.animateToBounds(
              _trail.mapBounds, screenHeight),
        );
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
        : TimeManager.get.currentTimestamp;
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
