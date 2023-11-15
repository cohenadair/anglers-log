import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/gps_trail_manager.dart';
import 'package:mobile/pages/gps_trail_page.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/subscription_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:mobile/utils/permission_utils.dart';
import 'package:mobile/utils/widget_utils.dart';
import 'package:mobile/widgets/our_bottom_sheet.dart';
import 'package:quiver/strings.dart';

import '../entity_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../location_monitor.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/fishing_spot_list_page.dart';
import '../res/dimen.dart';
import '../utils/map_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/button.dart';
import '../widgets/our_search_bar.dart';
import '../widgets/widget.dart';
import 'bottom_sheet_picker.dart';
import 'default_mapbox_map.dart';
import 'fishing_spot_details.dart';
import 'input_controller.dart';
import 'map_target.dart';
import 'mapbox_attribution.dart';
import 'slide_up_transition.dart';

/// A map widget that listens and responds to [FishingSpot] changes. This widget
/// should be used for displaying all fishing spots and/or picking a fishing spot.
///
/// See:
///  - [StaticFishingSpotMap]
///  - [EditCoordinatesPage]
///  - [DefaultMapboxMap]
class FishingSpotMap extends StatefulWidget {
  /// When non-null, sets up the map as an input picker.
  late final FishingSpotMapPickerSettings? pickerSettings;

  final bool showSearchBar;
  final bool showMyLocationButton;
  final bool showZoomExtentsButton;
  final bool showMapTypeButton;

  /// Regardless of this value, the GPS trail button is hidden if a new fishing
  /// spot is being picked (i.e. [pickerSettings] is not null).
  final bool showGpsTrailButton;

  final bool showFishingSpotActionButtons;

  /// Widgets placed in the map's stack, between the actual map, and the search
  /// bar and floating action buttons. This is used as an easy way to show
  /// the [HelpTooltip] above all widgets.
  late final List<Widget> children;

  /// When true, the map is placed inside a [Scaffold].
  final bool isPage;

  // ignore: prefer_const_constructors_in_immutables
  FishingSpotMap({
    this.pickerSettings,
    this.showSearchBar = true,
    this.showMyLocationButton = true,
    this.showZoomExtentsButton = true,
    this.showMapTypeButton = true,
    this.showGpsTrailButton = false,
    this.showFishingSpotActionButtons = true,
    this.children = const [],
    this.isPage = true,
  });

  /// A fishing spot page, with [fishingSpot] already selected.
  FishingSpotMap.selected(FishingSpot fishingSpot)
      : pickerSettings = FishingSpotMapPickerSettings._static(fishingSpot),
        showSearchBar = false,
        showMyLocationButton = true,
        showZoomExtentsButton = false,
        showMapTypeButton = true,
        showGpsTrailButton = false,
        showFishingSpotActionButtons = true,
        children = [
          const SafeArea(
            child: FloatingButton.back(
              padding: insetsDefault,
            ),
          )
        ],
        isPage = true;

  @override
  FishingSpotMapState createState() => FishingSpotMapState();
}

class FishingSpotMapState extends State<FishingSpotMap> {
  static const _log = Log("FishingSpotMap");

  final _fishingSpotKey = GlobalKey();
  final _isTargetShowingNotifier = ValueNotifier<bool>(false);

  MapboxMapController? _mapController;
  late MapType _mapType;
  late StreamSubscription<EntityEvent<GpsTrail>> _gpsTrailManagerSub;
  late StreamSubscription<String> _userPreferenceSub;

  Symbol? _activeSymbol;
  GpsMapTrail? _activeTrail;

  bool _myLocationEnabled = true;
  bool _didChangeMapType = false;
  bool _didAddFishingSpot = false;
  bool _isTrackingUser = false;

  // Displayed while dismissing the fishing spot container.
  FishingSpot? _oldFishingSpot;

  // Used to display old data during animations and async operations.
  bool _isDismissingFishingSpot = false;

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  GpsTrailManager get _gpsTrailManager => GpsTrailManager.of(context);

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);

  SubscriptionManager get _subscriptionManager =>
      SubscriptionManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  FishingSpotMapPickerSettings? get _pickerSettings => widget.pickerSettings;

  bool get _hasActiveSymbol => _activeSymbol != null;

  bool get _hasActiveDroppedPin => _hasActiveSymbol && _isDroppedPin;

  bool get _isPicking => _pickerSettings != null;

  bool get _isDroppedPin =>
      !_fishingSpotManager.entityExists(_activeFishingSpot?.id);

  bool get _hasActiveFishingSpot => _activeFishingSpot != null;

  FishingSpot? get _activeFishingSpot => _activeSymbol?.fishingSpot;

  @override
  void initState() {
    super.initState();

    _myLocationEnabled = _locationMonitor.currentLatLng != null;
    _gpsTrailManagerSub = _gpsTrailManager.stream.listen(_updateGpsTrail);
    _userPreferenceSub =
        _userPreferenceManager.stream.listen(_onUserPreferenceUpdate);

    // Refresh state so Mapbox attribution padding is updated. This needs to be
    // done after the fishing spot widget is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void didUpdateWidget(FishingSpotMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Required for updating static maps; for example, when a new fishing spot
    // is picked for a catch, and then that catch is saved.
    if (oldWidget.pickerSettings?.controller.value !=
        _pickerSettings?.controller.value) {
      _updateSymbols(selectedFishingSpot: _pickerSettings?.controller.value);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mapType = MapType.of(context);
  }

  @override
  void dispose() {
    _mapController?.onSymbolTapped.remove(_onSymbolTapped);
    _mapController?.removeListener(_updateTarget);
    _gpsTrailManagerSub.cancel();
    _userPreferenceSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var map = EntityListenerBuilder(
      managers: [_fishingSpotManager],
      changesUpdatesState: false,
      onAnyChange: () =>
          _updateSymbols(selectedFishingSpot: _activeFishingSpot),
      builder: (context) {
        var stack = Stack(children: [
          _buildMap(),
          ...widget.children,
          _buildNewFishingSpotTarget(),
          _buildNoSelectionMapAttribution(),
          _buildFishingSpot(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildSearchBar(),
                _buildMapStyleButton(),
                _buildCurrentLocationButton(),
                _buildZoomExtentsButton(),
                _buildGpsTrailButton(),
                _buildAddButton(),
              ],
            ),
          ),
        ]);

        return widget.isPage ? Scaffold(body: stack) : stack;
      },
    );

    // WillPopScope overrides the default "swipe to go back" behavior on iOS.
    // Only allow this behavior when we're not showing a static map.
    return WillPopScope(
      onWillPop: () {
        _pickerSettings?.controller.value = _activeSymbol?.fishingSpot;
        return Future.value(true);
      },
      child: map,
    );
  }

  Widget _buildMap() {
    return DefaultMapboxMap(
      isMyLocationEnabled: _myLocationEnabled,
      style: _mapType.url,
      startPosition: _activeFishingSpot?.latLng ??
          _pickerSettings?.controller.value?.latLng,
      onMapCreated: (controller) {
        _mapController = controller;
        _mapController?.addListener(_updateTarget);
      },
      onStyleLoadedCallback: _setupMap,
      onCameraIdle: () {
        // Note that onCameraIdle is called quite often, even when the camera
        // didn't move.
        if (_hasActiveDroppedPin) {
          _updateDroppedPin();
        }
      },
      onCameraTrackingChanged: (mode) =>
          _isTrackingUser = mode == MyLocationTrackingMode.Tracking,
    );
  }

  Widget _buildSearchBar() {
    if (!widget.showSearchBar) {
      // Row so it extends across the page.
      return const Row(children: [Empty()]);
    }

    String? name;
    if (_hasActiveFishingSpot) {
      if (_fishingSpotManager.entityExists(_activeFishingSpot!.id)) {
        // Showing active fishing spot.
        name = _fishingSpotManager.displayName(
          context,
          _activeFishingSpot!,
          includeLatLngLabels: false,
        );
      } else {
        // A pin was dropped.
        name = Strings.of(context).mapPageDroppedPin;
      }
    }

    Widget? leading;
    Widget? trailing;
    if (_isPicking) {
      if (_pickerSettings!.onNext != null) {
        trailing = Padding(
          padding: insetsRightSmall,
          child: ActionButton(
            condensed: true,
            text: Strings.of(context).next,
            textColor: context.colorDefault,
            onPressed: () {
              _pickerSettings!.controller.value = _activeFishingSpot;
              _pickerSettings!.onNext!.call();
            },
          ),
        );
      }
      leading = const BackButton();
    } else {
      trailing = AnimatedVisibility(
        visible: isNotEmpty(name),
        child: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => _selectFishingSpot(null, dismissIfNull: true),
        ),
      );
    }

    return OurSearchBar(
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
            pickerSettings: FishingSpotListPagePickerSettings.single(
              onPicked: (context, fishingSpot) {
                _selectFishingSpot(fishingSpot);
                return true;
              },
              initialValue: _activeFishingSpot,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMapStyleButton() {
    if (!widget.showMapTypeButton) {
      return const Empty();
    }

    return FloatingButton.icon(
      icon: Icons.layers,
      tooltip: Strings.of(context).mapPageMapTypeTooltip,
      onPressed: () {
        showOurBottomSheet(
          context,
          (context) => BottomSheetPicker<MapType>(
            currentValue: _mapType,
            items: {
              Strings.of(context).mapPageMapTypeLight: MapType.light,
              Strings.of(context).mapPageMapTypeDark: MapType.dark,
              Strings.of(context).mapPageMapTypeSatellite: MapType.satellite,
            },
            onPicked: (newType) {
              if (newType == _mapType) {
                return;
              }
              setState(() {
                _mapType = newType ?? MapType.of(context);
                _userPreferenceManager.setMapType(_mapType.id);
                _didChangeMapType = true;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildCurrentLocationButton() {
    if (!widget.showMyLocationButton) {
      return const Empty();
    }

    return FloatingButton.icon(
      padding: const EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingDefault,
      ),
      tooltip: Strings.of(context).mapPageMyLocationTooltip,
      icon: Icons.my_location,
      onPressed: () async {
        var isGranted = await requestLocationPermissionIfNeeded(
          context: context,
          requestAlways: false,
        );
        if (!isGranted) {
          return;
        }

        var currentLocation = _locationMonitor.currentLatLng;
        if (currentLocation == null) {
          safeUseContext(
            this,
            () => showErrorSnackBar(
                context, Strings.of(context).mapPageErrorGettingLocation),
          );
        } else {
          setState(() => _myLocationEnabled = true);

          if (_isPicking) {
            await _dropPin(currentLocation);
          } else {
            await _selectFishingSpot(null, dismissIfNull: true);
          }

          // Move map after pin changes so widgets are hidden/shown correctly.
          await _moveMap(
            currentLocation,
            zoomToDefault: !_gpsTrailManager.hasActiveTrail,
          );

          if (_gpsTrailManager.hasActiveTrail) {
            await _mapController?.startTracking();
          }
        }
      },
    );
  }

  Widget _buildZoomExtentsButton() {
    if (!widget.showZoomExtentsButton) {
      return const Empty();
    }

    return FloatingButton.icon(
      padding: const EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingDefault,
      ),
      tooltip: Strings.of(context).mapPageShowAllTooltip,
      icon: Icons.zoom_out_map,
      onPressed: () async {
        var bounds = fishingSpotMapBounds(_fishingSpotManager.list());
        if (bounds == null) {
          return;
        }

        await _selectFishingSpot(null, dismissIfNull: true);

        // Move map after updating fishing spot so widgets are hidden/shown
        // correctly.
        _mapController?.animateToBounds(bounds);
      },
    );
  }

  Widget _buildGpsTrailButton() {
    if (!widget.showGpsTrailButton || _isPicking) {
      return const Empty();
    }

    Future<void> Function() onPressed = () async {
      var isGranted = await requestLocationPermissionIfNeeded(
        context: context,
        requestAlways: true,
      );
      if (isGranted && context.mounted) {
        _gpsTrailManager.startTracking(context);
      }
    };

    var tooltip = Strings.of(context).mapPageStartTrackingTooltip;
    if (_gpsTrailManager.hasActiveTrail) {
      tooltip = Strings.of(context).mapPageStopTrackingTooltip;
      onPressed = () => _gpsTrailManager.stopTracking();
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingDefault,
      ),
      child: BadgeContainer(
        isBadgeVisible: _gpsTrailManager.hasActiveTrail,
        child: FloatingButton.icon(
          padding: insetsZero,
          tooltip: tooltip,
          icon: iconGpsTrail,
          onPressed: () {
            // Always allow users to stop tracking, regardless of subscription
            // status. This handles an edge case where their membership runs
            // out while a GPS trail is active.
            if (_subscriptionManager.isPro || _gpsTrailManager.hasActiveTrail) {
              onPressed();
            } else {
              present(context, const ProPage());
            }
          },
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    if (_isPicking && _pickerSettings!.isStatic) {
      return const Empty();
    }

    return FloatingButton.icon(
      padding: const EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingDefault,
      ),
      tooltip: Strings.of(context).mapPageAddTooltip,
      icon: Icons.add,
      onPressed: () async {
        _didAddFishingSpot = true;
        _updateDroppedPin();
      },
    );
  }

  Widget _buildFishingSpot() {
    var fishingSpot = _activeFishingSpot;
    if (_isDismissingFishingSpot && _oldFishingSpot != null) {
      fishingSpot = _oldFishingSpot;
    }

    // If the map isn't yet setup, but there's a picked spot, use that for
    // rendering. This allows us to calculate the padding for Mapbox
    // attributions, and shows a smoother transition when selecting a symbol.
    fishingSpot ??= _pickerSettings?.controller.value;

    Widget details = const Empty();
    if (fishingSpot != null) {
      details = Padding(
        padding: insetsTopSmall,
        child: FishingSpotDetails(
          fishingSpot,
          containerKey: _fishingSpotKey,
          isNewFishingSpot: _isDroppedPin,
          isPicking: _isPicking,
          showDirections: !_isPicking || _pickerSettings!.isStatic,
          showActionButtons: widget.showFishingSpotActionButtons,
        ),
      );
    }

    var container = Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(
          left: paddingDefault,
          right: paddingDefault,
          bottom: paddingDefault,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAttribution(),
            details,
          ],
        ),
      ),
    );

    return SafeArea(
      child: SlideUpTransition(
        isVisible: !_isDismissingFishingSpot && fishingSpot != null,
        onDismissed: () => _selectFishingSpot(null),
        child: container,
      ),
    );
  }

  Widget _buildNewFishingSpotTarget() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isTargetShowingNotifier,
      builder: (_, isShowing, __) {
        return MapTarget(
          isShowing: _isTargetShowingNotifier.value,
          mapType: _mapType,
        );
      },
    );
  }

  Widget _buildNoSelectionMapAttribution() {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: insetsDefault,
          child: _buildAttribution(),
        ),
      ),
    );
  }

  Widget _buildAttribution() {
    return MapboxAttribution(
      mapController: _mapController,
      mapType: _mapType,
    );
  }

  Future<void> _setupMap() async {
    // TODO: Some map settings are cleared when a new map style is loaded, so
    //  we reset the map as a workaround. For more details:
    //  https://github.com/tobrun/flutter-mapbox-gl/issues/349
    _mapController?.onSymbolTapped.remove(_onSymbolTapped);
    _mapController?.onSymbolTapped.add(_onSymbolTapped);
    _mapController?.setSymbolIconAllowOverlap(true);
    if (_didChangeMapType) {
      await _mapController?.clearSymbols();
      _didChangeMapType = false;
    }

    await _updateSymbols(
      selectedFishingSpot:
          _activeFishingSpot ?? _pickerSettings?.controller.value,
    );
    _setupPickerIfNeeded();
    _setupOrUpdateGpsTrail();
  }

  Future<void> _onSymbolTapped(Symbol symbol) async {
    return _selectFishingSpot(symbol.fishingSpot, animateMapMovement: true);
  }

  Future<void> _updateSymbols({
    required FishingSpot? selectedFishingSpot,
  }) async {
    var fishingSpotSymbols = _mapController?.fishingSpotSymbols ?? <Symbol>{};

    // Update and remove symbols, syncing them with FishingSpotManager.
    var symbolsToRemove = <Symbol>[];
    for (var symbol in fishingSpotSymbols) {
      var spot = _fishingSpotManager.entity(symbol.fishingSpot!.id);
      if (spot == null) {
        symbolsToRemove.add(symbol);
      } else {
        symbol.fishingSpot = spot;
        symbol.options = _copySymbolOptions(symbol.options, spot);
      }
    }
    await _mapController?.removeSymbols(symbolsToRemove);

    // Add symbols for new fishing spots.
    var spotsWithoutSymbols = _fishingSpotManager.list().whereNot((spot) =>
        fishingSpotSymbols
            .containsWhere((symbol) => symbol.fishingSpot!.id == spot.id));

    // Iterate all fishing spots without symbols, creating SymbolOptions and
    // data maps so all symbols can be added with one call to the platform
    // channel. A separate call to addSymbol for each symbol is far too slow.
    var options = <SymbolOptions>[];
    var data = <Map<dynamic, dynamic>>[];
    for (var fishingSpot in spotsWithoutSymbols) {
      options.add(createSymbolOptions(
        fishingSpot,
        isActive: selectedFishingSpot?.id == fishingSpot.id,
      ));
      data.add(_Symbols.fishingSpotData(fishingSpot));
    }
    await _mapController?.addSymbols(options, data) ?? [];

    // Need to reset fishingSpotSymbols variable after adding new symbols.
    fishingSpotSymbols = _mapController?.fishingSpotSymbols ?? <Symbol>{};

    // Now that symbols are updated, select the passed in fishing spot.
    FishingSpot? activeFishingSpot = fishingSpotSymbols
        .firstWhereOrNull((s) => s.fishingSpot!.id == selectedFishingSpot?.id)
        ?.fishingSpot;

    // Reset the active symbol to one of the updated symbols.
    _activeSymbol = fishingSpotSymbols
        .firstWhereOrNull((s) => s.fishingSpot!.id == activeFishingSpot?.id);
    if (_hasActiveSymbol) {
      _selectFishingSpot(_activeSymbol!.fishingSpot);
    } else {
      // Ensure we deselect the active fishing spot if it was deleted.
      _selectFishingSpot(null);
    }
  }

  void _updateDroppedPin() {
    var latLng = _mapController?.cameraPosition?.target;
    if (latLng == null) {
      _log.w("Can't update dropped pin with null position");
      return;
    }

    // Camera didn't actually move, no need to do anything.
    if (_hasActiveFishingSpot && _activeFishingSpot!.latLng == latLng) {
      return;
    }

    _log.d("Updating dropped pin");
    _isTargetShowingNotifier.value = false;
    _dropPin(latLng);
  }

  void _updateTarget() {
    if (!_hasActiveDroppedPin) {
      return;
    }

    var isMoving = _mapController?.isCameraMoving;
    if (isMoving == null) {
      return;
    }

    if (isMoving != _isTargetShowingNotifier.value) {
      _isTargetShowingNotifier.value = isMoving;
    }
  }

  void _updateGpsTrail(EntityEvent<GpsTrail> event) {
    if (_isPicking) {
      return;
    }

    _setupOrUpdateGpsTrail();

    // Update FAB.
    if (event.type == GpsTrailEventType.startTracking ||
        event.type == GpsTrailEventType.endTracking) {
      setState(() {});
    }

    if (event.type == GpsTrailEventType.endTracking && event.entity != null) {
      present(context, GpsTrailPage(event.entity!, isPresented: true));
    }
  }

  void _onUserPreferenceUpdate(String event) {
    if (event == UserPreferenceManager.keyMapType) {
      setState(() => _mapType = MapType.of(context));
    }
  }

  Future<void> _setupOrUpdateGpsTrail() async {
    if (_isPicking) {
      return;
    }

    var gpsTrail = _gpsTrailManager.activeTrial;
    if (gpsTrail == null) {
      await _activeTrail?.clear();
      await _mapController?.stopTracking();
      _activeTrail = null;
      return;
    }

    if (_activeTrail == null) {
      _activeTrail = GpsMapTrail(_mapController);
      await _mapController?.startTracking();
    }

    if (context.mounted) {
      await _activeTrail!.draw(context, _gpsTrailManager.activeTrial!);
    }

    // Update the cameras zoom only if needed. Note that you _could_ update
    // latLng here as well, but using updateMyLocationTrackingMode is a
    // smoother animation.
    var zoom = _mapController?.cameraPosition?.zoom;
    if (gpsTrail.points.isNotEmpty &&
        _isTrackingUser &&
        (zoom == null || zoom != mapZoomFollowingUser)) {
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target: gpsTrail.points.last.latLng,
          zoom: mapZoomFollowingUser,
        )),
      );
    }
  }

  /// Drops a pin at an existing fishing spot near [latLng], at [spot] if a
  /// nearby spot doesn't exist, or at [latLng] as a brand new, unsaved, spot.
  Future<void> _dropPin(LatLng latLng, [FishingSpot? spot]) async {
    // Select an existing fishing spot if found within the user's radius.
    var fishingSpot = _fishingSpotManager.withinPreferenceRadius(latLng);

    if (fishingSpot == null) {
      // Add a new pin to the map.
      fishingSpot = spot ?? FishingSpot()
        ..id = _didAddFishingSpot
            ? randomId()
            : _activeFishingSpot?.id ?? randomId()
        ..lat = latLng.latitude
        ..lng = latLng.longitude;
      await _mapController?.addSymbol(
        createSymbolOptions(
          fishingSpot,
          isActive: true,
        ),
        _Symbols.fishingSpotData(fishingSpot),
      );
      _didAddFishingSpot = false;
    }

    // Select the new pin.
    _selectFishingSpot(fishingSpot, animateMapMovement: true);
    _pickerSettings?.controller.value = fishingSpot;
  }

  SymbolOptions _copySymbolOptions(SymbolOptions options, FishingSpot spot) {
    return SymbolOptions(
      geometry: spot.latLng,
      iconImage: options.iconImage,
      iconSize: options.iconSize,
      draggable: options.draggable,
    );
  }

  Future<void> _selectFishingSpot(
    FishingSpot? fishingSpot, {
    bool animateMapMovement = false,
    // When true and fishingSpot == null, the current fishing spot widget is
    // animated out of view.
    bool dismissIfNull = false,
  }) async {
    var newActiveSymbol = _activeSymbol;
    var newIsDismissingFishingSpot = _isDismissingFishingSpot;
    var newOldFishingSpot = _oldFishingSpot;

    if (_isDroppedPin) {
      // Remove the current dropped pin, if one exists.
      if (_hasActiveSymbol) {
        await _mapController?.removeSymbol(_activeSymbol!);
      }
      newActiveSymbol = null;
    } else if (_hasActiveFishingSpot) {
      // Mark the active symbol as inactive.
      await _mapController?.updateSymbol(
        _activeSymbol!,
        SymbolOptions(
          // If the active symbol didn't change, keep the same icon.
          iconImage: _activeFishingSpot!.id == fishingSpot?.id
              ? mapPinActive
              : mapPinInactive,
        ),
      );
    }

    if (fishingSpot == null) {
      newActiveSymbol = null;

      if (dismissIfNull) {
        newOldFishingSpot = _activeSymbol?.fishingSpot;
        newIsDismissingFishingSpot = newOldFishingSpot != null;
      } else {
        newIsDismissingFishingSpot = false;
      }
    } else {
      // Find the symbol associated with the given fishing spot.
      newActiveSymbol = _mapController?.symbols
          .firstWhereOrNull((s) => fishingSpot.id == s.fishingSpot?.id);

      if (newActiveSymbol == null) {
        _log.e(StackTrace.current,
            "Couldn't find symbol associated with fishing spot");
      } else {
        // Update map.
        await _mapController?.updateSymbol(
          newActiveSymbol,
          const SymbolOptions(iconImage: mapPinActive),
        );

        _moveMap(
          newActiveSymbol.latLng,
          animate: animateMapMovement,
          zoomToDefault: false,
        );
      }
    }

    // The map may be refreshed while being disposed (for example, as part of
    // a listener being notified). Ensure it is still safe to update.
    safeUseContext(
      this,
      () => setState(() {
        _activeSymbol = newActiveSymbol;
        _isDismissingFishingSpot = newIsDismissingFishingSpot;
        _oldFishingSpot = newOldFishingSpot;
      }),
    );
  }

  void _setupPickerIfNeeded() {
    if (!_isPicking || _hasActiveSymbol) {
      return;
    }

    // If the picked spot isn't already selected, it means it doesn't exist,
    // so drop a pin. Note that _dropPin checks for existing fishing spots that
    // are close by.
    var selectedValue = _pickerSettings?.controller.value;
    if (selectedValue != null) {
      _dropPin(selectedValue.latLng, selectedValue);
      return;
    }

    // If there is no picker value, fallback on the user's current location.
    _dropPin(_locationMonitor.currentLatLng ?? const LatLng(0, 0));
  }

  Future<void> _moveMap(
    LatLng latLng, {
    bool animate = true,
    bool zoomToDefault = false,
  }) async {
    // The map is already at the desired position, no need to do anything.
    if (_mapController?.cameraPosition?.target == latLng) {
      return;
    }

    var zoom = _mapController?.cameraPosition?.zoom;
    if (zoom == null || zoomToDefault) {
      zoom = mapZoomDefault;
    }

    var update = CameraUpdate.newCameraPosition(CameraPosition(
      target: latLng,
      zoom: zoom,
    ));

    if (animate) {
      await _mapController?.animateCamera(update);
    } else {
      await _mapController?.moveCamera(update);
    }
  }
}

class FishingSpotMapPickerSettings {
  late final InputController<FishingSpot> controller;

  /// When non-null, a "NEXT" button is rendered in the search bar.
  final VoidCallback? onNext;

  final bool isStatic;

  FishingSpotMapPickerSettings({
    required this.controller,
    this.onNext,
    this.isStatic = false,
  });

  FishingSpotMapPickerSettings._static(FishingSpot fishingSpot)
      : this(
          controller: InputController<FishingSpot>()..value = fishingSpot,
          isStatic: true,
        );
}

extension _Symbols on Symbol {
  static const _keyFishingSpot = "fishing_spot";

  static Map<dynamic, dynamic> fishingSpotData(FishingSpot fishingSpot) {
    return {
      _keyFishingSpot: fishingSpot,
    };
  }

  bool get hasFishingSpot => fishingSpot != null;

  FishingSpot? get fishingSpot => data?[_keyFishingSpot];

  set fishingSpot(FishingSpot? fishingSpot) =>
      data?[_keyFishingSpot] = fishingSpot;

  LatLng get latLng => options.geometry!;
}

extension _MapboxMapControllers on MapboxMapController {
  Iterable<Symbol> get fishingSpotSymbols =>
      symbols.where((e) => e.hasFishingSpot);
}
