# Bound Search Result Image Bodies

Status: Completed

## Context

Search image downloads reject redirects and non-success responses but pass the
remote stream directly to `BitmapFactory`. Large, understated, or unknown-size
responses and extreme decoded dimensions can consume unbounded memory.

## Requirements

- Bound declared and streamed compressed image bodies to 1 MiB.
- Preserve exact-limit acceptance and reject one-byte overflow before decode.
- Inspect bitmap dimensions before allocation and reject invalid or more than
  four million pixels.
- Preserve HTTPS-only URLs, redirect rejection, 2xx status gating, timeouts,
  cancellation ownership, stream closure, and connection disconnection.
- Extend the pure-Java boundary harness and static contracts.

## Scope Boundaries

- Do not add caching, retries, alternate image libraries, scaling, or new UI.
- Do not change search JSON limits, backend requests, or Android dependencies.
- Do not claim live endpoint, emulator, device, or decoder fault injection.

## Verification Plan

- `make check` and external-working-directory `make check`.
- Pure-Java exact-boundary and one-byte-overflow tests.
- Hostile mutations for byte-limit expansion/bypass, direct stream decoding,
  dimension bypass, pixel overflow, gate removal, docs, and plan status.
- Diff, artifact, conflict-marker, and credential-shaped addition audits.

## Work Completed

- Reused the bounded response reader for exact-limit compressed image bytes.
- Rejected invalid and over-four-million-pixel dimensions before bitmap allocation.
- Added pure-Java byte-boundary coverage and portable static contracts.

## Verification Completed

- Local and external-working-directory `make check` passed the SDK-free
  baseline and pure-Java exact-limit and one-byte-overflow harness. Android
  lint, Gradle tests, and build truthfully skipped without an Android SDK.
- Eight focused hostile mutations were rejected: limit expansion, direct
  stream decoding, bounded-reader bypass, bounds-probe removal, pixel-limit
  removal, overflow-test removal, README guidance, and plan-status rollback.
