import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/method_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  var methods = [
    Method()
      ..id = randomId()
      ..name = "Casting",
    Method()
      ..id = randomId()
      ..name = "Kayak",
  ];

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.methodManager.listSortedByDisplayName(
      any,
      filter: anyNamed("filter"),
    )).thenReturn(methods);
  });

  testWidgets("Picker title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MethodListPage(
        pickerSettings: ManageableListPagePickerSettings(
          onPicked: (_, __) => false,
        ),
      ),
      appManager: appManager,
    ));
    expect(find.text("Select Fishing Methods"), findsOneWidget);
  });

  testWidgets("Normal title", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const MethodListPage(),
      appManager: appManager,
    ));
    expect(find.text("Fishing Methods (2)"), findsOneWidget);
  });

  testWidgets("Normal title filtered", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const MethodListPage(),
      appManager: appManager,
    ));
    expect(find.text("Fishing Methods (2)"), findsOneWidget);

    when(appManager.methodManager.listSortedByDisplayName(
      any,
      filter: anyNamed("filter"),
    )).thenReturn([methods[0]]);

    await enterTextAndSettle(tester, find.byType(CupertinoTextField), "Any");
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(find.text("Fishing Methods (1)"), findsOneWidget);
  });

  testWidgets("onPicked callback invoked", (tester) async {
    Method? pickedAngler;
    await tester.pumpWidget(Testable(
      (_) => MethodListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, method) {
            pickedAngler = method;
            return false;
          },
        ),
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Casting"));
    expect(pickedAngler, isNotNull);
    expect(pickedAngler, methods[0]);
  });
}
