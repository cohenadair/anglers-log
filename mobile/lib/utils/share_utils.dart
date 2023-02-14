import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import 'package:mobile/wrappers/share_plus_wrapper.dart';
import 'package:quiver/strings.dart';

IconData shareIconData(BuildContext context) {
  return IoWrapper.of(context).isAndroid ? Icons.share : Icons.ios_share;
}

Future<void> share(
  BuildContext context,
  List<String> imageNames, {
  String? text,
}) {
  var imageManager = ImageManager.of(context);
  var ioWrapper = IoWrapper.of(context);
  var shareWrapper = SharePlusWrapper.of(context);

  var hashtag = ioWrapper.isAndroid
      ? Strings.of(context).shareTextAndroid
      : Strings.of(context).shareTextApple;
  var shareText = "${isEmpty(text) ? "" : "$text\n\n"}$hashtag";

  if (imageNames.isEmpty) {
    return shareWrapper.share(shareText);
  } else {
    return shareWrapper.shareFiles(
      imageManager.imageXFiles(imageNames),
      text: shareText,
    );
  }
}
