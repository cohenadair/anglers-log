import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/device_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  test("isPad returns false when not an Apple OS", () async {
    when(managers.lib.ioWrapper.isIOS).thenReturn(false);
    expect(await isPad(), isFalse);
  });

  test("isPad returns false when not an iPad", () async {
    when(managers.lib.ioWrapper.isIOS).thenReturn(true);
    stubIosDeviceInfo(managers.lib.deviceInfoWrapper, name: "iphone");

    expect(await isPad(), isFalse);
    verify(managers.lib.deviceInfoWrapper.iosInfo).called(1);
  });

  test("isPad returns true", () async {
    when(managers.lib.ioWrapper.isIOS).thenReturn(true);
    stubIosDeviceInfo(managers.lib.deviceInfoWrapper, name: "ipad");

    expect(await isPad(), isTrue);
    verify(managers.lib.deviceInfoWrapper.iosInfo).called(1);
  });
}
