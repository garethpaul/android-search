# Search Searchable Info Guard

status: completed

## Context

Search menu setup already guards the action item, search service, and
`SearchView`. It still passed the result of
`SearchManager.getSearchableInfo(getComponentName())` directly into the
SearchView. If manifest metadata or `searchable.xml` drifts, Android can return
no searchable configuration.

## Objectives

- Preserve existing SearchView menu setup when searchable configuration exists.
- Avoid configuring the SearchView with a missing searchable configuration.
- Log a sanitized warning instead of crashing or exposing query text.
- Keep the SDK-free baseline covering the guard.

## Work Completed

- Added a `SearchableInfo` local and null guard before SearchView setup.
- Returned from menu setup when searchable configuration is unavailable.
- Extended `scripts/check-baseline.sh`.
- Updated README, VISION, and CHANGES.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

## Follow-Up Candidates

- Add an instrumentation test for malformed or missing searchable metadata
  after the legacy Android stack is modernized.
- Replace deprecated search/networking APIs in a dedicated modernization pass.
