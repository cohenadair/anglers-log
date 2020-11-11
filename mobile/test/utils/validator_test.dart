import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/validator.dart';

import '../test_utils.dart';

main() {
  group("GenericValidator", () {
    testWidgets("Runner is called", (WidgetTester tester) async {
      BuildContext context = await buildContext(tester);
      bool ran = false;
      GenericValidator((_, __) => (___) {
        ran = true;
        return null;
      }).run(context, "")(context);
      expect(ran, isTrue);
    });
  });

  group("NameValidator", () {
    testWidgets("Input", (WidgetTester tester) async {
      BuildContext context = await buildContext(tester);
      expect(NameValidator().run(context, "Test"), isNull);
      expect(() => NameValidator(
        nameExists: (_) => false,
        nameExistsMessage: null,
      ), throwsAssertionError);
      expect(NameValidator(
        nameExists: (_) => false,
        nameExistsMessage: (_) => "Message",
      ).run(context, "Test"), isNull);
    });

    testWidgets("null if old name == new name", (WidgetTester tester) async {
      BuildContext context = await buildContext(tester);
      expect(NameValidator(
        nameExists: (_) => false,
        nameExistsMessage: (_) => "Message",
        oldName: "Test",
      ).run(context, "Test"), isNull);
    });

    testWidgets("Error if new name is empty/null", (WidgetTester tester) async {
      BuildContext context = await buildContext(tester);
      expect(NameValidator(
        nameExists: (_) => false,
        nameExistsMessage: (_) => "Message",
      ).run(context, "")(context), "Required");
      expect(NameValidator(
        nameExists: (_) => false,
        nameExistsMessage: (_) => "Message",
      ).run(context, null)(context), "Required");
    });

    testWidgets("Error if new name exists", (WidgetTester tester) async {
      BuildContext context = await buildContext(tester);
      expect(NameValidator(
        nameExists: (_) => true,
        nameExistsMessage: (_) => "Exists",
      ).run(context, "Test")(context), "Exists");
    });

    testWidgets("null if valid", (WidgetTester tester) async {
      BuildContext context = await buildContext(tester);
      expect(NameValidator(
        nameExists: (_) => false,
        nameExistsMessage: (_) => "Exists",
        oldName: "Test",
      ).run(context, "Test 2"), isNull);
    });
  });

  group("DoubleValidator", () {
    testWidgets("Error if parse fails", (WidgetTester tester) async {
      BuildContext context = await buildContext(tester);
      expect(DoubleValidator().run(context, "Not a double")(context),
          "Invalid number input");
    });

    testWidgets("null if valid", (WidgetTester tester) async {
      BuildContext context = await buildContext(tester);
      expect(DoubleValidator().run(context, ""), isNull);
      expect(DoubleValidator().run(context, null), isNull);
      expect(DoubleValidator().run(context, "50.2"), isNull);
    });
  });

  group("EmailValidator", () {
    testWidgets("Error if invalid format", (WidgetTester tester) async {
      BuildContext context = await buildContext(tester);
      expect(EmailValidator().run(context, "not a valid email")(context),
          "Invalid email");
    });

    testWidgets("null if valid email", (WidgetTester tester) async {
      BuildContext context = await buildContext(tester);
      expect(EmailValidator().run(context, "test@test.com"), isNull);
    });

    testWidgets("null if empty and not required", (WidgetTester tester) async {
      BuildContext context = await buildContext(tester);
      expect(EmailValidator(required: false).run(context, ""), isNull);
      expect(EmailValidator(required: false).run(context, null), isNull);
    });

    testWidgets("Error if empty and required", (WidgetTester tester) async {
      BuildContext context = await buildContext(tester);
      expect(EmailValidator(required: true).run(context, "")(context),
          "Invalid email");
      expect(EmailValidator(required: true).run(context, null)(context),
          "Invalid email");
    });
  });

  group("EmptyValidator", () {
    testWidgets("Error if empty", (WidgetTester tester) async {
      BuildContext context = await buildContext(tester);
      expect(EmptyValidator().run(context, "")(context), "Required");
      expect(EmptyValidator().run(context, null)(context), "Required");
    });

    testWidgets("null if not empty", (WidgetTester tester) async {
      BuildContext context = await buildContext(tester);
      expect(EmptyValidator().run(context, "Not empty"), isNull);
    });
  });
}