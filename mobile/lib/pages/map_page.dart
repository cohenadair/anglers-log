import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/pages/save_fishing_spot_page.dart';
import 'package:mobile/res/dimen.dart';
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
  final double _bottomMapPadding = 110;

  final BitmapDescriptor _activeMarkerIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  final BitmapDescriptor _nonActiveMarkerIcon = BitmapDescriptor.defaultMarker;

  Completer<GoogleMapController> _mapController = Completer();

  Set<Marker> _fishingSpotMarkers = Set();
  Marker _activeMarker;

  bool get hasActiveMarker => _activeMarker != null;

  @override
  void initState() {
    super.initState();

    List<FishingSpot> fishingSpots = widget.app.fishingSpotManager.fishingSpots;
    fishingSpots.forEach((f) =>
        _fishingSpotMarkers.add(_createFishingSpotMarker(f)));
  }

  @override
  Widget build(BuildContext context) => Page(
    child: Stack(
      children: <Widget>[
        _buildMap(),
        _buildBottomSheet(),
      ],
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

    FishingSpot fishingSpot = widget.app.fishingSpotManager
        .fishingSpot(_activeMarker.markerId.value);
    if (fishingSpot == null) {
      fishingSpot = FishingSpot(latLng: _activeMarker.position);
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: StyledBottomSheet(
        onDismissed: () {
          _updateActiveMarker(null);
        },
        child: _FishingSpotBottomSheet(
          app: widget.app,
          fishingSpot: fishingSpot,
        )
      ),
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
      if (hasActiveMarker && _fishingSpotMarkers.firstWhere(
          (m) => m.markerId.value == _activeMarker.markerId.value,
          orElse: () => null) != null)
      {
        Marker oldActiveMarker =
            _copyMarker(_activeMarker, _nonActiveMarkerIcon);
        _fishingSpotMarkers.remove(_activeMarker);
        _fishingSpotMarkers.add(oldActiveMarker);
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

  final AppManager app;
  final FishingSpot fishingSpot;

  _FishingSpotBottomSheet({
    @required this.app,
    @required this.fishingSpot,
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

    if (isEmpty(fishingSpot.name)
        && !app.fishingSpotManager.exists(fishingSpot.id))
    {
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
            label: Strings.of(context).save,
            icon: Icons.save,
            onPressed: () {
              push(
                context,
                SaveFishingSpotPage(
                  app: app,
                  oldFishingSpot: fishingSpot,
                ),
                fullscreenDialog: true,
              );
            },
          ),
        ),
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