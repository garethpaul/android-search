# Changes

## 2026-06-09

- Added HTTPS validation and bounded connection/read timeouts for search result
  image downloads, with SDK-free checks against direct unvalidated URL opens.

## 2026-06-08

- Added explicit search request failure handling so missing parameters,
  transport errors, and malformed responses return displayable fallback JSON.
- Hardened search result rendering to tolerate missing text or image fields and
  avoid downloading empty image URLs.
- Added a repository changelog and expanded the documented Android verification
  gate to include lint, tests, and debug assembly.
- Cleaned Android lint findings by moving visible UI text into resources,
  adding an accessibility label for result images, and moving the screen
  background into the app theme.
- Moved bitmap assets to `drawable-nodpi`, removed unused starter strings, and
  documented the narrow legacy lint baseline.
- Added a guarded search response baseline for missing parameters, explicit
  JSON error results, configured HTTP timeouts, optional response fields, and
  empty image URLs.
- Added `make check` as the SDK-free verification wrapper.
- Removed full query URL and raw response-body logging from successful search
  requests.
