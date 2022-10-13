import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/polls_page.dart';
import 'package:mobile/poll_manager.dart';
import 'package:mobile/widgets/filled_row.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.pollManager.fetchPolls()).thenAnswer((_) => Future.value());
    when(appManager.pollManager.canVoteFree).thenReturn(true);
    when(appManager.pollManager.canVotePro).thenReturn(true);
    when(appManager.pollManager.freePoll).thenReturn(Poll(
      type: PollType.free,
      optionValues: {
        "Free Feature 1": 5, // 22%
        "Free Feature 2": 15, // 65%
        "Free Feature 3": 3, // 13%
      },
      updatedAt: 5000,
      comingSoon: "Coming soon free",
    ));
    when(appManager.pollManager.proPoll).thenReturn(Poll(
      type: PollType.pro,
      optionValues: {
        "Pro Feature 1": 60, // 36%
        "Pro Feature 2": 25, // 15%
        "Pro Feature 3": 80, // 48%
      },
      updatedAt: 5000,
      comingSoon: "Coming soon pro",
    ));
  });

  testWidgets("Loading widget is shown", (tester) async {
    when(appManager.pollManager.fetchPolls())
        .thenAnswer((_) => Future.delayed(const Duration(milliseconds: 50)));
    when(appManager.pollManager.freePoll).thenReturn(null);
    when(appManager.pollManager.proPoll).thenReturn(null);

    await pumpContext(tester, (_) => PollsPage(), appManager: appManager);

    expect(find.byType(Loading), findsOneWidget);
    expect(find.text("Next Free Feature"), findsNothing);
    expect(find.text("Next Pro Feature"), findsNothing);
    expect(find.text("No Polls"), findsNothing);

    // Pump to ensure fetchPolls() future finishes.
    tester.pumpAndSettle(const Duration(milliseconds: 50));
  });

  testWidgets("Placeholder shown when there are no polls", (tester) async {
    when(appManager.pollManager.freePoll).thenReturn(null);
    when(appManager.pollManager.proPoll).thenReturn(null);

    await pumpContext(tester, (_) => PollsPage(), appManager: appManager);
    await tester.pumpAndSettle();

    expect(find.byType(Loading), findsNothing);
    expect(find.text("Next Free Feature"), findsNothing);
    expect(find.text("Next Pro Feature"), findsNothing);
    expect(find.text("No Polls"), findsOneWidget);
  });

  testWidgets("Polls shown when user can vote", (tester) async {
    await pumpContext(tester, (_) => PollsPage(), appManager: appManager);
    await tester.pumpAndSettle();

    expect(find.byType(Loading), findsNothing);
    expect(find.text("Next Free Feature"), findsOneWidget);
    expect(find.text("Coming Soon To Free Users (As Voted)"), findsOneWidget);
    expect(find.text("Coming soon free"), findsOneWidget);
    expect(find.text("Next Pro Feature"), findsOneWidget);
    expect(find.text("Coming Soon To Pro Users (As Voted)"), findsOneWidget);
    expect(find.text("Coming soon pro"), findsOneWidget);
    expect(find.text("No Polls"), findsNothing);
  });

  testWidgets("Free poll hidden when null", (tester) async {
    when(appManager.pollManager.freePoll).thenReturn(null);

    await pumpContext(tester, (_) => PollsPage(), appManager: appManager);
    await tester.pumpAndSettle();

    expect(find.byType(Loading), findsNothing);
    expect(find.text("Next Free Feature"), findsNothing);
    expect(find.text("Next Pro Feature"), findsOneWidget);
    expect(find.text("No Polls"), findsNothing);
  });

  testWidgets("Pro poll hidden when null", (tester) async {
    when(appManager.pollManager.proPoll).thenReturn(null);

    await pumpContext(tester, (_) => PollsPage(), appManager: appManager);
    await tester.pumpAndSettle();

    expect(find.byType(Loading), findsNothing);
    expect(find.text("Next Free Feature"), findsOneWidget);
    expect(find.text("Next Pro Feature"), findsNothing);
    expect(find.text("No Polls"), findsNothing);
  });

  testWidgets("Polls disabled after vote", (tester) async {
    when(appManager.pollManager.canVoteFree).thenReturn(false);
    when(appManager.pollManager.canVotePro).thenReturn(false);

    await pumpContext(tester, (_) => PollsPage(), appManager: appManager);
    await tester.pumpAndSettle();

    expect(
      find.text("Thank you for voting in the free feature poll!"),
      findsOneWidget,
    );
    expect(
      find.text("Thank you for voting in the pro feature poll!"),
      findsOneWidget,
    );
    expect(find.byType(Column), findsNWidgets(8));

    var filledRows = tester.widgetList<FilledRow>(find.byType(FilledRow));
    for (var row in filledRows) {
      expect(row.onTap, isNull);
    }
  });

  testWidgets("Polls disabled while waiting for REST response", (tester) async {
    when(appManager.pollManager.vote(any, any)).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => true));

    await pumpContext(tester, (_) => PollsPage(), appManager: appManager);
    await tester.pumpAndSettle();

    await tester.tap(find.text("Free Feature 1"));
    await tester.tap(find.text("Pro Feature 1"));
    await tester.pump(); // Cannot settle because of Loading widget

    expect(find.byType(Loading), findsNWidgets(2));

    var filledRows = tester.widgetList<FilledRow>(find.byType(FilledRow));
    for (var row in filledRows) {
      expect(row.onTap, isNull);
    }

    // Pump to ensure fetchPolls() future finishes.
    tester.pumpAndSettle(const Duration(milliseconds: 50));
  });

  testWidgets("Correct percentages are shown", (tester) async {
    when(appManager.pollManager.canVoteFree).thenReturn(false);
    when(appManager.pollManager.canVotePro).thenReturn(false);

    await pumpContext(tester, (_) => PollsPage(), appManager: appManager);
    await tester.pumpAndSettle();

    expect(find.text("Free Feature 1 (22%)"), findsOneWidget);
    expect(find.text("Free Feature 2 (65%)"), findsOneWidget);
    expect(find.text("Free Feature 3 (13%)"), findsOneWidget);

    expect(find.text("Pro Feature 1 (36%)"), findsOneWidget);
    expect(find.text("Pro Feature 2 (15%)"), findsOneWidget);
    expect(find.text("Pro Feature 3 (48%)"), findsOneWidget);
  });

  testWidgets("Error message shown for failed vote", (tester) async {
    when(appManager.pollManager.vote(any, any))
        .thenAnswer((_) => Future.value(false));

    await pumpContext(tester, (_) => PollsPage(), appManager: appManager);
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.text("Free Feature 1"));
    expect(
      find.text(
          "There was an error casting your vote. Please try again later."),
      findsOneWidget,
    );

    await tapAndSettle(tester, find.text("Pro Feature 1"));
    expect(
      find.text(
          "There was an error casting your vote. Please try again later."),
      findsNWidgets(2),
    );
  });

  testWidgets("Result text is empty", (tester) async {
    await pumpContext(tester, (_) => PollsPage(), appManager: appManager);
    await tester.pumpAndSettle();
    expect(find.byType(Column), findsNWidgets(6));
  });

  testWidgets("Coming soon text is empty", (tester) async {
    when(appManager.pollManager.proPoll).thenReturn(Poll(
      type: PollType.pro,
      optionValues: {
        "Pro Feature 1": 60, // 36%
        "Pro Feature 2": 25, // 15%
        "Pro Feature 3": 80, // 48%
      },
      updatedAt: 5000,
      comingSoon: null,
    ));

    expect(find.text("Coming Soon To Pro Users (As Voted)"), findsNothing);
    expect(find.text("Coming soon pro"), findsNothing);
  });
}
