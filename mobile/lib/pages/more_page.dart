import 'package:flutter/material.dart';
import 'package:mobile/poll_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/entity_utils.dart';
import 'package:mobile/wrappers/url_launcher_wrapper.dart';

import '../i18n/strings.dart';
import '../pages/feedback_page.dart';
import '../pages/photos_page.dart';
import '../pages/settings_page.dart';
import '../utils/page_utils.dart';
import '../utils/share_utils.dart';
import '../utils/store_utils.dart';
import '../widgets/list_item.dart';
import '../widgets/widget.dart';
import 'backup_restore_page.dart';
import 'calendar_page.dart';
import 'csv_page.dart';
import 'polls_page.dart';
import 'pro_page.dart';
import 'scroll_page.dart';

class MorePage extends StatelessWidget {
  static const _instagramWebUrl =
      "https://www.instagram.com/explore/tags/anglerslogapp/?hl=en";
  static const _instagramAppUrl = "instagram://tag?name=anglerslogapp";
  static const _feedbackBorderWidth = 1.0;

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
              icon: Icons.calendar_month,
              title: Strings.of(context).calendarPageTitle,
              page: CalendarPage(),
            ),
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
            _buildPageItem(
              context,
              icon: shareIconData(context),
              title: Strings.of(context).csvPageTitle,
              page: CsvPage(),
              presentPage: true,
            ),
            const MinDivider(),
            _buildPageItem(
              context,
              icon: Icons.poll,
              title: Strings.of(context).pollsPageTitle,
              showNotificationBadge: PollManager.of(context).canVote,
              page: PollsPage(),
            ),
            _buildPageItem(
              context,
              icon: Icons.stars,
              title: Strings.of(context).morePagePro,
              page: const ProPage(),
              presentPage: true,
            ),
            _buildRateAndFeedbackItems(context),
            _buildHashtagItem(
              context,
              icon: CustomIcons.instagram,
              iconColor: context.colorGreyAccent,
              appUrl: _instagramAppUrl,
              webUrl: _instagramWebUrl,
            ),
            const MinDivider(),
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

  Widget _buildRateAndFeedbackItems(BuildContext context) {
    var rateItem = _buildPageItem(
      context,
      icon: Icons.star,
      trailing: const OpenInWebIcon(),
      title: Strings.of(context).morePageRateApp,
      onTap: () => launchStore(context),
    );

    var feedbackItem = _buildPageItem(
      context,
      icon: Icons.feedback,
      title: Strings.of(context).feedbackPageTitle,
      page: const FeedbackPage(),
      presentPage: true,
    );

    var column = Column(
      children: [
        rateItem,
        feedbackItem,
      ],
    );

    if (feedbackKey == null) {
      return column;
    }

    return Container(
      key: feedbackKey,
      decoration: BoxDecoration(
        border: Border.all(
          width: _feedbackBorderWidth,
          color: Colors.green,
        ),
      ),
      child: column,
    );
  }

  Widget _buildHashtagItem(
    BuildContext context, {
    required IconData icon,
    Color? iconColor,
    required String appUrl,
    required String webUrl,
  }) {
    return ListItem(
      title: Text(Strings.of(context).hashtag),
      leading: Icon(
        icon,
        color: iconColor,
      ),
      trailing: const OpenInWebIcon(),
      onTap: () async {
        var urlLauncher = UrlLauncherWrapper.of(context);
        if (await urlLauncher.canLaunch(appUrl)) {
          urlLauncher.launch(appUrl);
        } else {
          urlLauncher.launch(webUrl);
        }
      },
    );
  }

  Widget _buildPageItem(
    BuildContext context, {
    Key? key,
    required IconData icon,
    required String title,
    Widget? page,
    Widget? trailing,
    VoidCallback? onTap,
    bool presentPage = false,
    bool isVisible = true,
    bool showNotificationBadge = false,
  }) {
    if (!isVisible) {
      return const Empty();
    }

    assert(page != null || onTap != null);

    return ListItem(
      key: key,
      title: Text(title),
      leading: GreyAccentIcon(icon),
      trailing: _buildTrailing(
        presentPage: presentPage,
        onTap: onTap,
        showBadge: showNotificationBadge,
        trailing: trailing,
      ),
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

  Widget _buildTrailing({
    required bool presentPage,
    required VoidCallback? onTap,
    required bool showBadge,
    required Widget? trailing,
  }) {
    return Row(
      children: [
        MyBadge(isVisible: showBadge),
        const HorizontalSpace(paddingSmall),
        presentPage || onTap != null
            ? (trailing ?? const Empty())
            : RightChevronIcon(),
      ],
    );
  }
}
