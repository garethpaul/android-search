# Hosted Android Verification

## Status: Planned

## Context

The canonical workflow clears Android SDK variables and therefore proves only
source contracts. The existing API 22 project already passes Android lint,
Gradle unit-test tasks, and debug assembly locally with build-tools 24.0.3 and
Java 8. Its only lint finding is the intentionally deferred target-SDK
modernization warning.

## Goal

Run the complete legacy Android gate in hosted CI while preserving search,
network, privacy, and trust-boundary behavior.

## Changes

- Install Android API 22 and build-tools 24.0.3 before selecting Java 8.
- Run canonical `make check` with a bounded timeout.
- Keep `OldTargetApi` as the sole documented lint suppression and make every
  other warning fatal.
- Select deterministic non-queued PNG crunching without skipping aapt
  validation.
- Preserve immutable actions, read-only permissions, disabled checkout
  credentials, workflow uniqueness, and exact checker enforcement.
- Update README and CI plan evidence after the complete gate passes.

## Verification

- Run SDK-backed `make check` locally.
- Run the complete gate from a fresh external clone.
- Exercise focused hostile workflow, Gradle, lint, checker, documentation, and
  plan-status mutations.
- Pass `git diff --check`.
- Require exact-head hosted verification before completion.

## Boundaries

- Do not change search request, response, image, or UI behavior.
- Do not change compile SDK, target SDK, Gradle, Android plugin, or HTTP APIs.
- Do not add credentials, signing material, permissions, or dependencies.
