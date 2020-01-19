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

  /// Invoked when the default constructor is used to instantiate a
  /// [FutureListener] object. The passed in [List] include the values returned
  /// by each future in [futures], in the order given.
  final Widget Function(BuildContext, List<dynamic>) builder;

  /// Invoked when the [FutureListener.single] constructor is used to
  /// instantiate a [FutureListener] object. The passed in `dynamic` value is
  /// equal to the value returned by [futureCallback].
  final Widget Function(BuildContext, dynamic) singleBuilder;

  /// Invoked when the default constructor is used to instantiate a
  /// [FutureListener] object. Called when the given [Future] objects are
  /// finished retrieving data. This callback is called each time the future
  /// function is invoked (i.e. each time the stream is updated). This is _not_
  /// called for each `build` sequence.
  final Function(List<dynamic>) onFuturesFinished;

  /// Invoked when the [FutureListener.single] constructor is used to
  /// instantiate a [FutureListener] object. Called when the given [Future]
  /// objects are finished retrieving data. This callback is called each time
  /// the future function is invoked (i.e. each time the stream is updated).
  /// This is _not_ called for each `build` sequence.
  final void Function(dynamic) onFutureFinished;

  /// Values to show while the given [Future] objects are being executed.
  /// The types of values in this [List] should be the same as the return
  /// type of each given [Future].
  final List<dynamic> initialValues;

  FutureListener({
    @required this.futures,
    @required this.streams,
    @required this.builder,
    this.initialValues,
    this.onFuturesFinished,
  }) : assert(futures != null),
       assert(futures.isNotEmpty),
       assert(streams != null),
       assert(streams.isNotEmpty),
       assert(builder != null),
       singleBuilder = null,
       onFutureFinished = null;

  FutureListener.single({
    @required Future Function() future,
    @required Stream stream,
    @required Widget Function(BuildContext, dynamic) builder,
    this.initialValues,
    this.onFutureFinished,
  }) : futures = [ future ],
       streams = [ stream ],
       singleBuilder = builder,
       builder = null,
       onFuturesFinished = null;

  @override
  _FutureListenerState createState() => _FutureListenerState();
}

class _FutureListenerState extends State<FutureListener> {
  List<StreamSubscription> _onUpdateEvents = [];
  List<Future> _futures = [];

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
        if (!snapshot.hasData) {
          if (widget.initialValues == null) {
            return Empty();
          }

          return _build(
            singleValue: widget.initialValues.first,
            multiValue: widget.initialValues,
          );
        }

        // Need to check connectionState here because "providing a new but
        // already-completed future to a FutureBuilder will result in a single
        // frame in the ConnectionState.waiting state" (Flutter FutureBuilder
        // doc).
        if (_futuresUpdated && snapshot.connectionState == ConnectionState.done)
        {
          widget.onFuturesFinished?.call(snapshot.data);
          widget.onFutureFinished?.call((snapshot.data as Iterable).first);
          _futuresUpdated = false;
        }

        return _build(
          singleValue: snapshot.data.first,
          multiValue: snapshot.data,
        );
      },
    );
  }

  Widget _build({dynamic singleValue, List<dynamic> multiValue}) {
    if (widget.builder == null) {
      return widget.singleBuilder(context, singleValue);
    } else {
      return widget.builder(context, multiValue);
    }
  }

  void _updateFutures() {
    _futuresUpdated = true;
    _futures.clear();
    widget.futures.forEach((getFuture) {
      _futures.add(getFuture());
    });
  }
}