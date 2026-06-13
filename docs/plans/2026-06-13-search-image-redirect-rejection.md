# Search Image Redirect Rejection

Status: Planned

## Context

Search result image URLs are backend-controlled. The activity validates the
initial URL as HTTPS and applies one-second connection/read timeouts, but the
generic `URLConnection` path can follow redirects implicitly. A validated URL
must not silently change destination or scheme before image bytes are decoded.

## Scope

- Keep initial image URL parsing and HTTPS validation unchanged.
- Open images through `HttpsURLConnection` with automatic redirects disabled.
- Accept only 2xx responses before obtaining and decoding the response stream.
- Disconnect the HTTPS connection in `finally` after stream cleanup.
- Pin ordering and documentation with mutation-sensitive baseline checks.

## Out Of Scope

- Image caching, retries, certificate pinning, DNS/IP allowlists, or networking
  library modernization.
- Live backend, emulator, physical-device, or redirect-server integration tests.
- Changes to search-response parsing, request ownership, or UI lifecycle rules.

## Implementation

### U1: Reject Redirected Image Fetches

**File:** `app/src/main/java/gpj/androidsearch/MainActivity.java`

Use `HttpsURLConnection`, disable automatic redirects before connecting,
require a 2xx response, and disconnect after closing any opened stream.

### U2: Protect The Contract

**File:** `scripts/check-baseline.sh`

Require the exact redirect, status, stream, and cleanup ordering. Reject the
previous generic connection path and protect completed plan evidence.

### U3: Document And Verify

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
this plan

Document that image fetches reject redirects and non-success responses. Run the
canonical gate, an external-working-directory gate, focused hostile mutations,
and exact diff/artifact/secret inspection before push and hosted validation.

## Verification

- Pending implementation.
