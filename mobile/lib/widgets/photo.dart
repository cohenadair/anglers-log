import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../image_manager.dart';
import '../pages/photo_gallery_page.dart';
import '../res/dimen.dart';
import '../res/gen/custom_icons.dart';
import '../utils/page_utils.dart';
import '../widgets/widget.dart';

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
  final String? fileName;

  final double? width;
  final double? height;

  /// If null, is set to the larger of [width] and [height].
  final double? cacheSize;

  /// If true, [Photo] will be rendered in a circle. Default is false.
  final bool isCircular;

  /// If not empty, a [PhotoGalleryPage] is shown when this [Photo] is tapped,
  /// allowing the user to view [galleryImages] in fullscreen.
  final List<String> galleryImages;

  /// When true, shows a placeholder image if [imageName] doesn't exist in
  /// [ImageManager]. Defaults to true.
  final bool showPlaceholder;

  /// If [showPlaceholder] is false, and [imageName] does not exist, this field
  /// is ignored.
  final EdgeInsets? padding;

  Photo({
    required this.fileName,
    this.width,
    this.height,
    this.cacheSize,
    this.isCircular = false,
    this.galleryImages = const [],
    this.showPlaceholder = true,
    this.padding,
  }) : assert((width != null && height != null) ||
            (width == null && height == null));

  Photo.listThumbnail(
    String? fileName, {
    bool showPlaceholder = true,
    EdgeInsets? padding,
  }) : this(
          fileName: fileName,
          width: _listItemSize,
          height: _listItemSize,
          isCircular: true,
          showPlaceholder: showPlaceholder,
          padding: padding,
        );

  @override
  _PhotoState createState() => _PhotoState();
}

class _PhotoState extends State<Photo> {
  late Future<Uint8List?> _imageFuture;

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
    return FutureBuilder<Uint8List?>(
      future: _imageFuture,
      builder: (context, snapshot) {
        var image = snapshot.data;
        var w = widget.width;
        var h = widget.height;
        var hasSize = w != null && h != null;

        Widget child = Empty();
        if (image == null && widget.showPlaceholder) {
          // Use a default icon placeholder if a size was specified, otherwise
          // use an empty widget.
          child = hasSize
              ? Container(
                  width: w,
                  height: h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: widget.isCircular
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                  ),
                  child: Icon(
                    CustomIcons.catches,
                    size: min<double>(w!, h!) / 1.5,
                    color: Colors.white,
                  ),
                )
              : Empty();
        } else if (image != null) {
          child = Image.memory(
            image,
            width: w,
            height: h,
            fit: BoxFit.cover,
          );
        }

        if (child is Empty) {
          return child;
        }

        // Note that an AnimatedSwitcher isn't used here for a couple reasons:
        //   1. Loading from cache is quicker than the animation, and
        //   2. AnimatedSwitcher uses a Stack, which requires some extra work
        //      with images.
        // So no animation is used to keep things simple since an animation is
        // hardly noticeable anyway.
        if (widget.isCircular) {
          child = ClipOval(
            child: child,
          );
        }

        if (widget.galleryImages.isNotEmpty && image != null) {
          return GestureDetector(
            onTap: () {
              fade(
                context,
                PhotoGalleryPage(
                  fileNames: widget.galleryImages,
                  initialFileName: widget.fileName!,
                ),
              );
            },
            child: child,
          );
        }

        return Padding(
          padding: widget.padding ?? insetsZero,
          child: child,
        );
      },
    );
  }

  Future<Uint8List?> _decodeImage() async {
    if (isEmpty(widget.fileName)) {
      return null;
    }

    var size = widget.cacheSize;
    if (size == null) {
      size = widget.width == null || widget.height == null
          ? null
          : max<double>(widget.width!, widget.height!);
    }

    return await _imageManager.image(context,
        fileName: widget.fileName!, size: size);
  }
}
