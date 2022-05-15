import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:mobile/widgets/our_bottom_sheet.dart';
import 'package:mobile/wrappers/device_info_wrapper.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import 'package:quiver/strings.dart';

import '../entity_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../location_monitor.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/fishing_spot_list_page.dart';
import '../properties_manager.dart';
import '../res/dimen.dart';
import '../res/gen/custom_icons.dart';
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
import 'mapbox_attribution.dart';
import 'slide_up_transition.dart';

/// A [GoogleMap] wrapper that listens and responds to [FishingSpot] changes.
/// For a smaller, static map, use [StaticFishingSpotMap].
class FishingSpotMap extends StatefulWidget {
  /// When non-null, sets up the map as an input picker.
  late final FishingSpotMapPickerSettings? pickerSettings;

  final bool showSearchBar;
  final bool showMyLocationButton;
  final bool showZoomExtentsButton;
  final bool showMapTypeButton;
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
    this.showFishingSpotActionButtons = true,
    this.children = const [],
    this.isPage = true,
  });

  /// A fishing spot page, with [fishingSpot] already selected.
  FishingSpotMap.selected(FishingSpot fishingSpot)
      : pickerSettings = FishingSpotMapPickerSettings._static(fishingSpot),
        showSearchBar = false,
        showMyLocationButton = true,
        showZoomExtentsButton = true,
        showMapTypeButton = true,
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
  _FishingSpotMapState createState() => _FishingSpotMapState();
}

class _FishingSpotMapState extends State<FishingSpotMap> {
  static const _pinActive = "active-pin";
  static const _pinInactive = "inactive-pin";
  static const _pinSize = 1.25;
  static const _zoomDefault = 13.0;

  static const _log = Log("FishingSpotMap");

  final _fishingSpotKey = GlobalKey();
  final _mapKey = GlobalKey();
  final _isTargetShowingNotifier = ValueNotifier<bool>(false);

  // Wait for navigation animations to finish before loading the map. This
  // allows for a smooth animation.
  late final Future<bool> _mapFuture;

  MapboxMapController? _mapController;
  late MapType _mapType;

  Symbol? _activeSymbol;

  bool _myLocationEnabled = true;
  bool _isTelemetryEnabled = true;
  bool _didChangeMapType = false;

  // Displayed while dismissing the fishing spot container.
  FishingSpot? _oldFishingSpot;

  // Used to display old data during animations and async operations.
  bool _isDismissingFishingSpot = false;

  DeviceInfoWrapper get _deviceInfoWrapper => DeviceInfoWrapper.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  IoWrapper get _ioWrapper => IoWrapper.of(context);

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);

  PermissionHandlerWrapper get _permissionHandlerWrapper =>
      PermissionHandlerWrapper.of(context);

  PropertiesManager get _propertiesManager => PropertiesManager.of(context);

  UserPreferenceManager get _userPreferenceManager =>
      UserPreferenceManager.of(context);

  FishingSpotMapPickerSettings? get _pickerSettings => widget.pickerSettings;

  bool get _hasActiveSymbol => _activeSymbol != null;

  bool get _hasActiveDroppedPin => _hasActiveSymbol && _isDroppedPin;

  bool get _isPicking => _pickerSettings != null;

  bool get _isDroppedPin =>
      !_fishingSpotManager.entityExists(_activeSymbol?.fishingSpot.id);

  FishingSpot? get _activeFishingSpot => _activeSymbol?.fishingSpot;

  @override
  void initState() {
    super.initState();

    _mapType = MapType.fromContext(context);
    _myLocationEnabled = _locationMonitor.currentLocation != null;
    _mapFuture = Future.delayed(const Duration(milliseconds: 300), () => true);
    _setupHybridComposition();

    // Refresh state so Mapbox attribution padding is updated. This needs to be
    // done after the fishing spot widget is rendered.
    WidgetsBinding.instance?.addPostFrameCallback((_) => setState(() {}));
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
  void dispose() {
    super.dispose();
    _mapController?.onSymbolTapped.remove(_onSymbolTapped);
    _mapController?.removeListener(_updateTarget);
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
                _buildAddButton(),
              ],
            ),
          ),
        ]);

        return widget.isPage ? Scaffold(body: stack) : stack;
      },
    );

    // WillPopScope overrides the default "swipe to go back" behavior on iOS.
    // Only allow this behavior use it when we're not showing a static map.
    return WillPopScope(
      onWillPop: () {
        _pickerSettings?.controller.value = _activeSymbol?.fishingSpot;
        return Future.value(true);
      },
      child: map,
    );
  }

  Widget _buildMap() {
    return EmptyFutureBuilder<bool>(
      future: _mapFuture,
      builder: (context, _) {
        var start = _activeSymbol?.fishingSpot.latLng ??
            _pickerSettings?.controller.value?.latLng ??
            _locationMonitor.currentLocation ??
            const LatLng(0, 0);

        return MapboxMap(
          key: _mapKey,
          accessToken: _propertiesManager.mapboxApiKey,
          // Hide default attribution views, so we can show our own and
          // position them easier.
          attributionButtonMargins: const Point(0, -1000),
          logoViewMargins: const Point(0, -1000),
          myLocationEnabled: _myLocationEnabled,
          styleString: _mapType.url,
          initialCameraPosition: CameraPosition(
            target: start,
            zoom: start.latitude == 0 ? 0 : _zoomDefault,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            _mapController?.addListener(_updateTarget);
          },
          onStyleLoadedCallback: _setupMap,
          onCameraIdle: () {
            if (_hasActiveDroppedPin) {
              _updateDroppedPin();
            }
          },
          trackCameraPosition: true,
          compassEnabled: false,
        );
      },
    );
  }

  Widget _buildSearchBar() {
    if (!widget.showSearchBar) {
      // Row so it extends across the page.
      return Row(children: const [Empty()]);
    }

    String? name;
    if (_hasActiveSymbol) {
      if (_fishingSpotManager.entityExists(_activeSymbol!.fishingSpot.id)) {
        // Showing active fishing spot.
        name = _fishingSpotManager.displayName(
          context,
          _activeSymbol!.fishingSpot,
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
            textColor: Theme.of(context).primaryColor,
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
      onPressed: () {
        showOurBottomSheet(
          context,
          (context) => BottomSheetPicker<MapType>(
            currentValue: _mapType,
            items: {
              Strings.of(context).mapPageMapTypeNormal: MapType.normal,
              Strings.of(context).mapPageMapTypeSatellite: MapType.satellite,
            },
            onPicked: (newType) {
              if (newType == _mapType) {
                return;
              }
              setState(() {
                _mapType = newType ?? MapType.normal;
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
          setState(() {
            _myLocationEnabled = true;
          });

          if (_isPicking) {
            await _dropPin(currentLocation);
          } else {
            await _selectFishingSpot(null, dismissIfNull: true);
          }

          // Move map after pin changes so widgets are hidden/shown correctly.
          _moveMap(currentLocation, zoomToDefault: true);
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
      icon: Icons.zoom_out_map,
      onPressed: () async {
        var bounds = mapBounds(_fishingSpotManager.list());
        if (bounds == null) {
          return;
        }

        await _selectFishingSpot(null, dismissIfNull: true);

        // Move map after updating fishing spot so widgets are hidden/shown
        // correctly.
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
          bounds,
          left: paddingXL,
          right: paddingXL,
          top: paddingXL,
          bottom: paddingXL,
        ));
      },
    );
  }

  Widget _buildAddButton() {
    return FloatingButton.icon(
      padding: const EdgeInsets.only(
        left: paddingDefault,
        right: paddingDefault,
        bottom: paddingDefault,
      ),
      icon: Icons.add,
      onPressed: _updateDroppedPin,
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
        return AnimatedVisibility(
          visible: isShowing,
          child: Center(
            child: Icon(
              CustomIcons.mapTarget,
              color: mapIconColor(_mapType),
            ),
          ),
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
      mapType: _mapType,
      telemetry: MapboxTelemetry(
        isEnabled: _isTelemetryEnabled,
        onTogged: (enabled) async {
          await _mapController?.setTelemetryEnabled(enabled);
          _isTelemetryEnabled =
              await _mapController?.getTelemetryEnabled() ?? false;
          setState(() {});
        },
      ),
    );
  }

  Future<void> _setupMap() async {
    // TODO: Some map settings are cleared when a new map style is loaded, so
    //  we reset the map as a workaround. For more details:
    //  https://github.com/tobrun/flutter-mapbox-gl/issues/349
    _mapController?.onSymbolTapped.remove(_onSymbolTapped);
    _mapController?.onSymbolTapped.add(_onSymbolTapped);
    _mapController?.setSymbolIconAllowOverlap(true);
    _mapController
        ?.getTelemetryEnabled()
        .then((value) => _isTelemetryEnabled = value);
    if (_didChangeMapType) {
      await _mapController?.clearSymbols();
      _didChangeMapType = false;
    }

    await _updateSymbols(
      selectedFishingSpot:
          _activeFishingSpot ?? _pickerSettings?.controller.value,
    );
    _setupPickerIfNeeded();
  }

  Future<void> _onSymbolTapped(Symbol symbol) async {
    return _selectFishingSpot(symbol.fishingSpot, animateMapMovement: true);
  }

  Future<void> _updateSymbols({
    required FishingSpot? selectedFishingSpot,
  }) async {
    // Update and remove symbols, syncing them with FishingSpotManager.
    var symbolsToRemove = <Symbol>[];
    for (var symbol in _mapController?.symbols ?? <Symbol>{}) {
      var spot = _fishingSpotManager.entity(symbol.fishingSpot.id);
      if (spot == null) {
        symbolsToRemove.add(symbol);
      } else {
        symbol.fishingSpot = spot;
      }
    }
    await _mapController?.removeSymbols(symbolsToRemove);

    // Add symbols for new fishing spots.
    var spotsWithoutSymbols = _fishingSpotManager.list().whereNot((spot) =>
        _mapController?.symbols
            .containsWhere((symbol) => symbol.fishingSpot.id == spot.id) ??
        true);

    // Iterate all fishing spots without symbols, creating SymbolOptions and
    // data maps so all symbols can be added with one call to the platform
    // channel. A separate call to addSymbol for each symbol is far too slow.
    var options = <SymbolOptions>[];
    var data = <Map<dynamic, dynamic>>[];
    for (var fishingSpot in spotsWithoutSymbols) {
      options.add(_createSymbolOptions(
        fishingSpot,
        isActive: selectedFishingSpot?.id == fishingSpot.id,
      ));
      data.add(_Symbols.fishingSpotData(fishingSpot));
    }
    await _mapController?.addSymbols(options, data) ?? [];

    // Now that symbols are updated, select the passed in fishing spot.
    FishingSpot? activeFishingSpot = _mapController?.symbols
        .firstWhereOrNull((s) => s.fishingSpot.id == selectedFishingSpot?.id)
        ?.fishingSpot;

    // Reset the active symbol to one of the updated symbols.
    _activeSymbol = _mapController?.symbols
        .firstWhereOrNull((s) => s.fishingSpot.id == activeFishingSpot?.id);
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

  Future<void> _dropPin(LatLng latLng) async {
    // Select an existing fishing spot if
    var fishingSpot = _fishingSpotManager.withinRadius(latLng);

    if (fishingSpot == null) {
      // Add a new pin to the map.
      fishingSpot = FishingSpot()
        ..id = randomId()
        ..lat = latLng.latitude
        ..lng = latLng.longitude;
      await _mapController?.addSymbol(
        _createSymbolOptions(
          fishingSpot,
          isActive: true,
        ),
        _Symbols.fishingSpotData(fishingSpot),
      );
    }

    // Select the new pin.
    _selectFishingSpot(fishingSpot, animateMapMovement: true);
  }

  SymbolOptions _createSymbolOptions(
    FishingSpot fishingSpot, {
    bool isActive = false,
  }) {
    return SymbolOptions(
      geometry: fishingSpot.latLng,
      iconImage: isActive ? _pinActive : _pinInactive,
      iconSize: _pinSize,
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
    } else if (_hasActiveSymbol) {
      // Mark the active symbol as inactive.
      await _mapController?.updateSymbol(
        _activeSymbol!,
        SymbolOptions(
          // If the active symbol didn't change, keep the same icon.
          iconImage: _activeSymbol?.fishingSpot.id == fishingSpot?.id
              ? _pinActive
              : _pinInactive,
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
          .firstWhereOrNull((s) => s.fishingSpot.id == fishingSpot.id);

      if (newActiveSymbol == null) {
        _log.e(StackTrace.current,
            "Couldn't find symbol associated with fishing spot");
      } else {
        // Update map.
        await _mapController?.updateSymbol(
          newActiveSymbol,
          const SymbolOptions(iconImage: _pinActive),
        );

        _moveMap(
          newActiveSymbol.latLng,
          animate: animateMapMovement,
          zoomToDefault: false,
        );
      }
    }

    // The map may be refreshed while being disposed (for example, as part of
    // a listener being notified). Ensure it is still mounted before updating
    // the state.
    if (mounted) {
      setState(() {
        _activeSymbol = newActiveSymbol;
        _isDismissingFishingSpot = newIsDismissingFishingSpot;
        _oldFishingSpot = newOldFishingSpot;
      });
    }
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
      _dropPin(selectedValue.latLng);
      return;
    }

    // If there is no picker value, fallback on the user's current location.
    _dropPin(_locationMonitor.currentLocation ?? const LatLng(0, 0));
  }

  Future<void> _setupHybridComposition() async {
    if (!_ioWrapper.isAndroid) {
      return;
    }

    // Disabling hybrid composition improves performance on Android 9 devices.
    var sdkVersion = (await _deviceInfoWrapper.androidInfo).version.sdkInt;
    MapboxMap.useHybridComposition = sdkVersion != null && sdkVersion >= 29;
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
      zoom = _zoomDefault;
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

  FishingSpotMapPickerSettings({
    required this.controller,
    this.onNext,
  });

  FishingSpotMapPickerSettings._static(FishingSpot fishingSpot)
      : this(
          controller: InputController<FishingSpot>()..value = fishingSpot,
        );
}

extension _Symbols on Symbol {
  static const _keyFishingSpot = "fishing_spot";

  static Map<dynamic, dynamic> fishingSpotData(FishingSpot fishingSpot) {
    return {
      _keyFishingSpot: fishingSpot,
    };
  }

  FishingSpot get fishingSpot => data![_keyFishingSpot] as FishingSpot;

  set fishingSpot(FishingSpot fishingSpot) =>
      data![_keyFishingSpot] = fishingSpot;

  LatLng get latLng => options.geometry!;
}
