import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/save_name_page.dart';
import 'package:mobile/utils/validator.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mockito/mockito.dart';

import '../test_utils.dart';

void main() {
  testWidgets("Editing a name renders old name", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => SaveNamePage(
          title: Text("Title"),
          oldName: "Old name",
        ),
      ),
    );
    expect(find.text("Old name"), findsOneWidget);
    expect(
        findFirstWithText<ActionButton>(tester, "SAVE").onPressed, isNotNull);
  });

  testWidgets("New name renders error and disabled save button",
      (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => SaveNamePage(
          title: Text("Title"),
        ),
      ),
    );
    expect(findFirst<TextField>(tester).controller.text, isEmpty);
    expect(findFirstWithText<ActionButton>(tester, "SAVE").onPressed, isNull);
  });

  testWidgets("Saving the same as old does not invoke callback",
      (tester) async {
    var invoked = false;
    await tester.pumpWidget(
      Testable(
        (_) => SaveNamePage(
          title: Text("Title"),
          oldName: "Old name",
          onSave: (_) => invoked = true,
        ),
      ),
    );

    await tapAndSettle(tester, find.text("SAVE"));
    expect(invoked, isFalse);
  });

  testWidgets("Null onSave pops page", (tester) async {
    var observer = MockNavigatorObserver();
    var popped = false;
    when(observer.didPop(any, any)).thenAnswer((_) => popped = true);

    await tester.pumpWidget(Testable(
      (_) => SaveNamePage(
        title: Text("Title"),
      ),
      navigatorObserver: observer,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Name");
    await tapAndSettle(tester, find.text("SAVE"));
    expect(popped, isTrue);
  });

  testWidgets("Non-null onSave pops page if returns true",
      (tester) async {
    var observer = MockNavigatorObserver();
    var popped = false;
    when(observer.didPop(any, any)).thenAnswer((_) => popped = true);

    await tester.pumpWidget(Testable(
      (_) => SaveNamePage(
        title: Text("Title"),
        onSave: (_) => true,
      ),
      navigatorObserver: observer,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Name");
    await tapAndSettle(tester, find.text("SAVE"));
    expect(popped, isTrue);
  });

  testWidgets("Non-null onSave does not pop page if returns false",
      (tester) async {
    var observer = MockNavigatorObserver();
    var popped = false;
    when(observer.didPop(any, any)).thenAnswer((_) => popped = true);

    await tester.pumpWidget(Testable(
      (_) => SaveNamePage(
        title: Text("Title"),
        onSave: (_) => false,
      ),
      navigatorObserver: observer,
    ));

    await enterTextAndSettle(tester, find.byType(TextField), "Name");
    await tapAndSettle(tester, find.text("SAVE"));
    expect(popped, isFalse);
  });

  testWidgets("Invalid input disables save button",
      (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => SaveNamePage(
          title: Text("Title"),
          validator: NameValidator(
            nameExists: (_) => true,
            nameExistsMessage: (_) => "Name exists",
          ),
        ),
      ),
    );

    await enterTextAndSettle(tester, find.byType(TextField), "Name");
    expect(findFirstWithText<ActionButton>(tester, "SAVE").onPressed, isNull);
  });
}
