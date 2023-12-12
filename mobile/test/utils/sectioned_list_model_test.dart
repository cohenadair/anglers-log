import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/sectioned_list_model.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

void main() {
  testWidgets("buildModel", (tester) async {
    var model = _TestModel().buildModel(await buildContext(tester), null);
    expect(model.length, 7);
    expect((model[0] as BaitCategory).name, "Bugger");
    expect((model[1] as Bait).name, "Cyan");
    expect((model[2] as Bait).name, "Olive");
    expect((model[3] as BaitCategory).name, "Live");
    expect((model[4] as Bait).name, "Minnow");
    expect((model[5] as BaitCategory).name, "Other");
    expect((model[6] as Bait).name, "Crank");
  });

  testWidgets("buildItemModel", (tester) async {
    var context = await buildContext(tester);
    var model = _TestModel();
    var itemModels = model
        .buildModel(context, null)
        .map((e) => model.buildItemModel(context, e))
        .toList();

    expect(itemModels.length, 7);
    expect(
      ((itemModels[0].child as Padding).child as HeadingDivider).showDivider,
      isFalse,
    );
    expect(
      ((itemModels[0].child as Padding).child as HeadingDivider).text,
      "Bugger",
    );
    expect((itemModels[1].child as Text).data, "Cyan");
    expect((itemModels[2].child as Text).data, "Olive");

    expect(
      ((itemModels[3].child as Padding).child as HeadingDivider).showDivider,
      isTrue,
    );
    expect(
      ((itemModels[3].child as Padding).child as HeadingDivider).text,
      "Live",
    );
    expect((itemModels[4].child as Text).data, "Minnow");

    expect(
      ((itemModels[5].child as Padding).child as HeadingDivider).showDivider,
      isTrue,
    );
    expect(
      ((itemModels[5].child as Padding).child as HeadingDivider).text,
      "Other",
    );
    expect((itemModels[6].child as Text).data, "Crank");
  });
}

class _TestModel extends SectionedListModel<BaitCategory, Bait> {
  final _noCategoryId = Id(uuid: "131dfbc9-4313-48b6-930e-867298e553b9");

  final _baitCategories = <BaitCategory>[
    BaitCategory(
      id: randomId(),
      name: "Bugger",
    ),
    BaitCategory(
      id: randomId(),
      name: "Live",
    ),
    BaitCategory(
      id: randomId(),
      name: "Roe",
    ),
  ];

  @override
  ManageableListPageItemModel buildItem(BuildContext context, Bait item) =>
      ManageableListPageItemModel(child: Text(item.name));

  @override
  List<Bait> filteredItemList(BuildContext context, String? filter) => [
        Bait(
          id: randomId(),
          name: "Minnow",
          baitCategoryId: _baitCategories[1].id,
        ),
        Bait(
          id: randomId(),
          name: "Olive",
          baitCategoryId: _baitCategories[0].id,
        ),
        Bait(
          id: randomId(),
          name: "Cyan",
          baitCategoryId: _baitCategories[0].id,
        ),
        Bait(
          id: randomId(),
          name: "Crank",
        ),
      ];

  @override
  Id headerId(BaitCategory header) => header.id;

  @override
  String headerName(BaitCategory header) => header.name;

  @override
  bool itemHasHeaderId(Bait item) => item.hasBaitCategoryId();

  @override
  Id itemHeaderId(Bait item) => item.baitCategoryId;

  @override
  String itemName(BuildContext context, Bait item) => item.name;

  @override
  BaitCategory noSectionHeader(BuildContext context) {
    return BaitCategory(
      id: _noCategoryId,
      name: "Other",
    );
  }

  @override
  Id get noSectionHeaderId => _noCategoryId;

  @override
  List<BaitCategory> sectionHeaders(BuildContext context) => _baitCategories;
}
