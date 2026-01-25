import '../utils/map_utils.dart';
import 'lat_lng.dart';

class LatLngBounds {
  final LatLng southwest;
  final LatLng northeast;

  LatLngBounds({required this.southwest, required this.northeast})
    : assert(southwest.latitude <= northeast.latitude);

  LatLng get center => LatLng(
    southwest.latitude + (southwest.latitude - northeast.latitude).abs() / 2,
    southwest.longitude + (southwest.longitude - northeast.longitude).abs() / 2,
  );

  LatLngBounds grow(double byMeters) {
    var offset = byMeters / metersPerDegree;
    return LatLngBounds(
      northeast: LatLng(
        northeast.latitude + offset,
        northeast.longitude + offset,
      ),
      southwest: LatLng(
        southwest.latitude - offset,
        southwest.longitude - offset,
      ),
    );
  }

  bool contains(LatLng latLng) {
    return latLng.latitude <= northeast.latitude &&
        latLng.latitude >= southwest.latitude &&
        latLng.longitude <= northeast.longitude &&
        latLng.longitude >= southwest.longitude;
  }

  @override
  bool operator ==(Object other) {
    return other is LatLngBounds &&
        other.southwest == southwest &&
        other.northeast == northeast;
  }

  @override
  int get hashCode => Object.hash(southwest, northeast);
}
