# Search Runtime Exception Boundary

Status: Planned

## Priority

`NetworkRequest.doInBackground()` uses a final `catch (Throwable)` fallback.
That catches not only recoverable runtime failures but also Java `Error`
subclasses such as VM failures and `ThreadDeath`, converting serious process
conditions into an ordinary search error result. Java's API guidance says a
reasonable application should not try to catch `Error`.

## Requirements

- **R1:** Replace the broad final `Throwable` catch with `RuntimeException`.
- **R2:** Preserve protocol, IO, JSON, query encoding, HTTP cleanup, timeout,
  user-facing error-result, and redacted logging behavior.
- **R3:** Reject reintroduction of `catch (Throwable)` or `catch (Error)` in the
  request task.
- **R4:** Add fail-closed checker, documentation, hostile mutation, and truthful
  local and hosted verification evidence.

## Implementation Units

### U1: Narrow The Unexpected-Failure Boundary

**File:** `app/src/main/java/gpj/androidsearch/NetworkRequest.java`

Catch unexpected `RuntimeException` instances while allowing fatal JVM errors
to propagate according to the platform contract.

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

Pending implementation and execution.

## Sources

- Java SE 8 `Error` API:
  https://docs.oracle.com/javase/8/docs/api/java/lang/Error.html
- Java SE 8 `RuntimeException` API:
  https://docs.oracle.com/javase/8/docs/api/java/lang/RuntimeException.html
