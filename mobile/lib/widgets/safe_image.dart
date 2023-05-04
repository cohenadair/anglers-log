import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile/res/theme.dart';

/// An [Image] wrapper that catches "Invalid image data" exceptions.
class SafeImage extends StatelessWidget {
  final Uint8List? bytes;
  final File? file;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? fallback;

  const SafeImage.file(
    this.file, {
    this.width,
    this.height,
    this.fit,
    this.fallback,
  }) : bytes = null;

  const SafeImage.memory(
    this.bytes, {
    this.width,
    this.height,
    this.fit,
    this.fallback,
  }) : file = null;

  @override
  Widget build(BuildContext context) {
    if (file != null) {
      return Image.file(
        file!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, _, __) => _buildError(context),
      );
    }

    if (bytes != null) {
      return Image.memory(
        bytes!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, _, __) => _buildError(context),
      );
    }

    return _buildError(context);
  }

  Widget _buildError(BuildContext context) {
    return fallback ??
        Container(
          width: width,
          height: height,
          color: context.colorGreyAccentLight,
        );
  }
}
