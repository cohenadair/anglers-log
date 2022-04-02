import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/angler_list_page.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  var anglers = [
    Angler()
      ..id = randomId()
      ..name = "Cohen",
    Angler()
      ..id = randomId()
      ..name = "Someone",
  ];

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.anglerManager.listSortedByDisplayName(
      any,
      filter: anyNamed("filter"),
    )).thenReturn(anglers);
  });

  testWidgets("Picker title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => AnglerListPage(
        pickerSettings: ManageableListPagePickerSettings(
          onPicked: (_, __) => false,
          isMulti: false,
        ),
      ),
      appManager: appManager,
    ));
    expect(find.text("Select Angler"), findsOneWidget);
  });

  testWidgets("Normal title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const AnglerListPage(),
      appManager: appManager,
    ));
    expect(find.text("Anglers (2)"), findsOneWidget);
  });

  testWidgets("Normal title filtered", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const AnglerListPage(),
      appManager: appManager,
    ));
    expect(find.text("Anglers (2)"), findsOneWidget);

    when(appManager.anglerManager.listSortedByDisplayName(
      any,
      filter: anyNamed("filter"),
    )).thenReturn([anglers[0]]);

    await enterTextAndSettle(tester, find.byType(CupertinoTextField), "Any");
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(find.text("Anglers (1)"), findsOneWidget);
  });

  testWidgets("onPicked callback invoked", (tester) async {
    Angler? pickedAngler;
    await tester.pumpWidget(Testable(
      (_) => AnglerListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, angler) {
            pickedAngler = angler;
            return false;
          },
        ),
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Cohen"));
    expect(pickedAngler, isNotNull);
    expect(pickedAngler, anglers[0]);
  });
}
