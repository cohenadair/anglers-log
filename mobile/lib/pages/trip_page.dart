import 'package:flutter/material.dart';
import 'package:mobile/trip_manager.dart';

import '../entity_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/entity_page.dart';
import '../res/dimen.dart';
import '../utils/page_utils.dart';
import 'save_trip_page.dart';

class TripPage extends StatefulWidget {
  final Trip trip;

  const TripPage(this.trip);

  @override
  _TripPageState createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  TripManager get _tripManager => TripManager.of(context);

  late Trip _trip;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
  }

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder(
      managers: [
        _tripManager
      ],
      onDeleteEnabled: false,
      builder: (context) {
        // Always fetch the latest trip when the widget tree is (re)built.
        // Fallback on the current trip (if the current was deleted).
        _trip = _tripManager.entity(widget.trip.id) ?? _trip;

        return EntityPage(
          customEntityValues: _trip.customEntityValues,
          padding: insetsZero,
          onEdit: () => present(context, SaveTripPage.edit(_trip)),
          onDelete: () => _tripManager.delete(_trip.id),
          deleteMessage: _tripManager.deleteMessage(context, _trip),
          imageNames: _trip.imageNames,
          children: const <Widget>[
          ],
        );
      },
    );
  }
}
