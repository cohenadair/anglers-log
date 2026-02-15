import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/utils/duration.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/utils/page.dart';
import 'package:adair_flutter_lib/widgets/empty_or.dart';
import 'package:flutter/material.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:quiver/strings.dart';

import '../map/map_controller.dart';
import '../model/gen/anglers_log.pb.dart';
import '../utils/string_utils.dart';
import '../widgets/default_mapbox_map.dart';
import 'catch_page.dart';
import 'details_map_page.dart';

class GpsTrailPage extends StatefulWidget {
  final GpsTrail trail;
  final bool isPresented;

  const GpsTrailPage(this.trail, {this.isPresented = false});

  @override
  State<GpsTrailPage> createState() => _GpsTrailPageState();
}

class _GpsTrailPageState extends State<GpsTrailPage> {
  static const mapZoomStart = 16.5;

  final _log = const Log("GpsTrailPage");

  MapController? _mapController;

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

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
      onMapCreated: (controller) async {
        _mapController = controller;
        _mapController?.animateToBounds(_trail.latLngBounds);
        SymbolTrail(
          _mapController,
          _onTapCatch,
        ).draw(context, _trail, includeCatches: true);
      },
    );
  }

  Widget _buildDetails() {
    var bodyOfWaterName = _bodyOfWaterManager.displayNameFromId(
      context,
      _trail.bodyOfWaterId,
    );
    var bodyOfWaterWidget = EmptyOr(
      isShowing: isNotEmpty(bodyOfWaterName),
      builder: (context) =>
          Text(bodyOfWaterName!, style: stylePrimary(context)),
    );

    var timestampWidget = Text(
      _trail.elapsedDisplayValue(context) ?? _trail.startDisplayValue(context),
      style: isEmpty(bodyOfWaterName)
          ? stylePrimary(context)
          : styleSubtitle(context),
    );

    var inProgressWidget = EmptyOr(
      isShowing: _trail.isInProgress,
      builder: (context) => Text(
        Strings.of(context).gpsTrailListPageInProgress,
        style: styleSuccess(
          context,
        ).copyWith(fontSize: styleSubtitle(context).fontSize),
      ),
    );

    var endTimestamp = _trail.hasEndTimestamp()
        ? _trail.endTimestamp.toInt()
        : TimeManager.get.currentTimestamp;
    var durationWidget = Text(
      formatDurations(
        context: context,
        durations: [
          Duration(milliseconds: endTimestamp - _trail.startTimestamp.toInt()),
        ],
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
    var cat = CatchManager.get.entity(id);
    if (cat == null) {
      _log.w("Cannot show catch that doesn't exist");
      return;
    }

    push(context, CatchPage(cat));
  }
}
