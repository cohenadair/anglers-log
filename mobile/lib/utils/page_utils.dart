import 'package:flutter/material.dart';

push(BuildContext context, Widget page, {
  bool fullscreenDialog = false
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) => page,
      fullscreenDialog: fullscreenDialog,
    )
  );
}