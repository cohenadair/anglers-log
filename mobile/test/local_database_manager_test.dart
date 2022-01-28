import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/local_database_manager.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/utils/utils.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';

void main() {
  late StubbedAppManager appManager;
  late MockDatabase database;

  late LocalDatabaseManager databaseManager;

  setUp(() async {
    appManager = StubbedAppManager();
    database = MockDatabase();

    databaseManager = LocalDatabaseManager(appManager.app);
    await databaseManager.initialize(
      database: database,
    );
  });

  test("initialize closes DB if already open", () async {
    await databaseManager.initialize(
      database: database,
    );
    verify(database.close()).called(1);
  });

  test("insertOrReplace single", () async {
    when(database.insert(
      any,
      any,
      conflictAlgorithm: anyNamed("conflictAlgorithm"),
    )).thenAnswer((_) => Future.value(1));

    expect(await databaseManager.insertOrReplace("Any", {}), isTrue);
    verify(database.insert(
      any,
      any,
      conflictAlgorithm: anyNamed("conflictAlgorithm"),
    )).called(1);
  });

  test("insertOrReplace batch", () async {
    var batch = MockBatch();
    when(batch.insert(
      any,
      any,
      conflictAlgorithm: anyNamed("conflictAlgorithm"),
    )).thenAnswer((_) => Future.value(null));

    expect(await databaseManager.insertOrReplace("Any", {}, batch), isTrue);

    verifyNever(database.insert(
      any,
      any,
      conflictAlgorithm: anyNamed("conflictAlgorithm"),
    ));

    verify(batch.insert(
      any,
      any,
      conflictAlgorithm: anyNamed("conflictAlgorithm"),
    )).called(1);
  });

  test("deleteEntity single success", () async {
    when(appManager.ioWrapper.isAndroid).thenReturn(true);

    when(database.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(1));

    expect(await databaseManager.deleteEntity(randomId(), "Any"), isTrue);
    verify(database.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).called(1);
  });

  test("deleteEntity single failure", () async {
    when(appManager.ioWrapper.isAndroid).thenReturn(true);

    when(database.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(0));

    expect(await databaseManager.deleteEntity(randomId(), "Any"), isFalse);
    verify(database.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).called(1);
  });

  test("deleteEntity batch", () async {
    when(appManager.ioWrapper.isAndroid).thenReturn(true);

    var batch = MockBatch();
    when(batch.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(1));

    expect(
      await databaseManager.deleteEntity(randomId(), "Any", batch),
      isTrue,
    );
    verifyNever(database.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    ));
  });

  test("Hex functions used for Android delete queries", () async {
    when(database.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(0));

    when(appManager.ioWrapper.isAndroid).thenReturn(true);

    var id = randomId();
    await databaseManager.deleteEntity(id, "test");

    var result = verify(database.delete(
      any,
      where: captureAnyNamed("where"),
      whereArgs: captureAnyNamed("whereArgs"),
    ));
    result.called(1);

    String where = result.captured[0];
    String? whereArgs = result.captured[1].first;
    expect(where.contains("hex"), isTrue);
    expect(whereArgs, hex(id.uint8List));
  });

  test("Hex functions not used for iOS delete queries", () async {
    when(database.delete(
      any,
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) => Future.value(0));

    when(appManager.ioWrapper.isAndroid).thenReturn(false);

    var id = randomId();
    await databaseManager.deleteEntity(id, "test");

    var result = verify(database.delete(
      any,
      where: captureAnyNamed("where"),
      whereArgs: captureAnyNamed("whereArgs"),
    ));
    result.called(1);

    String where = result.captured[0];
    Uint8List? whereArgs = result.captured[1].first;
    expect(where.contains("hex"), isFalse);
    expect(whereArgs, id.uint8List);
  });
}
