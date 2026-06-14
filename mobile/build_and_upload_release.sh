#!/usr/bin/env bash
set -euo pipefail

export APPLE_ID=""
export APPLE_APP_SPECIFIC_PASSWORD=""
export APPLE_TEAM_ID=""
export GOOGLE_PLAY_JSON_KEY=anglers-log-release-pipeline-key.json
export ANDROID_PACKAGE_NAME=com.cohenadair.anglerslog

../../build_and_upload_release.sh ios android
