import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/validator.dart';

import '../test_utils.dart';

void main() {
  group("GenericValidator", () {
    testWidgets("Runner is called", (tester) async {
      var context = await buildContext(tester);
      var ran = false;
      GenericValidator(
        (_, __) => (___) {
          ran = true;
          return null;
        },
      ).run(context, "")(context);
      expect(ran, isTrue);
    });
  });

  group("NameValidator", () {
    testWidgets("Input", (tester) async {
      var context = await buildContext(tester);
      expect(NameValidator().run(context, "Test"), isNull);
      expect(
        () => NameValidator(
          nameExists: (_) => false,
          nameExistsMessage: null,
        ),
        throwsAssertionError,
      );
      expect(
        NameValidator(
          nameExists: (_) => false,
          nameExistsMessage: (_) => "Message",
        ).run(context, "Test"),
        isNull,
      );
    });

    testWidgets("null if old name == new name", (tester) async {
      var context = await buildContext(tester);
      expect(
        NameValidator(
          nameExists: (_) => false,
          nameExistsMessage: (_) => "Message",
          oldName: "Test",
        ).run(context, "Test"),
        isNull,
      );
    });

    testWidgets("Error if new name is empty/null", (tester) async {
      var context = await buildContext(tester);
      expect(
        NameValidator(
          nameExists: (_) => false,
          nameExistsMessage: (_) => "Message",
        ).run(context, "")!(context),
        "Required",
      );
      expect(
        NameValidator(
          nameExists: (_) => false,
          nameExistsMessage: (_) => "Message",
        ).run(context, null)!(context),
        "Required",
      );
    });

    testWidgets("Error if new name exists", (tester) async {
      var context = await buildContext(tester);
      expect(
        NameValidator(
          nameExists: (_) => true,
          nameExistsMessage: (_) => "Exists",
        ).run(context, "Test")!(context),
        "Exists",
      );
    });

    testWidgets("null if valid", (tester) async {
      var context = await buildContext(tester);
      expect(
        NameValidator(
          nameExists: (_) => false,
          nameExistsMessage: (_) => "Exists",
          oldName: "Test",
        ).run(context, "Test 2"),
        isNull,
      );
    });
  });

  group("DoubleValidator", () {
    testWidgets("Error if parse fails", (tester) async {
      var context = await buildContext(tester);
      expect(DoubleValidator().run(context, "Not a double")!(context),
          "Invalid number input");
    });

    testWidgets("null if valid", (tester) async {
      var context = await buildContext(tester);
      expect(DoubleValidator().run(context, ""), isNull);
      expect(DoubleValidator().run(context, null), isNull);
      expect(DoubleValidator().run(context, "50.2"), isNull);
    });
  });

  group("EmailValidator", () {
    testWidgets("Error if invalid format", (tester) async {
      var context = await buildContext(tester);
      expect(EmailValidator().run(context, "not a valid email")!(context),
          "Invalid email format");
    });

    testWidgets("null if valid email", (tester) async {
      var context = await buildContext(tester);
      expect(EmailValidator().run(context, "test@test.com"), isNull);
    });

    testWidgets("null if empty and not required", (tester) async {
      var context = await buildContext(tester);
      expect(EmailValidator(required: false).run(context, ""), isNull);
      expect(EmailValidator(required: false).run(context, null), isNull);
    });

    testWidgets("Error if empty and required", (tester) async {
      var context = await buildContext(tester);
      expect(EmailValidator(required: true).run(context, "")!(context),
          "Required");
      expect(EmailValidator(required: true).run(context, null)!(context),
          "Required");
    });
  });

  group("EmptyValidator", () {
    testWidgets("Error if empty", (tester) async {
      var context = await buildContext(tester);
      expect(EmptyValidator().run(context, "")!(context), "Required");
      expect(EmptyValidator().run(context, null)!(context), "Required");
    });

    testWidgets("null if not empty", (tester) async {
      var context = await buildContext(tester);
      expect(EmptyValidator().run(context, "Not empty"), isNull);
    });
  });

  group("PasswordValidator", () {
    testWidgets("Error if empty", (tester) async {
      var context = await buildContext(tester);
      expect(PasswordValidator().run(context, ""), isNotNull);
      expect(PasswordValidator().run(context, null), isNotNull);
    });

    testWidgets("Error if too short", (tester) async {
      var context = await buildContext(tester);
      expect(PasswordValidator().run(context, "12345"), isNotNull);
    });

    testWidgets("Valid password", (tester) async {
      var context = await buildContext(tester);
      expect(PasswordValidator().run(context, "123456"), isNull);
    });
  });

  group("RangeValidator", () {
    testWidgets("Error if empty", (tester) async {
      var context = await buildContext(tester);
      expect(RangeValidator().run(context, ""), isNotNull);
      expect(RangeValidator().run(context, null), isNotNull);
    });

    testWidgets("Error if bad double", (tester) async {
      var context = await buildContext(tester);
      expect(RangeValidator().run(context, "Not a number"), isNotNull);
    });

    testWidgets("Runner called", (tester) async {
      var context = await buildContext(tester);
      var called = false;
      expect(
          RangeValidator(
            runner: (context, newValue) {
              called = true;
              return (context) {
                return "This is an error!";
              };
            },
          ).run(context, "2"),
          isNotNull);
      expect(called, isTrue);
    });

    testWidgets("Null runner", (tester) async {
      var context = await buildContext(tester);
      expect(RangeValidator().run(context, "2.0"), isNull);
    });
  });
}
