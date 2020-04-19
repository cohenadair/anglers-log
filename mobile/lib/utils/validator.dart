import 'package:flutter/cupertino.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:quiver/strings.dart';

/// A function called to validate input. A function is used so pass a
/// [BuildContext] instance for using localized strings.
typedef String ValidationCallback(BuildContext context);

abstract class Validator {
  ValidationCallback run(BuildContext context, String newValue);
}

/// A generic validator used for inline validator creation.
class GenericValidator implements Validator {
  final ValidationCallback Function(BuildContext, String) runner;

  GenericValidator({@required this.runner}) : assert(runner != null);

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

  final String nameExistsMessage;
  final bool Function(String) nameExists;

  NameValidator({
    @required this.nameExistsMessage,
    @required this.nameExists,
    this.oldName,
  });

  @override
  ValidationCallback run(BuildContext context, String newName) {
    if (oldName != null && isEqualTrimmedLowercase(oldName, newName)) {
      return null;
    } else if (isEmpty(newName)) {
      return (context) => Strings.of(context).inputGenericRequired;
    } else if (nameExists(newName)) {
      return (context) => nameExistsMessage;
    } else {
      return null;
    }
  }
}

class DoubleValidator implements Validator {
  @override
  ValidationCallback run(BuildContext context, String newValue) {
    if (double.tryParse(newValue) == null) {
      return (context) => Strings.of(context).inputInvalidNumber;
    }
    return null;
  }
}