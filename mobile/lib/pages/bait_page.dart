import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/pages/save_bait_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/dialog_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class BaitPage extends StatefulWidget {
  final Bait bait;

  BaitPage(this.bait) : assert(bait != null);

  @override
  _BaitPageState createState() => _BaitPageState();
}

class _BaitPageState extends State<BaitPage> {
  Bait _bait;
  BaitCategory _category;
  StreamSubscription _baitsSubscription;

  @override
  void initState() {
    super.initState();

    _bait = widget.bait;
    _baitsSubscription = BaitManager.of(context).onBaitUpdate.stream
        .listen((_) async {
          Bait bait = await BaitManager.of(context).fetchBait(_bait.id);
          setState(() {
            _bait = bait;
          });
        });
  }

  @override
  void dispose() {
    super.dispose();
    finish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ActionButton.edit(
            condensed: true,
            onPressed: () => present(context, SaveBaitPage(
              oldBait: _bait,
              oldBaitCategory: _category,
            )),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => showDeleteDialog(
              context: context,
              description: Text(Strings.of(context).baitPageDeleteMessage),
              onDelete: () {
                BaitManager.of(context).deleteBait(_bait);
                finish();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: insetsDefault,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            isNotEmpty(_bait.categoryId) ? FutureBuilder<BaitCategory>(
              future: BaitManager.of(context)
                  .fetchCategory(_bait.categoryId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Empty();
                }
                _category = snapshot.data;
                return HeadingText(_category.name);
              },
            ) : Empty(),
            Text(
              _bait.name,
              style: styleTitle,
            ),
          ],
        ),
      ),
    );
  }

  void finish() {
    _baitsSubscription.cancel();
  }
}