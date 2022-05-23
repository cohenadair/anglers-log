import 'package:flutter/widgets.dart';

/// Checks [state.mounted] before invoking [use]. This should always be used in a
/// [StatefulWidget] after asynchronous work as been done to ensure the widget
/// still exists (i.e. is mounted).
void safeUseContext(State state, VoidCallback use) {
  if (!state.mounted) {
    return;
  }
  use();
}
