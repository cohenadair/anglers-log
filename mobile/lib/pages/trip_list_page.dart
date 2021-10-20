import 'package:flutter/material.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/date_time_utils.dart';
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
        loadItems: (query) => tripManager.listSortedByName(filter: query),
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
    var date = formatDateTimeRange(
      context,
      trip.startDateTime,
      trip.endDateTime,
      abbreviated: true,
    );

    String? title;
    String? subtitle;
    if (isNotEmpty(trip.name)) {
      title = trip.name;
      subtitle = date;
    } else {
      title = date;
    }

    return ManageableListPageItemModel(
      child: ManageableListImageItem(
        imageName: trip.imageNames.isNotEmpty ? trip.imageNames.first : null,
        title: title,
        subtitle: subtitle,
        subtitle2:
            formatNumberOfCatches(context, tripManager.numberOfCatches(trip)),
      ),
    );
  }
}
