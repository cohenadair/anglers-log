import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/widgets/widget.dart';

/// A utility [Widget] capable of listening to multiple [Stream]s.
///
/// The value of each [Stream] is never used. When an event is added to a given
/// [Stream], each given [Future] callback is invoked, and its [Future]
/// updated.
class FutureListener extends StatefulWidget {
  /// The [Future]s that are updated when their corresponding [Stream]
  /// receives an event.
  final List<Future<dynamic> Function()> futures;

  /// The [Stream]s to listen to.
  final List<Stream<dynamic>> streams;

  /// Builds the [Widget]. Use [onUpdate] to obtain latest values returned by
  /// given [Future] objects.
  final Widget Function(BuildContext) builder;

  /// Called when the given [Future] object(s) is finished retrieving data.
  /// This callback is called each time the future function(s) is invoked
  /// (i.e. each time the stream is updated). This is _not_ called for each
  /// build sequence. The [dynamic] variable is a [List] when the default
  /// constructor is used to instantiate the [FutureListener]. When
  /// [FutureListener.single] is used, [dynamic] is the value of the single
  /// [Future] provided.
  final Function(dynamic) onUpdate;

  FutureListener({
    @required this.futures,
    @required this.streams,
    @required this.builder,
    @required this.onUpdate,
  }) : assert(futures != null),
       assert(futures.isNotEmpty),
       assert(streams != null),
       assert(streams.isNotEmpty),
       assert(builder != null);

  FutureListener.single({
    @required Future Function() future,
    @required Stream stream,
    @required this.builder,
    @required this.onUpdate,
  }) : assert(future != null),
       assert(stream != null),
       assert(builder != null),
       futures = [ future ],
       streams = [ stream ];

  @override
  _FutureListenerState createState() => _FutureListenerState();
}

class _FutureListenerState extends State<FutureListener> {
  List<StreamSubscription> _onUpdateEvents = [];
  List<Future> _futures = [];

  // Tracks when futures are reset so we know when to call onUpdate.
  bool _futuresUpdated = false;

  @override
  void initState() {
    super.initState();

    widget.streams.forEach((stream) =>
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
          widget.onUpdate?.call(_futures.length > 1
              ? snapshot.data : snapshot.data.first);
          _futuresUpdated = false;
        }

        return widget.builder(context);
      },
    );
  }

  void _updateFutures() {
    _futures.clear();
    widget.futures.forEach((getFuture) {
      _futures.add(getFuture());
    });
    _futuresUpdated = true;
  }
}