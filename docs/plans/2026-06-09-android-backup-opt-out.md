# Android Backup Opt Out

status: completed

## Context

The Android Search sample manifest opted into platform app-data backup by
default. Search queries can contain personal information, so the checked-in
manifest should fail closed and avoid backing up app state unless a maintainer
deliberately changes that boundary.

## Objectives

- Set the application manifest to `android:allowBackup="false"`.
- Preserve the existing search intent and network behavior.
- Extend the SDK-free baseline checker so backup opt-in cannot return silently.
- Document the privacy guard in README, SECURITY, VISION, and CHANGES.

## Work Completed

- Disabled app-data backup in `app/src/main/AndroidManifest.xml`.
- Added static baseline coverage for the manifest opt-out.
- Added this completed plan and top-level documentation notes.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `git diff --check`
