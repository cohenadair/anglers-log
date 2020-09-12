import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/id.dart';
import 'package:mobile/pages/entity_page.dart';
import 'package:mobile/pages/save_bait_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

class BaitPage extends StatefulWidget {
  final Id baitId;

  /// See [EntityPage.static].
  final bool static;

  BaitPage(this.baitId, {
    this.static = false,
  }) : assert(baitId != null);

  @override
  _BaitPageState createState() => _BaitPageState();
}

class _BaitPageState extends State<BaitPage> {
  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);
  BaitManager get _baitManager => BaitManager.of(context);

  Bait get _bait => _baitManager.entity(widget.baitId);
  BaitCategory get _category =>
      _baitCategoryManager.entity(Id(_bait.baitCategoryId));

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
        customEntityValues: _bait.customEntityValues,
        padding: EdgeInsets.only(
          top: paddingDefault,
          bottom: paddingDefault,
        ),
        static: widget.static,
        onEdit: () => present(context, SaveBaitPage.edit(_bait)),
        onDelete: () => _baitManager.delete(Id(_bait.id)),
        deleteMessage: _baitManager.deleteMessage(context, _bait),
        children: [
          _bait.hasBaitCategoryId() ? Padding(
            padding: insetsHorizontalDefault,
            child: HeadingLabel(_category.name),
          ) : Empty(),
          TitleLabel(_bait.name),
        ],
      ),
    );
  }
}