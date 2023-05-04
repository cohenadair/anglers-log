import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/trip_page.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/utils/color_utils.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/app_bar_dropdown.dart';
import 'package:mobile/widgets/month_year_picker.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timezone/timezone.dart';

import '../catch_manager.dart';
import '../log.dart';
import '../model/gen/anglerslog.pb.dart';
import '../species_manager.dart';
import '../widgets/button.dart';
import 'catch_page.dart';

class CalendarPage extends StatefulWidget {
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const _appBarBottomHeight = 40.0;
  static const _daysOfWeekHeight = 40.0;
  static const _sfCalendarHeaderHeight = 0.0;
  static const _agendaRadius = 6.0;
  static const _agendaItemHeight = 50.0;

  final _log = const Log("CalendarPage");

  late final CalendarController _controller;
  late final Color _tripColor;
  late final Color _catchColor;

  List<_Event> _events = [];

  CatchManager get _catchManager => CatchManager.of(context);

  TimeManager get _timeManager => TimeManager.of(context);

  TripManager get _tripManager => TripManager.of(context);

  @override
  void initState() {
    super.initState();

    _controller = CalendarController();
    _controller.displayDate =
        _controller.selectedDate = _timeManager.currentDateTime;

    _tripColor = flattenedAccentColor(Colors.green);
    _catchColor = flattenedAccentColor(Colors.deepOrange);

    _events = _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(_appBarBottomHeight),
          child: _buildHeader(),
        ),
      ),
      body: EntityListenerBuilder(
        managers: [
          _catchManager,
          _tripManager,
        ],
        onAnyChange: () => _events = _loadEvents(),
        builder: (context) => Column(children: [_buildCalendar()]),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: insetsBottomDefault,
      child: Row(
        children: [
          const HorizontalSpace(paddingDefault),
          Expanded(
            child: InkWell(
              onTap: _showDatePicker,
              child: AppBarDropdown(
                title: DateFormat(monthYearFormat)
                    .format(_controller.displayDate!),
                textAlignment: MainAxisAlignment.start,
              ),
            ),
          ),
          const HorizontalSpace(paddingDefault),
          _buildIconButton(
            Icons.today,
            () => _controller.selectedDate =
                _controller.displayDate = _timeManager.currentDateTime,
          ),
          const HorizontalSpace(paddingDefault),
          _buildIconButton(
            Icons.chevron_left,
            () {
              _controller.backward?.call();
              _selectFirstEvent(_controller.displayDate);
            },
          ),
          const HorizontalSpace(paddingDefault),
          _buildIconButton(
            Icons.chevron_right,
            () {
              _controller.forward?.call();
              _selectFirstEvent(_controller.displayDate);
            },
          ),
          const HorizontalSpace(paddingDefault),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Expanded(
      child: SfCalendar(
        controller: _controller,
        dataSource: _EventDataSource(context, _events),
        view: CalendarView.month,
        headerHeight: _sfCalendarHeaderHeight,
        viewHeaderHeight: _daysOfWeekHeight,
        appointmentBuilder: _buildEvent,
        monthViewSettings: const MonthViewSettings(
          showAgenda: true,
          agendaItemHeight: _agendaItemHeight,
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return MinimumIconButton(
      onTap: () {
        onTap();
        setState(() {});
      },
      icon: icon,
      color: context.colorAppBarContent,
    );
  }

  Widget _buildEvent(BuildContext context, CalendarAppointmentDetails details) {
    if (details.appointments.length != 1) {
      _log.d("Invalid appointment count: ${details.appointments.length}");
      return const Empty();
    }

    var event = details.appointments.first as _Event;

    return InkWell(
      onTap: () {
        if (event is _TripEvent) {
          push(context, TripPage(event.trip));
        } else if (event is _CatchEvent) {
          push(context, CatchPage(event.cat));
        } else {
          _log.w("Invalid event type: ${event.runtimeType}");
        }
      },
      child: Container(
        padding: insetsSmall,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(_agendaRadius)),
          color: event.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              event.title(context),
              style: const TextStyle(fontWeight: fontWeightBold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              event.subtitle(context),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  List<_Event> _loadEvents() {
    return <_Event>[
      ..._catchManager.list().map((e) => _CatchEvent(e, _catchColor)),
      ..._tripManager.list().map((e) => _TripEvent(e, context, _tripColor)),
    ]..sort((lhs, rhs) => lhs.startTimestamp.compareTo(rhs.endTimestamp));
  }

  void _showDatePicker() async {
    var pickedDateTime = await showMonthYearPicker(context);
    if (pickedDateTime != null) {
      _selectFirstEvent(pickedDateTime);
    }
  }

  void _selectFirstEvent(DateTime? dateTime) {
    if (dateTime == null) {
      return;
    }

    var day = _events
        .firstWhereOrNull(
            (e) => isSameYearAndMonth(dateTime!, e.startDateTime(context)))
        ?.startDateTime(context)
        .day;
    dateTime = _timeManager
        .toTZDateTime(DateTime(dateTime.year, dateTime.month, day ?? 1));
    _controller.selectedDate = _controller.displayDate = dateTime;

    setState(() {});
  }
}

class _EventDataSource extends CalendarDataSource {
  final BuildContext context;

  TimeManager get _timeManager => TimeManager.of(context);

  _EventDataSource(this.context, List<_Event> source) {
    appointments = source;
  }

  _Event _eventAt(int index) => appointments![index];

  @override
  DateTime getStartTime(int index) => _timeManager.dateTime(
      _eventAt(index).startTimestamp, _eventAt(index).timeZone);

  @override
  DateTime getEndTime(int index) => _timeManager.dateTime(
      _eventAt(index).endTimestamp, _eventAt(index).timeZone);

  @override
  String getSubject(int index) => _eventAt(index).title(context);

  @override
  Color getColor(int index) => _eventAt(index).color;

  @override
  bool isAllDay(int index) => _eventAt(index).isAllDay;
}

abstract class _Event {
  final String timeZone;
  final int startTimestamp;
  final int endTimestamp;
  final Color color;
  final bool isAllDay;

  String title(BuildContext context);

  String subtitle(BuildContext context);

  TZDateTime startDateTime(BuildContext context);

  _Event({
    required this.timeZone,
    required this.color,
    required this.startTimestamp,
    required this.endTimestamp,
    required this.isAllDay,
  });
}

class _CatchEvent extends _Event {
  final Catch cat;

  _CatchEvent(this.cat, Color color)
      : super(
          timeZone: cat.timeZone,
          color: color,
          startTimestamp: cat.timestamp.toInt(),
          endTimestamp: cat.timestamp.toInt(),
          isAllDay: false,
        );

  @override
  String title(BuildContext context) {
    return SpeciesManager.of(context).entity(cat.speciesId)?.name ??
        Strings.of(context).unknownSpecies;
  }

  @override
  String subtitle(BuildContext context) {
    return formatTimeMillis(context, cat.timestamp, cat.timeZone);
  }

  @override
  TZDateTime startDateTime(BuildContext context) => cat.dateTime(context);
}

class _TripEvent extends _Event {
  final Trip trip;

  _TripEvent(this.trip, BuildContext context, Color color)
      : super(
          timeZone: trip.timeZone,
          color: color,
          startTimestamp: trip.startTimestamp.toInt(),
          endTimestamp: trip.endTimestamp.toInt(),
          isAllDay: trip.startDateTime(context).isMidnight,
        );

  @override
  String title(BuildContext context) {
    return isEmpty(trip.name)
        ? Strings.of(context).calendarPageTripLabel
        : trip.name;
  }

  @override
  String subtitle(BuildContext context) {
    return trip.elapsedDisplayValue(context);
  }

  @override
  TZDateTime startDateTime(BuildContext context) => trip.startDateTime(context);
}
