import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile/res/gen/custom_icons.dart';

/// An [ImagePlaceholder] is shown in place of an image, when an image does
/// not exist, or is being fetched from file storage.
class ImagePlaceholder extends StatelessWidget {
  final double size;

  ImagePlaceholder({
    @required this.size,
  }) : assert(size != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: Icon(CustomIcons.catches,
        size: size / 2,
        color: Colors.white,
      ),
    );
  }
}