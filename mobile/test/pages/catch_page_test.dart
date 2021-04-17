import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/catch_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/static_fishing_spot.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.catchManager.deleteMessage(any, any)).thenReturn("Delete");
    when(appManager.catchManager.entity(any)).thenReturn(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
      ..speciesId = randomId());
    when(appManager.speciesManager.entity(any)).thenReturn(Species()
      ..id = randomId()
      ..name = "Steelhead");
  });

  testWidgets("No bait renders empty", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(Duration(milliseconds: 250));
    expect(find.byType(ListItem), findsNothing);
  });

  testWidgets("Bait without category doesn't show subtitle", (tester) async {
    when(appManager.baitManager.entity(any)).thenReturn(
      Bait()
        ..id = randomId()
        ..name = "Worm",
    );
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.text("Worm"), findsOneWidget);
    expect(find.byType(SubtitleLabel), findsOneWidget); // One for time label.
  });

  testWidgets("Bait with category shows subtitle", (tester) async {
    when(appManager.baitManager.entity(any)).thenReturn(Bait()
      ..id = randomId()
      ..name = "Worm");
    when(appManager.baitCategoryManager.entity(any)).thenReturn(
      BaitCategory()
        ..id = randomId()
        ..name = "Live Bait",
    );
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.text("Worm"), findsOneWidget);
    expect(find.text("Live Bait"), findsOneWidget);
  });

  testWidgets("No fishing spot renders empty", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.byType(StaticFishingSpot), findsNothing);
  });

  testWidgets("Fishing spot renders", (tester) async {
    when(appManager.fishingSpotManager.entity(any)).thenReturn(
      FishingSpot()
        ..id = randomId()
        ..name = "Baskets"
        ..lat = 1.234567
        ..lng = 7.654321,
    );
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.byType(StaticFishingSpot), findsOneWidget);
  });

  testWidgets("No angler renders empty", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.byIcon(Icons.person), findsNothing);
  });

  testWidgets("Angler renders", (tester) async {
    when(appManager.anglerManager.entity(any)).thenReturn(Angler()
      ..id = randomId()
      ..name = "Cohen");
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets("No methods renders empty", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.byType(ChipWrap), findsNothing);
  });

  testWidgets("Fishing methods render", (tester) async {
    when(appManager.catchManager.entity(any)).thenReturn(Catch()
      ..id = randomId()
      ..timestamp = Int64(DateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
      ..speciesId = randomId()
      ..methodIds.add(randomId()));
    when(appManager.methodManager.list(any)).thenReturn([
      Method()
        ..id = randomId()
        ..name = "Casting",
      Method()
        ..id = randomId()
        ..name = "Kayak",
    ]);
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()..methodIds.add(randomId())),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(Duration(milliseconds: 250));

    expect(find.byType(ChipWrap), findsOneWidget);
    expect(find.text("Casting"), findsOneWidget);
    expect(find.text("Kayak"), findsOneWidget);
  });
}
