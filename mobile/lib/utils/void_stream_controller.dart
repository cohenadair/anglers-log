import 'dart:async';

/// A wrapper for a `void` [StreamController] to be used primarily for an
/// event stream where the value of the stream is irrelevant.
class VoidStreamController {
  final StreamController<void> _controller = StreamController.broadcast();

  Stream<void> get stream => _controller.stream;

  /// Sends and event to the underlying [StreamController] iff the
  /// [StreamController] has a listener. Does nothing otherwise.
  void notify() {
    if (_controller.hasListener) {
      _controller.add(null);
    }
  }

  /// Closes the underlying [StreamController]. The [VoidStreamController]
  /// becomes invalid after invoking this method.
  void close() {
    _controller.close();
  }
}
