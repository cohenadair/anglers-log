import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/migration_page.dart';
import 'package:mobile/widgets/data_importer.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mobile/widgets/work_result.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();
  });

  testWidgets("Loading shown while future is running", (tester) async {
    var methodChannel = MockMethodChannel();
    when(methodChannel.invokeMethod(any))
        .thenAnswer((_) => Future.delayed(const Duration(milliseconds: 50)));
    when(appManager.servicesWrapper.methodChannel(any))
        .thenReturn(methodChannel);

    await pumpContext(tester, (_) => MigrationPage(), appManager: appManager);
    expect(find.byType(Loading), findsOneWidget);
    expect(find.byType(DataImporter), findsNothing);
    expect(find.byType(WatermarkLogo), findsNothing);

    // Allow methodChannel future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
  });

  testWidgets("Importer shown when legacy data exists", (tester) async {
    var methodChannel = MockMethodChannel();
    when(methodChannel.invokeMethod(any)).thenAnswer((_) => Future.value({}));
    when(appManager.servicesWrapper.methodChannel(any))
        .thenReturn(methodChannel);

    await pumpContext(tester, (_) => MigrationPage(), appManager: appManager);
    // Need to rebuild after future has finished.
    await tester.pumpAndSettle();

    expect(find.byType(Loading), findsNothing);
    expect(find.byType(DataImporter), findsOneWidget);
    expect(find.byType(WorkResult), findsNothing);
  });

  testWidgets("Already done shown when legacy data doesn't exists",
      (tester) async {
    var methodChannel = MockMethodChannel();
    when(methodChannel.invokeMethod(any)).thenAnswer((_) => Future.value(null));
    when(appManager.servicesWrapper.methodChannel(any))
        .thenReturn(methodChannel);

    await pumpContext(tester, (_) => MigrationPage(), appManager: appManager);
    // Need to rebuild after future has finished.
    await tester.pumpAndSettle();

    expect(find.byType(Loading), findsNothing);
    expect(find.byType(DataImporter), findsNothing);
    expect(find.byType(WorkResult), findsOneWidget);
  });
}
