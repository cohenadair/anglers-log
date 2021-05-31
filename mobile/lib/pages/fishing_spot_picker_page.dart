import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quiver/strings.dart';

import '../entity_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../location_monitor.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/save_fishing_spot_page.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/device_utils.dart';
import '../utils/map_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/button.dart';
import '../widgets/fishing_spot_map.dart';
import '../widgets/floating_container.dart';
import '../widgets/widget.dart';

class FishingSpotPickerPage extends StatefulWidget {
  final void Function(BuildContext, FishingSpot?) onPicked;
  final Id? fishingSpotId;

  /// The start position of the map if [fishingSpotId] is null, or if a
  /// fishing spot with [fishingSpotId] doesn't exist. If [fishingSpotId] and
  /// [startPos] are both null, the device's current location is used.
  final LatLng? startPos;

  /// The text to signal that picking is finished. When tapped, [onPicked] is
  /// invoked. If null or empty, [onPicked] is invoked when this
  /// [FishingSpotPickerPage] is popped from the navigation stack.
  final String? actionButtonText;

  FishingSpotPickerPage({
    required this.onPicked,
    this.fishingSpotId,
    this.startPos,
    this.actionButtonText,
  });

  @override
  _FishingSpotPickerPageState createState() => _FishingSpotPickerPageState();
}

class _FishingSpotPickerPageState extends State<FishingSpotPickerPage>
    with SingleTickerProviderStateMixin {
  static final _pendingMarkerSize = 40.0;
  static final _pendingMarkerAnimOffset = _pendingMarkerSize * 3;

  /// If a spot is picked and there already exists a spot within this radius,
  /// the existing spot is automatically selected.
  static final _duplicateSpotRadiusMeters = 5;

  final _pendingMarkerSlideInDelay = Duration(milliseconds: 1000);

  final Completer<GoogleMapController> _mapController = Completer();

  late AnimationController _fishingSpotAnimController;
  late Animation<Offset> _fishingSpotAnimOffset;
  double _pendingMarkerOffset = _pendingMarkerAnimOffset;

  final Map<FishingSpot, Marker> _fishingSpotMarkerMap = {};

  /// The selected fishing spot ID.
  Id? _currentFishingSpotId;

  /// True if a "pending" fishing spot is showing on the map.
  bool _isFishingSpotPending = false;

  /// Updated as the map moves.
  late LatLng _currentPosition;
  LatLng? _startPosition;

  /// The color of the centered icon that represents the "bulls eye" of the map.
  /// Color will change based on [MapType].
  Color _targetColor = Colors.black;

  /// Set to true a fishing spot is selected, either via tapping a marker, or
  /// by searching. Set to false when the map becomes idle.
  bool _didSelectFishingSpot = false;

  /// True when the map is animating or being dragged by the user; false
  /// otherwise.
  bool _isMoving = false;

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  /// True if coordinates are selected, whether it's a real fishing spot, or a
  /// pending fishing spot.
  bool get _hasLocationSelected =>
      _currentFishingSpotId != null || _isFishingSpotPending;

  bool get _isBottomSheetShowing => _fishingSpotAnimController.isCompleted;

  @override
  void initState() {
    super.initState();

    _fishingSpotAnimController = AnimationController(
      vsync: this,
      duration: defaultAnimationDuration,
    );

    _fishingSpotAnimOffset = Tween<Offset>(
      begin: Offset(0.0, 2.0),
      end: Offset.zero,
    ).animate(_fishingSpotAnimController);

    _startPosition =
        widget.startPos ?? LocationMonitor.of(context).currentLocation;

    // TODO #390: Initial 2 map drag attempts do not work when _startPosition
    //  is set to _currentFishingSpot
    // Show fishing spot widgets if the picker is shown with a fishing spot
    // selected.
    var fishingSpot = _fishingSpotManager.entity(widget.fishingSpotId) ??
        _fishingSpotManager.withinRadius(_startPosition);
    if (fishingSpot != null) {
      _fishingSpotAnimController.value = _fishingSpotAnimController.upperBound;
      _pendingMarkerOffset = _pendingMarkerSize;
      _currentFishingSpotId = fishingSpot.id;
      _isFishingSpotPending = false;
      _startPosition = fishingSpot.latLng;
    }

    if (_startPosition != null) {
      _currentPosition = _startPosition!;
    }
  }

  @override
  void dispose() {
    _fishingSpotAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder(
      managers: [_fishingSpotManager],
      builder: (context) {
        _updateMarkers();
        return WillPopScope(
          onWillPop: () {
            if (isEmpty(widget.actionButtonText)) {
              _finishPicking();
            }
            return Future.value(true);
          },
          child: Scaffold(
            body: _buildMap(),
          ),
        );
      },
    );
  }

  Widget _buildMap() {
    return FishingSpotMap(
      mapController: _mapController,
      startLocation: _startPosition,
      markers: _fishingSpotMarkerMap.values.toSet(),
      children: [
        _buildPendingFishingSpotMarker(),
        Visibility(
          visible: !_hasLocationSelected,
          child: Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.add,
              color: _targetColor,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _buildCurrentSpot(),
        ),
      ],
      onIdle: () {
        _isMoving = false;
        _didSelectFishingSpot = false;

        // An existing fishing spot was selected, don't update to a "pending"
        // fishing spot.
        if (_currentFishingSpotId != null) {
          return;
        }

        _mapController.future.then((controller) {
          /// Updates the pending fishing spot after a delay. This is so a new
          /// marker isn't animated immediately every time the map finishes
          /// moving.
          Future.delayed(_pendingMarkerSlideInDelay, () {
            // Prevents the pending spot from being created if the user briefly
            // pauses dragging.
            if (_isMoving) {
              return;
            }

            // The map was moved to a spot extremely close to an existing
            // fishing spot. Select it instead of creating a new one.
            var existingSpot = _fishingSpotManager.withinRadius(
                _currentPosition, _duplicateSpotRadiusMeters);
            if (existingSpot == null) {
              setState(() {
                _isFishingSpotPending = true;
                _pendingMarkerOffset = _pendingMarkerSize;
                _fishingSpotAnimController.forward();
              });
            } else {
              _selectFishingSpot(existingSpot);
            }
          });
        });
      },
      onMove: (latLng) => _currentPosition = latLng,
      onMoveStarted: () {
        setState(() {
          if (!_didSelectFishingSpot) {
            _currentFishingSpotId = null;
            _isFishingSpotPending = false;
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
              ? Colors.black
              : Colors.white;
        });
      },
      searchBar: FishingSpotMapSearchBar(
        selectedFishingSpot: _fishingSpotManager.entity(_currentFishingSpotId),
        leading: BackButton(),
        trailing: isEmpty(widget.actionButtonText)
            ? null
            : Padding(
                padding: insetsRightWidgetSmall,
                child: ActionButton(
                  condensed: true,
                  text: widget.actionButtonText,
                  textColor: Theme.of(context).primaryColor,
                  onPressed: _hasLocationSelected ? _finishPicking : null,
                ),
              ),
        onFishingSpotPicked: (fishingSpot) {
          if (fishingSpot == null) {
            // "None" was picked.
            widget.onPicked(context, null);
          } else if (fishingSpot.id != _currentFishingSpotId) {
            _selectFishingSpot(fishingSpot);
          }
        },
      ),
      help: Text(
        Strings.of(context).fishingSpotPickerPageHint,
        style: styleLight,
      ),
    );
  }

  Widget _buildCurrentSpot() {
    if (!_hasLocationSelected) {
      return Empty();
    }

    Widget editButton = Padding(
      padding: insetsRightWidgetSmall,
      child: ActionButton.edit(
        condensed: true,
        textColor: Theme.of(context).primaryColor,
        onPressed: () {
          if (_isFishingSpotPending) {
            present(
              context,
              SaveFishingSpotPage(
                latLng: _currentPosition,
                onSave: _selectFishingSpot,
              ),
            );
          } else {
            present(
              context,
              SaveFishingSpotPage.edit(
                  _fishingSpotManager.entity(_currentFishingSpotId)),
            );
          }
        },
      ),
    );

    var fishingSpot = _fishingSpotManager.entity(_currentFishingSpotId);
    return SlideTransition(
      position: _fishingSpotAnimOffset,
      child: SafeArea(
        child: FloatingContainer(
          title: fishingSpot?.name,
          subtitle: formatLatLng(
            context: context,
            lat: fishingSpot?.lat ?? _currentPosition.latitude,
            lng: fishingSpot?.lng ?? _currentPosition.longitude,
          ),
          margin: EdgeInsets.only(
            top: paddingDefault,
            left: paddingDefault,
            right: paddingDefault,
            bottom: hasBottomSafeArea(context) ? paddingSmall : paddingDefault,
          ),
          children: [
            Align(
              alignment: Alignment.bottomRight,
              child: editButton,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingFishingSpotMarker() {
    var screenSize = MediaQuery.of(context).size;
    return AnimatedPositioned(
      duration: defaultAnimationDuration,
      top: screenSize.height / 2 - _pendingMarkerOffset,
      left: screenSize.width / 2 - _pendingMarkerSize / 2,
      child: Visibility(
        visible: _isFishingSpotPending,
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
      _currentFishingSpotId = fishingSpot.id;
      _isFishingSpotPending = false;
      _pendingMarkerOffset = _pendingMarkerAnimOffset;

      if (!_isBottomSheetShowing) {
        _fishingSpotAnimController.forward();
      }

      _updateMarkers();
    });
  }

  void _updateMarkers() {
    var fishingSpots = _fishingSpotManager.list();
    if (fishingSpots.isEmpty) {
      fishingSpots = List.from(_fishingSpotMarkerMap.keys);
    }

    _fishingSpotMarkerMap.clear();
    for (var fishingSpot in fishingSpots) {
      Marker marker = FishingSpotMarker(
        fishingSpot: fishingSpot,
        onTapFishingSpot: _selectFishingSpot,
        active: fishingSpot.id == _currentFishingSpotId,
      );
      _fishingSpotMarkerMap.update(fishingSpot, (_) => marker,
          ifAbsent: () => marker);
    }
  }

  void _finishPicking() {
    var pickedSpot = _fishingSpotManager.entity(_currentFishingSpotId);

    // A new fishing spot was picked, but not saved via "EDIT" bottom sheet
    // action; add the picked spot here.
    if (pickedSpot == null) {
      pickedSpot = FishingSpot()
        ..id = randomId()
        ..lat = _currentPosition.latitude
        ..lng = _currentPosition.longitude;
      _fishingSpotManager.addOrUpdate(pickedSpot);
    }

    widget.onPicked(context, pickedSpot);
  }
}
