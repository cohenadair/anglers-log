import 'lat_lng.dart';

class SymbolOptions {
  final String? iconImage;
  final double? iconRotate;
  final double? iconSize;
  final LatLng? geometry; // TODO: Rename?
  final bool draggable;

  const SymbolOptions({
    this.iconImage,
    this.iconRotate,
    this.iconSize,
    this.geometry,
    this.draggable = false,
  });
}
