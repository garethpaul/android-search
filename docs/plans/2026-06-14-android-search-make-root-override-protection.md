# Android Search Make Root Override Protection

Status: Completed

## Problem

The Makefile derives its repository root from its own location, but GNU Make
command-line variables override an ordinary assignment. A hostile `ROOT` value
can redirect the baseline checker, bounded-response security tests, and all
conditional Gradle gates away from the reviewed checkout.

## Requirements

1. Protect the Makefile-derived root with GNU Make's `override` directive.
2. Preserve configurable Android SDK variables, the configurable Gradle
   command, every target, every skip condition, and all existing commands.
3. Require exact protected-root and override semantics plus complete rooted
   baseline, bounded-response, lint, test, and build contracts.
4. Pass local, external-directory, and hostile-root `make check` gates.
5. Reject focused root, tool, path, environment, task, and completed-plan
   mutations.

## Verification

- Run shell syntax and the dependency-free baseline checker first.
- Run bounded local, external-directory, and hostile command-line `ROOT`
  `make check` gates, recording whether the Android SDK executes or truthfully
  skips the legacy Gradle tasks.
- Run focused mutations plus workflow YAML, Android XML, SVG XML, artifact,
  conflict-marker, whitespace, and changed-line credential audits.

## Scope Boundaries

- Do not change search networking, response/image limits, redirect policy,
  exception handling, dependencies, workflows, Android sources, or resources.
- Do not weaken wrapper, bounded-response, or security contracts.
- Do not create SDK placeholders or claim emulator/device verification.
- Do not merge or close any pull request without explicit owner authorization.

## Work Completed

- Protected the Makefile-derived root while preserving SDK and Gradle
  configurability, every target, skip condition, and security test command.
- Added dependency-free contracts for exact variables and complete rooted
  baseline, bounded-response, Gradle, and completed-plan behavior.

## Verification Results

- The focused baseline checker and shell syntax checks passed.
- Local, external-directory, and hostile command-line `ROOT` `make check`
  gates each passed the baseline and bounded-response security tests while
  remaining anchored to this checkout.
- No Android SDK was configured, so Gradle lint, tests, and assembly truthfully
  reported their designed skips in all three contexts; no SDK-backed compile,
  emulator, or device result is claimed.
- All twelve focused mutations were rejected: missing `override`, `CURDIR`,
  recursive root assignment, `firstword`, eager SDK assignment, eager Gradle
  assignment, unrooted baseline or bounded-response test, missing SDK-root
  propagation, replaced Gradle test task, unrooted Gradle build, and reopened
  plan status.
- Workflow YAML, Android XML, SVG XML, shell syntax, conflict-marker,
  whitespace, ignored-artifact, exact-diff, and changed-line credential audits
  passed; only the three intended files changed and no generated artifacts
  remained.
