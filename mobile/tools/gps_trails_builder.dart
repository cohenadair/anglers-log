/// Tool used for building and printing code to add a [GpsTrail]
/// created using GeoJSON: https://geojson.io/. This is useful when
/// gathering marketing screenshots to showcase the GPS trails feature.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:uuid/uuid.dart';

// ignore_for_file: avoid_print

void main() {
  var msBetweenPoints = 120000;
  var now = DateTime.now().millisecondsSinceEpoch;
  var json = jsonDecode(File("tools/geojson.json").readAsStringSync());
  var gpsTrail = GpsTrail(
    id: Id()..uuid = const Uuid().v4(),
    startTimestamp: Int64(now),
    endTimestamp:
        Int64((now + (json["features"].length * msBetweenPoints)).toInt()),
  );

  for (var i = 0; i < json["features"].length; i++) {
    var feature = json["features"][i];
    var featureCoordinates = feature["geometry"]["coordinates"];
    var nextCoordinates = i < json["features"].length - 1
        ? json["features"][i + 1]["geometry"]["coordinates"]
        : json["features"][0]["geometry"]["coordinates"];

    gpsTrail.points.add(
      GpsTrailPoint(
        timestamp: Int64(
            (now + json["features"].indexOf(feature) * msBetweenPoints)
                .toInt()),
        lat: featureCoordinates[1],
        lng: featureCoordinates[0],
        heading: _calculateHeading(
          featureCoordinates[1],
          featureCoordinates[0],
          nextCoordinates[1],
          nextCoordinates[0],
        ),
      ),
    );
  }

  print("Add to the end of GpsTrailManager.initialize(), and re-run the app:");
  print(
      "await addOrUpdate(GpsTrail()..mergeFromProto3Json(jsonDecode('${jsonEncode(gpsTrail.toProto3Json())}')));");
}

/// Returns the heading (initial bearing) from [startLat], [startLng] to [endLat], [endLng].
/// The result is in degrees, ranging from 0 to 360.
double _calculateHeading(
  double startLat,
  double startLng,
  double endLat,
  double endLng,
) {
  const toRadians = pi / 180;
  const toDegrees = 180 / pi;

  final lat1 = startLat * toRadians;
  final lat2 = endLat * toRadians;
  final deltaLng = (endLng - startLng) * toRadians;

  final y = sin(deltaLng) * cos(lat2);
  final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLng);
  final bearing = atan2(y, x) * toDegrees;

  return (bearing + 360) % 360; // Normalize to 0–360
}
