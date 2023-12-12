import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/manageable_list_page.dart';
import '../trip_manager.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/list_item.dart';
import 'save_trip_page.dart';
import 'trip_page.dart';

class TripListPage extends StatelessWidget {
  final Iterable<Id> ids;

  const TripListPage({
    this.ids = const [],
  });

  @override
  Widget build(BuildContext context) {
    var tripManager = TripManager.of(context);

    return ManageableListPage<Trip>(
      titleBuilder: (trips) => Text(
        format(Strings.of(context).tripListPageTitle, [trips.length]),
      ),
      forceCenterTitle: true,
      searchDelegate: ManageableListPageSearchDelegate(
        hint: Strings.of(context).tripListPageSearchHint,
      ),
      itemBuilder: (context, trip) =>
          _buildListItem(context, tripManager, trip),
      itemsHaveThumbnail: true,
      itemManager: ManageableListPageItemManager<Trip>(
        listenerManagers: [
          tripManager,
        ],
        loadItems: (query) => tripManager.trips(
          context,
          filter: query,
          opt: TripFilterOptions(tripIds: ids),
        ),
        emptyItemsSettings: ManageableListPageEmptyListSettings(
          icon: Icons.public,
          title: Strings.of(context).tripListPageEmptyListTitle,
          description: Strings.of(context).tripListPageEmptyListDescription,
        ),
        deleteWidget: (context, trip) =>
            Text(tripManager.deleteMessage(context, trip)),
        deleteItem: (context, cat) => tripManager.delete(cat.id),
        addPageBuilder: () => const SaveTripPage(),
        detailPageBuilder: (trip) => TripPage(trip),
        editPageBuilder: (trip) => SaveTripPage.edit(trip),
      ),
    );
  }

  ManageableListPageItemModel _buildListItem(
      BuildContext context, TripManager tripManager, Trip trip) {
    var date = trip.elapsedDisplayValue(context);

    String? title;
    String? subtitle;
    if (isNotEmpty(trip.name)) {
      title = trip.name;
      subtitle = date;
    } else {
      title = date;
    }

    var numberOfCatches = tripManager.numberOfCatches(trip);
    var subtitle2 = formatNumberOfCatches(context, numberOfCatches);
    var subtitle2Style = styleSuccess(context);
    if (numberOfCatches <= 0) {
      subtitle2 = Strings.of(context).tripSkunked;
      subtitle2Style = styleError(context);
    }

    return ManageableListPageItemModel(
      child: ManageableListImageItem(
        imageName: trip.imageNames.firstOrNull,
        title: title,
        subtitle: subtitle,
        subtitle2: subtitle2,
        subtitle2Style:
            subtitle2Style.copyWith(fontSize: styleSubtitle(context).fontSize),
      ),
    );
  }
}
