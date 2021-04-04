import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../i18n/strings.dart';
import '../location_monitor.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/fishing_spot_list_page.dart';
import '../pages/manageable_list_page.dart';
import '../res/dimen.dart';
import '../utils/dialog_utils.dart';
import '../utils/map_utils.dart';
import '../utils/page_utils.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/button.dart';
import '../widgets/search_bar.dart';
import '../widgets/widget.dart';
import '../wrappers/permission_handler_wrapper.dart';
import 'bottom_sheet_picker.dart';

class FishingSpotMapSearchBar {
  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final FishingSpot? selectedFishingSpot;
  final void Function(FishingSpot?)? onFishingSpotPicked;

  FishingSpotMapSearchBar({
    this.title,
    this.leading,
    this.trailing,
    this.selectedFishingSpot,
    this.onFishingSpotPicked,
  });
}

/// A [GoogleMap] wrapper that listens and responds to [FishingSpot] changes.
class FishingSpotMap extends StatefulWidget {
  /// Properties for the map's search bar. If `null`, no search bar will be
  /// shown.
  final FishingSpotMapSearchBar? searchBar;

  final Completer<GoogleMapController>? mapController;

  /// Adds padding to the [GoogleMap] widget. This allows you to move the
  /// Google logo that is required to be visible as per Google Maps TOS.
  final EdgeInsets? mapPadding;

  final LatLng? startLocation;
  final bool showMyLocationButton;
  final bool showZoomExtentsButton;

  /// See [GoogleMap.onTap].
  final void Function(LatLng)? onTap;

  /// See [GoogleMap.onCameraIdle].
  final VoidCallback? onIdle;

  /// See [GoogleMap.onCameraMove].
  final void Function(LatLng)? onMove;

  /// See [GoogleMap.onCameraMoveStarted].
  final VoidCallback? onMoveStarted;

  /// Invoked when the "current location" button is pressed.
  final VoidCallback? onCurrentLocationPressed;

  /// Invoked when the map type changes.
  final void Function(MapType)? onMapTypeChanged;

  /// If non-null, a "help" floating action button is rendered on the map, and
  /// a [HelpTooltip] with this widget as its child is toggled when tapped.
  final Widget? help;

  /// Widgets placed in the map's stack, between the actual map, and the search
  /// bar and floating action buttons. This is used as an easy way to show
  /// the [HelpTooltip] above all widgets.
  final List<Widget> children;

  final Set<Marker> markers;

  FishingSpotMap({
    this.mapController,
    this.mapPadding,
    this.searchBar,
    this.startLocation,
    this.showMyLocationButton = true,
    this.showZoomExtentsButton = true,
    this.onTap,
    this.onIdle,
    this.onMove,
    this.onMoveStarted,
    this.onCurrentLocationPressed,
    this.onMapTypeChanged,
    this.help,
    this.markers = const {},
    this.children = const [],
  });

  @override
  _FishingSpotMapState createState() => _FishingSpotMapState();
}

class _FishingSpotMapState extends State<FishingSpotMap> {
  static const _zoomDefault = 15.0;
  static const _helpTimerDuration = Duration(milliseconds: 2000);

  // TODO: Remove this when Google Maps performance issue is fixed.
  // https://github.com/flutter/flutter/issues/28493
  final Future<bool> _mapFuture =
      Future.delayed(Duration(milliseconds: 150), () => true);

  Timer? _hideHelpTimer;

  MapType _mapType = MapType.normal;
  bool _showHelp = true;
  bool _myLocationEnabled = true;

  late Completer<GoogleMapController> _mapController;

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);

  PermissionHandlerWrapper get _permissionHandlerWrapper =>
      PermissionHandlerWrapper.of(context);

  @override
  void initState() {
    super.initState();

    _mapController = widget.mapController ?? Completer();
    _myLocationEnabled = _locationMonitor.currentLocation != null;

    // No need to setup a timer if there is no help widget to show.
    if (widget.help != null) {
      _hideHelpTimer = Timer(_helpTimerDuration, () {
        setState(() {
          _showHelp = false;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _hideHelpTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [_buildMap()]
        ..addAll(widget.children)
        ..add(
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Row to extend column across page.
                _buildSearchBar(),
                _buildMapTypeButton(),
                _buildCurrentLocationButton(),
                _buildZoomExtentsButton(),
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
        // TODO: Test onCameraIdle fix when merged. Event sometimes stops after
        // interaction with map buttons.
        // https://github.com/flutter/flutter/issues/33988
        return GoogleMap(
          padding: widget.mapPadding ?? insetsZero,
          mapType: _mapType,
          markers: widget.markers,
          initialCameraPosition: CameraPosition(
            target: widget.startLocation ?? LatLng(0.0, 0.0),
            zoom: widget.startLocation == null ? 0 : _zoomDefault,
          ),
          onMapCreated: (controller) {
            if (!_mapController.isCompleted) {
              _mapController.complete(controller);
            }
          },
          myLocationButtonEnabled: false,
          myLocationEnabled: _myLocationEnabled,
          mapToolbarEnabled: false,
          // TODO: Try onLongPress again when Google Maps updated.
          // Long presses weren't being triggered first time.
          onTap: widget.onTap,
          onCameraIdle: widget.onIdle,
          onCameraMove: widget.onMove == null
              ? null
              : (position) => widget.onMove!(position.target),
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
    if (widget.searchBar == null) {
      // Row so it extends across the page.
      return Row(children: [Empty()]);
    }

    var searchBar = widget.searchBar!;

    return SearchBar(
      leading: searchBar.leading,
      trailing: searchBar.trailing,
      text: searchBar.title,
      hint: Strings.of(context).mapPageSearchHint,
      margin: EdgeInsets.only(
        // iOS "safe area" includes some padding, so keep the additional padding
        // small.
        top: Platform.isAndroid ? paddingDefault : paddingSmall,
        left: paddingDefault,
        right: paddingDefault,
      ),
      delegate: ButtonSearchBarDelegate(() {
        present(
          context,
          FishingSpotListPage(
            pickerSettings:
                ManageableListPagePickerSettings<FishingSpot>.single(
              onPicked: (context, fishingSpot) {
                searchBar.onFishingSpotPicked?.call(fishingSpot);
                if (fishingSpot != null) {
                  moveMap(
                    _mapController,
                    LatLng(fishingSpot.lat, fishingSpot.lng),
                    animate: false,
                  );
                }
                return true;
              },
              initialValue: searchBar.selectedFishingSpot,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMapTypeButton() {
    return FloatingIconButton(
      icon: Icons.layers,
      onPressed: () {
        showBottomSheetPicker(
          context,
          (context) => BottomSheetPicker<MapType>(
            currentValue: _mapType,
            items: {
              Strings.of(context).mapPageMapTypeNormal: MapType.normal,
              Strings.of(context).mapPageMapTypeSatellite: MapType.satellite,
              Strings.of(context).mapPageMapTypeHybrid: MapType.hybrid,
              Strings.of(context).mapPageMapTypeTerrain: MapType.terrain,
            },
            onPicked: (newMapType) {
              if (newMapType != _mapType) {
                var type = newMapType ?? MapType.normal;
                setState(() {
                  _mapType = type;
                });
                widget.onMapTypeChanged?.call(type);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildCurrentLocationButton() {
    if (!widget.showMyLocationButton) {
      return Empty();
    }

    return FloatingIconButton(
      padding: EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingDefault,
      ),
      icon: Icons.my_location,
      onPressed: () async {
        if (!(await _permissionHandlerWrapper.requestLocation())) {
          // If the user declines permission, let them know permission is
          // required to show their location on the map.
          showCancelDialog(
            context,
            title: Strings.of(context).fishingSpotMapLocationPermissionTitle,
            description:
                Strings.of(context).fishingSpotMapLocationPermissionDescription,
            actionText: Strings.of(context)
                .fishingSpotMapLocationPermissionOpenSettings,
            onTapAction: _permissionHandlerWrapper.openSettings,
          );
          return;
        } else {
          await _locationMonitor.initialize();
        }

        var currentLocation = _locationMonitor.currentLocation;
        if (currentLocation == null) {
          showErrorSnackBar(
              context, Strings.of(context).mapPageErrorGettingLocation);
        } else {
          moveMap(_mapController, currentLocation, zoom: _zoomDefault);
          widget.onCurrentLocationPressed?.call();
          setState(() {
            _myLocationEnabled = true;
          });
        }
      },
    );
  }

  Widget _buildZoomExtentsButton() {
    if (!widget.showZoomExtentsButton) {
      return Empty();
    }

    return FloatingIconButton(
      padding: EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingDefault,
      ),
      icon: Icons.zoom_out_map,
      onPressed: () {
        var bounds = mapBounds(widget.markers);
        if (bounds == null) {
          return;
        }
        setState(() {
          _mapController.future.then((controller) => controller.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, paddingDefaultDouble)));
        });
      },
    );
  }

  Widget _buildHelpButton() {
    if (widget.help == null) {
      return Empty();
    }

    return FloatingIconButton(
      padding: EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingDefault,
      ),
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
