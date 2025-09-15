import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/bait_page.dart';
import 'package:mobile/pages/bait_variant_page.dart';
import 'package:mobile/pages/entity_page.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.baitManager.formatNameWithCategory(any)).thenReturn(null);
  });

  testWidgets("Associated database bait is null", (tester) async {
    when(managers.baitManager.entity(any)).thenReturn(null);

    await tester.pumpWidget(
      Testable((_) => BaitVariantPage(BaitVariant(color: "Red"))),
    );

    expect(find.text("Red"), findsOneWidget);
  });

  testWidgets("Associated database variant is null", (tester) async {
    when(managers.baitManager.entity(any)).thenReturn(Bait(name: "Bait Name"));
    when(managers.baitManager.variant(any, any)).thenReturn(null);

    await tester.pumpWidget(
      Testable((_) => BaitVariantPage(BaitVariant(color: "Red"))),
    );

    expect(find.text("Red"), findsOneWidget);
  });

  testWidgets("Base bait name is empty", (tester) async {
    when(managers.baitManager.entity(any)).thenReturn(Bait());
    when(managers.baitManager.variant(any, any)).thenReturn(null);

    await tester.pumpWidget(
      Testable((_) => BaitVariantPage(BaitVariant(color: ""))),
    );

    expect(find.byType(ListItem), findsNothing);
  });

  testWidgets("allowBaseViewing = true", (tester) async {
    when(managers.baitManager.entity(any)).thenReturn(Bait(name: "Bait Name"));
    when(managers.baitManager.variant(any, any)).thenReturn(null);
    when(
      managers.baitManager.formatNameWithCategory(any),
    ).thenReturn("Bait Name");
    when(managers.baitManager.deleteMessage(any, any)).thenReturn("Delete");

    await tester.pumpWidget(
      Testable(
        (_) =>
            BaitVariantPage(BaitVariant(color: "Red"), allowBaseViewing: true),
      ),
    );

    expect(find.text("Bait Name"), findsOneWidget);
    expect(find.byType(RightChevronIcon), findsOneWidget);

    await tapAndSettle(tester, find.text("Bait Name"));
    expect(find.byType(BaitPage), findsOneWidget);
  });

  testWidgets("allowBaseViewing = false", (tester) async {
    when(managers.baitManager.entity(any)).thenReturn(Bait(name: "Bait Name"));
    when(managers.baitManager.variant(any, any)).thenReturn(null);
    when(
      managers.baitManager.formatNameWithCategory(any),
    ).thenReturn("Bait Name");

    await tester.pumpWidget(
      Testable(
        (_) =>
            BaitVariantPage(BaitVariant(color: "Red"), allowBaseViewing: false),
      ),
    );

    expect(find.text("Bait Name"), findsOneWidget);
    expect(find.byType(RightChevronIcon), findsNothing);
  });

  testWidgets("Any property not set renders empty", (tester) async {
    when(managers.baitManager.entity(any)).thenReturn(null);

    var context = await pumpContext(
      tester,
      (_) => BaitVariantPage(BaitVariant(), allowBaseViewing: false),
    );

    expect(find.text(Strings.of(context).inputColorLabel), findsNothing);
    expect(find.text(Strings.of(context).baitVariantPageModel), findsNothing);
    expect(find.text(Strings.of(context).baitVariantPageSize), findsNothing);
    expect(find.text(Strings.of(context).baitVariantPageModel), findsNothing);
    expect(find.text(Strings.of(context).inputDescriptionLabel), findsNothing);
  });

  testWidgets("No image shown", (tester) async {
    await pumpContext(
      tester,
      (_) => BaitVariantPage(BaitVariant(), allowBaseViewing: false),
    );
    expect(findFirst<EntityPage>(tester).imageNames, isEmpty);
  });

  testWidgets("Image shown", (tester) async {
    await stubImage(managers, tester, "flutter_logo.png");

    await pumpContext(
      tester,
      (_) => BaitVariantPage(
        BaitVariant(imageName: "flutter_logo.png"),
        allowBaseViewing: false,
      ),
    );
    expect(findFirst<EntityPage>(tester).imageNames, isNotEmpty);
    expect(findFirst<EntityPage>(tester).imageNames.first, "flutter_logo.png");
  });
}
