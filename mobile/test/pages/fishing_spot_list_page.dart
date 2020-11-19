import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/fishing_spot_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/checkbox_input.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockFishingSpotManager: true,
    );

    when(appManager.mockFishingSpotManager
            .listSortedByName(filter: anyNamed("filter")))
        .thenReturn([
      FishingSpot()
        ..id = randomId()
        ..name = "Test Fishing Spot"
        ..lat = 1.234567
        ..lng = 7.654321,
    ]);
  });

  group("Picker", () {
    testWidgets("Single title", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotListPage.picker(
          onPicked: (_, __) => true,
        ),
        appManager: appManager,
      ));
      expect(find.text("Select Fishing Spot"), findsOneWidget);
    });

    testWidgets("Multi title", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotListPage.picker(
          onPicked: (_, __) => true,
          multiPicker: true,
        ),
        appManager: appManager,
      ));
      expect(find.text("Select Fishing Spots"), findsOneWidget);
    });

    testWidgets("Has checkboxes", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotListPage.picker(
          onPicked: (_, __) => true,
          multiPicker: true,
        ),
        appManager: appManager,
      ));
      expect(find.byType(PaddedCheckbox), findsOneWidget);
    });
  });

  group("Normal list", () {
    testWidgets("Title", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotListPage(),
        appManager: appManager,
      ));
      expect(find.text("Fishing Spots (1)"), findsOneWidget);
    });

    testWidgets("Does not have checkboxes", (WidgetTester tester) async {
      await tester.pumpWidget(Testable(
        (_) => FishingSpotListPage(),
        appManager: appManager,
      ));
      expect(find.byType(PaddedCheckbox), findsNothing);
    });
  });
}
