import 'package:flutter/material.dart';
import 'package:mobile/log.dart';

class ListenerManager<T> {
  final _log = Log("ListenerManager");

  Set<T> _listeners = {};

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
    _listeners.forEach((listener) => notify(listener));
  }
}