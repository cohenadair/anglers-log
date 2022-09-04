import 'dart:async';

import 'package:flutter/widgets.dart';

/// Checks [state.mounted] before invoking [use]. This should always be used in a
/// [StatefulWidget] after asynchronous work as been done to ensure the widget
/// still exists (i.e. is mounted).
FutureOr<void> safeUseContext(
    State state, FutureOr<void> Function() use) async {
  if (!state.mounted) {
    return Future.value();
  }
  await use();
}
