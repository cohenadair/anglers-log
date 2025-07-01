import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/report_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/utils/report_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_managers.dart';
import 'test_utils.dart';

void main() {
  late StubbedManagers managers;
  late ReportManager reportManager;

  void stubTrackingEntities(bool isTracking) {
    when(managers.userPreferenceManager.isTrackingSpecies)
        .thenReturn(isTracking);
    when(managers.userPreferenceManager.isTrackingAnglers)
        .thenReturn(isTracking);
    when(managers.userPreferenceManager.isTrackingBaits).thenReturn(isTracking);
    when(managers.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(isTracking);
    when(managers.userPreferenceManager.isTrackingMethods)
        .thenReturn(isTracking);
    when(managers.userPreferenceManager.isTrackingMoonPhases)
        .thenReturn(isTracking);
    when(managers.userPreferenceManager.isTrackingPeriods)
        .thenReturn(isTracking);
    when(managers.userPreferenceManager.isTrackingSeasons)
        .thenReturn(isTracking);
    when(managers.userPreferenceManager.isTrackingTides).thenReturn(isTracking);
    when(managers.userPreferenceManager.isTrackingWaterClarities)
        .thenReturn(isTracking);
    when(managers.userPreferenceManager.isTrackingGear).thenReturn(isTracking);
  }

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(managers.lib.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);

    stubTrackingEntities(false);
    reportManager = ReportManager(managers.app);
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
    when(managers.localDatabaseManager.fetchAll(any)).thenAnswer((_) {
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
    when(managers.lib.timeManager.currentTimeZone)
        .thenReturn("America/Chicago");

    await reportManager.initialize();

    var reports = reportManager.list();
    expect(reports.length, 3);
    expect(reports[0].timeZone, "America/Chicago");
    expect(reports[1].timeZone, "America/New_York");
    expect(reports[2].timeZone, "America/Chicago");

    verify(managers.localDatabaseManager.insertOrReplace(any, any, any))
        .called(2);
  });
}
