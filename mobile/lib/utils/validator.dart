import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:quiver/strings.dart';

/// A function called to validate input. A function is used so pass a
/// [BuildContext] instance for using localized strings.
typedef String ValidationCallback(BuildContext context);

abstract class Validator {
  Future<ValidationCallback> run(BuildContext context, String newValue);
}

/// A generic validator used for inline validator creation.
class GenericValidator implements Validator {
  final Future<ValidationCallback> Function(BuildContext, String) runner;

  GenericValidator({@required this.runner}) : assert(runner != null);

  Future<ValidationCallback> run(BuildContext context, String newValue) {
    return runner(context, newValue);
  }
}

/// A [Validator] for validating name inputs. This validator checks:
///   - Whether the new name equals the old name
///   - Whether the name is empty
///   - Whether the name exists via [nameExistsFuture].
class NameValidator implements Validator {
  /// If non-null, input equal to [oldName] is considered valid.
  final String oldName;

  final String nameExistsMessage;
  final Future<bool> Function(String) nameExistsFuture;

  NameValidator({
    @required this.nameExistsMessage,
    @required this.nameExistsFuture,
    this.oldName,
  });

  @override
  Future<ValidationCallback> run(BuildContext context, String newName) async {
    if (oldName != null && isEqualTrimmedLowercase(oldName, newName)) {
      return null;
    } else if (isEmpty(newName)) {
      return (context) => Strings.of(context).inputGenericRequired;
    } else if (await nameExistsFuture(newName)) {
      return (context) => nameExistsMessage;
    } else {
      return null;
    }
  }
}

class DoubleValidator implements Validator {
  @override
  Future<ValidationCallback> run(BuildContext context, String newValue) {
    if (double.tryParse(newValue) == null) {
      return Future.value((context) => Strings.of(context).inputInvalidNumber);
    }
    return null;
  }
}