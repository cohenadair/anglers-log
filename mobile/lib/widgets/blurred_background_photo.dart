import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../res/dimen.dart';
import 'photo.dart';
import 'widget.dart';

/// A widget that shows a blurred version of itself in the background when
/// [height] * [_imageWidthFactor] has been exceeded.
class BlurredBackgroundPhoto extends StatelessWidget {
  static const _imageWidthFactor = 2.5;
  static const _blurSigma = 10.0;

  final String imageName;
  final double height;

  /// The border radius of the entire container.
  final BorderRadius? borderRadius;

  /// The outside padding of the entire container.
  final EdgeInsets? padding;

  /// See [Photo.galleryImages].
  final List<String> galleryImages;

  BlurredBackgroundPhoto({
    required this.imageName,
    required this.height,
    this.borderRadius,
    this.padding,
    this.galleryImages = const [],
  }) : assert(isNotEmpty(imageName));

  @override
  Widget build(BuildContext context) {
    Widget blurredBackground = const Empty();

    var imageWidthMax = height * _imageWidthFactor;
    var imageWidth = MediaQuery.of(context).size.width;
    var photoRadius = BorderRadius.zero;

    // The blur filter is an expensive operation, only use it if we need to.
    if (imageWidth > imageWidthMax) {
      blurredBackground = ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        // TODO: Blur "shimmers" sometimes when scrolling: https://github.com/flutter/flutter/issues/64828
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: _blurSigma,
            sigmaY: _blurSigma,
            tileMode: TileMode.mirror,
          ),
          child: Photo(fileName: imageName),
        ),
      );
      imageWidth = imageWidthMax;
    } else {
      photoRadius = borderRadius ?? BorderRadius.zero;
    }

    return Padding(
      padding: padding ?? insetsZero,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.zero,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            blurredBackground,
            Center(
              child: ClipRRect(
                borderRadius: photoRadius,
                child: Photo(
                  fileName: imageName,
                  width: imageWidth,
                  height: height,
                  galleryImages: galleryImages,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
