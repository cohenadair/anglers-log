import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/fishing_spot_details.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.bodyOfWaterManager.entity(any),
    ).thenReturn(BodyOfWater(id: randomId(), name: "Lake Huron"));

    when(managers.fishingSpotManager.entity(any)).thenReturn(null);
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);
    when(managers.fishingSpotManager.numberOfCatches(any)).thenReturn(0);

    when(
      managers.permissionHandlerWrapper.requestPhotos(),
    ).thenAnswer((_) => Future.value(false));

    when(managers.userPreferenceManager.catchFieldIds).thenReturn([]);

    when(
      managers.urlLauncherWrapper.canLaunch(any),
    ).thenAnswer((_) => Future.value(true));
    when(managers.lib.ioWrapper.isIOS).thenReturn(true);
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);
  });

  testWidgets("FishingSpotManager returns null falls back on input", (
    tester,
  ) async {
    when(managers.fishingSpotManager.entity(any)).thenReturn(null);

    await tester.pumpWidget(
      Testable((_) => FishingSpotDetails(FishingSpot(name: "Test"))),
    );

    verify(managers.fishingSpotManager.entity(any)).called(1);
    expect(find.text("Test"), findsOneWidget);
  });

  testWidgets("Fishing spot name is not empty", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(
            name: "Test",
            bodyOfWaterId: randomId(),
            lat: 1.23456,
            lng: 6.54321,
          ),
        ),
      ),
    );

    var listItem = findFirst<ImageListItem>(tester);
    expect(listItem.title, "Test");
    expect(listItem.subtitle, "Lake Huron");
    expect(listItem.subtitle2, "Lat: 1.234560, Lng: 6.543210");
    expect(listItem.subtitle3, isEmpty);
  });

  testWidgets("Fishing spot name is empty, but body of water is not", (
    tester,
  ) async {
    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(bodyOfWaterId: randomId(), lat: 1.23456, lng: 6.54321),
        ),
      ),
    );

    var listItem = findFirst<ImageListItem>(tester);
    expect(listItem.title, "Lake Huron");
    expect(listItem.subtitle, isNull);
    expect(listItem.subtitle2, "Lat: 1.234560, Lng: 6.543210");
    expect(listItem.subtitle3, isEmpty);
  });

  testWidgets("New Fishing Spot", (tester) async {
    when(managers.bodyOfWaterManager.entity(any)).thenReturn(null);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          isNewFishingSpot: true,
        ),
      ),
    );

    var listItem = findFirst<ImageListItem>(tester);
    expect(listItem.title, "New Fishing Spot");
    expect(listItem.subtitle, isNull);
    expect(listItem.subtitle2, "Lat: 1.234560, Lng: 6.543210");
    expect(listItem.subtitle3, isEmpty);
  });

  testWidgets("Coordinates as title", (tester) async {
    when(managers.bodyOfWaterManager.entity(any)).thenReturn(null);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(FishingSpot(lat: 1.23456, lng: 6.54321)),
      ),
    );

    var listItem = findFirst<ImageListItem>(tester);
    expect(listItem.title, "Lat: 1.234560, Lng: 6.543210");
    expect(listItem.subtitle, isNull);
    expect(listItem.subtitle2, isNull);
    expect(listItem.subtitle3, isEmpty);
  });

  testWidgets("Notes shown", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(
            name: "Test",
            lat: 1.23456,
            lng: 6.54321,
            notes: "Some notes.",
          ),
        ),
      ),
    );

    var listItem = findFirst<ImageListItem>(tester);
    expect(listItem.title, "Test");
    expect(listItem.subtitle, "Lake Huron");
    expect(listItem.subtitle2, "Lat: 1.234560, Lng: 6.543210");
    expect(listItem.subtitle3, "Some notes.");
  });

  testWidgets("List item hides notes", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(
            name: "Test",
            lat: 1.23456,
            lng: 6.54321,
            notes: "Some notes.",
          ),
          isListItem: true,
        ),
      ),
    );

    var listItem = findFirst<ImageListItem>(tester);
    expect(listItem.title, "Test");
    expect(listItem.subtitle, "Lake Huron");
    expect(listItem.subtitle2, "Lat: 1.234560, Lng: 6.543210");
    expect(listItem.subtitle3, isNull);
  });

  testWidgets("List item with non-null onTap", (tester) async {
    await tester.pumpWidget(
      Testable(
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
      ),
    );

    var listItem = findFirst<ImageListItem>(tester);
    expect(listItem.onTap, isNotNull);
    expect(find.byType(RightChevronIcon), findsOneWidget);
  });

  testWidgets("List item with null onTap", (tester) async {
    await tester.pumpWidget(
      Testable(
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
      ),
    );

    var listItem = findFirst<ImageListItem>(tester);
    expect(listItem.onTap, isNull);
    expect(find.byType(RightChevronIcon), findsNothing);
  });

  testWidgets("Show action buttons", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
        ),
      ),
    );
    expect(find.byType(ChipButton), findsWidgets);
  });

  testWidgets("Hide action buttons", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: false,
        ),
      ),
    );
    expect(find.byType(ChipButton), findsNothing);
  });

  testWidgets("Save action hidden when spot already exists", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
        ),
      ),
    );

    expect(find.widgetWithText(ChipButton, "Save"), findsNothing);
  });

  testWidgets("Save action hidden when picking", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          isPicking: true,
        ),
      ),
    );

    expect(find.widgetWithText(ChipButton, "Save"), findsNothing);
  });

  testWidgets("Save action shown", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          isPicking: false,
        ),
      ),
    );

    expect(find.widgetWithText(ChipButton, "Save"), findsOneWidget);
  });

  testWidgets("Add action hidden when spot doesn't exist", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
        ),
      ),
    );

    expect(find.widgetWithText(ChipButton, "Add Catch"), findsNothing);
  });

  testWidgets("Add action hidden when picking", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          isPicking: true,
        ),
      ),
    );

    expect(find.widgetWithText(ChipButton, "Add Catch"), findsNothing);
  });

  testWidgets("Add action shown", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          isPicking: false,
        ),
      ),
    );

    expect(find.widgetWithText(ChipButton, "Add Catch"), findsOneWidget);
  });

  testWidgets("Edit action hidden when spot doesn't exist and not picking", (
    tester,
  ) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          isPicking: false,
        ),
      ),
    );

    expect(find.widgetWithText(ChipButton, "Edit"), findsNothing);
  });

  testWidgets("Save details button in edit mode", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          isPicking: true,
        ),
      ),
    );

    expect(find.widgetWithText(ChipButton, "Edit"), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
  });

  testWidgets("Save details button in add mode", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          isPicking: true,
        ),
      ),
    );

    expect(find.widgetWithText(ChipButton, "Add Details"), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets("Delete action hidden if spot doesn't exist", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
        ),
      ),
    );

    expect(find.widgetWithText(ChipButton, "Delete"), findsNothing);
  });

  testWidgets("Delete action hidden if picking", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          isPicking: true,
        ),
      ),
    );

    expect(find.widgetWithText(ChipButton, "Delete"), findsNothing);
  });

  testWidgets("Delete action shown", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
        ),
      ),
    );

    expect(find.widgetWithText(ChipButton, "Delete"), findsOneWidget);
  });

  testWidgets("Directions action hidden", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          showDirections: false,
        ),
      ),
    );

    expect(find.widgetWithText(ChipButton, "Directions"), findsNothing);
  });

  testWidgets("Directions action shown", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          showDirections: true,
        ),
      ),
    );

    expect(find.widgetWithText(ChipButton, "Directions"), findsOneWidget);
  });

  testWidgets("Directions action shows all options", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          showDirections: true,
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Directions"));
    expect(find.text("Google Maps\u2122"), findsOneWidget);
    expect(find.text("Apple Maps\u2122"), findsOneWidget);
    expect(find.text("Waze\u2122"), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets("Dismissing bottom sheet doesn't launch directions", (
    tester,
  ) async {
    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          showDirections: true,
        ),
      ),
    );

    // Open bottom sheet.
    await tapAndSettle(tester, find.text("Directions"));
    expect(find.text("Google Maps\u2122"), findsOneWidget);
    expect(find.text("Apple Maps\u2122"), findsOneWidget);
    expect(find.text("Waze\u2122"), findsOneWidget);

    // Dismiss bottom sheet.
    await tester.fling(
      find.text("Apple Maps\u2122"),
      const Offset(0, 100),
      800,
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 150));
    expect(find.text("Google Maps\u2122"), findsNothing);
    expect(find.text("Apple Maps\u2122"), findsNothing);
    expect(find.text("Waze\u2122"), findsNothing);

    verifyNever(managers.urlLauncherWrapper.launch(any));
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets("Android has only 1 option", (tester) async {
    when(managers.lib.ioWrapper.isIOS).thenReturn(false);
    when(managers.lib.ioWrapper.isAndroid).thenReturn(true);
    when(
      managers.urlLauncherWrapper.canLaunch(any),
    ).thenAnswer((invocation) => Future.value(true));
    when(
      managers.urlLauncherWrapper.launch(any),
    ).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          showDirections: true,
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Directions"));

    var result = verify(managers.urlLauncherWrapper.launch(captureAny));
    result.called(1);

    expect(result.captured.first.contains("google.navigation"), isTrue);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets("No directions options defaults to browser", (tester) async {
    when(managers.lib.ioWrapper.isIOS).thenReturn(false);
    when(managers.urlLauncherWrapper.canLaunch(any)).thenAnswer(
      (invocation) => Future.value(
        invocation.positionalArguments.first.contains(
          "https://www.google.com/maps/dir/?",
        ),
      ),
    );
    when(
      managers.urlLauncherWrapper.launch(any),
    ).thenAnswer((_) => Future.value(true));

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          showDirections: true,
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Directions"));
    expect(find.byType(SnackBar), findsNothing);

    var result = verify(managers.urlLauncherWrapper.launch(captureAny));
    result.called(1);

    expect(
      result.captured.first.contains("https://www.google.com/maps/dir/?"),
      isTrue,
    );
  });

  testWidgets("Apple directions throws exception", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          showDirections: true,
        ),
      ),
    );

    when(
      managers.urlLauncherWrapper.launch(any),
    ).thenAnswer((_) => throw PlatformException(code: "CODE"));

    // Open bottom sheet.
    await tapAndSettle(tester, find.text("Directions"));
    await tapAndSettle(tester, find.text("Apple Maps\u2122"));

    verify(managers.urlLauncherWrapper.launch(any)).called(1);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets("Failed directions launch shows error snack bar", (tester) async {
    when(
      managers.urlLauncherWrapper.launch(any),
    ).thenAnswer((_) => Future.value(false));

    await tester.pumpWidget(
      Testable(
        (_) => Scaffold(
          body: FishingSpotDetails(
            FishingSpot(lat: 1.23456, lng: 6.54321),
            showActionButtons: true,
            showDirections: true,
          ),
        ),
      ),
    );

    await tapAndSettle(tester, find.text("Directions"));
    await tapAndSettle(tester, find.text("Apple Maps\u2122"));

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets("Shows chevron even if onTap is null", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => Scaffold(
          body: FishingSpotDetails(
            FishingSpot(lat: 1.23456, lng: 6.54321),
            showRightChevron: true,
            isListItem: true,
            onTap: null,
          ),
        ),
      ),
    );

    expect(find.byType(RightChevronIcon), findsOneWidget);
  });

  testWidgets("Hides chevron if isListItem is false", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => Scaffold(
          body: FishingSpotDetails(
            FishingSpot(lat: 1.23456, lng: 6.54321),
            showRightChevron: true,
            isListItem: false,
            onTap: null,
          ),
        ),
      ),
    );

    expect(find.byType(RightChevronIcon), findsNothing);
  });

  testWidgets("View catches action hidden when spot doesn't exist", (
    tester,
  ) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(false);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          isPicking: false,
        ),
      ),
    );

    verifyNever(managers.fishingSpotManager.numberOfCatches(any));
  });

  testWidgets("View 0 catches action", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(managers.fishingSpotManager.numberOfCatches(any)).thenReturn(0);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          isPicking: false,
        ),
      ),
    );

    expect(find.text("0 Catches"), findsOneWidget);
    expect(findFirst<ChipButton>(tester).onPressed, isNull);
  });

  testWidgets("View 1 catch action", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(managers.fishingSpotManager.numberOfCatches(any)).thenReturn(1);
    when(
      managers.catchManager.catches(any, opt: anyNamed("opt")),
    ).thenReturn([]);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          isPicking: false,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text("1 Catch"), findsOneWidget);
    await tapAndSettle(tester, find.text("1 Catch"));
    expect(find.byType(CatchListPage), findsOneWidget);
  });

  testWidgets("View multiple catches action", (tester) async {
    when(managers.fishingSpotManager.entityExists(any)).thenReturn(true);
    when(managers.fishingSpotManager.numberOfCatches(any)).thenReturn(2);
    when(
      managers.catchManager.catches(any, opt: anyNamed("opt")),
    ).thenReturn([]);

    await tester.pumpWidget(
      Testable(
        (_) => FishingSpotDetails(
          FishingSpot(lat: 1.23456, lng: 6.54321),
          showActionButtons: true,
          isPicking: false,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text("2 Catches"), findsOneWidget);
    await tapAndSettle(tester, find.text("2 Catches"));
    expect(find.byType(CatchListPage), findsOneWidget);
  });
}
