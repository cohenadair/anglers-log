import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quiver/strings.dart';

import '../entity_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../location_monitor.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/save_fishing_spot_page.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/dialog_utils.dart';
import '../utils/map_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/snackbar_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/bottom_sheet_picker.dart';
import '../widgets/button.dart';
import '../widgets/fishing_spot_map.dart';
import '../widgets/styled_bottom_sheet.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';
import '../wrappers/url_launcher_wrapper.dart';
import 'add_catch_journey.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _log = Log("MapPage");

  final Completer<GoogleMapController> _mapController = Completer();
  final Set<FishingSpotMarker> _fishingSpotMarkers = {};

  FishingSpotMarker _activeMarker;

  FishingSpot _activeFishingSpot;

  // Used to display old data during dismiss animations and during async
  // database calls.
  bool _waitingForDismissal = false;

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);

  bool get _hasActiveMarker => _activeMarker != null;

  bool get _hasActiveFishingSpot => _activeFishingSpot != null;

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EntityListenerBuilder(
        managers: [_fishingSpotManager],
        onAnyChange: () {
          _updateMarkers();

          // Reset the active marker and fishing spot, if there was one.
          if (_activeMarker != null) {
            _activeFishingSpot =
                _fishingSpotManager.withLatLng(_activeMarker.fishingSpot);

            Marker newMarker = _fishingSpotMarkers.firstWhere(
              (m) => m.position == _activeMarker.position,
              orElse: () => null,
            );
            _activeMarker = _copyMarker(newMarker, true);
          }
        },
        builder: _buildMap,
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    var markers = Set.of(_fishingSpotMarkers);
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
      startLocation: _locationMonitor.currentLocation,
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
        selectedFishingSpot: _activeFishingSpot,
        onFishingSpotPicked: (fishingSpot) {
          setState(() {
            if (fishingSpot == null) {
              _clearActiveFishingSpot();
            } else {
              _setActiveMarker(_findMarker(fishingSpot.id));
              _activeFishingSpot = fishingSpot;
              moveMap(_mapController, _activeFishingSpot.latLng,
                  animate: false);
            }
          });
        },
      ),
      onTap: (latLng) {
        setState(() {
          _setActiveMarker(_createDroppedPinMarker(latLng));
          _activeFishingSpot = null;
          moveMap(_mapController, latLng);
        });
      },
      onCurrentLocationPressed: () => setState(() {
        setState(_clearActiveFishingSpot);
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

    var fishingSpot = _activeFishingSpot?.clone();
    var editing = true;
    if (fishingSpot == null && _hasActiveMarker) {
      // Dropped pin case.
      fishingSpot = FishingSpot()
        ..id = randomId()
        ..lat = _activeMarker.position.latitude
        ..lng = _activeMarker.position.longitude;
      editing = false;
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: StyledBottomSheet(
        visible: fishingSpot != null && !_waitingForDismissal,
        onDismissed: () {
          setState(_clearActiveFishingSpot);
        },
        child: _FishingSpotBottomSheet(
          fishingSpot: fishingSpot,
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
      onTapFishingSpot: (fishingSpot) {
        setState(() {
          _setActiveMarker(_fishingSpotMarkers
              .firstWhere((marker) => marker.id == fishingSpot.id));
          _activeFishingSpot = _fishingSpotManager.entity(_activeMarker.id);
        });
      },
    );
  }

  Marker _createDroppedPinMarker(LatLng latLng) {
    // All dropped pins become active, and shouldn't be clickable.
    return FishingSpotMarker(
      fishingSpot: FishingSpot()
        ..id = randomId()
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
          _fishingSpotMarkers.add(_copyMarker(activeMarker, false));
        } else {
          _log.e("Error removing marker");
        }
      }
    }

    // Active marker should always appear on top.
    _activeMarker = _copyMarker(newActiveMarker, true, 1000);
  }

  FishingSpotMarker _copyMarker(FishingSpotMarker marker, bool active,
      [double zIndex]) {
    if (marker == null) {
      return null;
    }

    return marker.duplicate(
      active: active,
      zIndex: zIndex,
    );
  }

  Marker _findMarker(Id id) {
    return _fishingSpotMarkers.firstWhere((marker) => marker.id == id,
        orElse: () => null);
  }

  void _updateMarkers() {
    _fishingSpotMarkers.clear();
    _fishingSpotManager
        .list()
        .forEach((f) => _fishingSpotMarkers.add(_createFishingSpotMarker(f)));
  }

  void _clearActiveFishingSpot() {
    _setActiveMarker(null);
    _waitingForDismissal = false;
    _activeFishingSpot = null;
  }
}

/// A widget that shows details of a selected fishing spot.
class _FishingSpotBottomSheet extends StatelessWidget {
  final _log = Log("_FishingSpotBottomSheet");

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

    return isEmpty(name)
        ? Empty()
        : Padding(
            padding: insetsHorizontalDefault,
            child: Label(
              name,
              style: styleHeading,
            ),
          );
  }

  Widget _buildChips(BuildContext context) {
    var fishingSpotManager = FishingSpotManager.of(context);

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
              label:
                  editing ? Strings.of(context).edit : Strings.of(context).save,
              icon: editing ? Icons.edit : Icons.save,
              onPressed: () {
                if (editing) {
                  present(context, SaveFishingSpotPage.edit(fishingSpot));
                } else {
                  present(
                      context,
                      SaveFishingSpotPage(
                        latLng: fishingSpot.latLng,
                      ));
                }
              },
            ),
          ),
          editing
              ? Padding(
                  padding: insetsRightWidgetSmall,
                  child: ChipButton(
                    label: Strings.of(context).delete,
                    icon: Icons.delete,
                    onPressed: () {
                      showDeleteDialog(
                        context: context,
                        description: Text(fishingSpotManager.deleteMessage(
                            context, fishingSpot)),
                        onDelete: () {
                          onDelete?.call();
                          fishingSpotManager.delete(fishingSpot.id);
                        },
                      );
                    },
                  ),
                )
              : Empty(),
          editing
              ? Padding(
                  padding: insetsRightWidgetSmall,
                  child: ChipButton(
                    label: Strings.of(context).mapPageAddCatch,
                    icon: Icons.add,
                    onPressed: () => present(context, AddCatchJourney()),
                  ),
                )
              : Empty(),
          Padding(
            padding: insetsRightDefault,
            child: ChipButton(
              label: Strings.of(context).directions,
              icon: Icons.directions,
              onPressed: () => _launchDirections(context),
            ),
          ),
        ],
      ),
    );
  }

  void _launchDirections(BuildContext context) async {
    var navigationAppOptions = <String, String>{};
    var urlLauncher = UrlLauncherWrapper.of(context);
    var destination = "${fishingSpot.lat}%2C${fishingSpot.lng}";

    // Openable on Android as standard URL. Do not include as an option on
    // Android devices.
    var appleMapsUrl = "https://maps.apple.com/?daddr=$destination";
    if (Platform.isIOS && await urlLauncher.canLaunch(appleMapsUrl)) {
      navigationAppOptions[Strings.of(context).mapPageAppleMaps] = appleMapsUrl;
    }

    var googleMapsUrl = Platform.isAndroid
        ? "google.navigation:q=$destination"
        : "comgooglemaps://?daddr=$destination";
    if (await urlLauncher.canLaunch(googleMapsUrl)) {
      navigationAppOptions[Strings.of(context).mapPageGoogleMaps] =
          googleMapsUrl;
    }

    var wazeUrl = "waze://?ll=$destination&navigate=yes";
    if (await urlLauncher.canLaunch(wazeUrl)) {
      navigationAppOptions[Strings.of(context).mapPageWaze] = wazeUrl;
    }

    _log.d("Available navigation apps: ${navigationAppOptions.keys}");
    var launched = false;

    if (navigationAppOptions.isEmpty) {
      // Default to Google Maps in a browser.
      var defaultUrl = "https://www.google.com/maps/dir/?api=1&"
          "dir_action=preview&"
          "destination=$destination";
      if (await urlLauncher.canLaunch(defaultUrl) &&
          await urlLauncher.launch(defaultUrl)) {
        launched = true;
      }
    } else if (navigationAppOptions.length == 1) {
      // There's only one option, open it.
      var url = navigationAppOptions.values.first;
      if (await urlLauncher.canLaunch(url) && await urlLauncher.launch(url)) {
        launched = true;
      }
    } else {
      // There are multiple options, give the user a choice.
      String url;
      await showBottomSheetPicker(
        context,
        (context) => BottomSheetPicker<String>(
          onPicked: (pickedUrl) => url = pickedUrl,
          items: navigationAppOptions,
        ),
      ).then((_) async {
        // If empty, bottom sheet was dismissed.
        launched = isEmpty(url) || await urlLauncher.launch(url);
      });
    }

    if (!launched) {
      showErrorSnackBar(
          context, Strings.of(context).mapPageErrorOpeningDirections);
    }
  }
}
