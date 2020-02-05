import 'package:flutter/material.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/save_bait_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

class BaitListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: format(Strings.of(context).baitListPageTitle,
            [BaitManager.of(context).numberOfBaits]),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => push(
              context,
              SaveBaitPage(),
              fullscreenDialog: true,
            ),
          ),
        ],
      ),
      padding: insetsDefault,
      child: Empty(),
    );
  }
}