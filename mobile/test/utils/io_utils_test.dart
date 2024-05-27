import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/io_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.dart';
import '../mocks/mocks.mocks.dart';

void main() {
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
    var io = MockIoWrapper();
    when(io.lookup("example.com"))
        .thenAnswer((_) => Future.value([InternetAddress("192.0.2.146")]));
    expect(await isConnected(io), isTrue);
    verify(io.lookup(any)).called(1);
  });

  test("isConnected falls back on Google", () async {
    var io = MockIoWrapper();
    when(io.lookup("example.com")).thenAnswer((_) => Future.value([]));
    when(io.lookup("google.com"))
        .thenAnswer((_) => Future.value([InternetAddress("192.0.2.146")]));
    expect(await isConnected(io), isTrue);
    verify(io.lookup(any)).called(2);
  });
}
