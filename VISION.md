## Android Search Vision

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

- Preserve the search intent and `SearchView` flow
- Keep the remote API behavior visible in source
- Avoid broad changes to networking without documenting response expectations
- Maintain a buildable Android Studio/Gradle project baseline
- Maintain SDK-free `make check` coverage for network and response guardrails
- Keep root lint, test, and build gates wired to the Gradle project
- Keep search queries and raw responses out of success-path device logs
- Keep backend-provided image URLs HTTPS-only and timeout-bounded before decode
- Keep search activity startup safe when legacy ActionBar presentation is
  unavailable
- Keep search menu setup tolerant of missing framework search UI components

Next priorities:

- Replace deprecated Apache HTTP usage with maintained networking APIs
- Add input encoding, null handling, and error-state coverage around search
- Document the expected API response shape
- Modernize Gradle, SDK levels, and tests in a dedicated pass

Contribution rules:

- One PR = one focused search, networking, or build change.
- Keep the sample's query-to-result path easy to inspect.
- Document endpoint or response-shape changes in repository docs.
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
