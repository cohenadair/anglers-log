import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/fishing_spot_details.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.bodyOfWaterManager.entity(any)).thenReturn(BodyOfWater(
      id: randomId(),
      name: "Lake Huron",
    ));

    when(appManager.fishingSpotManager.entity(any)).thenReturn(null);
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    when(appManager.permissionHandlerWrapper.requestPhotos())
        .thenAnswer((_) => Future.value(false));

    when(appManager.userPreferenceManager.catchFieldIds).thenReturn([]);

    when(appManager.urlLauncherWrapper.canLaunch(any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.ioWrapper.isIOS).thenReturn(true);
  });

  testWidgets("FishingSpotManager returns null falls back on input",
      (tester) async {
    when(appManager.fishingSpotManager.entity(any)).thenReturn(null);

    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(name: "Test"),
      ),
      appManager: appManager,
    ));

    verify(appManager.fishingSpotManager.entity(any)).called(1);
    expect(find.text("Test"), findsOneWidget);
  });

  testWidgets("Fishing spot name is not empty", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(
          name: "Test",
          bodyOfWaterId: randomId(),
          lat: 1.23456,
          lng: 6.54321,
        ),
      ),
      appManager: appManager,
    ));

    var listItem = findFirst<ImageListItem>(tester);
    expect(listItem.title, "Test");
    expect(listItem.subtitle, "Lake Huron");
    expect(listItem.subtitle2, "Lat: 1.234560, Lng: 6.543210");
    expect(listItem.subtitle3, isEmpty);
  });

  testWidgets("Fishing spot name is empty, but body of water is not",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(
          bodyOfWaterId: randomId(),
          lat: 1.23456,
          lng: 6.54321,
        ),
      ),
      appManager: appManager,
    ));

    var listItem = findFirst<ImageListItem>(tester);
    expect(listItem.title, "Lake Huron");
    expect(listItem.subtitle, isNull);
    expect(listItem.subtitle2, "Lat: 1.234560, Lng: 6.543210");
    expect(listItem.subtitle3, isEmpty);
  });

  testWidgets("Dropped pin", (tester) async {
    when(appManager.bodyOfWaterManager.entity(any)).thenReturn(null);

    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(
          lat: 1.23456,
          lng: 6.54321,
        ),
        isDroppedPin: true,
      ),
      appManager: appManager,
    ));

    var listItem = findFirst<ImageListItem>(tester);
    expect(listItem.title, "Dropped Pin");
    expect(listItem.subtitle, isNull);
    expect(listItem.subtitle2, "Lat: 1.234560, Lng: 6.543210");
    expect(listItem.subtitle3, isEmpty);
  });

  testWidgets("Coordinates as title", (tester) async {
    when(appManager.bodyOfWaterManager.entity(any)).thenReturn(null);

    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(
          lat: 1.23456,
          lng: 6.54321,
        ),
      ),
      appManager: appManager,
    ));

    var listItem = findFirst<ImageListItem>(tester);
    expect(listItem.title, "Lat: 1.234560, Lng: 6.543210");
    expect(listItem.subtitle, isNull);
    expect(listItem.subtitle2, isNull);
    expect(listItem.subtitle3, isEmpty);
  });

  testWidgets("Notes shown", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(
          name: "Test",
          lat: 1.23456,
          lng: 6.54321,
          notes: "Some notes.",
        ),
      ),
      appManager: appManager,
    ));

    var listItem = findFirst<ImageListItem>(tester);
    expect(listItem.title, "Test");
    expect(listItem.subtitle, "Lake Huron");
    expect(listItem.subtitle2, "Lat: 1.234560, Lng: 6.543210");
    expect(listItem.subtitle3, "Some notes.");
  });

  testWidgets("List item hides notes", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(
          name: "Test",
          lat: 1.23456,
          lng: 6.54321,
          notes: "Some notes.",
        ),
        isListItem: true,
      ),
      appManager: appManager,
    ));

    var listItem = findFirst<ImageListItem>(tester);
    expect(listItem.title, "Test");
    expect(listItem.subtitle, "Lake Huron");
    expect(listItem.subtitle2, "Lat: 1.234560, Lng: 6.543210");
    expect(listItem.subtitle3, isNull);
  });

  testWidgets("List item with non-null onTap", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(
          name: "Test",
          lat: 1.23456,
          lng: 6.54321,
          notes: "Some notes.",
        ),
        isListItem: true,
        onTap: () {},
      ),
      appManager: appManager,
    ));

    var listItem = findFirst<ImageListItem>(tester);
    expect(listItem.onTap, isNotNull);
    expect(find.byType(RightChevronIcon), findsOneWidget);
  });

  testWidgets("List item with null onTap", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(
          name: "Test",
          lat: 1.23456,
          lng: 6.54321,
          notes: "Some notes.",
        ),
        isListItem: true,
        onTap: null,
      ),
      appManager: appManager,
    ));

    var listItem = findFirst<ImageListItem>(tester);
    expect(listItem.onTap, isNull);
    expect(find.byType(RightChevronIcon), findsNothing);
  });

  testWidgets("Show action buttons", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(
          lat: 1.23456,
          lng: 6.54321,
        ),
        showActionButtons: true,
      ),
      appManager: appManager,
    ));
    expect(find.byType(ChipButton), findsWidgets);
  });

  testWidgets("Hide action buttons", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(
          lat: 1.23456,
          lng: 6.54321,
        ),
        showActionButtons: false,
      ),
      appManager: appManager,
    ));
    expect(find.byType(ChipButton), findsNothing);
  });

  testWidgets("Save action hidden when spot already exists", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(lat: 1.23456, lng: 6.54321),
        showActionButtons: true,
      ),
      appManager: appManager,
    ));

    expect(find.widgetWithText(ChipButton, "Save"), findsNothing);
  });

  testWidgets("Save action hidden when picking", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(lat: 1.23456, lng: 6.54321),
        showActionButtons: true,
        isPicking: true,
      ),
      appManager: appManager,
    ));

    expect(find.widgetWithText(ChipButton, "Save"), findsNothing);
  });

  testWidgets("Save action shown", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(lat: 1.23456, lng: 6.54321),
        showActionButtons: true,
        isPicking: false,
      ),
      appManager: appManager,
    ));

    expect(find.widgetWithText(ChipButton, "Save"), findsOneWidget);
  });

  testWidgets("Add action hidden when spot doesn't exist", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(lat: 1.23456, lng: 6.54321),
        showActionButtons: true,
      ),
      appManager: appManager,
    ));

    expect(find.widgetWithText(ChipButton, "Add Catch"), findsNothing);
  });

  testWidgets("Add action hidden when picking", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(lat: 1.23456, lng: 6.54321),
        showActionButtons: true,
        isPicking: true,
      ),
      appManager: appManager,
    ));

    expect(find.widgetWithText(ChipButton, "Add Catch"), findsNothing);
  });

  testWidgets("Add action shown", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(lat: 1.23456, lng: 6.54321),
        showActionButtons: true,
        isPicking: false,
      ),
      appManager: appManager,
    ));

    expect(find.widgetWithText(ChipButton, "Add Catch"), findsOneWidget);
  });

  testWidgets("Edit action hidden when spot doesn't exist and not picking",
      (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(lat: 1.23456, lng: 6.54321),
        showActionButtons: true,
        isPicking: false,
      ),
      appManager: appManager,
    ));

    expect(find.widgetWithText(ChipButton, "Edit"), findsNothing);
  });

  testWidgets("Edit action shows when spot doesn't exist, but is picking",
      (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(lat: 1.23456, lng: 6.54321),
        showActionButtons: true,
        isPicking: true,
      ),
      appManager: appManager,
    ));

    expect(find.widgetWithText(ChipButton, "Edit"), findsOneWidget);
  });

  testWidgets("Delete action hidden if spot doesn't exist", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(lat: 1.23456, lng: 6.54321),
        showActionButtons: true,
      ),
      appManager: appManager,
    ));

    expect(find.widgetWithText(ChipButton, "Delete"), findsNothing);
  });

  testWidgets("Delete action shown", (tester) async {
    when(appManager.fishingSpotManager.entityExists(any)).thenReturn(true);

    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(lat: 1.23456, lng: 6.54321),
        showActionButtons: true,
      ),
      appManager: appManager,
    ));

    expect(find.widgetWithText(ChipButton, "Delete"), findsOneWidget);
  });

  testWidgets("Directions action hidden", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(lat: 1.23456, lng: 6.54321),
        showActionButtons: true,
        isPicking: true,
      ),
      appManager: appManager,
    ));

    expect(find.widgetWithText(ChipButton, "Directions"), findsNothing);
  });

  testWidgets("Directions action shown", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(lat: 1.23456, lng: 6.54321),
        showActionButtons: true,
        isPicking: false,
      ),
      appManager: appManager,
    ));

    expect(find.widgetWithText(ChipButton, "Directions"), findsOneWidget);
  });

  testWidgets("Directions action launches directions", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(lat: 1.23456, lng: 6.54321),
        showActionButtons: true,
        isPicking: false,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.widgetWithText(ChipButton, "Directions"));
  });

  testWidgets("All directions options", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(lat: 1.23456, lng: 6.54321),
        showActionButtons: true,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Directions"));
    expect(find.text("Google Maps"), findsOneWidget);
    expect(find.text("Apple Maps"), findsOneWidget);
    expect(find.text("Waze"), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets("Dismissing bottom sheet doesn't launch directions",
      (tester) async {
    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(lat: 1.23456, lng: 6.54321),
        showActionButtons: true,
      ),
      appManager: appManager,
    ));

    // Open bottom sheet.
    await tapAndSettle(tester, find.text("Directions"));
    expect(find.text("Google Maps"), findsOneWidget);
    expect(find.text("Apple Maps"), findsOneWidget);
    expect(find.text("Waze"), findsOneWidget);

    // Dismiss bottom sheet.
    await tester.fling(find.text("Apple Maps"), Offset(0, 100), 800);
    await tester.pumpAndSettle(Duration(milliseconds: 150));
    expect(find.text("Google Maps"), findsNothing);
    expect(find.text("Apple Maps"), findsNothing);
    expect(find.text("Waze"), findsNothing);

    verifyNever(appManager.urlLauncherWrapper.launch(any));
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets("Single directions option", (tester) async {
    when(appManager.ioWrapper.isIOS).thenReturn(false);
    when(appManager.urlLauncherWrapper.canLaunch(any)).thenAnswer(
        (invocation) => Future.value(
            invocation.positionalArguments.first.contains("waze")));
    when(appManager.urlLauncherWrapper.launch(any))
        .thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(lat: 1.23456, lng: 6.54321),
        showActionButtons: true,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Directions"));

    var result = verify(appManager.urlLauncherWrapper.launch(captureAny));
    result.called(1);

    expect(result.captured.first.contains("waze"), isTrue);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets("No directions options defaults to browser", (tester) async {
    when(appManager.ioWrapper.isIOS).thenReturn(false);
    when(appManager.urlLauncherWrapper.canLaunch(any)).thenAnswer(
        (invocation) => Future.value(invocation.positionalArguments.first
            .contains("https://www.google.com/maps/dir/?")));
    when(appManager.urlLauncherWrapper.launch(any))
        .thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(Testable(
      (_) => FishingSpotDetails(
        FishingSpot(lat: 1.23456, lng: 6.54321),
        showActionButtons: true,
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Directions"));
    expect(find.byType(SnackBar), findsNothing);

    var result = verify(appManager.urlLauncherWrapper.launch(captureAny));
    result.called(1);

    expect(
      result.captured.first.contains("https://www.google.com/maps/dir/?"),
      isTrue,
    );
  });

  testWidgets("Failed directions launch shows error snack bar", (tester) async {
    when(appManager.urlLauncherWrapper.launch(any))
        .thenAnswer((_) => Future.value(false));

    await tester.pumpWidget(Testable(
      (_) => Scaffold(
        body: FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
        ),
      ),
      appManager: appManager,
    ));

    await tapAndSettle(tester, find.text("Directions"));
    await tapAndSettle(tester, find.text("Apple Maps"));

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
