# Search Exception Log Redaction

Status: Completed

## Context

Search queries are URL-encoded and success paths avoid logging raw queries or
responses, but failure paths still pass caught exceptions and a top-level
throwable to Android logcat. Protocol and I/O exception messages or stacks can
include the query-bearing request URL, remote host details, and image URL or
decoder context. Those details are unnecessary for the app's generic recovery
behavior.

## Goals

- Replace throwable-bearing search and image failure logs with stable generic
  categories.
- Keep query text, request/image URLs, exception messages, and stack traces out
  of application logs on every reviewed failure path.
- Preserve explicit JSON error results, URL encoding, HTTPS image validation,
  timeouts, HTTP client cleanup, task ownership/cancellation, and UI behavior.
- Add SDK-free contracts against restored throwable, message-derived, raw
  stack, or additive sensitive logs.

## Non-Goals

- Do not change the external search endpoint, response schema, or image URL.
- Do not replace `AsyncTask`, Apache HTTP, or the image download implementation
  in this unit.
- Do not change user-visible fallback strings or add telemetry.
- Do not claim live-backend, emulator, or logcat runtime verification.

## Implementation Units

### 1. Redact Failure Logs

Files:

- Modify `app/src/main/java/gpj/androidsearch/NetworkRequest.java`.
- Modify `app/src/main/java/gpj/androidsearch/MainActivity.java`.

Approach:

- Keep each existing failure category as a fixed two-argument log statement.
- Remove caught exception/throwable objects and exception-derived text from
  log calls without changing catch structure or return behavior.

### 2. Protect The Logging Boundary

Files:

- Modify `scripts/check-baseline.sh`.

Approach:

- Require the exact reviewed failure categories and expected counts.
- Reject throwable overloads, `getMessage()`, raw stack printing/conversion,
  URL/query/response-derived log payloads, and extra error logs.
- Require completed plan and documentation evidence.

### 3. Document Privacy And Verification

Files:

- Modify `README.md`.
- Modify `SECURITY.md`.
- Modify `CHANGES.md`.
- Complete this plan with actual verification evidence.

Approach:

- State that search and image failures retain categories without exception or
  URL details.
- Keep the external backend and remote image privacy risks explicit.

## Verification

- Focused source/logging contracts in `scripts/check-baseline.sh` passed.
- Eleven hostile mutations restoring throwable, message-derived, raw-stack,
  query/URL/response, additive-log, category, documentation, or plan regressions
  were rejected.
- SDK-backed `make check` passed from the repository and an external working
  directory with Java 8 and API 22/build-tools 24.0.3, including zero-finding
  lint, both unit-test variants, and debug assembly.
- Workflow YAML parsing, shell syntax, `git diff --check`, and targeted secret
  scanning passed.

## Acceptance Criteria

- No search or image catch path passes an exception or throwable to logcat.
- The reviewed generic failure categories remain present exactly once.
- Request fallback, cleanup, ownership, and rendering behavior are unchanged.
- The plan records completed evidence only after all validation passes.
