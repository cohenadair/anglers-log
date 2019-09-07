import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

import 'add_catch_page.dart';

class CatchListPage extends StatelessWidget {
  final AppManager app;

  CatchListPage({
    @required this.app,
  }) : assert(app != null);

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: format(Strings.of(context).catchListPageTitle,
            [app.catchManager.numberOfCatches]),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => push(
              context,
              AddCatchPage(app: app),
              fullscreenDialog: true,
            ),
          )
        ],
      ),
      padding: insetsDefault,
      child: Empty(),
    );
  }
}