import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/water_clarity_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  var clarities = [
    WaterClarity()
      ..id = randomId()
      ..name = "Clear",
    WaterClarity()
      ..id = randomId()
      ..name = "Stained",
  ];

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.waterClarityManager.listSortedByDisplayName(
      any,
      filter: anyNamed("filter"),
    )).thenReturn(clarities);
  });

  testWidgets("Picker title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => WaterClarityListPage(
        pickerSettings: ManageableListPagePickerSettings(
          onPicked: (_, __) => false,
        ),
      ),
      appManager: appManager,
    ));
    expect(find.text("Select Water Clarities"), findsOneWidget);
  });

  testWidgets("Normal title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const WaterClarityListPage(),
      appManager: appManager,
    ));
    expect(find.text("Water Clarities (2)"), findsOneWidget);
  });

  testWidgets("Normal title filtered", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const WaterClarityListPage(),
      appManager: appManager,
    ));
    expect(find.text("Water Clarities (2)"), findsOneWidget);

    when(appManager.waterClarityManager.listSortedByDisplayName(
      any,
      filter: anyNamed("filter"),
    )).thenReturn([clarities[0]]);

    await enterTextAndSettle(tester, find.byType(CupertinoTextField), "Any");
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(find.text("Water Clarities (1)"), findsOneWidget);
  });

  testWidgets("onPicked callback invoked", (tester) async {
    WaterClarity? pickedClarity;
    await tester.pumpWidget(Testable(
      (_) => WaterClarityListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, clarity) {
            pickedClarity = clarity;
            return false;
          },
        ),
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Clear"));
    expect(pickedClarity, isNotNull);
    expect(pickedClarity, clarities[0]);
  });
}
