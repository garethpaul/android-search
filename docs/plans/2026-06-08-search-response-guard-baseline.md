# Search Response Guard Baseline

## Status: Completed

## Context

`android-search` is a legacy Android instant-search sample that sends user
queries to `https://garethpaul-app.appspot.com/api/search?q=` and displays JSON
response fields. The baseline already URL-encodes queries, but source checks now
also need to guard missing AsyncTask parameters, failed requests, and incomplete
JSON responses.

## Objectives

- Preserve the existing HTTPS backend endpoint and query parameter.
- Normalize missing search parameters before URL construction.
- Return explicit JSON error objects for failed network requests.
- Apply configured connection and socket timeouts to the legacy HTTP client.
- Tolerate missing response text or image fields in the UI.
- Skip image downloads when the response image URL is empty.
- Expose a root `make check` wrapper for the SDK-free baseline.

## Work Completed

- Added `queryFromParams` and `errorResult` helpers in `NetworkRequest`.
- Passed the configured HTTP params object to `DefaultHttpClient`.
- Updated `MainActivity` to use `optString` and guard empty image URLs.
- Extended `scripts/check-baseline.sh` to validate response handling and
  documented Gradle verification commands.
- Added `make check` as the root SDK-free verification wrapper.
- Updated README and CHANGES with the response-guard baseline.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew test --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
- `git diff --check`

## Follow-Up Candidates

- Replace deprecated Apache HTTP and AsyncTask usage in a behavior-aware pass.
- Add unit tests around URL construction and response parsing once the legacy
  Android test toolchain is modernized.
