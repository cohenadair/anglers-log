import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../pages/bait_category_list_page.dart';
import '../pages/bait_list_page.dart';
import '../pages/custom_entity_list_page.dart';
import '../pages/feedback_page.dart';
import '../pages/import_page.dart';
import '../pages/photos_page.dart';
import '../pages/settings_page.dart';
import '../pages/species_list_page.dart';
import '../pages/trip_list_page.dart';
import '../res/gen/custom_icons.dart';
import '../utils/page_utils.dart';
import '../utils/store_utils.dart';
import '../widgets/list_item.dart';
import '../widgets/widget.dart';
import 'scroll_page.dart';

class MorePage extends StatelessWidget {
  /// A [GlobalKey] for the feedback row. Used for scrolling to the feedback
  /// row when onboarding users.
  ///
  /// When this value is non-null, the feedback row will be highlighted to
  /// draw the user's attention.
  final GlobalKey feedbackKey;

  MorePage({
    this.feedbackKey,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      appBar: AppBar(
        title: Text(Strings.of(context).morePageTitle),
        centerTitle: true,
      ),
      children: [
        _buildPageItem(
          context,
          icon: CustomIcons.baitCategories,
          title: Strings.of(context).baitCategoryListPageMenuTitle,
          page: BaitCategoryListPage(),
        ),
        _buildPageItem(
          context,
          icon: Icons.bug_report,
          title: Strings.of(context).baitListPageMenuLabel,
          page: BaitListPage(),
        ),
        _buildPageItem(
          context,
          icon: Icons.build,
          title: Strings.of(context).customFields,
          page: CustomEntityListPage(),
        ),
        _buildPageItem(
          context,
          icon: Icons.photo_library,
          title: Strings.of(context).photosPageMenuLabel,
          page: PhotosPage(),
        ),
        _buildPageItem(
          context,
          icon: CustomIcons.species,
          title: Strings.of(context).speciesListPageMenuTitle,
          page: SpeciesListPage(),
        ),
        _buildPageItem(
          context,
          icon: Icons.public,
          title: Strings.of(context).tripListPageMenuLabel,
          page: TripListPage(),
        ),
        MinDivider(),
        _buildPageItem(
          context,
          icon: Icons.cloud_download,
          title: Strings.of(context).importPageMoreTitle,
          page: ImportPage(),
          presentPage: true,
        ),
        MinDivider(),
      ]
        ..addAll(_buildRateAndFeedbackItems(context))
        ..addAll([
          _buildPageItem(
            context,
            icon: Icons.settings,
            title: Strings.of(context).settingsPageTitle,
            page: SettingsPage(),
          ),
        ]),
    );
  }

  List<Widget> _buildRateAndFeedbackItems(BuildContext context) {
    var rateItem = _buildPageItem(
      context,
      icon: Icons.star,
      title: Strings.of(context).morePageRateApp,
      onTap: () => launchStore(context),
    );

    var feedbackItem = _buildPageItem(
      context,
      key: feedbackKey,
      icon: Icons.feedback,
      title: Strings.of(context).feedbackPageTitle,
      page: FeedbackPage(),
      presentPage: true,
    );

    if (feedbackKey == null) {
      return [rateItem, feedbackItem];
    }

    var borderSide = BorderSide(
      width: 1.0,
      color: Colors.green,
    );

    return [
      Container(
        decoration: BoxDecoration(
          border: Border(
            left: borderSide,
            top: borderSide,
            right: borderSide,
          ),
        ),
        child: rateItem,
      ),
      Container(
        decoration: BoxDecoration(
          border: Border(
            left: borderSide,
            bottom: borderSide,
            right: borderSide,
          ),
        ),
        child: feedbackItem,
      ),
    ];
  }

  Widget _buildPageItem(
    BuildContext context, {
    Key key,
    @required IconData icon,
    @required String title,
    Widget page,
    VoidCallback onTap,
    bool presentPage = false,
  }) {
    return ListItem(
      key: key,
      title: Text(title),
      leading: Icon(icon),
      trailing: presentPage || onTap != null ? null : RightChevronIcon(),
      onTap: () {
        if (onTap != null) {
          onTap();
          return;
        }

        if (presentPage) {
          present(context, page);
        } else {
          push(context, page);
        }
      },
    );
  }
}
