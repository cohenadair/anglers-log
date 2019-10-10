import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/page.dart';
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
  Set<Marker> _markers = Set();
  Marker _activeMarker;

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
    myLocationButtonEnabled: false,
    onLongPress: (LatLng latLng) {
      _addMarker(latLng);
    },
  );

  Widget _buildBottomSheet() {
    if (_activeMarker == null) {
      return Empty();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.white,
        padding: insetsDefault,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Wrap(
              direction: Axis.vertical,
              children: <Widget>[
                Text(_activeMarker.position.latitude.toString()),
                Text(_activeMarker.position.longitude.toString()),
              ],
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => _updateActiveMarker(null),
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
    });
  }

  void _updateActiveMarker(Marker marker) {
    setState(() {
      _activeMarker = marker;
    });
  }
}