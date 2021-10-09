import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
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
import '../res/style.dart';
import '../utils/dialog_utils.dart';
import '../utils/map_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/button.dart';
import '../widgets/search_bar.dart';
import '../widgets/widget.dart';
import '../wrappers/io_wrapper.dart';
import '../wrappers/permission_handler_wrapper.dart';
import '../wrappers/url_launcher_wrapper.dart';
import 'bottom_sheet_picker.dart';
import 'checkbox_input.dart';
import 'fishing_spot_details.dart';
import 'input_controller.dart';
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
      : pickerSettings = FishingSpotMapPickerSettings._static(fishingSpot),
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
      : pickerSettings = FishingSpotMapPickerSettings._static(fishingSpot),
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
  static const _mapStyleNormal =
      "mapbox://styles/cohenadair/ckt1zqb8d1h1p17pglx4pmz4y/draft";
  static const _mapStyleSatellite =
      "mapbox://styles/cohenadair/ckt1m613b127t17qqf3mmw47h/draft";
  static const _pinActive = "active-pin";
  static const _pinInactive = "inactive-pin";
  static const _pinSize = 1.5;
  static const _zoomDefault = 13.0;

  /// An arbitrary value used to calculate how much to offset the map's position
  /// based on the size of the fishing spot widget being shown.
  static const _fishingSpotDetailOffsetFactor = 0.00004117647059;

  final _fishingSpotKey = GlobalKey();

  final _log = Log("FishingSpotMap");

  // Wait for navigation animations to finish before loading the map. This
  // allows for a smooth animation.
  late final Future<bool> _mapFuture;

  late MapboxMapController _mapController;

  Symbol? _activeSymbol;
  Timer? _hideHelpTimer;

  var _currentStyle = _mapStyleNormal;
  bool _showHelp = false;
  bool _myLocationEnabled = true;
  bool _isSetup = false;
  bool _isTelemetryEnabled = true;

  // Displayed while dismissing the fishing spot container.
  FishingSpot? _oldFishingSpot;

  // Used to display old data during animations and async operations.
  bool _isDismissingFishingSpot = false;

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  LocationMonitor get _locationMonitor => LocationMonitor.of(context);

  PermissionHandlerWrapper get _permissionHandlerWrapper =>
      PermissionHandlerWrapper.of(context);

  PropertiesManager get _propertiesManager => PropertiesManager.of(context);

  FishingSpotMapPickerSettings? get _pickerSettings => widget.pickerSettings;

  bool get _hasActiveSymbol => _activeSymbol != null;

  bool get _isPicking => _pickerSettings != null;

  bool get _isStatic => widget._isStatic;

  bool get _isDroppedPin =>
      !_fishingSpotManager.entityExists(_activeSymbol?.fishingSpot.id);

  FishingSpot? get _activeFishingSpot => _activeSymbol?.fishingSpot;

  @override
  void initState() {
    super.initState();

    _myLocationEnabled = !_isStatic && _locationMonitor.currentLocation != null;
    _mapFuture = Future.delayed(Duration(milliseconds: 300), () => true);

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
      _updateSymbols().then(
        (_) => _selectFishingSpot(_pickerSettings?.controller.value),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _hideHelpTimer?.cancel();
    _mapController.onSymbolTapped.remove(_onSymbolTapped);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _pickerSettings?.controller.value = _activeSymbol?.fishingSpot;
        return Future.value(true);
      },
      child: EntityListenerBuilder(
        managers: [_fishingSpotManager],
        onAnyChange: _updateSymbols,
        builder: (context) {
          var stack = Stack(
            children: [_buildMap()]
              ..addAll(widget.children)
              ..add(_buildNoSelectionMapAttribution())
              ..add(_buildFishingSpot())
              ..add(
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildSearchBar(),
                      _buildMapStyleButton(),
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
    return EmptyFutureBuilder<bool>(
      future: _mapFuture,
      builder: (context, _) {
        var start = _activeSymbol?.fishingSpot.latLng ??
            _pickerSettings?.controller.value?.latLng ??
            _locationMonitor.currentLocation ??
            LatLng(0, 0);

        return IgnorePointer(
          ignoring: _isStatic,
          child: MapboxMap(
            accessToken: _propertiesManager.mapboxApiKey,
            // Hide default attribution views, so we can show our own and
            // position them easier.
            attributionButtonMargins: Point(0, -1000),
            logoViewMargins: Point(0, -1000),
            myLocationEnabled: _myLocationEnabled,
            styleString: _currentStyle,
            initialCameraPosition: CameraPosition(
              target: _offsetLatLng(start),
              zoom: start.latitude == 0 ? 0 : _zoomDefault,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onMapLongClick: (_, latLng) => _dropPin(latLng),
            onStyleLoadedCallback: _onMapStyleLoaded,
          ),
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
    if (_hasActiveSymbol) {
      if (_fishingSpotManager.entityExists(_activeSymbol!.fishingSpot.id)) {
        // Showing active fishing spot.
        name = _activeSymbol!.fishingSpot.displayName(
          context,
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
          padding: insetsRightWidgetSmall,
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
      leading = BackButton();
    } else {
      trailing = AnimatedVisibility(
        visible: isNotEmpty(name),
        child: IconButton(
          icon: Icon(Icons.clear),
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
      return Empty();
    }

    return FloatingButton.icon(
      icon: Icons.layers,
      onPressed: () {
        showBottomSheetPicker(
          context,
          (context) => BottomSheetPicker<String>(
            currentValue: _currentStyle,
            items: {
              Strings.of(context).mapPageMapTypeNormal: _mapStyleNormal,
              Strings.of(context).mapPageMapTypeSatellite: _mapStyleSatellite,
            },
            onPicked: (newStyle) {
              if (newStyle == _currentStyle) {
                return;
              }
              setState(() => _currentStyle = newStyle ?? _mapStyleNormal);
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
          _moveMap(currentLocation);
          setState(() {
            _myLocationEnabled = true;
            if (_isPicking) {
              _dropPin(currentLocation);
            } else {
              _selectFishingSpot(null, dismissIfNull: true);
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
        var bounds = mapBounds(_fishingSpotManager.list());
        if (bounds == null) {
          return;
        }
        _mapController.animateCamera(CameraUpdate.newLatLngBounds(
          bounds,
          left: paddingDefaultDouble,
          right: paddingDefaultDouble,
          top: paddingDefaultDouble,
          bottom: paddingDefaultDouble,
        ));
      },
    );
  }

  Widget _buildHelpButton() {
    if (!widget.showHelpButton) {
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
      onPressed: () => setState(() => _showHelp = !_showHelp),
    );
  }

  Widget _buildHelp() {
    return HelpTooltip(
      margin: insetsHorizontalDefault,
      showing: _showHelp,
      child: Text(
        _isPicking
            ? Strings.of(context).fishingSpotPickerPageHint
            : Strings.of(context).fishingSpotMapAddSpotHelp,
        style: styleLight,
      ),
    );
  }

  Widget _buildFishingSpot() {
    var fishingSpot = _activeFishingSpot;
    if (_isDismissingFishingSpot && _oldFishingSpot != null) {
      fishingSpot = _oldFishingSpot;
    }

    // If the map isn't yet setup, but there's a picked spot, use that for
    // rendering. This allows us to calculate the padding for Mapbox
    // attributions.
    if (fishingSpot == null && !_isSetup) {
      fishingSpot = _pickerSettings?.controller.value;
    }

    Widget details = Empty();
    if (fishingSpot != null) {
      details = Padding(
        padding: insetsTopWidgetSmall,
        child: FishingSpotDetails(
          fishingSpot,
          containerKey: _fishingSpotKey,
          isDroppedPin: _isDroppedPin,
          isPicking: _isPicking,
          showActionButtons: widget.showFishingSpotActionButtons,
        ),
      );
    }

    var container = Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
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

    if (_isStatic) {
      return container;
    }

    return SafeArea(
      child: SlideUpTransition(
        isVisible: !_isDismissingFishingSpot && fishingSpot != null,
        onDismissed: () => _selectFishingSpot(null),
        child: container,
      ),
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
      logoColor: _currentStyle == _mapStyleNormal ? Colors.black : Colors.white,
      isTelemetryEnabled: _isTelemetryEnabled,
      onTelemetryToggled: (enabled) async {
        await _mapController.setTelemetryEnabled(enabled);
        _isTelemetryEnabled = await _mapController.getTelemetryEnabled();
        setState(() {});
      },
    );
  }

  Future<void> _onMapStyleLoaded() async {
    // TODO: Some map settings are cleared when a new map style is loaded, so we
    //  reset the map as a workaround. For more details:
    //  https://github.com/tobrun/flutter-mapbox-gl/issues/349
    _mapController.onSymbolTapped.remove(_onSymbolTapped);
    _mapController.onSymbolTapped.add(_onSymbolTapped);
    _mapController.setSymbolIconAllowOverlap(true);
    _isTelemetryEnabled = await _mapController.getTelemetryEnabled();

    await _updateSymbols();

    // If the map has already been setup, it means a new map style was selected
    // by the user. In this case, reselect the active fishing spot.
    if (_isSetup) {
      _selectFishingSpot(_activeFishingSpot);
    } else {
      _setupPicker();
      _isSetup = true;
    }
  }

  Future<void> _onSymbolTapped(Symbol symbol) async {
    return _selectFishingSpot(symbol.fishingSpot, animateMapMovement: true);
  }

  Future<void> _updateSymbols() async {
    _mapController.clearSymbols();

    var options = <SymbolOptions>[];
    var data = <Map<dynamic, dynamic>>[];

    // Iterate all fishing spots, creating SymbolOptions and data maps so all
    // symbols can be added with one call to the platform channel.
    for (var fishingSpot in _fishingSpotManager.list()) {
      if (_isStatic && _pickerSettings?.controller.value != fishingSpot) {
        continue;
      }

      options.add(_createSymbolOptions(fishingSpot));
      data.add(_Symbols.fishingSpotData(fishingSpot));
    }

    var symbols = await _mapController.addSymbols(options, data);

    // Reset the active symbol to one of the newly created symbols.
    if (_hasActiveSymbol) {
      _activeSymbol = symbols.firstWhereOrNull(
          (s) => s.fishingSpot.id == _activeSymbol!.fishingSpot.id);
      if (_hasActiveSymbol) {
        _selectFishingSpot(_activeSymbol!.fishingSpot);
      }
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
      await _mapController.addSymbol(
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
        await _mapController.removeSymbol(_activeSymbol!);
      }
      newActiveSymbol = null;
    } else if (_hasActiveSymbol) {
      // Mark the active symbol as inactive.
      await _mapController.updateSymbol(
        _activeSymbol!,
        SymbolOptions(iconImage: _pinInactive),
      );
    }

    if (fishingSpot == null) {
      newActiveSymbol = null;

      if (dismissIfNull) {
        newOldFishingSpot = _activeSymbol?.fishingSpot;
        newIsDismissingFishingSpot = true;
      } else {
        newIsDismissingFishingSpot = false;
      }
    } else {
      // Find the symbol associated with the given fishing spot.
      newActiveSymbol = _mapController.symbols
          .firstWhereOrNull((s) => s.fishingSpot.id == fishingSpot.id);

      if (newActiveSymbol == null) {
        _log.e("Couldn't find symbol associated with fishing spot");
      } else {
        // Update map.
        await _mapController.updateSymbol(
          newActiveSymbol,
          SymbolOptions(iconImage: _pinActive),
        );

        _moveMap(newActiveSymbol.latLng, animate: animateMapMovement);
      }
    }

    setState(() {
      _activeSymbol = newActiveSymbol;
      _isDismissingFishingSpot = newIsDismissingFishingSpot;
      _oldFishingSpot = newOldFishingSpot;
    });
  }

  void _setupPicker() {
    if (!_isPicking) {
      return;
    }

    // Select the current fishing spot if it exists in the database.
    var selectedValue = _pickerSettings?.controller.value;
    if (_fishingSpotManager.entityExists(selectedValue?.id)) {
      _selectFishingSpot(_pickerSettings?.controller.value);
      return;
    }

    // If the picked spot doesn't exist, drop a pin. Note that _dropPin
    // checks for existing fishing spots that are close by.
    if (selectedValue != null) {
      _dropPin(selectedValue.latLng);
      return;
    }

    // If there is no picker value, fallback on the user's current location.
    _dropPin(_locationMonitor.currentLocation ?? LatLng(0, 0));
  }

  /// Offsets [latLng] to account for the height of the fishing spot widget.
  /// This should only be used when setting the map position, not when creating
  /// [Symbol] instances.
  LatLng _offsetLatLng(LatLng latLng) {
    var offset = 0.0;
    if (_fishingSpotKey.currentContext != null) {
      var fishingSpotBox =
          _fishingSpotKey.currentContext!.findRenderObject() as RenderBox;
      offset = fishingSpotBox.size.height * _fishingSpotDetailOffsetFactor;
    }

    return LatLng(latLng.latitude - offset, latLng.longitude);
  }

  void _moveMap(LatLng latLng, {bool animate = true}) {
    var update = CameraUpdate.newCameraPosition(CameraPosition(
      target: _offsetLatLng(latLng),
      zoom: _zoomDefault,
    ));

    if (animate) {
      _mapController.animateCamera(update);
    } else {
      _mapController.moveCamera(update);
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
              child: FishingSpotMap._static(fishingSpot),
            ),
          ],
        ),
      ),
    );
  }
}

extension _Symbols on Symbol {
  static const _keyFishingSpot = "fishing_spot";

  static Map<dynamic, dynamic> fishingSpotData(FishingSpot fishingSpot) {
    return {
      _keyFishingSpot: fishingSpot,
    };
  }

  FishingSpot get fishingSpot => data![_keyFishingSpot] as FishingSpot;

  LatLng get latLng => options.geometry!;
}

class MapboxAttribution extends StatelessWidget {
  static const _urlMapbox = "https://www.mapbox.com/about/maps/";
  static const _urlOpenStreetMap = "http://www.openstreetmap.org/copyright";
  static const _urlImproveThisMap = "https://www.mapbox.com/map-feedback/";
  static const _urlMaxar = "https://www.maxar.com/";

  static const _size = Size(85, 20);

  final Color logoColor;
  final void Function(bool) onTelemetryToggled;
  final bool isTelemetryEnabled;

  MapboxAttribution({
    required this.logoColor,
    required this.onTelemetryToggled,
    required this.isTelemetryEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: _size.width,
          height: _size.height,
          child: SvgPicture.asset(
            "assets/mapbox-logo.svg",
            color: logoColor,
          ),
        ),
        MinimumIconButton(
          icon: Icons.info_outline,
          onTap: () => showBottomSheetPicker(
            context,
            _buildPicker,
          ),
        ),
      ],
    );
  }

  BottomSheetPicker _buildPicker(BuildContext context) {
    return BottomSheetPicker<String>(
      title: IoWrapper.of(context).isAndroid
          ? Strings.of(context).mapAttributionTitleAndroid
          : Strings.of(context).mapAttributionTitleApple,
      itemStyle: styleHyperlink,
      items: {
        Strings.of(context).mapAttributionMapbox: _urlMapbox,
        Strings.of(context).mapAttributionOpenStreetMap: _urlOpenStreetMap,
        Strings.of(context).mapAttributionImproveThisMap: _urlImproveThisMap,
        Strings.of(context).mapAttributionMaxar: _urlMaxar,
      },
      onPicked: (url) => UrlLauncherWrapper.of(context).launch(url!),
      footer: CheckboxInput(
        label: Strings.of(context).mapAttributionTelemetryTitle,
        description: Strings.of(context).mapAttributionTelemetryDescription,
        value: isTelemetryEnabled,
        onChanged: onTelemetryToggled,
      ),
    );
  }
}
