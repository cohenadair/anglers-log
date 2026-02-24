import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/pages/details_map_page.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/string_utils.dart';

import '../map/map_controller.dart';
import '../model/gen/anglers_log.pb.dart';
import '../widgets/default_mapbox_map.dart';
import '../widgets/input_controller.dart';
import '../widgets/map_target.dart';

class EditCoordinatesPage extends StatefulWidget {
  final InputController<FishingSpot> controller;

  const EditCoordinatesPage(this.controller);

  @override
  State<EditCoordinatesPage> createState() => _EditCoordinatesPageState();
}

class _EditCoordinatesPageState extends State<EditCoordinatesPage> {
  MapController? _mapController;
  bool _isTargetShowing = false;
  Symbol? _fishingSpotSymbol;

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);

  FishingSpot get _fishingSpot => widget.controller.value!;

  @override
  Widget build(BuildContext context) {
    return DetailsMapPage(
      controller: _mapController,
      map: _buildMap(),
      details: _buildCoordinates(),
      children: [_buildTarget()],
    );
  }

  @override
  void initState() {
    super.initState();

    if (!widget.controller.hasValue) {
      var currentLatLng = _locationMonitor.currentLatLng ?? LatLngs.zero;
      widget.controller.value = FishingSpot(
        lat: currentLatLng.lat,
        lng: currentLatLng.lng,
      );
    }
  }

  DefaultMapboxMap _buildMap() {
    return DefaultMapboxMap(
      startPosition: _fishingSpot.latLng,
      onMapCreated: (controller) {
        _mapController = controller;
        _mapController?.onMapMoveCallback = _updateTarget;
        _mapController
            ?.addSymbol(Symbols.fromFishingSpot(_fishingSpot, isActive: true))
            .then((value) => _fishingSpotSymbol = value);
      },
    );
  }

  Widget _buildTarget() {
    return MapTarget(isShowing: _isTargetShowing);
  }

  Widget _buildCoordinates() {
    return Column(
      children: [
        Text(
          formatLatLng(
            context: context,
            lat: _fishingSpot.lat,
            lng: _fishingSpot.lng,
          ),
          style: stylePrimary(context),
        ),
        Container(height: paddingDefault),
        Text(
          Strings.of(context).editCoordinatesHint,
          style: styleSubtitle(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _updateTarget() {
    if (_mapController?.isCameraMoving ?? false) {
      setState(() => _isTargetShowing = true);
    } else {
      _updateFishingSpot();
    }
  }

  Future<void> _updateFishingSpot() async {
    final camera = await _mapController?.cameraPosition();
    if (camera == null) {
      return;
    }

    setState(() {
      _isTargetShowing = false;
      widget.controller.value = _fishingSpot.deepCopy()
        ..lat = camera.latLng.lat
        ..lng = camera.latLng.lng;
    });

    if (_fishingSpotSymbol == null) {
      return;
    }

    _fishingSpotSymbol = await _mapController?.updateSymbol(
      _fishingSpotSymbol!.deepCopy()..options.latLng = camera.latLng,
    );
  }
}
