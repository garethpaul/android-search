# Android Search

<!-- README-OVERVIEW-IMAGE -->
![Project overview](docs/readme-overview.svg)

Legacy Android search sample that sends the user's search query to the
`garethpaul-app.appspot.com` backend and displays returned text and image data.

## Toolchain

This project currently uses the original Android build stack:

- Gradle wrapper 2.2.1
- Android Gradle Plugin 1.2.3
- compile SDK 22 / target SDK 22
- Android build-tools 24.0.3

Configure an Android SDK path before running Gradle:

```sh
export ANDROID_HOME=/path/to/android-sdk
```

or create an untracked `local.properties` file:

```properties
sdk.dir=/path/to/android-sdk
```

## Verify

Run the SDK-free source baseline check first:

```sh
scripts/check-baseline.sh
```

Then run Gradle after Android SDK configuration is available:

```sh
ANDROID_HOME=/home/gjones/android-sdk ./gradlew lint --no-daemon
ANDROID_HOME=/home/gjones/android-sdk ./gradlew test --no-daemon
ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon
```

If Gradle reports `SDK location not found`, configure `ANDROID_HOME` or
`local.properties` and rerun the command.

## Modernization Notes

The current baseline URL-encodes search queries before calling the backend,
uses HTTPS Maven Central for dependency resolution, and pins build-tools to a
host-compatible version. `app/lint.xml` suppresses only the obsolete lint API
database error from this old toolchain and the missing-density-folder warning
for bitmap assets intentionally kept in `drawable-nodpi`. Future work should
replace the deprecated Apache HTTP client and AsyncTask flow, add testable
request/response parsing, modernize SDK levels, and add emulator or device
coverage.
