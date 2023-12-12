import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../body_of_water_manager.dart';
import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../pages/save_fishing_spot_page.dart';
import '../res/style.dart';
import '../utils/sectioned_list_model.dart';
import '../utils/string_utils.dart';
import '../widgets/widget.dart';

class FishingSpotListPage extends StatefulWidget {
  final FishingSpotListPagePickerSettings? pickerSettings;

  const FishingSpotListPage({
    this.pickerSettings,
  });

  @override
  State<FishingSpotListPage> createState() => _FishingSpotListPageState();
}

class _FishingSpotListPageState extends State<FishingSpotListPage> {
  late _FishingSpotListPageModel _model;

  BodyOfWaterManager get _bodyOfWaterManager => BodyOfWaterManager.of(context);

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  bool get _isPicking => widget.pickerSettings != null;

  @override
  void initState() {
    super.initState();

    _model = _FishingSpotListPageModel(
      bodyOfWaterManager: _bodyOfWaterManager,
      fishingSpotManager: _fishingSpotManager,
      itemBuilder: _buildFishingSpotItem,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManageableListPage<dynamic>(
      titleBuilder: (items) => Text(
        format(
          Strings.of(context).fishingSpotListPageTitle,
          [items.whereType<FishingSpot>().length],
        ),
      ),
      forceCenterTitle: !_isPicking,
      itemBuilder: _model.buildItemModel,
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).fishingSpotListPageSearchHint,
      ),
      pickerSettings: _manageableListPagePickerSettings(context, _model),
      itemManager: ManageableListPageItemManager<dynamic>(
        listenerManagers: [
          _bodyOfWaterManager,
          _fishingSpotManager,
        ],
        loadItems: (query) => _model.buildModel(context, query),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: iconFishingSpot,
          title: Strings.of(context).fishingSpotListPageEmptyListTitle,
          description:
              Strings.of(context).fishingSpotListPageEmptyListDescription,
          descriptionIcon: Icons.add,
        ),
        deleteWidget: (context, fishingSpot) =>
            Text(_fishingSpotManager.deleteMessage(context, fishingSpot)),
        deleteItem: (context, fishingSpot) =>
            _fishingSpotManager.delete(fishingSpot.id),
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
        fishingSpots.removeWhere((e) => e is! FishingSpot);
        return widget.pickerSettings!.onPicked(context,
            fishingSpots.map<FishingSpot>((e) => e as FishingSpot).toSet());
      },
      containsAll: (fishingSpots) => fishingSpots.containsAll(model.items),
      title: Text(Strings.of(context).pickerTitleFishingSpot),
      multiTitle: Text(Strings.of(context).pickerTitleFishingSpots),
      isMulti: widget.pickerSettings!.isMulti,
      isRequired: widget.pickerSettings!.isRequired,
      initialValues: widget.pickerSettings!.initialValues,
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
              : const Empty(),
        ],
      ),
    );
  }
}

class FishingSpotListPagePickerSettings {
  final bool Function(BuildContext, Set<FishingSpot>) onPicked;
  final Set<FishingSpot> initialValues;
  final bool isMulti;
  final bool isRequired;

  FishingSpotListPagePickerSettings({
    required this.onPicked,
    this.initialValues = const {},
    this.isMulti = true,
    this.isRequired = false,
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

  FishingSpotListPagePickerSettings.fromManageableList(
      ManageableListPagePickerSettings<FishingSpot> settings)
      : onPicked = settings.onPicked,
        initialValues = settings.initialValues,
        isRequired = settings.isRequired,
        isMulti = settings.isMulti;
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
  List<FishingSpot> filteredItemList(BuildContext context, String? filter) =>
      fishingSpotManager.filteredList(context, filter);

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
      fishingSpotManager.displayName(context, item);

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
  List<BodyOfWater> sectionHeaders(BuildContext context) =>
      bodyOfWaterManager.listSortedByDisplayName(context);
}
