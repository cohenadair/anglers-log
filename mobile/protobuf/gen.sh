#!/usr/bin/env bash

protoc --proto_path=. --proto_path=../../../adair-flutter-lib/protobuf/ --dart_out=. anglers_log.proto
protoc --dart_out=. user_polls.proto

# Relative paths, for whatever reason, don't seem to work with --dart_out, so we move the generated files.
mv *.dart ../lib/model/gen/

# Fix flutter lib's import statement.
find ../lib/model/gen/ -name "*.dart" -exec sed -i '' "s|import 'adair_flutter_lib\.pb\.dart' as \$0;|import 'package:adair_flutter_lib/model/gen/adair_flutter_lib.pb.dart' as \$0;|g" {} +