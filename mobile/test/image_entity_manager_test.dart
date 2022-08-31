import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';

void main() {
  late StubbedAppManager appManager;

  // Use real ImageEntityManager subclass for testing.
  late BaitManager baitManager;

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.baitCategoryManager.listen(any))
        .thenAnswer((_) => MockStreamSubscription());

    when(appManager.localDatabaseManager.insertOrReplace(any, any))
        .thenAnswer((_) => Future.value(true));

    when(appManager.subscriptionManager.stream)
        .thenAnswer((_) => const Stream.empty());
    when(appManager.subscriptionManager.isPro).thenReturn(false);

    baitManager = BaitManager(appManager.app);
  });

  test("Add without image", () async {
    await baitManager.addOrUpdate(Bait()
      ..id = randomId()
      ..name = "Rapala");
    verifyNever(
        appManager.imageManager.save(any, compress: anyNamed("compress")));
  });

  test("Add with image; error saving", () async {
    when(appManager.imageManager.save(any, compress: anyNamed("compress")))
        .thenAnswer((_) => Future.value([]));

    var id = randomId();
    await baitManager.addOrUpdate(
      Bait()
        ..id = id
        ..name = "Rapala"
        ..imageName = "123123123",
      imageFile: File("123123123.jpg"),
    );

    verify(appManager.imageManager.save(any, compress: anyNamed("compress")))
        .called(1);

    var bait = baitManager.entity(id);
    expect(bait, isNotNull);
    expect(bait!.hasImageName(), isFalse);
  });

  test("Add with image", () async {
    when(appManager.imageManager.save(any, compress: anyNamed("compress")))
        .thenAnswer((_) => Future.value(["123123123"]));

    var id = randomId();
    await baitManager.addOrUpdate(
      Bait()
        ..id = id
        ..name = "Rapala",
      imageFile: File("123123123.jpg"),
    );

    verify(appManager.imageManager.save(any, compress: anyNamed("compress")))
        .called(1);

    var bait = baitManager.entity(id);
    expect(bait, isNotNull);
    expect(bait!.hasImageName(), isTrue);
  });
}
