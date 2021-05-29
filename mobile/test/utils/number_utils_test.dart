import 'package:mobile/utils/number_utils.dart';
import 'package:test/test.dart';

void main() {
  test("isWhole", () {
    expect(2.5.isWhole, isFalse);
    expect(2.0.isWhole, isTrue);
    expect(2.toDouble().isWhole, isTrue);
  });

  test("roundIfWhole", () {
    expect(2.5.roundIfWhole(), isNull);
    expect(2.0.roundIfWhole(), 2);
    expect(2.toDouble().roundIfWhole(), 2);
  });
}
