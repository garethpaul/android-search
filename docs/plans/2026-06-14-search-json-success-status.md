# Require Successful JSON HTTP Status

Status: Planned

## Context

The JSON response handler rejects statuses at or above 300 but accepts
informational `1xx` responses. Search payloads should be read and parsed only
from final successful `2xx` responses, matching the image transport boundary.

## Scope

- Reject JSON response statuses below 200 and at or above 300.
- Perform the status decision before entity, media-type, stream, or body access.
- Preserve redirect rejection, response limits, strict UTF-8, transport
  cancellation, generic errors, and existing UI behavior.
- Add mutation-sensitive portable contracts and maintenance documentation.

## Verification

- Run SDK-backed repository `make check` and the external-directory portable
  gate with SDK variables unset.
- Reject mutations that restore informational-status acceptance, weaken the
  upper bound or ordering, remove documentation, or reopen this plan.
- Audit exact paths, generated artifacts, changed-line secret patterns, and
  whitespace before commit.

## Risks

- No live backend, proxy, or controlled informational response was exercised.
- Existing stacked pull requests remain open and require explicit owner
  authorization before merge or closure.
