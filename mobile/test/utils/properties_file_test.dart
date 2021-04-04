import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/properties_file.dart';

void main() {
  test("Valid input", () {
    var properties = PropertiesFile("key0=value0\nkey1=value1\nkey2=value2");
    expect(properties.stringForKey("key0"), "value0");
    expect(properties.stringForKey("key1"), "value1");
    expect(properties.stringForKey("key2"), "value2");
  });
}
