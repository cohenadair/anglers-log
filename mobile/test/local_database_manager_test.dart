import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/local_database_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/utils/utils.dart';

import 'mock_app_manager.dart';

void main() {
  MockAppManager appManager;
  MockDatabase database;

  LocalDatabaseManager databaseManager;

  setUp(() async {
    appManager = MockAppManager(
      mockIoWrapper: true,
    );
    database = MockDatabase();

    databaseManager = LocalDatabaseManager(appManager);
    await databaseManager.initialize(
      database: database,
      openDatabase: () => Future.value(database),
    );
  });

  test("Hex functions used for Android delete queries", () async {
    when(database.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(0));

    when(appManager.mockIoWrapper.isAndroid).thenReturn(true);

    var id = randomId();
    await databaseManager.deleteEntity(id, "test");

    var result = verify(database.delete(
      any,
      where: captureAnyNamed("where"),
      whereArgs: captureAnyNamed("whereArgs"),
    ));
    result.called(1);

    String where = result.captured[0];
    String whereArgs = result.captured[1].first;
    expect(where.contains("hex"), isTrue);
    expect(whereArgs, hex(id.uint8List));
  });

  test("Hex functions not used for iOS delete queries", () async {
    when(database.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(0));

    when(appManager.mockIoWrapper.isAndroid).thenReturn(false);

    var id = randomId();
    await databaseManager.deleteEntity(id, "test");

    var result = verify(database.delete(
      any,
      where: captureAnyNamed("where"),
      whereArgs: captureAnyNamed("whereArgs"),
    ));
    result.called(1);

    String where = result.captured[0];
    Uint8List whereArgs = result.captured[1].first;
    expect(where.contains("hex"), isFalse);
    expect(whereArgs, id.uint8List);
  });
}
