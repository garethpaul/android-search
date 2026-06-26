# Search Button View Type Guard

Status: Completed

## Context

The menu already type-checked the action view before casting it to
`SearchView`, but it cast the framework child returned for
`android:id/search_button` directly to `ImageView`. OEM, theme, or framework
drift could return a different `View` subtype and crash menu creation before the
existing null check ran.

## Design

- Read the internal child as `View`.
- Customize the icon only when the child is an `ImageView`.
- Keep menu creation successful and retain the framework default when the child
  is absent or differently typed.
- Emit a fixed warning without view details or user data.
- Preserve searchable configuration, action-view handling, resources, network
  behavior, and public Android lifecycle signatures.

## Test First

The SDK-free baseline was extended first to require the neutral `View` local,
the subtype check, the post-check cast, and the sanitized fallback warning. It
failed against the direct cast before implementation and passed afterward.

## Verification

- Run `scripts/check-baseline.sh`.
- Run every public Make target under `C` and `C.UTF-8` and from `/tmp`.
- Reject a mutation restoring the direct cast.
- Run shell syntax checks and `git diff --check`.
- Run hosted Android lint/tests/build and CodeQL on the exact PR head.
- Run canonical `make check` with local SDK-backed steps truthfully skipped when
  no Android SDK is configured.

## Scope Boundaries

- No search query, intent, networking, image policy, layout, resource, manifest,
  dependency, SDK, or API behavior change.
- Runtime device/OEM menu rendering remains covered by the explicit device
  verification matrix rather than claimed from source checks.

## Verification Completed

- The red-first SDK-free source contract failed before implementation and then
  passed with the type-safe child customization.
- The direct-cast restoration mutation was rejected.
- `make lint`, `test`, `build`, `verify`, and `check` passed under `C` and
  `C.UTF-8` and from an external working directory; local Gradle-backed steps
  explicitly skipped because no Android SDK is configured.
- Shell syntax checks and `git diff --check` passed.
- Hosted exact-head and review evidence will be recorded in the PR.
