# Search Options Callback Guard

Date: 2026-06-09
Status: Completed

## Problem

Search menu setup guarded missing action items, search services, action views,
and searchable configuration, but the callback entry points still assumed
Android always supplied non-null `Menu` and `MenuItem` objects. Stale framework
or test callback paths could crash before the existing inner guards ran.

## Scope

- Preserve normal SearchView menu inflation and selection behavior.
- Return without handling when callback inputs are missing.
- Avoid logging query text or response data.
- Keep verification available through the SDK-free baseline check.

## Work Completed

- Added a null guard to `onCreateOptionsMenu(Menu menu)` before inflation.
- Added a null guard to `onOptionsItemSelected(MenuItem item)` before reading
  the selected item id.
- Extended the SDK-free baseline for the callback-level menu guards.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
