import 'package:adair_flutter_lib/widgets/loading.dart';
import 'package:adair_flutter_lib/widgets/work_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/migration_page.dart';
import 'package:mobile/widgets/data_importer.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
  });

  testWidgets("Loading shown while future is running", (tester) async {
    var methodChannel = MockMethodChannel();
    when(
      methodChannel.invokeMethod(any),
    ).thenAnswer((_) => Future.delayed(const Duration(milliseconds: 50)));
    when(managers.servicesWrapper.methodChannel(any)).thenReturn(methodChannel);

    await pumpContext(tester, (_) => MigrationPage());
    expect(find.byType(Loading), findsOneWidget);
    expect(find.byType(DataImporter), findsNothing);
    expect(find.byType(WatermarkLogo), findsNothing);

    // Allow methodChannel future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
  });

  testWidgets("Importer shown when legacy data exists", (tester) async {
    var methodChannel = MockMethodChannel();
    when(methodChannel.invokeMethod(any)).thenAnswer((_) => Future.value({}));
    when(managers.servicesWrapper.methodChannel(any)).thenReturn(methodChannel);

    await pumpContext(tester, (_) => MigrationPage());
    // Need to rebuild after future has finished.
    await tester.pumpAndSettle();

    expect(find.byType(Loading), findsNothing);
    expect(find.byType(DataImporter), findsOneWidget);
    expect(find.byType(WorkResult), findsNothing);
  });

  testWidgets("Already done shown when legacy data doesn't exists", (
    tester,
  ) async {
    var methodChannel = MockMethodChannel();
    when(methodChannel.invokeMethod(any)).thenAnswer((_) => Future.value(null));
    when(managers.servicesWrapper.methodChannel(any)).thenReturn(methodChannel);

    await pumpContext(tester, (_) => MigrationPage());
    // Need to rebuild after future has finished.
    await tester.pumpAndSettle();

    expect(find.byType(Loading), findsNothing);
    expect(find.byType(DataImporter), findsNothing);
    expect(find.byType(WorkResult), findsOneWidget);
  });
}
