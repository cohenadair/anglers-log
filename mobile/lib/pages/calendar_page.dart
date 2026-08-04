import 'dart:async';

import 'package:adair_flutter_lib/l10n/l10n.dart';
import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:adair_flutter_lib/utils/color.dart';
import 'package:adair_flutter_lib/utils/date_format.dart';
import 'package:adair_flutter_lib/utils/date_time.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/utils/page.dart';
import 'package:adair_flutter_lib/widgets/app_bar_dropdown.dart';
import 'package:adair_flutter_lib/widgets/month_year_picker.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/pages/trip_page.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:quiver/strings.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timezone/timezone.dart';

import '../catch_manager.dart';
import '../model/gen/anglers_log.pb.dart';
import '../species_manager.dart';
import '../utils/string_utils.dart';
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
  late final _EventDataSource _dataSource;

  List<_Event> _events = [];

  // onViewChanged fires once on initial mount, in addition to every real
  // navigation. That first call needs no correction (initState already set
  // displayDate/selectedDate directly), so it's skipped to avoid scheduling
  // an unnecessary delayed Timer every time this page opens.
  var _isInitialViewChange = true;

  // onViewChanged can fire more than once for a single swipe (Syncfusion
  // re-syncs its internal state whenever this page's own setState calls
  // rebuild the SfCalendar widget), so only the most recently scheduled
  // timer should ever run. Canceled in dispose() so navigating away
  // mid-swipe doesn't leave a pending Timer behind.
  Timer? _selectFirstEventTimer;

  // Today and the month/year picker both write directly to
  // _controller.displayDate/selectedDate, already selecting the exact day
  // they intend. That write's own rebuild can trigger onViewChanged too
  // (the same re-sync side effect described above), which would otherwise
  // override that selection with the visible month's first event a moment
  // later. Set immediately before either of those writes so the very next
  // onViewChanged call is ignored.
  var _suppressNextViewChanged = false;

  TripManager get _tripManager => TripManager.of(context);

  @override
  void initState() {
    super.initState();

    _controller = CalendarController();
    _controller.displayDate = _controller.selectedDate =
        TimeManager.get.currentDateTime;

    _tripColor = flattenedAccentColor(Colors.green);
    _catchColor = flattenedAccentColor(Colors.deepOrange);

    _events = _loadEvents();
    _dataSource = _EventDataSource(context, _events);
  }

  @override
  void dispose() {
    _selectFirstEventTimer?.cancel();
    super.dispose();
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
        managers: [CatchManager.get, _tripManager],
        onAnyChange: _reloadEvents,
        builder: (context) => Column(children: [_buildCalendar()]),
      ),
    );
  }

  // TODO: This header (today/prev/next buttons + month/year picker) is
  // similar to activity-log's StatsCalendar._buildHeader. Consider
  // extracting a shared widget into adair-flutter-lib if a third consumer
  // appears.
  Widget _buildHeader() {
    return Padding(
      padding: insetsBottomDefault,
      child: Row(
        children: [
          Container(width: paddingDefault),
          Expanded(
            child: InkWell(
              onTap: _showDatePicker,
              child: AppBarDropdown(
                title: DateFormats.localized(
                  L10n.get.lib.dateFormatMonthYearFull,
                ).format(_controller.displayDate!),
                textAlignment: MainAxisAlignment.start,
              ),
            ),
          ),
          Container(width: paddingDefault),
          _buildIconButton(
            Icons.today,
            () => setState(() {
              _suppressNextViewChanged = true;
              _controller.selectedDate = _controller.displayDate =
                  TimeManager.get.currentDateTime;
            }),
          ),
          Container(width: paddingDefault),
          _buildIconButton(Icons.chevron_left, () {
            _controller.backward?.call();
            setState(() {});
          }),
          Container(width: paddingDefault),
          _buildIconButton(Icons.chevron_right, () {
            _controller.forward?.call();
            setState(() {});
          }),
          Container(width: paddingDefault),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    _dataSource.context = context;
    return Expanded(
      child: SfCalendar(
        controller: _controller,
        dataSource: _dataSource,
        view: CalendarView.month,
        headerHeight: _sfCalendarHeaderHeight,
        viewHeaderHeight: _daysOfWeekHeight,
        appointmentBuilder: _buildEvent,
        monthViewSettings: const MonthViewSettings(
          showAgenda: true,
          agendaItemHeight: _agendaItemHeight,
        ),
        onViewChanged: _onViewChanged,
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return MinimumIconButton(
      onTap: onTap,
      icon: icon,
      color: context.colorAppBarContent,
    );
  }

  Widget _buildEvent(BuildContext context, CalendarAppointmentDetails details) {
    if (details.appointments.length != 1) {
      _log.d("Invalid appointment count: ${details.appointments.length}");
      return const SizedBox();
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
            Text(event.subtitle(context), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  List<_Event> _loadEvents() {
    return <_Event>[
      ...CatchManager.get.list().map((e) => _CatchEvent(e, _catchColor)),
      ..._tripManager.list().map((e) => _TripEvent(e, context, _tripColor)),
    ]..sort((lhs, rhs) => lhs.startTimestamp.compareTo(rhs.endTimestamp));
  }

  void _reloadEvents() {
    _events = _loadEvents();
    _dataSource.appointments = _events;
    _dataSource.notifyListeners(CalendarDataSourceAction.reset, _events);
  }

  // SfCalendar fires onViewChanged for BOTH the chevron buttons (via
  // CalendarController.forward()/backward()) and a touch-drag swipe (its
  // internal gesture handler runs the same kind of settle animation) — this
  // is the single place that reacts to either, so their behavior can't
  // drift apart from one another.
  void _onViewChanged(ViewChangedDetails details) {
    if (_isInitialViewChange) {
      _isInitialViewChange = false;
      return;
    }

    if (_suppressNextViewChanged) {
      _suppressNextViewChanged = false;
      return;
    }

    // SfCalendar invokes this callback synchronously right as the settle
    // animation *starts*, not once it finishes, so the header refresh must
    // be deferred until after the current frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });

    // Neither CalendarController.forward()/backward() nor the internal
    // touch-swipe handler expose a completion callback for their ~250ms
    // settle animation, so this waits slightly longer than that before
    // reading the now-settled displayDate and jumping to the new month's
    // first event. Writing to the controller before the animation finishes
    // corrupts its internal swipe state (this was the cause of the
    // "missing dots" / mismatched-day bugs).
    //
    // CAUTION: 250ms is an internal Syncfusion implementation detail, not
    // part of its public API (syncfusion_flutter_calendar-28.2.12). If a
    // future package upgrade changes that duration, this hardcoded delay
    // may need to be adjusted to match, or the race this works around will
    // return.
    _selectFirstEventTimer?.cancel();
    _selectFirstEventTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _selectFirstEvent(_controller.displayDate);
      }
    });
  }

  void _showDatePicker() async {
    var pickedDateTime = await showMonthYearPicker(
      context,
      initialDate: _controller.displayDate,
    );
    // Note: this guard is a defensive check that cannot be triggered in
    // widget tests since widget disposal and async completion are
    // serialized by the test framework.
    if (!mounted) {
      return;
    }
    if (pickedDateTime != null) {
      _suppressNextViewChanged = true;
      _selectFirstEvent(pickedDateTime);
    }
  }

  void _selectFirstEvent(DateTime? dateTime) {
    if (dateTime == null) {
      return;
    }

    var day = _events
        .firstWhereOrNull(
          (e) => isSameYearAndMonth(dateTime!, e.startDateTime(context)),
        )
        ?.startDateTime(context)
        .day;
    dateTime = TimeManager.get.dateTimeToTz(
      DateTime(dateTime.year, dateTime.month, day ?? 1),
    );
    _controller.selectedDate = _controller.displayDate = dateTime;

    setState(() {});
  }
}

class _EventDataSource extends CalendarDataSource {
  BuildContext context;

  _EventDataSource(this.context, List<_Event> source) {
    appointments = source;
  }

  _Event _eventAt(int index) => appointments![index];

  @override
  DateTime getStartTime(int index) => TimeManager.get.dateTime(
    _eventAt(index).startTimestamp,
    _eventAt(index).timeZone,
  );

  @override
  DateTime getEndTime(int index) => TimeManager.get.dateTime(
    _eventAt(index).endTimestamp,
    _eventAt(index).timeZone,
  );

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
