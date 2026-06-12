---
title: Gradle Wrapper Verification
date: 2026-06-12
status: completed
execution: code
---

# Gradle Wrapper Verification

## Summary

Add a checksum-capable generated Gradle Wrapper bootstrap while preserving the
search sample's Gradle 2.2.1, Java 8, API 22, strict lint, network cleanup,
async ownership, privacy, and UI behavior.

## Problem Frame

The complete local and hosted Android gate is characterized, but the legacy
wrapper downloads Gradle 2.2.1 without archive verification and the SDK-free
checker does not authenticate the checked-in wrapper JAR or launchers. A
runtime upgrade would combine supply-chain hardening with compatibility work.

## Requirements

- **R1:** Preserve Gradle 2.2.1, Android Gradle Plugin 1.2.3, Java 8, API 22,
  build-tools 24.0.3, dependencies, app code, and search behavior.
- **R2:** Pin the official Gradle 2.2.1 all-distribution SHA-256,
  `1d7c28b3731906fd1b2955946c1d052303881585fc14baedd675e4cf2bc1ecab`.
- **R3:** Regenerate the wrapper bootstrap with official Gradle 8.14.5 tooling
  and verify wrapper JAR SHA-256
  `7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172`.
- **R4:** Reject wrapper URL, checksum, JAR, launcher, documentation, and
  completion-evidence drift in the SDK-free checker.
- **R5:** Pass the complete local and final exact-head hosted Android and
  CodeQL gates before tracker reconciliation.

## Key Technical Decisions

- Use Gradle 8.14.5 only to generate the bootstrap while retaining the legacy
  runtime required by Android Gradle Plugin 1.2.3.
- Verify the downloaded distribution and exact checked-in wrapper artifacts as
  separate trust boundaries.
- Preserve the all distribution and state that an uncached bootstrap remains
  dependent on Gradle's HTTPS service.

## Scope Boundaries

In scope: the four wrapper files, static contracts, repository guidance, and
local/hosted evidence. Deferred: runtime modernization, dependencies, search
logic, network behavior, UI, emulator/device tests, and separate PR #2.

## Implementation Units

### U1. Verified Wrapper Bootstrap

Generate the wrapper with official Gradle 8.14.5 tooling, retain Gradle 2.2.1,
and prove fresh Java 8 bootstrap success plus incorrect-checksum rejection.

### U2. Static Contracts And Documentation

Add exact wrapper properties, JAR, launcher, documentation, and completed-plan
contracts to `scripts/check-baseline.sh`.

### U3. Compatibility And Hosted Evidence

Run `make check` from the repository and an external working directory,
exercise focused hostile mutations, and require final exact-head Check and
CodeQL success.

## Risks And Mitigations

- Use a fresh temporary Gradle user home so cached archives cannot hide
  checksum behavior.
- Verify `./gradlew --version` under Java 8 before project tasks.
- Reject application and build-file changes in this unit.
- Leave separate conflicting PR #2 untouched.

## Sources

- [Gradle Wrapper documentation](https://docs.gradle.org/current/userguide/gradle_wrapper.html)
- [Gradle security best practices](https://docs.gradle.org/current/userguide/best_practices_security.html)
- [Gradle 2.2.1 all-distribution checksum](https://services.gradle.org/distributions/gradle-2.2.1-all.zip.sha256)
- [Gradle 8.14.5 wrapper JAR checksum](https://services.gradle.org/distributions/gradle-8.14.5-wrapper.jar.sha256)

## Work Completed

- Regenerated all four wrapper files with official Gradle 8.14.5 tooling while
  retaining the Gradle 2.2.1 all distribution and existing Android runtime.
- Added exact properties, wrapper JAR, launcher, documentation, and completed
  evidence contracts without changing application or build files.

## Verification Completed

- A fresh temporary Gradle user home downloaded the official distribution and
  reported Gradle 2.2.1 on Corretto Java 8 (`1.8.0_482`).
- A disposable wrapper with an incorrect checksum was rejected before Gradle execution.
- SDK-backed `make check` passed with zero lint issues, both unit-test variants,
  and debug assembly from the repository and an external working directory.
- Focused hostile mutations rejected wrapper properties, JAR, launcher,
  documentation, and incomplete plan evidence.
- `sh -n scripts/check-baseline.sh` and `git diff --check` passed.

## Hosted Verification

Hosted pull-request and CodeQL evidence will be recorded after the exact
implementation head completes both canonical checks.
