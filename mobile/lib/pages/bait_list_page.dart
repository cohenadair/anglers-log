import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

class BaitListPage extends StatelessWidget {
  final AppManager app;

  BaitListPage({
    @required this.app,
  }) : assert(app != null);

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: format(Strings.of(context).baitListPageTitle,
            [app.baitManager.numberOfBaits]),
        actions: [
        ],
      ),
      padding: insetsDefault,
      child: Empty(),
    );
  }
}