# Search Image Default HTTPS Port

Status: Planned

## Problem

The search backend controls the image URL consumed by the Android client. The
current policy requires HTTPS, a host, and no user info, but accepts arbitrary
explicit ports. A malformed or compromised response can therefore direct the
device to HTTPS services on non-default ports that normal image delivery does
not require.

## Requirements

1. Continue requiring HTTPS, a non-empty host, and no user-info credentials.
2. Accept an omitted port and explicit port 443.
3. Reject every other explicit image URL port before opening a connection.
4. Preserve paths, fragments, signed query strings, redirects, timeouts, media
   types, body limits, bitmap limits, cancellation, and response rendering.
5. Add dependency-free executable and mutation-sensitive static coverage.
6. Document truthful local, hosted, and Android-runtime verification limits.

## Implementation Units

### U1: Enforce The Default Port

**File:** `app/src/main/java/gpj/androidsearch/ImageUrlPolicy.java`

Reject an explicit port unless it is the default HTTPS port, after the existing
scheme, host, and user-info checks.

### U2: Protect The Policy

**Files:**

- Modify `scripts/test-image-url-policy.sh`.
- Modify `scripts/check-baseline.sh`.

Accept omitted and explicit-default ports, reject representative non-default
ports, and require the implementation, fixtures, completed plan, and guidance.

### U3: Record The Boundary

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
and this plan.

State that backend-provided image URLs use the default HTTPS port before
connection setup.

## Test Scenarios

- `https://images.example.test/photo.png` is accepted.
- `https://images.example.test:443/photo.png` is accepted.
- Explicit ports `1`, `80`, `444`, and `8443` are rejected.
- Existing HTTP, missing-host, and user-info rejection remains green.
- Existing signed queries, paths, and fragments remain accepted.

## Scope Boundaries

- Do not add host allowlists, DNS resolution, live requests, or dependencies.
- Do not change the search endpoint, JSON schema, image decoding, or UI.
- Do not claim emulator, device, backend, or live-network execution.
- Keep this work stacked on the image URL authority pull request.

## Verification To Complete

- Run the focused image URL policy suite and all portable host suites.
- Run repository and external-directory `make check` with bounded commands.
- Reject isolated mutations for omitted-port acceptance, explicit 443
  acceptance, non-default rejection, fixtures, guidance, and plan completion.
- Run exact diff, generated-artifact, likely-secret, and whitespace audits.
- Take one bounded exact-head hosted snapshot after push without polling.

