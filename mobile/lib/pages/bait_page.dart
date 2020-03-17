import 'package:flutter/material.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/page.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class BaitPage extends StatelessWidget {
  final Bait bait;

  BaitPage(this.bait);

  @override
  Widget build(BuildContext context) {
    return Page(
      appBarStyle: PageAppBarStyle(),
      padding: insetsDefault,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            bait.name,
            style: styleTitle,
          ),
          isNotEmpty(bait.categoryId) ? FutureBuilder<BaitCategory>(
            future: BaitManager.of(context).fetchCategory(bait.categoryId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Empty();
              }
              return HeadingText(snapshot.data.name);
            },
          ) : Empty(),
        ],
      ),
    );
  }
}