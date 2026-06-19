---
title: Search Image Special-Use IPv4 Boundary
type: security
status: completed
date: 2026-06-17
owner: repository maintainers
---

# Search Image Special-Use IPv4 Boundary

## Context

The image transport rejects loopback, private-use, shared, link-local,
multicast, and unique-local peers before TLS. Its IPv4 predicate still accepts
other IANA special-purpose destinations that are not suitable remote image
servers, including protocol-assignment, documentation, benchmarking,
deprecated relay, and reserved ranges. A backend-controlled image URL can
therefore pass both literal-host and DNS-answer checks for a destination that
is not globally reachable or is reserved for non-application use.

## Requirements

- R1. Reject `192.0.0.0/24` protocol-assignment addresses except the globally
  reachable `.9` and `.10` anycast exceptions recorded by IANA.
- R2. Reject `192.0.2.0/24`, `198.51.100.0/24`, and `203.0.113.0/24`
  documentation networks.
- R3. Reject `192.88.99.0/24` deprecated 6to4 relay space.
- R4. Reject `198.18.0.0/15` benchmarking space.
- R5. Reject `240.0.0.0/4`, including limited broadcast, as reserved space.
- R6. Apply the same predicate to numeric URL literals, DNS answers, and the
  actual connected TLS peer.
- R7. Preserve ordinary public IPv4 and IPv6 acceptance, DNS answer pinning,
  proxy bypass, hostname verification, redirect refusal, body limits,
  cancellation, and cleanup.
- R8. Add mutation-sensitive portable tests and baseline contracts for every
  new range, the two protocol-assignment exceptions, guidance, and completed
  verification evidence.

## Key Technical Decisions

- KTD1. Extend the existing byte-level IPv4 predicate instead of adding DNS or
  transport-specific checks, so literal, resolved, and connected-peer paths
  cannot drift.
- KTD2. Keep the IANA `.9` PCP and `.10` TURN anycast exceptions globally
  reachable, even though they are unlikely image origins, so the policy
  remains tied to registry reachability rather than an arbitrary host denylist.
- KTD3. Keep IPv6 behavior unchanged in this unit. Existing local, site-local,
  multicast, unique-local, and IPv4-mapped protections remain enforced.

## Implementation Units

### U1: Special-Use IPv4 Predicate

**File:** `app/src/main/java/gpj/androidsearch/ImageUrlPolicy.java`

Extend the shared IPv4 classification with explicit prefix checks and the two
globally reachable protocol-assignment exceptions.

### U2: Deterministic Policy Matrix

**File:** `scripts/test-image-url-policy.sh`

Cover lower/upper boundaries for each range, public neighbors, the `.9` and
`.10` exceptions, DNS answer rejection, and connected-peer rejection.

### U3: Contracts And Guidance

**Files:** `scripts/check-baseline.sh`, `AGENTS.md`, `README.md`, `SECURITY.md`,
`VISION.md`, `CHANGES.md`, and this plan.

Require the special-use prefix contracts, focused test cases, repository
guidance, completed status, and actual verification record.

## Test Scenarios

- Numeric literals in every special-use range fail URL authorization.
- DNS answers in every special-use range fail closed, including mixed answer
  sets that also contain a public address.
- A connected TLS peer in a newly prohibited range is closed before TLS
  delegation.
- `192.0.0.9` and `192.0.0.10` remain accepted by the address classifier.
- Public neighbors immediately outside each range remain accepted.
- Existing URL authority, default-port, loopback/private/shared address, DNS
  pinning, proxy, redirect, response, and bounded-body tests remain green.

## Scope Boundaries

- Do not add a host allowlist, DNS cache, proxy path, custom trust manager,
  permissive hostname verifier, dependency, or build-tool change.
- Do not change the search endpoint, response schema, query handling, UI, or
  accepted globally reachable image hosts.
- Do not claim emulator, physical-device, live DNS, CDN, or backend evidence
  from portable tests.
- Do not merge or close any stacked pull request without explicit owner
  authorization.

## Verification

- Run `scripts/test-image-url-policy.sh` before implementation and confirm the
  new special-use cases fail against the current predicate.
- Run focused policy tests, shell syntax, repository `make check`, and external
  working-directory `make check` with bounded execution.
- Reject isolated mutations for each prefix, the `.9`/`.10` exceptions,
  literal/DNS/peer coverage, guidance, plan status, and verification evidence.
- Audit the exact diff, generated Android/Gradle artifacts, dependency drift,
  credentials, conflict markers, file modes, and whitespace before commit.

## Work Completed

- Extended the shared IPv4 classifier for protocol-assignment,
  documentation, deprecated relay, benchmarking, and reserved ranges while
  preserving the globally reachable `192.0.0.9` and `192.0.0.10` exceptions.
- Added literal, DNS-answer, mixed-answer, connected-peer, boundary, and public
  neighbor coverage to the portable image policy matrix.
- Added baseline contracts and repository guidance for the new boundary.

## Verification Results

- The new matrix failed before implementation on the accepted
  `192.0.0.0` literal, reproducing the missing boundary.
- All three portable response, image-policy, and media-type test scripts pass.
- SDK-backed `./gradlew lint test assembleDebug --no-daemon` passes with zero
  lint issues.
- An isolated completed candidate copy passes SDK-backed `make check`.
- Repository and external-working-directory SDK-backed `make check` both pass
  the baseline, zero-issue lint, portable tests, Gradle tests, and debug build.
- Twelve isolated hostile mutations were rejected for the six range
  contracts, both protocol-assignment exceptions, connected-peer coverage,
  guidance, completed status, and verification evidence.

## References

- IANA IPv4 Special-Purpose Address Space:
  https://www.iana.org/assignments/iana-ipv4-special-registry/
- RFC 6890, Special-Purpose IP Address Registries:
  https://www.rfc-editor.org/rfc/rfc6890
