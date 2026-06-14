# AGENTS.md

## Repository purpose

`garethpaul/android-search` is an Android application or sample. Android Instant Search

## Project structure

- `Makefile` - repository verification targets
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets
- `app` - application source or app module
- `build.gradle` - Gradle build configuration
- `gradlew` - checked-in Gradle wrapper

## Development commands

- Install dependencies: no repository-specific install command is documented.
- Full baseline: `make check`
- Combined verification: `make verify`
- Lint/static checks: `make lint`
- Tests: `make test`
- Build: `make build`
- Android unit tests when the SDK is configured: `./gradlew test`
- Android debug build when the SDK is configured: `./gradlew assembleDebug`
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

## Coding conventions

- Language mix noted in the README: Java (3), shell (1).
- Use the checked-in Gradle wrapper for Android builds when an SDK is configured.

## Testing guidance

- A legacy Android instrumentation smoke test exists under `app/src/androidTest`,
  but there is no substantive behavioral test suite; treat `make check` as the
  minimum baseline.
- Start with the narrowest relevant test or Make target, then run `make check` before handing off if the change is not documentation-only.
- Preserve the 64 KiB response-body limit before parsing backend JSON.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- Image downloads bound compressed bodies and decoded pixel dimensions before allocation.

- Detected references to Twitter. Keep API keys, OAuth credentials, tokens, and account-specific values in local configuration only.
- This legacy Android baseline pins Android build-tools 24.0.3 and Android Gradle Plugin 1.2.3.
- Search result image downloads require HTTPS and bounded connection/read timeouts before decoding the bitmap.
- Image downloads reject redirects and non-success responses before decoding.
- Search JSON requests reject redirects before response validation.
- Search request HTTP clients must shut down their connection managers in a
  `finally` path so success, error-status, empty-body, and exception responses
  release sockets deterministically.
- Search request fallbacks may convert runtime exceptions into generic results,
  but fatal JVM errors must propagate to the platform.
- The search activity guards nullable ActionBar setup before applying icon and home presentation.
- Search menu setup guards missing framework search UI pieces before wiring the searchable configuration or replacing the search icon.
- Search action views are type-checked before SearchView casting so menu resource drift does not crash setup.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
