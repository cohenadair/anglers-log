import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/bait_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;

  var baitCategories = [
    BaitCategory()
      ..id = randomId()
      ..name = "Artificial",
    BaitCategory()
      ..id = randomId()
      ..name = "Live",
  ];

  var baits = [
    Bait()
      ..id = randomId()
      ..name = "Bullhead Minnow"
      ..baitCategoryId = baitCategories[1].id,
    Bait()
      ..id = randomId()
      ..name = "Threadfin Shad"
      ..baitCategoryId = baitCategories[1].id,
    Bait()
      ..id = randomId()
      ..name = "Gizzard Shad"
      ..baitCategoryId = baitCategories[1].id,
    Bait()
      ..id = randomId()
      ..name = "Skunk Flatfish"
      ..baitCategoryId = baitCategories[0].id,
    Bait()
      ..id = randomId()
      ..name = "Countdown Rapala 7"
      ..baitCategoryId = baitCategories[0].id,
  ];

  setUp(() {
    appManager = MockAppManager(
      mockBaitCategoryManager: true,
      mockBaitManager: true,
    );

    when(appManager.mockBaitCategoryManager.listSortedByName())
        .thenReturn(baitCategories);
    when(appManager.mockBaitManager.filteredList(any)).thenReturn(baits);
  });

  testWidgets("Single picker title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => BaitListPage.picker(
        onPicked: (_, __) => false,
        multiPicker: false,
      ),
      appManager: appManager,
    ));
    expect(find.text("Select Bait"), findsOneWidget);
  });

  testWidgets("Multi picker title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => BaitListPage.picker(
        onPicked: (_, __) => false,
        multiPicker: true,
      ),
      appManager: appManager,
    ));
    expect(find.text("Select Baits"), findsOneWidget);
  });

  testWidgets("Normal title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => BaitListPage(),
      appManager: appManager,
    ));
    expect(find.text("Baits (5)"), findsOneWidget);
  });

  testWidgets("Normal title when filtered", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => BaitListPage(),
      appManager: appManager,
    ));
    expect(find.text("Baits (5)"), findsOneWidget);

    when(appManager.mockBaitManager.filteredList(any)).thenReturn([
      baits[1],
      baits[2],
    ]);
    await enterTextAndSettle(tester, find.byType(CupertinoTextField), "Shad");
    await tester.pumpAndSettle(Duration(milliseconds: 600));

    expect(find.byType(PrimaryLabel), findsNWidgets(2));
    expect(find.text("Baits (2)"), findsOneWidget);
  });

  testWidgets("onPicked callback invoked", (tester) async {
    Set<Bait> pickedBaits;
    await tester.pumpWidget(Testable(
      (_) => BaitListPage.picker(
        onPicked: (_, baits) {
          pickedBaits = baits;
          return false;
        },
      ),
      appManager: appManager,
    ));
    await tapAndSettle(tester, find.text("Bullhead Minnow"));

    expect(pickedBaits, isNotNull);
    expect(pickedBaits.length, 1);
    expect(pickedBaits.first, baits[0]);
  });

  testWidgets("Different item types are rendered", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => BaitListPage(),
      appManager: appManager,
    ));

    var baitCategoryHeadings =
        tester.widgetList(find.byType(HeadingLabel)).toList();
    expect(baitCategoryHeadings.length, 2);
    expect((baitCategoryHeadings[0] as HeadingLabel).text, "Artificial");
    expect((baitCategoryHeadings[1] as HeadingLabel).text, "Live");

    var baitLabels = tester.widgetList(find.byType(PrimaryLabel)).toList();
    expect(baitLabels.length, 5);
    expect((baitLabels[0] as PrimaryLabel).text, "Countdown Rapala 7");
    expect((baitLabels[1] as PrimaryLabel).text, "Skunk Flatfish");
    expect((baitLabels[2] as PrimaryLabel).text, "Bullhead Minnow");
    expect((baitLabels[3] as PrimaryLabel).text, "Gizzard Shad");
    expect((baitLabels[4] as PrimaryLabel).text, "Threadfin Shad");

    expect(find.byType(Divider), findsOneWidget);
  });
}
