# Search Response Redirect Rejection

Status: In Progress

## Problem

Search result images reject redirects, but the fixed HTTPS JSON search request
still uses Apache HttpClient's default redirect behavior. A redirect can move
the request away from the reviewed endpoint before the existing status, media
type, and response-body checks run.

## Requirements

1. Disable redirects on the search request parameters before constructing the
   HTTP client.
2. Preserve the fixed endpoint, URL encoding, timeouts, bounded JSON body,
   media-type validation, cleanup, and generic failure behavior.
3. Add a mutation-sensitive static contract for the redirect setting and its
   ordering relative to client construction and execution.
4. Keep image download behavior and public application APIs unchanged.

## Implementation Units

### U1: Reject Search Redirects

**File:** `app/src/main/java/gpj/androidsearch/NetworkRequest.java`

Set Apache HttpClient redirect handling to false on the request parameters
before the client is created.

### U2: Protect And Document

**Files:** `scripts/check-baseline.sh`, `AGENTS.md`, `README.md`, `SECURITY.md`,
`CHANGES.md`, this plan

Require the exact setting and ordering, document the trust boundary, and record
truthful bounded verification.

## Scope Boundaries

- Do not change image requests, JSON parsing, response limits, media types,
  timeouts, endpoint selection, dependencies, Gradle configuration, or UI.
- Do not claim emulator, device, or live service behavior.
- Do not merge or close any pull request without explicit authorization.

## Verification

- Pending implementation and bounded validation.
