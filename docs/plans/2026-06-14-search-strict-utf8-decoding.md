# Search Strict UTF-8 Decoding

Status: Completed

## Context

The bounded search response reader uses `new String(bytes, "UTF-8")`, which
silently replaces malformed byte sequences. Corrupted or hostile response data
can therefore be altered before JSON parsing instead of failing through the
existing generic search-error path.

## Scope

- Decode bounded search JSON bytes with malformed and unmappable input set to
  `CodingErrorAction.REPORT`.
- Preserve the 64 KiB limit, exact-boundary behavior, stream cleanup, media
  type validation, redirect rejection, JSON parsing, and generic errors.
- Add an executable malformed-byte regression to the existing pure-Java body
  harness.
- Add mutation-sensitive source, test, documentation, and plan contracts.

## Verification Plan

- Demonstrate the malformed-byte regression fails against replacement decoding
  before changing production code.
- Run the focused bounded-body harness, SDK-backed `make check`, and the
  external-working-directory SDK-free gate.
- Reject isolated mutations that restore replacement decoding, weaken decoder
  policy, remove the fixture, weaken documentation, or reopen the plan.
- Audit the exact diff, generated artifacts, conflict markers, whitespace, and
  credential-shaped additions before commit and push.

## Risks

- A backend that emits malformed UTF-8 will now fail closed rather than
  producing replacement characters.
- This change does not inspect JSON semantics, alter image decoding, or replace
  the legacy Apache HTTP stack.

## Verification

Completed on 2026-06-14:

- The malformed-byte regression failed against replacement decoding and passed
  after strict decoder policy was installed.
- The focused bounded-response harness passed exact size, streaming overflow,
  zero-read, valid multibyte UTF-8, and malformed UTF-8 cases.
- SDK-backed and external-working-directory `make check` passed.
- Six isolated hostile mutations were rejected across replacement decoding,
  malformed and unmappable policies, the regression fixture, documentation,
  and completed-plan status.
- Exact-diff, generated-artifact, whitespace, conflict-marker, and
  credential-pattern audits passed before commit.
