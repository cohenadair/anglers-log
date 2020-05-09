import 'dart:io';

import 'package:flutter/material.dart';

bool hasBottomSafeArea(BuildContext context) {
  return MediaQuery.of(context).viewPadding.bottom > 0;
}

Future<bool> isConnected() async {
  // A quick DNS lookup will tell us if there's a current internet connection.
  return (await InternetAddress.lookup("example.com")).isNotEmpty;
}