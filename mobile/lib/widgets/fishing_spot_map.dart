import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/snackbar_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/no_results.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class FishingSpotMapSearchBar {
  final Widget title;
  final Widget leading;
  final Widget trailing;
  final void Function(FishingSpot) onFishingSpotPicked;

  FishingSpotMapSearchBar({
    this.title,
    this.leading,
    this.trailing,
    this.onFishingSpotPicked,
  });
}

class FishingSpotMap extends StatefulWidget {
  /// Properties for the map's search bar. If `null`, no search bar will be
  /// shown.
  final FishingSpotMapSearchBar searchBar;

  final Completer<GoogleMapController> mapController;
  final LatLng currentLocation;

  /// See [GoogleMap.onTap].
  final void Function(LatLng) onTap;

  /// See [GoogleMap.onCameraIdle].
  final VoidCallback onIdle;

  /// See [GoogleMap.onCameraMove].
  final void Function(LatLng) onMove;

  /// See [GoogleMap.onCameraMoveStarted].
  final VoidCallback onMoveStarted;

  /// Invoked when the map type changes.
  final void Function(MapType) onMapTypeChanged;

  final Set<Marker> markers;

  FishingSpotMap({
    @required this.mapController,
    this.searchBar,
    this.currentLocation,
    this.onTap,
    this.onIdle,
    this.onMove,
    this.onMoveStarted,
    this.onMapTypeChanged,
    this.markers,
  }) : assert(mapController != null);

  @override
  _FishingSpotMapState createState() => _FishingSpotMapState();
}

class _FishingSpotMapState extends State<FishingSpotMap> {
  // TODO: Remove this when Google Maps performance issue is fixed.
  // https://github.com/flutter/flutter/issues/28493
  Future _mapFuture = Future.delayed(Duration(milliseconds: 150), () => true);

  MapType _mapType = MapType.normal;

  Completer<GoogleMapController> get _mapController => widget.mapController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildMap(),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              widget.searchBar == null ? Empty() : _buildSearchBar(),
              _buildMapTypeButton(),
              _buildCurrentLocationButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    LatLng currentLocation = widget.currentLocation;

    return FutureBuilder(
      future: _mapFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Empty();
        }

        // TODO: Move Google logo when better solution is available.
        // https://github.com/flutter/flutter/issues/39610
        return GoogleMap(
          mapType: _mapType,
          markers: widget.markers,
          initialCameraPosition: CameraPosition(
            target: currentLocation ?? LatLng(0.0, 0.0),
            zoom: currentLocation == null ? 0 : 15,
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapController.complete(controller);
          },
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          // TODO: Try onLongPress again when Google Maps updated.
          // Long presses weren't being triggered first time.
          onTap: (latLng) {
            widget.onTap?.call(latLng);
          },
          onCameraIdle: widget.onIdle,
          onCameraMove: (position) {
            widget.onMove?.call(position.target);
          },
          onCameraMoveStarted: widget.onMoveStarted,
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.only(
        top: paddingSmall,
        left: paddingDefault,
        right: paddingDefault,
      ),
      decoration: FloatingBoxDecoration.rectangle(),
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
            widget.searchBar.onFishingSpotPicked?.call(result);

            if (result != null) {
              moveMap(_mapController, result.latLng, false);
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    widget.searchBar.leading ?? Empty(),
                    widget.searchBar.leading != null
                        ? SizedBox(width: paddingWidget) : Empty(),
                    widget.searchBar.title ?? SecondaryLabelText(
                        Strings.of(context).mapPageSearchHint),
                  ],
                ),
              ),
              widget.searchBar.trailing ?? Empty(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapTypeButton() {
    return FloatingIconButton(
      icon: Icons.layers,
      onPressed: () {
        showModalBottomSheet(
          isScrollControlled: true,
          useRootNavigator: true,
          context: context,
          builder: (BuildContext context) {
            return _MapTypeBottomSheet(
              currentMapType: _mapType,
              onMapTypeSelected: (MapType newMapType) {
                if (newMapType != _mapType) {
                  setState(() {
                    _mapType = newMapType;
                  });
                  widget.onMapTypeChanged?.call(newMapType);
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCurrentLocationButton() {
    return FloatingIconButton(
      padding: insetsHorizontalDefault,
      icon: Icons.my_location,
      onPressed: () {
        LatLng currentLocation =
            LocationMonitor.of(context).currentLocation;
        if (currentLocation == null) {
          showErrorSnackBar(context,
              Strings.of(context).mapPageErrorGettingLocation);
        } else {
          moveMap(_mapController, currentLocation);
        }
      },
    );
  }
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

class _MapTypeBottomSheet extends StatelessWidget {
  final Function(MapType) onMapTypeSelected;
  final MapType currentMapType;

  _MapTypeBottomSheet({
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