import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/save_name_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/empty_list_placeholder.dart';
import 'package:mobile/widgets/search_bar.dart';
import 'package:mobile/widgets/text_input.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';
import 'package:quiver/strings.dart' as quiver;

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;

  // Use real ManageableListItem instance when listeners are required.
  SpeciesManager speciesManager;

  List<String> items;

  setUp(() {
    items = <String>[
      "Smallmouth Bass",
      "Largemouth Bass",
      "Striped Bass",
      "White Bass",
    ];

    // Use a real use of ManageableListPage for this test because an
    // EntityManagerListener is needed.
    appManager = MockAppManager(
      mockAuthManager: true,
      mockCatchManager: true,
      mockLocalDatabaseManager: true,
      mockSubscriptionManager: true,
    );

    when(appManager.mockAuthManager.stream).thenAnswer((_) => MockStream());

    when(appManager.mockCatchManager.list()).thenReturn([]);
    when(appManager.mockCatchManager
            .existsWith(speciesId: anyNamed("speciesId")))
        .thenReturn(false);

    when(appManager.mockLocalDatabaseManager
            .insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.mockLocalDatabaseManager.deleteEntity(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);

    speciesManager = SpeciesManager(appManager);
    when(appManager.speciesManager).thenReturn(speciesManager);
  });

  List<String> loadItems(searchQuery) {
    var species = List.of(items);
    species.retainWhere((item) {
      if (quiver.isEmpty(searchQuery)) {
        return true;
      }
      return item.contains(searchQuery);
    });
    return species;
  }

  Widget deleteWidget(BuildContext context, String item) =>
      Text("Delete item?");
  deleteItem(BuildContext context, String item) => items.remove(item);

  var defaultItemManager = ManageableListPageItemManager<String>(
    loadItems: loadItems,
    deleteWidget: deleteWidget,
    deleteItem: deleteItem,
  );

  ManageableListPageItemModel defaultItemBuilder(
          BuildContext context, String item) =>
      ManageableListPageItemModel(
        child: Text(item),
      );

  Finder findCheckbox(WidgetTester tester, String item) {
    return find.descendant(
      of: find.widgetWithText(ManageableListItem, item),
      matching: find.byType(PaddedCheckbox),
    );
  }

  Finder findCheckIcon(WidgetTester tester, String item) {
    return find.descendant(
      of: find.widgetWithText(ManageableListItem, item),
      matching: find.byIcon(Icons.check),
    );
  }

  void verifyCheckbox(WidgetTester tester, String item, {bool checked}) {
    expect(
      (tester.firstWidget(findCheckbox(tester, item)) as PaddedCheckbox)
          .checked,
      checked,
    );
  }

  group("Picker", () {
    testWidgets("Multi-picker initial values", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: defaultItemManager,
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>(
              initialValues: {"Smallmouth Bass", "Largemouth Bass"},
              isMulti: true,
              onPicked: (context, items) => false,
            ),
          ),
        ),
      );

      verifyCheckbox(tester, "Smallmouth Bass", checked: true);
      verifyCheckbox(tester, "Largemouth Bass", checked: true);
      verifyCheckbox(tester, "Striped Bass", checked: false);
      verifyCheckbox(tester, "White Bass", checked: false);
    });

    testWidgets("Multi-picker all initial values", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: defaultItemManager,
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>(
              onPicked: (context, items) => false,
              initialValues: {
                "Smallmouth Bass",
                "Largemouth Bass",
                "Striped Bass",
                "White Bass",
              },
            ),
          ),
        ),
      );

      verifyCheckbox(tester, "All", checked: true);
      verifyCheckbox(tester, "Smallmouth Bass", checked: true);
      verifyCheckbox(tester, "Largemouth Bass", checked: true);
      verifyCheckbox(tester, "Striped Bass", checked: true);
      verifyCheckbox(tester, "White Bass", checked: true);
    });

    testWidgets("Single-picker initial value", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: defaultItemManager,
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>(
              initialValues: {"Smallmouth Bass"},
              isMulti: false,
              onPicked: (context, items) => false,
            ),
          ),
        ),
      );

      expect(find.byType(PaddedCheckbox), findsNothing);
      expect(findCheckIcon(tester, "Smallmouth Bass"), findsOneWidget);
    });

    testWidgets("Single-picker initial value none", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: defaultItemManager,
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>.single(
              onPicked: (context, items) => false,
            ),
          ),
        ),
      );

      expect(find.byType(PaddedCheckbox), findsNothing);
      expect(findCheckIcon(tester, "None"), findsOneWidget);
    });

    testWidgets("Multi-picker callback invoked on close page", (tester) async {
      Set<String> items;
      await tester.pumpWidget(
        Testable(
          (context) => Scaffold(
            body: Button(
              text: "Test",
              onPressed: () => push(
                context,
                ManageableListPage<String>(
                  itemManager: defaultItemManager,
                  itemBuilder: defaultItemBuilder,
                  pickerSettings: ManageableListPagePickerSettings<String>(
                    isMulti: true,
                    onPicked: (context, pickedItems) {
                      items = pickedItems;
                      return false;
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tapAndSettle(tester, find.byType(Button));
      await tapAndSettle(tester, findCheckbox(tester, "Smallmouth Bass"));
      await tapAndSettle(tester, findCheckbox(tester, "White Bass"));
      await tapAndSettle(tester, find.byType(BackButton));

      expect(items, isNotNull);
      expect(items.length, 2);
    });

    testWidgets("Single-picker callback not invoked on close page",
        (tester) async {
      var invoked = false;
      await tester.pumpWidget(
        Testable(
          (context) => Scaffold(
            body: Button(
              text: "Test",
              onPressed: () => push(
                context,
                ManageableListPage<String>(
                  itemManager: defaultItemManager,
                  itemBuilder: defaultItemBuilder,
                  pickerSettings: ManageableListPagePickerSettings<String>(
                    isMulti: false,
                    onPicked: (context, pickedItems) {
                      invoked = true;
                      return false;
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tapAndSettle(tester, find.byType(Button));
      await tapAndSettle(tester, find.byType(BackButton));
      expect(invoked, isFalse);
    });

    testWidgets("Single-picker changing editing state", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: ManageableListPageItemManager<String>(
              loadItems: loadItems,
              deleteWidget: deleteWidget,
              deleteItem: deleteItem,
              addPageBuilder: () => Empty(),
              editPageBuilder: (_) => Empty(),
            ),
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>(
              isMulti: false,
              onPicked: (context, items) => false,
            ),
          ),
        ),
      );

      // Normal, not editing state.
      expect(find.widgetWithText(ActionButton, "EDIT"), findsOneWidget);
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
        (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: ManageableListPageItemManager<String>(
              loadItems: loadItems,
              deleteWidget: deleteWidget,
              deleteItem: deleteItem,
              addPageBuilder: () => Empty(),
            ),
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>(
              isMulti: false,
              onPicked: (context, items) => false,
            ),
          ),
        ),
      );

      expect(find.widgetWithText(ActionButton, "EDIT"), findsNothing);
      expect(find.widgetWithText(ActionButton, "DONE"), findsNothing);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets("Single-picker no add button when not addable", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: ManageableListPageItemManager<String>(
              loadItems: loadItems,
              deleteWidget: deleteWidget,
              deleteItem: deleteItem,
              editPageBuilder: (_) => Empty(),
            ),
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>(
              isMulti: false,
              onPicked: (context, items) => false,
            ),
          ),
        ),
      );

      expect(find.widgetWithText(ActionButton, "EDIT"), findsOneWidget);
      expect(find.widgetWithText(ActionButton, "DONE"), findsNothing);
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets("Single-picker add button tapped", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: ManageableListPageItemManager<String>(
              loadItems: loadItems,
              deleteWidget: deleteWidget,
              deleteItem: deleteItem,
              addPageBuilder: () => SaveNamePage(title: Text("New Name")),
              editPageBuilder: (_) => Empty(),
            ),
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>(
              isMulti: false,
              onPicked: (context, items) => false,
            ),
          ),
        ),
      );

      await tapAndSettle(tester, find.byIcon(Icons.add));

      expect(find.byType(SaveNamePage), findsOneWidget);
    });

    testWidgets("Multi-picker shows checkboxes", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: defaultItemManager,
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>(
              isMulti: true,
              isRequired: true,
              onPicked: (context, items) => false,
            ),
          ),
        ),
      );

      expect(find.byType(PaddedCheckbox), findsNWidgets(4));
    });

    testWidgets("Single-picker doesn't show right chevron", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: ManageableListPageItemManager<String>(
              loadItems: loadItems,
              deleteWidget: deleteWidget,
              deleteItem: deleteItem,
              detailPageBuilder: (_) => Empty(),
            ),
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>(
              isMulti: false,
              onPicked: (context, items) => false,
            ),
          ),
        ),
      );

      // Pickers don't allow to view details of a row.
      expect(find.byType(RightChevronIcon), findsNothing);
    });

    testWidgets("No details page doesn't show right chevron", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: defaultItemManager,
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>(
              isMulti: false,
              onPicked: (context, items) => false,
            ),
          ),
        ),
      );

      // Pickers don't allow to view details of a row.
      expect(find.byType(RightChevronIcon), findsNothing);
    });

    testWidgets("Multi-picker tap row is a no-op", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: defaultItemManager,
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>(
              isMulti: true,
              onPicked: (context, items) => false,
            ),
          ),
        ),
      );

      await tapAndSettle(tester, find.text("Smallmouth Bass"));
      verifyCheckbox(tester, "Smallmouth Bass", checked: false);
    });

    testWidgets("Single-picker tap row invokes callback", (tester) async {
      var invoked = false;
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: defaultItemManager,
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>(
              isMulti: false,
              onPicked: (context, items) {
                invoked = true;
                return false;
              },
            ),
          ),
        ),
      );

      await tapAndSettle(tester, find.text("Smallmouth Bass"));
      expect(invoked, isTrue);
    });

    testWidgets("Not required multi-picker shows clear option", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: defaultItemManager,
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>(
              onPicked: (context, items) => false,
            ),
          ),
        ),
      );
      expect(find.text("All"), findsOneWidget);
      expect(find.byType(MinDivider), findsOneWidget);
    });

    testWidgets("Required multi-picker does not show clear option",
        (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: defaultItemManager,
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>(
              onPicked: (context, items) => false,
              isRequired: true,
            ),
          ),
        ),
      );
      expect(find.text("All"), findsNothing);
      expect(find.byType(MinDivider), findsNothing);
    });

    testWidgets("Multi-picker (de)selecting all toggles all checkboxes",
        (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: defaultItemManager,
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>(
              onPicked: (context, items) => false,
            ),
          ),
        ),
      );

      await tapAndSettle(tester, findCheckbox(tester, "All"));

      verifyCheckbox(tester, "All", checked: true);
      verifyCheckbox(tester, "Smallmouth Bass", checked: true);
      verifyCheckbox(tester, "Largemouth Bass", checked: true);
      verifyCheckbox(tester, "Striped Bass", checked: true);
      verifyCheckbox(tester, "White Bass", checked: true);

      await tapAndSettle(tester, findCheckbox(tester, "All"));

      verifyCheckbox(tester, "All", checked: false);
      verifyCheckbox(tester, "Smallmouth Bass", checked: false);
      verifyCheckbox(tester, "Largemouth Bass", checked: false);
      verifyCheckbox(tester, "Striped Bass", checked: false);
      verifyCheckbox(tester, "White Bass", checked: false);
    });

    testWidgets("Not-required single-picker shows clear option",
        (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: defaultItemManager,
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>.single(
              onPicked: (context, items) => false,
            ),
          ),
        ),
      );
      expect(find.text("None"), findsOneWidget);
      expect(find.byType(MinDivider), findsOneWidget);
    });

    testWidgets("Required single-picker hides clear option", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: defaultItemManager,
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>.single(
              onPicked: (context, items) => false,
              isRequired: true,
            ),
          ),
        ),
      );
      expect(find.text("None"), findsNothing);
      expect(find.byType(MinDivider), findsNothing);
    });

    testWidgets("Empty list shows nothing", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: ManageableListPageItemManager<String>(
              loadItems: (_) => [],
              deleteItem: (_, __) {},
              deleteWidget: (_, __) => Empty(),
            ),
            itemBuilder: (_, __) => null,
            pickerSettings: ManageableListPagePickerSettings<String>(
              onPicked: (context, items) => false,
            ),
          ),
        ),
      );
      expect(find.text("All"), findsNothing);
      expect(find.byType(MinDivider), findsNothing);
    });

    testWidgets("Multi-picker custom containsAll always false", (tester) async {
      await tester.pumpWidget(
        Testable(
          (_) => ManageableListPage<String>(
            itemManager: defaultItemManager,
            itemBuilder: defaultItemBuilder,
            pickerSettings: ManageableListPagePickerSettings<String>(
              onPicked: (context, items) => false,
              containsAll: (_) => false,
            ),
          ),
        ),
      );

      await tapAndSettle(tester, findCheckbox(tester, "All"));

      verifyCheckbox(tester, "All", checked: false);
      verifyCheckbox(tester, "Smallmouth Bass", checked: true);
      verifyCheckbox(tester, "Largemouth Bass", checked: true);
      verifyCheckbox(tester, "Striped Bass", checked: true);
      verifyCheckbox(tester, "White Bass", checked: true);
    });

    testWidgets("Editing item persists picked selection", (tester) async {
      // Add initial species.
      var species = Species()
        ..id = randomId()
        ..name = "Bass";
      speciesManager.addOrUpdate(species);

      await tester.pumpWidget(
        Testable(
          (_) => SpeciesListPage(
            pickerSettings: ManageableListPagePickerSettings<Species>.single(
              initialValue: species,
            ),
          ),
          appManager: appManager,
        ),
      );

      // Verify initial selection.
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Update species.
      await tapAndSettle(tester, find.text("EDIT"));
      await tapAndSettle(tester, find.text("EDIT"));
      await enterTextAndSettle(tester, find.byType(TextField), "Bass 2");
      await tapAndSettle(tester, find.text("SAVE"));
      await tapAndSettle(tester, find.text("DONE"));

      expect(find.text("Bass 2"), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  testWidgets("No search bar", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ManageableListPage<String>(
          itemManager: defaultItemManager,
          itemBuilder: defaultItemBuilder,
        ),
      ),
    );

    expect(find.byType(SearchBar), findsNothing);
  });

  testWidgets("Searching filters list", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ManageableListPage<String>(
          itemManager: defaultItemManager,
          itemBuilder: defaultItemBuilder,
          searchDelegate: ManageableListPageSearchDelegate(
            hint: "Search",
          ),
        ),
      ),
    );

    expect(find.text("Search"), findsOneWidget);

    await tester.enterText(find.byType(CupertinoTextField), "mouth");
    // Wait for SearchTimer.
    await tester.pumpAndSettle(Duration(milliseconds: 750));

    expect(find.text("Smallmouth Bass"), findsOneWidget);
    expect(find.text("Largemouth Bass"), findsOneWidget);
    expect(find.text("Striped Bass"), findsNothing);
    expect(find.text("White Bass"), findsNothing);
  });

  testWidgets("No results search", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ManageableListPage<String>(
          itemManager: defaultItemManager,
          itemBuilder: defaultItemBuilder,
          searchDelegate: ManageableListPageSearchDelegate(
            hint: "Search",
          ),
        ),
      ),
    );

    expect(find.text("Search"), findsOneWidget);

    await tester.enterText(find.byType(CupertinoTextField), "Pike");
    // Wait for SearchTimer.
    await tester.pumpAndSettle(Duration(milliseconds: 750));

    expect(find.byType(EmptyListPlaceholder), findsOneWidget);
    expect(find.text("Smallmouth Bass"), findsNothing);
    expect(find.text("Largemouth Bass"), findsNothing);
    expect(find.text("Striped Bass"), findsNothing);
    expect(find.text("White Bass"), findsNothing);
  });

  testWidgets("Changes to listener updates state", (tester) async {
    when(appManager.mockLocalDatabaseManager
            .insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    var speciesManager = SpeciesManager(appManager);

    await tester.pumpWidget(
      Testable(
        (_) => ManageableListPage<Species>(
          itemManager: ManageableListPageItemManager<Species>(
            loadItems: (species) => speciesManager.list(),
            deleteWidget: (_, __) => Text("Delete"),
            deleteItem: (_, __) {},
            listenerManagers: [speciesManager],
          ),
          itemBuilder: (_, species) => ManageableListPageItemModel(
            child: Text(species.name),
          ),
        ),
      ),
    );

    expect(find.byType(ManageableListItem), findsNothing);

    // Add a species and check that the widget has updated.
    await speciesManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Bass");

    await tester.pumpAndSettle();
    expect(find.text("Bass"), findsOneWidget);
  });

  testWidgets("Title widget", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ManageableListPage<String>(
          itemManager: defaultItemManager,
          itemBuilder: defaultItemBuilder,
          titleBuilder: (_) => Text("A Title"),
        ),
      ),
    );

    expect(find.text("A Title"), findsOneWidget);
  });

  testWidgets("Non-editable, non-selectable list item", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ManageableListPage<String>(
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
        ),
      ),
    );

    expect(find.byType(RightChevronIcon), findsNWidgets(items.length - 1));
  });

  testWidgets("Tapping disabled row is a no-op", (tester) async {
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
      (tester) async {
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

  testWidgets("Tapping delete button invokes callback", (tester) async {
    String deletedItem;
    await tester.pumpWidget(
      Testable(
        (_) => ManageableListPage<String>(
          itemManager: ManageableListPageItemManager<String>(
            loadItems: loadItems,
            deleteWidget: deleteWidget,
            deleteItem: (_, item) => deletedItem = item,
            editPageBuilder: (_) => Empty(),
          ),
          itemBuilder: defaultItemBuilder,
        ),
      ),
    );

    await tapAndSettle(tester, find.text("EDIT"));
    await tapAndSettle(
        tester,
        find.descendant(
          of: find.widgetWithText(ManageableListItem, "Smallmouth Bass"),
          matching: find.byIcon(Icons.delete),
        ));
    await tapAndSettle(tester, find.text("DELETE"));

    expect(deletedItem, isNotNull);
    expect(deletedItem, "Smallmouth Bass");
  });

  testWidgets("Custom delete button action", (tester) async {
    String deletedItem;
    await tester.pumpWidget(
      Testable(
        (_) => ManageableListPage<String>(
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
        ),
      ),
    );

    await tapAndSettle(tester, find.text("EDIT"));
    await tapAndSettle(
      tester,
      find.descendant(
        of: find.widgetWithText(ManageableListItem, "Smallmouth Bass"),
        matching: find.byIcon(Icons.delete),
      ),
    );

    expect(deletedItem, isNotNull);
    expect(deletedItem, "Smallmouth Bass");
  });

  testWidgets("When editing, tapping row shows edit page", (tester) async {
    var invoked = false;
    await tester.pumpWidget(
      Testable(
        (_) => ManageableListPage<String>(
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
        ),
      ),
    );

    await tapAndSettle(tester, find.text("EDIT"));
    await tapAndSettle(tester, find.text("Smallmouth Bass"));

    expect(invoked, true);
  });

  testWidgets("When not editing, tapping row shows detail page",
      (tester) async {
    var invoked = false;
    await tester.pumpWidget(
      Testable(
        (_) => ManageableListPage<String>(
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
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Smallmouth Bass"));

    expect(invoked, true);
  });

  testWidgets("If details page is not null, right chevrons are shown",
      (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ManageableListPage<String>(
          itemManager: ManageableListPageItemManager<String>(
            loadItems: loadItems,
            deleteWidget: deleteWidget,
            deleteItem: deleteItem,
            detailPageBuilder: (_) => Empty(),
          ),
          itemBuilder: defaultItemBuilder,
        ),
      ),
    );

    expect(find.byType(RightChevronIcon), findsNWidgets(items.length));
  });

  testWidgets("End ending if all items are deleted", (tester) async {
    // Add initial species.
    speciesManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Bass");

    await tester.pumpWidget(
      Testable(
        (_) => SpeciesListPage(),
        appManager: appManager,
      ),
    );

    // Start editing and delete item.
    await tapAndSettle(tester, find.text("EDIT"));
    await tapAndSettle(tester, find.byIcon(Icons.delete));
    await tapAndSettle(tester, find.text("DELETE"));
    expect(find.text("Bass"), findsNothing);
    expect(find.text("DONE"), findsNothing);
    expect(find.text("EDIT"), findsNothing);

    // Add item back.
    await tapAndSettle(
      tester,
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.add),
      ),
    );
    await enterTextAndSettle(tester, find.byType(TextInput), "Bass");
    await tapAndSettle(tester, find.text("SAVE"));

    // Verify we're not longer editing.
    expect(find.text("Bass"), findsOneWidget);
    expect(find.widgetWithText(ListItem, "EDIT"), findsNothing);
  });

  testWidgets(
      // ignore: lines_longer_than_80_chars
      "Empty list placeholder shown when emptyItemsSettings != null and searchDelegate == null",
      (tester) async {
    items = [];
    await tester.pumpWidget(
      Testable(
        (_) => ManageableListPage<String>(
          itemManager: ManageableListPageItemManager<String>(
            loadItems: loadItems,
            deleteWidget: deleteWidget,
            deleteItem: deleteItem,
            detailPageBuilder: (_) => Empty(),
            emptyItemsSettings: ManageableListPageEmptyListSettings(
              title: "Test",
              description: "Description",
              icon: Icons.update,
            ),
          ),
          itemBuilder: defaultItemBuilder,
          searchDelegate: null,
        ),
      ),
    );

    expect(find.text("Test"), findsOneWidget);
    expect(find.text("Description"), findsOneWidget);
    expect(find.byIcon(Icons.update), findsOneWidget);
  });

  testWidgets(
      "Empty list placeholder shown when no search text and list is empty",
      (tester) async {
    items = [];
    await tester.pumpWidget(
      Testable(
        (_) => ManageableListPage<String>(
          itemManager: ManageableListPageItemManager<String>(
            loadItems: loadItems,
            deleteWidget: deleteWidget,
            deleteItem: deleteItem,
            detailPageBuilder: (_) => Empty(),
            emptyItemsSettings: ManageableListPageEmptyListSettings(
              title: "Test",
              description: "Description",
              icon: Icons.update,
            ),
          ),
          itemBuilder: defaultItemBuilder,
          searchDelegate: ManageableListPageSearchDelegate(
            hint: "Test hint",
          ),
        ),
      ),
    );

    expect(find.text("Test"), findsOneWidget);
    expect(find.text("Description"), findsOneWidget);
    expect(find.byIcon(Icons.update), findsOneWidget);
  });

  testWidgets("No search results watermark shown", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ManageableListPage<String>(
          itemManager: ManageableListPageItemManager<String>(
            loadItems: loadItems,
            deleteWidget: deleteWidget,
            deleteItem: deleteItem,
            detailPageBuilder: (_) => Empty(),
            emptyItemsSettings: ManageableListPageEmptyListSettings(
              title: "Test",
              description: "Description",
              icon: Icons.update,
            ),
          ),
          itemBuilder: defaultItemBuilder,
          searchDelegate: ManageableListPageSearchDelegate(
            hint: "Test hint",
          ),
        ),
      ),
    );

    await enterTextAndSettle(tester, find.byType(CupertinoTextField), "Test");
    await tester.pumpAndSettle(Duration(milliseconds: 500));
    expect(find.byIcon(Icons.search_off), findsOneWidget);
  });

  testWidgets("Edit button hidden for empty list", (tester) async {
    items = [];
    await tester.pumpWidget(
      Testable(
        (_) => ManageableListPage<String>(
          itemManager: ManageableListPageItemManager<String>(
            loadItems: loadItems,
            deleteWidget: deleteWidget,
            deleteItem: deleteItem,
            detailPageBuilder: (_) => Empty(),
            editPageBuilder: (_) => Empty(),
          ),
          itemBuilder: defaultItemBuilder,
        ),
      ),
    );
    expect(find.text("EDIT"), findsNothing);
  });

  testWidgets(
      "Managing items in the list correctly updates animated list model",
      (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => SpeciesListPage(),
        appManager: appManager,
      ),
    );

    expect(find.byType(EmptyListPlaceholder), findsOneWidget);

    // Add an item to the list.
    await tapAndSettle(tester, find.widgetWithIcon(IconButton, Icons.add));
    await enterTextAndSettle(tester, find.byType(TextInput), "Rainbow Trout");
    await tapAndSettle(tester, find.text("SAVE"), 250);

    // Verify item is added.
    expect(find.byType(EmptyListPlaceholder), findsNothing);
    expect(find.text("Rainbow Trout"), findsOneWidget);

    // Remove the only item in the list.
    await tapAndSettle(tester, find.text("EDIT"));
    await tapAndSettle(tester, find.byIcon(Icons.delete));
    await tapAndSettle(tester, find.text("DELETE"));

    // Verify item is removed.
    expect(find.byType(EmptyListPlaceholder), findsOneWidget);
    expect(find.text("Rainbow Trout"), findsNothing);

    // Add a couple items.
    await speciesManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Rainbow Trout");
    await speciesManager.addOrUpdate(Species()
      ..id = randomId()
      ..name = "Largemouth Bass");
    await tester.pumpAndSettle();

    expect(find.text("Largemouth Bass"), findsOneWidget);
    expect(find.text("Rainbow Trout"), findsOneWidget);

    // Insert into the start of the list.
    await tapAndSettle(tester, find.widgetWithIcon(IconButton, Icons.add));
    await enterTextAndSettle(tester, find.byType(TextInput), "Bass");
    await tapAndSettle(tester, find.text("SAVE"), 250);

    expect(
      find.descendant(
        of: find.byType(ManageableListItem).first,
        matching: find.text("Bass"),
      ),
      findsOneWidget,
    );

    // Insert into the end of the list.
    await tapAndSettle(tester, find.widgetWithIcon(IconButton, Icons.add));
    await enterTextAndSettle(tester, find.byType(TextInput), "Silver Bass");
    await tapAndSettle(tester, find.text("SAVE"), 250);

    expect(
      find.descendant(
        of: find.byType(ManageableListItem).last,
        matching: find.text("Silver Bass"),
      ),
      findsOneWidget,
    );
  });

  testWidgets("On non-T item changed doesn't modify list", (tester) async {
    var loadCount = 0;

    // Build a ManageableListPage that listens to a non-T manager.
    await tester.pumpWidget(
      Testable(
        (_) => ManageableListPage<String>(
          itemManager: ManageableListPageItemManager<String>(
            listenerManagers: [
              speciesManager,
            ],
            loadItems: (query) {
              loadCount++;
              return loadItems(query);
            },
            deleteWidget: deleteWidget,
            deleteItem: deleteItem,
            detailPageBuilder: (_) => Empty(),
            editPageBuilder: (_) => Empty(),
          ),
          itemBuilder: defaultItemBuilder,
        ),
        appManager: appManager,
      ),
    );

    expect(loadCount, 1);
    expect(find.byType(ManageableListItem), findsNWidgets(4));
    loadCount = 0;

    var species = Species()
      ..id = randomId()
      ..name = "Test";

    // Trigger add.
    await speciesManager.addOrUpdate(species);
    expect(loadCount, 1);
    expect(find.byType(ManageableListItem), findsNWidgets(4));
    loadCount = 0;

    // Trigger delete.
    await speciesManager.delete(species.id);
    expect(loadCount, 0); // None for onDelete callback.
    expect(find.byType(ManageableListItem), findsNWidgets(4));
    loadCount = 0;

    // Trigger update.
    await speciesManager.addOrUpdate(species..name = "Test 2");
    expect(loadCount, 1);
    expect(find.byType(ManageableListItem), findsNWidgets(4));
  });
}
