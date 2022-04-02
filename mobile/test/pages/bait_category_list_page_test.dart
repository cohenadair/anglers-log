import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/bait_category_list_page.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  var baitCategories = [
    BaitCategory()
      ..id = randomId()
      ..name = "Artificial",
    BaitCategory()
      ..id = randomId()
      ..name = "Live",
  ];

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.baitCategoryManager.listSortedByDisplayName(
      any,
      filter: anyNamed("filter"),
    )).thenReturn(baitCategories);
  });

  testWidgets("Picker title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => BaitCategoryListPage(
        pickerSettings: ManageableListPagePickerSettings(
          onPicked: (_, __) => false,
          isMulti: false,
        ),
      ),
      appManager: appManager,
    ));
    expect(find.text("Select Bait Category"), findsOneWidget);
  });

  testWidgets("Normal title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const BaitCategoryListPage(),
      appManager: appManager,
    ));
    expect(find.text("Bait Categories (2)"), findsOneWidget);
  });

  testWidgets("Normal title filtered", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const BaitCategoryListPage(),
      appManager: appManager,
    ));
    expect(find.text("Bait Categories (2)"), findsOneWidget);

    when(appManager.baitCategoryManager.listSortedByDisplayName(
      any,
      filter: anyNamed("filter"),
    )).thenReturn([baitCategories[0]]);

    await enterTextAndSettle(tester, find.byType(CupertinoTextField), "Any");
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(find.text("Bait Categories (1)"), findsOneWidget);
  });

  testWidgets("onPicked callback invoked", (tester) async {
    BaitCategory? pickedCategory;
    await tester.pumpWidget(Testable(
      (_) => BaitCategoryListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, category) {
            pickedCategory = category;
            return false;
          },
        ),
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Artificial"));
    expect(pickedCategory, isNotNull);
    expect(pickedCategory, baitCategories[0]);
  });
}
