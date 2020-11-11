import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/gen/google/protobuf/timestamp.pb.dart';
import 'package:mobile/pages/catch_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/static_fishing_spot.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockBaitManager: true,
      mockBaitCategoryManager: true,
      mockCatchManager: true,
      mockFishingSpotManager: true,
      mockSpeciesManager: true,
      mockTimeManager: true,
    );

    when(appManager.mockCatchManager.entity(any)).thenReturn(Catch()
      ..id = randomId()
      ..timestamp = Timestamp.fromDateTime(DateTime(2020, 1, 1, 15, 30))
      ..speciesId = randomId());
    when(appManager.mockSpeciesManager.entity(any)).thenReturn(Species()
      ..id = randomId()
      ..name = "Steelhead");
  });

  testWidgets("No bait renders empty", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchPage(randomId()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(Duration(milliseconds: 250));
    expect(find.byType(ListItem), findsNothing);
  });

  testWidgets("Bait without category doesn't show subtitle",
      (WidgetTester tester) async
  {
    when(appManager.mockBaitManager.entity(any)).thenReturn(Bait()
      ..id = randomId()
      ..name = "Worm");
    await tester.pumpWidget(Testable(
      (_) => CatchPage(randomId()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.text("Worm"), findsOneWidget);
    expect(find.byType(SubtitleLabel), findsOneWidget); // One for time label.
  });

  testWidgets("Bait with category shows subtitle", (WidgetTester tester) async {
    when(appManager.mockBaitManager.entity(any)).thenReturn(Bait()
      ..id = randomId()
      ..name = "Worm");
    when(appManager.mockBaitCategoryManager.entity(any)).thenReturn(
        BaitCategory()
          ..id = randomId()
          ..name = "Live Bait");
    await tester.pumpWidget(Testable(
      (_) => CatchPage(randomId()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.text("Worm"), findsOneWidget);
    expect(find.text("Live Bait"), findsOneWidget);
  });

  testWidgets("No fishing spot renders empty", (WidgetTester tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchPage(randomId()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.byType(StaticFishingSpot), findsNothing);
  });

  testWidgets("Fishing spot renders", (WidgetTester tester) async {
    when(appManager.mockFishingSpotManager.entity(any))
        .thenReturn(FishingSpot()
          ..id = randomId()
          ..name = "Baskets"
          ..lat = 1.234567
          ..lng = 7.654321);
    await tester.pumpWidget(Testable(
      (_) => CatchPage(randomId()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.byType(StaticFishingSpot), findsOneWidget);
  });
}