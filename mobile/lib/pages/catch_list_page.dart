import 'package:flutter/material.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/save_catch_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

class CatchListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: format(Strings.of(context).catchListPageTitle,
            [CatchManager.of(context).numberOfCatches]),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => present(context, SaveCatchPage()),
          ),
        ],
      ),
      padding: insetsDefault,
      child: Empty(),
    );
  }
}