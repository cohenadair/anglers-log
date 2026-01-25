import 'package:mobile/map/lat_lng.dart';

class CameraPosition {
  final LatLng target;
  final double? zoom;
  final double left;
  final double right;
  final double top;
  final double bottom;

  CameraPosition({
    required this.target,
    this.zoom,
    this.left = 0.0,
    this.right = 0.0,
    this.top = 0.0,
    this.bottom = 0.0,
  });
}
