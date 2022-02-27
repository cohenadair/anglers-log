import 'package:flutter/material.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/entity_utils.dart';
import 'package:mobile/wrappers/url_launcher_wrapper.dart';

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
  static const _instagramWebUrl =
      "https://www.instagram.com/explore/tags/anglerslogapp/?hl=en";
  static const _instagramAppUrl = "instagram://tag?name=anglerslogapp";
  static const _twitterWebUrl =
      "https://twitter.com/search?f=realtime&q=%23anglerslogapp&src=typd&lang=en";
  static const _twitterAppUrl = "twitter://search?query=%23anglerslogapp";
  static const _twitterColor = Color.fromRGBO(29, 155, 240, 100);
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
              page: const ProPage(),
              presentPage: true,
            ),
            _buildRateAndFeedbackItems(context),
            _buildHashtagItem(
              context,
              icon: CustomIcons.instagram,
              appUrl: _instagramAppUrl,
              webUrl: _instagramWebUrl,
            ),
            _buildHashtagItem(
              context,
              icon: CustomIcons.twitter,
              iconColor: _twitterColor,
              appUrl: _twitterAppUrl,
              webUrl: _twitterWebUrl,
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
      trailing: const Icon(Icons.open_in_new),
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
      trailing: const Icon(Icons.open_in_new),
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
  }) {
    if (!isVisible) {
      return const Empty();
    }

    assert(page != null || onTap != null);

    return ListItem(
      key: key,
      title: Text(title),
      leading: Icon(icon),
      trailing: presentPage || onTap != null ? trailing : RightChevronIcon(),
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
