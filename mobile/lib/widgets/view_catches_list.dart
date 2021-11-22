import 'package:flutter/material.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/string_utils.dart';

import 'list_item.dart';
import 'widget.dart';

/// A widget that shows a column of items that, when and item is tapped,
/// shows a list of catches. If there are no catches in the model for that
/// row, the row is not clickable and a value of "0" is displayed in place
/// of a [RightChevronIcon].
class ViewCatchesList extends StatelessWidget {
  final Iterable<ViewCatchesListModel> models;

  const ViewCatchesList(this.models);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: models
          .map((model) => _ViewCatchesListItem(model.catchIds, model.dateRange))
          .toList(),
    );
  }
}

class ViewCatchesListModel {
  final Set<Id> catchIds;
  final DateRange dateRange;

  ViewCatchesListModel(this.catchIds, this.dateRange);
}

class _ViewCatchesListItem extends StatelessWidget {
  final Set<Id> catchIds;
  final DateRange dateRange;

  const _ViewCatchesListItem(this.catchIds, this.dateRange);

  @override
  Widget build(BuildContext context) {
    if (catchIds.isEmpty) {
      return ListItem(
        title: Text(Strings.of(context).reportSummaryNumberOfCatches),
        subtitle: Text(dateRange.displayName(context)),
        trailing: Text("0", style: styleSecondary(context)),
      );
    }

    return ListItem(
      title: Text(format(
          Strings.of(context).reportSummaryViewCatches, [catchIds.length])),
      subtitle: Text(dateRange.displayName(context)),
      onTap: () => push(
        context,
        CatchListPage(
          enableAdding: false,
          catches: CatchManager.of(context).list(catchIds),
        ),
      ),
      trailing: RightChevronIcon(),
    );
  }
}
