import 'dart:async';

import 'package:flutter/material.dart';

/// A helper class for use with [FutureStreamBuilder].
///
/// The value of each [Stream] is never used. When an event is added to a given
/// [Stream], each given [Future] callback is invoked, and its associated
/// [Future] updated.
class FutureStreamHolder {
  /// The [Future]s that are updated when their corresponding [Stream]
  /// receives an event.
  final List<Future<dynamic> Function()> futureCallbacks;

  /// The [Stream]s to listen to.
  final List<Stream> streams;

  /// Invoked when a future is updated. This is _not_ called for each
  /// build sequence. The [dynamic] variable is a [List] of values produced
  /// by the configured future callbacks, or a single value is a single
  /// stream/value is used.
  final Function(dynamic) onUpdate;

  FutureStreamHolder.single({
    @required Future<dynamic> Function() futureCallback,
    @required Stream stream,
    @required Function(dynamic) onUpdate,
  }) : this(
    futureCallbacks: futureCallback == null ? null : [futureCallback],
    streams: stream == null ? null : [stream],
    onUpdate: onUpdate,
  );

  FutureStreamHolder({
    @required this.futureCallbacks,
    @required this.streams,
    @required this.onUpdate,
  }) : assert(futureCallbacks != null && futureCallbacks.isNotEmpty),
       assert(streams != null && streams.isNotEmpty),
       assert(streams.length == futureCallbacks.length),
       assert(onUpdate != null);
}

/// A convenience [Widget] to be used alongside a [FutureStreamHolder] instance.
class FutureStreamBuilder extends StatefulWidget {
  final FutureStreamHolder holder;

  /// Builds the [Widget]. Use [FutureStreamHolder.onUpdate] to obtain latest
  /// values returned by given [Future] objects.
  final Widget Function(BuildContext) builder;

  FutureStreamBuilder({
    @required this.holder,
    @required this.builder,
  }) : assert(holder != null),
       assert(builder != null);

  @override
  _FutureStreamBuilderState createState() => _FutureStreamBuilderState();
}

class _FutureStreamBuilderState extends State<FutureStreamBuilder> {
  List<StreamSubscription> _onUpdateEvents = [];
  List<Future> _futures = [];

  // Tracks when futures are actually reset, and not just a new instance with
  // an already completed result.
  bool _futuresUpdated = false;

  FutureStreamHolder get _listener => widget.holder;

  @override
  void initState() {
    super.initState();

    _listener.streams.forEach((stream) =>
        _onUpdateEvents.add(stream.listen((newValue) {
          setState(() {
            _updateFutures();
          });
        })));

    _updateFutures();
  }

  @override
  void dispose() {
    super.dispose();
    _onUpdateEvents.forEach((event) => event.cancel());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait(_futures),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // Need to check connectionState here because "providing a new but
        // already-completed future to a FutureBuilder will result in a single
        // frame in the ConnectionState.waiting state" (Flutter FutureBuilder
        // doc).
        if (_futuresUpdated && snapshot.connectionState == ConnectionState.done)
        {
          _listener.onUpdate(
              _futures.length > 1 ? snapshot.data : snapshot.data.first);
          _futuresUpdated = false;
        }

        return widget.builder(context);
      },
    );
  }

  void _updateFutures() {
    _futures.clear();
    _listener.futureCallbacks.forEach((getFuture) {
      _futures.add(getFuture());
    });
    _futuresUpdated = true;
  }
}