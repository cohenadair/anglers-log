import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/styled_bottom_sheet.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:uuid/uuid.dart';

class MapPage extends StatefulWidget {
  final AppManager app;

  MapPage({
    @required this.app,
  }) : assert(app != null);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // TODO: See if GoogleMap functionality has been updated to address this.
  // Unfortunately, the only way to keep the "Google" logo visible when a
  // bottom sheet is showing, it to add manual padding. This will need to be
  // adjusted as the bottom sheet changes size, but it should always be the
  // same height so it shouldn't be a problem.
  final double _bottomMapPadding = 75;

  Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = Set();
  Marker _activeMarker;

  bool get hasActiveMarker => _activeMarker != null;

  @override
  Widget build(BuildContext context) {
    return Page(
      child: Stack(
        children: <Widget>[
          _buildMap(),
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildMap() => GoogleMap(
    markers: _markers,
    initialCameraPosition: CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962),
      zoom: 15,
    ),
    onMapCreated: (GoogleMapController controller) {
      _mapController.complete(controller);
    },
    myLocationButtonEnabled: true,
    myLocationEnabled: true,
    onTap: (LatLng latLng) {
      _addMarker(latLng);
    },
    padding: EdgeInsets.only(
      bottom: hasActiveMarker ? _bottomMapPadding : 0,
    ),
  );

  /// Material [BottomSheet] widget doesn't work here because it animates from
  /// the bottom of the screen. We want this bottom sheet to animate from the
  /// bottom of the map.
  Widget _buildBottomSheet() {
    if (_activeMarker == null) {
      return Empty();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: StyledBottomSheet(
        onDismissed: () => _updateActiveMarker(null),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(_activeMarker.position.latitude.toString()),
                Text(_activeMarker.position.longitude.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addMarker(LatLng latLng) {
    setState(() {
      MarkerId markerId = MarkerId(Uuid().v1().toString());
      _activeMarker = Marker(
        markerId: markerId,
        position: latLng,
        onTap: () => _updateActiveMarker(_markers
            .firstWhere((Marker marker) => marker.markerId == markerId)),
      );
      _markers.add(_activeMarker);

      // Animate the new marker to the middle of the map.
      _mapController.future.then((controller) {
        controller.animateCamera(
            CameraUpdate.newLatLng(_activeMarker.position));
      });
    });
  }

  void _updateActiveMarker(Marker marker) {
    setState(() {
      _activeMarker = marker;
    });
  }
}