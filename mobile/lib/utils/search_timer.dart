import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:quiver/strings.dart';

/// A [Timer] wrapper for use with a search feature.
class SearchTimer {
  final Duration _inputDelayDuration = const Duration(milliseconds: 500);

  /// Invoked when the [SearchTimer] is reset with an empty query, or if the
  /// underlying [Timer] runs out.
  VoidCallback onFinished;

  Timer? _timer;

  SearchTimer(this.onFinished);

  /// Resets the [SearchTimer]. Returns true
  void reset(String? query) {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }

    if (isEmpty(query)) {
      // When text is cleared, invoke callback immediately.
      onFinished.call();
    } else {
      // Only use a timer if the user is typing.
      _timer = Timer(_inputDelayDuration, () {
        onFinished.call();
      });
    }
  }

  void finish() {
    _timer?.cancel();
  }
}
