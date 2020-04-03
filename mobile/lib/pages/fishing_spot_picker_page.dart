import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/pages/save_fishing_spot_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/fishing_spot_map.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class FishingSpotPickerPage extends StatefulWidget {
  final void Function(BuildContext, FishingSpot) onPicked;

  FishingSpotPickerPage({
    @required this.onPicked,
  }) : assert(onPicked != null);

  @override
  _FishingSpotPickerPageState createState() => _FishingSpotPickerPageState();
}

class _FishingSpotPickerPageState extends State<FishingSpotPickerPage>
    with SingleTickerProviderStateMixin
{
  static final _pendingMarkerSize = 40.0;
  static final _pendingMarkerAnimOffset = _pendingMarkerSize * 3;

  final _pendingMarkerSlideInDelay = Duration(milliseconds: 1000);
  final _pendingMarkerSlideInDuration = Duration(milliseconds: 150);

  final Completer<GoogleMapController> _mapController = Completer();

  AnimationController _fishingSpotAnimController;
  Animation<Offset> _fishingSpotAnimOffset;

  Map<FishingSpot, Marker> _fishingSpotMarkerMap = {};

  /// The selected fishing spot when it exists in the database.
  FishingSpot _fishingSpot;

  /// A [FishingSpot] object that doesn't exist in the database, but is
  /// currently showing on the map.
  FishingSpot _pendingFishingSpot;

  /// The last set fishing spot. Used for dismiss animations.
  FishingSpot _lastFishingSpot;

  LatLng _currentPosition;

  /// The color of the centered icon that represents the "bulls eye" of the map.
  Color _targetColor = Colors.black;

  /// Set to true a fishing spot is selected, either via tapping a marker, or
  /// by searching. Set to false when the map becomes idle.
  bool _didSelectFishingSpot = false;

  /// True when the map is animating or being dragged by the user; false
  /// otherwise.
  bool _isMoving = false;

  double _pendingMarkerOffset = _pendingMarkerAnimOffset;

  bool get _hasFishingSpot => _fishingSpot != null;
  bool get _hasPendingFishingSpot => _pendingFishingSpot != null;

  bool get _fishingSpotShowing => _fishingSpotAnimController.isCompleted;

  @override
  void initState() {
    super.initState();

    _fishingSpotAnimController = AnimationController(
      vsync: this,
      duration: _pendingMarkerSlideInDuration,
    );

    _fishingSpotAnimOffset = Tween<Offset>(
      begin: Offset(0.0, 2.0),
      end: Offset.zero,
    ).animate(_fishingSpotAnimController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FishingSpotsBuilder(
            onUpdate: (fishingSpots) {
              for (var fishingSpot in fishingSpots) {
                Marker marker = Marker(
                  markerId: MarkerId(fishingSpot.id),
                  position: fishingSpot.latLng,
                  onTap: () {
                    _selectFishingSpot(fishingSpot);
                  }
                );
                _fishingSpotMarkerMap.update(fishingSpot, (_) => marker,
                    ifAbsent: () => marker);
              }
            },
            builder: (context) => _buildMap(context),
          ),
          _buildPendingFishingSpotMarker(),
          Visibility(
            visible: !_hasFishingSpot && !_hasPendingFishingSpot,
            child: Align(
              alignment: Alignment.center,
              child: Icon(Icons.add,
                color: _targetColor,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildCurrentSpot(),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    return FishingSpotMap(
      mapController: _mapController,
      currentLocation: LocationMonitor.of(context).currentLocation,
      markers: _fishingSpotMarkerMap.values.toSet(),
      onIdle: () {
        _isMoving = false;
        _didSelectFishingSpot = false;

        // An existing fishing spot was selected, don't create a "pending"
        // fishing spot.
        if (_hasFishingSpot) {
          return;
        }

        _mapController.future.then((controller) {
          _updatePendingFishingSpot(FishingSpot(
            lat: _currentPosition.latitude,
            lng: _currentPosition.longitude,
          ));
        });
      },
      onMove: (latLng) {
        _currentPosition = latLng;
      },
      onMoveStarted: () {
        setState(() {
          if (!_didSelectFishingSpot) {
            _fishingSpot = null;
            _fishingSpotAnimController.reverse();
          }
          _clearPendingFishingSpot();
          _isMoving = true;
        });
      },
      onMapTypeChanged: (mapType) {
        setState(() {
          _targetColor = mapType == MapType.normal || mapType == MapType.terrain
              ? Colors.black : Colors.white;
        });
      },
      searchBar: FishingSpotMapSearchBar(
        leading: BackButton(),
        trailing: Padding(
          padding: insetsRightWidgetSmall,
          child: ActionButton(
            condensed: true,
            text: Strings.of(context).next,
            textColor: Theme.of(context).primaryColor,
            onPressed: () {
              widget.onPicked(context, _fishingSpot ?? _pendingFishingSpot);
            },
          ),
        ),
        onFishingSpotPicked: (fishingSpot) {
          if (fishingSpot != null && fishingSpot != _fishingSpot) {
            _selectFishingSpot(fishingSpot);
          }
        },
      ),
      help: Text(Strings.of(context).fishingSpotPickerPageHint,
        style: styleLight,
      ),
    );
  }

  Widget _buildCurrentSpot() {
    FishingSpot fishingSpot =
        _fishingSpot ?? _pendingFishingSpot ?? _lastFishingSpot;

    if (fishingSpot == null) {
      return Empty();
    }

    Widget name = Empty();
    if (isNotEmpty(fishingSpot.name)) {
      name = Padding(
        padding: insetsRightDefault,
        child: Text(fishingSpot.name, style: styleHeading),
      );
    }

    Widget coordinates = Padding(
      padding: insetsRightDefault,
      child: Text(formatLatLng(
        context: context,
        lat: fishingSpot.lat,
        lng: fishingSpot.lng,
      )),
    );

    Widget moreButton = Padding(
      padding: insetsRightWidgetSmall,
      child: ActionButton.edit(
        condensed: true,
        textColor: Theme.of(context).primaryColor,
        onPressed: () {
          present(context, SaveFishingSpotPage(
            oldFishingSpot: _fishingSpot ?? _pendingFishingSpot,
            editing: _fishingSpot != null,
            onSave: (updatedFishingSpot) {
              setState(() {
                if (_fishingSpot != null) {
                  _fishingSpot = updatedFishingSpot;
                } else {
                  _pendingFishingSpot = updatedFishingSpot;
                }
              });
            },
          ));
        },
      ),
    );

    return SlideTransition(
      position: _fishingSpotAnimOffset,
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.only(
            top: paddingDefault,
            left: paddingDefault,
            right: paddingDefault,
            bottom: paddingSmall,
          ),
          padding: EdgeInsets.only(
            top: paddingDefault,
            left: paddingDefault,
          ),
          decoration: FloatingBoxDecoration.rectangle(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              name,
              coordinates,
              Align(
                alignment: Alignment.bottomRight,
                child: moreButton,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingFishingSpotMarker() {
    Size screenSize = MediaQuery.of(context).size;
    return AnimatedPositioned(
      duration: _pendingMarkerSlideInDuration,
      top: screenSize.height / 2 - _pendingMarkerOffset,
      left: screenSize.width / 2 - _pendingMarkerSize / 2,
      child: Visibility(
        visible: _hasPendingFishingSpot,
        child: Icon(
          Icons.place,
          size: _pendingMarkerSize,
        ),
      ),
    );
  }

  void _selectFishingSpot(FishingSpot fishingSpot) {
    setState(() {
      _didSelectFishingSpot = true;
      _fishingSpot = fishingSpot;
      _clearPendingFishingSpot();

      if (!_fishingSpotShowing) {
        _fishingSpotAnimController.forward();
      }
    });
  }

  /// Updates the pending fishing spot after a delay. This is so a new marker
  /// isn't animated immediately every time the map finishes moving.
  void _updatePendingFishingSpot(FishingSpot fishingSpot) {
    Future.delayed(_pendingMarkerSlideInDelay, () {
      // Prevents the pending spot from being created if the user briefly
      // pauses dragging.
      if (_isMoving) {
        return;
      }

      setState(() {
        _pendingFishingSpot = fishingSpot;
        _pendingMarkerOffset = _pendingMarkerSize;
        _fishingSpotAnimController.forward();
      });
    });
  }

  void _clearPendingFishingSpot() {
    _pendingFishingSpot = null;
    _pendingMarkerOffset = _pendingMarkerAnimOffset;
  }
}