import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/bait_category_list_page.dart';
import 'package:mobile/pages/bait_list_page.dart';
import 'package:mobile/pages/custom_entity_list_page.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mobile/pages/import_page.dart';
import 'package:mobile/pages/photos_page.dart';
import 'package:mobile/pages/settings_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/pages/trip_list_page.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/widget.dart';

class MorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.of(context).morePageTitle),
      ),
      body: ListView(
        children: <Widget>[
          _buildPageItem(
            context,
            icon: CustomIcons.bait_categories,
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
            title: Strings.of(context).importPageTitle,
            page: ImportPage(),
            presentPage: true,
          ),
          MinDivider(),
          _buildPageItem(
            context,
            icon: Icons.feedback,
            title: Strings.of(context).feedbackPageTitle,
            page: FeedbackPage(),
            presentPage: true,
          ),
          _buildPageItem(
            context,
            icon: Icons.settings,
            title: Strings.of(context).settingsPageTitle,
            page: SettingsPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildPageItem(
    BuildContext context, {
    @required IconData icon,
    @required String title,
    @required Widget page,
    bool presentPage = false,
  }) =>
      ListItem(
        title: Text(title),
        leading: Icon(icon),
        trailing: presentPage ? null : RightChevronIcon(),
        onTap: () {
          if (presentPage) {
            present(context, page);
          } else {
            push(context, page);
          }
        },
      );
}
