import 'package:flutter/material.dart';
import 'package:mobile/pages/entity_page.dart';

import '../model/gen/anglerslog.pb.dart';

class GearPage extends StatelessWidget {
  final Gear gear;

  const GearPage(this.gear);

  @override
  Widget build(BuildContext context) {
    return EntityPage(children: const []);
  }
}
