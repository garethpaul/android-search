# Issue 1: Handle Search Request Failures

## Context

GitHub issue: `garethpaul/android-search#1`

`NetworkRequest` previously wrapped the whole search request in a broad `Throwable` catch and printed stack traces. Failures could be swallowed without useful diagnostics, and `MainActivity` could continue as though a response existed.

## Plan

1. Validate the search query before building the request.
2. Catch expected encoding, protocol, I/O, and JSON failures explicitly with log context.
3. Return `null` on handled request failure and show a user-visible search failure message before reading fields.
4. Extend the baseline script and README verification notes for the failure-handling contract.

## Verification

- Run `bash scripts/check-baseline.sh`.
- Run `git diff --check`.
