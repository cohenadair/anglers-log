import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../fishing_spot_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../res/dimen.dart';
import '../utils/string_utils.dart';
import '../widgets/fishing_spot_map.dart';
import '../widgets/floating_container.dart';

class FishingSpotPage extends StatefulWidget {
  final Id fishingSpotId;

  FishingSpotPage(this.fishingSpotId) : assert(fishingSpotId != null);

  @override
  _FishingSpotPageState createState() => _FishingSpotPageState();
}

class _FishingSpotPageState extends State<FishingSpotPage> {
  static const _mapPadding = EdgeInsets.only(
    bottom: 90,
    left: 8,
  );

  Color _backButtonColor = Colors.black;

  @override
  void initState() {
    super.initState();

    // TODO: Load from preferences.
    _updateBackButtonColor(MapType.normal);
  }

  @override
  Widget build(BuildContext context) {
    var fishingSpot =
        FishingSpotManager.of(context).entity(widget.fishingSpotId);
    assert(fishingSpot != null);

    var latLng = LatLng(fishingSpot.lat, fishingSpot.lng);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: FishingSpotMap(
        mapPadding: _mapPadding,
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
    return FloatingContainer(
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
