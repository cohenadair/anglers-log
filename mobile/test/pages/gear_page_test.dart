import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/gear_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/gear_page.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/blurred_background_photo.dart';
import 'package:mobile/widgets/icon_list.dart';
import 'package:mockito/mockito.dart';

import '../mocks/stubbed_managers.dart';
import '../test_utils.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.catchManager.list()).thenReturn([]);

    when(managers.gearManager.deleteMessage(any, any)).thenReturn("Delete");
    when(managers.gearManager.entity(any)).thenReturn(null);
  });

  testWidgets("Widget is updated when gear changes", (tester) async {
    var gearManager = GearManager(managers.app);
    when(managers.app.gearManager).thenReturn(gearManager);
    when(managers.localDatabaseManager.insertOrReplace(any, any, any))
        .thenAnswer((_) => Future.value(true));

    var gear = Gear(
      id: randomId(),
      name: "Bass Rod",
    );
    await gearManager.addOrUpdate(gear);

    await pumpContext(
      tester,
      (context) => GearPage(gear),
    );
    expect(find.text("Bass Rod"), findsOneWidget);

    gear.name = "Bass Rod 2";
    await gearManager.addOrUpdate(gear);
    await tester.pump();

    expect(find.text("Bass Rod"), findsNothing);
    expect(find.text("Bass Rod 2"), findsOneWidget);
  });

  testWidgets("Gear has an image", (tester) async {
    await stubImage(managers, tester, "flutter_logo.png");
    await pumpContext(
      tester,
      (context) => GearPage(Gear(
        id: randomId(),
        name: "Bass Rod",
        imageName: "flutter_logo.png",
      )),
    );
    expect(
      findFirst<BlurredBackgroundPhoto>(tester).galleryImages.isEmpty,
      isFalse,
    );
  });

  testWidgets("Gear doesn't have an image", (tester) async {
    await pumpContext(
      tester,
      (context) => GearPage(Gear(
        id: randomId(),
        name: "Bass Rod",
      )),
    );
    expect(find.byType(BlurredBackgroundPhoto), findsNothing);
  });

  testWidgets("All fields are set", (tester) async {
    stubImage(managers, tester, "flutter_logo.png");

    await pumpContext(
      tester,
      (context) => GearPage(Gear(
        id: randomId(),
        name: "Bass Rod",
        imageName: "flutter_logo.png",
        rodMakeModel: "Ugly Stick",
        rodSerialNumber: "ABC123",
        rodLength: MultiMeasurement(
          mainValue: Measurement(
            unit: Unit.feet,
            value: 9,
          ),
        ),
        rodAction: RodAction.fast,
        rodPower: RodPower.light,
        reelMakeModel: "Pflueger",
        reelSerialNumber: "123ABC",
        reelSize: "3000",
        lineMakeModel: "FireLine Crystal",
        lineRating: MultiMeasurement(
          mainValue: Measurement(
            unit: Unit.pound_test,
            value: 8,
          ),
        ),
        lineColor: "Mono",
        leaderLength: MultiMeasurement(
          mainValue: Measurement(
            unit: Unit.feet,
            value: 15,
          ),
        ),
        leaderRating: MultiMeasurement(
          mainValue: Measurement(
            unit: Unit.pound_test,
            value: 15,
          ),
        ),
        tippetLength: MultiMeasurement(
          mainValue: Measurement(
            unit: Unit.inches,
            value: 24,
          ),
        ),
        tippetRating: MultiMeasurement(
          mainValue: Measurement(
            unit: Unit.x,
            value: 2,
          ),
        ),
        hookMakeModel: "Mustad Demon",
        hookSize: MultiMeasurement(
          mainValue: Measurement(
            unit: Unit.hashtag,
            value: 6,
          ),
        ),
      )),
    );

    expect(find.byType(BlurredBackgroundPhoto), findsOneWidget);
    expect(find.text("Bass Rod"), findsOneWidget);
    expect(find.text("Ugly Stick"), findsOneWidget);
    expect(find.text("Serial Number: ABC123"), findsOneWidget);
    expect(find.text("9 ft, Fast, Light"), findsOneWidget);
    expect(find.text("Pflueger"), findsOneWidget);
    expect(find.text("Serial Number: 123ABC"), findsOneWidget);
    expect(find.text("Size: 3000"), findsOneWidget);
    expect(find.text("FireLine Crystal"), findsOneWidget);
    expect(find.text("8 lb test, Mono"), findsOneWidget);
    expect(find.text("Leader: 15 ft, 15 lb test"), findsOneWidget);
    expect(find.text("Tippet: 24 in, 2X"), findsOneWidget);
    expect(find.text("Mustad Demon"), findsOneWidget);
    expect(find.text("Size: #6"), findsOneWidget);
  });

  testWidgets("Only required fields are set", (tester) async {
    await pumpContext(
      tester,
      (context) => GearPage(Gear(
        id: randomId(),
        name: "Bass Rod",
      )),
    );
    expect(find.text("Bass Rod"), findsOneWidget);
    expect(find.byType(IconList), findsNothing);
    expect(find.byType(BlurredBackgroundPhoto), findsNothing);
  });
}
