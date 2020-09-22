import 'package:flutter/material.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
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

  @override
  Widget build(BuildContext context) {
    assert(_bait != null);

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
        onDelete: () => _baitManager.delete(_bait.id),
        deleteMessage: _baitManager.deleteMessage(context, _bait),
        children: [
          _buildBaitCategory(),
          TitleLabel(_bait.name),
        ],
      ),
    );
  }

  Widget _buildBaitCategory() {
    BaitCategory baitCategory =
        _baitCategoryManager.entity(_bait.baitCategoryId);
    if (baitCategory == null) {
      return Empty();
    }

    return Padding(
      padding: insetsHorizontalDefault,
      child: HeadingLabel(baitCategory.name),
    );
  }
}