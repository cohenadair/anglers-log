import 'package:flutter/material.dart';
import 'package:mobile/pages/scroll_page.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import 'package:mobile/wrappers/package_info_wrapper.dart';
import 'package:mobile/wrappers/url_launcher_wrapper.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../i18n/strings.dart';
import '../widgets/widget.dart';

class AboutPage extends StatelessWidget {
  static const _urlAppleEula =
      "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/";
  static const _urlPrivacy =
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
              snapshot.hasData
                  ? "${snapshot.data!.version} (${snapshot.data!.buildNumber})"
                  : "",
              style: styleSecondary(context),
            ),
          ),
        ),
        _buildAppleEula(context),
        ListItem(
          title: Text(Strings.of(context).aboutPagePrivacy),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => urlLauncher.launch(_urlPrivacy),
        ),
      ],
    );
  }

  Widget _buildAppleEula(BuildContext context) {
    if (!IoWrapper.of(context).isIOS) {
      return const Empty();
    }

    return ListItem(
      title: Text(Strings.of(context).aboutPageEula),
      trailing: const Icon(Icons.open_in_new),
      onTap: () => UrlLauncherWrapper.of(context).launch(_urlAppleEula),
    );
  }
}
