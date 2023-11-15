import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/pages/details_map_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:protobuf/protobuf.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../widgets/default_mapbox_map.dart';
import '../widgets/input_controller.dart';
import '../widgets/map_target.dart';
import '../widgets/widget.dart';

class EditCoordinatesPage extends StatefulWidget {
  final InputController<FishingSpot> controller;

  const EditCoordinatesPage(this.controller);

  @override
  State<EditCoordinatesPage> createState() => _EditCoordinatesPageState();
}

class _EditCoordinatesPageState extends State<EditCoordinatesPage> {
  MapboxMapController? _mapController;
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
      children: [
        _buildTarget(),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    if (!widget.controller.hasValue) {
      var currentLatLng = _locationMonitor.currentLatLng ?? const LatLng(0, 0);
      widget.controller.value = FishingSpot(
        lat: currentLatLng.latitude,
        lng: currentLatLng.longitude,
      );
    }
  }

  @override
  void dispose() {
    _mapController?.removeListener(_updateTarget);
    super.dispose();
  }

  DefaultMapboxMap _buildMap() {
    return DefaultMapboxMap(
      startPosition: _fishingSpot.latLng,
      onMapCreated: (controller) {
        _mapController = controller;
        _mapController?.addListener(_updateTarget);
      },
      onStyleLoadedCallback: () {
        _mapController
            ?.addSymbol(createSymbolOptions(_fishingSpot, isActive: true))
            .then((value) => _fishingSpotSymbol = value);
      },
      onCameraIdle: _updateFishingSpot,
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
        const VerticalSpace(paddingDefault),
        Text(
          Strings.of(context).editCoordinatesHint,
          style: styleSubtitle(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _updateTarget() {
    var isMoving = _mapController?.isCameraMoving;
    if (isMoving == null) {
      return;
    }

    if (isMoving != _isTargetShowing) {
      setState(() => _isTargetShowing = isMoving);
    }
  }

  void _updateFishingSpot() {
    var latLng = _mapController?.cameraPosition?.target;
    if (latLng == null) {
      // Happens when the map is first loaded.
      return;
    }

    setState(() {
      _isTargetShowing = false;
      widget.controller.value = _fishingSpot.deepCopy()
        ..lat = latLng.latitude
        ..lng = latLng.longitude;
    });

    if (_fishingSpotSymbol != null) {
      _mapController?.updateSymbol(
        _fishingSpotSymbol!,
        SymbolOptions(
          geometry: latLng,
        ),
      );
    }
  }
}
