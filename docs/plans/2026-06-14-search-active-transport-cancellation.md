# Android Search Active Transport Cancellation

Status: Completed

## Problem

Replacing or pausing a search calls `AsyncTask.cancel(true)` and prevents stale
UI delivery, but the active Apache `HttpGet` and image `HttpsURLConnection`
remain unowned by cancellation. A superseded task can therefore keep a socket,
response stream, and decoder work alive until the configured timeout.

## Requirements

1. Bind each search task to its currently executing `HttpGet` and abort that
   request before cancelling the task.
2. Bind each image task to its currently executing `HttpsURLConnection` and
   disconnect it before cancelling the task.
3. Close the publication race by checking cancellation before transport
   creation and immediately after publishing transport ownership.
4. Clear transport ownership only when the completing operation still owns the
   same object.
5. Preserve timeouts, redirect rejection, response limits, media validation,
   strict UTF-8, stale-result guards, error rendering, and lifecycle behavior.
6. Add mutation-sensitive portable contracts, maintenance guidance, and
   truthful verification evidence.

## Implementation Units

### 1. Abort active search requests

Files:

- `app/src/main/java/gpj/androidsearch/NetworkRequest.java`
- `app/src/main/java/gpj/androidsearch/MainActivity.java`

Track the active `HttpGet` with volatile visibility, guard publication against
already-cancelled tasks, abort the owned request, and have activity cancellation
use the transport-aware method.

### 2. Disconnect active image requests

Files:

- `app/src/main/java/gpj/androidsearch/MainActivity.java`

Track the active HTTPS connection, close the pre-publication cancellation race,
disconnect before task cancellation, and clear ownership in `finally`.

### 3. Protect cancellation ownership

Files:

- `scripts/check-baseline.sh`
- `README.md`
- `SECURITY.md`
- `VISION.md`
- `CHANGES.md`
- `docs/plans/2026-06-14-search-active-transport-cancellation.md`

Require abort/disconnect ordering, race checks, identity-based cleanup,
documentation, and completed verification evidence.

## Verification

- `sh -n scripts/check-baseline.sh`, portable source contracts, bounded
  response-body tests, and media-type tests passed.
- With Amazon Corretto 8 and the Android API 22 SDK,
  `./gradlew lint test assembleDebug --no-daemon` passed debug/release
  compilation, zero-issue lint, both unit-test variants, and debug APK
  assembly.
- Repository-root `make check` passed with the API 22 SDK configured, and an
  external-directory invocation passed with SDK variables unset to exercise
  the location-independent portable path.
- Ten isolated mutations were rejected for search abort ordering, late search
  publication, search ownership clearing, image disconnect ordering, late
  image publication, image ownership clearing, caller integration,
  documentation, and completed plan evidence.

## Scope Boundaries

- Do not migrate AsyncTask or the legacy HTTP stack in this focused change.
- Do not change endpoints, payloads, timeouts, limits, parsing, or UI output.
- Do not claim live backend, controlled-network, emulator, or device execution.
- Do not merge or close any pull request without explicit authorization.
