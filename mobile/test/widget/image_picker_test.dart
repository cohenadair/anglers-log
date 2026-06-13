import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart' as ip;
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/widgets/image_picker.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../../../../adair-flutter-lib/test/test_utils/widget.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);
    when(
      managers.lib.permissionHandlerWrapper.requestPhotos(),
    ).thenAnswer((_) => Future.value(true));

    when(
      managers.photoManagerWrapper.getAllAssetPathEntity(any),
    ).thenAnswer((_) => Future.value(null));
  });

  testWidgets("Enabled", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ImagePicker(onImagesPicked: (_) {}, onImageDeleted: (_) {}),
      ),
    );

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    expect(find.byType(ImagePickerPage), findsOneWidget);
  });

  testWidgets("Disabled", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ImagePicker(
          onImagesPicked: (_) {},
          onImageDeleted: (_) {},
          isEnabled: false,
        ),
      ),
    );

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    expect(find.byType(ImagePickerPage), findsNothing);
  });

  testWidgets("Single selection", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ImagePicker(
          onImagesPicked: (_) {},
          onImageDeleted: (_) {},
          isMulti: false,
        ),
      ),
    );
    expect(find.text("Photo"), findsOneWidget);
    expect(find.text("Add Photos"), findsNothing);
  });

  testWidgets("Multiple selection", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ImagePicker(onImagesPicked: (_) {}, onImageDeleted: (_) {}),
      ),
    );
    expect(find.text("Add Photos"), findsOneWidget);
    expect(find.text("Photo"), findsNothing);
  });

  testWidgets("No images", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ImagePicker(onImagesPicked: (_) {}, onImageDeleted: (_) {}),
      ),
    );
    expect(find.byType(Image), findsNothing);
    expect(find.byType(SizedBox), findsNWidgets(2));
  });

  testWidgets("At least one image, enabled", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ImagePicker(
          onImagesPicked: (_) {},
          onImageDeleted: (_) {},
          initialImages: {
            PickedImage(originalFile: File("test/resources/flutter_logo.png")),
            PickedImage(originalFile: File("test/resources/android_logo.png")),
          },
        ),
      ),
    );

    expect(find.byType(Image), findsNWidgets(2));
    expect(findFirst<ListView>(tester).physics, isNull);
  });

  testWidgets("At least one image, disabled", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ImagePicker(
          onImagesPicked: (_) {},
          onImageDeleted: (_) {},
          initialImages: {
            PickedImage(originalFile: File("test/resources/flutter_logo.png")),
            PickedImage(originalFile: File("test/resources/android_logo.png")),
          },
          isEnabled: false,
        ),
      ),
    );

    expect(find.byType(Image), findsNWidgets(2));
    expect(findFirst<ListView>(tester).physics, isNotNull);
  });

  testWidgets("Load from file", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ImagePicker(
          onImagesPicked: (_) {},
          onImageDeleted: (_) {},
          initialImages: {
            PickedImage(originalFile: File("test/resources/flutter_logo.png")),
          },
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets("Load from memory", (tester) async {
    await tester.pumpWidget(
      Testable(
        (_) => ImagePicker(
          onImagesPicked: (_) {},
          onImageDeleted: (_) {},
          initialImages: {
            PickedImage(
              thumbData: File(
                "test/resources/flutter_logo.png",
              ).readAsBytesSync(),
            ),
          },
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets("onImageDeleted callback invoked", (tester) async {
    bool invoked = false;

    await tester.pumpWidget(
      Testable(
        (_) => ImagePicker(
          onImagesPicked: (_) {},
          onImageDeleted: (_) => invoked = true,
          initialImages: {
            PickedImage(
              thumbData: File(
                "test/resources/flutter_logo.png",
              ).readAsBytesSync(),
            ),
          },
        ),
      ),
    );

    // Delete photo.
    await tapAndSettle(tester, find.byIcon(Icons.close));
    await tapAndSettle(tester, find.text("DELETE"));
    expect(invoked, isTrue);
  });

  testWidgets("Android tap shows source selection bottom sheet", (
    tester,
  ) async {
    when(managers.lib.ioWrapper.isAndroid).thenReturn(true);
    when(managers.lib.ioWrapper.isIOS).thenReturn(false);

    await pumpContext(
      tester,
      (_) => ImagePicker(onImagesPicked: (_) {}, onImageDeleted: (_) {}),
    );

    await tapAndSettle(tester, find.byType(InkWell));

    expect(find.text("Gallery"), findsOneWidget);
    expect(find.text("Camera"), findsOneWidget);
    expect(find.text("Browse"), findsOneWidget);
    expect(find.text("No Photo"), findsNothing);
  });

  testWidgets("Android dismissed bottom sheet does not invoke onImagesPicked", (
    tester,
  ) async {
    when(managers.lib.ioWrapper.isAndroid).thenReturn(true);
    when(managers.lib.ioWrapper.isIOS).thenReturn(false);

    var invoked = false;
    await pumpContext(
      tester,
      (_) => ImagePicker(
        onImagesPicked: (_) => invoked = true,
        onImageDeleted: (_) {},
      ),
    );

    await tapAndSettle(tester, find.byType(InkWell));

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(invoked, isFalse);
  });

  testWidgets("Android empty gallery result does not invoke onImagesPicked", (
    tester,
  ) async {
    when(managers.lib.ioWrapper.isAndroid).thenReturn(true);
    when(managers.lib.ioWrapper.isIOS).thenReturn(false);
    when(
      managers.lib.permissionHandlerWrapper.requestAccessMediaLocation(),
    ).thenAnswer((_) => Future.value(true));
    when(
      managers.imagePickerWrapper.pickMultiImage(),
    ).thenAnswer((_) => Future.value([]));

    var invoked = false;
    await pumpContext(
      tester,
      (_) => ImagePicker(
        onImagesPicked: (_) => invoked = true,
        onImageDeleted: (_) {},
      ),
    );

    await tapAndSettle(tester, find.byType(InkWell));
    await tapAndSettle(tester, find.text("Gallery"));
    await tester.pumpAndSettle();

    expect(invoked, isFalse);
  });

  testWidgets(
    "Android multi-select invokes onImagesPicked with merged images",
    (tester) async {
      when(managers.lib.ioWrapper.isAndroid).thenReturn(true);
      when(managers.lib.ioWrapper.isIOS).thenReturn(false);
      when(
        managers.lib.permissionHandlerWrapper.requestAccessMediaLocation(),
      ).thenAnswer((_) => Future.value(true));
      when(managers.imagePickerWrapper.pickMultiImage()).thenAnswer(
        (_) => Future.value([ip.XFile("test/resources/android_logo.png")]),
      );

      var exif = MockExif();
      when(exif.getLatLong()).thenAnswer((_) => Future.value(null));
      when(exif.getOriginalDate()).thenAnswer((_) => Future.value(null));
      when(
        managers.exifWrapper.fromPath(any),
      ).thenAnswer((_) => Future.value(exif));

      Set<PickedImage>? result;
      await pumpContext(
        tester,
        (_) => ImagePicker(
          isMulti: true,
          onImagesPicked: (images) => result = images,
          onImageDeleted: (_) {},
          initialImages: {
            PickedImage(originalFile: File("test/resources/flutter_logo.png")),
          },
        ),
      );

      await tapAndSettle(tester, find.byType(InkWell).first);
      await tapAndSettle(tester, find.text("Gallery"));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.length, 2);
    },
  );

  testWidgets(
    "Android single-select invokes onImagesPicked with only new images",
    (tester) async {
      when(managers.lib.ioWrapper.isAndroid).thenReturn(true);
      when(managers.lib.ioWrapper.isIOS).thenReturn(false);
      when(
        managers.lib.permissionHandlerWrapper.requestAccessMediaLocation(),
      ).thenAnswer((_) => Future.value(true));
      when(managers.imagePickerWrapper.pickImage(any)).thenAnswer(
        (_) => Future.value(ip.XFile("test/resources/android_logo.png")),
      );

      var exif = MockExif();
      when(exif.getLatLong()).thenAnswer((_) => Future.value(null));
      when(exif.getOriginalDate()).thenAnswer((_) => Future.value(null));
      when(
        managers.exifWrapper.fromPath(any),
      ).thenAnswer((_) => Future.value(exif));

      Set<PickedImage>? result;
      await pumpContext(
        tester,
        (_) => ImagePicker(
          isMulti: false,
          onImagesPicked: (images) => result = images,
          onImageDeleted: (_) {},
          initialImages: {
            PickedImage(originalFile: File("test/resources/flutter_logo.png")),
          },
        ),
      );

      await tapAndSettle(tester, find.byType(InkWell).first);
      await tapAndSettle(tester, find.text("Gallery"));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      // Single-select: only the newly picked image, not the initial one.
      expect(result!.length, 1);
      expect(result!.first.fileName, "android_logo.png");
    },
  );
}
