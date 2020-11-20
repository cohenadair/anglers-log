import 'package:flutter/material.dart';

import '../i18n/strings.dart';
import '../utils/string_utils.dart';
import '../widgets/widget.dart';

class TripListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(format(Strings.of(context).tripListPageTitle, [0])),
      ),
      body: Empty(),
    );
  }
}
