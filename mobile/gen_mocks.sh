#!/bin/bash
rm test/mocks/mocks.mocks.dart
flutter packages pub run build_runner build
sed -i "" "1s#^#// ignore_for_file: directives_ordering,avoid_equals_and_hash_code_on_mutable_classes,lines_longer_than_80_chars,subtype_of_sealed_class,unnecessary_overrides,must_be_immutable,duplicate_ignore,invalid_implementation_override\n#g" test/mocks/mocks.mocks.dart