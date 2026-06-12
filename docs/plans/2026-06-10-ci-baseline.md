# Android Search CI Baseline

## Status: Completed

## Context

`android-search` has source contracts and guarded Gradle gates behind
`make check`. The canonical workflow now installs the compatible legacy Android
toolchain so query/privacy, UI guard, Android backup, lint, tests, and assembly
are checked before review.

## Objectives

- Run the complete `make check` wrapper in GitHub Actions.
- Install Android API 22 and build-tools 24.0.3 under Java 8.
- Make the workflow and complete hosted gate part of the source baseline.

## Work Completed

- Added `.github/workflows/check.yml` to run `make check` on pushes, pull
  requests, and manual dispatches.
- Pinned checkout and Java setup to immutable revisions, limited permissions to
  repository reads, and bounded the job to 15 minutes.
- Installed the exact API 22 and build-tools 24.0.3 packages before running the
  existing guarded Makefile targets.
- Made lint warnings fatal while retaining only documented legacy suppressions.
- Selected deterministic non-queued PNG crunching without skipping aapt
  validation.
- Extended `scripts/check-baseline.sh` to require the CI workflow and this
  completed plan.
- Updated README, VISION, SECURITY, and CHANGES with the CI baseline.
- Disabled persisted checkout credentials and replaced partial string matching
  with a canonical single-workflow contract.
- Added self-protecting CODEOWNERS coverage for CI controls and application
  source; repository rules remain responsible for requiring owner approval.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`

## Follow-Up Candidates

- Exercise the search flow on an emulator and live backend separately.
- Modernize the legacy Gradle, Android plugin, HTTP API, and target SDK in a
  behavior-aware follow-up.
