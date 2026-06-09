---
title: Search Action View Type Guard
type: reliability
status: completed
date: 2026-06-09
---

# Search Action View Type Guard

## Problem Frame

Search menu setup guarded missing menu items and searchable configuration, but
it still cast the menu action view directly to `SearchView`. Resource or
framework drift could return a different view type and crash menu creation with
a `ClassCastException`.

## Scope Boundaries

- Preserve the existing SearchView menu behavior when the menu resource is
  valid.
- Keep the current searchable XML and custom search icon behavior.
- Avoid redesigning the search UI or migrating to a modern toolbar in this
  pass.
- Keep verification available through the SDK-free baseline script.

## Implementation Units

### U1: Type-Check The Action View

Files:

- Modify `app/src/main/java/gpj/androidsearch/MainActivity.java`

Approach:

- Keep the existing search service and menu item guards.
- Read the action view into a `View` local.
- Verify it is a `SearchView` before casting.
- Log a sanitized warning and keep menu creation non-fatal when the type is
  unexpected.

### U2: Cover And Document The Contract

Files:

- Modify `scripts/check-baseline.sh`
- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Add SDK-free checks that reject direct action-view casts.
- Document the action-view type-safety behavior in project notes.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
