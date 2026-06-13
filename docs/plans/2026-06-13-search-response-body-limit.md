# Bound Search Response Bodies

Status: Completed

## Context

The legacy search request uses `BasicResponseHandler`, which materializes the
entire successful HTTP entity before JSON parsing. A misconfigured or hostile
endpoint can therefore consume unbounded application memory even though the
request already has connection and socket timeouts.

## Requirements

- R1. Reject a response whose declared content length exceeds 64 KiB before
  reading its body.
- R2. Enforce the same 64 KiB limit while streaming responses with missing or
  inaccurate content lengths.
- R3. Accept a body exactly at the limit, decode accepted bytes as UTF-8, and
  close the response stream on success and failure.
- R4. Preserve HTTP status rejection, generic privacy-safe failure handling,
  request timeouts, client shutdown, asynchronous ownership, and JSON parsing.
- R5. Keep the helper independently executable on the host and compatible with
  the repository's Java 8/API 22 baseline.

## Implementation Units

### 1. Bounded byte reader

Files:
- `app/src/main/java/gpj/androidsearch/BoundedResponseBody.java`
- `scripts/test-bounded-response-body.sh`

Add a pure-Java helper that validates declared length, reads at most one byte
beyond the configured cap to detect overflow, and returns UTF-8 text. Cover
empty, exact-limit, over-limit, unknown-length, misleading-length, and invalid
limit cases with an executable host harness.

### 2. Legacy HTTP integration

Files:
- `app/src/main/java/gpj/androidsearch/NetworkRequest.java`

Replace `BasicResponseHandler` with a response handler that retains non-success
status rejection, delegates entity reads to the bounded helper, and closes the
entity stream from a `finally` block.

### 3. Durable contracts and guidance

Files:
- `scripts/check-baseline.sh`
- `Makefile`
- `AGENTS.md`
- `README.md`
- `SECURITY.md`
- `VISION.md`
- `CHANGES.md`

Run the host harness from the canonical test gate. Add exact limit, integration,
cleanup-order, documentation, and completed-plan contracts that reject drift.

## Verification

Verification: Completed

- `scripts/test-bounded-response-body.sh` passes under Java 8 with Java 7
  source compatibility and warnings treated as errors.
- Canonical and external-working-directory SDK-backed `make check` pass API 22
  lint, unit-test variants, debug assembly, and the host boundary harness.
- Ten focused hostile mutations cover cap increase, declared-length bypass,
  streaming lookahead removal, exact-boundary rejection, stream-close removal,
  `BasicResponseHandler` restoration, test-gate removal, exact-boundary test
  removal, stale plan status, and missing mutation evidence. Every mutation is
  rejected.
- `sh -n`, `git diff --check`, generated-artifact inspection, and
  credential-shaped added-line scanning are part of the pre-push audit.
- Exact-head hosted checks and code-scanning state are recorded after push.

## Work Completed

- Added a pure-Java reader that rejects oversized declared lengths without
  reading and detects streaming overflow after at most one byte beyond the cap.
- Replaced the unbounded basic response handler while preserving HTTP status
  rejection, generic failure handling, JSON parsing, and client shutdown.
- Closed entity streams from `finally` on successful reads and read failures.
- Wired executable exact-boundary and overflow tests into the canonical test
  gate and documented the operational limit.

## Scope Boundaries

- Do not replace Apache HTTP or `AsyncTask` in this focused change.
- Do not change the endpoint, query encoding, UI behavior, or failure message.
- Do not claim live endpoint, emulator, or device execution.
