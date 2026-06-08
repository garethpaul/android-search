---
title: Android Search URL and Build Baseline
type: fix
status: completed
date: 2026-06-08
---

# Android Search URL and Build Baseline

## Summary

Raise the baseline for the legacy Android search app by making search request
URLs encode user queries safely, pinning host-compatible Android build-tools,
adding an SDK-free source check, and documenting local verification commands.

---

## Problem Frame

`NetworkRequest` builds its backend URL by directly concatenating the raw search
query into the `q=` parameter. Queries containing spaces, ampersands, or other
reserved URL characters can produce malformed requests or change query
semantics. The project also uses build-tools 22.0.1, whose 32-bit `aapt` does
not run on this host, and the repository has no README or local baseline check.

---

## Requirements

- R1. Search queries must be URL-encoded before being appended to the backend request URL.
- R2. The backend endpoint and `q` parameter name must remain unchanged.
- R3. The app must pin a host-compatible build-tools version while preserving compile SDK 22 and target SDK 22.
- R4. Build repositories must use explicit HTTPS Maven Central URLs instead of JCenter.
- R5. The repository must include an SDK-free source check for request URL and build metadata drift.
- R6. README documentation must explain the legacy Android toolchain and verification commands.

---

## Key Technical Decisions

- **Extract URL construction:** Add a small `NetworkRequest.buildSearchUrl`
  helper so URL encoding is explicit and easy to guard.
- **Use `URLEncoder` with UTF-8:** This keeps the implementation available to
  the legacy Java/Android stack without new dependencies.
- **Pin build-tools 24.0.3:** The installed 24.0.3 build-tools provide a 64-bit
  `aapt` that can assemble on this host.
- **Use HTTPS Maven Central:** Android Gradle Plugin 1.2.3 resolves from Maven Central, so JCenter is unnecessary.
- **Use source checks:** Shell checks can guard URL encoding and build metadata
  before emulator or device coverage exists.

---

## Scope Boundaries

- This pass does not replace deprecated Apache HTTP APIs or AsyncTask.
- This pass does not change the backend endpoint, response parsing, UI layout, or search intent behavior.
- This pass does not migrate Gradle, Android Gradle Plugin, target SDK, or app dependencies.
- This pass does not add emulator or instrumentation tests.

---

## Implementation Units

### U1. Encode Search Query URLs

- **Goal:** Preserve the existing backend call while safely encoding user input.
- **Files:** `app/src/main/java/gpj/androidsearch/NetworkRequest.java`
- **Patterns:** Keep `AsyncTask` and `DefaultHttpClient` behavior unchanged; route URL creation through a helper.
- **Test Scenarios:**
  - URL construction uses `URLEncoder.encode(String.valueOf(query), "UTF-8")`.
  - The endpoint remains `https://garethpaul-app.appspot.com/api/search?q=`.
  - Raw string concatenation with the unencoded query is absent.
- **Verification:** `scripts/check-baseline.sh`, `ANDROID_HOME=/home/gjones/android-sdk ./gradlew assembleDebug --no-daemon`

### U2. Stabilize Local Build Metadata

- **Goal:** Let the app configure and assemble with the local Android SDK.
- **Files:** `build.gradle`, `app/build.gradle`, `README.md`
- **Patterns:** Preserve compile SDK 22, target SDK 22, Gradle wrapper 2.2.1, and Android Gradle Plugin 1.2.3.
- **Test Scenarios:**
  - `app/build.gradle` pins `buildToolsVersion "24.0.3"`.
  - `build.gradle` uses `https://repo1.maven.org/maven2` and no `jcenter()`.
  - README documents build-tools 24.0.3.
- **Verification:** `scripts/check-baseline.sh`, `ANDROID_HOME=/home/gjones/android-sdk ./gradlew tasks --no-daemon`

### U3. Add Documentation and Source Check

- **Goal:** Provide a repeatable baseline for future maintenance.
- **Files:** `README.md`, `scripts/check-baseline.sh`
- **Patterns:** Short setup, verification, and modernization notes.
- **Test Scenarios:**
  - README lists `scripts/check-baseline.sh`.
  - README lists Gradle task and debug assembly commands.
  - Script fails if URL encoding or build-tools pin is removed.
- **Verification:** `scripts/check-baseline.sh`

---

## Risks & Dependencies

- Runtime behavior still depends on the hosted App Engine endpoint and live image URLs.
- The app remains on deprecated Apache HTTP and AsyncTask APIs; replacing those should be a separate behavior-aware pass.
- Full search UX verification requires a device or emulator with network access.

---

## Sources / Research

- `app/src/main/java/gpj/androidsearch/NetworkRequest.java` contains the backend request URL construction.
- `app/src/main/java/gpj/androidsearch/MainActivity.java` handles Android search intents and response display.
- `app/build.gradle` pins compile SDK 22, target SDK 22, and build-tools 22.0.1.
- `build.gradle` originally used JCenter for plugin and dependency resolution.
- `gradle/wrapper/gradle-wrapper.properties` pins Gradle 2.2.1.
