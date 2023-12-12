import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/fishing_spot_list_page.dart';
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

  var fishingSpots = [
    FishingSpot()
      ..id = randomId()
      ..name = "Test Fishing Spot"
      ..lat = 1.234567
      ..lng = 7.654321,
    FishingSpot()
      ..id = randomId()
      ..lat = 1.234568
      ..lng = 7.654322,
  ];

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.bodyOfWaterManager
            .listSortedByDisplayName(any, filter: anyNamed("filter")))
        .thenReturn([]);

    when(appManager.fishingSpotManager.filteredList(any, any))
        .thenReturn(fishingSpots);
    when(appManager.fishingSpotManager.displayName(any, any))
        .thenAnswer((invocation) => invocation.positionalArguments[1].name);
  });

  testWidgets("Not picking has null picker settings", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const FishingSpotListPage(),
      appManager: appManager,
    ));

    var manageableListPage = findFirst<ManageableListPage>(tester);
    expect(manageableListPage.pickerSettings, isNull);
  });

  group("Picker", () {
    testWidgets("Single title", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotListPage(
          pickerSettings: FishingSpotListPagePickerSettings.single(
            onPicked: (_, __) => true,
          ),
        ),
        appManager: appManager,
      ));
      expect(find.text("Select Fishing Spot"), findsOneWidget);
    });

    testWidgets("Multi title", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotListPage(
          pickerSettings: FishingSpotListPagePickerSettings(
            onPicked: (_, __) => true,
          ),
        ),
        appManager: appManager,
      ));
      expect(find.text("Select Fishing Spots"), findsOneWidget);
    });

    testWidgets("Has checkboxes", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotListPage(
          pickerSettings: FishingSpotListPagePickerSettings(
            onPicked: (_, __) => true,
          ),
        ),
        appManager: appManager,
      ));
      expect(find.byType(PaddedCheckbox), findsNWidgets(3));
    });

    testWidgets("Picking all includes only FishingSpot objects",
        (tester) async {
      var pickedFishingSpots = <FishingSpot>{};

      await tester.pumpWidget(Testable(
        (context) {
          return Button(
            text: "Test",
            onPressed: () {
              push(context, FishingSpotListPage(
                pickerSettings: FishingSpotListPagePickerSettings(
                  onPicked: (_, pickedSpots) {
                    pickedFishingSpots = pickedSpots;
                    return true;
                  },
                ),
              ));
            },
          );
        },
        appManager: appManager,
      ));

      await tapAndSettle(tester, find.text("TEST"));
      await tapAndSettle(tester, findManageableListItemCheckbox(tester, "All"));
      await tapAndSettle(tester, find.byType(BackButton));

      expect(pickedFishingSpots.length, 2);
    });

    testWidgets("Single picker returns null when nothing picked",
        (tester) async {
      FishingSpot? picked;
      var invoked = false;
      await tester.pumpWidget(Testable(
        (_) => FishingSpotListPage(
          pickerSettings: FishingSpotListPagePickerSettings.single(
            onPicked: (_, spot) {
              picked = spot;
              invoked = true;
              return true;
            },
          ),
        ),
        appManager: appManager,
      ));

      await tapAndSettle(tester, find.text("None"));

      expect(invoked, isTrue);
      expect(picked, isNull);
    });

    testWidgets("Single picker returns single value", (tester) async {
      FishingSpot? picked;
      await tester.pumpWidget(Testable(
        (_) => FishingSpotListPage(
          pickerSettings: FishingSpotListPagePickerSettings.single(
            onPicked: (_, spot) {
              picked = spot;
              return true;
            },
          ),
        ),
        appManager: appManager,
      ));

      await tapAndSettle(tester, find.text("Test Fishing Spot"));
      expect(picked, isNotNull);
    });

    testWidgets("Single picker initial value selected", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotListPage(
          pickerSettings: FishingSpotListPagePickerSettings.single(
            onPicked: (_, __) => true,
            initialValue: fishingSpots[0],
          ),
        ),
        appManager: appManager,
      ));

      expect(
        siblingOfText(tester, ManageableListItem, "Test Fishing Spot",
            find.byIcon(Icons.check)),
        findsOneWidget,
      );
    });
  });

  group("Normal list", () {
    testWidgets("Title", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => const FishingSpotListPage(),
        appManager: appManager,
      ));
      expect(find.text("Fishing Spots (2)"), findsOneWidget);
    });

    testWidgets("Does not have checkboxes", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => const FishingSpotListPage(),
        appManager: appManager,
      ));
      expect(find.byType(PaddedCheckbox), findsNothing);
    });

    testWidgets("Spot with no name shows coordinates as title", (tester) async {
      var context = await pumpContext(
        tester,
        (_) => const FishingSpotListPage(),
        appManager: appManager,
      );
      expect(find.primaryText(context, text: "Lat: 1.234568, Lng: 7.654322"),
          findsOneWidget);
      expect(find.subtitleText(context), findsOneWidget);
    });

    testWidgets("Spot with name shows coordinates as subtitle", (tester) async {
      var context = await pumpContext(
        tester,
        (_) => const FishingSpotListPage(),
        appManager: appManager,
      );
      expect(
          find.primaryText(context, text: "Test Fishing Spot"), findsOneWidget);
      expect(find.subtitleText(context, text: "Lat: 1.234567, Lng: 7.654321"),
          findsOneWidget);
    });
  });
}
