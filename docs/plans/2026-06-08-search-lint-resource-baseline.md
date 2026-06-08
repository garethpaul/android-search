---
title: Search Lint Resource Baseline
type: chore
status: completed
date: 2026-06-08
---

# Search Lint Resource Baseline

## Summary

Clean the remaining Android lint findings in the legacy search sample while
preserving the URL encoding and build metadata baseline.

## Requirements

- R1. Preserve UTF-8 URL encoding for backend search queries.
- R2. Keep compile SDK 22, target SDK 22, and build-tools 24.0.3.
- R3. Move visible UI text into string resources.
- R4. Keep bitmap assets in `drawable-nodpi` and document the narrow lint
  suppressions required by the old Android toolchain.
- R5. Verify with the SDK-free source check, Android lint, unit tests, and
  debug assembly.

## Verification

- `scripts/check-baseline.sh`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew test --no-daemon`
- `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`
