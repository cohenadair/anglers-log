import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/catch_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      managers.userPreferenceManager.catchListItemSubtitleFieldId,
    ).thenReturn(null);

    when(managers.baitManager.attachmentDisplayValue(any, any)).thenReturn("");

    when(
      managers.catchManager.catches(
        any,
        filter: anyNamed("filter"),
        opt: anyNamed("opt"),
      ),
    ).thenReturn([
      Catch()
        ..id = randomId()
        ..timestamp = Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch)
        ..baits.add(BaitAttachment(baitId: randomId())),
    ]);

    when(managers.speciesManager.entity(any)).thenReturn(
      Species()
        ..id = randomId()
        ..name = "Steelhead",
    );
    stubFormatDisplayNamesFromIds(
      managers.speciesManager,
      (_) => ["Steelhead"],
    );
  });

  testWidgets("Adding disabled", (tester) async {
    await tester.pumpWidget(
      Testable((_) => const CatchListPage(enableAdding: false)),
    );
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets("Adding enabled", (tester) async {
    await tester.pumpWidget(
      Testable((_) => const CatchListPage(enableAdding: true)),
    );
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets("Fishing spot with name used as subtitle", (tester) async {
    when(managers.fishingSpotManager.entity(any)).thenReturn(
      FishingSpot()
        ..id = randomId()
        ..name = "Baskets"
        ..lat = 1.234567
        ..lng = 7.654321,
    );
    when(
      managers.fishingSpotManager.displayName(
        any,
        any,
        useLatLngFallback: anyNamed("useLatLngFallback"),
        includeBodyOfWater: anyNamed("includeBodyOfWater"),
      ),
    ).thenReturn("Baskets");
    await tester.pumpWidget(Testable((_) => const CatchListPage()));

    expect(find.text("Baskets"), findsOneWidget);
  });

  testWidgets("Null fishing spot uses bait as subtitle", (tester) async {
    when(managers.baitManager.entity(any)).thenReturn(
      Bait()
        ..id = randomId()
        ..name = "Roe Bag",
    );
    when(
      managers.baitManager.attachmentDisplayValue(any, any),
    ).thenReturn("Roe Bag");
    await tester.pumpWidget(Testable((_) => const CatchListPage()));

    expect(find.text("Roe Bag"), findsOneWidget);
  });

  testWidgets("Fishing spot without display name uses bait as subtitle", (
    tester,
  ) async {
    when(managers.fishingSpotManager.entity(any)).thenReturn(FishingSpot());
    when(
      managers.fishingSpotManager.displayName(
        any,
        any,
        useLatLngFallback: anyNamed("useLatLngFallback"),
        includeBodyOfWater: anyNamed("includeBodyOfWater"),
      ),
    ).thenReturn("");
    when(managers.baitManager.entity(any)).thenReturn(
      Bait()
        ..id = randomId()
        ..name = "Roe Bag",
    );
    when(
      managers.baitManager.attachmentDisplayValue(any, any),
    ).thenReturn("Roe Bag");
    await tester.pumpWidget(Testable((_) => const CatchListPage()));

    expect(find.text("Roe Bag"), findsOneWidget);
  });

  testWidgets("No subtitle if bait and fishing spot are null", (tester) async {
    var context = await pumpContext(tester, (_) => const CatchListPage());
    // 1 widget for the timestamp subtitle on one row.
    expect(find.subtitleText(context), findsOneWidget);
  });

  testWidgets("Empty input invokes CatchManager.catches", (tester) async {
    await tester.pumpWidget(Testable((_) => const CatchListPage(catches: [])));
    verify(
      managers.catchManager.catches(
        any,
        filter: anyNamed("filter"),
        opt: anyNamed("opt"),
      ),
    ).called(1);
  });

  testWidgets("Non-empty input does not invoke CatchManager.catches", (
    tester,
  ) async {
    await tester.pumpWidget(
      Testable((_) => CatchListPage(catches: [Catch(id: randomId())])),
    );
    verifyNever(
      managers.catchManager.catches(
        any,
        filter: anyNamed("filter"),
        opt: anyNamed("opt"),
      ),
    );
  });

  testWidgets("Items rebuild when catch list preferences change", (
    tester,
  ) async {
    var controller = StreamController<String>.broadcast();
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => controller.stream);
    when(
      managers.userPreferenceManager.catchListItemSubtitleFieldId,
    ).thenReturn(catchFieldIdQuantity);
    when(managers.fishingSpotManager.entity(any)).thenReturn(null);

    await pumpContext(tester, (_) => const CatchListPage());
    expect(find.text("Quantity: -"), findsOneWidget);

    when(
      managers.userPreferenceManager.catchListItemSubtitleFieldId,
    ).thenReturn(catchFieldIdNotes);
    controller.add(UserPreferenceManager.catchListItemKeys.first);
    await tester.pumpAndSettle();

    expect(find.text("Quantity: -"), findsNothing);
    expect(find.text("Notes: -"), findsOneWidget);
  });

  testWidgets("Items don't rebuild when unrelated preferences change", (
    tester,
  ) async {
    var controller = StreamController<String>.broadcast();
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => controller.stream);
    when(
      managers.userPreferenceManager.catchListItemSubtitleFieldId,
    ).thenReturn(catchFieldIdQuantity);
    when(managers.fishingSpotManager.entity(any)).thenReturn(null);

    await pumpContext(tester, (_) => const CatchListPage());
    expect(find.text("Quantity: -"), findsOneWidget);

    when(
      managers.userPreferenceManager.catchListItemSubtitleFieldId,
    ).thenReturn(catchFieldIdNotes);
    controller.add("unrelated_key");
    await tester.pumpAndSettle();

    expect(find.text("Quantity: -"), findsOneWidget);
    expect(find.text("Notes: -"), findsNothing);
  });

  testWidgets("Explicit subtitle field overrides the preference", (
    tester,
  ) async {
    when(
      managers.userPreferenceManager.catchListItemSubtitleFieldId,
    ).thenReturn(catchFieldIdQuantity);
    when(managers.fishingSpotManager.entity(any)).thenReturn(null);

    await pumpContext(
      tester,
      (_) => CatchListPage(subtitleFieldId: catchFieldIdNotes),
    );

    expect(find.text("Quantity: -"), findsNothing);
    expect(find.text("Notes: -"), findsOneWidget);
  });
}
