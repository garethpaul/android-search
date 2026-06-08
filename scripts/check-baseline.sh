#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
NETWORK_REQUEST="$ROOT_DIR/app/src/main/java/gpj/androidsearch/NetworkRequest.java"
APP_BUILD="$ROOT_DIR/app/build.gradle"

if ! grep -Fq 'buildToolsVersion "24.0.3"' "$APP_BUILD"; then
  printf '%s\n' "Android build-tools must stay pinned to 24.0.3 for 64-bit aapt." >&2
  exit 1
fi

if ! grep -Fq 'static final String SEARCH_ENDPOINT = "https://garethpaul-app.appspot.com/api/search?q="' "$NETWORK_REQUEST"; then
  printf '%s\n' "Search endpoint constant is missing or changed." >&2
  exit 1
fi

if ! grep -Fq 'URLEncoder.encode(query, "UTF-8")' "$NETWORK_REQUEST"; then
  printf '%s\n' "Search query must be URL-encoded with UTF-8." >&2
  exit 1
fi

if grep -Fq '"https://garethpaul-app.appspot.com/api/search?q=" + query' "$NETWORK_REQUEST"; then
  printf '%s\n' "Search request must not concatenate raw query text into the URL." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the SDK-free baseline check." >&2
  exit 1
fi

if ! grep -Fq "Android build-tools 24.0.3" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the pinned Android build-tools version." >&2
  exit 1
fi

printf '%s\n' "Android search baseline checks passed."
