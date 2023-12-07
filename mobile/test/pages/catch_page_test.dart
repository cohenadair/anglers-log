import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/bait_page.dart';
import 'package:mobile/pages/bait_variant_page.dart';
import 'package:mobile/pages/catch_page.dart';
import 'package:mobile/res/gen/custom_icons.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/atmosphere_wrap.dart';
import 'package:mobile/widgets/fishing_spot_map.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/static_fishing_spot_map.dart';
import 'package:mobile/widgets/tide_chart.dart';
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
      ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
      ..speciesId = randomId());

    when(appManager.fishingSpotManager.list(any)).thenReturn([]);

    when(appManager.ioWrapper.isAndroid).thenReturn(false);

    when(appManager.propertiesManager.mapboxApiKey).thenReturn("");

    when(appManager.speciesManager.entity(any)).thenReturn(Species()
      ..id = randomId()
      ..name = "Steelhead");

    when(appManager.userPreferenceManager.mapType).thenReturn(null);
  });

  testWidgets("No period renders empty", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.text("Jan 1, 2020 at 3:30 PM"), findsOneWidget);
  });

  testWidgets("Period renders with timestamp", (tester) async {
    when(appManager.catchManager.entity(any)).thenReturn(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
      ..speciesId = randomId()
      ..period = Period.afternoon);

    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.text("Jan 1, 2020 at 3:30 PM (Afternoon)"), findsOneWidget);
  });

  testWidgets("No season renders empty", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.text("Jan 1, 2020 at 3:30 PM"), findsOneWidget);
  });

  testWidgets("Season renders with timestamp", (tester) async {
    when(appManager.catchManager.entity(any)).thenReturn(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
      ..speciesId = randomId()
      ..season = Season.autumn);

    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.text("Jan 1, 2020 at 3:30 PM (Autumn)"), findsOneWidget);
  });

  testWidgets("Period and season renders with timestamp", (tester) async {
    when(appManager.catchManager.entity(any)).thenReturn(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
      ..speciesId = randomId()
      ..period = Period.morning
      ..season = Season.autumn);

    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(
        find.text("Jan 1, 2020 at 3:30 PM (Morning, Autumn)"), findsOneWidget);
  });

  testWidgets("No bait renders empty", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.byType(ListItem), findsNothing);
  });

  testWidgets("Gear renders", (tester) async {
    when(appManager.catchManager.entity(any)).thenReturn(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
      ..speciesId = randomId()
      ..gearIds.add(randomId()));
    when(appManager.gearManager.list(any)).thenReturn([Gear()]);
    when(appManager.gearManager.entity(any)).thenReturn(Gear());
    when(appManager.gearManager.displayName(any, any)).thenReturn("Bass Rod");
    when(appManager.gearManager.numberOfCatchQuantities(any)).thenReturn(1);
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()..gearIds.add(randomId())),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(ImageListItem), findsOneWidget);
    expect(find.text("Bass Rod"), findsOneWidget);
  });

  testWidgets("Deleted gear renders empty", (tester) async {
    when(appManager.catchManager.entity(any)).thenReturn(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
      ..speciesId = randomId()
      ..gearIds.add(randomId()));
    when(appManager.gearManager.list(any)).thenReturn([Gear()]);
    when(appManager.gearManager.entity(any)).thenReturn(null);

    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()..gearIds.add(randomId())),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(ImageListItem), findsNothing);
  });

  testWidgets("No fishing spot renders empty", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(FishingSpotMap), findsNothing);
  });

  testWidgets("Fishing spot renders", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);
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

    expect(find.byType(StaticFishingSpotMap), findsOneWidget);
  });

  testWidgets("No angler renders empty", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

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
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets("No water clarity renders empty", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byIcon(CustomIcons.waterClarities), findsNothing);
  });

  testWidgets("Angler renders", (tester) async {
    when(appManager.waterClarityManager.entity(any)).thenReturn(WaterClarity()
      ..id = randomId()
      ..name = "Clear");
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byIcon(CustomIcons.waterClarities), findsOneWidget);
  });

  testWidgets("No methods renders empty", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(ChipWrap), findsNothing);
  });

  testWidgets("Fishing methods render", (tester) async {
    when(appManager.catchManager.entity(any)).thenReturn(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
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
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(ChipWrap), findsOneWidget);
    expect(find.text("Casting"), findsOneWidget);
    expect(find.text("Kayak"), findsOneWidget);
  });

  testWidgets("Fishing methods don't render if they don't exist",
      (tester) async {
    when(appManager.catchManager.entity(any)).thenReturn(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
      ..speciesId = randomId()
      ..methodIds.add(randomId()));
    when(appManager.methodManager.list(any)).thenReturn([]);
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()..methodIds.add(randomId())),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(ChipWrap), findsNothing);
  });

  testWidgets("No catch and release data renders empty", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.error), findsNothing);
  });

  testWidgets("Catch and release is true", (tester) async {
    when(appManager.catchManager.entity(any)).thenReturn(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
      ..speciesId = randomId()
      ..wasCatchAndRelease = true);
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()..wasCatchAndRelease = true),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text("Released"), findsOneWidget);
  });

  testWidgets("Catch and release is false", (tester) async {
    when(appManager.catchManager.entity(any)).thenReturn(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
      ..speciesId = randomId()
      ..wasCatchAndRelease = false);
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()..wasCatchAndRelease = false),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byIcon(Icons.error), findsOneWidget);
    expect(find.text("Kept"), findsOneWidget);
  });

  testWidgets("No atmosphere renders empty", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(AtmosphereWrap), findsNothing);
  });

  testWidgets("Atmosphere renders", (tester) async {
    when(appManager.catchManager.entity(any)).thenReturn(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
      ..atmosphere = Atmosphere(
        humidity: MultiMeasurement(
          mainValue: Measurement(
            unit: Unit.percent,
            value: 50,
          ),
        ),
      ));

    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));
    // Wait for map timer to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(AtmosphereWrap), findsOneWidget);
  });

  testWidgets("Multiple baits rendered", (tester) async {
    var baitId0 = randomId();
    var baitId1 = randomId();

    when(appManager.catchManager.entity(any)).thenReturn(Catch()
      ..id = randomId()
      ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
      ..baits.addAll([
        BaitAttachment(baitId: baitId0),
        BaitAttachment(baitId: baitId1),
      ]));

    when(appManager.baitManager.entity(baitId0)).thenReturn(Bait(
      id: baitId0,
      name: "Bait 0",
    ));
    when(appManager.baitManager.entity(baitId1)).thenReturn(Bait(
      id: baitId1,
      name: "Bait 1",
    ));
    when(appManager.baitManager.variant(any, any)).thenReturn(null);
    when(appManager.baitManager.formatNameWithCategory(any)).thenReturn("Test");

    await tester.pumpWidget(Testable(
      (_) => CatchPage(Catch()),
      appManager: appManager,
    ));

    expect(find.text("Test"), findsNWidgets(2));
  });

  testWidgets("Share text is empty", (tester) async {
    when(appManager.speciesManager.entity(any)).thenReturn(null);
    when(appManager.catchManager.entity(any)).thenReturn(Catch(
      id: randomId(),
      timestamp: Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch),
      speciesId: randomId(),
    ));
    when(appManager.sharePlusWrapper.share(any))
        .thenAnswer((_) => Future.value(null));

    await pumpContext(
      tester,
      (_) => CatchPage(Catch()),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(Icons.ios_share));

    var result = verify(appManager.sharePlusWrapper.share(captureAny));
    result.called(1);

    var text = result.captured.first as String;
    expect(text, "Shared with #AnglersLogApp for iOS.");
  });

  testWidgets("Share text includes species, length and weight", (tester) async {
    when(appManager.speciesManager.entity(any)).thenReturn(Species(
      name: "Smallmouth Bass",
    ));
    when(appManager.catchManager.entity(any)).thenReturn(Catch(
      id: randomId(),
      timestamp: Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch),
      speciesId: randomId(),
      length: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.centimeters,
          value: 30,
        ),
      ),
      weight: MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 2,
        ),
        fractionValue: Measurement(
          unit: Unit.ounces,
          value: 3,
        ),
      ),
    ));
    when(appManager.sharePlusWrapper.share(any))
        .thenAnswer((_) => Future.value(null));

    await pumpContext(
      tester,
      (_) => CatchPage(Catch()),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(Icons.ios_share));

    var result = verify(appManager.sharePlusWrapper.share(captureAny));
    result.called(1);

    var text = result.captured.first as String;
    expect(
      text,
      "Smallmouth Bass\n"
      "Length: 30 cm\n"
      "Weight: 2 lbs 3 oz\n\n"
      "Shared with #AnglersLogApp for iOS.",
    );
  });

  testWidgets("Share text includes a single bait", (tester) async {
    when(appManager.speciesManager.entity(any)).thenReturn(null);
    when(appManager.catchManager.entity(any)).thenReturn(Catch(
      id: randomId(),
      timestamp: Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch),
      speciesId: randomId(),
      baits: [
        BaitAttachment(baitId: randomId()),
      ],
    ));
    when(appManager.baitManager.attachmentDisplayValue(any, any))
        .thenReturn("Bait Attachment");
    when(appManager.sharePlusWrapper.share(any))
        .thenAnswer((_) => Future.value(null));

    await pumpContext(
      tester,
      (_) => CatchPage(Catch()),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(Icons.ios_share));

    var result = verify(appManager.sharePlusWrapper.share(captureAny));
    result.called(1);

    var text = result.captured.first as String;
    expect(
      text,
      "Bait: Bait Attachment\n\n"
      "Shared with #AnglersLogApp for iOS.",
    );
  });

  testWidgets("Share text includes a multiple baits", (tester) async {
    when(appManager.speciesManager.entity(any)).thenReturn(null);
    when(appManager.catchManager.entity(any)).thenReturn(Catch(
      id: randomId(),
      timestamp: Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch),
      speciesId: randomId(),
      baits: [
        BaitAttachment(baitId: randomId()),
        BaitAttachment(baitId: randomId()),
      ],
    ));
    when(appManager.baitManager.attachmentsDisplayValues(any, any))
        .thenReturn(["Bait Attachment", "Bait Attachment"]);
    when(appManager.sharePlusWrapper.share(any))
        .thenAnswer((_) => Future.value(null));

    await pumpContext(
      tester,
      (_) => CatchPage(Catch()),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(Icons.ios_share));

    var result = verify(appManager.sharePlusWrapper.share(captureAny));
    result.called(1);

    var text = result.captured.first as String;
    expect(
      text,
      "Baits: Bait Attachment, Bait Attachment\n\n"
      "Shared with #AnglersLogApp for iOS.",
    );
  });

  testWidgets("Share text includes everything", (tester) async {
    when(appManager.speciesManager.entity(any)).thenReturn(Species(
      name: "Smallmouth Bass",
    ));
    when(appManager.catchManager.entity(any)).thenReturn(Catch(
      id: randomId(),
      timestamp: Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch),
      speciesId: randomId(),
      length: MultiMeasurement(
        system: MeasurementSystem.metric,
        mainValue: Measurement(
          unit: Unit.centimeters,
          value: 30,
        ),
      ),
      weight: MultiMeasurement(
        system: MeasurementSystem.imperial_whole,
        mainValue: Measurement(
          unit: Unit.pounds,
          value: 2,
        ),
        fractionValue: Measurement(
          unit: Unit.ounces,
          value: 3,
        ),
      ),
      baits: [
        BaitAttachment(baitId: randomId()),
        BaitAttachment(baitId: randomId()),
      ],
    ));
    when(appManager.baitManager.attachmentsDisplayValues(any, any))
        .thenReturn(["Bait Attachment", "Bait Attachment"]);
    when(appManager.sharePlusWrapper.share(any))
        .thenAnswer((_) => Future.value(null));

    await pumpContext(
      tester,
      (_) => CatchPage(Catch()),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.byIcon(Icons.ios_share));

    var result = verify(appManager.sharePlusWrapper.share(captureAny));
    result.called(1);

    var text = result.captured.first as String;
    expect(
      text,
      "Smallmouth Bass\n"
      "Length: 30 cm\n"
      "Weight: 2 lbs 3 oz\n"
      "Baits: Bait Attachment, Bait Attachment\n\n"
      "Shared with #AnglersLogApp for iOS.",
    );
  });

  group("Water fields", () {
    testWidgets("No water fields", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch());
      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(CustomIcons.waterClarities), findsNothing);
    });

    testWidgets("Water clarity", (tester) async {
      when(appManager.waterClarityManager.entity(any)).thenReturn(WaterClarity(
        id: randomId(),
        name: "Chocolate Milk",
      ));
      when(appManager.catchManager.entity(any)).thenReturn(Catch(
        waterClarityId: randomId(),
      ));

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(CustomIcons.waterClarities), findsOneWidget);
      expect(find.text("Chocolate Milk"), findsOneWidget);
    });

    testWidgets("Water temperature", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch(
        waterTemperature: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.celsius,
            value: 50,
          ),
        ),
      ));

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(CustomIcons.waterClarities), findsOneWidget);
      expect(find.text("50\u00B0C"), findsOneWidget);
    });

    testWidgets("Water depth", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch(
        waterDepth: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.feet,
            value: 50,
          ),
        ),
      ));

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(CustomIcons.waterClarities), findsOneWidget);
      expect(find.text("50 ft"), findsOneWidget);
    });

    testWidgets("Non-chart tide with all data", (tester) async {
      when(appManager.catchManager.entity(any))
          .thenReturn(Catch(tide: Tide(type: TideType.outgoing)));

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.waves), findsOneWidget);
      expect(find.text("Outgoing Tide"), findsOneWidget);
    });

    testWidgets("Catch doesn't have a tide value", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch());

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.waves), findsNothing);
      expect(find.byType(TideChart), findsNothing);
    });

    testWidgets("Non-chart tide with no data", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch(tide: Tide()));

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.waves), findsNothing);
      expect(find.byType(TideChart), findsNothing);
    });

    testWidgets("Non-chart tide with current only", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch(
          tide: Tide(
        type: TideType.incoming,
      )));

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.waves), findsOneWidget);
      expect(find.byType(TideChart), findsNothing);
      expect(find.text("Incoming Tide"), findsOneWidget);
    });

    testWidgets("Non-chart tide with extremes only", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch(
          tide: Tide(
        firstLowTimestamp: Int64(1626937200000),
        firstHighTimestamp: Int64(1626973200000),
      )));

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.waves), findsOneWidget);
      expect(find.byType(TideChart), findsNothing);
      expect(find.text("Low: 3:00 AM; High: 1:00 PM"), findsOneWidget);
    });

    testWidgets("Chart tide", (tester) async {
      var height = Tide_Height(value: 0.015, timestamp: Int64(1626973200000));
      var cat = Catch(
        tide: Tide(
          height: height,
          daysHeights: [height],
        ),
      );

      when(appManager.userPreferenceManager.stream)
          .thenAnswer((_) => const Stream.empty());
      when(appManager.userPreferenceManager.tideHeightSystem)
          .thenReturn(MeasurementSystem.metric);
      when(appManager.catchManager.entity(any)).thenReturn(cat);

      await tester.pumpWidget(Testable(
        (_) => CatchPage(cat),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.waves), findsNothing);
      expect(find.byType(TideChart), findsOneWidget);
    });

    testWidgets("All water fields set", (tester) async {
      when(appManager.waterClarityManager.entity(any)).thenReturn(WaterClarity(
        id: randomId(),
        name: "Chocolate Milk",
      ));

      when(appManager.catchManager.entity(any)).thenReturn(Catch(
        waterTemperature: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.celsius,
            value: 50,
          ),
        ),
        waterDepth: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.feet,
            value: 10,
          ),
        ),
        waterClarityId: randomId(),
        tide: Tide(type: TideType.outgoing),
      ));

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.text("Chocolate Milk, 50\u00B0C, 10 ft"), findsOneWidget);
      expect(find.text("Outgoing Tide"), findsOneWidget);
    });
  });

  group("Size fields", () {
    testWidgets("No size weight", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch());

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(CustomIcons.ruler), findsNothing);
    });

    testWidgets("Weight", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch(
        weight: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.kilograms,
            value: 50,
          ),
        ),
      ));

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(CustomIcons.ruler), findsOneWidget);
      expect(find.text("50 kg"), findsOneWidget);
    });

    testWidgets("Length", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch(
        length: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.centimeters,
            value: 50,
          ),
        ),
      ));

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(CustomIcons.ruler), findsOneWidget);
      expect(find.text("50 cm"), findsOneWidget);
    });

    testWidgets("All size fields", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch(
        length: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.centimeters,
            value: 50,
          ),
        ),
        weight: MultiMeasurement(
          system: MeasurementSystem.metric,
          mainValue: Measurement(
            unit: Unit.kilograms,
            value: 10,
          ),
        ),
      ));

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(CustomIcons.ruler), findsOneWidget);
      expect(find.text("10 kg, 50 cm"), findsOneWidget);
    });
  });

  group("Notes fields", () {
    testWidgets("No notes fields", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch());
      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.notes), findsNothing);
    });

    testWidgets("Empty notes field", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch(
        notes: "",
      ));
      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.notes), findsNothing);
    });

    testWidgets("Zero quantity", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch(
        quantity: 0,
      ));
      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.notes), findsNothing);
    });

    testWidgets("Quantity", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch(
        quantity: 5,
      ));
      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.notes), findsOneWidget);
      expect(find.text("Quantity: 5"), findsOneWidget);
    });

    testWidgets("Notes", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch(
        notes: "Some notes.",
      ));
      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      expect(find.byIcon(Icons.notes), findsOneWidget);
      expect(find.text("Some notes."), findsOneWidget);
    });

    testWidgets("All notes fields", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch(
        notes: "Some notes.",
        quantity: 5,
      ));
      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));
      // Wait for map timer to finish.
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.pumpAndSettle(const Duration(milliseconds: 50));

      // One for each "note". Only one is visible.
      expect(find.byIcon(Icons.notes), findsNWidgets(2));
      expect(find.text("Some notes."), findsOneWidget);
      expect(find.text("Quantity: 5"), findsOneWidget);
    });
  });

  group("_BaitAttachmentListItem", () {
    testWidgets("Bait is null renders empty", (tester) async {
      var baitId0 = randomId();
      var baitId1 = randomId();

      when(appManager.catchManager.entity(any)).thenReturn(Catch()
        ..id = randomId()
        ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
        ..baits.addAll([
          BaitAttachment(baitId: baitId0),
          BaitAttachment(baitId: baitId1),
        ]));

      when(appManager.baitManager.entity(baitId0)).thenReturn(Bait(
        id: baitId0,
        name: "Bait 0",
      ));
      when(appManager.baitManager.entity(baitId1)).thenReturn(null);
      when(appManager.baitManager.variant(any, any)).thenReturn(null);
      when(appManager.baitManager.formatNameWithCategory(any))
          .thenReturn("Test");

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));

      expect(find.text("Test"), findsOneWidget);
    });

    testWidgets("Bait variant is null renders empty", (tester) async {
      var baitId0 = randomId();
      var baitId1 = randomId();

      when(appManager.catchManager.entity(any)).thenReturn(Catch()
        ..id = randomId()
        ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
        ..baits.addAll([
          BaitAttachment(baitId: baitId0, variantId: randomId()),
          BaitAttachment(baitId: baitId1),
        ]));

      when(appManager.baitManager.entity(baitId0)).thenReturn(Bait(
        id: baitId0,
        name: "Bait 0",
      ));
      when(appManager.baitManager.entity(baitId1)).thenReturn(Bait(
        id: baitId1,
        name: "Bait 1",
      ));
      when(appManager.baitManager.variant(any, any)).thenReturn(null);
      when(appManager.baitManager.formatNameWithCategory(any))
          .thenReturn("Test");

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));

      expect(find.text("Test"), findsOneWidget);
    });

    testWidgets("Tapping variant shows variant page", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch()
        ..id = randomId()
        ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
        ..baits.addAll([
          BaitAttachment(baitId: randomId(), variantId: randomId()),
        ]));

      when(appManager.baitManager.entity(any)).thenReturn(Bait(
        name: "Bait 0",
      ));
      when(appManager.baitManager.variant(any, any)).thenReturn(BaitVariant(
        color: "Red",
      ));
      when(appManager.baitManager.variantDisplayValue(
        any,
        any,
        includeCustomValues: anyNamed("includeCustomValues"),
      )).thenReturn("Red");
      when(appManager.baitManager.formatNameWithCategory(any))
          .thenReturn("Test");

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));

      await tapAndSettle(tester, find.text("Test"));
      expect(find.byType(BaitVariantPage), findsOneWidget);
    });

    testWidgets("Tapping bait shows bait page", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch()
        ..id = randomId()
        ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
        ..baits.addAll([
          BaitAttachment(baitId: randomId()),
        ]));

      when(appManager.baitManager.entity(any)).thenReturn(Bait(
        name: "Bait 0",
      ));
      when(appManager.baitManager.variant(any, any)).thenReturn(null);
      when(appManager.baitManager.formatNameWithCategory(any))
          .thenReturn("Test");
      when(appManager.baitManager.deleteMessage(any, any)).thenReturn("Delete");

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));

      await tapAndSettle(tester, find.text("Test"));
      expect(find.byType(BaitPage), findsOneWidget);
    });

    testWidgets("Image passed to ImageListItem", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch()
        ..id = randomId()
        ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
        ..baits.addAll([
          BaitAttachment(baitId: randomId()),
        ]));

      when(appManager.baitManager.entity(any)).thenReturn(Bait(
        name: "Bait 0",
        imageName: "image.png",
      ));
      when(appManager.baitManager.variant(any, any)).thenReturn(null);
      when(appManager.baitManager.formatNameWithCategory(any))
          .thenReturn("Test");

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));

      var imageItem = tester.widget<ImageListItem>(find.byType(ImageListItem));
      expect(imageItem.imageName, "image.png");
    });

    testWidgets("Null image passed to ImageListItem", (tester) async {
      when(appManager.catchManager.entity(any)).thenReturn(Catch()
        ..id = randomId()
        ..timestamp = Int64(dateTime(2020, 1, 1, 15, 30).millisecondsSinceEpoch)
        ..baits.addAll([
          BaitAttachment(baitId: randomId()),
        ]));

      when(appManager.baitManager.entity(any)).thenReturn(Bait(
        name: "Bait 0",
      ));
      when(appManager.baitManager.variant(any, any)).thenReturn(null);
      when(appManager.baitManager.formatNameWithCategory(any))
          .thenReturn("Test");

      await tester.pumpWidget(Testable(
        (_) => CatchPage(Catch()),
        appManager: appManager,
      ));

      var imageItem = tester.widget<ImageListItem>(find.byType(ImageListItem));
      expect(imageItem.imageName, isNull);
    });
  });
}
