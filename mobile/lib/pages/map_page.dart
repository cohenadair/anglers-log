import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/widgets/page.dart';

class MapPage extends StatelessWidget {
  final AppManager app;

  MapPage({
    @required this.app,
  }) : assert(app != null);

  @override
  Widget build(BuildContext context) {
    return Page(
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.42796133580664, -122.085749655962),
          zoom: 15,
        ),
        myLocationButtonEnabled: false,
      ),
    );
  }
}