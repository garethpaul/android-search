# Search Asynchronous Results

Status: Completed

## Goal

Keep remote search I/O off the activity thread and avoid applying late results
after the activity has begun teardown.

## Requirements

- Reject null and whitespace-only queries before network dispatch.
- Do not call `AsyncTask.get()` from search intent handling.
- Render JSON results from `onPostExecute`.
- Ignore callbacks when the activity is finishing or destroyed.
- Preserve existing response fallback and optional image behavior.
- Enforce the behavior with the SDK-free baseline.
- Make root checks location-independent and accept either Android SDK variable.
- Pin hosted verification and cancel superseded runs.

## Implementation

- Override `NetworkRequest.onPostExecute` at the activity call site.
- Extract `displaySearchResult` from the former blocking try/catch block.
- Trim the query before dispatch and show the existing failure state for blank
  input.
- Remove blocking-task exception imports and handling.
- Extend `scripts/check-baseline.sh` with asynchronous, rooted `Makefile`, and
  CI contracts.

## Verification

- `make check`
- `make -f /absolute/path/to/Makefile check` from outside the repository
- asynchronous-result and automation mutation checks
- `sh -n scripts/check-baseline.sh`
- `git diff --check`

The Android SDK and backend are unavailable on this host, so runtime UI and
network behavior still require verification with the legacy-compatible stack.
