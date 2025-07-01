import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/share_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  Future<BuildContext> context(WidgetTester tester) {
    return buildContext(tester);
  }

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.sharePlusWrapper.share(any, any))
        .thenAnswer((_) => Future.value(null));
    when(managers.sharePlusWrapper.shareFiles(
      any,
      any,
      text: anyNamed("text"),
    )).thenAnswer((_) => Future.value(null));

    when(managers.ioWrapper.isAndroid).thenReturn(false);
  });

  testWidgets("Share icon is iOS", (tester) async {
    when(managers.ioWrapper.isAndroid).thenReturn(false);
    expect(shareIconData(await context(tester)), Icons.ios_share);
  });

  testWidgets("Share icon is Android", (tester) async {
    when(managers.ioWrapper.isAndroid).thenReturn(true);
    expect(shareIconData(await context(tester)), Icons.share);
  });

  testWidgets("Share text is iOS", (tester) async {
    when(managers.ioWrapper.isAndroid).thenReturn(false);
    await share(await context(tester), [], null);

    var result = verify(managers.sharePlusWrapper.share(captureAny, any));
    result.called(1);

    expect(result.captured.first, "Shared with #AnglersLogApp for iOS.");
  });

  testWidgets("Share text is Android", (tester) async {
    when(managers.ioWrapper.isAndroid).thenReturn(true);
    await share(await context(tester), [], null);

    var result = verify(managers.sharePlusWrapper.share(captureAny, any));
    result.called(1);

    expect(result.captured.first, "Shared with #AnglersLogApp for Android.");
  });

  testWidgets("Empty text doesn't add new lines", (tester) async {
    await share(await context(tester), [], null, text: null);
    var result = verify(managers.sharePlusWrapper.share(captureAny, any));
    result.called(1);

    expect(result.captured.first, "Shared with #AnglersLogApp for iOS.");
  });

  testWidgets("Text adds new lines", (tester) async {
    await share(await context(tester), [], null, text: "Test");
    var result = verify(managers.sharePlusWrapper.share(captureAny, any));
    result.called(1);

    expect(
      result.captured.first,
      "Test\n\nShared with #AnglersLogApp for iOS.",
    );
  });

  testWidgets("With images", (tester) async {
    when(managers.imageManager.imageXFiles(any)).thenReturn([]);

    await share(await context(tester), ["test.png"], null);

    verify(managers.sharePlusWrapper.shareFiles(
      any,
      any,
      text: anyNamed("text"),
    )).called(1);
  });

  testWidgets("Without images", (tester) async {
    when(managers.imageManager.imageXFiles(any)).thenReturn([]);
    await share(await context(tester), [], null);
    verify(managers.sharePlusWrapper.share(any, any)).called(1);
  });
}
