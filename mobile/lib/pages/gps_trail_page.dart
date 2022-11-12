import 'package:flutter/material.dart';

import '../model/gen/anglerslog.pb.dart';
import '../widgets/widget.dart';

class GpsTrailPage extends StatelessWidget {
  final GpsTrail trail;

  const GpsTrailPage(this.trail);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Empty(),
    );
  }
}