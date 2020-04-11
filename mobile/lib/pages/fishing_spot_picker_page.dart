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
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/fishing_spot_map.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class FishingSpotPickerPage extends StatefulWidget {
  final void Function(BuildContext, FishingSpot) onPicked;
  final FishingSpot fishingSpot;
  final String doneButtonText;

  FishingSpotPickerPage({
    @required this.onPicked,
    this.fishingSpot,
    this.doneButtonText,
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
  double _pendingMarkerOffset = _pendingMarkerAnimOffset;

  Map<FishingSpot, Marker> _fishingSpotMarkerMap = {};

  /// The selected fishing spot.
  FishingSpot _currentFishingSpot;

  /// Updated as the map moves.
  LatLng _currentPosition;
  LatLng _startPosition;

  /// The color of the centered icon that represents the "bulls eye" of the map.
  /// Color will change based on [MapType].
  Color _targetColor = Colors.black;

  /// Set to true a fishing spot is selected, either via tapping a marker, or
  /// by searching. Set to false when the map becomes idle.
  bool _didSelectFishingSpot = false;

  /// True when the map is animating or being dragged by the user; false
  /// otherwise.
  bool _isMoving = false;

  bool get _hasFishingSpot => _currentFishingSpot != null;
  bool get _fishingSpotShowing => _fishingSpotAnimController.isCompleted;
  bool get _fishingSpotInDatabase =>
      _fishingSpotMarkerMap.containsKey(_currentFishingSpot);

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

    _startPosition = LocationMonitor.of(context).currentLocation;

    // Show fishing spot widgets if the picker is shown with a fishing spot
    // selected.
    if (widget.fishingSpot != null) {
      _fishingSpotAnimController.value = _fishingSpotAnimController.upperBound;
      _pendingMarkerOffset = _pendingMarkerSize;
      _currentFishingSpot = widget.fishingSpot;
      _startPosition = widget.fishingSpot.latLng;
    }

    _currentPosition = _startPosition;
  }

  @override
  void dispose() {
    _fishingSpotAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FishingSpotsBuilder(
      onUpdate: (fishingSpots) => _updateMarkers(fishingSpots),
      builder: (context) => Scaffold(
        body: Stack(
          children: [
            _buildMap(),
            _buildPendingFishingSpotMarker(),
            Visibility(
              visible: !_hasFishingSpot,
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
          ]
        ),
      ),
    );
  }

  Widget _buildMap() {
    return FishingSpotMap(
      mapController: _mapController,
      startLocation: _startPosition,
      markers: _fishingSpotMarkerMap.values.toSet(),
      onIdle: () {
        _isMoving = false;
        _didSelectFishingSpot = false;

        // An existing fishing spot was selected, don't update to a "pending"
        // fishing spot.
        if (_hasFishingSpot || _fishingSpotInDatabase) {
          return;
        }

        _mapController.future.then((controller) {
          FishingSpot spot = FishingSpot(
            lat: _currentPosition.latitude,
            lng: _currentPosition.longitude,
          );
          _updateFishingSpotDelayed(spot);
        });
      },
      onMove: (latLng) {
        _currentPosition = latLng;
      },
      onMoveStarted: () {
        setState(() {
          if (!_didSelectFishingSpot) {
            _currentFishingSpot = null;
            _fishingSpotAnimController.reverse();
            _updateMarkers();
          }
          _pendingMarkerOffset = _pendingMarkerAnimOffset;
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
            text: widget.doneButtonText ?? Strings.of(context).done,
            textColor: Theme.of(context).primaryColor,
            onPressed: _hasFishingSpot ? () {
              widget.onPicked(context, _currentFishingSpot);
            } : null,
          ),
        ),
        onFishingSpotPicked: (fishingSpot) {
          if (fishingSpot != null && fishingSpot != _currentFishingSpot) {
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
    if (_currentFishingSpot == null) {
      return Empty();
    }

    Widget name = Empty();
    if (isNotEmpty(_currentFishingSpot.name)) {
      name = Padding(
        padding: insetsRightDefault,
        child: Text(_currentFishingSpot.name, style: styleHeading),
      );
    }

    Widget coordinates = Padding(
      padding: insetsRightDefault,
      child: Text(formatLatLng(
        context: context,
        lat: _currentFishingSpot.lat,
        lng: _currentFishingSpot.lng,
      )),
    );

    Widget editButton = Padding(
      padding: insetsRightWidgetSmall,
      child: ActionButton.edit(
        condensed: true,
        textColor: Theme.of(context).primaryColor,
        onPressed: () {
          present(context, SaveFishingSpotPage(
            oldFishingSpot: _currentFishingSpot,
            editing: _currentFishingSpot != null,
            onSave: (updatedFishingSpot) {
              setState(() {
                _currentFishingSpot = updatedFishingSpot;
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
                child: editButton,
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
        visible: _hasFishingSpot && !_fishingSpotInDatabase,
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
      _currentFishingSpot = fishingSpot;
      _pendingMarkerOffset = _pendingMarkerAnimOffset;

      if (!_fishingSpotShowing) {
        _fishingSpotAnimController.forward();
      }

      _updateMarkers();
    });
  }

  /// Updates the pending fishing spot after a delay. This is so a new marker
  /// isn't animated immediately every time the map finishes moving.
  void _updateFishingSpotDelayed(FishingSpot fishingSpot) {
    Future.delayed(_pendingMarkerSlideInDelay, () {
      // Prevents the pending spot from being created if the user briefly
      // pauses dragging.
      if (_isMoving) {
        return;
      }

      setState(() {
        _currentFishingSpot = fishingSpot;
        _pendingMarkerOffset = _pendingMarkerSize;
        _fishingSpotAnimController.forward();
      });
    });
  }

  void _updateMarkers([List<FishingSpot> fishingSpots]) {
    if (fishingSpots == null || fishingSpots.isEmpty) {
      fishingSpots = List.from(_fishingSpotMarkerMap.keys);
    }

    _fishingSpotMarkerMap.clear();
    for (var fishingSpot in fishingSpots) {
      Marker marker = FishingSpotMarker(
        fishingSpot: fishingSpot,
        onTap: _selectFishingSpot,
        active: fishingSpot == _currentFishingSpot,
      );
      _fishingSpotMarkerMap.update(fishingSpot, (_) => marker,
          ifAbsent: () => marker);
    }
  }
}