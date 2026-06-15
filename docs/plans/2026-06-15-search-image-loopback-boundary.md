# Search Image Loopback Boundary

Status: Completed

## Problem

The search backend controls the image URL consumed by the Android client. The
current policy requires HTTPS, a non-empty host, no user info, and the default
HTTPS port, but it accepts loopback targets. A malformed or compromised response
can therefore direct the app toward `localhost`, an IPv4 `127.0.0.0/8` literal,
or the IPv6 loopback literal before image media and body checks run.

A dependency-free reproduction confirmed that the current policy accepts
`https://localhost/image.png`, `https://127.0.0.1/image.png`, and
`https://[::1]/image.png`.

## Priorities

1. **P0: Reject explicit loopback image targets.** Block localhost names and
   loopback IP literals before connection setup.
2. **P1 follow-up: Resolve and pin connection addresses.** Consider DNS
   rebinding and private-network policy only with a maintained HTTP client and
   connection-level address verification.
3. **P2 follow-up: Modernize networking.** Replace deprecated Apache HTTP and
   ad hoc image transport in a coordinated SDK, dependency, and integration
   pass.

This plan implements only P0.

## Requirements

- Continue requiring HTTPS, a non-empty host, no user-info credentials, and an
  omitted or explicit port 443.
- Reject `localhost` case-insensitively and names beneath `.localhost`.
- Reject explicit IPv4 loopback literals across one-to-four-part decimal,
  octal, and hexadecimal forms.
- Reject bracketed IPv6 loopback and IPv4-mapped loopback literals.
- Continue accepting normal DNS hosts, paths, signed query strings, fragments,
  and explicit port 443.
- Preserve redirects, timeouts, media-type checks, body limits, bitmap limits,
  cancellation, result ownership, and UI behavior.
- Add dependency-free executable and mutation-sensitive static coverage.

## Implementation Units

### 1. Extend the pure URL policy

**File:** `app/src/main/java/gpj/androidsearch/ImageUrlPolicy.java`

Add a deterministic loopback-host predicate after existing authority and port
validation. Operate only on explicit URL host syntax; do not perform DNS during
policy evaluation.

### 2. Prove accepted and rejected boundaries

**Files:** `scripts/test-image-url-policy.sh`, `scripts/check-baseline.sh`

Reject exact and mixed-case localhost names, localhost subdomains, representative
IPv4 `127/8` literals, and IPv6 loopback. Preserve acceptance of public-style
DNS names, signed queries, fragments, and explicit port 443. Require the policy,
fixtures, maintained guidance, and completed-plan evidence in the portable
checker.

### 3. Synchronize maintained guidance

**Files:** `README.md`, `SECURITY.md`, `VISION.md`, `AGENTS.md`, `CHANGES.md`

Document that backend-provided image URLs cannot explicitly target loopback
hosts before connection setup.

## Verification

- Run the focused image URL policy suite and every dependency-free Java host
  suite.
- Run Android lint, unit tasks, and debug assembly when the compatible SDK is
  available.
- Run `make check` from the repository root and an external directory.
- Run isolated hostile mutations for localhost, IPv4 loopback, IPv6 loopback,
  fixtures, guidance, and plan completion.
- Audit exact intended paths, generated artifacts, conflict markers,
  whitespace, dependency drift, and credential-shaped additions.

## Completion Evidence

- Added `isLoopbackHost`, local one-to-four-part IPv4 numeric parsing, and
  bracketed IPv6 literal handling after the existing scheme, authority,
  user-info, and port checks.
- The focused image URL policy suite passed with exact/mixed-case localhost,
  localhost subdomain, IPv4 `127/8`, compressed IPv6, and expanded IPv6
  rejection fixtures while preserving non-loopback DNS-style hosts.
- All three dependency-free Java host suites passed.
- With Java 8 and the installed Android SDK, Gradle `testDebug` and
  `testRelease` passed, debug/release lint reported zero issues, and debug APK
  assembly succeeded.
- Ten isolated hostile mutations were rejected for exact localhost, localhost
  subdomains, IPv4 loopback masks, compact-address width, numeric radix,
  IPv6 loopback, mapped-address fixtures, over-rejection controls, guidance,
  and completed-plan status.
- Repository-root and external-directory `make check` passed with explicit SDK
  environment variables.
- Exact-path diff, generated-artifact, conflict-marker, whitespace, dependency
  drift, and credential-shaped-addition audits passed.
- No emulator, physical device, backend, DNS, or live-network behavior was
  exercised; DNS rebinding and private-network enforcement remain out of scope.

## Risks And Mitigations

- **False private-network claim:** state explicitly that this syntactic boundary
  does not resolve hostname DNS or prevent rebinding.
- **Numeric address ambiguity:** parse legacy one-to-four-part IPv4 numeric
  syntax locally and use `InetAddress` only for bracketed IPv6 literals, never
  for DNS-style hosts.
- **Compatibility:** preserve all currently accepted non-loopback fixtures and
  run the complete existing policy suite.
- **Stacked delivery:** base the pull request on PR #19 and retain base-first
  ordering.

## Out Of Scope

- Hostname DNS resolution, DNS rebinding prevention, private-network allowlists,
  certificate policy, proxy policy, or host pinning.
- Changing the search endpoint, JSON schema, image decoding, UI, dependencies,
  Gradle, or SDK levels.
- Emulator, device, backend, DNS, or live-network execution.
