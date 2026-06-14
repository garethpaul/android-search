# Android Search Query Length

Status: Completed

## Problem

Search intents accepted arbitrarily long text before UTF-8 URL encoding and
outbound request construction.

## Requirements

1. Trim the search query once before validation.
2. Reject blank or greater-than-200-character queries before task creation.
3. Preserve valid search, request cancellation, image clearing, and failure UI.

## Verification

- Root and external-directory `make check` passed portable source contracts;
  unavailable Android SDK tasks remained truthfully skipped.
- Six hostile mutations were rejected for limit removal, normalization drift,
  execution bypass, documentation drift, and reopened plan status.
