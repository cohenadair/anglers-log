import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../body_of_water_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_fishing_spot_page.dart';
import '../res/style.dart';
import '../utils/protobuf_utils.dart';
import '../utils/sectioned_list_model.dart';
import '../utils/string_utils.dart';
import '../widgets/widget.dart';

class FishingSpotListPage extends StatelessWidget {
  final FishingSpotListPagePickerSettings? pickerSettings;

  FishingSpotListPage({
    this.pickerSettings,
  });

  bool get _isPicking => pickerSettings != null;

  @override
  Widget build(BuildContext context) {
    var bodyOfWaterManager = BodyOfWaterManager.of(context);
    var fishingSpotManager = FishingSpotManager.of(context);

    var model = _FishingSpotListPageModel(
      bodyOfWaterManager: bodyOfWaterManager,
      fishingSpotManager: fishingSpotManager,
      itemBuilder: _buildFishingSpotItem,
    );

    return ManageableListPage<dynamic>(
      titleBuilder: (items) => Text(
        format(
          Strings.of(context).fishingSpotListPageTitle,
          [items.whereType<FishingSpot>().length],
        ),
      ),
      forceCenterTitle: !_isPicking,
      itemBuilder: model.buildItemModel,
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).fishingSpotListPageSearchHint,
      ),
      pickerSettings: _manageableListPagePickerSettings(context, model),
      itemManager: ManageableListPageItemManager<dynamic>(
        listenerManagers: [
          bodyOfWaterManager,
          fishingSpotManager,
        ],
        loadItems: (query) => model.buildModel(context, query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: Icons.place,
          title: Strings.of(context).fishingSpotListPageEmptyListTitle,
          description:
              Strings.of(context).fishingSpotListPageEmptyListDescription,
        ),
        deleteWidget: (context, fishingSpot) =>
            Text(fishingSpotManager.deleteMessage(context, fishingSpot)),
        deleteItem: (context, fishingSpot) =>
            fishingSpotManager.delete(fishingSpot.id),
        editPageBuilder: (fishingSpot) => SaveFishingSpotPage.edit(fishingSpot),
      ),
    );
  }

  ManageableListPagePickerSettings<dynamic>? _manageableListPagePickerSettings(
      BuildContext context, SectionedListModel model) {
    if (!_isPicking) {
      return null;
    }

    return ManageableListPagePickerSettings<dynamic>(
      onPicked: (context, fishingSpots) {
        fishingSpots..removeWhere((e) => !(e is FishingSpot));
        return pickerSettings!.onPicked(
            context,
            fishingSpots.map<FishingSpot>((e) => e as FishingSpot).toSet());
      },
      containsAll: (fishingSpots) => fishingSpots.containsAll(model.items),
      title: Text(Strings.of(context).pickerTitleFishingSpot),
      multiTitle: Text(Strings.of(context).pickerTitleFishingSpots),
      isMulti: pickerSettings!.isMulti,
      initialValues: pickerSettings!.initialValues,
    );
  }

  ManageableListPageItemModel _buildFishingSpotItem(
      BuildContext context, FishingSpot fishingSpot) {
    var latLngString = formatLatLng(
      context: context,
      lat: fishingSpot.lat,
      lng: fishingSpot.lng,
    );

    return ManageableListPageItemModel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isNotEmpty(fishingSpot.name) ? fishingSpot.name : latLngString,
            style: stylePrimary(context),
          ),
          isNotEmpty(fishingSpot.name)
              ? Text(latLngString, style: styleSubtitle(context))
              : Empty(),
        ],
      ),
    );
  }
}

class FishingSpotListPagePickerSettings {
  final bool Function(BuildContext, Set<FishingSpot>) onPicked;
  final Set<FishingSpot> initialValues;
  final bool isMulti;

  FishingSpotListPagePickerSettings({
    required this.onPicked,
    this.initialValues = const {},
    this.isMulti = true,
  });

  FishingSpotListPagePickerSettings.single({
    required bool Function(BuildContext, FishingSpot?) onPicked,
    FishingSpot? initialValue,
  }) : this(
          onPicked: (context, spots) =>
              onPicked(context, spots.isEmpty ? null : spots.first),
          initialValues:
              initialValue == null ? <FishingSpot>{} : {initialValue},
          isMulti: false,
        );
}

class _FishingSpotListPageModel
    extends SectionedListModel<BodyOfWater, FishingSpot> {
  final _noBodyOfWaterId = Id(uuid: "325623c2-b191-470b-ba61-8fd41ed5cb5d");

  final BodyOfWaterManager bodyOfWaterManager;
  final FishingSpotManager fishingSpotManager;
  final ManageableListPageItemModel Function(BuildContext, FishingSpot)
      itemBuilder;

  _FishingSpotListPageModel({
    required this.bodyOfWaterManager,
    required this.fishingSpotManager,
    required this.itemBuilder,
  });

  @override
  ManageableListPageItemModel buildItem(
          BuildContext context, FishingSpot item) =>
      itemBuilder(context, item);

  @override
  List<FishingSpot> filteredItemList(String? filter) =>
      fishingSpotManager.filteredList(filter);

  @override
  Id headerId(BodyOfWater header) => header.id;

  @override
  String headerName(BodyOfWater header) => header.name;

  @override
  bool itemHasHeaderId(FishingSpot item) => item.hasBodyOfWaterId();

  @override
  Id itemHeaderId(FishingSpot item) => item.bodyOfWaterId;

  @override
  String itemName(BuildContext context, FishingSpot item) =>
      item.displayName(context);

  @override
  BodyOfWater noSectionHeader(BuildContext context) {
    return BodyOfWater(
      id: _noBodyOfWaterId,
      name: Strings.of(context).fishingSpotListPageNoBodyOfWater,
    );
  }

  @override
  Id get noSectionHeaderId => _noBodyOfWaterId;

  @override
  List<BodyOfWater> get sectionHeaders => bodyOfWaterManager.listSortedByName();
}
