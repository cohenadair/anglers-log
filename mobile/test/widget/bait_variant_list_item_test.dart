import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/bait_variant_page.dart';
import 'package:mobile/pages/save_bait_variant_page.dart';
import 'package:mobile/widgets/bait_variant_list_item.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.baitManager.variantDisplayValue(any, any))
        .thenReturn("Test Variant");
    when(appManager.baitManager.formatNameWithCategory(any))
        .thenReturn("Bait Name");

    when(appManager.customEntityManager.entityExists(any)).thenReturn(false);

    when(appManager.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(appManager.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(appManager.userPreferenceManager.stream)
        .thenAnswer((_) => const Stream.empty());
  });

  testWidgets("Tapping while editing shows SaveBaitVariantPage",
      (tester) async {
    await pumpContext(
      tester,
      (_) => BaitVariantListItem(
        BaitVariant(),
        isEditing: true,
      ),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.text("Test Variant"));
    expect(find.byType(SaveBaitVariantPage), findsOneWidget);
    expect(find.byType(BaitVariantPage), findsNothing);
  });

  testWidgets("Tapping while viewing shows BaitVariantPage", (tester) async {
    await pumpContext(
      tester,
      (_) => BaitVariantListItem(
        BaitVariant(),
        isEditing: false,
      ),
      appManager: appManager,
    );

    await tapAndSettle(tester, find.text("Test Variant"));
    expect(find.byType(SaveBaitVariantPage), findsNothing);
    expect(find.byType(BaitVariantPage), findsOneWidget);
  });

  testWidgets("onPicked is invoked", (tester) async {
    var invoked = false;
    await pumpContext(
      tester,
      (_) => BaitVariantListItem(
        BaitVariant(),
        onPicked: (_) => invoked = true,
      ),
      appManager: appManager,
    );
    await tapAndSettle(tester, find.text("Test Variant"));
    expect(invoked, isTrue);
  });

  testWidgets("Null trailing widget shows RightChevronIcon", (tester) async {
    await pumpContext(
      tester,
      (_) => BaitVariantListItem(
        BaitVariant(),
        trailing: null,
      ),
      appManager: appManager,
    );
    expect(find.byType(RightChevronIcon), findsOneWidget);
  });

  testWidgets("Description shown if not in title text", (tester) async {
    when(appManager.baitManager.variantDisplayValue(any, any))
        .thenReturn("Red");

    await pumpContext(
      tester,
      (_) => BaitVariantListItem(
        BaitVariant(
          color: "Red",
          description: "Description",
        ),
      ),
      appManager: appManager,
    );

    expect(find.text("Red"), findsOneWidget);
    expect(find.text("Description"), findsOneWidget);
  });

  testWidgets("Description shown if not in title text", (tester) async {
    when(appManager.baitManager.variantDisplayValue(any, any))
        .thenReturn("Description");

    var context = await pumpContext(
      tester,
      (_) => BaitVariantListItem(
        BaitVariant(
          description: "Description",
        ),
      ),
      appManager: appManager,
    );

    expect(find.primaryText(context, text: "Description"), findsOneWidget);
  });
}
