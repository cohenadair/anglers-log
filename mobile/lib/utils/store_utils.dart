import 'package:flutter/cupertino.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import '../wrappers/url_launcher_wrapper.dart';

import 'snackbar_utils.dart';

Future<void> launchStore(BuildContext context) async {
  var launcher = UrlLauncherWrapper.of(context);
  var io = IoWrapper.of(context);

  var url = "itms-apps://apps.apple.com/app/id959989008?action=write-review";
  var error = Strings.of(context).morePageRateErrorApple;
  if (io.isAndroid) {
    url =
        "https://play.google.com/store/apps/details?id=com.cohenadair.anglerslog";
    error = Strings.of(context).morePageRateErrorAndroid;
  }

  if (await launcher.canLaunch(url)) {
    launcher.launch(url);
  } else if (context.mounted) {
    showErrorSnackBar(context, error);
  }
}
