import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/how_to_feedback_page.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mockito/mockito.dart';

import '../../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(
      managers.backupRestoreManager.progressStream,
    ).thenAnswer((_) => const Stream.empty());
    when(managers.backupRestoreManager.hasLastProgressError).thenReturn(false);

    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);

    when(managers.pollManager.canVote).thenReturn(false);

    when(managers.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingBaits).thenReturn(true);
    when(
      managers.userPreferenceManager.isTrackingFishingSpots,
    ).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingMethods).thenReturn(true);
    when(
      managers.userPreferenceManager.isTrackingWaterClarities,
    ).thenReturn(true);
    when(managers.userPreferenceManager.isTrackingGear).thenReturn(true);
    when(
      managers.userPreferenceManager.stream,
    ).thenAnswer((_) => const Stream.empty());
  });

  testWidgets("Feedback and rate scrolling", (tester) async {
    await tester.pumpWidget(
      Testable((_) => const HowToFeedbackPage(nextLabel: "Next")),
    );

    var scrollable = Scrollable.of(
      (tester
                  .firstWidget(
                    find.ancestor(
                      of: find.widgetWithText(ListItem, "Send Feedback"),
                      matching: find.byType(Container),
                    ),
                  )
                  .key
              as GlobalKey)
          .currentContext!,
    );
    expect(scrollable.widget.controller!.offset, 0.0);

    // Wait for scroll animation. Duration is scroll delay + duration from
    // _HowToFeedbackPageState.
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));
    expect(scrollable.widget.controller!.offset, greaterThan(0.0));

    // Wait to jump back to top.
    await tester.pumpAndSettle(const Duration(milliseconds: 2500));
    expect(scrollable.widget.controller!.offset, 0.0);

    // And scroll again.
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));
    expect(scrollable.widget.controller!.offset, greaterThan(0.0));
  });
}
