---
title: Search Menu Null Safety
type: reliability
status: completed
date: 2026-06-09
---

# Search Menu Null Safety

## Problem Frame

The search menu setup assumed the action item, framework search service,
`SearchView`, and internal search button image view were all present. Legacy
theme, resource, or framework differences could make any of those lookups
return null and crash menu creation.

## Scope Boundaries

- Preserve the existing `SearchView` flow and searchable XML configuration.
- Keep the custom search icon behavior when the internal image view is present.
- Do not redesign the search UI or migrate networking in this pass.
- Keep verification available through the SDK-free baseline script.

## Implementation Units

### U1: Guard Menu Setup

Files:

- Modify `app/src/main/java/gpj/androidsearch/MainActivity.java`

Approach:

- Check the search menu item before reading its action view.
- Check the search service and `SearchView` before setting searchable info.
- Only replace the internal search button image when that view is available.

### U2: Cover And Document The Contract

Files:

- Modify `scripts/check-baseline.sh`
- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Add SDK-free checks that reject chained nullable menu lookups.
- Document the search menu null-safety behavior in project notes.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `make verify`
- `git diff --check`
