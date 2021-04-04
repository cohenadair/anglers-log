import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/fishing_spot_list_page.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.fishingSpotManager
            .listSortedByName(filter: anyNamed("filter")))
        .thenReturn([
      FishingSpot()
        ..id = randomId()
        ..name = "Test Fishing Spot"
        ..lat = 1.234567
        ..lng = 7.654321,
      FishingSpot()
        ..id = randomId()
        ..lat = 1.234568
        ..lng = 7.654322,
    ]);
  });

  group("Picker", () {
    testWidgets("Single title", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotListPage(
          pickerSettings: ManageableListPagePickerSettings.single(
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
          pickerSettings: ManageableListPagePickerSettings(
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
          pickerSettings: ManageableListPagePickerSettings(
            onPicked: (_, __) => true,
          ),
        ),
        appManager: appManager,
      ));
      expect(find.byType(PaddedCheckbox), findsNWidgets(3));
    });
  });

  group("Normal list", () {
    testWidgets("Title", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotListPage(),
        appManager: appManager,
      ));
      expect(find.text("Fishing Spots (2)"), findsOneWidget);
    });

    testWidgets("Does not have checkboxes", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotListPage(),
        appManager: appManager,
      ));
      expect(find.byType(PaddedCheckbox), findsNothing);
    });

    testWidgets("Spot with no name shows coordinates as title", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotListPage(),
        appManager: appManager,
      ));
      expect(find.widgetWithText(PrimaryLabel, "Lat: 1.234568, Lng: 7.654322"),
          findsOneWidget);
    });

    testWidgets("Spot with name shows coordinates as subtitle", (tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotListPage(),
        appManager: appManager,
      ));
      expect(find.widgetWithText(SubtitleLabel, "Lat: 1.234567, Lng: 7.654321"),
          findsOneWidget);
    });
  });
}
