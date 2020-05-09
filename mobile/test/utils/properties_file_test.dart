import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/properties_file.dart';

void main() {
  test("Empty input", () {
    var properties = PropertiesFile(null);
    expect(properties.stringForKey("Test"), isNull);

    properties = PropertiesFile("");
    expect(properties.stringForKey("Test"), isNull);
  });

  test("Invalid input", () {
    var properties = PropertiesFile("key0\nkey1=value1\nkey2=");
    expect(properties.stringForKey("key0"), isNull);
    expect(properties.stringForKey("key1"), "value1");
    expect(properties.stringForKey("key2"), isNull);
  });

  test("Valid input", () {
    var properties = PropertiesFile("key0=value0\nkey1=value1\nkey2=value2");
    expect(properties.stringForKey("key0"), "value0");
    expect(properties.stringForKey("key1"), "value1");
    expect(properties.stringForKey("key2"), "value2");
  });
}