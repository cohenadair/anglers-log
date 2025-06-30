import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/preference_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/stubbed_managers.dart';

class TestPreferenceManager extends PreferenceManager {
  TestPreferenceManager();

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

  Map<Id, int> get testIdMap => idMap<int>("test_id_map");

  set testIdMap(Map<Id, int>? value) => putIdMap("test_id_map", value);

  Id? get testId => id("test_id");

  set testId(Id? value) => putId("test_id", value);
}

void main() {
  late StubbedManagers managers;

  late TestPreferenceManager preferenceManager;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));
    when(managers.localDatabaseManager.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(true));

    when(managers.lib.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);

    preferenceManager = TestPreferenceManager();
  });

  test("Test initialize local data", () async {
    when(managers.localDatabaseManager.fetchAll(preferenceManager.tableName))
        .thenAnswer((_) => Future.value([]));
    await preferenceManager.init();
    expect(preferenceManager.prefs, isEmpty);

    var id0 = randomId();
    var id1 = randomId();

    // Test with all supported data types.
    when(managers.localDatabaseManager.fetchAll(preferenceManager.tableName))
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
    await preferenceManager.init();
    expect(preferenceManager.prefs["bait_custom_entity_ids"],
        [id0.uuid.toString(), id1.uuid.toString()]);
    expect(preferenceManager.prefs["rate_timer_started_at"], 10000);
    expect(preferenceManager.prefs["did_rate_app"], true);
    expect(preferenceManager.prefs["selected_report_id"], id1.uuid.toString());
  });

  test("Setting property to the same value is a no-op", () {
    preferenceManager.testInt = 10;
    verify(managers.localDatabaseManager.insertOrReplace(any, any)).called(1);

    preferenceManager.testInt = 10;
    verifyNever(managers.localDatabaseManager.insertOrReplace(any, any));
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
    verify(managers.localDatabaseManager.insertOrReplace(any, any)).called(1);

    // Setting to the same value is a no-op.
    preferenceManager.testStringList = ["0", "1"];
    verifyNever(managers.localDatabaseManager.insertOrReplace(any, any));

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
    verify(managers.localDatabaseManager.insertOrReplace(any, any)).called(1);

    // Setting to the same value is a no-op.
    preferenceManager.testIdList = [id0, id1];
    verifyNever(managers.localDatabaseManager.insertOrReplace(any, any));

    // Reset to null.
    preferenceManager.testIdList = null;
    expect(preferenceManager.testIdList, isEmpty);
  });

  test("Id map", () {
    expect(preferenceManager.testIdMap, isEmpty);

    var id0 = randomId();
    var id1 = randomId();
    preferenceManager.testIdMap = {
      id0: 5,
      id1: 10,
    };
    expect(preferenceManager.testIdMap, {
      id0: 5,
      id1: 10,
    });
    verify(managers.localDatabaseManager.insertOrReplace(any, any)).called(1);

    // Setting to the same value is a no-op.
    preferenceManager.testIdMap = {
      id0: 5,
      id1: 10,
    };
    verifyNever(managers.localDatabaseManager.insertOrReplace(any, any));

    // Reset to null.
    preferenceManager.testIdMap = null;
    expect(preferenceManager.testIdMap, isEmpty);
  });
}
