import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/pages/save_fishing_spot_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/styled_bottom_sheet.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';
import 'package:uuid/uuid.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Log _log = Log("MapPage");

  // TODO: See if GoogleMap functionality has been updated to address this.
  // Unfortunately, the only way to keep the "Google" logo visible when a
  // bottom sheet is showing, it to add manual padding. This will need to be
  // adjusted as the bottom sheet changes size, but it should always be the
  // same height so it shouldn't be a problem.
  final double _bottomMapPadding = 110;

  final BitmapDescriptor _activeMarkerIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  final BitmapDescriptor _nonActiveMarkerIcon = BitmapDescriptor.defaultMarker;

  Completer<GoogleMapController> _mapController = Completer();

  List<FishingSpot> _fishingSpots;
  Set<Marker> _fishingSpotMarkers = Set();
  Marker _activeMarker;

  bool get hasActiveMarker => _activeMarker != null;

  @override
  Widget build(BuildContext context) => Page(
    child: FishingSpotsBuilder(
      onUpdate: (List<FishingSpot> fishingSpots) {
        _log.d("Reloading fishing spots...");

        _fishingSpotMarkers.clear();
        _fishingSpots = fishingSpots;
        _fishingSpots.forEach((f) =>
            _fishingSpotMarkers.add(_createFishingSpotMarker(f)));

        // Reset the active marker, if there was one.
        if (_activeMarker != null) {
          Marker newMarker = _fishingSpotMarkers.firstWhere(
            (m) => m.position == _activeMarker.position,
            orElse: () => null,
          );
          _activeMarker = _copyMarker(newMarker, _activeMarkerIcon);
        }
      },
      builder: (BuildContext context) {
        return Stack(
          children: <Widget>[
            _buildMap(),
            _buildBottomSheet(),
          ],
        );
      },
    ),
  );

  Widget _buildMap() {
    Set<Marker> markers = Set.of(_fishingSpotMarkers);
    if (hasActiveMarker) {
      markers.add(_activeMarker);
    }

    return GoogleMap(
      markers: markers,
      initialCameraPosition: CameraPosition(
        target: LatLng(37.42796133580664, -122.085749655962),
        zoom: 10,
      ),
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
      },
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      onTap: (LatLng latLng) {
        _addPin(latLng);
      },
      padding: EdgeInsets.only(
        bottom: hasActiveMarker ? _bottomMapPadding : 0,
      ),
    );
  }

  /// Material [BottomSheet] widget doesn't work here because it animates from
  /// the bottom of the screen. We want this bottom sheet to animate from the
  /// bottom of the map.
  Widget _buildBottomSheet() {
    if (_activeMarker == null) {
      return Empty();
    }

    return FutureBuilder<FishingSpot>(
      future: FishingSpotManager.of(context)
          .fetch(id: _activeMarker.markerId.value),
      builder: (BuildContext context, AsyncSnapshot<FishingSpot> snapshot) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: StyledBottomSheet(
            onDismissed: () {
              _updateActiveMarker(null);
            },
            child: _FishingSpotBottomSheet(
              fishingSpot: snapshot.data != null ? snapshot.data : FishingSpot(
                lat: _activeMarker.position.latitude,
                lng: _activeMarker.position.longitude,
              ),
              editing: snapshot.data != null,
            ),
          ),
        );
      },
    );
  }

  Marker _createFishingSpotMarker(FishingSpot fishingSpot) {
    if (fishingSpot == null) {
      return null;
    }
    return _createMarker(fishingSpot.latLng, id: fishingSpot.id);
  }

  Marker _createDroppedPinMarker(LatLng latLng) {
    // All dropped pins become active, and shouldn't be tappable.
    return _createMarker(
      latLng,
      tappable: false,
      icon: _activeMarkerIcon,
    );
  }

  Marker _createMarker(LatLng latLng, {
    String id,
    BitmapDescriptor icon,
    bool tappable = true,
  }) {
    MarkerId markerId = MarkerId(id ?? Uuid().v1().toString());
    return Marker(
      markerId: markerId,
      position: latLng,
      onTap: tappable ? () => _updateActiveMarker(_fishingSpotMarkers
          .firstWhere((Marker marker) => marker.markerId == markerId)) : null,
      icon: icon,
    );
  }

  void _addPin(LatLng latLng) {
    setState(() {
      _updateActiveMarker(_createDroppedPinMarker(latLng));

      // Animate the new marker to the middle of the map.
      _mapController.future.then((controller) {
        controller.animateCamera(CameraUpdate.newLatLng(latLng));
      });
    });
  }

  void _updateActiveMarker(Marker newActiveMarker) {
    setState(() {
      // A marker's icon property is readonly, so we rebuild the current active
      // marker to give it a default icon, then remove and add it to the
      // fishing spot markers.
      //
      // This only applies if the active marker belongs to an existing fishing
      // spot. A dropped pin is removed from the map when updating the active
      // marker.
      if (hasActiveMarker) {
        Marker activeMarker = _fishingSpotMarkers.firstWhere(
          (m) => m.markerId.value == _activeMarker.markerId.value,
          orElse: () => null,
        );

        if (activeMarker != null) {
          if (_fishingSpotMarkers.remove(activeMarker)) {
            _fishingSpotMarkers.add(_copyMarker(activeMarker,
                _nonActiveMarkerIcon));
          } else {
            _log.e("Error removing marker");
          }
        }
      }

      _activeMarker = _copyMarker(newActiveMarker, _activeMarkerIcon);
    });
  }

  Marker _copyMarker(Marker marker, BitmapDescriptor icon) {
    if (marker == null) {
      return null;
    }

    return Marker(
      markerId: marker.markerId,
      position: marker.position,
      onTap: marker.onTap,
      icon: icon,
    );
  }
}

/// A widget that shows details of a selected fishing spot.
class _FishingSpotBottomSheet extends StatelessWidget {
  final double _chipHeight = 45;
  final int _coordinateDecimalPlaces = 6;

  final FishingSpot fishingSpot;
  final bool editing;

  _FishingSpotBottomSheet({
    @required this.fishingSpot,
    this.editing = false,
  }) : assert(fishingSpot != null);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildName(context),
        Padding(
          padding: insetsHorizontalDefault,
          child: Text(format(
            Strings.of(context).fishingSpotBottomSheetLatLngLabel, [
              fishingSpot.lat.toStringAsFixed(_coordinateDecimalPlaces),
              fishingSpot.lng.toStringAsFixed(_coordinateDecimalPlaces),
            ],
          )),
        ),
        _buildChips(context),
      ],
    );
  }

  Widget _buildName(BuildContext context) {
    String name;
    if (isEmpty(fishingSpot.name)) {
      // A new pin was dropped.
      name = Strings.of(context).fishingSpotBottomSheetDroppedPin;
    } else if (isNotEmpty(fishingSpot.name)) {
      // Fishing spot exists, and has a name.
      name = fishingSpot.name;
    }

    return isEmpty(name) ? Empty() : Padding(
      padding: insetsHorizontalDefault,
      child: BoldLabelText(name),
    );
  }

  Widget _buildChips(BuildContext context) => Container(
    height: _chipHeight,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: paddingDefault,
            right: paddingWidgetSmall,
          ),
          child: ChipButton(
            label: editing
                ? Strings.of(context).edit : Strings.of(context).save,
            icon: editing ? Icons.edit : Icons.save,
            onPressed: () {
              push(
                context,
                SaveFishingSpotPage(
                  oldFishingSpot: fishingSpot,
                ),
                fullscreenDialog: true,
              );
            },
          ),
        ),
        editing ? Padding(
          padding: insetsRightWidgetSmall,
          child: ChipButton(
            label: Strings.of(context).delete,
            icon: Icons.delete,
            onPressed: () {
              showDeleteDialog(
                context: context,
                title: Strings.of(context).delete,
                description: format(Strings.of(context)
                    .mapPageDeleteFishingSpot, [fishingSpot.name]),
                onDelete: () {
                  FishingSpotManager.of(context).remove(fishingSpot);
                }
              );
            },
          ),
        ) : Empty(),
        Padding(
          padding: insetsRightDefault,
          child: ChipButton(
            label: Strings.of(context).directions,
            icon: Icons.directions,
            onPressed: () {},
          ),
        ),
      ],
    ),
  );
}