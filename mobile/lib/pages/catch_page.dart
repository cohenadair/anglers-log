import 'package:flutter/material.dart';
import 'package:mobile/res/style.dart';
import 'package:quiver/strings.dart';

import '../angler_manager.dart';
import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../catch_manager.dart';
import '../entity_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../method_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/bait_page.dart';
import '../pages/entity_page.dart';
import '../pages/save_catch_page.dart';
import '../res/dimen.dart';
import '../res/gen/custom_icons.dart';
import '../species_manager.dart';
import '../utils/date_time_utils.dart';
import '../utils/page_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../water_clarity_manager.dart';
import '../widgets/atmosphere_wrap.dart';
import '../widgets/list_item.dart';
import '../widgets/static_fishing_spot.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';

class CatchPage extends StatefulWidget {
  final Catch cat;

  CatchPage(this.cat);

  @override
  _CatchPageState createState() => _CatchPageState();
}

class _CatchPageState extends State<CatchPage> {
  AnglerManager get _anglerManager => AnglerManager.of(context);

  BaitManager get _baitManager => BaitManager.of(context);

  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);

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
          deleteMessage: _catchManager.deleteMessage(context, _catch),
          imageNames: _catch.imageNames,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                top: paddingDefault,
                right: paddingDefault,
                bottom: paddingSmall,
              ),
              child: _buildHeader(),
            ),
            _buildMethods(),
            _buildBait(),
            _buildFishingSpot(),
            _buildAtmosphere(),
            _buildSize(),
            _buildAngler(),
            _buildCatchAndRelease(),
            _buildWater(),
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
              TitleLabel(
                _speciesManager.entity(_catch.speciesId)?.name ??
                    Strings.of(context).unknownSpecies,
                overflow: TextOverflow.visible,
              ),
              Padding(
                padding: insetsLeftDefault,
                child: Text(
                  _formatTimeFields(),
                  style: styleSubtitle(context),
                ),
              ),
            ],
          ),
        ),
        CatchFavoriteStar(
          _catch,
          large: true,
        ),
      ],
    );
  }

  String _formatTimeFields() {
    var result = formatTimestamp(context, _catch.timestamp.toInt());

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

  Widget _buildBait() {
    var bait = _baitManager.entity(_catch.baitId);
    if (bait == null) {
      return Empty();
    }

    Widget? subtitle;
    var baitCategory = _baitCategoryManager.entity(bait.baitCategoryId);
    if (baitCategory != null) {
      subtitle = Text(baitCategory.name, style: styleSubtitle(context));
    }

    return ListItem(
      title: Text(bait.name),
      subtitle: subtitle,
      trailing: RightChevronIcon(),
      onTap: () => push(
        context,
        BaitPage(
          bait,
          static: true,
        ),
      ),
    );
  }

  Widget _buildFishingSpot() {
    var fishingSpot = _fishingSpotManager.entity(_catch.fishingSpotId);
    if (fishingSpot == null) {
      return Empty();
    }

    return StaticFishingSpot(
      fishingSpot,
      padding: insetsHorizontalDefaultVerticalSmall,
    );
  }

  Widget _buildAtmosphere() {
    if (!_catch.hasAtmosphere()) {
      return Empty();
    }

    return Padding(
      padding: insetsDefault,
      child: AtmosphereWrap(_catch.atmosphere),
    );
  }

  Widget _buildAngler() {
    var angler = _anglerManager.entity(_catch.anglerId);
    if (angler == null) {
      return Empty();
    }

    return ListItem(
      leading: Icon(Icons.person),
      title: Text(angler.name),
    );
  }

  Widget _buildCatchAndRelease() {
    if (!_catch.hasWasCatchAndRelease()) {
      return Empty();
    }

    if (_catch.wasCatchAndRelease) {
      return ListItem(
        leading: Icon(Icons.check_circle),
        title: Text(Strings.of(context).catchPageReleased),
      );
    } else {
      return ListItem(
        leading: Icon(Icons.error),
        title: Text(Strings.of(context).catchPageKept),
      );
    }
  }

  Widget _buildWater() {
    var values = <String>[];

    var clarity = _waterClarityManager.entity(_catch.waterClarityId);
    if (clarity != null) {
      values.add(clarity.name);
    }

    if (_catch.hasWaterTemperature()) {
      values.add(_catch.waterTemperature.displayValue(context));
    }

    if (_catch.hasWaterDepth()) {
      values.add(_catch.waterDepth.displayValue(context));
    }

    if (values.isEmpty) {
      return Empty();
    }

    return ListItem(
      leading: Icon(CustomIcons.waterClarities),
      title: Text(values.join(", ")),
    );
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
      return Empty();
    }

    return ListItem(
      leading: Icon(CustomIcons.ruler),
      title: Text(values.join(", ")),
    );
  }

  Widget _buildNotes() {
    var values = <String>[];

    if (_catch.hasQuantity() && _catch.quantity > 0) {
      values.add(format(
          Strings.of(context).catchPageQuantityLabel, [_catch.quantity]));
    }

    if (_catch.hasNotes() && isNotEmpty(_catch.notes)) {
      values.add(_catch.notes);
    }

    if (values.isEmpty) {
      return Empty();
    }

    Widget buildRow(String value) {
      return Row(
        children: [
          Opacity(
            // Use Opacity so items are horizontally aligned.
            opacity: values.indexOf(value) >= 1 ? 0.0 : 1.0,
            child: Icon(
              Icons.notes,
              color: Theme.of(context).disabledColor,
            ),
          ),
          HorizontalSpace(paddingWidgetDouble),
          Expanded(
            child: Text(
              value,
              style: stylePrimary(context),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: insetsHorizontalDefaultVerticalSmall,
      child: Wrap(
        runSpacing: paddingTiny,
        children: values.map(buildRow).toList(),
      ),
    );
  }

  Widget _buildMethods() {
    if (_catch.methodIds.isEmpty) {
      return Empty();
    }

    var methodNames =
        _methodManager.list(_catch.methodIds).map((m) => m.name).toSet();
    if (methodNames.isEmpty) {
      return Empty();
    }

    return ListItem(title: ChipWrap(methodNames));
  }
}
