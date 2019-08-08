import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/angler.dart';
import 'package:mobile/pages/form_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/input.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/widget.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(
        title: "Home",
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => push(context, FormPage(
              inputWidgetMap: {
                Angler.keyName : TextInput(
                  label: Strings.of(context).anglerNameLabel,
                  requiredText: format(Strings.of(context).inputRequiredMessage,
                      [Strings.of(context).anglerNameLabel]),
                  capitalization: TextCapitalization.words,
                ),
              },
              onSave: (Map<String, dynamic> result) => print(result),
            ), fullscreenDialog: true),
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