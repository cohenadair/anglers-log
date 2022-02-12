import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/main_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../mocks/stubbed_map_controller.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late StubbedMapController mapController;

  setUp(() {
    appManager = StubbedAppManager();
    mapController = StubbedMapController();

    when(appManager.baitCategoryManager.listSortedByName(
      filter: anyNamed("filter"),
    )).thenReturn([]);

    when(appManager.catchManager.imageNamesSortedByTimestamp(any))
        .thenReturn([]);
    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      dateRange: anyNamed("dateRange"),
      catchIds: anyNamed("catchIds"),
      speciesIds: anyNamed("speciesIds"),
      fishingSpotIds: anyNamed("fishingSpotIds"),
      baits: anyNamed("baits"),
    )).thenReturn([]);
    when(appManager.catchManager.hasEntities).thenReturn(false);

    when(appManager.reportManager.entityExists(any)).thenReturn(false);
    when(appManager.reportManager.defaultReport).thenReturn(Report());
    when(appManager.reportManager.displayName(any, any)).thenReturn("Test");

    when(appManager.fishingSpotManager.list()).thenReturn([]);
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    when(appManager.locationMonitor.currentLocation).thenReturn(null);

    when(appManager.propertiesManager.mapboxApiKey).thenReturn("");

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(true);

    when(appManager.timeManager.currentDateTime).thenReturn(DateTime.now());

    when(appManager.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingBaits).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingMethods).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingWaterClarities)
        .thenReturn(true);
    when(appManager.userPreferenceManager.selectedReportId).thenReturn(null);
    when(appManager.userPreferenceManager.setSelectedReportId(any))
        .thenAnswer((_) => Future.value());
    when(appManager.userPreferenceManager.mapType).thenReturn(null);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
  });

  testWidgets("Tapping nav item opens page", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await mapController.finishLoading(tester);

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
    expect(find.text("Add New"), findsOneWidget);
  });

  testWidgets("Navigation state is persisted when switching tabs",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => MainPage(),
      appManager: appManager,
    ));
    // Let map timers settle.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await mapController.finishLoading(tester);

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
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await mapController.finishLoading(tester);

    await tapAndSettle(tester, find.byIcon(Icons.more_horiz));
    await tapAndSettle(tester, find.text("Bait Categories"));

    expect(find.text("Bait Categories (0)"), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.more_horiz));
    expect(find.text("Bait Categories (0)"), findsNothing);
  });
}
