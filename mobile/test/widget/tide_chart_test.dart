import 'package:fixnum/fixnum.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/widgets/tide_chart.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.userPreferenceManager.tideHeightSystem)
        .thenReturn(MeasurementSystem.metric);
  });

  Tide defaultTide() {
    return Tide(
      type: TideType.incoming,
      height: Tide_Height(
        timestamp: Int64(1626937200000), // 3:00 AM
        value: 0.025,
      ),
      daysHeights: [
        Tide_Height(
          timestamp: Int64(3000),
          value: 0.015,
        ),
        Tide_Height(
          timestamp: Int64(1626937200000), // 3:00 AM
          value: 0.025,
        ),
        Tide_Height(
          timestamp: Int64(7000),
          value: 0.035,
        ),
        Tide_Height(
          timestamp: Int64(9000),
          value: 0.045,
        ),
      ],
      // 3:00 AM
      firstLowHeight: Tide_Height(timestamp: Int64(1626937200000)),
      firstHighHeight: Tide_Height(timestamp: Int64(1626937200000)),
    );
  }

  testWidgets("Is empty when dayHeights is empty", (tester) async {
    await pumpContext(tester, (context) => TideChart(Tide()));
    expect(find.byType(Empty), findsOneWidget);
    expect(find.byType(StreamBuilder), findsNothing);
  });

  testWidgets("Chart includes extremes text", (tester) async {
    await pumpContext(
      tester,
      (context) => TideChart(defaultTide()),
      appManager: appManager,
    );

    var tooltipText = tester
        .widget<LineChart>(find.byType(LineChart))
        .data
        .lineTouchData
        .touchTooltipData
        .getTooltipItems([])
        .first
        ?.text;
    expect(tooltipText, "Incoming, 0.025 m at 3:00 AM");

    // Height labels (6) + extremes (2).
    expect(find.byType(Text), findsNWidgets(8));

    expect(find.text("Low: 3:00 AM"), findsOneWidget);
    expect(find.text("High: 3:00 AM"), findsOneWidget);
  });

  testWidgets("Extremes text is empty", (tester) async {
    await pumpContext(
      tester,
      (context) => TideChart(
        defaultTide()
          ..clearFirstLowHeight()
          ..clearFirstHighHeight(),
      ),
      appManager: appManager,
    );
    // Height labels (6) + extremes (0).
    expect(find.byType(Text), findsNWidgets(6));
  });

  testWidgets("Axis labels", (tester) async {
    await pumpContext(
      tester,
      (context) => TideChart(Tide(
        type: TideType.incoming,
        height: Tide_Height(
          timestamp: Int64(1626937200000), // 3:00 AM
          value: 0.025,
        ),
        daysHeights: [
          Tide_Height(
            timestamp: Int64(1626933600000), // Midnight
            value: -1,
          ),
          Tide_Height(
            timestamp: Int64(1626937200000), // 3:00 AM
            value: 0.025,
          ),
          Tide_Height(
            timestamp: Int64(1626973200000), // 1:00 PM
            value: 0.035,
          ),
          Tide_Height(
            timestamp: Int64(1627020000000), // Midnight
            value: 1,
          ),
        ],
        // 3:00 AM
        firstLowHeight: Tide_Height(timestamp: Int64(1626937200000)),
        firstHighHeight: Tide_Height(timestamp: Int64(1626937200000)),
      )),
      appManager: appManager,
    );
    expect(find.text("8:00 AM"), findsOneWidget);
    expect(find.text("8:00 PM"), findsOneWidget);
    expect(find.text("1 m"), findsOneWidget);
    expect(find.text("0.5 m"), findsOneWidget);
    expect(find.text("0 m"), findsOneWidget);
    expect(find.text("-0.5 m"), findsOneWidget);
    expect(find.text("-1 m"), findsOneWidget);
  });
}
