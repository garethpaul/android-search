# Search Image Shared Address Boundary

Status: Planned

## Problem

Backend-provided image URLs are checked syntactically before connection setup.
The current literal policy rejects unspecified, loopback, link-local, and
RFC1918 IPv4 targets but still accepts shared address space in
`100.64.0.0/10`. A device can route that range toward carrier or internal
infrastructure, so accepting it contradicts the documented non-public literal
boundary.

## Priorities

1. Reject explicit IPv4 shared-address literals before opening a connection.
2. Cover the range boundaries and legacy one-to-four-part decimal, octal, and
   hexadecimal spellings already supported by the parser.
3. Preserve public literals, DNS-style hosts, signed queries, fragments,
   default-port handling, redirects, media-type checks, body limits,
   cancellation, and image decoding.

## Requirements

- Extend the existing IPv4 predicate with the exact `100.64.0.0/10` mask.
- Add rejected fixtures at both shared-range boundaries and encoded forms.
- Add accepted controls immediately below and above the range.
- Keep DNS names unresolved during policy validation and retain the documented
  DNS-rebinding limitation.
- Add mutation-sensitive source, fixture, guidance, and completion contracts.

## Implementation Units

### 1. Extend the literal policy

**File:** `app/src/main/java/gpj/androidsearch/ImageUrlPolicy.java`

Classify the IPv4 shared-address range alongside the existing non-public
literal masks.

### 2. Add executable and static regressions

**Files:** `scripts/test-image-url-policy.sh`, `scripts/check-baseline.sh`

Exercise range boundaries, legacy numeric forms, public controls, integration,
maintained guidance, and completed-plan evidence.

### 3. Synchronize maintained guidance

**Files:** `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, `CHANGES.md`,
and this plan.

Document the shared-address exclusion without claiming DNS or live-connection
enforcement.

## Verification

- Run the focused image URL policy suite before and after implementation.
- Run repository-root and external-directory `make check` with the configured
  Java and Android SDK environment when available.
- Reject isolated mask, boundary fixture, public control, integration,
  guidance, and incomplete-plan mutations.
- Audit exact paths, generated artifacts, conflict markers, dependency and
  workflow drift, whitespace, and credential-shaped additions.

## Risks

- An incorrect mask could over-reject adjacent public IPv4 space; boundary
  controls must remain executable.
- The syntactic policy still does not resolve DNS-style hosts and therefore
  does not prevent DNS rebinding.
- This PR is stacked on PR #21 and must retain base-first merge ordering.

## Out Of Scope

- DNS resolution, rebinding prevention, connection-address pinning, proxy or
  certificate policy, and hostname allowlists.
- Other special-purpose IP ranges, networking-client migration, endpoint or
  schema changes, Gradle modernization, and dependency upgrades.
- Emulator, physical-device, backend, DNS, and live-network execution.
