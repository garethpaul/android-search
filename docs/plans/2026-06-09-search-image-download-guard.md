---
title: Search Image Download Guard
type: security
status: completed
date: 2026-06-09
---

# Search Image Download Guard

## Problem Frame

The search UI decodes an image URL returned by the backend. The previous
`DownloadImageTask` opened that URL directly, accepted any supported URL scheme,
had no connection or read timeout, and printed stack traces on failure.

## Scope Boundaries

- Preserve the existing search endpoint, response fields, and bitmap rendering
  behavior.
- Do not add a new image loading library or broad networking abstraction.
- Keep verification available through the SDK-free baseline script.

## Implementation Units

### U1: Validate And Bound Image Downloads

Files:

- Modify `app/src/main/java/gpj/androidsearch/MainActivity.java`

Approach:

- Trim and reject missing image URL inputs.
- Parse result image URLs through a helper that requires HTTPS.
- Use `URLConnection` with bounded connection and read timeouts before decoding.
- Replace stack-trace logging with sanitized Android log messages.

### U2: Extend Static Baseline Checks

Files:

- Modify `scripts/check-baseline.sh`

Approach:

- Assert that HTTPS validation, timeout configuration, and `URLConnection`
  stream handling stay present.
- Reject direct `new URL(...).openStream()` image downloads.
- Reject `printStackTrace()` in the search activity.

### U3: Document The Guardrail

Files:

- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Record that backend-provided image URLs must be HTTPS and timeout-bounded.
- Keep broader image caching or networking modernization separate from this
  safety pass.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`
