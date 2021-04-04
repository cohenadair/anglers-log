#!/usr/bin/env bash

protoc320 --dart_out=../lib/model/gen/ \
  anglerslog.proto

for f in $(find ../lib/model/gen -iname '*.dart'); do
  printf "// ignore_for_file: constant_identifier_names,lines_longer_than_80_chars,directives_ordering,prefer_mixin,implementation_imports\n" >> "$f"
done