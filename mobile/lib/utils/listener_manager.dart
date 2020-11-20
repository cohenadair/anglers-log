import 'package:flutter/material.dart';

import '../log.dart';

class ListenerManager<T> {
  final _log = Log("ListenerManager");

  final Set<T> _listeners = {};

  void addListener(T listener) {
    _listeners.add(listener);
  }

  void removeListener(T listener) {
    if (_listeners.remove(listener) == null) {
      _log.w("Attempt to remove listener that isn't in stored in manager");
    }
  }

  @protected
  void notify(void Function(T) notify) {
    for (var listener in _listeners) {
      notify(listener);
    }
  }
}
