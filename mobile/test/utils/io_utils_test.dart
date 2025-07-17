import 'dart:io';

import 'package:adair_flutter_lib/utils/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/io_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  testWidgets("safeDeleteFileSystemEntity exits early", (tester) async {
    var file = MockFile();
    when(file.existsSync()).thenReturn(false);

    safeDeleteFileSystemEntity(file);
    verify(file.existsSync()).called(1);
    verifyNever(file.deleteSync(recursive: anyNamed("recursive")));
  });

  testWidgets("safeDeleteFileSystemEntity deletes file", (tester) async {
    var file = MockFile();
    when(file.existsSync()).thenReturn(true);
    when(file.deleteSync(recursive: anyNamed("recursive"))).thenAnswer((_) {});

    safeDeleteFileSystemEntity(file);
    verify(file.existsSync()).called(1);
    verify(file.deleteSync(recursive: anyNamed("recursive"))).called(1);
  });

  test("isConnected works with example.com", () async {
    when(
      managers.lib.ioWrapper.lookup("example.com"),
    ).thenAnswer((_) => Future.value([InternetAddress("192.0.2.146")]));
    expect(await isConnected(), isTrue);
    verify(managers.lib.ioWrapper.lookup(any)).called(1);
  });

  test("isConnected falls back on Google", () async {
    when(
      managers.lib.ioWrapper.lookup("example.com"),
    ).thenAnswer((_) => Future.value([]));
    when(
      managers.lib.ioWrapper.lookup("google.com"),
    ).thenAnswer((_) => Future.value([InternetAddress("192.0.2.146")]));
    expect(await isConnected(), isTrue);
    verify(managers.lib.ioWrapper.lookup(any)).called(2);
  });
}
