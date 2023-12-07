import 'package:flutter/material.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/gear_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/entity_page.dart';
import 'package:mobile/pages/save_gear_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:quiver/strings.dart';

import '../model/gen/anglerslog.pb.dart';
import '../res/gen/custom_icons.dart';
import '../utils/page_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/icon_list.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';

class GearPage extends StatefulWidget {
  final Gear gear;

  const GearPage(this.gear);

  @override
  State<GearPage> createState() => _GearPageState();
}

class _GearPageState extends State<GearPage> {
  GearManager get _gearManager => GearManager.of(context);

  late Gear _gear;

  @override
  void initState() {
    super.initState();
    _gear = widget.gear;
  }

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder(
      managers: [_gearManager],
      builder: (context) {
        // Always fetch the latest gear when the widget tree is (re)built.
        // Fallback on the current gear (if the current was deleted).
        _gear = _gearManager.entity(widget.gear.id) ?? _gear;

        return EntityPage(
          customEntityValues: _gear.customEntityValues,
          imageNames: _gear.hasImageName() ? [_gear.imageName] : const [],
          onEdit: () => present(context, SaveGearPage.edit(_gear)),
          onDelete: () => _gearManager.delete(_gear.id),
          deleteMessage: _gearManager.deleteMessage(context, _gear),
          padding: insetsVerticalDefault,
          children: [
            _buildName(),
            _buildRod(context),
            _buildReel(),
            _buildLine(),
            _buildHook(),
          ],
        );
      },
    );
  }

  Widget _buildName() {
    return Padding(
      padding: insetsBottomDefault,
      child: TitleLabel.style1(
        _gear.name,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _buildRod(BuildContext context) {
    var values = <String>[];

    if (isNotEmpty(_gear.rodMakeModel)) {
      values.add(_gear.rodMakeModel);
    }

    if (isNotEmpty(_gear.rodSerialNumber)) {
      values.add(format(
          Strings.of(context).gearPageSerialNumber, [_gear.rodSerialNumber]));
    }

    var specs = <String>[];
    if (_gear.hasRodLength()) {
      specs.add(_gear.rodLength.displayValue(context));
    }

    if (_gear.hasRodAction()) {
      specs.add(_gear.rodAction.displayName(context));
    }

    if (_gear.hasRodPower()) {
      specs.add(_gear.rodPower.displayName(context));
    }

    if (specs.isNotEmpty) {
      values.add(formatList(specs));
    }

    return _buildIconList(values, CustomIcons.rod);
  }

  Widget _buildReel() {
    var values = <String>[];

    if (isNotEmpty(_gear.reelMakeModel)) {
      values.add(_gear.reelMakeModel);
    }

    if (isNotEmpty(_gear.reelSerialNumber)) {
      values.add(format(
          Strings.of(context).gearPageSerialNumber, [_gear.reelSerialNumber]));
    }

    if (_gear.hasReelSize()) {
      values.add(format(Strings.of(context).gearPageSize, [_gear.reelSize]));
    }

    return _buildIconList(values, CustomIcons.reel);
  }

  Widget _buildLine() {
    var values = <String>[];

    if (isNotEmpty(_gear.lineMakeModel)) {
      values.add(_gear.lineMakeModel);
    }

    var ratingColor = <String>[];
    if (_gear.hasLineRating()) {
      ratingColor.add(_gear.lineRating.displayValue(context));
    }
    if (isNotEmpty(_gear.lineColor)) {
      ratingColor.add(_gear.lineColor);
    }
    if (ratingColor.isNotEmpty) {
      values.add(formatList(ratingColor));
    }

    var leader = <String>[];
    if (_gear.hasLeaderLength()) {
      leader.add(_gear.leaderLength.displayValue(context));
    }
    if (_gear.hasLeaderRating()) {
      leader.add(_gear.leaderRating.displayValue(context));
    }
    if (leader.isNotEmpty) {
      values.add(
          format(Strings.of(context).gearPageLeader, [formatList(leader)]));
    }

    var tippet = <String>[];
    if (_gear.hasTippetLength()) {
      tippet.add(_gear.tippetLength.displayValue(context));
    }
    if (_gear.hasTippetRating()) {
      tippet.add(_gear.tippetRating.displayValue(context));
    }
    if (tippet.isNotEmpty) {
      values.add(
          format(Strings.of(context).gearPageTippet, [formatList(tippet)]));
    }

    return _buildIconList(values, CustomIcons.line);
  }

  Widget _buildHook() {
    var values = <String>[];

    if (isNotEmpty(_gear.hookMakeModel)) {
      values.add(_gear.hookMakeModel);
    }

    if (_gear.hasHookSize()) {
      values.add(format(Strings.of(context).gearPageSize,
          [_gear.hookSize.displayValue(context)]));
    }

    return _buildIconList(values, CustomIcons.hook);
  }

  Widget _buildIconList(List<String> values, IconData icon) {
    if (values.isEmpty) {
      return const Empty();
    }

    return Padding(
      padding: insetsDefault,
      child: IconList(
        values: values,
        icon: icon,
      ),
    );
  }
}
