import 'package:adair_flutter_lib/widgets/button.dart';
import 'package:adair_flutter_lib/widgets/loading.dart';
import 'package:adair_flutter_lib/widgets/work_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/anglers_log_pro_page.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mobile/widgets/async_feedback.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.userPreferenceManager.userName).thenReturn(null);
    when(managers.userPreferenceManager.userEmail).thenReturn(null);
  });

  testWidgets("Action button disabled while loading", (tester) async {
    await pumpContext(
      tester,
      (_) => AsyncFeedback(
        actionText: "Action",
        state: AsyncFeedbackState.loading,
        action: () {},
      ),
    );

    expect(findFirst<Button>(tester).onPressed, isNull);
  });

  testWidgets("Action button enabled while idle", (tester) async {
    await pumpContext(
      tester,
      (_) => AsyncFeedback(
        actionText: "Action",
        state: AsyncFeedbackState.none,
        action: () {},
      ),
    );

    expect(findFirst<Button>(tester).onPressed, isNotNull);
  });

  testWidgets("Feedback empty when idle", (tester) async {
    await pumpContext(
      tester,
      (_) => AsyncFeedback(
        actionText: "Action",
        state: AsyncFeedbackState.none,
        action: () {},
      ),
    );

    expect(find.byType(Loading), findsNothing);
    expect(find.byType(WorkResult), findsNothing);
  });

  testWidgets("Feedback while loading", (tester) async {
    await pumpContext(
      tester,
      (_) => AsyncFeedback(
        actionText: "Action",
        state: AsyncFeedbackState.loading,
        action: () {},
      ),
    );

    expect(find.byType(Loading), findsOneWidget);
    expect(find.byType(WorkResult), findsNothing);
  });

  testWidgets("Feedback success", (tester) async {
    await pumpContext(
      tester,
      (_) => AsyncFeedback(
        actionText: "Action",
        state: AsyncFeedbackState.success,
        action: () {},
      ),
    );

    expect(find.byType(Loading), findsNothing);
    expect(find.byType(WorkResult), findsOneWidget);
    expect(find.text("SEND REPORT"), findsNothing);
  });

  testWidgets("Feedback error", (tester) async {
    await pumpContext(
      tester,
      (_) => AsyncFeedback(
        actionText: "Action",
        state: AsyncFeedbackState.error,
        action: () {},
        feedbackPage: const FeedbackPage(),
      ),
    );

    expect(find.byType(Loading), findsNothing);
    expect(find.byType(WorkResult), findsOneWidget);
    expect(find.text("SEND REPORT"), findsOneWidget);

    await tapAndSettle(tester, find.text("SEND REPORT"));

    expect(find.byType(FeedbackPage), findsOneWidget);
  });

  testWidgets("Feedback page is hidden", (tester) async {
    await pumpContext(
      tester,
      (_) => const AsyncFeedback(
        actionText: "Action",
        state: AsyncFeedbackState.error,
      ),
    );
    expect(find.text("SEND REPORT"), findsNothing);
  });

  testWidgets("Action requires Pro subscription", (tester) async {
    when(managers.lib.subscriptionManager.isFree).thenReturn(true);
    when(managers.lib.subscriptionManager.isPro).thenReturn(false);
    when(
      managers.lib.subscriptionManager.subscriptions(),
    ).thenAnswer((_) => Future.value());

    await pumpContext(
      tester,
      (_) => AsyncFeedback(
        actionText: "ACTION",
        state: AsyncFeedbackState.error,
        actionRequiresPro: true,
        action: () {},
      ),
    );

    await tapAndSettle(tester, find.text("ACTION"));
    expect(find.byType(AnglersLogProPage), findsOneWidget);
  });

  testWidgets("Action is invoked", (tester) async {
    var called = false;
    await pumpContext(
      tester,
      (_) => AsyncFeedback(
        actionText: "ACTION",
        actionRequiresPro: false,
        action: () => called = true,
      ),
    );

    await tapAndSettle(tester, find.text("ACTION"));
    expect(find.byType(AnglersLogProPage), findsNothing);
    expect(called, isTrue);
  });
}
