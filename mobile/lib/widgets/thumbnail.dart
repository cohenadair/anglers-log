import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/res/gen/custom_icons.dart';

/// When an image is being fetched, or the passed in [File] object is null,
/// [Thumbnail] will render a placeholder widget.
class Thumbnail extends StatelessWidget {
  static final double _listItemSize = 48;
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
    // A CircleAvatar widget is not used here because we want to have a nice
    // animation for transitioning between the placeholder and image.

    Widget placeholder = Container(
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

    if (file == null) {
      return placeholder;
    }

    return ClipOval(
      child: Image.file(file,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }

          return AnimatedCrossFade(
            crossFadeState: frame == null
                ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Align(
              child: placeholder,
              alignment: Alignment.center,
            ),
            secondChild: child,
            duration: _crossFadeDuration,
          );
        },
      ),
    );
  }
}