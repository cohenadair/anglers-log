import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.baitManager.attachmentDisplayValue(any, any))
        .thenReturn("");

    when(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn([
      Catch()
        ..id = randomId()
        ..timestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch)
        ..baits.add(BaitAttachment(baitId: randomId())),
    ]);

    when(appManager.speciesManager.entity(any)).thenReturn(Species()
      ..id = randomId()
      ..name = "Steelhead");
  });

  testWidgets("Adding disabled", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const CatchListPage(
        enableAdding: false,
      ),
      appManager: appManager,
    ));
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets("Adding enabled", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const CatchListPage(
        enableAdding: true,
      ),
      appManager: appManager,
    ));
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets("Fishing spot with name used as subtitle", (tester) async {
    when(appManager.fishingSpotManager.entity(any)).thenReturn(FishingSpot()
      ..id = randomId()
      ..name = "Baskets"
      ..lat = 1.234567
      ..lng = 7.654321);
    when(appManager.fishingSpotManager.displayName(
      any,
      any,
      useLatLngFallback: anyNamed("useLatLngFallback"),
      includeBodyOfWater: anyNamed("includeBodyOfWater"),
    )).thenReturn("Baskets");
    await tester.pumpWidget(Testable(
      (_) => const CatchListPage(),
      appManager: appManager,
    ));

    expect(find.text("Baskets"), findsOneWidget);
  });

  testWidgets("Null fishing spot uses bait as subtitle", (tester) async {
    when(appManager.baitManager.entity(any)).thenReturn(Bait()
      ..id = randomId()
      ..name = "Roe Bag");
    when(appManager.baitManager.attachmentDisplayValue(any, any))
        .thenReturn("Roe Bag");
    await tester.pumpWidget(Testable(
      (_) => const CatchListPage(),
      appManager: appManager,
    ));

    expect(find.text("Roe Bag"), findsOneWidget);
  });

  testWidgets("Fishing spot without display name uses bait as subtitle",
      (tester) async {
    when(appManager.fishingSpotManager.entity(any)).thenReturn(FishingSpot());
    when(appManager.fishingSpotManager.displayName(
      any,
      any,
      useLatLngFallback: anyNamed("useLatLngFallback"),
      includeBodyOfWater: anyNamed("includeBodyOfWater"),
    )).thenReturn("");
    when(appManager.baitManager.entity(any)).thenReturn(Bait()
      ..id = randomId()
      ..name = "Roe Bag");
    when(appManager.baitManager.attachmentDisplayValue(any, any))
        .thenReturn("Roe Bag");
    await tester.pumpWidget(Testable(
      (_) => const CatchListPage(),
      appManager: appManager,
    ));

    expect(find.text("Roe Bag"), findsOneWidget);
  });

  testWidgets("No subtitle if bait and fishing spot are null", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => const CatchListPage(),
      appManager: appManager,
    );
    // 1 widget for the timestamp subtitle on one row.
    expect(find.subtitleText(context), findsOneWidget);
  });

  testWidgets("Empty input invokes CatchManager.catches", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const CatchListPage(catches: []),
      appManager: appManager,
    ));
    verify(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).called(1);
  });

  testWidgets("Non-empty input does not invoke CatchManager.catches",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchListPage(catches: [
        Catch(id: randomId()),
      ]),
      appManager: appManager,
    ));
    verifyNever(appManager.catchManager.catches(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    ));
  });
}
