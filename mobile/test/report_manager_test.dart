import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/report_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/report_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late ReportManager reportManager;

  void stubTrackingEntities(bool isTracking) {
    when(appManager.userPreferenceManager.isTrackingSpecies)
        .thenReturn(isTracking);
    when(appManager.userPreferenceManager.isTrackingAnglers)
        .thenReturn(isTracking);
    when(appManager.userPreferenceManager.isTrackingBaits)
        .thenReturn(isTracking);
    when(appManager.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(isTracking);
    when(appManager.userPreferenceManager.isTrackingMethods)
        .thenReturn(isTracking);
    when(appManager.userPreferenceManager.isTrackingMoonPhases)
        .thenReturn(isTracking);
    when(appManager.userPreferenceManager.isTrackingPeriods)
        .thenReturn(isTracking);
    when(appManager.userPreferenceManager.isTrackingSeasons)
        .thenReturn(isTracking);
    when(appManager.userPreferenceManager.isTrackingTides)
        .thenReturn(isTracking);
    when(appManager.userPreferenceManager.isTrackingWaterClarities)
        .thenReturn(isTracking);
    when(appManager.userPreferenceManager.isTrackingGear)
        .thenReturn(isTracking);
  }

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    stubTrackingEntities(false);
    reportManager = ReportManager(appManager.app);
  });

  testWidgets("displayName for default reports", (tester) async {
    var context = await buildContext(tester);
    expect(
      reportManager.displayName(context, Report(id: reportIdPersonalBests)),
      "Personal Bests",
    );
  });

  testWidgets("displayName falls back on report value", (tester) async {
    var context = await buildContext(tester);
    expect(
      reportManager.displayName(
        context,
        Report(
          id: randomId(),
          name: "Test Report",
        ),
      ),
      "Test Report",
    );
  });

  test("entity returns default report", () {
    var pb = reportManager.entity(reportIdPersonalBests);
    expect(pb, isNotNull);
    expect(pb!.id, reportIdPersonalBests);
  });

  test("entity returns custom report", () async {
    expect(reportManager.entity(randomId()), isNull);

    var reportId = randomId();
    await reportManager.addOrUpdate(Report(
      id: reportId,
      name: "Test Report",
    ));

    expect(reportManager.entity(reportId), isNotNull);
  });

  test("defaultReports includes all trackable reports", () {
    stubTrackingEntities(true);
    expect(reportManager.defaultReports.length, 15);
  });

  test("defaultReports excludes all trackable reports", () {
    stubTrackingEntities(false);
    expect(reportManager.defaultReports.length, 3);
  });

  test("initialize updates report time zones", () async {
    var reportId1 = randomId();
    var reportId2 = randomId();
    var reportId3 = randomId();
    when(appManager.localDatabaseManager.fetchAll(any)).thenAnswer((_) {
      return Future.value([
        {
          "id": reportId1.uint8List,
          "bytes": Report(
            id: reportId1,
          ).writeToBuffer(),
        },
        {
          "id": reportId2.uint8List,
          "bytes": Report(
            id: reportId2,
            timeZone: defaultTimeZone,
          ).writeToBuffer(),
        },
        {
          "id": reportId3.uint8List,
          "bytes": Report(
            id: reportId3,
          ).writeToBuffer(),
        },
      ]);
    });
    when(appManager.timeManager.currentTimeZone).thenReturn("America/Chicago");

    await reportManager.initialize();

    var reports = reportManager.list();
    expect(reports.length, 3);
    expect(reports[0].timeZone, "America/Chicago");
    expect(reports[1].timeZone, "America/New_York");
    expect(reports[2].timeZone, "America/Chicago");

    verify(appManager.localDatabaseManager.insertOrReplace(any, any, any))
        .called(2);
  });
}
