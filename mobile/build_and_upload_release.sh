#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Apple/Google Play secrets live in this local, gitignored file — see
# release_credentials.sh.example for the template.
credentials_file="release_credentials.sh"
if [[ ! -f "$credentials_file" ]]; then
  echo "Error: $credentials_file not found." >&2
  echo "Copy release_credentials.sh.example to $credentials_file and fill in real values." >&2
  exit 1
fi
# shellcheck source=/dev/null
source "$credentials_file"

export ANDROID_PACKAGE_NAME=com.cohenadair.anglerslog

# Extra args (--version=, --skip-upload, a platform subset for a retry, etc.)
# are passed straight through to the root script. If none of them is a
# platform, default to building/uploading both, same as always — checking
# for $# -eq 0 alone wouldn't catch e.g. `--version=1.2.3` with no platform.
has_platform=false
for arg in "$@"; do
  if [[ "$arg" == "ios" || "$arg" == "macos" || "$arg" == "android" ]]; then
    has_platform=true
    break
  fi
done
if [[ "$has_platform" != "true" ]]; then
  set -- "$@" ios android
fi

../../build_and_upload_release.sh "$@"
