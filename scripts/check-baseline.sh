#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
NETWORK_REQUEST="$ROOT_DIR/app/src/main/java/gpj/androidsearch/NetworkRequest.java"
MAIN_ACTIVITY="$ROOT_DIR/app/src/main/java/gpj/androidsearch/MainActivity.java"
APP_BUILD="$ROOT_DIR/app/build.gradle"
ROOT_BUILD="$ROOT_DIR/build.gradle"
MANIFEST="$ROOT_DIR/app/src/main/AndroidManifest.xml"
LAYOUT="$ROOT_DIR/app/src/main/res/layout/activity_main.xml"
README="$ROOT_DIR/README.md"
SECURITY="$ROOT_DIR/SECURITY.md"
RESPONSE_PLAN="$ROOT_DIR/docs/plans/2026-06-08-search-response-guard-baseline.md"
IMAGE_DOWNLOAD_PLAN="$ROOT_DIR/docs/plans/2026-06-09-search-image-download-guard.md"
INTENT_UI_PLAN="$ROOT_DIR/docs/plans/2026-06-09-search-intent-ui-guard.md"
SEARCHABLE_INFO_PLAN="$ROOT_DIR/docs/plans/2026-06-09-search-searchable-info-guard.md"
SEARCH_ACTION_VIEW_PLAN="$ROOT_DIR/docs/plans/2026-06-09-search-action-view-type-guard.md"
ANDROID_BACKUP_PLAN="$ROOT_DIR/docs/plans/2026-06-09-android-backup-opt-out.md"
OPTIONS_CALLBACK_PLAN="$ROOT_DIR/docs/plans/2026-06-09-search-options-callback-guard.md"
HTTP_CLIENT_CLEANUP_PLAN="$ROOT_DIR/docs/plans/2026-06-12-search-http-client-cleanup.md"
HOSTED_ANDROID_PLAN="$ROOT_DIR/docs/plans/2026-06-12-hosted-android-verification.md"
CI_PLAN="$ROOT_DIR/docs/plans/2026-06-10-ci-baseline.md"
RES_DIR="$ROOT_DIR/app/src/main/res"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"
CODEOWNERS="$ROOT_DIR/.github/CODEOWNERS"
LINT_CONFIG="$ROOT_DIR/app/lint.xml"
WRAPPER_PLAN="$ROOT_DIR/docs/plans/2026-06-12-gradle-wrapper-verification.md"
GRADLEW="$ROOT_DIR/gradlew"
GRADLEW_BAT="$ROOT_DIR/gradlew.bat"
WRAPPER_JAR="$ROOT_DIR/gradle/wrapper/gradle-wrapper.jar"
WRAPPER_PROPERTIES="$ROOT_DIR/gradle/wrapper/gradle-wrapper.properties"

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    printf '%s\n' "A SHA-256 utility is required for wrapper verification." >&2
    exit 1
  fi
}

expected_wrapper_properties() {
  cat <<'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionSha256Sum=1d7c28b3731906fd1b2955946c1d052303881585fc14baedd675e4cf2bc1ecab
distributionUrl=https\://services.gradle.org/distributions/gradle-2.2.1-all.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF
}

expected_ci_workflow() {
  cat <<'EOF'
name: Check

on:
  push:
    branches:
      - master
  pull_request:
  workflow_dispatch:

permissions:
  contents: read

env:
  FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true

concurrency:
  group: check-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  check:
    runs-on: ubuntu-24.04
    timeout-minutes: 15
    steps:
      - name: Check out repository
        uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10 # v6.0.3
        with:
          persist-credentials: false

      - name: Install Android SDK packages
        run: '"${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-22" "build-tools;24.0.3"'

      - name: Set up Java 8
        uses: actions/setup-java@be666c2fcd27ec809703dec50e508c2fdc7f6654 # v5.2.0
        with:
          distribution: corretto
          java-version: "8"

      - name: Run full verification
        run: make check
EOF
}

if ! grep -Fq "url 'https://repo1.maven.org/maven2'" "$ROOT_BUILD"; then
  printf '%s\n' "Build repositories must use HTTPS Maven Central." >&2
  exit 1
fi

if grep -Fq "jcenter()" "$ROOT_BUILD"; then
  printf '%s\n' "Build repositories must not use JCenter." >&2
  exit 1
fi

if ! grep -Fq 'buildToolsVersion "24.0.3"' "$APP_BUILD"; then
  printf '%s\n' "Android build-tools must stay pinned to 24.0.3 for 64-bit aapt." >&2
  exit 1
fi

for build_contract in \
  "useNewCruncher false" \
  "warningsAsErrors true"; do
  if ! grep -Fq "$build_contract" "$APP_BUILD"; then
    printf '%s\n' "Android build must keep hosted verification contract: $build_contract" >&2
    exit 1
  fi
done

if grep -Fq 'android:allowBackup="true"' "$MANIFEST" ||
  ! grep -Fq 'android:allowBackup="false"' "$MANIFEST"; then
  printf '%s\n' "Android manifest must explicitly disable app-data backup." >&2
  exit 1
fi

if ! grep -Fq 'static final String SEARCH_ENDPOINT = "https://garethpaul-app.appspot.com/api/search?q="' "$NETWORK_REQUEST"; then
  printf '%s\n' "Search endpoint constant is missing or changed." >&2
  exit 1
fi

if ! grep -Fq 'URLEncoder.encode(String.valueOf(query), "UTF-8")' "$NETWORK_REQUEST"; then
  printf '%s\n' "Search query must be URL-encoded with UTF-8." >&2
  exit 1
fi

if grep -Fq '"https://garethpaul-app.appspot.com/api/search?q=" + query' "$NETWORK_REQUEST"; then
  printf '%s\n' "Search request must not concatenate raw query text into the URL." >&2
  exit 1
fi

if grep -Fq "query = params[0];" "$NETWORK_REQUEST"; then
  printf '%s\n' "Search request must not index AsyncTask params without validation." >&2
  exit 1
fi

if ! grep -Fq "private static String queryFromParams(String... params)" "$NETWORK_REQUEST"; then
  printf '%s\n' "Search request must centralize query parameter normalization." >&2
  exit 1
fi

if ! grep -Fq "private static JSONObject errorResult(String message)" "$NETWORK_REQUEST"; then
  printf '%s\n' "Search request must return explicit JSON errors." >&2
  exit 1
fi

HTTP_CLIENT_SCOPE=$(sed -n \
  '/HttpClient httpclient = new DefaultHttpClient(httpParams);/,/} catch (Throwable t)/p' \
  "$NETWORK_REQUEST")
HTTP_CLIENT_FINALLY=$(printf '%s\n' "$HTTP_CLIENT_SCOPE" | sed -n '/} finally {/,/^            }/p')
if [ "$(printf '%s\n' "$HTTP_CLIENT_SCOPE" | grep -Fc "new DefaultHttpClient(httpParams)")" -ne 1 ] || \
   [ "$(printf '%s\n' "$HTTP_CLIENT_SCOPE" | grep -Fc "httpclient.getConnectionManager().shutdown();")" -ne 1 ] || \
   ! printf '%s\n' "$HTTP_CLIENT_FINALLY" | grep -Fq "httpclient.getConnectionManager().shutdown();"; then
  printf '%s\n' "Search HTTP client must shut down exactly once from its finally block." >&2
  exit 1
fi

execute_line=$(printf '%s\n' "$HTTP_CLIENT_SCOPE" | grep -nF "httpclient.execute(" | cut -d: -f1)
finally_line=$(printf '%s\n' "$HTTP_CLIENT_SCOPE" | grep -nF "} finally {" | cut -d: -f1)
shutdown_line=$(printf '%s\n' "$HTTP_CLIENT_SCOPE" | grep -nF "httpclient.getConnectionManager().shutdown();" | cut -d: -f1)
if [ -z "$execute_line" ] || [ -z "$finally_line" ] || [ -z "$shutdown_line" ] || \
   [ "$execute_line" -ge "$finally_line" ] || [ "$finally_line" -ge "$shutdown_line" ]; then
  printf '%s\n' "Search HTTP client cleanup must follow request execution through finally." >&2
  exit 1
fi

if [ ! -f "$HTTP_CLIENT_CLEANUP_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$HTTP_CLIENT_CLEANUP_PLAN" || \
   ! grep -Fq "make check" "$HTTP_CLIENT_CLEANUP_PLAN"; then
  printf '%s\n' "Search HTTP client cleanup plan must record completed make check verification." >&2
  exit 1
fi

if ! grep -Fq 'return errorResult("Search request failed");' "$NETWORK_REQUEST"; then
  printf '%s\n' "Network failures must return an explicit error result." >&2
  exit 1
fi

if ! grep -Fq "HttpConnectionParams.setConnectionTimeout(httpParams," "$NETWORK_REQUEST"; then
  printf '%s\n' "Search request must configure a connection timeout." >&2
  exit 1
fi

if ! grep -Fq "HttpConnectionParams.setSoTimeout(httpParams, 1000)" "$NETWORK_REQUEST"; then
  printf '%s\n' "Search request must configure a socket timeout." >&2
  exit 1
fi

if ! grep -Fq "HttpClient httpclient = new DefaultHttpClient(httpParams);" "$NETWORK_REQUEST"; then
  printf '%s\n' "Configured HTTP parameters must be passed to DefaultHttpClient." >&2
  exit 1
fi

if grep -Fq 'Log.d("url", url)' "$NETWORK_REQUEST"; then
  printf '%s\n' "Search requests must not log full URLs with user queries." >&2
  exit 1
fi

if grep -Fq 'Log.v("network_request", responseBody)' "$NETWORK_REQUEST"; then
  printf '%s\n' "Search requests must not log raw response bodies." >&2
  exit 1
fi

for async_contract in \
  "if (query == null || query.trim().length() == 0)" \
  "activeSearchRequest = new NetworkRequest()" \
  "protected void onPostExecute(JSONObject json)" \
  "if (activeSearchRequest != this || isFinishing() || isDestroyed())" \
  "displaySearchResult(json);" \
  "activeSearchRequest.execute(query.trim());" \
  "private void displaySearchResult(JSONObject json)"; do
  if ! grep -Fq "$async_contract" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing asynchronous search contract: $async_contract" >&2
    exit 1
  fi
done

for ownership_contract in \
  "private NetworkRequest activeSearchRequest;" \
  "private DownloadImageTask activeImageRequest;" \
  "cancelActiveRequests();" \
  "activeSearchRequest.cancel(true);" \
  "activeImageRequest.cancel(true);" \
  "if (activeImageRequest != this || isFinishing() || isDestroyed())" \
  "imageView.setImageDrawable(null);" \
  "protected void onPause()"; do
  if ! grep -Fq "$ownership_contract" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing search result ownership contract: $ownership_contract" >&2
    exit 1
  fi
done

if grep -Fq "request.get()" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Search handling must not block the activity thread on AsyncTask.get()." >&2
  exit 1
fi

if grep -Eq "InterruptedException|ExecutionException" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Search activity must not keep blocking-task exception handling." >&2
  exit 1
fi

if grep -Fq "new DefaultHttpClient(p)" "$NETWORK_REQUEST"; then
  printf '%s\n' "Search request must not pass an unconfigured params object to DefaultHttpClient." >&2
  exit 1
fi

if ! grep -Fq 'json.optString("text"' "$MAIN_ACTIVITY"; then
  printf '%s\n' "Search UI must tolerate missing text fields." >&2
  exit 1
fi

if grep -Fq "getActionBar().set" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Search activity must guard nullable getActionBar() results." >&2
  exit 1
fi

if grep -Fq "menu.findItem(R.id.action_search).getActionView()" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Search menu setup must not chain through nullable search menu items." >&2
  exit 1
fi

for pattern in \
  "private void configureActionBar()" \
  "ActionBar actionBar = getActionBar();" \
  "if (actionBar == null)" \
  "actionBar.setDisplayHomeAsUpEnabled(false);" \
  "actionBar.setDisplayShowHomeEnabled(true);" \
  "actionBar.setIcon(R.drawable.search);"; do
  if ! grep -Fq "$pattern" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing search ActionBar guard: $pattern" >&2
    exit 1
  fi
done

for pattern in \
  "if (menu == null)" \
  "Search options menu is unavailable" \
  "MenuItem searchItem = menu.findItem(R.id.action_search);" \
  "if (searchItem == null)" \
  "if (searchManager == null)" \
  "Search UI is unavailable" \
  "View actionView = searchItem.getActionView();" \
  "if (!(actionView instanceof SearchView))" \
  "Search action view is unavailable" \
  "SearchView searchView = (SearchView) actionView;" \
  "SearchableInfo searchableInfo = searchManager.getSearchableInfo(getComponentName());" \
  "if (searchableInfo == null)" \
  "Searchable configuration is unavailable" \
  "searchView.setSearchableInfo(searchableInfo);" \
  "if (v != null)" \
  "v.setImageResource(R.drawable.cross);"; do
  if ! grep -Fq "$pattern" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing search menu guard: $pattern" >&2
    exit 1
  fi
done

for pattern in \
  "if (intent == null)" \
  "Search intent is unavailable" \
  "if (!Intent.ACTION_SEARCH.equals(intent.getAction()))" \
  "if (textView == null)" \
  "Search result text view is unavailable" \
  "ImageView imageView = (ImageView) findViewById(R.id.imageView);" \
  "if (imageView != null)" \
  "activeImageRequest = new DownloadImageTask(imageView);"; do
  if ! grep -Fq "$pattern" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing search intent/UI guard: $pattern" >&2
    exit 1
  fi
done

for pattern in \
  "if (item == null)" \
  "Search options item is unavailable"; do
  if ! grep -Fq "$pattern" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing search options callback guard: $pattern" >&2
    exit 1
  fi
done

if grep -Fq "if (Intent.ACTION_SEARCH.equals(intent.getAction())) {" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Search intent handling must guard null intents before reading the action." >&2
  exit 1
fi

if grep -Fq "new DownloadImageTask((ImageView) findViewById(R.id.imageView))" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Search image tasks must guard nullable result image views." >&2
  exit 1
fi

if grep -Fq "searchManager.getSearchableInfo(getComponentName()))" "$MAIN_ACTIVITY"; then
  printf '%s\n' "SearchView setup must guard missing searchable configuration." >&2
  exit 1
fi

if grep -Fq "SearchView searchView = (SearchView) searchItem.getActionView();" "$MAIN_ACTIVITY"; then
  printf '%s\n' "SearchView setup must type-check action views before casting." >&2
  exit 1
fi

if ! grep -Fq "if (textImage.length() > 0 && imageView != null)" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Search UI must not download empty image URLs." >&2
  exit 1
fi

for pattern in \
  "private static final int IMAGE_DOWNLOAD_TIMEOUT_MILLIS = 1000" \
  "private static URL httpsImageUrl(String value) throws MalformedURLException" \
  "equalsIgnoreCase(imageUrl.getProtocol())" \
  "URLConnection connection = imageUrl.openConnection();" \
  "connection.setConnectTimeout(IMAGE_DOWNLOAD_TIMEOUT_MILLIS);" \
  "connection.setReadTimeout(IMAGE_DOWNLOAD_TIMEOUT_MILLIS);" \
  "in = connection.getInputStream();" \
  "Log.e(LOG_TAG, \"Unable to download search image\", e);"; do
  if ! grep -Fq "$pattern" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing image download guard: $pattern" >&2
    exit 1
  fi
done

if grep -Fq "new java.net.URL(urldisplay).openStream()" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Search image downloads must not open unvalidated URLs directly." >&2
  exit 1
fi

if grep -Fq "printStackTrace()" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Search activity failures must use sanitized Android logging." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the SDK-free baseline check." >&2
  exit 1
fi

if [ ! -f "$CI_WORKFLOW" ]; then
  printf '%s\n' "GitHub Actions check workflow is missing." >&2
  exit 1
fi

workflow_paths=$(find "$ROOT_DIR/.github/workflows" -type f \( -name '*.yml' -o -name '*.yaml' \) -print)
if [ "$workflow_paths" != "$CI_WORKFLOW" ]; then
  printf '%s\n' "check.yml must remain the only approved GitHub Actions workflow." >&2
  exit 1
fi

if [ "$(cat "$CI_WORKFLOW")" != "$(expected_ci_workflow)" ]; then
  printf '%s\n' "GitHub Actions check workflow must match the approved complete Android security baseline." >&2
  exit 1
fi

if [ ! -f "$HOSTED_ANDROID_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq "make check" "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq "with zero lint issues, both Gradle" "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq "15 focused hostile" "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq 'pull-request run `27402189913`' "$HOSTED_ANDROID_PLAN" || \
   ! grep -Fq '`0a7cec5db4958f134bdd4dda4f256fe381e2e1df`' "$HOSTED_ANDROID_PLAN"; then
  printf '%s\n' "Hosted Android verification plan must record completed local and exact-head hosted evidence." >&2
  exit 1
fi

if [ ! -f "$CI_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$CI_PLAN" || \
   ! grep -Fq 'complete `make check` wrapper' "$CI_PLAN" || \
   ! grep -Fq "Android API 22 and build-tools 24.0.3" "$CI_PLAN"; then
  printf '%s\n' "CI plan must document the complete hosted Android gate." >&2
  exit 1
fi

if ! grep -Fq "GitHub Actions installs Android API 22 and build-tools 24.0.3" "$README" || \
   ! grep -Fq 'complete `make check` gate' "$README" || \
   ! grep -Fq "All other lint warnings fail the build." "$README"; then
  printf '%s\n' "README must document the complete hosted Android and strict lint gates." >&2
  exit 1
fi

if [ ! -f "$CODEOWNERS" ] ||
  [ "$(wc -l < "$CODEOWNERS" | tr -d ' ')" -ne 5 ] ||
  ! grep -Fxq '/.github/CODEOWNERS @garethpaul' "$CODEOWNERS" ||
  ! grep -Fxq '/.github/workflows/ @garethpaul' "$CODEOWNERS" ||
  ! grep -Fxq '/Makefile @garethpaul' "$CODEOWNERS" ||
  ! grep -Fxq '/scripts/check-baseline.sh @garethpaul' "$CODEOWNERS" ||
  ! grep -Fxq '/app/src/main/java/ @garethpaul' "$CODEOWNERS"; then
  printf '%s\n' "CODEOWNERS must protect CI controls and privacy-sensitive application source." >&2
  exit 1
fi

for make_contract in \
  'ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' \
  'ANDROID_SDK := $(if $(ANDROID_HOME),$(ANDROID_HOME),$(ANDROID_SDK_ROOT))'; do
  if ! grep -Fq "$make_contract" "$ROOT_DIR/Makefile"; then
    printf '%s\n' "Makefile must keep contract: $make_contract" >&2
    exit 1
  fi
done

if grep -Fq "/home/gjones" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must not embed a maintainer-specific Android SDK path." >&2
  exit 1
fi

if ! grep -Fq "Search HTTP clients shut down their connection managers" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document search HTTP client cleanup." >&2
  exit 1
fi
if ! grep -Fq "Android build-tools 24.0.3" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the pinned Android build-tools version." >&2
  exit 1
fi

if ! grep -Fq "configured 1-second connection and socket timeouts" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document the configured HTTP timeouts." >&2
  exit 1
fi

if [ ! -f "$ROOT_DIR/CHANGES.md" ]; then
  printf '%s\n' "CHANGES.md is missing." >&2
  exit 1
fi

if [ ! -f "$ROOT_DIR/Makefile" ]; then
  printf '%s\n' "Makefile is missing." >&2
  exit 1
fi

if [ ! -f "$RESPONSE_PLAN" ]; then
  printf '%s\n' "Search response guard plan is missing." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$RESPONSE_PLAN" || ! grep -Fq "make check" "$RESPONSE_PLAN"; then
  printf '%s\n' "Search response guard plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$IMAGE_DOWNLOAD_PLAN" ]; then
  printf '%s\n' "Search image download guard plan is missing." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$IMAGE_DOWNLOAD_PLAN" || ! grep -Fq "make check" "$IMAGE_DOWNLOAD_PLAN"; then
  printf '%s\n' "Search image download guard plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$INTENT_UI_PLAN" ]; then
  printf '%s\n' "Search intent/UI guard plan is missing." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$INTENT_UI_PLAN" || ! grep -Fq "make check" "$INTENT_UI_PLAN"; then
  printf '%s\n' "Search intent/UI guard plan must record completed status and make check verification." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must run the SDK-free baseline check." >&2
  exit 1
fi

if ! grep -Fq "lint:" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose a lint gate." >&2
  exit 1
fi

if ! grep -Fq "test:" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose a test gate." >&2
  exit 1
fi

if ! grep -Fq "build:" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose a build gate." >&2
  exit 1
fi

if ! grep -Fq "verify: lint test build" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile verify must run lint, test, and build gates." >&2
  exit 1
fi

if grep -Fq "hello_world" "$RES_DIR/values/strings.xml" || grep -Fq "action_settings" "$RES_DIR/values/strings.xml"; then
  printf '%s\n' "Unused starter strings must not be restored." >&2
  exit 1
fi

for image in cross search; do
  if [ ! -f "$RES_DIR/drawable-nodpi/$image.png" ]; then
    printf '%s\n' "Search image must stay in drawable-nodpi: $image.png" >&2
    exit 1
  fi
done

if [ -d "$RES_DIR/drawable" ] && find "$RES_DIR/drawable" -name '*.png' | grep -q .; then
  printf '%s\n' "Search PNG assets must not live in density-scaled drawable/." >&2
  exit 1
fi

if grep -Fq 'android:background="#57e2ca"' "$LAYOUT"; then
  printf '%s\n' "Search screen background must live in the theme to avoid layout overdraw." >&2
  exit 1
fi

if ! grep -Fq 'android:contentDescription="@string/search_result_image"' "$LAYOUT"; then
  printf '%s\n' "Search result image must have an accessibility description." >&2
  exit 1
fi

if ! grep -Fq 'android:title="@string/search_hint"' "$RES_DIR/menu/menu_main.xml"; then
  printf '%s\n' "Search action menu item must use a string title." >&2
  exit 1
fi

if ! grep -Fq "LintError" "$LINT_CONFIG"; then
  printf '%s\n' "lint.xml must document the obsolete lint API database limitation." >&2
  exit 1
fi

if ! grep -Fq "IconMissingDensityFolder" "$LINT_CONFIG"; then
  printf '%s\n' "lint.xml must document the nodpi bitmap asset baseline." >&2
  exit 1
fi

if ! grep -Fq "OldTargetApi" "$LINT_CONFIG"; then
  printf '%s\n' "lint.xml must document the deferred target-SDK modernization boundary." >&2
  exit 1
fi

if [ "$(grep -c '<issue id=' "$LINT_CONFIG")" -ne 3 ]; then
  printf '%s\n' "lint.xml must keep exactly the three documented legacy suppressions." >&2
  exit 1
fi

if ! grep -Fq "./gradlew lint --no-daemon" "$README"; then
  printf '%s\n' "README must document Gradle lint verification." >&2
  exit 1
fi

if ! grep -Fq "./gradlew test --no-daemon" "$README"; then
  printf '%s\n' "README must document Gradle test verification." >&2
  exit 1
fi

if ! grep -Fq "./gradlew assembleDebug --no-daemon" "$README"; then
  printf '%s\n' "README must document Gradle build verification." >&2
  exit 1
fi

if ! grep -Fq "make check" "$README"; then
  printf '%s\n' "README must document the make check wrapper." >&2
  exit 1
fi

if ! grep -Fq "Search menu setup guards missing framework search UI pieces" "$README"; then
  printf '%s\n' "README must document search menu null-safety." >&2
  exit 1
fi

if ! grep -Fq "Search intent handling guards null intents and missing result views" "$README"; then
  printf '%s\n' "README must document search intent/UI null-safety." >&2
  exit 1
fi

if ! grep -Fq "Searchable configuration is checked before SearchView wiring" "$README"; then
  printf '%s\n' "README must document searchable configuration null-safety." >&2
  exit 1
fi

if ! grep -Fq "Search action views are type-checked before SearchView casting" "$README"; then
  printf '%s\n' "README must document search action-view type safety." >&2
  exit 1
fi

if ! grep -Fq "Android app-data backup is disabled" "$README"; then
  printf '%s\n' "README must document Android backup opt-out." >&2
  exit 1
fi

if ! grep -Fq "Superseded search and image tasks are cancelled" "$README"; then
  printf '%s\n' "README must document active search result ownership." >&2
  exit 1
fi

if ! grep -Fq "make check" "$ROOT_DIR/docs/plans/2026-06-09-search-menu-null-safety.md"; then
  printf '%s\n' "Search menu null-safety plan must document make check verification." >&2
  exit 1
fi

if ! grep -Fq "make check" "$SEARCHABLE_INFO_PLAN"; then
  printf '%s\n' "Search searchable-info guard plan must document make check verification." >&2
  exit 1
fi

if [ ! -f "$SEARCH_ACTION_VIEW_PLAN" ]; then
  printf '%s\n' "Search action-view type guard plan is missing." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$SEARCH_ACTION_VIEW_PLAN" || ! grep -Fq "make check" "$SEARCH_ACTION_VIEW_PLAN"; then
  printf '%s\n' "Search action-view type guard plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$ANDROID_BACKUP_PLAN" ]; then
  printf '%s\n' "Android backup opt-out plan is missing." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$ANDROID_BACKUP_PLAN" || ! grep -Fq "make check" "$ANDROID_BACKUP_PLAN"; then
  printf '%s\n' "Android backup opt-out plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -f "$OPTIONS_CALLBACK_PLAN" ]; then
  printf '%s\n' "Search options callback guard plan is missing." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$OPTIONS_CALLBACK_PLAN" || ! grep -Fq "make check" "$OPTIONS_CALLBACK_PLAN"; then
  printf '%s\n' "Search options callback guard plan must record completed status and make check verification." >&2
  exit 1
fi

if ! grep -Fq "Status: Completed" "$ROOT_DIR/docs/plans/2026-06-10-search-result-ownership.md" || \
   ! grep -Fq "make check" "$ROOT_DIR/docs/plans/2026-06-10-search-result-ownership.md"; then
  printf '%s\n' "Search result ownership plan must record completed status and make check verification." >&2
  exit 1
fi

if [ ! -x "$GRADLEW" ] || [ ! -f "$GRADLEW_BAT" ] || [ ! -f "$WRAPPER_JAR" ] || [ ! -f "$WRAPPER_PROPERTIES" ]; then
  printf '%s\n' "Generated Gradle wrapper files must be present and gradlew must be executable." >&2
  exit 1
fi
if [ "$(cat "$WRAPPER_PROPERTIES")" != "$(expected_wrapper_properties)" ]; then
  printf '%s\n' "Gradle wrapper properties must retain the reviewed Gradle 2.2.1 URL and checksum." >&2
  exit 1
fi
if [ "$(sha256_file "$WRAPPER_JAR")" != "7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172" ]; then
  printf '%s\n' "Gradle wrapper JAR must match Gradle's published 8.14.5 wrapper checksum." >&2
  exit 1
fi
if [ "$(sha256_file "$GRADLEW")" != "b187b4c52e749f5760afdd6fadc31b2a98ad35fb249bf0dff03b72650f320409" ] || \
   [ "$(sha256_file "$GRADLEW_BAT")" != "94102713eb8fb22d032397924c0f38ab2da783ba60d07054339f1190a0c4e2cd" ]; then
  printf '%s\n' "Gradle wrapper launchers must match the reviewed generated scripts." >&2
  exit 1
fi
if ! grep -Fq "Gradle start up script for POSIX generated by Gradle." "$GRADLEW" || ! grep -Fq "Gradle startup script for Windows" "$GRADLEW_BAT"; then
  printf '%s\n' "Gradle wrapper launchers must retain generated provenance markers." >&2
  exit 1
fi
if [ ! -f "$WRAPPER_PLAN" ] || ! grep -Fq "status: completed" "$WRAPPER_PLAN" || \
   ! grep -Fq "fresh temporary Gradle user home" "$WRAPPER_PLAN" || ! grep -Fq "incorrect checksum was rejected" "$WRAPPER_PLAN" || \
   ! grep -Fq 'SDK-backed `make check` passed' "$WRAPPER_PLAN" || ! grep -Fq "external working directory" "$WRAPPER_PLAN" || \
   ! grep -Fq "hostile mutations rejected" "$WRAPPER_PLAN" || \
   ! grep -Fq 'pull-request `Check` run `27440820729` passed' "$WRAPPER_PLAN" || \
   ! grep -Fq 'CodeQL run `27440818612` passed' "$WRAPPER_PLAN" || \
   ! grep -Fq "a12f99f40ac2361a63dc6090875939fb3450a602" "$WRAPPER_PLAN"; then
  printf '%s\n' "Gradle wrapper plan must record completed local verification evidence." >&2
  exit 1
fi
if ! grep -Fq "distributionSha256Sum" "$README" || ! grep -Fq "uncached build offline-reproducible" "$README" || \
   ! grep -Fq "wrapper JAR and Gradle distribution checksums" "$SECURITY"; then
  printf '%s\n' "Repository docs must describe wrapper verification and its online boundary." >&2
  exit 1
fi

printf '%s\n' "Android search baseline checks passed."
