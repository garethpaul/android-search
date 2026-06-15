# Search Image URL Authority Validation

Status: Completed

## Problem

The search backend controls the image URL consumed by the Android client.
The current helper requires HTTPS, but it still accepts URLs with no host and
URLs containing user-info credentials. Those values pass the local boundary
and fail later during transport setup or carry credential-like material into a
request URL.

## Requirements

1. Continue requiring HTTPS for backend-provided image URLs.
2. Require a non-empty URL host before opening a connection.
3. Reject image URLs containing user-info credentials.
4. Preserve normal paths, explicit ports, fragments, and signed query strings.
5. Add dependency-free host tests and mutation-sensitive baseline contracts.
6. Document the authority boundary and truthful verification evidence.

## Implementation Units

### 1. Isolate the image URL policy

Files:

- `app/src/main/java/gpj/androidsearch/ImageUrlPolicy.java`
- `app/src/main/java/gpj/androidsearch/MainActivity.java`

Move URL parsing into a package-private pure-Java policy and use it before
opening the HTTPS image connection.

### 2. Add executable and static coverage

Files:

- `scripts/test-image-url-policy.sh`
- `scripts/check-baseline.sh`
- `Makefile`

Exercise accepted HTTPS URLs, including signed queries, and reject HTTP,
missing-host, and user-info inputs. Require the policy integration, test
fixtures, completed plan, and documentation wording in the portable checker.

### 3. Record the maintained boundary

Files:

- `AGENTS.md`
- `README.md`
- `SECURITY.md`
- `VISION.md`
- `CHANGES.md`

State that backend-provided image URLs require HTTPS, a host, and no user-info
credentials before connection setup.

## Verification Completed

- The scheme-only policy accepted `https:/photo.png`; the focused host test
  failed before the authority guards were added and passed afterward.
- `sh -n` and all three dependency-free Java host suites passed.
- Repository and external-directory `make check` passed with the baseline and
  all three dependency-free Java host suites. Android SDK-dependent lint,
  tests, and assembly were truthfully skipped because the SDK is unavailable.
- Seven isolated hostile mutations were rejected for scheme, host, user-info,
  downloader integration, fixture, guidance, and completed-plan weakening.

## Scope Boundaries

- Do not change the search endpoint, response schema, image size limits,
  redirect handling, timeouts, media-type checks, or bitmap decoding.
- Do not reject explicit image ports, fragments, paths, or query parameters.
- Do not add dependencies or claim emulator, device, backend, or live-network
  execution.
- Do not merge or close any pull request without explicit authorization.
