import 'package:adair_flutter_lib/pages/scroll_page.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/wrappers/package_info_wrapper.dart';
import 'package:mobile/wrappers/url_launcher_wrapper.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../utils/string_utils.dart';
import '../widgets/widget.dart';

class AboutPage extends StatelessWidget {
  static const _urlPrivacy =
      "https://anglerslog.ca/privacy/2.0/privacy-policy%s.html";

  const AboutPage();

  @override
  Widget build(BuildContext context) {
    var packageInfo = PackageInfoWrapper.of(context);
    var urlLauncher = UrlLauncherWrapper.of(context);

    return ScrollPage(
      appBar: AppBar(),
      children: [
        ListItem(
          title: Text(Strings.of(context).aboutPageVersion),
          trailing: FutureBuilder<PackageInfo>(
            future: packageInfo.fromPlatform(),
            builder: (context, snapshot) => Text(
              snapshot.hasData
                  ? "${snapshot.data!.version} (${snapshot.data!.buildNumber})"
                  : "",
              style: styleSecondary(context),
            ),
          ),
        ),
        ListItem(
          title: Text(Strings.of(context).aboutPagePrivacy),
          trailing: const OpenInWebIcon(),
          onTap: () {
            var languageCode = Localizations.localeOf(context).languageCode;
            urlLauncher.launch(
              format(_urlPrivacy, [
                languageCode != "en" ? "-$languageCode" : "",
              ]),
            );
          },
        ),
        _buildWorldTides(context),
      ],
    );
  }

  Widget _buildWorldTides(BuildContext context) {
    return ListItem(
      title: Text(Strings.of(context).aboutPageWorldTides),
      trailing: RightChevronIcon(),
      onTap: () => push(
        context,
        ScrollPage(
          appBar: AppBar(),
          padding: insetsDefault,
          children: [
            Linkify(
              text: Strings.of(context).aboutPageWorldTidePrivacy,
              style: stylePrimary(context),
              linkStyle: styleHyperlink(context),
              onOpen: (link) => UrlLauncherWrapper.of(context).launch(link.url),
            ),
          ],
        ),
      ),
    );
  }
}
