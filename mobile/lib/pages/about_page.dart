import 'package:flutter/material.dart';
import 'package:mobile/pages/scroll_page.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/wrappers/package_info_wrapper.dart';
import 'package:mobile/wrappers/url_launcher_wrapper.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../i18n/strings.dart';

class AboutPage extends StatelessWidget {
  static const _privacyUrl =
      "https://anglerslog.ca/privacy/2.0/privacy-policy.html";

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
              snapshot.hasData ? snapshot.data!.version : "",
              style: styleSecondary(context),
            ),
          ),
        ),
        ListItem(
          title: Text(Strings.of(context).aboutPagePrivacy),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => urlLauncher.launch(_privacyUrl),
        ),
      ],
    );
  }
}
