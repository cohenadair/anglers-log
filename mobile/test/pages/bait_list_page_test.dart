import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/bait_list_page.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/list_item.dart';
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
    appManager = StubbedAppManager();

    when(appManager.baitCategoryManager.listSortedByName())
        .thenReturn(baitCategories);
    when(appManager.baitCategoryManager.addSimpleListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
    )).thenReturn(SimpleEntityListener());

    when(appManager.baitManager.filteredList(any)).thenReturn(baits);
    when(appManager.baitManager.addSimpleListener(
      onAdd: anyNamed("onAdd"),
      onUpdate: anyNamed("onUpdate"),
      onDelete: anyNamed("onDelete"),
    )).thenReturn(SimpleEntityListener());
  });

  testWidgets("Single picker title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => BaitListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, __) => false,
        ),
      ),
      appManager: appManager,
    ));
    expect(find.text("Select Bait"), findsOneWidget);
  });

  testWidgets("Multi picker title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => BaitListPage(
        pickerSettings: ManageableListPagePickerSettings(
          onPicked: (_, __) => false,
        ),
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
    var context = await pumpContext(
      tester,
      (_) => BaitListPage(),
      appManager: appManager,
    );
    expect(find.text("Baits (5)"), findsOneWidget);

    when(appManager.baitManager.filteredList(any)).thenReturn([
      baits[1],
      baits[2],
    ]);
    await enterTextAndSettle(tester, find.byType(CupertinoTextField), "Shad");
    await tester.pumpAndSettle(Duration(milliseconds: 600));

    expect(find.primaryText(context), findsNWidgets(2));
    expect(find.text("Baits (2)"), findsOneWidget);
  });

  testWidgets("onPicked callback invoked", (tester) async {
    Bait? pickedBait;
    await tester.pumpWidget(Testable(
      (_) => BaitListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, bait) {
            pickedBait = bait;
            return false;
          },
        ),
      ),
      appManager: appManager,
    ));
    await tapAndSettle(tester, find.text("Bullhead Minnow"));

    expect(pickedBait, isNotNull);
    expect(pickedBait, baits[0]);
  });

  testWidgets("All baits picked only includes Bait objects", (tester) async {
    Set<Bait>? pickedBaits;
    await tester.pumpWidget(
      Testable(
        (context) => Scaffold(
          body: Button(
            text: "Test",
            onPressed: () => push(
              context,
              BaitListPage(
                pickerSettings: ManageableListPagePickerSettings(
                  onPicked: (_, baits) {
                    pickedBaits = baits as Set<Bait>?;
                    return false;
                  },
                ),
              ),
            ),
          ),
        ),
        appManager: appManager,
      ),
    );

    await tapAndSettle(tester, find.byType(Button));
    await tapAndSettle(
      tester,
      find.descendant(
        of: find.widgetWithText(ManageableListItem, "All"),
        matching: find.byType(PaddedCheckbox),
      ),
    );
    await tapAndSettle(tester, find.byType(BackButton));

    expect(pickedBaits, isNotNull);
    expect(pickedBaits!.length, 5);
  });

  testWidgets("No baits picked doesn't crash", (tester) async {
    Set<Bait>? pickedBaits;
    await tester.pumpWidget(
      Testable(
        (context) => Scaffold(
          body: Button(
            text: "Test",
            onPressed: () => push(
              context,
              BaitListPage(
                pickerSettings: ManageableListPagePickerSettings(
                  onPicked: (_, baits) {
                    pickedBaits = baits as Set<Bait>?;
                    return false;
                  },
                ),
              ),
            ),
          ),
        ),
        appManager: appManager,
      ),
    );

    await tapAndSettle(tester, find.byType(Button));
    // Select all.
    await tapAndSettle(
      tester,
      find.descendant(
        of: find.widgetWithText(ManageableListItem, "All"),
        matching: find.byType(PaddedCheckbox),
      ),
    );
    // Deselect all.
    await tapAndSettle(
      tester,
      find.descendant(
        of: find.widgetWithText(ManageableListItem, "All"),
        matching: find.byType(PaddedCheckbox),
      ),
    );
    await tapAndSettle(tester, find.byType(BackButton));

    expect(pickedBaits, isNotNull);
    expect(pickedBaits!.isEmpty, isTrue);
  });

  testWidgets("Different item types are rendered", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => BaitListPage(),
      appManager: appManager,
    );

    var baitCategoryHeadings =
        tester.widgetList(find.listHeadingText(context)).toList();
    expect(baitCategoryHeadings.length, 2);
    expect((baitCategoryHeadings[0] as Text).data, "Artificial");
    expect((baitCategoryHeadings[1] as Text).data, "Live");

    var baitLabels = tester.widgetList(find.primaryText(context)).toList();
    expect(baitLabels.length, 5);
    expect((baitLabels[0] as Text).data, "Countdown Rapala 7");
    expect((baitLabels[1] as Text).data, "Skunk Flatfish");
    expect((baitLabels[2] as Text).data, "Bullhead Minnow");
    expect((baitLabels[3] as Text).data, "Gizzard Shad");
    expect((baitLabels[4] as Text).data, "Threadfin Shad");

    expect(find.byType(Divider), findsOneWidget);
  });
}
