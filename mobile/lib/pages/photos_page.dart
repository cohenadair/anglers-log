import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

class PhotosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: format(Strings.of(context).photosPageTitle,
            [TripManager.of(context).numberOfTrips]),
        actions: [
        ],
      ),
      padding: insetsDefault,
      child: Empty(),
    );
  }
}