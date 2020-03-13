import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/bait_list_page.dart';
import 'package:mobile/pages/settings_page.dart';
import 'package:mobile/pages/trip_list_page.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

class MorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: Strings.of(context).morePageTitle,
      ),
      child: ListView(
        children: <Widget>[
          _buildPageItem(context,
            icon: Icons.public,
            title: Strings.of(context).tripListPageMenuLabel,
            page: TripListPage(),
          ),
          _buildPageItem(context,
            icon: Icons.bug_report,
            title: Strings.of(context).baitListPageMenuLabel,
            page: BaitListPage(),
          ),
          MinDivider(),
          _buildPageItem(context,
            icon: Icons.settings,
            title: Strings.of(context).settingsPageTitle,
            page: SettingsPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildPageItem(BuildContext context, {
    @required IconData icon,
    @required String title,
    @required Widget page,
  }) => ListItem(
    leading: Icon(icon),
    title: Text(title),
    onTap: () => push(context, page),
  );
}