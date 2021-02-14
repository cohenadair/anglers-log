import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/add_anything_page.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mock_app_manager.dart';
import '../test_utils.dart';

void main() {
  MockAppManager appManager;

  setUp(() {
    appManager = MockAppManager(
      mockAuthManager: true,
      mockBaitCategoryManager: true,
      mockBaitManager: true,
      mockCatchManager: true,
      mockComparisonReportManager: true,
      mockLocalDatabaseManager: true,
      mockFishingSpotManager: true,
      mockImageManager: true,
      mockLocationMonitor: true,
      mockPreferencesManager: true,
      mockSpeciesManager: true,
      mockSubscriptionManager: true,
      mockSummaryReportManager: true,
      mockTimeManager: true,
    );

    when(appManager.mockAuthManager.stream).thenAnswer((_) => MockStream());

    when(appManager.mockBaitCategoryManager.listSortedByName(
      filter: anyNamed("filter"),
    )).thenReturn([]);

    when(appManager.mockCatchManager.imageNamesSortedByTimestamp(any))
        .thenReturn([]);
    when(appManager.mockCatchManager.catchesSortedByTimestamp(
      any,
      filter: anyNamed("filter"),
      dateRange: anyNamed("dateRange"),
      catchIds: anyNamed("catchIds"),
      speciesIds: anyNamed("speciesIds"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      baitIds: anyNamed("baitIds"),
    )).thenReturn([]);

    when(appManager.mockComparisonReportManager.entityExists(any))
        .thenReturn(false);

    when(appManager.mockFishingSpotManager.list()).thenReturn([]);

    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);

    when(appManager.mockSummaryReportManager.entityExists(any))
        .thenReturn(false);

    when(appManager.mockTimeManager.currentDateTime).thenReturn(DateTime.now());
  });

  testWidgets("Tapping nav item opens page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    // Starts on Catches page.
    expect(findFirst<IndexedStack>(tester).index, 1);

    await tapAndSettle(tester, find.text("Catches"));
    expect(findFirst<IndexedStack>(tester).index, 1);

    await tapAndSettle(tester, find.text("Map"));
    expect(findFirst<IndexedStack>(tester).index, 0);

    await tapAndSettle(tester, find.text("Stats"));
    expect(findFirst<IndexedStack>(tester).index, 3);

    await tapAndSettle(tester, find.byIcon(Icons.more_horiz));
    expect(findFirst<IndexedStack>(tester).index, 4);

    await tapAndSettle(tester, find.text("Add"));
    // Indexed stack should stay at the same index.
    expect(findFirst<IndexedStack>(tester).index, 4);
    expect(find.byType(AddAnythingPage), findsOneWidget);
  });

  testWidgets("Navigation state is persisted when switching tabs",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    await tapAndSettle(tester, find.byIcon(Icons.more_horiz));
    await tapAndSettle(tester, find.text("Bait Categories"));

    expect(find.text("Bait Categories (0)"), findsOneWidget);

    await tapAndSettle(tester, find.text("Catches"));
    expect(find.text("Bait Categories (0)"), findsOneWidget);
  });

  testWidgets("Tapping current nav item again pops all pages on current stack",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    await tapAndSettle(tester, find.byIcon(Icons.more_horiz));
    await tapAndSettle(tester, find.text("Bait Categories"));

    expect(find.text("Bait Categories (0)"), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.more_horiz));
    expect(find.text("Bait Categories (0)"), findsNothing);
  });

  testWidgets("Rate dialog shown when catches updated", (tester) async {
    var species = Species()
      ..id = randomId()
      ..name = "Bass";
    when(appManager.mockSpeciesManager.entity(any)).thenReturn(species);

    var catchManager = CatchManager(appManager);
    when(appManager.catchManager).thenReturn(catchManager);

    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));

    var quarterDuration = Duration.millisecondsPerDay * (365 / 4);
    when(appManager.mockTimeManager.msSinceEpoch)
        .thenReturn((quarterDuration + 10).toInt());
    when(appManager.mockPreferencesManager.didRateApp).thenReturn(false);
    when(appManager.mockPreferencesManager.rateTimerStartedAt).thenReturn(0);
    when(appManager.mockImageManager.save(any, compress: anyNamed("compress")))
        .thenAnswer((_) => Future.value([]));
    when(appManager.mockLocalDatabaseManager
            .insertOrUpdateEntity(any, any, any))
        .thenAnswer((_) => Future.value(true));

    catchManager.addOrUpdate(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch)
      ..speciesId = species.id);

    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
