import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/pages/search_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/snackbar_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/no_results.dart';
import 'package:mobile/widgets/search_bar.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class FishingSpotMapSearchBar {
  final String title;
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

/// A [GoogleMap] wrapper that listens and responds to [FishingSpot] changes.
class FishingSpotMap extends StatefulWidget {
  /// Properties for the map's search bar. If `null`, no search bar will be
  /// shown.
  final FishingSpotMapSearchBar searchBar;

  final Completer<GoogleMapController> mapController;
  final LatLng startLocation;

  /// See [GoogleMap.onTap].
  final void Function(LatLng) onTap;

  /// See [GoogleMap.onCameraIdle].
  final VoidCallback onIdle;

  /// See [GoogleMap.onCameraMove].
  final void Function(LatLng) onMove;

  /// See [GoogleMap.onCameraMoveStarted].
  final VoidCallback onMoveStarted;

  /// Invoked when the "current location" button is pressed.
  final VoidCallback onCurrentLocationPressed;

  /// Invoked when the map type changes.
  final void Function(MapType) onMapTypeChanged;

  /// If non-null, a "help" floating action button is rendered on the map, and
  /// a [HelpTooltip] with this widget as its child is toggled when tapped.
  final Widget help;

  /// Widgets placed in the map's stack, between the actual map, and the search
  /// bar and floating action buttons. This is used as an easy way to show
  /// the [HelpTooltip] above all widgets.
  final List<Widget> children;

  final Set<Marker> markers;

  FishingSpotMap({
    @required this.mapController,
    this.searchBar,
    this.startLocation,
    this.onTap,
    this.onIdle,
    this.onMove,
    this.onMoveStarted,
    this.onCurrentLocationPressed,
    this.onMapTypeChanged,
    this.help,
    this.markers,
    this.children = const [],
  }) : assert(mapController != null);

  @override
  _FishingSpotMapState createState() => _FishingSpotMapState();
}

class _FishingSpotMapState extends State<FishingSpotMap> {
  // TODO: Remove this when Google Maps performance issue is fixed.
  // https://github.com/flutter/flutter/issues/28493
  Future<bool> _mapFuture =
      Future.delayed(Duration(milliseconds: 150), () => true);

  MapType _mapType = MapType.normal;
  bool _showHelp = true;

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  Completer<GoogleMapController> get _mapController => widget.mapController;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 2000), () {
      setState(() {
        _showHelp = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildMap()
      ]..addAll(widget.children)..add(
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              widget.searchBar == null ? Empty() : _buildSearchBar(),
              _buildMapTypeButton(),
              _buildCurrentLocationButton(),
              _buildHelpButton(),
              _buildHelp(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return EmptyFutureBuilder<bool>(
      future: _mapFuture,
      builder: (context, _) {
        // TODO: Move Google logo when better solution is available.
        // https://github.com/flutter/flutter/issues/39610
        // TODO: Test onCameraIdle fix when merged. Event sometimes stops after interaction with map buttons.
        // https://github.com/flutter/flutter/issues/33988
        return GoogleMap(
          mapType: _mapType,
          markers: widget.markers,
          initialCameraPosition: CameraPosition(
            target: widget.startLocation ?? LatLng(0.0, 0.0),
            zoom: widget.startLocation == null ? 0 : 15,
          ),
          onMapCreated: (GoogleMapController controller) {
            if (!_mapController.isCompleted) {
              _mapController.complete(controller);
            }
          },
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          // TODO: Try onLongPress again when Google Maps updated.
          // Long presses weren't being triggered first time.
          onTap: widget.onTap,
          onCameraIdle: widget.onIdle,
          onCameraMove: widget.onMove == null ? null : (position) {
            widget.onMove(position.target);
          },
          onCameraMoveStarted: () {
            widget.onMoveStarted?.call();
            if (widget.help != null) {
              setState(() {
                _showHelp = false;
              });
            }
          },
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return SearchBar(
      leading: widget.searchBar.leading,
      trailing: widget.searchBar.trailing,
      text: widget.searchBar.title,
      hint: Strings.of(context).mapPageSearchHint,
      margin: EdgeInsets.only(
        // iOS "safe area" includes some padding, so keep the additional padding
        // small.
        top: Platform.isAndroid ? paddingDefault : paddingSmall,
        left: paddingDefault,
        right: paddingDefault,
      ),
      delegate: ButtonSearchBarDelegate(() {
        present(context, SearchPage(
          hint: Strings.of(context).mapPageSearchHint,
          suggestionsBuilder: (context) => _buildSearchPageList(
              _fishingSpotManager.entityListSortedByName()),
          resultsBuilder: (context, query) {
            var fishingSpots =
                _fishingSpotManager.entityListSortedByName(filter: query);

            if (fishingSpots.isEmpty) {
              return NoResults(Strings.of(context).mapPageNoSearchResults);
            }

            return _buildSearchPageList(fishingSpots);
          }
        ),
        );
      }),
    );
  }

  Widget _buildSearchPageList(List<FishingSpot> fishingSpots) {
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
          onTap: () {
            widget.searchBar.onFishingSpotPicked?.call(fishingSpot);
            moveMap(_mapController, fishingSpot.latLng, false);
            Navigator.pop(context);
          },
        );
      },
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
          widget.onCurrentLocationPressed?.call();
        }
      },
    );
  }

  Widget _buildHelpButton() {
    if (widget.help == null) {
      return Empty();
    }

    return FloatingIconButton(
      icon: Icons.help,
      pushed: _showHelp,
      onPressed: () {
        setState(() {
          _showHelp = !_showHelp;
        });
      },
    );
  }

  Widget _buildHelp() {
    if (widget.help == null) {
      return Empty();
    }

    return HelpTooltip(
      margin: insetsHorizontalDefault,
      showing: _showHelp,
      child: widget.help,
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