import 'package:flutter/material.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
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
        ],
      ),
      padding: insetsDefault,
      child: Empty(),
    );
  }
}