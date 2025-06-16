import 'package:flutter/material.dart';
import 'package:mobile/wrappers/device_info_wrapper.dart';
import 'package:mobile/wrappers/io_wrapper.dart';

bool hasBottomSafeArea(BuildContext context) {
  return MediaQuery.of(context).viewPadding.bottom > 0;
}

Future<bool> isPad() async {
  if (!IoWrapper.get.isIOS) {
    return false;
  }
  // This will typically return "iPad", "iPad13,2", etc. for iPads.
  return (await DeviceInfoWrapper.get.iosInfo)
      .name
      .toLowerCase()
      .contains("ipad");
}
