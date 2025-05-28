import 'package:flutter/material.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import 'package:mobile/wrappers/share_plus_wrapper.dart';
import 'package:quiver/strings.dart';

import '../../utils/string_utils.dart';

IconData shareIconData(BuildContext context) {
  return IoWrapper.get.isAndroid ? Icons.share : Icons.ios_share;
}

Future<void> share(
  BuildContext context,
  List<String> imageNames,
  Rect? buttonPos, {
  String? text,
}) {
  var imageManager = ImageManager.of(context);
  var shareWrapper = SharePlusWrapper.of(context);

  var hashtag = IoWrapper.get.isAndroid
      ? Strings.of(context).shareTextAndroid
      : Strings.of(context).shareTextApple;
  var shareText = "${isEmpty(text) ? "" : "$text\n\n"}$hashtag";

  if (imageNames.isEmpty) {
    return shareWrapper.share(shareText, buttonPos);
  } else {
    return shareWrapper.shareFiles(
      imageManager.imageXFiles(imageNames),
      buttonPos,
      text: shareText,
    );
  }
}
