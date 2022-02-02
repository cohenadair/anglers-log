import 'package:flutter/material.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/entity_utils.dart';

import '../i18n/strings.dart';
import '../pages/feedback_page.dart';
import '../pages/photos_page.dart';
import '../pages/settings_page.dart';
import '../utils/page_utils.dart';
import '../utils/store_utils.dart';
import '../widgets/list_item.dart';
import '../widgets/widget.dart';
import 'backup_restore_page.dart';
import 'pro_page.dart';
import 'scroll_page.dart';

class MorePage extends StatelessWidget {
  /// A [GlobalKey] for the feedback row. Used for scrolling to the feedback
  /// row when onboarding users.
  ///
  /// When this value is non-null, the feedback row will be highlighted to
  /// draw the user's attention.
  final GlobalKey? feedbackKey;

  const MorePage({
    this.feedbackKey,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      // Listen for entity tracking changes.
      stream: UserPreferenceManager.of(context).stream,
      builder: (context, snapshot) {
        return ScrollPage(
          appBar: AppBar(
            title: Text(Strings.of(context).morePageTitle),
            centerTitle: true,
          ),
          children: [
            ...allEntitySpecs.map((spec) {
              if (spec == catchesEntitySpec) {
                // Catches is shown in bottom navigation.
                return const Empty();
              }
              return _buildPageItem(
                context,
                icon: spec.icon,
                title: spec.pluralName(context),
                page: spec.listPageBuilder(context),
                isVisible: spec.isTracked(context),
              );
            }).toList(),
            const MinDivider(),
            _buildPageItem(
              context,
              icon: Icons.photo_library,
              title: Strings.of(context).photosPageMenuLabel,
              page: PhotosPage(),
            ),
            const MinDivider(),
            _buildPageItem(
              context,
              icon: BackupPage.icon,
              title: Strings.of(context).backupPageTitle,
              page: BackupPage(),
              presentPage: true,
            ),
            _buildPageItem(
              context,
              icon: RestorePage.icon,
              title: Strings.of(context).restorePageTitle,
              page: RestorePage(),
              presentPage: true,
            ),
            const MinDivider(),
            _buildPageItem(
              context,
              icon: Icons.stars,
              title: Strings.of(context).morePagePro,
              page: ProPage(),
              presentPage: true,
            ),
            ..._buildRateAndFeedbackItems(context),
            _buildPageItem(
              context,
              icon: Icons.settings,
              title: Strings.of(context).settingsPageTitle,
              page: SettingsPage(),
            ),
          ],
        );
      },
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
      page: const FeedbackPage(),
      presentPage: true,
    );

    if (feedbackKey == null) {
      return [rateItem, feedbackItem];
    }

    var borderSide = const BorderSide(
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
    Key? key,
    required IconData icon,
    required String title,
    Widget? page,
    VoidCallback? onTap,
    bool presentPage = false,
    bool isVisible = true,
  }) {
    if (!isVisible) {
      return const Empty();
    }

    assert(page != null || onTap != null);

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
          present(context, page!);
        } else {
          push(context, page!);
        }
      },
    );
  }
}
