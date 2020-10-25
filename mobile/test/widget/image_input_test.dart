import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/pages/image_picker_page.dart';
import 'package:mobile/widgets/image_input.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

main() {
  testWidgets("Enabled", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => ImageInput(
      onImagesPicked: (_) => {},
      requestPhotoPermission: () => Future.value(true),
    )));

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    expect(find.byType(ImagePickerPage), findsOneWidget);
  });

  testWidgets("Disabled", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => ImageInput(
      onImagesPicked: (_) => {},
      requestPhotoPermission: () => Future.value(true),
      enabled: false,
    )));

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    expect(find.byType(ImagePickerPage), findsNothing);
  });

  testWidgets("Single selection", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => ImageInput.single(
      onImagePicked: (_) => {},
      requestPhotoPermission: () => Future.value(true),
    )));
    expect(find.text("Photo"), findsOneWidget);
    expect(find.text("Photos"), findsNothing);
  });

  testWidgets("Multiple selection", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => ImageInput(
      onImagesPicked: (_) => {},
      requestPhotoPermission: () => Future.value(true),
    )));
    expect(find.text("Photos"), findsOneWidget);
    expect(find.text("Photo"), findsNothing);
  });

  testWidgets("No images", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => ImageInput(
      onImagesPicked: (_) => {},
      requestPhotoPermission: () => Future.value(true),
    )));
    expect(find.byType(Image), findsNothing);
    expect(find.byType(Empty), findsOneWidget);
  });

  testWidgets("At least one image, enabled", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => ImageInput(
      onImagesPicked: (_) => {},
      requestPhotoPermission: () => Future.value(true),
      initialImages: [
        PickedImage(originalFile: File("test/resources/flutter_logo.png")),
        PickedImage(originalFile: File("test/resources/flutter_logo.png")),
      ],
    )));

    expect(find.byType(Image), findsNWidgets(2));
    expect(findFirst<ListView>(tester).physics, isNull);
  });

  testWidgets("At least one image, disabled", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => ImageInput(
      onImagesPicked: (_) => {},
      requestPhotoPermission: () => Future.value(true),
      initialImages: [
        PickedImage(originalFile: File("test/resources/flutter_logo.png")),
        PickedImage(originalFile: File("test/resources/flutter_logo.png")),
      ],
      enabled: false,
    )));

    expect(find.byType(Image), findsNWidgets(2));
    expect(findFirst<ListView>(tester).physics, isNotNull);
  });

  testWidgets("Load from file", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => ImageInput(
      onImagesPicked: (_) => {},
      requestPhotoPermission: () => Future.value(true),
      initialImages: [
        PickedImage(originalFile: File("test/resources/flutter_logo.png")),
      ],
    )));

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets("Load from memory", (WidgetTester tester) async {
    await tester.pumpWidget(Testable((_) => ImageInput(
      onImagesPicked: (_) => {},
      requestPhotoPermission: () => Future.value(true),
      initialImages: [
        PickedImage(
          thumbData: File("test/resources/flutter_logo.png").readAsBytesSync(),
        ),
      ],
    )));

    expect(find.byType(Image), findsOneWidget);
  });
}