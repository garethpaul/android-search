---
title: Search Intent UI Guard
type: reliability
status: completed
date: 2026-06-09
---

# Search Intent UI Guard

## Problem Frame

`MainActivity.handleIntent()` assumed Android always delivered a non-null
intent and that the result text and image views were available. Legacy theme,
layout, or lifecycle changes could otherwise crash the sample before showing a
user-facing search result or fallback.

## Scope Boundaries

- Preserve the existing Android search action flow.
- Preserve the backend request and JSON response handling behavior.
- Do not redesign the search screen or migrate away from `AsyncTask`.
- Keep verification available through the SDK-free baseline script.

## Implementation Units

### U1: Guard Search Intent And Result Views

Files:

- Modify `app/src/main/java/gpj/androidsearch/MainActivity.java`

Approach:

- Return early when the incoming intent is unavailable.
- Ignore non-search intents before reading search extras.
- Return early when the result text view is unavailable.
- Guard the result image view before starting the image download task.

### U2: Cover And Document The Contract

Files:

- Modify `scripts/check-baseline.sh`
- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Add SDK-free checks for the intent and result view guards.
- Reject the old direct image-view task construction pattern.
- Record the null-safety behavior in project maintenance notes.

## Verification

- `make check`
- `scripts/check-baseline.sh`
- `git diff --check`
