import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/pages/save_fishing_spot_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/list_item.dart';
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

  Set<Marker> _fishingSpotMarkers = Set();
  Marker _activeMarker;
  FishingSpot _activeFishingSpot;

  bool get _hasActiveMarker => _activeMarker != null;
  bool get _hasActiveFishingSpot => _activeFishingSpot != null;

  @override
  Widget build(BuildContext context) => Page(
    child: FishingSpotsBuilder(
      onUpdate: (List<FishingSpot> fishingSpots) {
        _log.d("Reloading fishing spots...");

        _fishingSpotMarkers.clear();
        fishingSpots.forEach((f) =>
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
            _hasActiveMarker ? FutureBuilder<FishingSpot>(
              future: FishingSpotManager.of(context)
                  .fetch(id: _activeMarker.markerId.value),
              builder: (BuildContext context,
                  AsyncSnapshot<FishingSpot> snapshot)
              {
                _activeFishingSpot = snapshot.data;
                return Stack(
                  children: <Widget>[
                    _buildSearchBar(),
                    _buildBottomSheet(),
                  ],
                );
              },
            ) : _buildSearchBar(),
          ],
        );
      },
    ),
  );

  Widget _buildMap() {
    Set<Marker> markers = Set.of(_fishingSpotMarkers);
    if (_hasActiveMarker) {
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
      // TODO: Try onLongPress again when Google Maps updated.
      // Log presses weren't being triggered first time.
      onTap: (LatLng latLng) {
        _addPin(latLng);
      },
      padding: EdgeInsets.only(
        bottom: _hasActiveMarker ? _bottomMapPadding : 0,
      ),
    );
  }

  Widget _buildSearchBar() {
    final cornerRadius = 10.0;

    Widget text = DisabledText(Strings.of(context).mapPageSearchHint);
    Widget icon = Empty();

    if (_hasActiveMarker) {
      text = Flexible(
        child: Text(
          _hasActiveFishingSpot
              ? _activeFishingSpot.name : Strings.of(context).mapPageDroppedPin,
          overflow: TextOverflow.ellipsis,
        ),
      );

      icon = SmallIconButton(
        icon: Icons.clear,
        onTap: () {
          _clearSearch();
        },
      );
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: insetsHorizontalMedium,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: boxShadowSmallBottom,
              borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  FishingSpot result = await showSearch(
                    context: context,
                    delegate: _SearchDelegate(),
                  );
                  // Only reset selection if a new selection was made.
                  if (result != null) {
                    _updateActiveFishingSpot(result);
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
                      text,
                      icon,
                    ],
                  ),
                ),
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
    if (!_hasActiveMarker) {
      return Empty();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: StyledBottomSheet(
        onDismissed: () {
          _updateActiveFishingSpot(null);
        },
        child: _FishingSpotBottomSheet(
          fishingSpot: _hasActiveFishingSpot ? _activeFishingSpot : FishingSpot(
            lat: _activeMarker.position.latitude,
            lng: _activeMarker.position.longitude,
          ),
          editing: _hasActiveFishingSpot,
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
      onTap: tappable ? () => _updateActiveMarker(_fishingSpotMarkers
          .firstWhere((Marker marker) => marker.markerId == markerId)) : null,
      icon: icon,
    );
  }

  void _addPin(LatLng latLng) {
    setState(() {
      _updateActiveMarker(_createDroppedPinMarker(latLng));
      _updateCamera(latLng);
    });
  }

  void _updateCamera(LatLng latLng) {
    // Animate the new marker to the middle of the map.
    _mapController.future.then((controller) {
      controller.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void _updateActiveMarker(Marker newActiveMarker) {
    setState(() {
      _resetActiveMarker(newActiveMarker);
    });
  }

  void _updateActiveFishingSpot(FishingSpot newActiveFishingSpot) {
    setState(() {
      _activeFishingSpot = newActiveFishingSpot;

      if (_activeFishingSpot == null) {
        _resetActiveMarker(null);
      } else {
        _resetActiveMarker(_fishingSpotMarkers.firstWhere((Marker marker) =>
            _activeFishingSpot.id == marker.markerId.value));
        _updateCamera(_activeFishingSpot.latLng);
      }
    });
  }

  void _resetActiveMarker(Marker newActiveMarker) {
    // A marker's icon property is readonly, so we rebuild the current active
    // marker to give it a default icon, then remove and add it to the
    // fishing spot markers.
    //
    // This only applies if the active marker belongs to an existing fishing
    // spot. A dropped pin is removed from the map when updating the active
    // marker.
    if (_hasActiveMarker) {
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

  void _clearSearch() {
    _updateActiveFishingSpot(null);
  }
}

/// A widget that shows details of a selected fishing spot.
class _FishingSpotBottomSheet extends StatelessWidget {
  final double _chipHeight = 45;

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
          child: SecondaryText(formatLatLng(
            context: context,
            lat: fishingSpot.lat,
            lng: fishingSpot.lng,
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
      name = Strings.of(context).mapPageDroppedPin;
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
  List<FishingSpot> _fishingSpots = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    return null;
  }

  @override
  Widget buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListView(
      children: <Widget>[
        // TODO: Query database
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FishingSpotsBuilder(
      onUpdate: (List<FishingSpot> fishingSpots) {
        _fishingSpots = fishingSpots ?? [];
      },
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: _fishingSpots.length,
          itemBuilder: (BuildContext context, int index) {
            FishingSpot fishingSpot = _fishingSpots[index];

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
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }
}