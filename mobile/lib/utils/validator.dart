import 'package:flutter/cupertino.dart';
import 'package:quiver/strings.dart';

import '../i18n/strings.dart';
import '../utils/string_utils.dart';

/// A function called to validate input. A function is used so pass a
/// [BuildContext] instance for using localized strings.
typedef ValidationCallback = String Function(BuildContext context);

// ignore: one_member_abstracts
abstract class Validator {
  ValidationCallback run(BuildContext context, String newValue);
}

/// A generic validator used for inline validator creation.
class GenericValidator implements Validator {
  final ValidationCallback Function(BuildContext, String) runner;

  GenericValidator(this.runner) : assert(runner != null);

  ValidationCallback run(BuildContext context, String newValue) {
    return runner(context, newValue);
  }
}

/// A [Validator] for validating name inputs. This validator checks:
///   - Whether the new name equals the old name
///   - Whether the name is empty
///   - Whether the name exists via [nameExists].
class NameValidator implements Validator {
  /// If non-null, input equal to [oldName] is considered valid.
  final String oldName;

  final String Function(BuildContext) nameExistsMessage;
  final bool Function(String) nameExists;

  NameValidator({
    this.nameExistsMessage,
    this.nameExists,
    this.oldName,
  }) : assert((nameExists != null && nameExistsMessage != null) ||
            (nameExists == null && nameExistsMessage == null));

  @override
  ValidationCallback run(BuildContext context, String newName) {
    if (!isEmpty(oldName) && equalsTrimmedIgnoreCase(oldName, newName)) {
      return null;
    } else if (isEmpty(newName)) {
      return (context) => Strings.of(context).inputGenericRequired;
    } else if (nameExists != null && nameExists(newName)) {
      return nameExistsMessage;
    } else {
      return null;
    }
  }
}

class DoubleValidator implements Validator {
  @override
  ValidationCallback run(BuildContext context, String newValue) {
    if (isNotEmpty(newValue) && double.tryParse(newValue) == null) {
      return (context) => Strings.of(context).inputInvalidNumber;
    }
    return null;
  }
}

class EmailValidator implements Validator {
  final bool required;

  EmailValidator({
    this.required = false,
  });

  @override
  ValidationCallback run(BuildContext context, String newValue) {
    if (!required && isEmpty(newValue)) {
      return null;
    }

    if (required && isEmpty(newValue)) {
      return (context) => Strings.of(context).inputGenericRequired;
    }

    if (newValue == null ||
        !RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
            .hasMatch(newValue)) {
      return (context) => Strings.of(context).inputInvalidEmail;
    }

    return null;
  }
}

class PasswordValidator implements Validator {
  static const _minPasswordLength = 6;

  @override
  ValidationCallback run(BuildContext context, String newValue) {
    if (isEmpty(newValue)) {
      return (context) => Strings.of(context).inputGenericRequired;
    }

    if (newValue.length < _minPasswordLength) {
      return (context) => Strings.of(context).inputPasswordInvalidLength;
    }

    return null;
  }
}

/// A validator that ensures input is not empty.
class EmptyValidator implements Validator {
  @override
  ValidationCallback run(BuildContext context, String newValue) {
    if (isNotEmpty(newValue)) {
      return null;
    }
    return (context) => Strings.of(context).inputGenericRequired;
  }
}
