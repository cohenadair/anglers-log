#!/usr/bin/env bash

protoc --dart_out=. anglerslog.proto

# Relative paths, for whatever reason, don't seem to work with --dart_out, so we move the generated files.
mv *.dart ../lib/model/gen/

for f in $(find ../lib/model/gen -iname '*.dart'); do
  printf "// ignore_for_file: undefined_named_parameter,no_leading_underscores_for_local_identifiers\n" >> "$f"
done