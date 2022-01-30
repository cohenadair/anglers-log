import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/pages/save_custom_entity_page.dart';
import 'package:mobile/widgets/add_anything_bottom_sheet.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.subscriptionManager.subscriptions())
        .thenAnswer((_) => Future.value(null));

    when(appManager.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingBaits).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingMethods).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingWaterClarities)
        .thenReturn(true);
  });

  testWidgets("All entities are visible", (tester) async {
    await pumpContext(
      tester,
      (_) => const AddAnythingBottomSheet(),
      appManager: appManager,
    );

    expect(find.text("Angler"), findsOneWidget);
    expect(find.text("Bait Category"), findsOneWidget);
    expect(find.text("Bait"), findsOneWidget);
    expect(find.text("Body Of Water"), findsOneWidget);
    expect(find.text("Catch"), findsOneWidget);
    expect(find.text("Custom Field"), findsOneWidget);
    expect(find.text("Fishing Method"), findsOneWidget);
    expect(find.text("Species"), findsOneWidget);
    expect(find.text("Trip"), findsOneWidget);
    expect(find.text("Water Clarity"), findsOneWidget);
  });

  testWidgets("Entities not tracked aren't visible", (tester) async {
    when(appManager.userPreferenceManager.isTrackingMethods).thenReturn(false);

    await pumpContext(
      tester,
      (_) => const AddAnythingBottomSheet(),
      appManager: appManager,
    );

    expect(find.text("Fishing Method"), findsNothing);
  });

  testWidgets("Pro only entities show ProPage for free users", (tester) async {
    when(appManager.subscriptionManager.isFree).thenReturn(true);
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    await pumpContext(
      tester,
      (_) => const AddAnythingBottomSheet(),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.text("Custom Field"));
    expect(find.byType(ProPage), findsOneWidget);
    expect(find.byType(SaveCustomEntityPage), findsNothing);
  });

  testWidgets("Pro only entities do not show ProPage for pro users",
      (tester) async {
    when(appManager.subscriptionManager.isFree).thenReturn(false);

    await pumpContext(
      tester,
      (_) => const AddAnythingBottomSheet(),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.text("Custom Field"));
    expect(find.byType(ProPage), findsNothing);
    expect(find.byType(SaveCustomEntityPage), findsOneWidget);
  });
}
