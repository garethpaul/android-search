# Search Image Private Literal Boundary

Status: Completed

## Problem

The backend controls image URLs. The current syntactic policy rejects loopback
targets but still accepts explicit private, link-local, and unspecified IP
literals. Those literals can direct image requests toward non-public services
without requiring DNS resolution or rebinding.

## Scope

- Reject explicit IPv4 unspecified, private, and link-local address literals,
  including accepted one-to-four-part decimal, octal, and hexadecimal forms.
- Reject bracketed IPv6 unspecified, unique-local, and link-local literals,
  including IPv4-mapped non-public literals.
- Preserve public IPv4 and IPv6 literals, DNS-style hosts, HTTPS authority,
  default-port, redirect, media-type, body-limit, and cancellation behavior.
- Do not resolve DNS names or claim protection against DNS rebinding.

## Implementation

1. Extend `ImageUrlPolicy` with a deterministic explicit-address predicate
   after the existing authority and port checks.
2. Add executable accepted and rejected fixtures for IPv4 and IPv6 boundaries.
3. Add mutation-sensitive baseline contracts for masks, IPv6 categories,
   public controls, guidance, and completed-plan evidence.
4. Synchronize `AGENTS.md`, `README.md`, `SECURITY.md`, `VISION.md`, and
   `CHANGES.md` with the exact syntactic boundary and its DNS limitation.

## Verification

- Run the focused image URL policy suite and all dependency-free Java suites.
- Run the full repository and external-directory `make check` gates.
- Run compatible Android unit, lint, and assembly tasks when the SDK is
  available.
- Reject isolated hostile mutations for IPv4 masks, IPv6 categories, public
  controls, maintained guidance, and plan completion.
- Audit the exact diff, generated artifacts, conflicts, whitespace,
  dependency/workflow drift, and credential-shaped additions.

## Completion Evidence

- Added `isPrivateAddressLiteral` after the existing HTTPS authority, port,
  and loopback checks without resolving DNS-style hosts.
- The focused image URL policy suite passed with private, link-local,
  unspecified, unique-local, mapped-address, legacy IPv4 numeric, public IP,
  and DNS-style fixtures.
- All three dependency-free Java host suites passed.
- With Java 8 and `/home/gjones/android-sdk`, Gradle debug/release unit tests
  passed, debug/release lint reported zero errors and warnings, and debug APK
  assembly succeeded.
- Fourteen isolated hostile mutations were rejected: nine runtime mutations
  across complete guard removal, every IPv4 mask, IPv6
  unique-local/link-local/unspecified handling, and public-address
  over-rejection; plus five static mutations covering source ownership,
  rejected and public fixtures, maintained guidance, and plan completion.
- Repository-root and external-directory `make check` passed with Java 8 and
  the configured Android SDK.
- No emulator, physical device, backend, DNS, or live-network behavior was
  exercised; hostname resolution and DNS rebinding remain out of scope.

## Risks

- `InetAddress` must be used only for already bracketed IPv6 literal syntax;
  DNS-style names must not be resolved during policy validation.
- Public literal controls must prevent an accidental all-IP denial.
- This PR is stacked on PR #20 and must retain base-first ordering.

## Out Of Scope

- DNS resolution, DNS rebinding prevention, connection-address pinning,
  proxy/certificate policy, or hostname allowlists.
- Networking-client, endpoint, schema, image decoding, Gradle, dependency, or
  SDK modernization.
- Emulator, physical-device, backend, DNS, or live-network execution.
