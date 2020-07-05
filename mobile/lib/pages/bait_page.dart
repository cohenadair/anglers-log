import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/bait.dart';
import 'package:mobile/model/bait_category.dart';
import 'package:mobile/pages/entity_page.dart';
import 'package:mobile/pages/save_bait_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class BaitPage extends StatefulWidget {
  final String baitId;

  /// See [EntityPage.static].
  final bool static;

  BaitPage(this.baitId, {
    this.static = false,
  }) : assert(isNotEmpty(baitId));

  @override
  _BaitPageState createState() => _BaitPageState();
}

class _BaitPageState extends State<BaitPage> {
  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);
  BaitManager get _baitManager => BaitManager.of(context);

  Bait get _bait => _baitManager.entity(id: widget.baitId);
  BaitCategory get _category =>
      _baitCategoryManager.entity(id: _bait.categoryId);

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder(
      managers: [
        _baitCategoryManager,
        _baitManager,
      ],
      // When deleted, we pop immediately. Don't reload; bait will be null.
      onDeleteEnabled: false,
      builder: (context) => EntityPage(
        entityId: _bait.id,
        padding: EdgeInsets.only(
          top: paddingDefault,
          bottom: paddingDefault,
        ),
        static: widget.static,
        onEdit: () => present(context, SaveBaitPage.edit(_bait)),
        onDelete: () => BaitManager.of(context).delete(_bait),
        deleteMessage: _baitManager.deleteMessage(context, _bait),
        children: [
          isNotEmpty(_bait.categoryId) ? Padding(
            padding: insetsHorizontalDefault,
            child: HeadingLabel(_category.name),
          ) : Empty(),
          TitleLabel(_bait.name),
        ],
      ),
    );
  }
}