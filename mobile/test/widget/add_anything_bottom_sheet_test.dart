import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/entity_utils.dart';
import 'package:mobile/widgets/add_anything_bottom_sheet.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingBaits).thenReturn(true);
    when(
      managers.userPreferenceManager.isTrackingFishingSpots,
    ).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingMethods).thenReturn(true);
    when(
      managers.userPreferenceManager.isTrackingWaterClarities,
    ).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingGear).thenReturn(true);
  });

  testWidgets("All entities are visible", (tester) async {
    await showPresentedWidget(
      tester,
      (context) => showAddAnythingBottomSheet(context),
    );

    expect(find.text("Angler"), findsOneWidget);
    expect(find.text("Bait Category"), findsOneWidget);
    expect(find.text("Bait"), findsOneWidget);
    expect(find.text("Body of Water"), findsOneWidget);
    expect(find.text("Catch"), findsOneWidget);
    expect(find.text("Custom Field"), findsOneWidget);
    expect(find.text("Fishing Method"), findsOneWidget);
    expect(find.text("Species"), findsOneWidget);
    expect(find.text("Trip"), findsOneWidget);
    expect(find.text("Water Clarity"), findsOneWidget);
    expect(find.text("Gear"), findsOneWidget);
    expect(find.text("GPS Trail"), findsNothing);
  });

  testWidgets("Entities not tracked aren't visible", (tester) async {
    when(managers.userPreferenceManager.isTrackingMethods).thenReturn(false);
    await showPresentedWidget(
      tester,
      (context) => showAddAnythingBottomSheet(context),
    );
    expect(find.text("Fishing Method"), findsNothing);
  });

  testWidgets("EntitySpec is returned when selected", (tester) async {
    EntitySpec? spec;
    await showPresentedWidget(
      tester,
      (context) =>
          showAddAnythingBottomSheet(context).then((value) => spec = value),
    );

    await tapAndSettle(tester, find.text("Angler"));

    expect(spec, isNotNull);
    expect(spec!.icon, iconAngler);
  });
}
