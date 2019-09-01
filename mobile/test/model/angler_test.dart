import 'package:mobile/model/angler.dart';
import 'package:test/test.dart';

void main() {
  test("Name is set properly", () {
    var angler = Angler(name: "Cohen Adair");
    expect(angler.name, "Cohen Adair");
  });
}