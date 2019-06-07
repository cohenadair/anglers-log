import 'package:flutter/material.dart';

push(BuildContext context, Widget page, {
  bool fullscreenDialog = false
}) {
  Navigator.of(context, rootNavigator: fullscreenDialog).push(
    MaterialPageRoute(
      builder: (BuildContext context) => page,
      fullscreenDialog: fullscreenDialog,
    )
  );
}