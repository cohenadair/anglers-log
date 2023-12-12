import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/onboarding/how_to_feedback_page.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/stubbed_app_manager.dart';
import '../../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.ioWrapper.isAndroid).thenReturn(false);

    when(appManager.pollManager.canVote).thenReturn(false);

    when(appManager.userPreferenceManager.isTrackingSpecies).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingAnglers).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingBaits).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingFishingSpots)
        .thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingMethods).thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingWaterClarities)
        .thenReturn(true);
    when(appManager.userPreferenceManager.isTrackingGear).thenReturn(true);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
  });

  testWidgets("Feedback and rate scrolling", (tester) async {
    await tester.pumpWidget(Testable(
      (_) => const HowToFeedbackPage(nextLabel: "Next"),
      appManager: appManager,
    ));

    var scrollable = Scrollable.of((tester
            .firstWidget(find.ancestor(
              of: find.widgetWithText(ListItem, "Send Feedback"),
              matching: find.byType(Container),
            ))
            .key as GlobalKey)
        .currentContext!);
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
