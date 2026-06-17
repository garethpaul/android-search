---
title: Search Image Non-Global IPv6 Boundary
type: security
status: planned
date: 2026-06-17
owner: repository maintainers
---

# Search Image Non-Global IPv6 Boundary

## Context

The image transport applies one address predicate to numeric URL literals,
DNS answers, and the connected TLS peer. That predicate rejects local,
multicast, unique-local, IPv4-mapped, and reviewed special-use IPv4 ranges,
but it still accepts several IPv6 prefixes that the IANA IPv6 Special-Purpose
Address Registry marks as not globally reachable or invalid as destinations.
A backend-controlled image URL can therefore target documentation,
benchmarking, discard-only, local translation, dummy, or SRv6 SID space and
pass every current address boundary.

An unchanged-head probe accepted all seven reviewed examples:
`64:ff9b:1::1`, `100::1`, `100:0:0:1::1`, `2001:2::1`, `2001:db8::1`,
`3fff::1`, and `5f00::1`.

## Requirements

- R1. Reject `64:ff9b:1::/48`, the locally assigned IPv4/IPv6 translation
  prefix that IANA marks not globally reachable.
- R2. Reject `100::/64` discard-only space and `100:0:0:1::/64` dummy IPv6
  space.
- R3. Reject `2001:2::/48` benchmarking space.
- R4. Reject `2001:db8::/32` and `3fff::/20` documentation space.
- R5. Reject `5f00::/16` SRv6 SID space, which IANA marks not globally
  reachable.
- R6. Apply the same classification to numeric URL literals, DNS answers,
  mixed DNS answer sets, and the actual connected TLS peer.
- R7. Preserve ordinary globally reachable IPv6, existing IPv4 behavior,
  DNS answer pinning, proxy bypass, hostname verification, redirect refusal,
  body limits, cancellation, and cleanup.
- R8. Add mutation-sensitive portable tests and baseline contracts for every
  new prefix, representative boundaries, public controls, guidance, completed
  plan status, and actual verification evidence.

## Key Technical Decisions

- KTD1. Extend `ImageUrlPolicy.isProhibitedAddress` through a byte-prefix IPv6
  helper so literal, resolved, and connected-peer paths cannot drift.
- KTD2. Encode only dedicated entries whose current IANA registry state is
  explicitly non-global or destination-invalid. Do not broadly reject
  `2001::/23`, because it contains more-specific globally reachable anycast
  and protocol allocations.
- KTD3. Leave Teredo, 6to4, ORCHIDv2, and other entries with globally
  reachable or registry-specific semantics unchanged in this unit.
- KTD4. Preserve Java 7 source compatibility and the repository's
  dependency-free portable policy harness.

## Implementation Units

### U1: Shared IPv6 Prefix Classification

**File:** `app/src/main/java/gpj/androidsearch/ImageUrlPolicy.java`

Add a small byte-prefix matcher and classify the seven reviewed prefixes from
the existing shared address predicate.

### U2: Literal, Resolution, And Peer Matrix

**File:** `scripts/test-image-url-policy.sh`

Cover a representative address in every prefix, prefix boundaries and public
neighbors where meaningful, mixed DNS answers, and connected-peer rejection.

### U3: Mutation Contracts And Repository Guidance

**Files:** `scripts/check-baseline.sh`, `AGENTS.md`, `README.md`, `SECURITY.md`,
`VISION.md`, `CHANGES.md`, and this plan.

Require the prefix implementation, focused tests, maintained guidance,
completed plan status, and truthful verification results.

## Test Scenarios

- Numeric literals from all seven reviewed prefixes fail URL authorization.
- DNS answers from every reviewed prefix fail closed.
- A mixed public and prohibited DNS answer set fails closed.
- A connected TLS peer in reviewed non-global IPv6 space is closed before TLS
  delegation.
- Public IPv6 controls such as `2001:4860:4860::8888` remain accepted.
- Adjacent addresses outside the reviewed prefixes remain accepted where the
  surrounding allocation is globally reachable or otherwise unchanged.
- Existing URL authority, IPv4, DNS pinning, proxy, redirect, response, and
  bounded-body tests remain green.

## Scope Boundaries

- Do not add a host allowlist, DNS cache, proxy path, custom trust manager,
  permissive hostname verifier, dependency, or build-tool change.
- Do not broadly reject IANA parent blocks containing globally reachable
  exceptions or change transitional IPv6 policy in this unit.
- Do not change the search endpoint, response schema, query handling, UI, or
  accepted globally reachable image hosts.
- Do not claim emulator, physical-device, live DNS, CDN, or backend evidence
  from portable tests.
- Do not merge or close any stacked pull request without explicit owner
  authorization.

## Verification

- Run a pre-fix package-level probe and record that all seven reviewed
  non-global examples are accepted by the current predicate.
- Run focused policy tests, shell syntax, repository `make check`, and external
  working-directory `make check` with the configured Android SDK and bounded
  execution.
- Reject isolated mutations for every prefix, literal/DNS/peer coverage,
  public controls, guidance, completed status, and verification evidence.
- Audit the exact diff, generated Android/Gradle artifacts, dependencies,
  credentials, conflict markers, file modes, and whitespace before commit.

## Assumptions

- The current IANA registry's `Globally Reachable` and `Destination` fields are
  the authoritative policy inputs for this narrow SSRF boundary.
- Existing tracked behavior for special-purpose entries with globally
  reachable or indeterminate semantics remains intentional until reviewed in
  a separate plan.

## References

- IANA IPv6 Special-Purpose Address Space, last updated 2025-10-09:
  https://www.iana.org/assignments/iana-ipv6-special-registry/
- RFC 6890, Special-Purpose IP Address Registries:
  https://www.rfc-editor.org/rfc/rfc6890
