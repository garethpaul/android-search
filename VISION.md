## Android Search Vision

Search intents are trimmed and limited to 200 characters before URL encoding.

This document explains the current state and direction of the project.
Project overview and developer docs: [`README.md`](README.md)

Android Search is a legacy Android instant-search sample. It accepts an Android
search intent, queries a small HTTPS API, displays returned text, and downloads
an image for the result.

The repository is useful as a compact example of search UI wiring, network
request handling, and JSON response display in an older Android stack.

The goal is to keep the sample understandable while making future network,
threading, and Android API modernization deliberate.

The current focus is:

Priority:

- Image downloads bound compressed bodies and decoded pixel dimensions before allocation.

- Preserve the search intent and `SearchView` flow
- Keep the remote API behavior visible in source
- Avoid broad changes to networking without documenting response expectations
- Maintain a buildable Android Studio/Gradle project baseline
- Maintain SDK-free `make check` coverage for network and response guardrails
- Keep root lint, test, and build gates wired to the Gradle project
- Keep search queries and raw responses out of success-path device logs
- Convert recoverable runtime failures into generic results without catching
  fatal JVM errors
- Keep the 64 KiB response-body limit enforced before backend JSON parsing
- Reject malformed UTF-8 search JSON before parsing backend responses
- Search JSON responses require successful 2xx status before entity access
- Keep backend-provided image URLs HTTPS-only and timeout-bounded before decode
- Backend-provided image URLs require HTTPS, a non-empty host, and no user-info credentials before connection setup.
- Image downloads reject redirects and non-success responses before decoding.
- Keep Android app-data backup disabled by default for the sample
- Keep search activity startup safe when legacy ActionBar presentation is
  unavailable
- Keep search menu setup tolerant of missing framework search UI components
- Keep search options callbacks tolerant of missing menu callback objects
- Keep SearchView action-view wiring type-safe around menu resource drift
- Keep SearchView wiring tolerant of missing searchable configuration
- Keep search intent handling tolerant of null intents and missing result views
- Keep network completion asynchronous and ignore results after activity
  teardown
- Abort active JSON and image transports when search task ownership is cancelled
- Keep search and image results owned by the latest active request
- Keep the SDK-free `make check` baseline running in GitHub Actions
- Keep the legacy Gradle runtime behind a checksum-verified generated wrapper
- Keep exact-commit Android Search device verification matrix evidence separate
  from portable checks, with unexecuted backend, network, and UI rows explicit

Next priorities:

- Replace deprecated Apache HTTP usage with maintained networking APIs
- Add input encoding, null handling, and error-state coverage around search
- Document the expected API response shape
- Evaluate Gradle runtime, SDK, and test modernization together in a dedicated
  compatibility pass; wrapper hardening is separate
- Execute the device verification matrix with synthetic queries and
  privacy-safe backend, network, and lifecycle evidence

Contribution rules:

- One PR = one focused search, networking, or build change.
- Keep the sample's query-to-result path easy to inspect.
- Document endpoint or response-shape changes in repository docs.
- Preserve Android backup opt-out when changing the manifest.
- Verify UI behavior manually when changing search intent handling.

## Security And Privacy

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

Search queries can contain personal information. Do not add analytics,
unnecessary logging, or broader network transmission of query text.

Endpoint changes should use HTTPS and make timeout and failure behavior clear to
users and maintainers.

## What We Will Not Merge (For Now)

- New remote services without response docs and failure handling
- Networking rewrites mixed with UI redesigns
- Query logging or analytics without an explicit privacy rationale
- Build migrations that leave the sample unverifiable

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
