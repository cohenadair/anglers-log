import 'package:adair_flutter_lib/utils/color.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/calendar_page.dart';
import 'package:mobile/pages/catch_page.dart';
import 'package:mobile/pages/trip_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timezone/timezone.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;
  late TZDateTime currentDateTime;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.catchManager.list()).thenReturn([]);
    when(managers.catchManager.deleteMessage(any, any)).thenReturn("Delete");

    when(
      managers.imageManager.save(any, compress: anyNamed("compress")),
    ).thenAnswer((_) => Future.value([]));

    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);

    when(
      managers.localDatabaseManager.insertOrReplace(any, any),
    ).thenAnswer((_) => Future.value(true));

    when(
      managers.speciesManager.entity(any),
    ).thenReturn(Species(id: randomId(), name: "Rainbow"));

    when(managers.tripManager.list()).thenReturn([]);
    when(managers.tripManager.deleteMessage(any, any)).thenReturn("Delete");
    when(managers.tripManager.numberOfCatches(any)).thenReturn(0);

    when(managers.userPreferenceManager.autoAddCatchesToTrip).thenReturn(false);

    currentDateTime = dateTime(2022, 10, 15);
    when(managers.lib.timeManager.currentDateTime).thenReturn(currentDateTime);
  });

  Finder findCatchEvent(WidgetTester tester) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration != null &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color ==
              flattenedAccentColor(Colors.deepOrange),
    );
  }

  void stubSingleCatch([DateTime? dateTime]) {
    when(managers.catchManager.list()).thenReturn([
      Catch(
        id: randomId(),
        timestamp: Int64(
          dateTime?.millisecondsSinceEpoch ??
              currentDateTime.millisecondsSinceEpoch,
        ),
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

    when(managers.tripManager.list()).thenReturn([trip]);
    when(managers.tripManager.entity(any)).thenReturn(trip);
  }

  testWidgets("Page rebuilds when entities update", (tester) async {
    CatchManager.reset();
    when(managers.tripManager.list()).thenReturn([]);

    // Load up an empty calendar.
    await pumpContext(tester, (_) => CalendarPage());
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(findCatchEvent(tester), findsNothing);

    // Add a catch.
    await CatchManager.get.addOrUpdate(
      Catch(
        id: randomId(),
        timestamp: Int64(currentDateTime.millisecondsSinceEpoch),
        speciesId: randomId(),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    // Verify calendar was updated.
    expect(findCatchEvent(tester), findsOneWidget);
  });

  testWidgets("Today button selects today's date", (tester) async {
    stubSingleCatch();

    await pumpContext(tester, (_) => CalendarPage());
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(findCatchEvent(tester), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(Icons.chevron_left).last);
    expect(findCatchEvent(tester), findsNothing);

    await tapAndSettle(tester, find.byIcon(Icons.today).last);
    expect(findCatchEvent(tester), findsOneWidget);
  });

  testWidgets("Today button keeps today selected, not the first event", (
    tester,
  ) async {
    // A catch elsewhere in October, not on the 15th (today), so "first
    // event of October" != today.
    stubSingleCatch(DateTime(2022, 10, 3));

    await pumpContext(tester, (_) => CalendarPage());
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byIcon(Icons.chevron_left).last);
    await tapAndSettle(tester, find.byIcon(Icons.today).last);

    // Wait out any delayed selection timer that might override this.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    var sfCalendar = tester.widget<SfCalendar>(find.byType(SfCalendar));
    expect(sfCalendar.controller?.selectedDate?.day, 15);
  });

  testWidgets("Backwards button changes the month", (tester) async {
    await pumpContext(tester, (_) => CalendarPage());
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // 1 for our view, one for SfCalendarView that is hidden.
    expect(find.text("October 2022"), findsNWidgets(2));

    await tapAndSettle(tester, find.byIcon(Icons.chevron_left).last);
    expect(find.text("October 2022"), findsNothing);

    // 1 for our view, one for SfCalendarView that is hidden.
    expect(find.text("September 2022"), findsNWidgets(2));
  });

  testWidgets("Forwards button changes the month", (tester) async {
    await pumpContext(tester, (_) => CalendarPage());
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // 1 for our view, one for SfCalendarView that is hidden.
    expect(find.text("October 2022"), findsNWidgets(2));

    await tapAndSettle(tester, find.byIcon(Icons.chevron_right).last);
    expect(find.text("October 2022"), findsNothing);

    // 1 for our view, one for SfCalendarView that is hidden.
    expect(find.text("November 2022"), findsNWidgets(2));
  });

  testWidgets("Forwards button rolls over into the next year", (tester) async {
    await pumpContext(tester, (_) => CalendarPage());
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("October 2022").last);
    await tapAndSettle(tester, find.text("Dec"));
    await tapAndSettle(tester, find.text("OK"));
    expect(find.text("December 2022"), findsNWidgets(2));

    await tapAndSettle(tester, find.byIcon(Icons.chevron_right).last);
    expect(find.text("December 2022"), findsNothing);
    expect(find.text("January 2023"), findsNWidgets(2));
  });

  testWidgets("Backwards button rolls over into the previous year", (
    tester,
  ) async {
    await pumpContext(tester, (_) => CalendarPage());
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("October 2022").last);
    await tapAndSettle(tester, find.text("Jan"));
    await tapAndSettle(tester, find.text("OK"));
    expect(find.text("January 2022"), findsNWidgets(2));

    await tapAndSettle(tester, find.byIcon(Icons.chevron_left).last);
    expect(find.text("January 2022"), findsNothing);
    expect(find.text("December 2021"), findsNWidgets(2));
  });

  testWidgets("Backwards button selects the event's day in the new month", (
    tester,
  ) async {
    stubSingleCatch(DateTime(2022, 9, 20));

    await pumpContext(tester, (_) => CalendarPage());
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(findCatchEvent(tester), findsNothing);

    await tapAndSettle(tester, find.byIcon(Icons.chevron_left).last);

    var sfCalendar = tester.widget<SfCalendar>(find.byType(SfCalendar));
    expect(sfCalendar.controller?.displayDate?.month, 9);
    expect(sfCalendar.controller?.selectedDate?.day, 20);
    expect(findCatchEvent(tester), findsOneWidget);
  });

  testWidgets("Drag swipe selects the event's day in the new month", (
    tester,
  ) async {
    stubSingleCatch(DateTime(2022, 9, 20));

    await pumpContext(tester, (_) => CalendarPage());
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(findCatchEvent(tester), findsNothing);

    await tester.drag(find.byType(SfCalendar), const Offset(600, 0));
    await tester.pumpAndSettle();

    var sfCalendar = tester.widget<SfCalendar>(find.byType(SfCalendar));
    expect(sfCalendar.controller?.displayDate?.month, 9);
    expect(sfCalendar.controller?.selectedDate?.day, 20);
    expect(findCatchEvent(tester), findsOneWidget);
  });

  testWidgets("Header updates after a real drag swipe", (tester) async {
    await pumpContext(tester, (_) => CalendarPage());
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    // 1 for our view, one for SfCalendarView that is hidden.
    expect(find.text("October 2022"), findsNWidgets(2));

    await tester.drag(find.byType(SfCalendar), const Offset(600, 0));
    await tester.pumpAndSettle();

    expect(find.text("October 2022"), findsNothing);
    expect(find.text("September 2022"), findsNWidgets(2));
  });

  testWidgets("Event builder exits early for invalid appointments", (
    tester,
  ) async {
    var context = await pumpContext(tester, (_) => CalendarPage());
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

    expect(event is SizedBox, isTrue);
  });

  testWidgets("Event opens trip page", (tester) async {
    stubSingleTrip();

    await pumpContext(tester, (_) => CalendarPage());
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("Trip"));
    expect(find.byType(TripPage), findsOneWidget);
  });

  testWidgets("Event opens catch page", (tester) async {
    stubSingleCatch();

    await pumpContext(tester, (_) => CalendarPage());
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.text("Rainbow"));
    expect(find.byType(CatchPage), findsOneWidget);
  });

  testWidgets("Events are populated correctly", (tester) async {
    stubSingleTrip();
    stubSingleCatch();

    await pumpContext(tester, (_) => CalendarPage());
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("Trip"), findsOneWidget);
    expect(find.text("Rainbow"), findsOneWidget);
  });

  testWidgets("Month-year picker opens to the visible month, not today", (
    tester,
  ) async {
    await pumpContext(tester, (_) => CalendarPage());
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    await tapAndSettle(tester, find.byIcon(Icons.chevron_left).last);
    expect(find.text("September 2022"), findsNWidgets(2));

    // 1 for our view, one for SfCalendarView that is hidden.
    await tapAndSettle(tester, find.text("September 2022").last);
    await tapAndSettle(tester, find.text("OK"));

    // Confirming without picking a different month/year should leave the
    // calendar on September — proving the picker opened there, not on
    // today's month (October).
    expect(find.text("October 2022"), findsNothing);
    expect(find.text("September 2022"), findsNWidgets(2));
  });

  testWidgets("Month-year picker updates state", (tester) async {
    stubSingleCatch(DateTime(2022, 9, 15));

    await pumpContext(tester, (_) => CalendarPage());
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
    await pumpContext(tester, (_) => CalendarPage());
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
    when(managers.speciesManager.entity(any)).thenReturn(null);

    await pumpContext(tester, (_) => CalendarPage());
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("Unknown Species"), findsOneWidget);
  });

  testWidgets("Trip with name", (tester) async {
    stubSingleTrip("Trip Name");

    await pumpContext(tester, (_) => CalendarPage());
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.text("Trip Name"), findsOneWidget);
  });
}
