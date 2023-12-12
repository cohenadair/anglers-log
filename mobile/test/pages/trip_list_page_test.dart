import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/trip_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  Trip defaultTrip() {
    return Trip(
      id: randomId(),
      startTimestamp: Int64(dateTime(2020, 1, 1).millisecondsSinceEpoch),
      endTimestamp: Int64(dateTime(2020, 2, 1).millisecondsSinceEpoch),
    );
  }

  setUp(() {
    appManager = StubbedAppManager();
    when(appManager.tripManager.numberOfCatches(any)).thenReturn(0);
  });

  testWidgets("Trip with name", (tester) async {
    when(appManager.tripManager.trips(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn([defaultTrip()..name = "Test Trip"]);

    var context = await pumpContext(
      tester,
      (_) => const TripListPage(),
      appManager: appManager,
    );

    expect(find.primaryText(context, text: "Test Trip"), findsOneWidget);
  });

  testWidgets("Trip without name", (tester) async {
    when(appManager.tripManager.trips(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn([defaultTrip()]);

    var context = await pumpContext(
      tester,
      (_) => const TripListPage(),
      appManager: appManager,
    );

    expect(
      find.primaryText(context, text: "Jan 1, 2020 to Feb 1, 2020"),
      findsOneWidget,
    );
  });

  testWidgets("Trip without catches", (tester) async {
    when(appManager.tripManager.trips(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn([defaultTrip()]);
    when(appManager.tripManager.numberOfCatches(any)).thenReturn(0);

    await pumpContext(
      tester,
      (_) => const TripListPage(),
      appManager: appManager,
    );
    expect(
      findFirst<ManageableListImageItem>(tester).subtitle2Style!.color,
      Colors.red,
    );
    expect(find.text("Skunked"), findsOneWidget);
  });

  testWidgets("Trip with catches", (tester) async {
    when(appManager.tripManager.trips(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn([defaultTrip()]);
    when(appManager.tripManager.numberOfCatches(any)).thenReturn(5);

    await pumpContext(
      tester,
      (_) => const TripListPage(),
      appManager: appManager,
    );
    expect(
      findFirst<ManageableListImageItem>(tester).subtitle2Style!.color,
      Colors.green,
    );
    expect(find.text("5 Catches"), findsOneWidget);
  });

  testWidgets("Trip without images", (tester) async {
    when(appManager.tripManager.trips(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn([defaultTrip()..imageNames.clear()]);

    await pumpContext(
      tester,
      (_) => const TripListPage(),
      appManager: appManager,
    );
    expect(
      findFirst<ManageableListImageItem>(tester).imageName,
      isNull,
    );
  });

  testWidgets("Trip with images", (tester) async {
    when(appManager.tripManager.trips(
      any,
      filter: anyNamed("filter"),
      opt: anyNamed("opt"),
    )).thenReturn([defaultTrip()..imageNames.add("test.png")]);

    await pumpContext(
      tester,
      (_) => const TripListPage(),
      appManager: appManager,
    );
    expect(
      findFirst<ManageableListImageItem>(tester).imageName,
      isNotNull,
    );
  });
}
