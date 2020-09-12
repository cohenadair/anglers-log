#!/usr/bin/env bash

protoc320 --dart_out=../lib/model/gen/ \
  anglerslog.proto \
  /usr/local/include/google/protobuf/timestamp.proto