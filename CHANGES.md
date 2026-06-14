# Changes

## 2026-06-14

- Search JSON responses require successful 2xx status before entity access.
- Search cancellation now aborts active JSON requests and disconnects active
  image transports, including cancellation races during transport publication.
- Added an exact-commit Android Search device verification matrix for query
  boundaries, cancellation, backend failures, response and image guards,
  rotation, relaunch, and privacy-safe evidence, with every runtime row explicitly unexecuted.
- Search intents are trimmed and limited to 200 characters before URL encoding.
- Required JSON and image response media types before acquiring network body
  streams, including parameter and structured `+json` handling.
- Disabled redirects for fixed-endpoint JSON search requests.
- Search clients reject malformed UTF-8 search JSON before JSON parsing.
- Added a dependency-free Java media-type matrix to the canonical test gate.

## 2026-06-13

- Image downloads bound compressed bodies and decoded pixel dimensions before allocation.
- Image downloads reject redirects and non-success responses before decoding.
- Added a 64 KiB response-body limit for declared and streaming search JSON,
  with an executable Java boundary harness and guaranteed stream cleanup.
- Narrowed the final search request fallback to runtime exceptions so fatal JVM
  errors continue to propagate to the Android platform.
- Replaced throwable-bearing network and image errors with generic search
  failure logs and added contracts against exception- or request-derived data.

## 2026-06-12

- Regenerated the Gradle wrapper bootstrap with official Gradle 8.14.5 tooling
  while retaining the Gradle 2.2.1 Android runtime.
- Pinned the official distribution checksum and exact wrapper artifact contracts.
- Promoted CI from source-only contracts to the complete API 22 lint, unit-test,
  and debug-assembly gate with deterministic legacy resource processing.
- Shut down each legacy search HTTP client's connection manager after request
  completion or failure to avoid retaining sockets across repeated queries.

## 2026-06-10

- Removed activity-thread blocking on `AsyncTask.get()`, rejected blank search
  queries, and ignored network callbacks after activity teardown.
- Cancelled superseded query/image tasks, rejected stale completions, and
  cleared prior images before rendering a new result.
- Made root checks location-independent, accepted `ANDROID_SDK_ROOT`, and
  pinned CI to Ubuntu 24.04 with superseded-run cancellation.
- Added pinned, read-only GitHub Actions that runs `make check` for the Android
  Search baseline with explicit SDK-free execution.
- Extended the SDK-free baseline to require the CI workflow and completed CI
  plan.
- Removed the maintainer-specific Android SDK path from the Makefile.
- Removed a generated preview that did not match the app's TextView/ImageView
  result screen.
- Disabled persisted checkout credentials, added ownership for CI controls and
  privacy-sensitive application source, and replaced partial workflow checks
  with one canonical workflow contract.

## 2026-06-09

- Guarded search options menu callbacks when Android supplies missing menu or
  menu item objects.
- Disabled Android app-data backup in the checked-in manifest and added
  SDK-free baseline coverage for the opt-out.
- Type-checked the search menu action view before casting it to `SearchView` so
  menu resource drift does not crash setup.
- Guarded SearchView setup when the searchable configuration lookup is
  unavailable.
- Guarded search intent handling when the incoming intent or result text/image
  views are unavailable.
- Guarded search menu setup when the action item, search service, SearchView,
  or internal search icon view is unavailable.
- Added root `make lint`, `make test`, and `make build` gates around the
  existing SDK-free and Gradle verification commands.
- Added HTTPS validation and bounded connection/read timeouts for search result
  image downloads, with SDK-free checks against direct unvalidated URL opens.
- Guarded nullable ActionBar setup before applying search icon and home
  presentation.

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
