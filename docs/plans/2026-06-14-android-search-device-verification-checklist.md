# Android Search Device Verification Checklist

Status: In Progress

## Problem

Portable contracts cover query bounds, response limits, redirects, media
types, strict UTF-8 decoding, image allocation limits, cancellation, and error
boundaries, but no checklist defines repeatable emulator or physical-device
evidence for the exact search implementation commit.

## Requirements

1. Add an exact-commit matrix for valid search, invalid input, cancellation,
   offline behavior, protocol failures, image failures, rotation, and relaunch.
2. Require synthetic queries and sanitized toolchain, device, result, and
   evidence fields.
3. Keep repository checks separate from unexecuted Android, backend, network,
   and UI scenarios.
4. Add mutation-sensitive contracts for the checklist and completion evidence.

## Scope Boundaries

- Do not change the backend API, Android SDK, Gradle plugin, dependencies, or
  runtime behavior.
- Do not add API keys, tokens, cookies, account data, real user queries, device
  identifiers, response bodies, screenshots, logs, APKs, or local config.
- Do not claim emulator, backend, network, or physical-device execution from
  portable checks.
- Do not merge or close stacked pull requests without explicit authorization.

## Verification

- Pending implementation and bounded repository validation.
