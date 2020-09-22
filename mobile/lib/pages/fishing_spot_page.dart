import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/fishing_spot_map.dart';
import 'package:mobile/widgets/floating_bottom_container.dart';

class FishingSpotPage extends StatefulWidget {
  final Id fishingSpotId;

  FishingSpotPage(this.fishingSpotId) : assert(fishingSpotId != null);

  @override
  _FishingSpotPageState createState() => _FishingSpotPageState();
}

class _FishingSpotPageState extends State<FishingSpotPage> {
  final Completer<GoogleMapController> _mapController = Completer();

  Color _backButtonColor = Colors.black;

  @override
  void initState() {
    super.initState();

    // TODO: Load from preferences.
    _updateBackButtonColor(MapType.normal);
  }

  @override
  Widget build(BuildContext context) {
    FishingSpot fishingSpot =
        FishingSpotManager.of(context).entity(widget.fishingSpotId);
    assert(fishingSpot != null);

    LatLng latLng = LatLng(fishingSpot.lat, fishingSpot.lng);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: FishingSpotMap(
        mapController: _mapController,
        startLocation: latLng,
        showMyLocationButton: false,
        onMapTypeChanged: (mapType) {
          setState(() {
            _updateBackButtonColor(mapType);
          });
        },
        markers: {
          Marker(
            markerId: MarkerId(fishingSpot.id.uuid),
            position: latLng,
          ),
        },
        children: [
          _buildBackButton(),
          _buildBottomSheet(fishingSpot),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return SafeArea(
      child: Padding(
        padding: insetsMedium,
        child: Material(
          clipBehavior: Clip.antiAlias,
          shape: CircleBorder(),
          color: Colors.transparent,
          child: BackButton(
            color: _backButtonColor,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(FishingSpot fishingSpot) {
    return FloatingBottomContainer(
      title: fishingSpot.name,
      subtitle: formatLatLng(
        context: context,
        lat: fishingSpot.lat,
        lng: fishingSpot.lng,
      ),
    );
  }

  void _updateBackButtonColor(MapType type) {
    switch (type) {
      case MapType.hybrid:
      case MapType.satellite:
        _backButtonColor = Colors.white;
        break;
      case MapType.normal:
      case MapType.terrain:
      case MapType.none:
        _backButtonColor = Colors.black;
        break;
    }
  }
}