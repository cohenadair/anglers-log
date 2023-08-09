import 'package:fixnum/fixnum.dart';
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
      firstLowTimestamp: Int64(1626937200000),
      // 3:00 AM,
      firstHighTimestamp: Int64(1626937200000), // 3:00 AM,
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
      (context) => TideChart(
        defaultTide(),
        isSummary: true,
      ),
      appManager: appManager,
    );

    expect(find.text("Incoming Tide, 0.025 m at 3:00 AM"), findsOneWidget);
    expect(find.text("Low: 3:00 AM; High: 3:00 AM"), findsOneWidget);
  });

  testWidgets("Chart excludes extremes text", (tester) async {
    await pumpContext(
      tester,
      (context) => TideChart(
        defaultTide(),
        isSummary: false,
      ),
      appManager: appManager,
    );

    expect(find.text("Incoming, 0.025 m at 3:00 AM"), findsOneWidget);
    expect(find.text("Low: 3:00 AM; High: 3:00 AM"), findsNothing);
  });

  testWidgets("Extremes text is empty", (tester) async {
    await pumpContext(
      tester,
      (context) => TideChart(
        defaultTide()
          ..clearFirstLowTimestamp()
          ..clearFirstHighTimestamp(),
        isSummary: true,
      ),
      appManager: appManager,
    );
    expect(find.byType(Text), findsOneWidget);
    expect(find.byType(Empty), findsOneWidget);
  });
}
