import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/share_utils.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  Future<BuildContext> context(WidgetTester tester) {
    return buildContext(tester, appManager: appManager);
  }

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.sharePlusWrapper.share(any))
        .thenAnswer((_) => Future.value(null));
    when(appManager.sharePlusWrapper.shareFiles(any, text: anyNamed("text")))
        .thenAnswer((_) => Future.value(null));

    when(appManager.ioWrapper.isAndroid).thenReturn(false);
  });

  testWidgets("Share icon is iOS", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(false);
    expect(shareIconData(await context(tester)), Icons.ios_share);
  });

  testWidgets("Share icon is Android", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(true);
    expect(shareIconData(await context(tester)), Icons.share);
  });

  testWidgets("Share text is iOS", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(false);
    await share(await context(tester), []);

    var result = verify(appManager.sharePlusWrapper.share(captureAny));
    result.called(1);

    expect(result.captured.first, "Shared with #AnglersLogApp for iOS.");
  });

  testWidgets("Share text is Android", (tester) async {
    when(appManager.ioWrapper.isAndroid).thenReturn(true);
    await share(await context(tester), []);

    var result = verify(appManager.sharePlusWrapper.share(captureAny));
    result.called(1);

    expect(result.captured.first, "Shared with #AnglersLogApp for Android.");
  });

  testWidgets("Empty text doesn't add new lines", (tester) async {
    await share(await context(tester), [], text: null);
    var result = verify(appManager.sharePlusWrapper.share(captureAny));
    result.called(1);

    expect(result.captured.first, "Shared with #AnglersLogApp for iOS.");
  });

  testWidgets("Text adds new lines", (tester) async {
    await share(await context(tester), [], text: "Test");
    var result = verify(appManager.sharePlusWrapper.share(captureAny));
    result.called(1);

    expect(
      result.captured.first,
      "Test\n\nShared with #AnglersLogApp for iOS.",
    );
  });

  testWidgets("With images", (tester) async {
    when(appManager.imageManager.imageXFiles(any)).thenReturn([]);

    await share(await context(tester), ["test.png"]);

    verify(appManager.sharePlusWrapper.shareFiles(
      any,
      text: anyNamed("text"),
    )).called(1);
  });

  testWidgets("Without images", (tester) async {
    when(appManager.imageManager.imageXFiles(any)).thenReturn([]);
    await share(await context(tester), []);
    verify(appManager.sharePlusWrapper.share(any)).called(1);
  });
}
