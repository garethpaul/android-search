# Search Response Media Types

Status: Completed

## Problem

Search responses are parsed as JSON and result images are decoded as bitmaps
without first checking the server-declared media type. Existing status,
redirect, byte-size, and pixel-size guards limit resource use, but HTML or
other unexpected content still reaches parsers that were not selected for it.

## Requirements

1. Normalize media types case-insensitively and ignore optional parameters.
2. Accept search bodies only as `application/json` or an `application/*+json`
   structured syntax suffix.
3. Accept image bodies only when their normalized media type begins `image/`.
4. Reject missing, empty, malformed, or mismatched media types before reading
   response bytes.
5. Preserve status, redirect, timeout, body-size, pixel-size, stream cleanup,
   connection cleanup, JSON parsing, bitmap decoding, endpoints, and UI.
6. Add dependency-free host tests and mutation-sensitive source contracts.

## Implementation Units

### U1: Add Shared Media-Type Classification

**Files:** `app/src/main/java/gpj/androidsearch/ResponseMediaType.java`,
`scripts/test-response-media-type.sh`

Add a pure-Java helper and host test matrix for parameters, case, suffixes,
missing values, malformed values, and cross-type rejection.

### U2: Enforce Before Body Reads

**Files:** `app/src/main/java/gpj/androidsearch/NetworkRequest.java`,
`app/src/main/java/gpj/androidsearch/MainActivity.java`

Validate the search entity header and image connection media type after the
existing success-status checks but before obtaining either input stream.

### U3: Protect And Document The Boundary

**Files:** `Makefile`, `scripts/check-baseline.sh`, `README.md`, `SECURITY.md`,
`CHANGES.md`, this plan

Run the host media-type test from `make test`, protect validation ordering and
accepted sets, and record truthful verification evidence.

## Verification

- Run shell syntax and the dependency-free baseline checker.
- Run the existing body-reader tests plus the new host Java media-type matrix.
- Run bounded local and external-working-directory `make check` with the
  compatible Android SDK when available.
- Reject focused mutations for parameter handling, case normalization, broad
  JSON/image acceptance, missing-value acceptance, validation after stream
  acquisition, omitted test invocation, and stale plan status.
- Inspect exact diff, generated artifacts, conflict markers, whitespace, and
  credential-shaped added lines before committing.

## Scope Boundaries

- Do not add content sniffing, host allowlists, DNS filtering, retries, caches,
  new dependencies, endpoint changes, or UI changes.
- Do not change existing response/body/pixel limits or redirect behavior.
- Do not claim emulator, physical-device, or production-server verification.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification Completed

- `scripts/test-response-media-type.sh` passed its accepted and rejected JSON
  and image media-type matrix under Java 7 source compatibility.
- `scripts/test-bounded-response-body.sh` passed, preserving the existing
  bounded string and byte-reader behavior.
- Eleven focused mutations were rejected for parameter stripping, case
  normalization, broad JSON acceptance, empty structured suffixes, broad
  image acceptance, malformed subtype whitespace, JSON and image validation
  after stream acquisition, omitted Make invocation, incomplete host cases,
  and stale plan status.
- SDK-backed `make check` passed from the repository root with baseline
  contracts, Android lint (zero issues), unit tests, both host suites, and
  debug APK assembly.
- SDK-backed `make -f <absolute-repository-Makefile> check` passed from an
  unrelated temporary directory with the same checks, proving that the
  protected Make root remains effective.
