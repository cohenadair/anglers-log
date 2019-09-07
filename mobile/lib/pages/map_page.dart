import 'package:flutter/material.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

class MapPage extends StatelessWidget {
  final AppManager app;

  MapPage({
    @required this.app,
  }) : assert(app != null);

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: "Map",
        actions: [
        ],
      ),
      padding: insetsDefault,
      child: Empty(),
    );
  }
}