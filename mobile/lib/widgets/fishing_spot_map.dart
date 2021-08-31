import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quiver/strings.dart';

import '../entity_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../location_monitor.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/fishing_spot_list_page.dart';
import '../pages/manageable_list_page.dart';
import '../res/dimen.dart';
import '../res/style.dart';
import '../utils/dialog_utils.dart';
import '../utils/map_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/button.dart';
import '../widgets/search_bar.dart';
import '../widgets/widget.dart';
import '../wrappers/permission_handler_wrapper.dart';
import 'bottom_sheet_picker.dart';
import 'fishing_spot_details.dart';
import 'input_controller.dart';
import 'slide_up_transition.dart';

/// A [GoogleMap] wrapper that listens and responds to [FishingSpot] changes.
class FishingSpotMap extends StatefulWidget {
  /// When non-null, sets up the map as an input picker.
  late final FishingSpotMapPickerSettings? pickerSettings;

  final bool showSearchBar;
  final bool showMyLocationButton;
  final bool showZoomExtentsButton;
  final bool showMapTypeButton;
  final bool showHelpButton;
  final bool showFishingSpotActionButtons;

  /// Widgets placed in the map's stack, between the actual map, and the search
  /// bar and floating action buttons. This is used as an easy way to show
  /// the [HelpTooltip] above all widgets.
  late final List<Widget> children;

  /// When true, the map is placed inside a [Scaffold].
  final bool isPage;

  final bool _isStatic;

  FishingSpotMap({
    this.pickerSettings,
    this.showSearchBar = true,
    this.showMyLocationButton = true,
    this.showZoomExtentsButton = true,
    this.showMapTypeButton = true,
    this.showHelpButton = true,
    this.showFishingSpotActionButtons = true,
    this.children = const [],
    this.isPage = true,
  }) : _isStatic = false;

  /// A fishing spot widget, not embedded in a page. This constructor should be
  /// used inside a sized box. This constructor should not be used directly.
  /// Instead, use [StaticFishingSpotMap].
  FishingSpotMap._static(FishingSpot fishingSpot)
      : pickerSettings = FishingSpotMapPickerSettings.static(fishingSpot),
        showSearchBar = false,
        showMyLocationButton = false,
        showZoomExtentsButton = false,
        showMapTypeButton = false,
        showHelpButton = false,
        showFishingSpotActionButtons = false,
        children = const [],
        isPage = false,
        _isStatic = true;

  /// A fishing spot page, with [fishingSpot] already selected.
  FishingSpotMap.selected(FishingSpot fishingSpot)
      : pickerSettings = FishingSpotMapPickerSettings.static(fishingSpot),
        showSearchBar = false,
        showMyLocationButton = true,
        showZoomExtentsButton = true,
        showMapTypeButton = true,
        showHelpButton = false,
        showFishingSpotActionButtons = true,
        children = [
          SafeArea(
            child: FloatingButton.back(
              padding: insetsDefault,
            ),
          )
        ],
        isPage = true,
        _isStatic = false;

  @override
  _FishingSpotMapState createState() => _FishingSpotMapState();
}

class _FishingSpotMapState extends State<FishingSpotMap> {
  static const _zoomDefault = 15.0;

  final _log = Log("FishingSpotMap");

  // TODO: Remove this when Google Maps performance issue is fixed.
  // https://github.com/flutter/flutter/issues/28493
  late final Future<bool> _mapFuture;

  final Completer<GoogleMapController> _mapController = Completer();
  final Set<FishingSpotMarker> _fishingSpotMarkers = {};
  FishingSpotMarker? _activeMarker;
  FishingSpot? _activeFishingSpot;

  Timer? _hideHelpTimer;

  MapType _mapType = MapType.normal;
  bool _showHelp = false;
  bool _myLocationEnabled = true;

  // Displayed while dismissing the fishing spot container.
  FishingSpot? _oldFishingSpot;

  // Used to display old data during animations and async operations.
  bool _isDismissingFishingSpot = false;

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);

  PermissionHandlerWrapper get _permissionHandlerWrapper =>
      PermissionHandlerWrapper.of(context);

  FishingSpotMapPickerSettings? get _pickerSettings => widget.pickerSettings;

  bool get _hasActiveMarker => _activeMarker != null;

  bool get _hasActiveFishingSpot => _activeFishingSpot != null;

  bool get _isPicking => _pickerSettings != null;

  bool get _isStatic => widget._isStatic;

  @override
  void initState() {
    super.initState();

    _myLocationEnabled = !_isStatic && _locationMonitor.currentLocation != null;
    _updateMarkers();
    _setupPicker();

    _mapFuture = Future.delayed(Duration(milliseconds: 150), () => true);
  }

  @override
  void didUpdateWidget(FishingSpotMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Required for updating static maps; for example, when a new fishing spot
    // is picked for a catch, and then that catch is saved.
    if (oldWidget.pickerSettings?.controller.value !=
        _pickerSettings?.controller.value) {
      _updateMarkers();
      _selectFishingSpot(_pickerSettings?.controller.value, animate: false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _hideHelpTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _pickerSettings?.controller.value =
            _activeFishingSpot ?? _activeMarker?.fishingSpot;
        return Future.value(true);
      },
      child: EntityListenerBuilder(
        managers: [_fishingSpotManager],
        onAnyChange: _onFishingSpotsUpdated,
        builder: (context) {
          var stack = Stack(
            children: [_buildMap()]
              ..addAll(widget.children)
              ..add(_buildFishingSpot())
              ..add(
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
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

          return widget.isPage ? Scaffold(body: stack) : stack;
        },
      ),
    );
  }

  Widget _buildMap() {
    var markers = Set.of(_fishingSpotMarkers);
    if (_hasActiveMarker) {
      markers.add(_activeMarker!);
    }

    var startPosition = _activeFishingSpot?.latLng ??
        _activeMarker?.fishingSpot.latLng ??
        LatLng(0, 0);

    return EmptyFutureBuilder<bool>(
      future: _mapFuture,
      builder: (context, _) {
        return GoogleMap(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            top: widget.showSearchBar ? SearchBar.height : 0,
            // TODO: Need some value here to show the Google logo
            bottom: 0.0,
          ),
          mapType: _mapType,
          markers: markers,
          initialCameraPosition: CameraPosition(
            target: startPosition,
            zoom: startPosition.latitude == 0 ? 0 : _zoomDefault,
          ),
          onMapCreated: (controller) {
            if (!_mapController.isCompleted) {
              _mapController.complete(controller);
            }
          },
          myLocationButtonEnabled: false,
          myLocationEnabled: _myLocationEnabled,
          mapToolbarEnabled: false,
          onTap: (latLng) => setState(() => _dropPin(latLng)),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    if (!widget.showSearchBar) {
      // Row so it extends across the page.
      return Row(children: [Empty()]);
    }

    String? name;
    if (_hasActiveFishingSpot) {
      // Showing active fishing spot.
      name = _activeFishingSpot!.displayName(
        context,
        includeLatLngLabels: false,
      );
    } else if (_hasActiveMarker) {
      // A pin was dropped.
      name = Strings.of(context).mapPageDroppedPin;
    }

    Widget? leading;
    Widget? trailing;
    if (_isPicking) {
      if (_pickerSettings!.onNext != null) {
        VoidCallback? onPressed;
        if (_hasActiveFishingSpot) {
          onPressed = () {
            _pickerSettings!.controller.value = _activeFishingSpot;
            _pickerSettings!.onNext!.call();
          };
        }

        trailing = Padding(
          padding: insetsRightWidgetSmall,
          child: ActionButton(
            condensed: true,
            text: Strings.of(context).next,
            textColor: Theme.of(context).primaryColor,
            onPressed: onPressed,
          ),
        );
      }
      leading = BackButton();
    } else {
      trailing = AnimatedVisibility(
        visible: isNotEmpty(name),
        child: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => setState(_dismissActiveFishingSpot),
        ),
      );
    }

    return SearchBar(
      leading: leading,
      trailing: trailing,
      text: isEmpty(name) ? null : name,
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
                setState(() => _selectFishingSpot(fishingSpot, animate: false));
                return true;
              },
              initialValue: _activeFishingSpot,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMapTypeButton() {
    if (!widget.showMapTypeButton) {
      return Empty();
    }

    return FloatingButton.icon(
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
              if (newMapType == _mapType) {
                return;
              }
              setState(() => _mapType = newMapType ?? MapType.normal);
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

    return FloatingButton.icon(
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
          setState(() {
            _myLocationEnabled = true;
            if (_isPicking) {
              _dropPin(currentLocation);
            } else {
              _dismissActiveFishingSpot();
            }
          });
        }
      },
    );
  }

  Widget _buildZoomExtentsButton() {
    if (!widget.showZoomExtentsButton) {
      return Empty();
    }

    return FloatingButton.icon(
      padding: EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingDefault,
      ),
      icon: Icons.zoom_out_map,
      onPressed: () {
        var bounds = mapBounds(_fishingSpotMarkers);
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
    if (!_isPicking || !widget.showHelpButton) {
      return Empty();
    }

    return FloatingButton.icon(
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
    if (!_isPicking) {
      return Empty();
    }

    return HelpTooltip(
      margin: insetsHorizontalDefault,
      showing: _showHelp,
      child: Text(
        Strings.of(context).fishingSpotPickerPageHint,
        style: styleLight,
      ),
    );
  }

  Widget _buildFishingSpot() {
    var fishingSpot = _activeFishingSpot;
    if (_isDismissingFishingSpot && _oldFishingSpot != null) {
      fishingSpot = _oldFishingSpot;
    }

    var isDroppedPin = false;
    if (fishingSpot == null && _hasActiveMarker) {
      fishingSpot = _activeMarker!.fishingSpot;
      isDroppedPin = true;
    }

    if (fishingSpot == null) {
      return Empty();
    }

    var details = FishingSpotDetails(
      fishingSpot,
      isDroppedPin: isDroppedPin,
      isPicking: _isPicking,
      showActionButtons: widget.showFishingSpotActionButtons,
    );

    if (_isStatic) {
      return details;
    }

    return SafeArea(
      child: SlideUpTransition(
        isVisible: !_isDismissingFishingSpot,
        onDismissed: () => setState(_clearActiveFishingSpot),
        child: details,
      ),
    );
  }

  void _onFishingSpotsUpdated() {
    _updateMarkers();

    if (_activeMarker == null) {
      return;
    }

    // Reset the active marker and fishing spot, if there was one.
    var updatedSpot =
        _fishingSpotManager.withLatLng(_activeMarker!.fishingSpot);
    _setActiveFishingSpot(
      updatedSpot,
      _fishingSpotMarkers.firstWhereOrNull(
        (m) => m.position == _activeMarker!.position,
      ),
      updatedSpot,
    );
  }

  void _updateMarkers() {
    _fishingSpotMarkers.clear();
    _fishingSpotManager.list().forEach((f) {
      if (!_isStatic || _pickerSettings?.controller.value == f) {
        _fishingSpotMarkers.add(_createFishingSpotMarker(f));
      }
    });
  }

  FishingSpotMarker _createFishingSpotMarker(FishingSpot fishingSpot) {
    return FishingSpotMarker(
      fishingSpot: fishingSpot,
      isActive: false,
      onTapFishingSpot: (spot) => setState(() => _selectFishingSpot(spot)),
    );
  }

  FishingSpotMarker _createDroppedPinMarker(LatLng latLng) {
    return FishingSpotMarker(
      fishingSpot: FishingSpot()
        ..id = randomId()
        ..lat = latLng.latitude
        ..lng = latLng.longitude,
      isActive: true,
    );
  }

  FishingSpotMarker _copyMarker(FishingSpotMarker marker, bool active,
      [double? zIndex]) {
    return marker.duplicate(
      active: active,
      zIndex: zIndex,
    );
  }

  FishingSpotMarker? _findMarker(Id id) {
    return _fishingSpotMarkers.firstWhereOrNull((marker) => marker.id == id);
  }

  void _dropPin(LatLng latLng) {
    var pin = _createDroppedPinMarker(latLng);
    _setActiveFishingSpot(null, pin, pin.fishingSpot);
    moveMap(_mapController, latLng);
  }

  void _selectFishingSpot(FishingSpot? fishingSpot, {bool animate = true}) {
    if (fishingSpot == null) {
      _clearActiveFishingSpot();
      return;
    }

    var marker = _findMarker(fishingSpot.id);
    if (marker == null) {
      _log.e("Couldn't find marker for selected fishing spot");
    }

    _setActiveFishingSpot(fishingSpot, marker, fishingSpot);
    moveMap(_mapController, _activeFishingSpot!.latLng, animate: animate);
  }

  void _dismissActiveFishingSpot() {
    if (!_hasActiveFishingSpot && !_hasActiveMarker) {
      return;
    }

    _oldFishingSpot = _activeFishingSpot ?? _activeMarker?.fishingSpot;
    _isDismissingFishingSpot = true;
  }

  void _setActiveFishingSpot(FishingSpot? fishingSpot,
      FishingSpotMarker? marker, FishingSpot? pickerControllerValue) {
    // A marker's icon property is readonly, so we rebuild the current active
    // marker to give it a default icon, then remove and add it to the
    // fishing spot markers.
    //
    // This only applies if the active marker belongs to an existing fishing
    // spot. A dropped pin is removed from the map when updating the active
    // marker.
    if (_hasActiveMarker) {
      var activeMarker = _findMarker(_activeMarker!.id);
      if (activeMarker != null) {
        if (_fishingSpotMarkers.remove(activeMarker)) {
          _fishingSpotMarkers.add(_copyMarker(activeMarker, false));
        } else {
          _log.e("Error removing marker");
        }
      }
    }

    if (marker == null) {
      _activeMarker = null;
    } else {
      // Active marker should always appear on top.
      _activeMarker = _copyMarker(marker, true, 1000);
    }

    _activeFishingSpot = fishingSpot;
  }

  void _clearActiveFishingSpot() {
    _setActiveFishingSpot(null, null, null);
    _isDismissingFishingSpot = false;
  }

  void _setupPicker() {
    if (!_isPicking) {
      return;
    }

    // Select the current fishing spot if it exists in the database.
    var selectedValue = _pickerSettings?.controller.value;
    if (_fishingSpotManager.entityExists(selectedValue?.id)) {
      _selectFishingSpot(_pickerSettings?.controller.value, animate: false);
      return;
    }

    // If the selected spot doesn't exist, see if one is close to the selected
    // spot or the user's current location.
    var currentLocation = _locationMonitor.currentLocation;
    var selectedLatLng = selectedValue?.latLng;
    var closeSpot = _fishingSpotManager.withinRadius(selectedLatLng) ??
        _fishingSpotManager.withinRadius(currentLocation);
    if (closeSpot != null) {
      _selectFishingSpot(closeSpot, animate: false);
      return;
    }

    // As a fallback, drop a pin at the user's current location.
    _dropPin(currentLocation ?? LatLng(0, 0));
  }
}

class FishingSpotMapPickerSettings {
  late final InputController<FishingSpot> controller;

  /// When non-null, a "NEXT" button is rendered in the search bar.
  final VoidCallback? onNext;

  FishingSpotMapPickerSettings({
    required this.controller,
    this.onNext,
  });

  FishingSpotMapPickerSettings.static(FishingSpot fishingSpot)
      : this(
          controller: InputController<FishingSpot>()..value = fishingSpot,
        );
}

/// A widget that displays [FishingSpot] details on a small map.
class StaticFishingSpotMap extends StatelessWidget {
  static const _mapHeight = 300.0;

  final FishingSpot fishingSpot;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  StaticFishingSpotMap(
    this.fishingSpot, {
    this.padding,
    this.onTap,
  });

  // TODO: Map moves slightly when scrolling inside a scrollable view; for
  //  example, SaveCatchPage. Verify fixed when Google Maps library is updated.

  @override
  Widget build(BuildContext context) {
    return HorizontalSafeArea(
      child: Container(
        padding: padding,
        height: _mapHeight,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(floatingCornerRadius),
              ),
              child: IgnorePointer(
                child: FishingSpotMap._static(fishingSpot),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
