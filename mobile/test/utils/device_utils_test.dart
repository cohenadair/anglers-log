import 'package:adair_flutter_lib/wrappers/io_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/device_utils.dart';
import 'package:mobile/wrappers/device_info_wrapper.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/mocks/mocks.mocks.dart';
import '../mocks/mocks.mocks.dart';
import '../test_utils.dart';

void main() {
  late MockDeviceInfoWrapper deviceInfoWrapper;
  late MockIoWrapper ioWrapper;

  setUp(() {
    ioWrapper = MockIoWrapper();
    IoWrapper.set(ioWrapper);

    deviceInfoWrapper = MockDeviceInfoWrapper();
    DeviceInfoWrapper.set(deviceInfoWrapper);
  });

  test("isPad returns false when not an Apple OS", () async {
    when(ioWrapper.isIOS).thenReturn(false);
    expect(await isPad(), isFalse);
  });

  test("isPad returns false when not an iPad", () async {
    when(ioWrapper.isIOS).thenReturn(true);
    stubIosDeviceInfo(deviceInfoWrapper, name: "iphone");

    expect(await isPad(), isFalse);
    verify(deviceInfoWrapper.iosInfo).called(1);
  });

  test("isPad returns true", () async {
    when(ioWrapper.isIOS).thenReturn(true);
    stubIosDeviceInfo(deviceInfoWrapper, name: "ipad");

    expect(await isPad(), isTrue);
    verify(deviceInfoWrapper.iosInfo).called(1);
  });
}
