import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/pages/save_fishing_spot_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/snackbar_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/no_results.dart';
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

  final BitmapDescriptor _activeMarkerIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  final BitmapDescriptor _nonActiveMarkerIcon = BitmapDescriptor.defaultMarker;

  Completer<GoogleMapController> _mapController = Completer();

  Set<Marker> _fishingSpotMarkers = Set();
  Marker _activeMarker;

  FishingSpot _activeFishingSpot;

  // Used to display old data during dismiss animations and during async
  // database calls.
  FishingSpot _lastActiveFishingSpot;
  bool _waitingForFuture = false;
  bool _waitingForDismissal = false;

  // Cache future so we don't make redundant database calls.
  Future<FishingSpot> _activeFishingSpotFuture = Future.value(null);

  MapType _mapType = MapType.normal;

  bool get _hasActiveMarker => _activeMarker != null;
  bool get _hasActiveFishingSpot => _activeFishingSpot != null;
  bool get _hasLastActiveFishingSpot => _lastActiveFishingSpot != null;

  @override
  Widget build(BuildContext context) => Page(
    child: FishingSpotsBuilder(
      onUpdate: (List<FishingSpot> fishingSpots) {
        _log.d("Reloading fishing spots...");

        _fishingSpotMarkers.clear();
        fishingSpots.forEach((f) =>
            _fishingSpotMarkers.add(_createFishingSpotMarker(f)));

        // Reset the active marker and fishing spot, if there was one.
        if (_activeMarker != null) {
          FishingSpot activeFishingSpot = fishingSpots.firstWhere(
            (FishingSpot fishingSpot) =>
                fishingSpot.latLng == _activeMarker.position,
            orElse: () => null,
          );
          if (activeFishingSpot != null) {
            _activeFishingSpotFuture = Future.value(activeFishingSpot);
          }

          Marker newMarker = _fishingSpotMarkers.firstWhere(
            (m) => m.position == _activeMarker.position,
            orElse: () => null,
          );
          _activeMarker = _copyMarker(newMarker, _activeMarkerIcon);
        }
      },
      builder: (BuildContext context) => Stack(
        children: <Widget>[
          _buildMap(),
          FutureBuilder<FishingSpot>(
            future: _activeFishingSpotFuture,
            builder: (BuildContext context, AsyncSnapshot<FishingSpot> snapshot)
            {
              if (snapshot.connectionState == ConnectionState.none
                  || snapshot.connectionState == ConnectionState.done)
              {
                _activeFishingSpot = snapshot.data;
                if (_activeFishingSpot != null) {
                  _lastActiveFishingSpot = _activeFishingSpot;
                }
                _waitingForFuture = false;
              } else {
                _waitingForFuture = true;
              }

              return Stack(
                children: <Widget>[
                  _buildFloatingWidgets(),
                  _buildBottomSheet(),
                ],
              );
            },
          ),
        ],
      )
    ),
  );

  Widget _buildMap() {
    Set<Marker> markers = Set.of(_fishingSpotMarkers);
    if (_hasActiveMarker) {
      markers.add(_activeMarker);
    }

    LatLng currentLocation = LocationMonitor.of(context).currentLocation;

    // TODO: Move Google logo when better solution is available.
    // https://github.com/flutter/flutter/issues/39610
    return GoogleMap(
      mapType: _mapType,
      markers: markers,
      initialCameraPosition: CameraPosition(
        target: currentLocation == null ? LatLng(0.0, 0.0) : currentLocation,
        zoom: currentLocation == null ? 0 : 15,
      ),
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
      },
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      // TODO: Try onLongPress again when Google Maps updated.
      // Log presses weren't being triggered first time.
      onTap: (LatLng latLng) {
        setState(() {
          _setActiveMarker(_createDroppedPinMarker(latLng));
          _activeFishingSpotFuture = Future.value(null);
          _animateCamera(latLng);
        });
      },
    );
  }

  Widget _buildFloatingWidgets() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _buildSearchBar(),
          FloatingIconButton(
            icon: Icons.layers,
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                useRootNavigator: true,
                context: context,
                builder: (BuildContext context) {
                  return MapTypeBottomSheet(
                    currentMapType: _mapType,
                    onMapTypeSelected: (MapType newMapType) {
                      if (newMapType != _mapType) {
                        setState(() {
                          _mapType = newMapType;
                        });
                      }
                    },
                  );
                },
              );
            },
          ),
          FloatingIconButton(
            padding: insetsHorizontalDefault,
            icon: Icons.my_location,
            onPressed: () {
              LatLng currentLocation =
                  LocationMonitor.of(context).currentLocation;
              if (currentLocation == null) {
                showErrorSnackBar(context,
                    Strings.of(context).mapPageErrorGettingLocation);
              } else {
                _animateCamera(currentLocation);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    String name;
    if (_hasActiveMarker && _hasLastActiveFishingSpot && _waitingForFuture) {
      // Active fishing spot is being updated.
      name = _lastActiveFishingSpot.name;
    } else if (_hasActiveMarker && _hasActiveFishingSpot) {
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

    return AppBar(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      title: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: boxShadowSmallBottom,
          borderRadius: BorderRadius.all(
            Radius.circular(floatingCornerRadius),
          ),
        ),
        // Wrap InkWell in a Material widget so the fill animation is shown
        // on top of the parent Container widget.
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              FishingSpot result = await showSearch(
                context: context,
                delegate: _SearchDelegate(
                  searchFieldLabel: Strings.of(context).mapPageSearchHint,
                ),
              );
              // Only reset selection if a new selection was made.
              if (result != null) {
                setState(() {
                  _setActiveMarker(_findMarker(result.id));
                  _activeFishingSpotFuture = Future.value(result);
                  _moveCamera(result.latLng);
                });
              }
            },
            child: Padding(
              padding: EdgeInsets.only(
                top: paddingMedium,
                bottom: paddingMedium,
                left: paddingDefault,
                right: paddingDefault,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.search),
                        SizedBox(width: paddingWidget),
                        LabelText(isEmpty(name)
                            ? Strings.of(context).mapPageSearchHint : name),
                      ],
                    ),
                  ),
                  Visibility(
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: true,
                    visible: isNotEmpty(name),
                    child: MinimumIconButton(
                      icon: Icons.clear,
                      onTap: () {
                        setState(() {
                          _waitingForDismissal = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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

    bool editing = true;
    if (!_hasActiveFishingSpot && _hasActiveMarker) {
      // Dropped pin case.
      _lastActiveFishingSpot = FishingSpot(
        lat: _activeMarker.position.latitude,
        lng: _activeMarker.position.longitude,
      );
      editing = false;
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: StyledBottomSheet(
        visible: _hasActiveMarker && !_waitingForDismissal,
        onDismissed: () {
          setState(() {
            _setActiveMarker(null);
            _waitingForDismissal = false;
            _activeFishingSpotFuture = Future.value(null);
          });
        },
        child: _FishingSpotBottomSheet(
          fishingSpot: _lastActiveFishingSpot ?? FishingSpot(lat: 0, lng: 0),
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
      onTap: !tappable ? null : () {
        setState(() {
          _setActiveMarker(_fishingSpotMarkers
              .firstWhere((Marker marker) => marker.markerId == markerId));
          _activeFishingSpotFuture = FishingSpotManager.of(context)
              .fetch(id: _activeMarker.markerId.value);
        });
      },
      icon: icon,
    );
  }

  void _animateCamera(LatLng latLng) {
    _mapController.future.then((controller) {
      controller.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void _moveCamera(LatLng latLng) {
    _mapController.future.then((controller) {
      controller.moveCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void _setActiveMarker(Marker newActiveMarker) {
    // A marker's icon property is readonly, so we rebuild the current active
    // marker to give it a default icon, then remove and add it to the
    // fishing spot markers.
    //
    // This only applies if the active marker belongs to an existing fishing
    // spot. A dropped pin is removed from the map when updating the active
    // marker.
    if (_hasActiveMarker) {
      Marker activeMarker = _findMarker(_activeMarker.markerId.value);
      if (activeMarker != null) {
        if (_fishingSpotMarkers.remove(activeMarker)) {
          _fishingSpotMarkers.add(_copyMarker(activeMarker,
              _nonActiveMarkerIcon));
        } else {
          _log.e("Error removing marker");
        }
      }
    }

    _activeMarker = _copyMarker(
      newActiveMarker,
      _activeMarkerIcon,
      zIndex: 1000, // Active marker should always appear on top.
    );
  }

  Marker _copyMarker(Marker marker, BitmapDescriptor icon, {double zIndex}) {
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

  Marker _findMarker(String id) {
    return _fishingSpotMarkers.firstWhere(
      (Marker marker) => marker.markerId.value == id,
      orElse: () => null,
    );
  }
}

/// A widget that shows details of a selected fishing spot.
class _FishingSpotBottomSheet extends StatelessWidget {
  final double _chipHeight = 45;

  final FishingSpot fishingSpot;
  final bool editing;
  final VoidCallback onDelete;

  bool get hasName => isNotEmpty(fishingSpot.name) && editing;

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
            child: Text(
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
      child: Text(
        name,
        style: styleHeading,
      ),
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
              present(
                context,
                SaveFishingSpotPage(
                  oldFishingSpot: fishingSpot,
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
                description: InsertedBoldText(
                  text: Strings.of(context).mapPageDeleteFishingSpot,
                  args: [fishingSpot.name],
                ),
                onDelete: () {
                  onDelete?.call();
                  FishingSpotManager.of(context).delete(fishingSpot);
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

class _SearchDelegate extends SearchDelegate<FishingSpot> {
  List<FishingSpot> _allFishingSpots = [];
  List<FishingSpot> _searchFishingSpots = [];

  _SearchDelegate({
    String searchFieldLabel,
  }) : super(
    searchFieldLabel: searchFieldLabel,
  );

  @override
  List<Widget> buildActions(BuildContext context) {
    return isEmpty(query) ? null : [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return FishingSpotsBuilder(
      searchText: query,
      onUpdate: (List<FishingSpot> fishingSpots) {
        _searchFishingSpots = fishingSpots ?? [];
      },
      builder: (BuildContext context) {
        if (_searchFishingSpots.isNotEmpty) {
          return _buildList(_searchFishingSpots);
        }
        return NoResults(Strings.of(context).mapPageNoSearchResults);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FishingSpotsBuilder(
      onUpdate: (List<FishingSpot> fishingSpots) {
        _allFishingSpots = fishingSpots ?? [];
      },
      builder: (BuildContext context) {
        return _buildList(_allFishingSpots);
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  Widget _buildList(List<FishingSpot> fishingSpots) {
    return ListView.builder(
      itemCount: fishingSpots.length,
      itemBuilder: (BuildContext context, int index) {
        FishingSpot fishingSpot = fishingSpots[index];

        Widget title = Empty();
        if (isNotEmpty(fishingSpot.name)) {
          title = Text(fishingSpot.name);
        } else {
          title = Text(formatLatLng(
            context: context,
            lat: fishingSpot.lat,
            lng: fishingSpot.lng,
          ));
        }

        return ListItem(
          title: title,
          onTap: () => close(context, fishingSpot),
        );
      },
    );
  }
}

class MapTypeBottomSheet extends StatelessWidget {
  final Function(MapType) onMapTypeSelected;
  final MapType currentMapType;

  MapTypeBottomSheet({
    this.onMapTypeSelected,
    this.currentMapType = MapType.normal,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SwipeChip(),
          _buildItem(context, Strings.of(context).mapPageMapTypeNormal,
              MapType.normal),
          _buildItem(context, Strings.of(context).mapPageMapTypeSatellite,
              MapType.satellite),
          _buildItem(context, Strings.of(context).mapPageMapTypeHybrid,
              MapType.hybrid),
          _buildItem(context, Strings.of(context).mapPageMapTypeTerrain,
              MapType.terrain),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String title, MapType mapType) {
    return ListItem(
      title: Text(title),
      trailing: Visibility(
        visible: currentMapType == mapType,
        child: Icon(
          Icons.check,
          color: Colors.black,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onMapTypeSelected?.call(mapType);
      },
    );
  }
}