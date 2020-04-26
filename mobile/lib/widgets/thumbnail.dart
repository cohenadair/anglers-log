import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/res/gen/custom_icons.dart';

/// When an image is being fetched, or the passed in [File] object is null,
/// [Thumbnail] will render a placeholder widget.
class Thumbnail extends StatelessWidget {
  static final double _listItemSize = 45;
  static final Duration _crossFadeDuration = Duration(milliseconds: 150);

  final File file;
  final double size;

  Thumbnail({
    this.file,
    @required this.size,
  }) : assert(size != null);

  Thumbnail.listItem({
    File file,
  }) : this(
    file: file,
    size: _listItemSize,
  );

  @override
  Widget build(BuildContext context) {
    Widget fishIcon = Icon(CustomIcons.catches,
      size: size / 2,
      color: Colors.white,
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: file == null ? fishIcon : ClipOval(
        child: Image.file(file,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          cacheWidth: size.toInt(),
          cacheHeight: size.toInt(),
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) {
              return child;
            }

            return AnimatedCrossFade(
              crossFadeState: frame == null
                  ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: Align(
                child: fishIcon,
                alignment: Alignment.center,
              ),
              secondChild: child,
              duration: _crossFadeDuration,
            );
          },
        ),
      ),
    );
  }
}