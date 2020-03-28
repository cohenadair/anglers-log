import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/fishing_spot_map.dart';
import 'package:mobile/widgets/widget.dart';

class FishingSpotPickerPage extends StatefulWidget {
  final void Function(BuildContext, FishingSpot) onPicked;

  FishingSpotPickerPage({
    @required this.onPicked,
  }) : assert(onPicked != null);

  @override
  _FishingSpotPickerPageState createState() => _FishingSpotPickerPageState();
}

class _FishingSpotPickerPageState extends State<FishingSpotPickerPage> {
  Completer<GoogleMapController> _mapController = Completer();

  FishingSpot _fishingSpot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildCurrentSpot(),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FishingSpotMap(
      mapController: _mapController,
      currentLocation: LocationMonitor.of(context).currentLocation,
      searchBar: FishingSpotMapSearchBar(
        leading: BackButton(),
        trailing: ActionButton(
          text: Strings.of(context).next,
          textColor: Theme.of(context).primaryColor,
          onPressed: () => widget.onPicked(context, _fishingSpot),
        ),
        onFishingSpotPicked: (fishingSpot) {
          if (fishingSpot != _fishingSpot) {
            setState(() {
              _fishingSpot = fishingSpot;
            });
          }
        },
      ),
    );
  }

  Widget _buildCurrentSpot() {
    Widget name;
    Widget coordinates;
    if (_fishingSpot == null) {
      name = Empty();
      coordinates = Text(Strings.of(context).fishingSpotPickerPageHint);
    } else {
      name = Text(_fishingSpot.name, style: styleHeading);
      coordinates = Text(formatLatLng(
        context: context,
        lat: _fishingSpot.lat,
        lng: _fishingSpot.lng,
      ));
    }

    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(
          left: paddingDefault,
          right: paddingDefault,
          bottom: paddingSmall,
        ),
        padding: insetsDefault,
        decoration: FloatingBoxDecoration.rectangle(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            name,
            coordinates,
          ],
        ),
      ),
    );
  }
}