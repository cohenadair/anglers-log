import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/pages/save_fishing_spot_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/fishing_spot_map.dart';
import 'package:mobile/widgets/styled_bottom_sheet.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Log _log = Log("MapPage");

  final BitmapDescriptor _activeMarkerIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  final BitmapDescriptor _nonActiveMarkerIcon = BitmapDescriptor.defaultMarker;

  Completer<GoogleMapController> _mapController = Completer();

  Set<FishingSpotMarker> _fishingSpotMarkers = Set();
  FishingSpotMarker _activeMarker;

  FishingSpot _activeFishingSpot;

  // Used to display old data during dismiss animations and during async
  // database calls.
  bool _waitingForDismissal = false;

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  bool get _hasActiveMarker => _activeMarker != null;
  bool get _hasActiveFishingSpot => _activeFishingSpot != null;

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: EntityListenerBuilder(
      managers: [ _fishingSpotManager ],
      onUpdate: () {
        _updateMarkers();

        // Reset the active marker and fishing spot, if there was one.
        if (_activeMarker != null) {
          _activeFishingSpot =
              _fishingSpotManager.withLatLng(_activeMarker.fishingSpot);

          Marker newMarker = _fishingSpotMarkers.firstWhere(
            (m) => m.position == _activeMarker.position,
            orElse: () => null,
          );
          _activeMarker = _copyMarker(newMarker, _activeMarkerIcon);
        }
      },
      builder: _buildMap,
    ),
  );

  Widget _buildMap(BuildContext context) {
    Set<Marker> markers = Set.of(_fishingSpotMarkers);
    if (_hasActiveMarker) {
      markers.add(_activeMarker);
    }

    String name;
    if (_hasActiveFishingSpot) {
      // Showing active fishing spot.
      if (isNotEmpty(_activeFishingSpot.name)) {
        name = _activeFishingSpot.name;
      } else {
        name = formatLatLng(
          context: context,
          lat: _activeFishingSpot.lat,
          lng: _activeFishingSpot.lng,
          includeLabels: false,
        );
      }
    } else if (_hasActiveMarker) {
      // A pin was dropped.
      name = Strings.of(context).mapPageDroppedPin;
    }

    return FishingSpotMap(
      markers: markers,
      mapController: _mapController,
      startLocation: LocationMonitor.of(context).currentLocation,
      children: [
        _buildBottomSheet(),
      ],
      searchBar: FishingSpotMapSearchBar(
        title: isEmpty(name) ? null : name,
        trailing: AnimatedVisibility(
          visible: isNotEmpty(name),
          child: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _waitingForDismissal = true;
              });
            },
          ),
        ),
        onFishingSpotPicked: (fishingSpot) {
          // Only reset selection if a new selection was made.
          if (fishingSpot != null) {
            setState(() {
              _setActiveMarker(_findMarker(Id(fishingSpot.id)));
              _activeFishingSpot = fishingSpot;
            });
          }
        }
      ),
      onTap: (latLng) {
        setState(() {
          _setActiveMarker(_createDroppedPinMarker(latLng));
          _activeFishingSpot = null;
          moveMap(_mapController, latLng);
        });
      },
      onCurrentLocationPressed: () => setState(() {
        setState(() {
          _clearActiveFishingSpot();
        });
      }),
    );
  }

  /// Material [BottomSheet] widget doesn't work here because it animates from
  /// the bottom of the screen. We want this bottom sheet to animate from the
  /// bottom of the map.
  Widget _buildBottomSheet() {
    if (!_hasActiveMarker && !_waitingForDismissal) {
      // Use empty container here instead of Empty() so the search bar size is
      // set correctly.
      return Container();
    }

    FishingSpot fishingSpot = _activeFishingSpot;
    bool editing = true;
    if (!_hasActiveFishingSpot && _hasActiveMarker) {
      // Dropped pin case.
      fishingSpot = FishingSpot()
        ..id = Id.random().bytes
        ..lat = _activeMarker.position.latitude
        ..lng = _activeMarker.position.longitude;
      editing = false;
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: StyledBottomSheet(
        visible: fishingSpot != null && !_waitingForDismissal,
        onDismissed: () {
          setState(() {
            _clearActiveFishingSpot();
          });
        },
        child: _FishingSpotBottomSheet(
          fishingSpot: fishingSpot ?? FishingSpot()
            ..id = Id.random().bytes
            ..lat = 0
            ..lng = 0,
          editing: editing,
          onDelete: () {
            setState(() {
              _waitingForDismissal = true;
            });
          },
        ),
      ),
    );
  }

  Marker _createFishingSpotMarker(FishingSpot fishingSpot) {
    if (fishingSpot == null) {
      return null;
    }
    return FishingSpotMarker(
      fishingSpot: fishingSpot,
      active: false,
      onTap: (fishingSpot) {
        setState(() {
          _setActiveMarker(_fishingSpotMarkers.firstWhere((marker) =>
              marker.id == Id(fishingSpot.id)));
          _activeFishingSpot = _fishingSpotManager.entity(_activeMarker.id);
        });
      }
    );
  }

  Marker _createDroppedPinMarker(LatLng latLng) {
    // All dropped pins become active, and shouldn't be clickable.
    return FishingSpotMarker(
      fishingSpot: FishingSpot()
        ..id = Id.random().bytes
        ..lat = latLng.latitude
        ..lng = latLng.longitude,
      active: true,
    );
  }

  void _setActiveMarker(FishingSpotMarker newActiveMarker) {
    // A marker's icon property is readonly, so we rebuild the current active
    // marker to give it a default icon, then remove and add it to the
    // fishing spot markers.
    //
    // This only applies if the active marker belongs to an existing fishing
    // spot. A dropped pin is removed from the map when updating the active
    // marker.
    if (_hasActiveMarker) {
      FishingSpotMarker activeMarker = _findMarker(_activeMarker.id);
      if (activeMarker != null) {
        if (_fishingSpotMarkers.remove(activeMarker)) {
          _fishingSpotMarkers.add(_copyMarker(activeMarker,
              _nonActiveMarkerIcon));
        } else {
          _log.e("Error removing marker");
        }
      }
    }

    // Active marker should always appear on top.
    _activeMarker = _copyMarker(newActiveMarker, _activeMarkerIcon, 1000);
  }

  Marker _copyMarker(FishingSpotMarker marker, BitmapDescriptor icon,
      [double zIndex])
  {
    if (marker == null) {
      return null;
    }

    return Marker(
      markerId: marker.markerId,
      position: marker.position,
      onTap: marker.onTap,
      icon: icon,
      zIndex: zIndex ?? 0.0,
    );
  }

  Marker _findMarker(Id id) {
    return _fishingSpotMarkers.firstWhere((marker) => marker.id == id,
        orElse: () => null);
  }

  void _updateMarkers() {
    _fishingSpotMarkers.clear();
    _fishingSpotManager.list().forEach((f) =>
        _fishingSpotMarkers.add(_createFishingSpotMarker(f)));
  }

  void _clearActiveFishingSpot() {
    _setActiveMarker(null);
    _waitingForDismissal = false;
    _activeFishingSpot = null;
  }
}

/// A widget that shows details of a selected fishing spot.
class _FishingSpotBottomSheet extends StatelessWidget {
  final double _chipHeight = 45;

  /// Note that an [Id] is not used here because the [FishingSpot] being shown
  /// hasn't necessarily been added to [FishingSpotManager] yet.
  final FishingSpot fishingSpot;

  final bool editing;
  final VoidCallback onDelete;

  _FishingSpotBottomSheet({
    @required this.fishingSpot,
    this.editing = false,
    this.onDelete,
  }) : assert(fishingSpot != null);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildName(context),
          Padding(
            padding: insetsHorizontalDefault,
            child: Label(
              formatLatLng(
                context: context,
                lat: fishingSpot.lat,
                lng: fishingSpot.lng,
              ),
              style: styleSecondary,
            ),
          ),
          _buildChips(context),
        ],
      ),
    );
  }

  Widget _buildName(BuildContext context) {
    String name;
    if (isNotEmpty(fishingSpot.name)) {
      // Fishing spot exists, and has a name.
      name = fishingSpot.name;
    } else if (!editing) {
      // A new pin was dropped.
      name = Strings.of(context).mapPageDroppedPin;
    }

    return isEmpty(name) ? Empty() : Padding(
      padding: insetsHorizontalDefault,
      child: Label(
        name,
        style: styleHeading,
      ),
    );
  }

  Widget _buildChips(BuildContext context) {
    FishingSpotManager fishingSpotManager = FishingSpotManager.of(context);

    return Container(
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
                present(
                  context,
                  SaveFishingSpotPage(
                    oldFishingSpotId: Id(fishingSpot.id),
                    editing: editing,
                  ),
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
                  description: Text(fishingSpotManager
                      .deleteMessage(context, fishingSpot)),
                  onDelete: () {
                    onDelete?.call();
                    fishingSpotManager.delete(Id(fishingSpot.id));
                  },
                );
              },
            ),
          ) : Empty(),
          editing ? Padding(
            padding: insetsRightWidgetSmall,
            child: ChipButton(
              label: Strings.of(context).mapPageAddCatch,
              icon: Icons.add,
              onPressed: () {},
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
}