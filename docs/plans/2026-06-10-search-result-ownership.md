# Android Search Result Ownership

Status: Completed

## Context

Each search and result image launched an independent `AsyncTask`. A slower old
request could complete after a newer query and overwrite the current text or
image, while a result without an image left the prior bitmap visible. Tasks also
remained eligible to update views after the activity paused.

## Changes

- Retain one active search request and one active image request.
- Cancel superseded work before starting a new search and when the activity
  pauses.
- Require completion callbacks to still own the active task slot before
  updating UI.
- Clear the prior result image before optionally downloading a replacement.
- Extend the SDK-free baseline with task ownership and cancellation contracts.

## Verification

- `make check`
- Static mutations for removed search identity and image-clear guards
- `git diff --check`

The Android SDK is unavailable on this host, so lifecycle and rapid-query races
still require verification with a compatible Android toolchain.
