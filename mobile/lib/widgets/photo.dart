import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

/// A widget that displays a photo on the screen. The photo source is one
/// already saved to the app's sandbox (i.e. an image associated with an
/// [Entity]), and is fetched from [ImageManager].
///
/// Both [width] and [height] must be set, or both must be null. If null,
/// the widget conforms to the parent widget constraints, and the full image
/// is fetched from [ImageManager]. If non-null, the largest of [width] and
/// [height] is fetched from [ImageManager].
class Photo extends StatefulWidget {
  static final double _listItemSize = 48;

  /// The unique file name of the image.
  final String fileName;

  final double width;
  final double height;

  /// If null, is set to the larger of [width] and [height].
  final double cacheSize;

  /// If true, [Photo] will be rendered in a circle. Default is false.
  final bool circular;

  Photo({
    @required this.fileName,
    this.width,
    this.height,
    this.cacheSize,
    this.circular = false,
  }) : assert((width != null && height != null)
      || (width == null && height == null));

  Photo.listThumbnail(String fileName) : this(
    fileName: fileName,
    width: _listItemSize,
    height: _listItemSize,
    circular: true,
  );

  @override
  _PhotoState createState() => _PhotoState();
}

class _PhotoState extends State<Photo> {
  Future<ui.Image> _imageFuture;

  ImageManager get _imageManager => ImageManager.of(context);

  @override
  void initState() {
    super.initState();
    _imageFuture = _decodeImage();
  }

  @override
  void didUpdateWidget(Photo oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reload image if it changed.
    if (oldWidget.fileName != widget.fileName) {
      _imageFuture = _decodeImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: _imageFuture,
      builder: (context, snapshot) {
        ui.Image image = snapshot.data;
        double w = widget.width;
        double h = widget.height;
        bool hasSize = w != null && h != null;

        Widget child;
        if (image == null) {
          // Use a default icon placeholder if a size was specified, otherwise
          // use an empty widget.
          child = hasSize ? Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: widget.circular ? BoxShape.circle : BoxShape.rectangle,
            ),
            child: Icon(CustomIcons.catches,
              size: min<double>(w, h) / 2,
              color: Colors.white,
            ),
          ) : Empty();
        } else {
          // Use RawImage instead of Image to avoid the overhead of Flutter's
          // image caching.
          child = RawImage(
            width: w,
            height: h,
            image: image,
            fit: BoxFit.cover,
          );
        }

        if (widget.circular) {
          return ClipOval(
            child: child,
          );
        }

        return child;
      },
    );
  }

  Future<ui.Image> _decodeImage() async {
    if (isEmpty(widget.fileName)) {
      return null;
    }

    double size = widget.cacheSize;
    if (size == null) {
      size = widget.width == null
          ? null : max<double>(widget.width, widget.height);
    }

    // Get image from cache.
    Uint8List bytes = await _imageManager.image(context,
      fileName: widget.fileName,
      size: size,
    );

    return (await (await ui.instantiateImageCodec(bytes)).getNextFrame()).image;
  }
}