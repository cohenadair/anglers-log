import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

import 'add_catch_page.dart';

class HomePage extends StatelessWidget {
  final AppManager app;

  HomePage({
    @required this.app,
  }) : assert(app != null);

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: "Home",
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
      child: Button(
        text: "Push",
        onPressed: () => push(context, Page(
          appBarStyle: PageAppBarStyle(
            title: "Pushed Home Page",
          ),
          child: Empty(),
        )),
      ),
    );
  }
}