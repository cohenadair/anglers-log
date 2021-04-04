import 'package:flutter/material.dart';

import '../bait_category_manager.dart';
import '../bait_manager.dart';
import '../entity_manager.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/entity_page.dart';
import '../pages/save_bait_page.dart';
import '../res/dimen.dart';
import '../utils/page_utils.dart';
import '../widgets/text.dart';
import '../widgets/widget.dart';

class BaitPage extends StatefulWidget {
  final Bait bait;

  /// See [EntityPage.static].
  final bool static;

  BaitPage(
    this.bait, {
    this.static = false,
  });

  @override
  _BaitPageState createState() => _BaitPageState();
}

class _BaitPageState extends State<BaitPage> {
  BaitCategoryManager get _baitCategoryManager =>
      BaitCategoryManager.of(context);
  BaitManager get _baitManager => BaitManager.of(context);

  late Bait _bait;

  @override
  void initState() {
    super.initState();
    _bait = widget.bait;
  }

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder(
      managers: [
        _baitCategoryManager,
        _baitManager,
      ],
      onDeleteEnabled: false,
      builder: (context) {
        // Always fetch the latest bait when the widget tree is (re)built.
        // Fallback on the current bait (if the current was deleted).
        _bait = _baitManager.entity(widget.bait.id) ?? _bait;

        return EntityPage(
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
            TitleLabel(
              _bait.name,
              overflow: TextOverflow.visible,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBaitCategory() {
    var baitCategory = _baitCategoryManager.entity(_bait.baitCategoryId);
    if (baitCategory == null) {
      return Empty();
    }

    return Padding(
      padding: insetsHorizontalDefault,
      child: HeadingLabel(baitCategory.name),
    );
  }
}
