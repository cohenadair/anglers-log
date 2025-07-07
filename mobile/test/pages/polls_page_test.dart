import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/user_polls.pb.dart';
import 'package:mobile/pages/feedback_page.dart';
import 'package:mobile/pages/polls_page.dart';
import 'package:mobile/widgets/filled_row.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;
  late Polls polls;

  Polls defaultPolls() {
    return Polls(
      free: Poll(
        updatedAtTimestamp: Int64(5000),
        comingSoon: {
          "en": "Coming soon free",
        }.entries,
        options: {
          Option(
            voteCount: 5, // 22%
            localizations: {
              "en": "Free Feature 1",
            }.entries,
          ),
          Option(
            voteCount: 15, // 65%
            localizations: {
              "en": "Free Feature 2",
            }.entries,
          ),
          Option(
            voteCount: 3, // 13%
            localizations: {
              "en": "Free Feature 3",
            }.entries,
          ),
        },
      ),
      pro: Poll(
        updatedAtTimestamp: Int64(5000),
        comingSoon: {
          "en": "Coming soon pro",
        }.entries,
        options: {
          Option(
            voteCount: 60, // 36%
            localizations: {
              "en": "Pro Feature 1",
            }.entries,
          ),
          Option(
            voteCount: 25, // 15%
            localizations: {
              "en": "Pro Feature 2",
            }.entries,
          ),
          Option(
            voteCount: 80, // 48%
            localizations: {
              "en": "Pro Feature 3",
            }.entries,
          ),
        },
      ),
    );
  }

  setUp(() async {
    managers = await StubbedManagers.create();
    polls = defaultPolls();

    when(managers.pollManager.fetchPolls()).thenAnswer((_) => Future.value());
    when(managers.pollManager.canVoteFree).thenReturn(true);
    when(managers.pollManager.canVotePro).thenReturn(true);
    when(managers.pollManager.hasPoll).thenReturn(true);
    when(managers.pollManager.hasFreePoll).thenReturn(true);
    when(managers.pollManager.hasProPoll).thenReturn(true);
    when(managers.pollManager.polls).thenReturn(polls);
  });

  testWidgets("Loading widget is shown", (tester) async {
    when(managers.pollManager.fetchPolls())
        .thenAnswer((_) => Future.delayed(const Duration(milliseconds: 50)));
    when(managers.pollManager.polls).thenReturn(null);
    when(managers.pollManager.hasFreePoll).thenReturn(false);
    when(managers.pollManager.hasProPoll).thenReturn(false);

    await pumpContext(tester, (_) => PollsPage());

    expect(find.byType(Loading), findsOneWidget);
    expect(find.text("Next Free Feature"), findsNothing);
    expect(find.text("Next Pro Feature"), findsNothing);
    expect(find.text("No Polls"), findsNothing);

    // Pump to ensure fetchPolls() future finishes.
    tester.pumpAndSettle(const Duration(milliseconds: 50));
  });

  testWidgets("Placeholder shown when there are no polls", (tester) async {
    when(managers.pollManager.polls).thenReturn(null);
    when(managers.pollManager.hasFreePoll).thenReturn(false);
    when(managers.pollManager.hasProPoll).thenReturn(false);
    when(managers.pollManager.hasPoll).thenReturn(false);

    await pumpContext(tester, (_) => PollsPage());
    await tester.pumpAndSettle();

    expect(find.byType(Loading), findsNothing);
    expect(find.text("Next Free Feature"), findsNothing);
    expect(find.text("Next Pro Feature"), findsNothing);
    expect(find.text("No Polls"), findsOneWidget);

    when(managers.userPreferenceManager.userName).thenReturn(null);
    when(managers.userPreferenceManager.userEmail).thenReturn(null);

    await tapAndSettle(tester, find.text("SEND FEEDBACK"));
    expect(find.byType(FeedbackPage), findsOneWidget);
  });

  testWidgets("Polls shown when user can vote", (tester) async {
    await pumpContext(tester, (_) => PollsPage());
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
    when(managers.pollManager.hasFreePoll).thenReturn(false);

    await pumpContext(tester, (_) => PollsPage());
    await tester.pumpAndSettle();

    expect(find.byType(Loading), findsNothing);
    expect(find.text("Next Free Feature"), findsNothing);
    expect(find.text("Next Pro Feature"), findsOneWidget);
    expect(find.text("No Polls"), findsNothing);
  });

  testWidgets("Pro poll hidden when null", (tester) async {
    when(managers.pollManager.hasProPoll).thenReturn(false);

    await pumpContext(tester, (_) => PollsPage());
    await tester.pumpAndSettle();

    expect(find.byType(Loading), findsNothing);
    expect(find.text("Next Free Feature"), findsOneWidget);
    expect(find.text("Next Pro Feature"), findsNothing);
    expect(find.text("No Polls"), findsNothing);
  });

  testWidgets("Polls disabled after vote", (tester) async {
    when(managers.pollManager.canVoteFree).thenReturn(false);
    when(managers.pollManager.canVotePro).thenReturn(false);

    await pumpContext(tester, (_) => PollsPage());
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
    when(managers.pollManager.vote(any, any)).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 50), () => true));

    await pumpContext(tester, (_) => PollsPage());
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
    when(managers.pollManager.canVoteFree).thenReturn(false);
    when(managers.pollManager.canVotePro).thenReturn(false);

    await pumpContext(tester, (_) => PollsPage());
    await tester.pumpAndSettle();

    expect(find.text("Free Feature 1 (22%)"), findsOneWidget);
    expect(find.text("Free Feature 2 (65%)"), findsOneWidget);
    expect(find.text("Free Feature 3 (13%)"), findsOneWidget);

    expect(find.text("Pro Feature 1 (36%)"), findsOneWidget);
    expect(find.text("Pro Feature 2 (15%)"), findsOneWidget);
    expect(find.text("Pro Feature 3 (48%)"), findsOneWidget);
  });

  testWidgets("Error message shown for failed vote", (tester) async {
    when(managers.pollManager.vote(any, any))
        .thenAnswer((_) => Future.value(false));

    await pumpContext(tester, (_) => PollsPage());
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
    await pumpContext(tester, (_) => PollsPage());
    await tester.pumpAndSettle();
    expect(find.byType(Column), findsNWidgets(6));
  });

  testWidgets("Coming soon text is empty", (tester) async {
    polls.pro.comingSoon.clear();
    await pumpContext(tester, (_) => PollsPage());
    await tester.pumpAndSettle();
    expect(find.text("Coming Soon To Pro Users (As Voted)"), findsNothing);
    expect(find.text("Coming soon pro"), findsNothing);
  });

  testWidgets("Assertion error thrown when no English value exists",
      (tester) async {
    polls.pro.options.first.localizations.clear();

    // Catch assertions from pumpAndSettle.
    FlutterErrorDetails? errorDetails;
    FlutterError.onError = (FlutterErrorDetails details) {
      errorDetails = details;
    };

    await pumpContext(tester, (_) => PollsPage());
    await tester.pumpAndSettle();

    expect(errorDetails, isNotNull);
    expect(
      errorDetails!.exception,
      isA<AssertionError>().having(
        (e) => e.toString(),
        "message",
        contains("An English (en) localization must exist"),
      ),
    );

    // Reset error handler so it doesn't interfere with other tests.
    FlutterError.onError = FlutterError.dumpErrorToConsole;
  });

  testWidgets("Localization uses language and country", (tester) async {
    polls.pro.options[0].localizations["en_US"] = "English US Option 1";

    await pumpContext(
      tester,
      (_) => PollsPage(),
      locale: const Locale("en", "US"),
    );
    await tester.pumpAndSettle();

    expect(find.text("English US Option 1"), findsOneWidget);
    expect(find.text("Pro Feature 1"), findsNothing);
  });

  testWidgets("Localization uses language only", (tester) async {
    polls.pro.options[0].localizations["es"] = "Spanish Option 1";

    await pumpContext(
      tester,
      (_) => PollsPage(),
      locale: const Locale("es", "MX"),
    );
    await tester.pumpAndSettle();

    expect(find.text("Spanish Option 1"), findsOneWidget);
    expect(find.text("Pro Feature 1"), findsNothing);
  });

  testWidgets("Localization defaults to English", (tester) async {
    await pumpContext(
      tester,
      (_) => PollsPage(),
      locale: const Locale("en"),
    );

    await tester.pumpAndSettle();
    expect(find.text("Pro Feature 1"), findsOneWidget);
  });
}
