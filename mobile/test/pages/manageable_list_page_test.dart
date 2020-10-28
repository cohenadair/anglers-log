import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/save_name_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/search_bar.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';
import 'package:quiver/strings.dart' as Q;

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  var items = [
    "Smallmouth Bass",
    "Largemouth Bass",
    "Striped Bass",
    "White Bass",
  ];

  List<String> Function(String) loadItems = (searchQuery) {
    List<String> species = List.of(items);
    species.retainWhere((item) {
      if (Q.isEmpty(searchQuery)) {
        return true;
      }
      return item.contains(searchQuery);
    });
    return species;
  };

  Widget Function(BuildContext, String) deleteWidget =
      (_, __) => Text("Delete item?");

  void Function(BuildContext, String) deleteItem =
      (_, item) => items.remove(item);

  var defaultItemManager = ManageableListPageItemManager<String>(
    loadItems: loadItems,
    deleteWidget: deleteWidget,
    deleteItem: deleteItem,
  );

  var defaultItemBuilder = (context, item) => ManageableListPageItemModel(
    child: Text(item),
  );

  void verifyCheckbox(WidgetTester tester, String item, bool checked) {
    expect((tester.firstWidget(find.descendant(
      of: find.widgetWithText(ManageableListItem, item),
      matching: find.byType(PaddedCheckbox),
    )) as PaddedCheckbox).checked, checked);
  }

  group("Picker", () {
    testWidgets("Multi-picker initial values", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: defaultItemManager,
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          initialValues: {"Smallmouth Bass", "Largemouth Bass"},
          multi: true,
          onPicked: (context, items) => false,
        ),
      )));

      verifyCheckbox(tester, "Smallmouth Bass", true);
      verifyCheckbox(tester, "Largemouth Bass", true);
      verifyCheckbox(tester, "Striped Bass", false);
      verifyCheckbox(tester, "White Bass", false);
    });

    testWidgets("Single-picker initial value", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: defaultItemManager,
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          initialValues: {"Smallmouth Bass"},
          multi: false,
          onPicked: (context, items) => false,
        ),
      )));

      expect(find.byType(PaddedCheckbox), findsNothing);
      expect(find.descendant(
        of: find.widgetWithText(ManageableListItem, "Smallmouth Bass"),
        matching: find.byIcon(Icons.check),
      ), findsOneWidget);
    });

    testWidgets("Multi-picker done button always shown", (WidgetTester tester)
        async
    {
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: defaultItemManager,
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          multi: true,
          onPicked: (context, items) => false,
        ),
      )));

      expect(find.widgetWithText(ActionButton, "DONE"), findsOneWidget);
    });

    testWidgets("Multi-picker no overflow menu", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: defaultItemManager,
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          multi: true,
          onPicked: (context, items) => false,
        ),
      )));

      expect(find.widgetWithText(ActionButton, "DONE"), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets("Multi-picker overflow menu editable and addable",
        (WidgetTester tester) async
    {
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: ManageableListPageItemManager<String>(
          loadItems: loadItems,
          deleteWidget: deleteWidget,
          deleteItem: deleteItem,
          addPageBuilder: () => Empty(),
          editPageBuilder: (_) => Empty(),
        ),
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          multi: true,
          onPicked: (context, items) => false,
        ),
      )));

      expect(find.widgetWithText(ActionButton, "DONE"), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      await tapAndSettle(tester, find.byIcon(Icons.more_vert));

      expect(findFirstWithText<PopupMenuItem>(tester, "Add").enabled, isTrue);
      expect(findFirstWithText<PopupMenuItem>(tester, "Edit").enabled, isTrue);
    });

    testWidgets("Multi-picker overflow menu not editable",
        (WidgetTester tester) async
    {
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: ManageableListPageItemManager<String>(
          loadItems: loadItems,
          deleteWidget: deleteWidget,
          deleteItem: deleteItem,
          addPageBuilder: () => Empty(),
        ),
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          multi: true,
          onPicked: (context, items) => false,
        ),
      )));

      expect(find.widgetWithText(ActionButton, "DONE"), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      await tapAndSettle(tester, find.byIcon(Icons.more_vert));

      expect(findFirstWithText<PopupMenuItem>(tester, "Add").enabled, isTrue);
      expect(find.widgetWithText(PopupMenuItem, "Edit"), findsNothing);
    });

    testWidgets("Multi-picker overflow menu not addable", (WidgetTester tester)
        async
    {
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: ManageableListPageItemManager<String>(
          loadItems: loadItems,
          deleteWidget: deleteWidget,
          deleteItem: deleteItem,
          editPageBuilder: (_) => Empty(),
        ),
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          multi: true,
          onPicked: (context, items) => false,
        ),
      )));

      expect(find.widgetWithText(ActionButton, "DONE"), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      await tapAndSettle(tester, find.byIcon(Icons.more_vert));

      expect(findFirstWithText<PopupMenuItem>(tester, "Edit").enabled, isTrue);
      expect(find.widgetWithText(PopupMenuItem, "Add"), findsNothing);
    });

    testWidgets("Multi-picker overflow edit disabled when editing",
        (WidgetTester tester) async
    {
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: ManageableListPageItemManager<String>(
          loadItems: loadItems,
          deleteWidget: deleteWidget,
          deleteItem: deleteItem,
          editPageBuilder: (_) => Empty(),
        ),
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          multi: true,
          onPicked: (context, items) => false,
        ),
      )));

      await tapAndSettle(tester, find.byIcon(Icons.more_vert));
      await tapAndSettle(tester, find.text("Edit"));
      await tapAndSettle(tester, find.byIcon(Icons.more_vert));

      expect(findFirstWithText<PopupMenuItem>(tester, "Edit").enabled, isFalse);
    });

    testWidgets("Multi-picker overflow menu add pressed", (WidgetTester tester)
        async
    {
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: ManageableListPageItemManager<String>(
          loadItems: loadItems,
          deleteWidget: deleteWidget,
          deleteItem: deleteItem,
          addPageBuilder: () => SaveNamePage(title: Text("New Name")),
          editPageBuilder: (_) => Empty(),
        ),
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          multi: true,
          onPicked: (context, items) => false,
        ),
      )));

      await tapAndSettle(tester, find.byIcon(Icons.more_vert));
      await tapAndSettle(tester, find.text("Add"));

      expect(find.byType(SaveNamePage), findsOneWidget);
    });

    testWidgets("Single-picker changing editing state", (WidgetTester tester)
        async
    {
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: ManageableListPageItemManager<String>(
          loadItems: loadItems,
          deleteWidget: deleteWidget,
          deleteItem: deleteItem,
          addPageBuilder: () => Empty(),
          editPageBuilder: (_) => Empty(),
        ),
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          multi: false,
          onPicked: (context, items) => false,
        ),
      )));

      // Normal, not editing state.
      expect(find.widgetWithText(ActionButton, "EDIT"), findsOneWidget);
      expect(find.widgetWithText(ActionButton, "DONE"), findsNothing);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Start editing.
      await tapAndSettle(tester, find.text("EDIT"));

      expect(find.widgetWithText(ActionButton, "EDIT"), findsNothing);
      expect(find.widgetWithText(ActionButton, "DONE"), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Stop editing.
      await tapAndSettle(tester, find.text("DONE"));

      expect(find.widgetWithText(ActionButton, "EDIT"), findsOneWidget);
      expect(find.widgetWithText(ActionButton, "DONE"), findsNothing);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets("Single-picker no edit button when not editable",
        (WidgetTester tester) async
    {
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: ManageableListPageItemManager<String>(
          loadItems: loadItems,
          deleteWidget: deleteWidget,
          deleteItem: deleteItem,
          addPageBuilder: () => Empty(),
        ),
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          multi: false,
          onPicked: (context, items) => false,
        ),
      )));

      expect(find.widgetWithText(ActionButton, "EDIT"), findsNothing);
      expect(find.widgetWithText(ActionButton, "DONE"), findsNothing);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets("Single-picker no add button when not addable",
        (WidgetTester tester) async
    {
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: ManageableListPageItemManager<String>(
          loadItems: loadItems,
          deleteWidget: deleteWidget,
          deleteItem: deleteItem,
          editPageBuilder: (_) => Empty(),
        ),
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          multi: false,
          onPicked: (context, items) => false,
        ),
      )));

      expect(find.widgetWithText(ActionButton, "EDIT"), findsOneWidget);
      expect(find.widgetWithText(ActionButton, "DONE"), findsNothing);
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets("Single-picker add button tapped", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: ManageableListPageItemManager<String>(
          loadItems: loadItems,
          deleteWidget: deleteWidget,
          deleteItem: deleteItem,
          addPageBuilder: () => SaveNamePage(title: Text("New Name")),
          editPageBuilder: (_) => Empty(),
        ),
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          multi: false,
          onPicked: (context, items) => false,
        ),
      )));

      await tapAndSettle(tester, find.byIcon(Icons.add));

      expect(find.byType(SaveNamePage), findsOneWidget);
    });

    testWidgets("Multi-picker shows checkboxes", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: defaultItemManager,
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          multi: true,
          onPicked: (context, items) => false,
        ),
      )));

      expect(find.byType(PaddedCheckbox), findsNWidgets(4));
    });

    testWidgets("Single-picker doesn't show right chevron",
        (WidgetTester tester) async
    {
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: ManageableListPageItemManager<String>(
          loadItems: loadItems,
          deleteWidget: deleteWidget,
          deleteItem: deleteItem,
          detailPageBuilder: (_) => Empty(),
        ),
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          multi: false,
          onPicked: (context, items) => false,
        ),
      )));

      // Pickers don't allow to view details of a row.
      expect(find.byType(RightChevronIcon), findsNothing);
    });

    testWidgets("No details page doesn't show right chevron",
        (WidgetTester tester) async
    {
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: defaultItemManager,
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          multi: false,
          onPicked: (context, items) => false,
        ),
      )));

      // Pickers don't allow to view details of a row.
      expect(find.byType(RightChevronIcon), findsNothing);
    });

    testWidgets("Multi-picker tap row is a no-op", (WidgetTester tester) async {
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: defaultItemManager,
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          multi: true,
          onPicked: (context, items) => false,
        ),
      )));

      await tapAndSettle(tester, find.text("Smallmouth Bass"));
      verifyCheckbox(tester, "Smallmouth Bass", false);
    });

    testWidgets("Single-picker tap row invokes callback", (WidgetTester tester)
        async
    {
      bool invoked = false;
      await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
        itemManager: defaultItemManager,
        itemBuilder: defaultItemBuilder,
        pickerSettings: ManageableListPagePickerSettings<String>(
          multi: false,
          onPicked: (context, items) {
            invoked = true;
            return false;
          },
        ),
      )));

      await tapAndSettle(tester, find.text("Smallmouth Bass"));
      expect(invoked, isTrue);
    });
  });

  testWidgets("No search bar", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
      itemManager: defaultItemManager,
      itemBuilder: defaultItemBuilder,
    )));

    expect(find.byType(SearchBar), findsNothing);
  });

  testWidgets("Searching filters list", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
      itemManager: defaultItemManager,
      itemBuilder: defaultItemBuilder,
      searchDelegate: ManageableListPageSearchDelegate(
        hint: "Search",
        noResultsMessage: "No results",
      ),
    )));

    expect(find.text("Search"), findsOneWidget);

    await tester.enterText(find.byType(CupertinoTextField), "mouth");
    // Wait for SearchTimer.
    await tester.pumpAndSettle(Duration(milliseconds: 750));

    expect(find.text("Smallmouth Bass"), findsOneWidget);
    expect(find.text("Largemouth Bass"), findsOneWidget);
    expect(find.text("Striped Bass"), findsNothing);
    expect(find.text("White Bass"), findsNothing);
  });

  testWidgets("No results search", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
      itemManager: defaultItemManager,
      itemBuilder: defaultItemBuilder,
      searchDelegate: ManageableListPageSearchDelegate(
        hint: "Search",
        noResultsMessage: "No results",
      ),
    )));

    expect(find.text("Search"), findsOneWidget);

    await tester.enterText(find.byType(CupertinoTextField), "Pike");
    // Wait for SearchTimer.
    await tester.pumpAndSettle(Duration(milliseconds: 750));

    expect(find.text("No results"), findsOneWidget);
    expect(find.text("Smallmouth Bass"), findsNothing);
    expect(find.text("Largemouth Bass"), findsNothing);
    expect(find.text("Striped Bass"), findsNothing);
    expect(find.text("White Bass"), findsNothing);
  });

  testWidgets("Changes to listener updates state", (WidgetTester tester) async {
    MockAppManager appManager = MockAppManager(
      mockDataManager: true,
    );
    when(appManager.mockDataManager.insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    var speciesManager = SpeciesManager(appManager);

    await tester.pumpWidget(Testable((_) => ManageableListPage<Species>(
      itemManager: ManageableListPageItemManager<Species>(
        loadItems: (species) => speciesManager.list(),
        deleteWidget: (_, __) => Text("Delete"),
        deleteItem: (_, __) {},
        listenerManagers: [speciesManager],
      ),
      itemBuilder: (_, species) => ManageableListPageItemModel(
        child: Text(species.name),
      ),
    )));

    expect(find.byType(ManageableListItem), findsNothing);

    // Add a species and check that the widget has updated.
    await speciesManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Bass");

    await tester.pumpAndSettle();
    expect(find.text("Bass"), findsOneWidget);
  });

  testWidgets("Title widget", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
      itemManager: defaultItemManager,
      itemBuilder: defaultItemBuilder,
      titleBuilder: (_) => Text("A Title"),
    )));

    expect(find.text("A Title"), findsOneWidget);
  });

  testWidgets("Non-editable, non-selectable list item", (WidgetTester tester)
      async
  {
    await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
      itemManager: ManageableListPageItemManager<String>(
        loadItems: loadItems,
        deleteWidget: deleteWidget,
        deleteItem: deleteItem,
        detailPageBuilder: (_) => Empty(),
      ),
      itemBuilder: (_, item) {
        if (item == "Smallmouth Bass") {
          return ManageableListPageItemModel(
            child: Text("Smallmouth Bass"),
            editable: false,
            selectable: false,
          );
        }

        return ManageableListPageItemModel(
          child: Text(item),
        );
      },
    )));

    expect(find.byType(RightChevronIcon), findsNWidgets(items.length - 1));
  });

  testWidgets("Tapping disabled row is a no-op", (WidgetTester tester) async {
    var navigatorObserver = MockNavigatorObserver();

    await tester.pumpWidget(Testable(
      (_) => ManageableListPage<String>(
        itemManager: ManageableListPageItemManager<String>(
          loadItems: loadItems,
          deleteWidget: deleteWidget,
          deleteItem: deleteItem,
          addPageBuilder: () => Empty(),
          editPageBuilder: (_) => Empty(),
          detailPageBuilder: (_) => Empty(),
        ),
        itemBuilder: (_, item) {
          if (item == "Smallmouth Bass") {
            return ManageableListPageItemModel(
              child: Text("Smallmouth Bass"),
              editable: false,
            );
          }

          return ManageableListPageItemModel(
            child: Text(item),
          );
        },
      ),
      navigatorObserver: navigatorObserver,
    ));
    // Verify initial navigator push when loading widget.
    verify(navigatorObserver.didPush(any, any)).called(1);

    await tapAndSettle(tester, find.text("EDIT"));
    await tapAndSettle(tester, find.text("Smallmouth Bass"));

    verifyNever(navigatorObserver.didPush(any, any));
  });

  testWidgets("Tapping enabled, no detail, and non-editable is a no-op",
      (WidgetTester tester) async
  {
    var navigatorObserver = MockNavigatorObserver();

    await tester.pumpWidget(Testable(
      (_) => ManageableListPage<String>(
        itemManager: ManageableListPageItemManager<String>(
          loadItems: loadItems,
          deleteWidget: deleteWidget,
          deleteItem: deleteItem,
          addPageBuilder: () => Empty(),
          editPageBuilder: (_) => Empty(),
        ),
        itemBuilder: (_, item) {
          if (item == "Smallmouth Bass") {
            return ManageableListPageItemModel(
              child: Text("Smallmouth Bass"),
              editable: false,
            );
          }

          return ManageableListPageItemModel(
            child: Text(item),
          );
        },
      ),
      navigatorObserver: navigatorObserver,
    ));
    // Verify initial navigator push when loading widget.
    verify(navigatorObserver.didPush(any, any)).called(1);

    await tapAndSettle(tester, find.text("Smallmouth Bass"));

    verifyNever(navigatorObserver.didPush(any, any));
  });

  testWidgets("Tapping delete button invokes callback", (WidgetTester tester)
      async
  {
    String deletedItem;
    await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
      itemManager: ManageableListPageItemManager<String>(
        loadItems: loadItems,
        deleteWidget: deleteWidget,
        deleteItem: (_, item) => deletedItem = item,
        editPageBuilder: (_) => Empty(),
      ),
      itemBuilder: defaultItemBuilder,
    )));

    await tapAndSettle(tester, find.text("EDIT"));
    await tapAndSettle(tester, find.descendant(
      of: find.widgetWithText(ManageableListItem, "Smallmouth Bass"),
      matching: find.byIcon(Icons.delete),
    ));
    await tapAndSettle(tester, find.text("DELETE"));

    expect(deletedItem, isNotNull);
    expect(deletedItem, "Smallmouth Bass");
  });

  testWidgets("Custom delete button action", (WidgetTester tester) async {
    String deletedItem;
    await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
      itemManager: ManageableListPageItemManager<String>(
        loadItems: loadItems,
        deleteWidget: deleteWidget,
        deleteItem: deleteItem,
        onTapDeleteButton: (item) {
          deletedItem = item;
          return true;
        },
        editPageBuilder: (_) => Empty(),
      ),
      itemBuilder: defaultItemBuilder,
    )));

    await tapAndSettle(tester, find.text("EDIT"));
    await tapAndSettle(tester, find.descendant(
      of: find.widgetWithText(ManageableListItem, "Smallmouth Bass"),
      matching: find.byIcon(Icons.delete),
    ));

    expect(deletedItem, isNotNull);
    expect(deletedItem, "Smallmouth Bass");
  });

  testWidgets("When editing, tapping row shows edit page",
      (WidgetTester tester) async
  {
    bool invoked = false;
    await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
      itemManager: ManageableListPageItemManager<String>(
        loadItems: loadItems,
        deleteWidget: deleteWidget,
        deleteItem: deleteItem,
        editPageBuilder: (_) {
          invoked = true;
          return Empty();
        },
      ),
      itemBuilder: defaultItemBuilder,
    )));

    await tapAndSettle(tester, find.text("EDIT"));
    await tapAndSettle(tester, find.text("Smallmouth Bass"));

    expect(invoked, true);
  });

  testWidgets("When not editing, tapping row shows detail page",
      (WidgetTester tester) async
  {
    bool invoked = false;
    await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
      itemManager: ManageableListPageItemManager<String>(
        loadItems: loadItems,
        deleteWidget: deleteWidget,
        deleteItem: deleteItem,
        detailPageBuilder: (_) {
          invoked = true;
          return Empty();
        },
      ),
      itemBuilder: defaultItemBuilder,
    )));

    await tapAndSettle(tester, find.text("Smallmouth Bass"));

    expect(invoked, true);
  });

  testWidgets("If details page is not null, right chevrons are shown",
      (WidgetTester tester) async
  {
    await tester.pumpWidget(Testable((_) => ManageableListPage<String>(
      itemManager: ManageableListPageItemManager<String>(
        loadItems: loadItems,
        deleteWidget: deleteWidget,
        deleteItem: deleteItem,
        detailPageBuilder: (_) => Empty(),
      ),
      itemBuilder: defaultItemBuilder,
    )));

    expect(find.byType(RightChevronIcon), findsNWidgets(items.length));
  });
}