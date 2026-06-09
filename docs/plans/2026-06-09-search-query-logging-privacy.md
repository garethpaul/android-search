---
title: Search Query Logging Privacy
type: privacy
status: completed
date: 2026-06-09
---

# Search Query Logging Privacy

## Problem Frame

Search queries can contain personal information. `NetworkRequest` currently logs
the fully built request URL and raw response body, which can expose query text
or returned content through device logs.

## Scope Boundaries

- Preserve endpoint, URL encoding, timeout, request, and response fallback
  behavior.
- Keep operational error logs for transport and parse failures.
- Do not migrate networking APIs or change UI rendering in this pass.

## Implementation Units

### U1: Remove Sensitive Success-Path Logs

Files:

- Modify `app/src/main/java/gpj/androidsearch/NetworkRequest.java`

Approach:

- Remove the full URL debug log.
- Remove the raw response-body log.
- Keep failure logs that do not include query text or response bodies.

### U2: Extend SDK-Free Baseline Checks

Files:

- Modify `scripts/check-baseline.sh`

Approach:

- Assert that full URL and response body logs are absent.
- Keep existing endpoint, encoding, timeout, and fallback checks intact.

### U3: Document The Privacy Guard

Files:

- Modify `README.md`
- Modify `CHANGES.md`
- Modify `VISION.md`

Approach:

- Record that baseline checks guard against logging full query URLs or response
  bodies.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`
