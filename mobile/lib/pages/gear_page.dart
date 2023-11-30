import 'package:flutter/material.dart';
import 'package:mobile/gear_manager.dart';
import 'package:mobile/pages/entity_page.dart';
import 'package:mobile/pages/save_gear_page.dart';
import 'package:mobile/res/dimen.dart';

import '../model/gen/anglerslog.pb.dart';
import '../utils/page_utils.dart';

class GearPage extends StatelessWidget {
  final Gear gear;

  const GearPage(this.gear);

  @override
  Widget build(BuildContext context) {
    var gearManager = GearManager.of(context);

    return EntityPage(
      customEntityValues: gear.customEntityValues,
      imageNames: gear.hasImageName() ? [gear.imageName] : const [],
      onEdit: () => present(context, SaveGearPage.edit(gear)),
      onDelete: () => gearManager.delete(gear.id),
      deleteMessage: gearManager.deleteMessage(context, gear),
      padding: insetsVerticalDefault,
      children: const [
        // TODO
      ],
    );
  }
}
