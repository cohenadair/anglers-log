import 'package:mobile/map/camera_position.dart';

class CameraUpdate {
  static CameraPosition newCameraPosition(CameraPosition position) {
    return CameraPosition(target: position.target, zoom: position.zoom);
  }
}
