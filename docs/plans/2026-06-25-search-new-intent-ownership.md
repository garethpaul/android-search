# Search New-Intent Ownership

## Status: Completed

## Problem

`MainActivity` uses `singleTop`, so a later search is delivered through
`onNewIntent`. The activity dispatched that new search immediately but did not
call `setIntent`. Android therefore kept `getIntent()` pointing at the original
launch intent. A later recreation or any code consulting the activity's current
intent could replay stale query state instead of the most recently delivered
search.

## Evidence and Decision

Android's `Activity.getIntent()` documentation states that `onNewIntent` still
returns the original intent until `setIntent` updates it. The narrow fix calls
the superclass, installs the new intent, and only then dispatches the query.

Alternatives considered:

- Keeping the current direct dispatch leaves stale activity ownership.
- Duplicating query state into saved-instance state introduces a second source
  of truth for a value Android already models through the current intent.
- Calling `super.onNewIntent(intent)`, `setIntent(intent)`, then
  `handleIntent(intent)` preserves platform lifecycle ownership with no new
  persistence mechanism and is the selected approach.

Primary reference:

- https://developer.android.com/reference/android/app/Activity#getIntent()

## Work Completed

- Added superclass delivery and current-intent replacement before search
  dispatch in `MainActivity.onNewIntent`.
- Added an ordered SDK-free source contract for all three lifecycle operations.
- Updated contributor, user, security, vision, and timestamped change guidance.

## Verification

- The pre-fix baseline failed because `super.onNewIntent(intent)` and
  `setIntent(intent)` were absent.
- `sh scripts/check-baseline.sh` passed after implementation.
- Repository-root and external-directory `make check` passed.
- Three hostile intent-ownership mutations were rejected: removing superclass
  delivery, removing `setIntent`, and dispatching before intent replacement.
- Isolated hostile intent-ownership mutations were rejected without changing
  query validation, cancellation, network, image, or response behavior.
- No Android SDK, emulator, or physical device was used; device recreation
  remains an integration scenario in `DEVICE_VERIFICATION.md`.

## Scope Boundaries

- Search query content, URL construction, network dispatch, result ownership,
  and cancellation remain unchanged.
- No saved-state format, manifest launch mode, Android API level, Gradle, or
  dependency change is included.
