# Search Runtime Exception Boundary

Status: Completed

## Priority

`NetworkRequest.doInBackground()` uses a final `catch (Throwable)` fallback.
That catches not only recoverable runtime failures but also Java `Error`
subclasses such as VM failures and `ThreadDeath`, converting serious process
conditions into an ordinary search error result. Java's API guidance says a
reasonable application should not try to catch `Error`.

## Requirements

- **R1:** Replace the broad final `Throwable` catch with `RuntimeException`,
  keeping checked query-encoding failures inside the reviewed IO boundary.
- **R2:** Preserve protocol, IO, JSON, query encoding, HTTP cleanup, timeout,
  user-facing error-result, and redacted logging behavior.
- **R3:** Reject reintroduction of `catch (Throwable)` or `catch (Error)` in the
  request task.
- **R4:** Add fail-closed checker, documentation, hostile mutation, and truthful
  local and hosted verification evidence.

## Implementation Units

### U1: Narrow The Unexpected-Failure Boundary

**File:** `app/src/main/java/gpj/androidsearch/NetworkRequest.java`

Keep URL construction inside the existing checked-IO boundary, catch unexpected
`RuntimeException` instances at the task boundary, and allow fatal JVM errors to
propagate according to the platform contract.

### U2: Protect The Catch Contract

**File:** `scripts/check-baseline.sh`

Require the runtime-exception fallback in the outer request scope, reject broad
fatal-condition catches, and preserve HTTP-client cleanup ordering.

### U3: Document And Verify

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
`docs/plans/2026-06-13-search-runtime-exception-boundary.md`

Document the recoverable-versus-fatal exception boundary and record exact
verification evidence.

## Test Scenarios

- Protocol, IO, JSON, and unexpected runtime exceptions still return the
  generic user-facing search error.
- Java `Error` subclasses are not caught by the request task.
- HTTP client shutdown remains in `finally` after request execution.
- Restoring `Throwable`, catching `Error`, removing runtime fallback, changing
  cleanup ordering, removing guidance, or reverting plan completion fails.

## Scope Boundaries

- Do not change endpoints, query encoding, response parsing, UI ownership,
  image downloads, dependencies, Android/Gradle versions, or log contents.
- Do not claim live backend, device, or fatal-VM execution without a compatible
  controlled runtime.

## Verification

- SDK-backed `make check` passed in an isolated tracked-file copy after the
  source and checker changes. The first compile correctly exposed that query
  URL construction still sat outside the checked-IO catch; moving URL and
  `HttpGet` construction into that existing boundary made the full lint, unit
  test, and debug assembly gate pass.
- Nine hostile mutations were rejected: restoring `Throwable`, catching
  `Error` or an `Error` subclass, substituting another fallback exception,
  changing the generic log, removing an error result, removing deterministic
  client shutdown, deleting the fatal-JVM guidance, and reverting this
  completion status.
- SDK-backed `make check` then passed from the canonical worktree and through
  `make -C` from an external working directory.
- Device execution and deliberate fatal-VM injection were not run; the checked
  build and fail-closed source contracts verify this legacy sample boundary.

## Sources

- Java SE 8 `Error` API:
  https://docs.oracle.com/javase/8/docs/api/java/lang/Error.html
- Java SE 8 `RuntimeException` API:
  https://docs.oracle.com/javase/8/docs/api/java/lang/RuntimeException.html
