import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/database/sqlite_open_helper.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.dart';

void main() {
  test("base64Encode file doesn't exist returns error", () async {
    var file = MockFile();
    when(file.exists()).thenAnswer((_) => Future.value(false));
    when(file.path).thenReturn("test/path/file.db");

    var base64 = await base64Db(file);
    expect(
      utf8.decode(base64Decode(base64)),
      "Can't Base64 a database that doesn't exist: test/path/file.db",
    );
  });

  test("base64Encode exists returns non-null", () async {
    var file = MockFile();
    when(file.exists()).thenAnswer((_) => Future.value(true));
    when(
      file.readAsBytes(),
    ).thenAnswer((_) => Future.value(utf8.encode("Test file contents")));

    var base64 = await base64Db(file);
    expect(utf8.decode(base64Decode(base64)), "Test file contents");
  });
}
