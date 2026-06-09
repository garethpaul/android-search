#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
NETWORK_REQUEST="$ROOT_DIR/app/src/main/java/gpj/androidsearch/NetworkRequest.java"
MAIN_ACTIVITY="$ROOT_DIR/app/src/main/java/gpj/androidsearch/MainActivity.java"
APP_BUILD="$ROOT_DIR/app/build.gradle"
ROOT_BUILD="$ROOT_DIR/build.gradle"
LAYOUT="$ROOT_DIR/app/src/main/res/layout/activity_main.xml"
README="$ROOT_DIR/README.md"
RESPONSE_PLAN="$ROOT_DIR/docs/plans/2026-06-08-search-response-guard-baseline.md"
IMAGE_DOWNLOAD_PLAN="$ROOT_DIR/docs/plans/2026-06-09-search-image-download-guard.md"
RES_DIR="$ROOT_DIR/app/src/main/res"

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
  "MenuItem searchItem = menu.findItem(R.id.action_search);" \
  "if (searchItem == null)" \
  "SearchView searchView = (SearchView) searchItem.getActionView();" \
  "if (searchManager == null || searchView == null)" \
  "Search UI is unavailable" \
  "if (v != null)" \
  "v.setImageResource(R.drawable.cross);"; do
  if ! grep -Fq "$pattern" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing search menu guard: $pattern" >&2
    exit 1
  fi
done

if ! grep -Fq "if (textImage.length() > 0)" "$MAIN_ACTIVITY"; then
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
  "Log.e(LOG_TAG, \"Unable to download search image\", e);" \
  "Log.e(LOG_TAG, \"Search task failed\", e);"; do
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

if ! grep -Fq "LintError" "$ROOT_DIR/app/lint.xml"; then
  printf '%s\n' "lint.xml must document the obsolete lint API database limitation." >&2
  exit 1
fi

if ! grep -Fq "IconMissingDensityFolder" "$ROOT_DIR/app/lint.xml"; then
  printf '%s\n' "lint.xml must document the nodpi bitmap asset baseline." >&2
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

if ! grep -Fq "make check" "$ROOT_DIR/docs/plans/2026-06-09-search-menu-null-safety.md"; then
  printf '%s\n' "Search menu null-safety plan must document make check verification." >&2
  exit 1
fi

printf '%s\n' "Android search baseline checks passed."
