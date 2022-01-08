import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/preference_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_app_manager.dart';

class TestPreferenceManager extends PreferenceManager {
  bool firestoreEnabled = false;

  TestPreferenceManager(AppManager appManager) : super(appManager);

  @override
  String get tableName => "test_preference";

  Map<String, dynamic> get prefs => preferences;

  int? get testInt => preferences["test_int"];

  set testInt(int? value) => put("test_int", value);

  List<String> get testStringList => stringList("test_string_list");

  set testStringList(List<String>? value) =>
      putStringList("test_string_list", value);

  List<Id> get testIdList => idList("test_id_list");

  set testIdList(List<Id>? value) => putIdCollection("test_id_list", value);

  Id? get testId => id("test_id");

  set testId(Id? value) => putId("test_id", value);
}

void main() {
  late StubbedAppManager appManager;

  late TestPreferenceManager preferenceManager;

  setUp(() async {
    appManager = StubbedAppManager();

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(appManager.localDatabaseManager.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(true));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    preferenceManager = TestPreferenceManager(appManager.app);
  });

  test("Test initialize local data", () async {
    when(appManager.localDatabaseManager.fetchAll(preferenceManager.tableName))
        .thenAnswer((_) => Future.value([]));
    await preferenceManager.initialize();
    expect(preferenceManager.prefs, isEmpty);

    var id0 = randomId();
    var id1 = randomId();

    // Test with all supported data types.
    when(appManager.localDatabaseManager.fetchAll(preferenceManager.tableName))
        .thenAnswer(
      (_) => Future.value(
        [
          {
            "id": "bait_custom_entity_ids",
            "value": jsonEncode([id0.uuid.toString(), id1.uuid.toString()])
          },
          {"id": "rate_timer_started_at", "value": jsonEncode(10000)},
          {"id": "did_rate_app", "value": jsonEncode(true)},
          {
            "id": "selected_report_id",
            "value": jsonEncode(id1.uuid.toString())
          },
        ],
      ),
    );
    await preferenceManager.initialize();
    expect(preferenceManager.prefs["bait_custom_entity_ids"],
        [id0.uuid.toString(), id1.uuid.toString()]);
    expect(preferenceManager.prefs["rate_timer_started_at"], 10000);
    expect(preferenceManager.prefs["did_rate_app"], true);
    expect(preferenceManager.prefs["selected_report_id"], id1.uuid.toString());
  });

  test("Setting property to the same value is a no-op", () {
    preferenceManager.testInt = 10;
    verify(appManager.localDatabaseManager.insertOrReplace(any, any)).called(1);

    preferenceManager.testInt = 10;
    verifyNever(appManager.localDatabaseManager.insertOrReplace(any, any));
  });

  test("Setting property to null removes it from data map", () {
    preferenceManager.testInt = 10;
    expect(preferenceManager.prefs, isNotEmpty);

    preferenceManager.testInt = null;
    expect(preferenceManager.prefs, isEmpty);
  });

  testWidgets("Setting property notifies listener", (tester) async {
    var called = false;
    var sub = preferenceManager.stream.listen((_) {
      called = true;
    });

    await tester.runAsync(() async {
      preferenceManager.testInt = 10;

      // Give some time for listeners to to be invoked.
      await Future.delayed(const Duration(milliseconds: 50));

      expect(called, isTrue);
      sub.cancel();
    });
  });

  test("String list", () {
    expect(preferenceManager.testStringList, isEmpty);
    preferenceManager.testStringList = ["0", "1"];
    expect(preferenceManager.testStringList, ["0", "1"]);
    verify(appManager.localDatabaseManager.insertOrReplace(any, any)).called(1);

    // Setting to the same value is a no-op.
    preferenceManager.testStringList = ["0", "1"];
    verifyNever(appManager.localDatabaseManager.insertOrReplace(any, any));

    // Reset to null.
    preferenceManager.testStringList = null;
    expect(preferenceManager.testStringList, isEmpty);
  });

  test("Id", () {
    // Doesn't exist in map.
    expect(preferenceManager.testId, isNull);

    var id = randomId();
    preferenceManager.testId = id;
    expect(preferenceManager.testId, id);

    // Reset to null.
    preferenceManager.testId = null;
    expect(preferenceManager.testId, isNull);
  });

  test("Id list", () {
    expect(preferenceManager.testIdList, isEmpty);

    var id0 = randomId();
    var id1 = randomId();
    preferenceManager.testIdList = [id0, id1];
    expect(preferenceManager.testIdList, [id0, id1]);
    verify(appManager.localDatabaseManager.insertOrReplace(any, any)).called(1);

    // Setting to the same value is a no-op.
    preferenceManager.testIdList = [id0, id1];
    verifyNever(appManager.localDatabaseManager.insertOrReplace(any, any));

    // Reset to null.
    preferenceManager.testIdList = null;
    expect(preferenceManager.testIdList, isEmpty);
  });
}
