import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

void main() {
  testWidgets("Initial values in multi-select are selected", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => PickerPage<String>(
          itemBuilder: () => [
            PickerPageItem(title: "Option A", value: "Option A"),
            PickerPageItem(title: "Option B", value: "Option B"),
            PickerPageItem(title: "Option C", value: "Option C"),
          ],
          onFinishedPicking: (_, __) => {},
          initialValues: const {"Option A", "Option C"},
        ),
      ),
    );

    expect(findCheckbox(tester, "Option A")!.checked, isTrue);
    expect(findCheckbox(tester, "Option B")!.checked, isFalse);
    expect(findCheckbox(tester, "Option C")!.checked, isTrue);
  });

  testWidgets("Initial value in single-select is selected", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => PickerPage<String>.single(
          itemBuilder: () => [
            PickerPageItem(title: "Option A", value: "Option A"),
            PickerPageItem(title: "Option B", value: "Option B"),
            PickerPageItem(title: "Option C", value: "Option C"),
          ],
          onFinishedPicking: (_, __) => {},
          initialValue: "Option B",
        ),
      ),
    );

    var optionA = find.descendant(
      of: find.widgetWithText(ListItem, "Option A"),
      matching: find.byType(AnimatedVisibility),
    );
    expect(
      (optionA.evaluate().first.widget as AnimatedVisibility).visible,
      isFalse,
    );

    var optionB = find.descendant(
      of: find.widgetWithText(ListItem, "Option B"),
      matching: find.byType(AnimatedVisibility),
    );
    expect(
      (optionB.evaluate().first.widget as AnimatedVisibility).visible,
      isTrue,
    );

    var optionC = find.descendant(
      of: find.widgetWithText(ListItem, "Option C"),
      matching: find.byType(AnimatedVisibility),
    );
    expect(
      (optionC.evaluate().first.widget as AnimatedVisibility).visible,
      isFalse,
    );
  });

  testWidgets("Multi-picker callback invoked when page is closed",
      (tester) async {
    var called = false;
    await tester.pumpWidget(
      Testable(
        (context) => Scaffold(
          body: Button(
            text: "Test",
            onPressed: () => push(
              context,
              PickerPage<String>(
                itemBuilder: () => [
                  PickerPageItem(title: "Option A", value: "Option A"),
                ],
                multiSelect: true,
                onFinishedPicking: (_, __) => called = true,
              ),
            ),
          ),
        ),
      ),
    );

    await tapAndSettle(tester, find.byType(Button));
    await tapAndSettle(tester, find.byType(BackButton));
    expect(called, isTrue);
  });

  testWidgets("Single-picker callback not invoked when page is closed",
      (tester) async {
    var called = false;
    await tester.pumpWidget(
      Testable(
        (context) => Scaffold(
          body: Button(
            text: "Test",
            onPressed: () => push(
              context,
              PickerPage<String>(
                itemBuilder: () => [
                  PickerPageItem(title: "Option A", value: "Option A"),
                ],
                multiSelect: false,
                onFinishedPicking: (_, __) => called = true,
              ),
            ),
          ),
        ),
      ),
    );

    await tapAndSettle(tester, find.byType(Button));
    await tapAndSettle(tester, find.byType(BackButton));
    expect(called, isFalse);
  });

  testWidgets("Action widget", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => PickerPage<String>(
          itemBuilder: () => [
            PickerPageItem(title: "Option A", value: "Option A"),
          ],
          onFinishedPicking: (_, __) => {},
          action: const Icon(Icons.search),
        ),
      ),
    );

    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets("List header", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => PickerPage<String>(
          itemBuilder: () => [
            PickerPageItem(title: "Option A", value: "Option A"),
          ],
          onFinishedPicking: (_, __) => {},
          listHeader: const Text("This is a list header."),
        ),
      ),
    );

    expect(find.text("This is a list header."), findsOneWidget);
  });

  testWidgets("All-item", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => PickerPage<String>(
          itemBuilder: () => [
            PickerPageItem(title: "Option A", value: "Option A"),
          ],
          onFinishedPicking: (_, __) => {},
          allItem: PickerPageItem(title: "All", value: "All"),
        ),
      ),
    );

    expect(find.text("All"), findsOneWidget);
  });

  testWidgets("Divider item", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => PickerPage<String>(
          itemBuilder: () => [
            PickerPageItem(title: "Option A", value: "Option A"),
            PickerPageItem.divider(),
            PickerPageItem(title: "Option B", value: "Option B"),
          ],
          onFinishedPicking: (_, __) => {},
        ),
      ),
    );

    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets("Heading item", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => PickerPage<String>(
        itemBuilder: () => [
          PickerPageItem(title: "Option A", value: "Option A"),
          PickerPageItem.heading("Heading"),
          PickerPageItem(title: "Option B", value: "Option B"),
        ],
        onFinishedPicking: (_, __) => {},
      ),
    );

    expect(find.listHeadingText(context, text: "Heading"), findsOneWidget);
  });

  testWidgets("Note item", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => PickerPage<String>(
        itemBuilder: () => [
          PickerPageItem(title: "Option A", value: "Option A"),
          PickerPageItem.note(title: "A note"),
          PickerPageItem(title: "Option B", value: "Option B"),
        ],
        onFinishedPicking: (_, __) => {},
      ),
    );

    expect(find.noteText(context, text: "A note"), findsOneWidget);
  });

  testWidgets("Note icon item", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => PickerPage<String>(
          itemBuilder: () => [
            PickerPageItem(title: "Option A", value: "Option A"),
            PickerPageItem.note(
              title: "A note with icon %s",
              noteIcon: Icons.note,
            ),
            PickerPageItem(title: "Option B", value: "Option B"),
          ],
          onFinishedPicking: (_, __) => {},
        ),
      ),
    );

    expect(find.byType(IconLabel), findsOneWidget);
  });

  testWidgets("Enabled single-select item pops page and invokes callback",
      (tester) async {
    String? pickedValue;
    await tester.pumpWidget(
      Testable(
        (_) => PickerPage<String>.single(
          itemBuilder: () => [
            PickerPageItem(title: "Option A", value: "Option A"),
          ],
          onFinishedPicking: (_, value) => pickedValue = value,
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Option A"));
    expect(pickedValue, "Option A");
  });

  testWidgets("Enabled single-select item custom callback", (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      Testable(
        (_) => PickerPage<String>.single(
          itemBuilder: () => [
            PickerPageItem(
              title: "Option A",
              value: "Option A",
              onTap: () => tapped = true,
            ),
          ],
          onFinishedPicking: (_, __) {},
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Option A"));
    expect(tapped, isTrue);
  });

  testWidgets("Enabled multi-select item does not pop page", (tester) async {
    var invoked = false;
    await tester.pumpWidget(
      Testable(
        (_) => PickerPage<String>(
          itemBuilder: () => [
            PickerPageItem(title: "Option A", value: "Option A"),
          ],
          onFinishedPicking: (_, __) => invoked = true,
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Option A"));
    expect(invoked, isFalse);
  });

  testWidgets("Item with subtitle", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => PickerPage<String>(
        itemBuilder: () => [
          PickerPageItem(
            title: "Option A",
            value: "Option A",
            subtitle: "Subtitle",
          ),
        ],
        onFinishedPicking: (_, __) => {},
      ),
    );

    expect(find.subtitleText(context, text: "Subtitle"), findsOneWidget);
  });

  testWidgets("Item without subtitle", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => PickerPage<String>(
        itemBuilder: () => [
          PickerPageItem(title: "Option A", value: "Option A"),
        ],
        onFinishedPicking: (_, __) => {},
      ),
    );

    expect(find.subtitleText(context), findsNothing);
  });

  testWidgets("All item selects/deselects other items", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => PickerPage<String>(
          itemBuilder: () => [
            PickerPageItem(title: "Option A", value: "Option A"),
            PickerPageItem(title: "Option B", value: "Option B"),
            PickerPageItem(title: "Option C", value: "Option C"),
          ],
          onFinishedPicking: (_, __) => {},
          allItem: PickerPageItem(title: "All", value: "All"),
          initialValues: const {"Option A", "Option B"},
        ),
      ),
    );

    await tapAndSettle(
      tester,
      find.descendant(
        of: find.widgetWithText(ListItem, "All"),
        matching: find.byType(PaddedCheckbox),
      ),
    );

    expect(findCheckbox(tester, "All")!.checked, isTrue);
    expect(findCheckbox(tester, "Option A")!.checked, isTrue);
    expect(findCheckbox(tester, "Option B")!.checked, isTrue);
    expect(findCheckbox(tester, "Option C")!.checked, isTrue);

    await tapAndSettle(
      tester,
      find.descendant(
        of: find.widgetWithText(ListItem, "All"),
        matching: find.byType(PaddedCheckbox),
      ),
    );
    expect(findCheckbox(tester, "All")!.checked, isFalse);
    expect(findCheckbox(tester, "Option A")!.checked, isFalse);
    expect(findCheckbox(tester, "Option B")!.checked, isFalse);
    expect(findCheckbox(tester, "Option C")!.checked, isFalse);
  });

  testWidgets("Selection deselects All item", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => PickerPage<String>(
          itemBuilder: () => [
            PickerPageItem(title: "Option A", value: "Option A"),
            PickerPageItem(title: "Option B", value: "Option B"),
            PickerPageItem(title: "Option C", value: "Option C"),
          ],
          onFinishedPicking: (_, __) => {},
          allItem: PickerPageItem(title: "All", value: "All"),
          initialValues: const {"All"},
        ),
      ),
    );

    await tapAndSettle(
      tester,
      find.descendant(
        of: find.widgetWithText(ListItem, "Option A"),
        matching: find.byType(PaddedCheckbox),
      ),
    );

    expect(findCheckbox(tester, "All")!.checked, isFalse);
    expect(findCheckbox(tester, "Option A")!.checked, isTrue);
    expect(findCheckbox(tester, "Option B")!.checked, isFalse);
    expect(findCheckbox(tester, "Option C")!.checked, isFalse);
  });

  testWidgets("Multi-none item pops navigator with empty selection",
      (tester) async {
    Set<String>? pickedItems;
    await tester.pumpWidget(
      Testable(
        (_) => PickerPage<String>(
          itemBuilder: () => [
            PickerPageItem(title: "Option A", value: "Option A"),
            PickerPageItem(title: "Option B", value: "Option B"),
            PickerPageItem(title: "Option C", value: "Option C"),
          ],
          onFinishedPicking: (_, items) => pickedItems = items,
          allItem: PickerPageItem(
            title: "None",
            value: "None",
            isMultiNone: true,
          ),
          initialValues: const {},
          multiSelect: true,
        ),
      ),
    );

    expect(find.text("None"), findsOneWidget);

    var check = tester.widget<AnimatedVisibility>(find.descendant(
      of: find.widgetWithText(PickerListItem, "None"),
      matching: find.byType(AnimatedVisibility),
    ));
    expect(check.visible, isTrue);

    await tapAndSettle(
      tester,
      find.descendant(
        of: find.widgetWithText(ListItem, "Option A"),
        matching: find.byType(PaddedCheckbox),
      ),
    );
    // Wait for check to disappear.
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    check = tester.widget<AnimatedVisibility>(find.descendant(
      of: find.widgetWithText(PickerListItem, "None"),
      matching: find.byType(AnimatedVisibility),
    ));
    expect(check.visible, isFalse);

    await tapAndSettle(tester, find.text("None"));
    expect(pickedItems, isNotNull);
    expect(pickedItems!, isEmpty);
  });
}
