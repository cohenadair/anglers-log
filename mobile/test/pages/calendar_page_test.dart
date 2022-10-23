import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/calendar_page.dart';
import 'package:mobile/pages/catch_page.dart';
import 'package:mobile/pages/trip_page.dart';
import 'package:mobile/utils/color_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timezone/timezone.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late TZDateTime currentDateTime;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.catchManager.list()).thenReturn([]);
    when(appManager.catchManager.deleteMessage(any, any)).thenReturn("Delete");

    when(appManager.imageManager.save(any, compress: anyNamed("compress")))
        .thenAnswer((_) => Future.value([]));

    when(appManager.ioWrapper.isAndroid).thenReturn(false);

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.speciesManager.entity(any)).thenReturn(Species(
      id: randomId(),
      name: "Rainbow",
    ));

    when(appManager.tripManager.list()).thenReturn([]);
    when(appManager.tripManager.deleteMessage(any, any)).thenReturn("Delete");
    when(appManager.tripManager.numberOfCatches(any)).thenReturn(0);

    currentDateTime = dateTime(2022, 10, 15);
    when(appManager.timeManager.currentDateTime).thenReturn(currentDateTime);
  });

  Finder findCatchEvent(WidgetTester tester) {
    return find.byWidgetPredicate((widget) =>
        widget is Container &&
        widget.decoration != null &&
        widget.decoration is BoxDecoration &&
        (widget.decoration as BoxDecoration).color ==
            flattenedAccentColor(Colors.deepOrange));
  }

  void stubSingleCatch([DateTime? dateTime]) {
    when(appManager.catchManager.list()).thenReturn([
      Catch(
        id: randomId(),
        timestamp: Int64(dateTime?.millisecondsSinceEpoch ??
            currentDateTime.millisecondsSinceEpoch),
        speciesId: randomId(),
      ),
    ]);
  }

  void stubSingleTrip([String? tripName]) {
    var trip = Trip(
      id: randomId(),
      startTimestamp: Int64(currentDateTime.millisecondsSinceEpoch),
      endTimestamp: Int64(currentDateTime.millisecondsSinceEpoch),
    );
    if (tripName != null) {
      trip.name = tripName;
    }

    when(appManager.tripManager.list()).thenReturn([trip]);
    when(appManager.tripManager.entity(any)).thenReturn(trip);
  }

  testWidgets("Page rebuilds when entities update", (tester) async {
    var catchManager = CatchManager(appManager.app);
    when(appManager.app.catchManager).thenReturn(catchManager);
    when(appManager.tripManager.list()).thenReturn([]);

    // Load up an empty calendar.
    await pumpContext(tester, (_) => CalendarPage(), appManager: appManager);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(findCatchEvent(tester), findsNothing);

    // Add a catch.
    await catchManager.addOrUpdate(Catch(
      id: randomId(),
      timestamp: Int64(currentDateTime.millisecondsSinceEpoch),
      speciesId: randomId(),
    ));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Verify calendar was updated.
    expect(findCatchEvent(tester), findsOneWidget);
  });

  testWidgets("Today button selects today's date", (tester) async {
    stubSingleCatch();

    await pumpContext(tester, (_) => CalendarPage(), appManager: appManager);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(findCatchEvent(tester), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.chevron_left).last);
    expect(findCatchEvent(tester), findsNothing);

    await tapAndSettle(tester, find.byIcon(Icons.today).last);
    expect(findCatchEvent(tester), findsOneWidget);
  });

  testWidgets("Backwards button changes the month", (tester) async {
    await pumpContext(tester, (_) => CalendarPage(), appManager: appManager);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // 1 for our view, one for SfCalendarView that is hidden.
    expect(find.text("October 2022"), findsNWidgets(2));

    await tapAndSettle(tester, find.byIcon(Icons.chevron_left).last);
    expect(find.text("October 2022"), findsNothing);

    // 1 for our view, one for SfCalendarView that is hidden.
    expect(find.text("September 2022"), findsNWidgets(2));
  });

  testWidgets("Forwards button changes the month", (tester) async {
    await pumpContext(tester, (_) => CalendarPage(), appManager: appManager);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // 1 for our view, one for SfCalendarView that is hidden.
    expect(find.text("October 2022"), findsNWidgets(2));

    await tapAndSettle(tester, find.byIcon(Icons.chevron_right).last);
    expect(find.text("October 2022"), findsNothing);

    // 1 for our view, one for SfCalendarView that is hidden.
    expect(find.text("November 2022"), findsNWidgets(2));
  });

  testWidgets("Event builder exits early for invalid appointments",
      (tester) async {
    var context = await pumpContext(tester, (_) => CalendarPage(),
        appManager: appManager);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    var sfCalendar = tester.widget<SfCalendar>(find.byType(SfCalendar));
    var event = sfCalendar.appointmentBuilder!(
      context,
      CalendarAppointmentDetails(
        DateTime.now(),
        [],
        const Rect.fromLTWH(0, 0, 10, 10),
      ),
    );

    expect(event is Empty, isTrue);
  });

  testWidgets("Event opens trip page", (tester) async {
    stubSingleTrip();

    await pumpContext(tester, (_) => CalendarPage(), appManager: appManager);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("Trip"));
    expect(find.byType(TripPage), findsOneWidget);
  });

  testWidgets("Event opens catch page", (tester) async {
    stubSingleCatch();

    await pumpContext(tester, (_) => CalendarPage(), appManager: appManager);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("Rainbow"));
    expect(find.byType(CatchPage), findsOneWidget);
  });

  testWidgets("Events are populated correctly", (tester) async {
    stubSingleTrip();
    stubSingleCatch();

    await pumpContext(tester, (_) => CalendarPage(), appManager: appManager);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("Trip"), findsOneWidget);
    expect(find.text("Rainbow"), findsOneWidget);
  });

  testWidgets("Month-year picker updates state", (tester) async {
    stubSingleCatch(DateTime(2022, 9, 15));

    await pumpContext(tester, (_) => CalendarPage(), appManager: appManager);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("Rainbow"), findsNothing);

    // 1 for our view, one for SfCalendarView that is hidden.
    await tapAndSettle(tester, find.text("October 2022").last);
    await tapAndSettle(tester, find.text("Sep"));
    await tapAndSettle(tester, find.text("OK"));

    expect(find.text("October 2022"), findsNothing);

    // 1 for our view, one for SfCalendarView that is hidden.
    expect(find.text("September 2022"), findsNWidgets(2));
    expect(find.text("Rainbow"), findsOneWidget);
  });

  testWidgets("If no events on month, day 1 is selected", (tester) async {
    await pumpContext(tester, (_) => CalendarPage(), appManager: appManager);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // 1 for our view, one for SfCalendarView that is hidden.
    await tapAndSettle(tester, find.text("October 2022").last);
    await tapAndSettle(tester, find.text("Sep"));
    await tapAndSettle(tester, find.text("OK"));

    var sfCalendar = tester.widget<SfCalendar>(find.byType(SfCalendar));
    expect(sfCalendar.controller?.selectedDate?.day, 1);
  });

  testWidgets("Catch with unknown species", (tester) async {
    stubSingleCatch();
    when(appManager.speciesManager.entity(any)).thenReturn(null);

    await pumpContext(tester, (_) => CalendarPage(), appManager: appManager);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("Unknown Species"), findsOneWidget);
  });

  testWidgets("Trip with name", (tester) async {
    stubSingleTrip("Trip Name");

    await pumpContext(tester, (_) => CalendarPage(), appManager: appManager);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("Trip Name"), findsOneWidget);
  });
}
