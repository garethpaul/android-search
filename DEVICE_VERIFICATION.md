# Android Search Device Verification Matrix

Use this matrix only for an exact implementation commit. Record the commit SHA and pull request
before testing so backend, UI, and lifecycle evidence cannot be transferred to
a different request implementation.

## Evidence Rules

- Use a synthetic query that contains no personal, account, location, or
  business-sensitive information.
- Record the Android SDK, API level, device or emulator class, network setup,
  backend fixture or fault-injection method, result, and evidence identifier.
- Do not include device identifiers, response bodies, account names, cookies,
  tokens, unrelated notifications, or raw diagnostic dumps.
- Store durable evidence outside git. Link only a sanitized run, screenshot, or
  short log excerpt by stable identifier.
- Record each result as `pass`, `fail`, `blocked`, or `not run`, with an owner
  and follow-up for every result other than `pass`.
- Do not convert `not run` into passing evidence.

## Run Identity

| Field | Value |
| --- | --- |
| Commit SHA | `not run` |
| Pull request | `not run` |
| Android SDK / API | `not run` |
| Device or emulator | `not run` |
| Backend fixture | `not run` |
| Network profile | `not run` |
| Synthetic query | `not run` |
| Evidence location | `not run` |

## Verification Matrix

| Scenario | Expected evidence | Result | Evidence |
| --- | --- | --- | --- |
| Valid search | A synthetic query renders the expected text and image without logging the query or response. | `not run` | `not run` |
| Blank query | Whitespace-only input is rejected without starting a network request. | `not run` | `not run` |
| Overlength query | Input above 200 characters is rejected before URL encoding or task creation. | `not run` | `not run` |
| Rapid repeated searches | Only the latest request owns the text and image result; superseded tasks cannot overwrite it. | `not run` | `not run` |
| Cancel active search | Leaving or pausing the activity cancels active search and image work without a late UI update. | `not run` | `not run` |
| Offline request | Connection failure produces a generic error state without query-bearing or exception-bearing logs. | `not run` | `not run` |
| Redirected JSON | A redirected search response is rejected before body parsing. | `not run` | `not run` |
| Malformed UTF-8 | Invalid UTF-8 is rejected before JSON parsing and does not render replacement text. | `not run` | `not run` |
| Oversized JSON | Declared and streaming bodies above 64 KiB fail without unbounded allocation. | `not run` | `not run` |
| Wrong JSON media type | A non-JSON response is rejected before acquiring its body stream. | `not run` | `not run` |
| Image redirect | A redirected image response is rejected without decoding. | `not run` | `not run` |
| Oversized image | Compressed-body or decoded-dimension limits reject the image without allocation pressure. | `not run` | `not run` |
| Rotation during search | Rotation or recreation does not let an old request update the replacement activity. | `not run` | `not run` |
| Process relaunch | Relaunch starts with no stale query, image, task ownership, cookie, or sensitive state. | `not run` | `not run` |

## Current Status

No Android SDK, emulator, backend fixture, controlled network, physical device,
or live UI scenario was executed for this checklist. Treat every Android, backend, network, and UI row as unexecuted
until evidence is attached to the exact commit.
