import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:mobile/gear_manager.dart';
import 'package:mobile/pages/gear_page.dart';
import 'package:mobile/utils/share_utils.dart';
import 'package:mobile/utils/widget_utils.dart';
import 'package:mobile/widgets/static_fishing_spot_map.dart';
import 'package:mobile/widgets/tide_chart.dart';
import 'package:mobile/widgets/water_conditions.dart';
import 'package:quiver/strings.dart';

import '../angler_manager.dart';
import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../body_of_water_manager.dart';
import '../catch_manager.dart';
import '../entity_manager.dart';
import '../fishing_spot_manager.dart';
import '../method_manager.dart';
import '../model/gen/anglers_log.pb.dart';
import '../pages/bait_page.dart';
import '../pages/entity_page.dart';
import '../pages/save_catch_page.dart';
import '../res/gen/custom_icons.dart';
import '../res/style.dart';
import '../species_manager.dart';
import '../utils/gear_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../water_clarity_manager.dart';
import '../widgets/atmosphere_wrap.dart';
import '../widgets/icon_list.dart';
import '../widgets/list_item.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';
import 'anglers_log_pro_page.dart';
import 'bait_variant_page.dart';

class CatchPage extends StatefulWidget {
  final Catch cat;

  const CatchPage(this.cat);

  @override
  CatchPageState createState() => CatchPageState();
}

class CatchPageState extends State<CatchPage> {
  final _shareButtonKey = GlobalKey();

  AnglerManager get _anglerManager => AnglerManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  CatchManager get _catchManager => CatchManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  MethodManager get _methodManager => MethodManager.of(context);

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  WaterClarityManager get _waterClarityManager =>
      WaterClarityManager.of(context);

  late Catch _catch;

  @override
  void initState() {
    super.initState();
    _catch = widget.cat;
  }

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder(
      managers: [
        _anglerManager,
        _baitCategoryManager,
        _baitManager,
        _bodyOfWaterManager,
        _catchManager,
        _fishingSpotManager,
        _methodManager,
        _speciesManager,
        _waterClarityManager,
      ],
      onDeleteEnabled: false,
      builder: (context) {
        // Always fetch the latest catch when the widget tree is (re)built.
        // Fallback on the current catch (if the current was deleted).
        _catch = _catchManager.entity(widget.cat.id) ?? _catch;

        return EntityPage(
          customEntityValues: _catch.customEntityValues,
          padding: insetsZero,
          onEdit: () => present(context, SaveCatchPage.edit(_catch)),
          onDelete: () => _catchManager.delete(_catch.id),
          onShare: _onShare,
          shareButtonKey: _shareButtonKey,
          onCopy: _onCopy,
          deleteMessage: _catchManager.deleteMessage(context, _catch),
          imageNames: _catch.imageNames,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(
                top: paddingDefault,
                right: paddingDefault,
                bottom: paddingSmall,
              ),
              child: _buildHeader(),
            ),
            _buildMethods(),
            _buildBaits(),
            _buildGear(),
            _buildFishingSpot(),
            _buildAtmosphere(),
            _buildTide(),
            _buildSize(),
            _buildAngler(),
            _buildCatchAndRelease(),
            _buildWaterConditions(),
            _buildNotes(),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleLabel.style1(
                _speciesName ?? Strings.of(context).unknownSpecies,
                overflow: TextOverflow.visible,
              ),
              Padding(
                padding: insetsLeftDefault,
                child: Text(_formatTimeFields(), style: styleSubtitle(context)),
              ),
            ],
          ),
        ),
        CatchFavoriteStar(_catch, large: true),
      ],
    );
  }

  String _formatTimeFields() {
    var result = _catch.displayTimestamp(context);

    if (!_catch.hasPeriod() && !_catch.hasSeason()) {
      return result;
    }

    result += " (";

    var items = <String>[];
    if (_catch.hasPeriod()) {
      items.add(_catch.period.displayName(context));
    }
    if (_catch.hasSeason()) {
      items.add(_catch.season.displayName(context));
    }

    return result += "${items.join(", ")})";
  }

  Widget _buildBaits() {
    if (_catch.baits.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: _catch.baits.map((e) => _BaitAttachmentListItem(e)).toList(),
    );
  }

  Widget _buildGear() {
    if (_catch.gearIds.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: _catch.gearIds.map((e) => _GearListItem(e)).toList(),
    );
  }

  Widget _buildFishingSpot() {
    var fishingSpot = _fishingSpotManager.entity(_catch.fishingSpotId);
    if (fishingSpot == null) {
      return const SizedBox();
    }

    return StaticFishingSpotMap(
      fishingSpot,
      padding: insetsHorizontalDefaultVerticalSmall,
    );
  }

  Widget _buildAtmosphere() {
    if (!_catch.hasAtmosphere()) {
      return const SizedBox();
    }

    return Padding(
      padding: insetsDefault,
      child: AtmosphereWrap(_catch.atmosphere),
    );
  }

  Widget _buildTide() {
    if (!_catch.hasTide()) {
      return const SizedBox();
    }

    if (_catch.tide.daysHeights.isEmpty) {
      var current = _catch.tide.currentDisplayValue(context, useChipName: true);
      var extremes = _catch.tide.extremesDisplayValue(context);

      // No information to show.
      if (isEmpty(current) && isEmpty(extremes)) {
        return const SizedBox();
      }

      var title = isEmpty(current)
          ? Strings.of(context).catchFieldTide
          : current;

      return ListItem(
        leading: const GreyAccentIcon(Icons.waves),
        title: isEmpty(title) ? null : Text(title),
        subtitle: isEmpty(extremes)
            ? null
            : Text(extremes, overflow: TextOverflow.visible),
      );
    }

    return Padding(padding: insetsDefault, child: TideChart(_catch.tide));
  }

  Widget _buildAngler() {
    var angler = _anglerManager.entity(_catch.anglerId);
    if (angler == null) {
      return const SizedBox();
    }

    return ListItem(
      leading: const GreyAccentIcon(iconAngler),
      title: Text(angler.name),
    );
  }

  Widget _buildCatchAndRelease() {
    if (!_catch.hasWasCatchAndRelease()) {
      return const SizedBox();
    }

    if (_catch.wasCatchAndRelease) {
      return ListItem(
        leading: const GreyAccentIcon(Icons.check_circle),
        title: Text(Strings.of(context).catchPageReleased),
      );
    } else {
      return ListItem(
        leading: const GreyAccentIcon(Icons.error),
        title: Text(Strings.of(context).catchPageKept),
      );
    }
  }

  Widget _buildWaterConditions() {
    return WaterConditions(_catch);
  }

  Widget _buildSize() {
    var values = <String>[];

    if (_catch.hasWeight()) {
      values.add(_catch.weight.displayValue(context));
    }

    if (_catch.hasLength()) {
      values.add(_catch.length.displayValue(context));
    }

    if (values.isEmpty) {
      return const SizedBox();
    }

    return ListItem(
      leading: const GreyAccentIcon(CustomIcons.ruler),
      title: Text(values.join(", ")),
    );
  }

  Widget _buildNotes() {
    var values = <String>[];

    if (_catch.hasQuantity() && _catch.quantity > 0) {
      values.add(Strings.of(context).catchPageQuantityLabel(_catch.quantity));
    }

    if (_catch.hasNotes() && isNotEmpty(_catch.notes)) {
      values.add(_catch.notes);
    }

    if (values.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: insetsDefault,
      child: IconList(values: values, icon: Icons.notes),
    );
  }

  Widget _buildMethods() {
    if (_catch.methodIds.isEmpty) {
      return const SizedBox();
    }

    var methodNames = _methodManager
        .list(_catch.methodIds)
        .map((m) => m.name)
        .toSet();
    if (methodNames.isEmpty) {
      return const SizedBox();
    }

    return ListItem(title: ChipWrap(methodNames));
  }

  void _onShare() {
    var shareText = _speciesName ?? "";

    if (_catch.hasLength()) {
      shareText += newLineOrEmpty(shareText);
      shareText += Strings.of(
        context,
      ).shareLength(_catch.length.displayValue(context));
    }

    if (_catch.hasWeight()) {
      shareText += newLineOrEmpty(shareText);
      shareText += Strings.of(
        context,
      ).shareWeight(_catch.weight.displayValue(context));
    }

    if (_catch.baits.isNotEmpty) {
      if (_catch.baits.length == 1) {
        shareText += newLineOrEmpty(shareText);
        shareText += Strings.of(context).shareBait(
          _baitManager.attachmentDisplayValue(context, _catch.baits[0]),
        );
      } else {
        shareText += newLineOrEmpty(shareText);
        shareText += Strings.of(context).shareBaits(
          _baitManager
              .attachmentsDisplayValues(context, _catch.baits)
              .join(", "),
        );
      }
    }

    share(
      context,
      _catch.imageNames,
      _shareButtonKey.globalPosition(),
      text: shareText,
    );
  }

  void _onCopy() {
    if (SubscriptionManager.get.isFree) {
      present(context, const AnglersLogProPage());
    } else {
      present(
        context,
        SaveCatchPage.copied(
          _catch.deepCopy()
            // ID and images are really the only fields that definitely will not be
            // the same value.
            ..id = randomId()
            ..imageNames.clear(),
        ),
      );
    }
  }

  String? get _speciesName => _speciesManager.entity(_catch.speciesId)?.name;
}

class _BaitAttachmentListItem extends StatelessWidget {
  final BaitAttachment attachment;

  const _BaitAttachmentListItem(this.attachment);

  @override
  Widget build(BuildContext context) {
    var baitManager = BaitManager.of(context);

    var bait = baitManager.entity(attachment.baitId);
    if (bait == null) {
      return const SizedBox();
    }

    // If the variant attached to this attachment no longer exists, do not
    // show anything.
    var variant = baitManager.variant(bait, attachment.variantId);
    if (attachment.hasVariantId() && variant == null) {
      return const SizedBox();
    }

    var title = baitManager.formatNameWithCategory(bait.id)!;
    String? subtitle;
    VoidCallback onTap;

    if (variant == null) {
      onTap = () => push(context, BaitPage(bait));
    } else {
      subtitle = baitManager.variantDisplayValue(
        context,
        variant,
        includeCustomValues: true,
      );
      onTap = () {
        push(context, BaitVariantPage(variant, allowBaseViewing: true));
      };
    }

    return ImageListItem(
      imageName: bait.displayImageName,
      title: title,
      subtitle: subtitle,
      trailing: RightChevronIcon(),
      onTap: onTap,
    );
  }
}

class _GearListItem extends StatelessWidget {
  final Id gearId;

  const _GearListItem(this.gearId);

  @override
  Widget build(BuildContext context) {
    var gear = GearManager.of(context).entity(gearId);
    if (gear == null) {
      return const SizedBox();
    }

    var model = GearListItemModel(context, gear);

    return ImageListItem(
      imageName: model.imageName,
      title: model.title,
      subtitle: model.subtitle,
      trailing: RightChevronIcon(),
      onTap: () => push(context, GearPage(gear)),
    );
  }
}
