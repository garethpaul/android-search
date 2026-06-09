# Search ActionBar Guard

## Status: Completed

## Context

`MainActivity.onCreate()` configured the ActionBar directly through
`getActionBar().set...`. Legacy theme or embedding changes that return a null
ActionBar could therefore crash the activity before search intent handling ran.

## Objectives

- Preserve the existing search icon and home presentation when an ActionBar is
  present.
- Avoid startup crashes when `getActionBar()` returns null.
- Keep the behavior covered by the SDK-free baseline checker.

## Work Completed

- Added `configureActionBar()` in `MainActivity`.
- Guarded nullable `getActionBar()` results before applying presentation
  settings.
- Extended `scripts/check-baseline.sh` to reject direct `getActionBar().set...`
  calls and require the guard helper.
- Updated README, VISION, and CHANGES notes for the startup guard.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

Gradle verification remains a separate SDK-backed step for hosts with a
compatible Android SDK.
