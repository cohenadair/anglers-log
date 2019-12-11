import 'package:flutter/material.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

class TripListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: format(Strings.of(context).tripListPageTitle,
            [CatchManager.of(context).numberOfCatchPhotos]),
        actions: [
        ],
      ),
      padding: insetsDefault,
      child: Empty(),
    );
  }
}