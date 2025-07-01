import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/bait_variant_page.dart';
import 'package:mobile/pages/save_bait_variant_page.dart';
import 'package:mobile/widgets/bait_variant_list_item.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.baitManager.variantDisplayValue(any, any))
        .thenReturn("Test Variant");
    when(managers.baitManager.formatNameWithCategory(any))
        .thenReturn("Bait Name");

    when(managers.customEntityManager.entityExists(any)).thenReturn(false);
    when(managers.customEntityManager.customValuesDisplayValue(any, any))
        .thenReturn("");

    when(managers.userPreferenceManager.waterDepthSystem)
        .thenReturn(MeasurementSystem.metric);
    when(managers.userPreferenceManager.baitVariantFieldIds).thenReturn([]);
    when(managers.userPreferenceManager.stream)
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
    );
    expect(find.byType(RightChevronIcon), findsOneWidget);
  });

  testWidgets("Description shown if not in title text", (tester) async {
    when(managers.baitManager.variantDisplayValue(any, any)).thenReturn("Red");

    await pumpContext(
      tester,
      (_) => BaitVariantListItem(
        BaitVariant(
          color: "Red",
          description: "Description",
        ),
      ),
    );

    expect(find.text("Red"), findsOneWidget);
    expect(find.text("Description"), findsOneWidget);
  });

  testWidgets("Description shown if not in title text", (tester) async {
    when(managers.baitManager.variantDisplayValue(any, any))
        .thenReturn("Description");

    var context = await pumpContext(
      tester,
      (_) => BaitVariantListItem(
        BaitVariant(
          description: "Description",
        ),
      ),
    );

    expect(find.primaryText(context, text: "Description"), findsOneWidget);
  });
}
