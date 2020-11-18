import 'package:flutter/material.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/save_fishing_spot_page.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:quiver/strings.dart';

class FishingSpotListPage extends StatelessWidget {
  final bool Function(BuildContext, Set<FishingSpot>) onPicked;
  final bool multiPicker;
  final Set<FishingSpot> initialValues;

  FishingSpotListPage()
      : onPicked = null,
        multiPicker = false,
        initialValues = null;

  FishingSpotListPage.picker({
    @required this.onPicked,
    this.multiPicker = false,
    this.initialValues,
  }) : assert(onPicked != null);

  bool get _picking => onPicked != null;

  @override
  Widget build(BuildContext context) {
    FishingSpotManager fishingSpotManager = FishingSpotManager.of(context);

    String title;
    if (_picking && multiPicker) {
      title = Strings.of(context).fishingSpotListPageMultiPickerTitle;
    } else if (_picking && !multiPicker) {
      title = Strings.of(context).fishingSpotListPageSinglePickerTitle;
    }

    return ManageableListPage<FishingSpot>(
      titleBuilder: isNotEmpty(title)
          ? (_) => Text(title)
          : (fishingSpots) => Text(format(
              Strings.of(context).fishingSpotListPageTitle,
              [fishingSpots.length])),
      forceCenterTitle: !_picking,
      itemBuilder: (context, fishingSpot) => ManageableListPageItemModel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryLabel(fishingSpot.name),
            SubtitleLabel(formatLatLng(
              context: context,
              lat: fishingSpot.lat,
              lng: fishingSpot.lng,
            )),
          ],
        ),
      ),
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).fishingSpotListPageSearchHint,
        noResultsMessage:
            Strings.of(context).fishingSpotListPageNoSearchResults,
      ),
      pickerSettings: _picking
          ? ManageableListPagePickerSettings<FishingSpot>(
              onPicked: (context, fishingSpots) =>
                  onPicked(context, fishingSpots),
              multi: multiPicker,
              initialValues: initialValues,
            )
          : null,
      itemManager: ManageableListPageItemManager<FishingSpot>(
        listenerManagers: [fishingSpotManager],
        loadItems: (query) =>
            fishingSpotManager.listSortedByName(filter: query),
        deleteWidget: (context, fishingSpot) =>
            Text(fishingSpotManager.deleteMessage(context, fishingSpot)),
        deleteItem: (context, fishingSpot) =>
            fishingSpotManager.delete(fishingSpot.id),
        editPageBuilder: (fishingSpot) => SaveFishingSpotPage.edit(fishingSpot),
      ),
    );
  }
}
