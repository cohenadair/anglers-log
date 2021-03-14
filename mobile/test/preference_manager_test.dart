import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/preference_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mock_app_manager.dart';
import 'test_utils.dart';

class TestPreferenceManager extends PreferenceManager {
  bool firestoreEnabled = false;

  TestPreferenceManager(AppManager appManager) : super(appManager);

  @override
  bool get enableFirestore => firestoreEnabled;

  @override
  String get firestoreDocPath => "test/path";

  @override
  String get tableName => "test_preference";

  Map<String, dynamic> get prefs => preferences;

  void clearLocal() => clearLocalData();

  int get testInt => preferences["test_int"];

  set testInt(int value) => put("test_int", value);

  List<String> get testStringList => stringList("test_string_list");

  set testStringList(List<String> value) =>
      putStringList("test_string_list", value);

  List<Id> get testIdList => idList("test_id_list");

  set testIdList(List<Id> value) => putIdList("test_id_list", value);

  Id get testId => id("test_id");

  set testId(Id value) => putId("test_id", value);

  @override
  void onUpgradeToPro() {
    // TODO: implement onUpgradeToPro
  }
}

void main() {
  MockAppManager appManager;

  TestPreferenceManager preferenceManager;

  setUp(() async {
    appManager = MockAppManager(
      mockAppPreferenceManager: true,
      mockAuthManager: true,
      mockLocalDatabaseManager: true,
      mockSubscriptionManager: true,
      mockFirestoreWrapper: true,
    );

    var stream = MockStream<AuthState>();
    when(stream.listen(any)).thenReturn(null);
    when(appManager.mockAuthManager.stream).thenAnswer((_) => stream);

    when(appManager.mockLocalDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value());

    when(appManager.mockSubscriptionManager.stream)
        .thenAnswer((_) => MockStream<void>());
    when(appManager.mockSubscriptionManager.isPro).thenReturn(false);

    preferenceManager = TestPreferenceManager(appManager);
  });

  test("Test initialize local data", () async {
    when(appManager.mockAppPreferenceManager.lastLoggedInUserId)
        .thenReturn(null);
    when(appManager.mockAuthManager.userId).thenReturn("ID");

    when(appManager.mockLocalDatabaseManager
            .fetchAll(preferenceManager.tableName))
        .thenAnswer((_) => Future.value([]));
    await preferenceManager.initialize();
    expect(preferenceManager.prefs, isEmpty);

    var id0 = randomId();
    var id1 = randomId();

    // Test with all supported data types.
    when(appManager.mockLocalDatabaseManager
            .fetchAll(preferenceManager.tableName))
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

  test("Initialize Firestore data", () async {
    when(appManager.mockSubscriptionManager.isPro).thenReturn(true);

    var snapshot = MockDocumentSnapshot();
    when(snapshot.exists).thenReturn(false);

    var doc = MockDocumentReference();
    when(doc.get()).thenAnswer((_) => Future.value(snapshot));
    when(appManager.mockFirestoreWrapper.doc(any)).thenReturn(doc);

    var stream = MockStream<MockDocumentSnapshot>();
    // Mimic Firebase's behaviour by invoking listener immediately.
    when(stream.listen(any)).thenAnswer(
        (invocation) => invocation.positionalArguments.first(snapshot));
    when(doc.snapshots()).thenAnswer((_) => stream);

    preferenceManager.firestoreEnabled = true;

    // Setup Firestore listener.
    await preferenceManager.initialize();
    expect(preferenceManager.prefs, isEmpty);

    // In this test, we assume Firestore listeners work as expected, and we
    // capture the listener function passed to snapshots().listen and invoke it
    // manually.
    var result = verify(stream.listen(captureAny));
    result.called(1);

    var listener = result.captured.first;

    // Valid data.
    when(snapshot.data()).thenReturn({
      "test_int": 10,
    });
    listener(snapshot);
    expect(preferenceManager.prefs, isNotEmpty);
    expect(preferenceManager.testInt, 10);

    // No data passed to listener doesn't change the data map.
    when(snapshot.data()).thenReturn(null);
    listener(snapshot);
    expect(preferenceManager.prefs, isNotEmpty);
    expect(preferenceManager.testInt, 10);

    // Empty data clears data map.
    when(snapshot.data()).thenReturn({});
    listener(snapshot);
    expect(preferenceManager.prefs, isEmpty);
  });

  test("Clearing local data leaves an empty data map", () {
    expect(preferenceManager.prefs, isEmpty);

    preferenceManager.testIdList = [randomId(), randomId()];
    preferenceManager.testId = randomId();
    expect(preferenceManager.prefs, isNotEmpty);

    preferenceManager.clearLocal();
    expect(preferenceManager.prefs, isEmpty);
  });

  test("Setting property to the same value is a no-op", () {
    preferenceManager.testInt = 10;
    verify(appManager.mockSubscriptionManager.isPro).called(1);

    preferenceManager.testInt = 10;
    verifyNever(appManager.mockSubscriptionManager.isPro);
  });

  test("Setting property to null removes it from data map", () {
    preferenceManager.testInt = 10;
    expect(preferenceManager.prefs, isNotEmpty);

    preferenceManager.testInt = null;
    expect(preferenceManager.prefs, isEmpty);
  });

  test("Firestore document is added if it doesn't exist", () async {
    when(appManager.mockSubscriptionManager.isPro).thenReturn(true);

    var snapshot = MockDocumentSnapshot();
    when(snapshot.exists).thenReturn(false);
    var doc = MockDocumentReference();
    when(doc.get()).thenAnswer((_) => Future.value(snapshot));
    when(appManager.mockFirestoreWrapper.doc(any)).thenReturn(doc);

    preferenceManager.firestoreEnabled = true;
    preferenceManager.testInt = 10;
    verify(appManager.mockFirestoreWrapper.doc("test/path")).called(1);

    await untilCalled(doc.set(any));
    verify(doc.set(any)).called(1);
    verifyNever(doc.update(any));
  });

  test("Firestore document is updated if it exists", () async {
    when(appManager.mockSubscriptionManager.isPro).thenReturn(true);

    var snapshot = MockDocumentSnapshot();
    when(snapshot.exists).thenReturn(true);
    var doc = MockDocumentReference();
    when(doc.get()).thenAnswer((_) => Future.value(snapshot));
    when(appManager.mockFirestoreWrapper.doc(any)).thenReturn(doc);

    preferenceManager.firestoreEnabled = true;
    preferenceManager.testInt = 10;
    verify(appManager.mockFirestoreWrapper.doc("test/path")).called(1);

    await untilCalled(doc.update(any));
    verify(doc.update(any)).called(1);
    verifyNever(doc.set(any));
  });

  test("String list", () {
    expect(preferenceManager.testStringList, isEmpty);
    preferenceManager.testStringList = ["0", "1"];
    expect(preferenceManager.testStringList, ["0", "1"]);
    verify(appManager.mockSubscriptionManager.isPro).called(1);

    // Setting to the same value is a no-op.
    preferenceManager.testStringList = ["0", "1"];
    verifyNever(appManager.mockSubscriptionManager.isPro);

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
    verify(appManager.mockSubscriptionManager.isPro).called(1);

    // Setting to the same value is a no-op.
    preferenceManager.testIdList = [id0, id1];
    verifyNever(appManager.mockSubscriptionManager.isPro);

    // Reset to null.
    preferenceManager.testIdList = null;
    expect(preferenceManager.testIdList, isEmpty);
  });
}
