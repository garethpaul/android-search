# Type-check the search result image view

Status: Completed

## Problem

`MainActivity` guarded a missing result image view but force-cast the value from
`findViewById` first. A stale or modified layout that reused `R.id.imageView`
for another view type could therefore throw `ClassCastException` while clearing
or displaying search results.

## Fix

- Centralize result image lookup in a helper that checks `instanceof ImageView`.
- Use the helper for both image clearing and image download setup.
- Preserve the existing no-download behavior for empty backend image values.
- Log only a generic UI-availability warning without backend data.

## Verification

- Observe the source contract fail before implementation.
- Run `make check` and the host policy harnesses.
- Require hosted Gradle and CodeQL checks on the exact PR head.
