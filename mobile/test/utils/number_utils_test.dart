import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/region_manager.dart';
import 'package:mobile/utils/number_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  late MockRegionManager regionManager;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    regionManager = MockRegionManager();
    RegionManager.set(regionManager);
    when(regionManager.decimalFormat).thenReturn("#,###,###.##");
  });

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

  test("displayValue", () {
    // Whole number.
    expect(10.toDouble().displayValue(), "10");

    // Floating number.
    expect(10.58694.displayValue(), "10.59");

    // Whole floating number.
    expect(10.0.displayValue(), "10");

    // Trailing 0.
    expect(10.50.displayValue(), "10.5");

    // Set decimal places.
    expect(10.5556.displayValue(decimalPlaces: 3), "10.556");

    // Other formats.
    when(regionManager.decimalFormat).thenReturn("#\u202f###\u202f###,##");
    expect(1000000.55.displayValue(), "1\u202f000\u202f000,55");

    // Input for nb_NO is a non-breaking space, but NumberFormat.decimalPattern
    // outputs a narrow, non-breaking space.
    when(regionManager.decimalFormat).thenReturn("#\u00A0###\u00A0###,##");
    expect(1000000.55.displayValue(), "1\u202f000\u202f000,55");

    when(regionManager.decimalFormat).thenReturn("# ### ###,##");
    expect(1000000.55.displayValue(), "1\u202f000\u202f000,55");

    when(regionManager.decimalFormat).thenReturn("#\u202f###\u202f###.##");
    expect(1000000.55.displayValue(), "1\u00A0000\u00A0000.55");

    when(regionManager.decimalFormat).thenReturn("#.###.###,##");
    expect(1000000.55.displayValue(), "1.000.000,55");

    when(regionManager.decimalFormat).thenReturn("#,###,###.##");
    expect(1000000.55.displayValue(), "1,000,000.55");

    when(regionManager.decimalFormat).thenReturn("#'###'###.##");
    expect(1000000.55.displayValue(), "1'000'000.55");
  });

  test("tryParse", () {
    // Empty input.
    expect(Doubles.tryParse(null), null);
    expect(Doubles.tryParse(""), null);

    // Invalid input.
    expect(Doubles.tryParse("Not a double"), null);

    // Valid input with dot.
    expect(Doubles.tryParse("10.5"), 10.5);

    // Valid input with comma.
    expect(Doubles.tryParse("10,5"), 10.5);

    // Other formats.
    expect(Doubles.tryParse("1,005,300.5"), 1005300.5);
    expect(Doubles.tryParse("1 005 300,5"), 1005300.5);
    expect(Doubles.tryParse("1.005.300,5"), 1005300.5);
    expect(Doubles.tryParse("1,005,300.543"), 1005300.543);
    expect(Doubles.tryParse("1 005 300,543"), 1005300.543);
    expect(Doubles.tryParse("1.005.300,543"), 1005300.543);
  });

  test("percent", () {
    expect(percent(50, 200), 25);
    expect(percent(0, 200), 0);
    expect(percent(200, 200), 100);
    expect(percent(100, 50), 200);
    expect(() => percent(200, 0), throwsAssertionError);
  });
}
