import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/pages/bait_page.dart';
import 'package:mobile/pages/entity_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/bait_variant_list_input.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.baitManager.deleteMessage(any, any)).thenReturn("Delete");
    when(managers.baitManager.entity(any)).thenReturn(
      Bait()
        ..id = randomId()
        ..name = "Countdown Brown Trout",
    );
    when(managers.baitManager.variantDisplayValue(any, any)).thenReturn("");
  });

  testWidgets("Null bait category renders empty", (tester) async {
    var context = await pumpContext(tester, (_) => BaitPage(Bait()));
    expect(find.listHeadingText(context), findsNothing);
  });

  testWidgets("Non-null bait category", (tester) async {
    when(managers.baitCategoryManager.entity(any)).thenReturn(
      BaitCategory()
        ..id = randomId()
        ..name = "Rapala",
    );
    var context = await pumpContext(tester, (_) => BaitPage(Bait()));

    expect(find.listHeadingText(context), findsOneWidget);
    expect(find.text("Rapala"), findsOneWidget);
    expect(find.text("Countdown Brown Trout"), findsOneWidget);
  });

  testWidgets("Image is passed to EntityPage", (tester) async {
    when(managers.baitManager.entity(any)).thenReturn(
      Bait()
        ..id = randomId()
        ..name = "Countdown Brown Trout"
        ..imageName = "image_name.png",
    );

    await tester.pumpWidget(Testable((_) => BaitPage(Bait())));

    var entityPage = tester.widget<EntityPage>(find.byType(EntityPage));
    expect(entityPage.imageNames.isEmpty, isFalse);
    expect(entityPage.imageNames.first, "image_name.png");
  });

  testWidgets("Empty image list is passed to EntityPage", (tester) async {
    when(managers.baitManager.entity(any)).thenReturn(
      Bait()
        ..id = randomId()
        ..name = "Countdown Brown Trout",
    );

    await tester.pumpWidget(Testable((_) => BaitPage(Bait())));

    var entityPage = tester.widget<EntityPage>(find.byType(EntityPage));
    expect(entityPage.imageNames.isEmpty, isTrue);
  });

  testWidgets("No type", (tester) async {
    when(managers.baitManager.entity(any)).thenReturn(
      Bait()
        ..id = randomId()
        ..name = "Countdown Brown Trout",
    );

    await tester.pumpWidget(Testable((_) => BaitPage(Bait())));

    expect(find.byType(MinChip), findsNothing);
  });

  testWidgets("Type", (tester) async {
    when(managers.baitManager.entity(any)).thenReturn(
      Bait()
        ..id = randomId()
        ..name = "Countdown Brown Trout"
        ..type = Bait_Type.live,
    );

    await tester.pumpWidget(Testable((_) => BaitPage(Bait())));

    expect(find.byType(MinChip), findsOneWidget);
    expect(find.text("Live"), findsOneWidget);
  });

  testWidgets("No variants", (tester) async {
    when(managers.baitManager.entity(any)).thenReturn(
      Bait()
        ..id = randomId()
        ..name = "Countdown Brown Trout",
    );

    await tester.pumpWidget(Testable((_) => BaitPage(Bait())));

    expect(find.byType(BaitVariantListInput), findsNothing);
  });

  testWidgets("Variants", (tester) async {
    when(
      managers.customEntityManager.customValuesDisplayValue(any, any),
    ).thenReturn("");
    when(managers.baitManager.entity(any)).thenReturn(
      Bait()
        ..id = randomId()
        ..name = "Countdown Brown Trout"
        ..variants.add(BaitVariant(color: "Red")),
    );

    await tester.pumpWidget(Testable((_) => BaitPage(Bait())));

    expect(find.byType(BaitVariantListInput), findsOneWidget);
  });
}
