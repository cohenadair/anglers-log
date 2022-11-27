import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/properties_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/fishing_spot_details.dart';
import 'package:mobile/widgets/mapbox_attribution.dart';
import 'package:mobile/wrappers/http_wrapper.dart';

import '../log.dart';
import '../utils/network_utils.dart';
import 'fishing_spot_map.dart';
import 'safe_image.dart';

/// A widget that displays [FishingSpot] details on a constrained map.
///
/// See:
///  - [FishingSpotMap]
///  - [EditCoordinatesPage]
///  - [DefaultMapboxMap]
class StaticFishingSpotMap extends StatefulWidget {
  final FishingSpot fishingSpot;
  final EdgeInsets? padding;

  const StaticFishingSpotMap(
    this.fishingSpot, {
    this.padding,
  });

  @override
  State<StaticFishingSpotMap> createState() => _StaticFishingSpotMapState();
}

class _StaticFishingSpotMapState extends State<StaticFishingSpotMap> {
  // Enforced by Static Maps API. This size can be increased with the @2x
  // parameter, but support for larger scales isn't available yet.
  static const _maxImagePixels = 1280.0;
  static const _mapHeight = 200.0;
  static const _mapZoom = 11;
  static const _pinSize = 25.0;
  static const _mapboxBaseUrl = "https://api.mapbox.com/styles/v1/cohenadair";

  static const _log = Log("StaticFishingSpotMap");

  late Future<Uint8List?> _imageFuture;
  late Size _imageSize;
  late MapType _mapType;

  HttpWrapper get _httpWrapper => HttpWrapper.of(context);

  ImageManager get _imageManager => ImageManager.of(context);

  MediaQueryData get _mediaQuery => MediaQuery.of(context);

  PropertiesManager get _propertiesManager => PropertiesManager.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _imageSize = Size(
      max(0, _mediaQuery.size.width - (widget.padding?.horizontal ?? 0)),
      max(0, _mapHeight - (widget.padding?.vertical ?? 0)),
    );
    _mapType = MapType.of(context);
    _imageFuture = _fetchImage();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => push(context, FishingSpotMap.selected(widget.fishingSpot)),
      child: Column(
        children: [
          Container(
            padding: insetsHorizontalDefaultTopDefault,
            width: double.infinity,
            height: _mapHeight,
            child: ClipRRect(
              borderRadius: defaultBorderRadius,
              child: Stack(children: [
                Positioned.fill(child: _buildImage()),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: insetsSmall,
                    child: MapboxAttribution(mapType: _mapType),
                  ),
                ),
                Center(
                  child: SvgPicture.asset(
                    "assets/active-pin.svg",
                    width: _pinSize,
                    height: _pinSize,
                  ),
                ),
              ]),
            ),
          ),
          _buildDetails(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return FutureBuilder<Uint8List?>(
      future: _imageFuture,
      builder: (context, snapshot) {
        return SafeImage.memory(
          snapshot.data,
          width: _imageSize.width,
          height: _imageSize.height,
          fit: BoxFit.cover,
        );
      },
    );
  }

  Widget _buildDetails() {
    return FishingSpotDetails(
      widget.fishingSpot,
      isListItem: true,
      showRightChevron: true,
    );
  }

  Future<Uint8List?> _fetchImage() async {
    var fileName = "${widget.fishingSpot.lat}_"
        "${widget.fishingSpot.lng}_"
        "${_imageSize.width.round()}x${_imageSize.height.round()}_"
        "${_mapType.mapboxStaticId}"
        ".png";

    var cachedImage = await _imageManager.image(fileName: fileName);
    if (cachedImage != null) {
      _log.d("Image $fileName found in cache");
      return cachedImage;
    }

    _log.d("Downloading image $fileName...");
    return await _downloadImage(fileName);
  }

  Future<Uint8List?> _downloadImage(String fileName) async {
    var height = _imageSize.height * _mediaQuery.devicePixelRatio;
    var width = _imageSize.width * _mediaQuery.devicePixelRatio;
    var isScaled = false;

    if (width > _maxImagePixels && width < _maxImagePixels * 2) {
      // If the desired width is between max and max * 2 (available API scale),
      // use the scaled version to get exact size.
      width /= 2;
      height /= 2;
      isScaled = true;
    } else if (width > _maxImagePixels * 2) {
      // If the desired width is greater than the max, use the max.
      width = _maxImagePixels;
      height /= 2;
      isScaled = true;
    }

    _log.d("Requesting image: ${width}x$height, scaled=$isScaled");

    var path = "$_mapboxBaseUrl"
        "/${_mapType.mapboxStaticId}"
        "/static"
        "/${widget.fishingSpot.lng},${widget.fishingSpot.lat},$_mapZoom"
        "/${width.round()}x${height.round()}${isScaled ? "@2x" : ""}"
        "?access_token=${_propertiesManager.mapboxApiKey}"
        "&attribution=false"
        "&logo=false";
    var response = await getRest(_httpWrapper, Uri.parse(path));
    if (response == null) {
      return null;
    }

    // Don't wait for this to complete; it can be done asynchronously.
    _imageManager.saveImageBytes(response.bodyBytes, fileName);
    return response.bodyBytes;
  }
}
