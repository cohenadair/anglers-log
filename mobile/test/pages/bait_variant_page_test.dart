import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/bait_page.dart';
import 'package:mobile/pages/bait_variant_page.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_app_manager.dart';
import '../test_utils.dart';

void main() {
  late StubbedAppManager appManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.baitManager.formatNameWithCategory(any)).thenReturn(null);
  });

  testWidgets("Associated database bait is null", (tester) async {
    when(appManager.baitManager.entity(any)).thenReturn(null);

    await tester.pumpWidget(
      Testable(
        (_) => BaitVariantPage(BaitVariant(
          color: "Red",
        )),
        appManager: appManager,
      ),
    );

    expect(find.text("Red"), findsOneWidget);
  });

  testWidgets("Associated database variant is null", (tester) async {
    when(appManager.baitManager.entity(any)).thenReturn(Bait(
      name: "Bait Name",
    ));
    when(appManager.baitManager.variant(any, any)).thenReturn(null);

    await tester.pumpWidget(
      Testable(
        (_) => BaitVariantPage(BaitVariant(
          color: "Red",
        )),
        appManager: appManager,
      ),
    );

    expect(find.text("Red"), findsOneWidget);
  });

  testWidgets("Base bait name is empty", (tester) async {
    when(appManager.baitManager.entity(any)).thenReturn(Bait());
    when(appManager.baitManager.variant(any, any)).thenReturn(null);

    await tester.pumpWidget(
      Testable(
        (_) => BaitVariantPage(BaitVariant(
          color: "",
        )),
        appManager: appManager,
      ),
    );

    expect(find.byType(ListItem), findsNothing);
  });

  testWidgets("allowBaseViewing = true", (tester) async {
    when(appManager.baitManager.entity(any)).thenReturn(Bait(
      name: "Bait Name",
    ));
    when(appManager.baitManager.variant(any, any)).thenReturn(null);
    when(appManager.baitManager.formatNameWithCategory(any))
        .thenReturn("Bait Name");
    when(appManager.baitManager.deleteMessage(any, any)).thenReturn("Delete");

    await tester.pumpWidget(
      Testable(
        (_) => BaitVariantPage(
          BaitVariant(
            color: "Red",
          ),
          allowBaseViewing: true,
        ),
        appManager: appManager,
      ),
    );

    expect(find.text("Bait Name"), findsOneWidget);
    expect(find.byType(RightChevronIcon), findsOneWidget);

    await tapAndSettle(tester, find.text("Bait Name"));
    expect(find.byType(BaitPage), findsOneWidget);
  });

  testWidgets("allowBaseViewing = false", (tester) async {
    when(appManager.baitManager.entity(any)).thenReturn(Bait(
      name: "Bait Name",
    ));
    when(appManager.baitManager.variant(any, any)).thenReturn(null);
    when(appManager.baitManager.formatNameWithCategory(any))
        .thenReturn("Bait Name");

    await tester.pumpWidget(
      Testable(
        (_) => BaitVariantPage(
          BaitVariant(
            color: "Red",
          ),
          allowBaseViewing: false,
        ),
        appManager: appManager,
      ),
    );

    expect(find.text("Bait Name"), findsOneWidget);
    expect(find.byType(RightChevronIcon), findsNothing);
  });

  testWidgets("Any property not set renders empty", (tester) async {
    when(appManager.baitManager.entity(any)).thenReturn(null);

    var context = await pumpContext(
      tester,
      (_) => BaitVariantPage(
        BaitVariant(),
        allowBaseViewing: false,
      ),
      appManager: appManager,
    );

    expect(find.text(Strings.of(context).inputColorLabel), findsNothing);
    expect(find.text(Strings.of(context).baitVariantPageModel), findsNothing);
    expect(find.text(Strings.of(context).baitVariantPageSize), findsNothing);
    expect(find.text(Strings.of(context).baitVariantPageModel), findsNothing);
    expect(find.text(Strings.of(context).inputDescriptionLabel), findsNothing);
  });
}
