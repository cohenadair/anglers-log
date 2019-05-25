import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: "Home",
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