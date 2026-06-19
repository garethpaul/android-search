# Require Successful JSON HTTP Status

Status: Completed

## Context

The JSON response handler rejects statuses at or above 300 but accepts
informational `1xx` responses. Search payloads should be read and parsed only
from final successful `2xx` responses, matching the image transport boundary.

## Scope

- Reject JSON response statuses below 200 and at or above 300.
- Perform the status decision before entity, media-type, stream, or body access.
- Preserve redirect rejection, response limits, strict UTF-8, transport
  cancellation, generic errors, and existing UI behavior.
- Add mutation-sensitive portable contracts and maintenance documentation.

## Verification

- Run SDK-backed repository `make check` and the external-directory portable
  gate with SDK variables unset.
- Reject mutations that restore informational-status acceptance, weaken the
  upper bound or ordering, remove documentation, or reopen this plan.
- Audit exact paths, generated artifacts, changed-line secret patterns, and
  whitespace before commit.

## Risks

- No live backend, proxy, or controlled informational response was exercised.
- Existing stacked pull requests remain open and require explicit owner
  authorization before merge or closure.

## Verification Results

Completed on 2026-06-14:

- SDK-backed `make check` passed source contracts, debug and release Java
  compilation, zero-issue Android lint, bounded response and media-type tests,
  both Gradle unit-test variants, and debug APK assembly under Amazon Corretto
  8 and Android API 22.
- External-working-directory `make check` passed with Android SDK variables
  intentionally unset.
- Eight hostile mutations covering lower and upper status bounds, pre-entity
  ordering, maintained documentation, and completed-plan status were rejected.
- Exact diff, generated-artifact, changed-line secret-pattern, and whitespace
  audits passed before commit.
- No live backend, proxy, or controlled informational response was exercised.
