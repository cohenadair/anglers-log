import 'package:flutter/material.dart';

import 'package:share_plus/share_plus.dart';

import '../app_manager.dart';

class SharePlusWrapper {
  static SharePlusWrapper of(BuildContext context) =>
      AppManager.get.sharePlusWrapper;

  Future<void> shareFiles(
    List<XFile> files,
    Rect? sharePositionOrigin, {
    String? subject,
    String? text,
  }) {
    return Share.shareXFiles(
      files,
      subject: subject,
      text: text,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  Future<void> share(
    String text,
    Rect? sharePositionOrigin, {
    String? subject,
  }) {
    return Share.share(
      text,
      subject: subject,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
