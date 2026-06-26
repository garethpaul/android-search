# Changes

## 2026-06-26 02:54 PDT - P2 - Type-check framework search buttons

### Summary
Hardened search menu creation against OEM or framework drift that exposes the
internal search-button ID as a non-`ImageView` child.

### Work completed
- Read the framework child into a neutral `View` reference.
- Apply the custom cross icon only after an `instanceof ImageView` check.
- Preserve the framework default icon when the child is missing or differently
  typed and emit only a sanitized warning.
- Added an SDK-free source contract rejecting the previous direct cast.
- Framework search-button children are type-checked before ImageView casting.

### Threads
- Started: none.
- Continued: search menu framework-boundary hardening — child type guard complete.
- Stopped: none.

### Files changed
- `app/src/main/java/gpj/androidsearch/MainActivity.java` — makes the internal
  search-button customization type-safe.
- `scripts/check-baseline.sh` — enforces source, plan, and documentation
  contracts.
- Documentation and plan files — record the non-fatal fallback behavior.

### Validation
- Red-first `scripts/check-baseline.sh` — failed on the missing neutral-view
  and subtype guard, then passed after implementation.
- Direct-cast restoration mutation — rejected by the SDK-free baseline.
- `make lint|test|build|verify|check` — passed under `C` and `C.UTF-8` and from
  `/tmp` through the absolute Makefile path.
- Canonical gates truthfully skipped Gradle-backed steps because no local
  Android SDK is configured.
- Shell syntax and `git diff --check` — passed.
- Hosted Android/CodeQL exact-head checks and review remain the next action.

### Bugs / findings
- P2: the prior cast executed before the null check, so an unexpected framework
  child subtype could throw `ClassCastException` during menu creation.

### Blockers
- None for SDK-free validation; local Android SDK availability is checked by
  the canonical Make gate.

### Next action
- Open the PR, run hosted exact-head validation and review, then merge.

## 2026-06-25 07:28:18 PDT

- New singleTop search intents become the activity's current intent before dispatch.
- Added ordered lifecycle contracts that reject missing superclass delivery,
  stale activity intent ownership, and dispatch-before-ownership regressions.

## 2026-06-15

- Backend-provided image URLs require HTTPS, a non-empty host, and no user-info credentials before connection setup.
- Backend-provided image URLs use only the default HTTPS port before connection setup.
- Backend-provided image URLs cannot explicitly target loopback hosts before connection setup.
- Backend-provided image URLs cannot explicitly target private, link-local, or unspecified IP literals before connection setup.
- Backend-provided image URLs cannot explicitly target IPv4 shared address space before connection setup.
- Backend-provided image URLs cannot target IANA special-use IPv4 protocol-assignment, documentation, deprecated relay, benchmarking, or reserved ranges.
- Backend-provided image URLs cannot target IANA non-global IPv6 translation, discard-only, dummy, benchmarking, documentation, or SRv6 SID ranges.
- Backend-provided image URL DNS answers must exclude prohibited address classes, and a direct HTTPS connection must match an authorized answer before TLS or HTTP data is sent.

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
