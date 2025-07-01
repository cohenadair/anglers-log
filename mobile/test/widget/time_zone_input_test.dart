import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/time_zone_input.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/timezone.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.lib.timeManager.filteredLocations(
      any,
      exclude: anyNamed("exclude"),
    )).thenAnswer((_) {
      return [
        TimeZoneLocation.fromName("America/New_York"),
        TimeZoneLocation.fromName("America/Chicago"),
        TimeZoneLocation.fromName("Europe/Isle_of_Man"),
      ];
    });
    when(managers.lib.timeManager.currentLocation)
        .thenReturn(TimeZoneLocation.fromName("America/New_York"));
  });

  testWidgets("Selecting time zone updates controller; invokes callback",
      (tester) async {
    late TimeZoneInputController controller;
    var invoked = false;
    await pumpContext(
      tester,
      (context) {
        controller = TimeZoneInputController(context);
        return TimeZoneInput(
          controller: controller,
          onPicked: () => invoked = true,
        );
      },
    );

    var timezoneToTap = getLocation(defaultTimeZone).currentTimeZone.isDst
        ? "America/Chicago (UTC-05:00)"
        : "America/Chicago (UTC-06:00)";
    await tapAndSettle(tester, find.text("Time Zone"));
    await tapAndSettle(tester, find.text(timezoneToTap));

    expect(invoked, isTrue);
    expect(controller.value, "America/Chicago");
  });

  testWidgets("Initial value is selected", (tester) async {
    late TimeZoneInputController controller;
    await pumpContext(
      tester,
      (context) {
        controller = TimeZoneInputController(context);
        controller.value = "America/Chicago";
        return TimeZoneInput(controller: controller);
      },
    );
    expect(find.text("America/Chicago"), findsOneWidget);
  });
}
