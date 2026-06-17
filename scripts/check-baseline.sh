#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
NETWORK_REQUEST="$ROOT_DIR/app/src/main/java/gpj/androidsearch/NetworkRequest.java"
MAIN_ACTIVITY="$ROOT_DIR/app/src/main/java/gpj/androidsearch/MainActivity.java"
IMAGE_URL_POLICY="$ROOT_DIR/app/src/main/java/gpj/androidsearch/ImageUrlPolicy.java"
ADDRESS_PINNING_FACTORY="$ROOT_DIR/app/src/main/java/gpj/androidsearch/AddressPinningSSLSocketFactory.java"
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
EXCEPTION_LOG_PLAN="$ROOT_DIR/docs/plans/2026-06-13-search-exception-log-redaction.md"
RUNTIME_EXCEPTION_PLAN="$ROOT_DIR/docs/plans/2026-06-13-search-runtime-exception-boundary.md"
RESPONSE_BODY_LIMIT_PLAN="$ROOT_DIR/docs/plans/2026-06-13-search-response-body-limit.md"
IMAGE_REDIRECT_PLAN="$ROOT_DIR/docs/plans/2026-06-13-search-image-redirect-rejection.md"
IMAGE_BODY_PLAN="$ROOT_DIR/docs/plans/2026-06-13-search-image-body-limit.md"
MEDIA_TYPE_PLAN="$ROOT_DIR/docs/plans/2026-06-14-search-response-media-types.md"
SEARCH_REDIRECT_PLAN="$ROOT_DIR/docs/plans/2026-06-14-search-response-redirect-rejection.md"
JSON_SUCCESS_STATUS_PLAN="$ROOT_DIR/docs/plans/2026-06-14-search-json-success-status.md"
STRICT_UTF8_PLAN="$ROOT_DIR/docs/plans/2026-06-14-search-strict-utf8-decoding.md"
QUERY_LENGTH_PLAN="$ROOT_DIR/docs/plans/2026-06-14-search-query-length.md"
DEVICE_VERIFICATION_PLAN="$ROOT_DIR/docs/plans/2026-06-14-android-search-device-verification-checklist.md"
TRANSPORT_CANCELLATION_PLAN="$ROOT_DIR/docs/plans/2026-06-14-search-active-transport-cancellation.md"
IMAGE_URL_AUTHORITY_PLAN="$ROOT_DIR/docs/plans/2026-06-15-search-image-url-authority.md"
IMAGE_DEFAULT_PORT_PLAN="$ROOT_DIR/docs/plans/2026-06-15-search-image-default-port.md"
IMAGE_LOOPBACK_PLAN="$ROOT_DIR/docs/plans/2026-06-15-search-image-loopback-boundary.md"
IMAGE_PRIVATE_LITERAL_PLAN="$ROOT_DIR/docs/plans/2026-06-15-search-image-private-literal-boundary.md"
IMAGE_SHARED_ADDRESS_PLAN="$ROOT_DIR/docs/plans/2026-06-15-search-image-shared-address-boundary.md"
IMAGE_DNS_PEER_PLAN="$ROOT_DIR/docs/plans/2026-06-16-search-image-dns-peer-binding.md"
IMAGE_SPECIAL_USE_IPV4_PLAN="$ROOT_DIR/docs/plans/2026-06-17-search-image-special-use-ipv4-boundary.md"
RESPONSE_BODY_READER="$ROOT_DIR/app/src/main/java/gpj/androidsearch/BoundedResponseBody.java"
RESPONSE_BODY_TEST="$ROOT_DIR/scripts/test-bounded-response-body.sh"
MEDIA_TYPE_READER="$ROOT_DIR/app/src/main/java/gpj/androidsearch/ResponseMediaType.java"
MEDIA_TYPE_TEST="$ROOT_DIR/scripts/test-response-media-type.sh"
IMAGE_URL_POLICY_TEST="$ROOT_DIR/scripts/test-image-url-policy.sh"
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

for network_failure_log in \
  'Log.e("network_request", "Unable to build error result");' \
  'Log.e("network_request", "Search protocol error");' \
  'Log.e("network_request", "Search IO error");' \
  'Log.e("network_request", "Search response parse error");' \
  'Log.e("network_request", "Unexpected search request error");'; do
  if [ "$(grep -Fc "$network_failure_log" "$NETWORK_REQUEST" || true)" -ne 1 ]; then
    printf '%s\n' "Search network failure log contract changed: $network_failure_log" >&2
    exit 1
  fi
done
for image_failure_log in \
  'Log.e(LOG_TAG, "Unable to download search image");' \
  'Log.e(LOG_TAG, "Unable to close search image stream");'; do
  if [ "$(grep -Fc "$image_failure_log" "$MAIN_ACTIVITY" || true)" -ne 1 ]; then
    printf '%s\n' "Search image failure log contract changed: $image_failure_log" >&2
    exit 1
  fi
done
if [ "$(grep -Fc 'Log.e(' "$NETWORK_REQUEST" || true)" -ne 5 ] || \
   [ "$(grep -Fc 'Log.e(' "$MAIN_ACTIVITY" || true)" -ne 2 ]; then
  printf '%s\n' "Search failure logging must keep exactly seven reviewed error categories." >&2
  exit 1
fi
for sensitive_log_pattern in ", e);" ", t);" "getMessage()" "printStackTrace()" \
  "Log.getStackTraceString" "+ query" "+ url" "+ imageUrl" "+ responseBody" \
  ", query);" ", url);" ", imageUrl);" ", responseBody);"; do
  if grep -Fq "$sensitive_log_pattern" "$NETWORK_REQUEST" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Search logs must not include exception or request-derived details: $sensitive_log_pattern" >&2
    exit 1
  fi
done
if [ ! -f "$EXCEPTION_LOG_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$EXCEPTION_LOG_PLAN" || \
   ! grep -Fq "make check" "$EXCEPTION_LOG_PLAN" || \
   ! grep -Fq "hostile mutations" "$EXCEPTION_LOG_PLAN"; then
  printf '%s\n' "Search exception-log plan must record completed verification." >&2
  exit 1
fi
for exception_log_doc in "$README" "$SECURITY" "$ROOT_DIR/CHANGES.md"; do
  if ! tr '\n' ' ' < "$exception_log_doc" | tr -s '[:space:]' ' ' | \
      grep -Fiq "generic search failure logs"; then
    printf '%s\n' "$exception_log_doc must document generic search failure logs." >&2
    exit 1
  fi
done

HTTP_CLIENT_SCOPE=$(sed -n \
  '/HttpClient httpclient = new DefaultHttpClient(httpParams);/,/} catch (RuntimeException e)/p' \
  "$NETWORK_REQUEST")
if [ "$(printf '%s\n' "$HTTP_CLIENT_SCOPE" | grep -Fc "new DefaultHttpClient(httpParams)")" -ne 1 ] || \
   [ "$(printf '%s\n' "$HTTP_CLIENT_SCOPE" | grep -Fc "httpclient.getConnectionManager().shutdown();")" -ne 1 ]; then
  printf '%s\n' "Search HTTP client must shut down exactly once from its finally block." >&2
  exit 1
fi

if [ "$(grep -Fc 'import org.apache.http.client.params.HttpClientParams;' "$NETWORK_REQUEST")" -ne 1 ] || \
   [ "$(grep -Fc 'HttpClientParams.setRedirecting(httpParams, false);' "$NETWORK_REQUEST")" -ne 1 ]; then
  printf '%s\n' "Search requests must disable Apache HttpClient redirects exactly once." >&2
  exit 1
fi

redirect_line=$(grep -nF 'HttpClientParams.setRedirecting(httpParams, false);' "$NETWORK_REQUEST" | cut -d: -f1)
client_line=$(grep -nF 'HttpClient httpclient = new DefaultHttpClient(httpParams);' "$NETWORK_REQUEST" | cut -d: -f1)
execute_source_line=$(grep -nF 'String responseBody = httpclient.execute(httpget,' "$NETWORK_REQUEST" | cut -d: -f1)
if [ -z "$redirect_line" ] || [ -z "$client_line" ] || [ -z "$execute_source_line" ] || \
   [ "$redirect_line" -ge "$client_line" ] || [ "$client_line" -ge "$execute_source_line" ]; then
  printf '%s\n' "Search redirects must be disabled before client construction and execution." >&2
  exit 1
fi

if [ ! -f "$SEARCH_REDIRECT_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$SEARCH_REDIRECT_PLAN" || \
   ! grep -Fq "make check" "$SEARCH_REDIRECT_PLAN" || \
   ! grep -Fq "hostile mutations" "$SEARCH_REDIRECT_PLAN"; then
  printf '%s\n' "Search redirect plan must record completed verification." >&2
  exit 1
fi

execute_line=$(printf '%s\n' "$HTTP_CLIENT_SCOPE" | grep -nF "httpclient.execute(" | cut -d: -f1)
finally_line=$(printf '%s\n' "$HTTP_CLIENT_SCOPE" | grep -nF "} finally {" | tail -1 | cut -d: -f1)
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

REQUEST_TASK_SCOPE=$(sed -n \
  '/protected JSONObject doInBackground(String\.\.\. params)/,/protected void onPostExecute(JSONObject feed)/p' \
  "$NETWORK_REQUEST")
if [ "$(printf '%s\n' "$REQUEST_TASK_SCOPE" | grep -Fc '} catch (RuntimeException e) {')" -ne 1 ] || \
   [ "$(printf '%s\n' "$REQUEST_TASK_SCOPE" | grep -Fc 'Log.e("network_request", "Unexpected search request error");')" -ne 1 ] || \
   [ "$(printf '%s\n' "$REQUEST_TASK_SCOPE" | grep -Fc 'return errorResult("Search request failed");')" -ne 4 ]; then
  printf '%s\n' "Search request task must keep its reviewed RuntimeException fallback." >&2
  exit 1
fi
if printf '%s\n' "$REQUEST_TASK_SCOPE" | \
    grep -Eq 'catch \((Throwable|[[:alnum:]_.$]*Error)([[:space:]]|\))'; then
  printf '%s\n' "Search request task must not catch Throwable or an Error class." >&2
  exit 1
fi
if [ ! -f "$RUNTIME_EXCEPTION_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$RUNTIME_EXCEPTION_PLAN" || \
   ! grep -Fq "make check" "$RUNTIME_EXCEPTION_PLAN" || \
   ! grep -Fq "hostile mutations" "$RUNTIME_EXCEPTION_PLAN"; then
  printf '%s\n' "Search runtime-exception plan must record completed verification." >&2
  exit 1
fi
for runtime_exception_doc in "$ROOT_DIR/AGENTS.md" "$README" "$SECURITY" \
  "$ROOT_DIR/VISION.md" "$ROOT_DIR/CHANGES.md"; do
  if ! tr '\n' ' ' < "$runtime_exception_doc" | tr -s '[:space:]' ' ' | \
      grep -Fiq "fatal JVM errors"; then
    printf '%s\n' "$runtime_exception_doc must document propagation of fatal JVM errors." >&2
    exit 1
  fi
done

for response_body_contract in \
  'private static final int MAX_RESPONSE_BODY_BYTES = 64 * 1024;' \
  'private static ResponseHandler<String> boundedResponseHandler()' \
  'int statusCode = statusLine.getStatusCode();' \
  'if (statusCode < 200 || statusCode >= 300)' \
  'BoundedResponseBody.read(content,' \
  'entity.getContentLength(), MAX_RESPONSE_BODY_BYTES);' \
  'ResponseHandler<String> responseHandler = boundedResponseHandler();'; do
  if ! grep -Fq "$response_body_contract" "$NETWORK_REQUEST"; then
    printf '%s\n' "Search response-body limit integration changed: $response_body_contract" >&2
    exit 1
  fi
done

status_line=$(grep -nF 'int statusCode = statusLine.getStatusCode();' "$NETWORK_REQUEST" | head -1 | cut -d: -f1)
success_guard_line=$(grep -nF 'if (statusCode < 200 || statusCode >= 300)' "$NETWORK_REQUEST" | head -1 | cut -d: -f1)
entity_line=$(grep -nF 'HttpEntity entity = response.getEntity();' "$NETWORK_REQUEST" | head -1 | cut -d: -f1)
if [ -z "$status_line" ] || [ -z "$success_guard_line" ] || [ -z "$entity_line" ] || \
   [ "$status_line" -ge "$success_guard_line" ] || [ "$success_guard_line" -ge "$entity_line" ]; then
  printf '%s\n' "Search JSON must require a 2xx status before response entity access." >&2
  exit 1
fi

for json_success_status_document in "$README" "$SECURITY" "$ROOT_DIR/VISION.md" "$ROOT_DIR/CHANGES.md"; do
  if ! grep -Fq "JSON responses require successful 2xx status" "$json_success_status_document"; then
    printf '%s\n' "$json_success_status_document must document the JSON success-status boundary." >&2
    exit 1
  fi
done

for json_success_status_plan_contract in "Status: Completed" "make check" "mutations"; do
  if ! grep -Fqi "$json_success_status_plan_contract" "$JSON_SUCCESS_STATUS_PLAN"; then
    printf '%s\n' "JSON success-status plan must preserve completion evidence: $json_success_status_plan_contract" >&2
    exit 1
  fi
done
if grep -Fq "BasicResponseHandler" "$NETWORK_REQUEST"; then
  printf '%s\n' "Search responses must not use the unbounded BasicResponseHandler." >&2
  exit 1
fi

RESPONSE_HANDLER_SCOPE=$(sed -n \
  '/private static ResponseHandler<String> boundedResponseHandler()/,/^    }/p' \
  "$NETWORK_REQUEST")
RESPONSE_HANDLER_COMPACT=$(printf '%s\n' "$RESPONSE_HANDLER_SCOPE" | tr -d '[:space:]')
if ! printf '%s\n' "$RESPONSE_HANDLER_COMPACT" | grep -Fq \
    'HeadercontentType=entity.getContentType();if(contentType==null||!ResponseMediaType.isJson(contentType.getValue())){thrownewClientProtocolException("SearchresponsemediatypeisnotJSON");}InputStreamcontent=entity.getContent();'; then
  printf '%s\n' "Search JSON media type must be validated before response stream acquisition." >&2
  exit 1
fi
if ! printf '%s\n' "$RESPONSE_HANDLER_COMPACT" | grep -Fq \
    'try{returnBoundedResponseBody.read(content,entity.getContentLength(),MAX_RESPONSE_BODY_BYTES);}finally{content.close();}'; then
  printf '%s\n' "Search response streams must close after bounded reads on success and failure." >&2
  exit 1
fi

for response_reader_contract in \
  'if (contentLength > maxBytes)' \
  'int remaining = maxBytes - total;' \
  'int requested = (int) Math.min(buffer.length, (long) remaining + 1L);' \
  'if (count > remaining)' \
  'Charset.forName("UTF-8").newDecoder()' \
  '.onMalformedInput(CodingErrorAction.REPORT)' \
  '.onUnmappableCharacter(CodingErrorAction.REPORT)' \
  '.decode(ByteBuffer.wrap(body))' \
  'return output.toByteArray();'; do
  if ! grep -Fq "$response_reader_contract" "$RESPONSE_BODY_READER"; then
    printf '%s\n' "Bounded response reader contract changed: $response_reader_contract" >&2
    exit 1
  fi
done
if [ ! -x "$RESPONSE_BODY_TEST" ] || \
   ! grep -Fq 'LIMIT + 1' "$RESPONSE_BODY_TEST" || \
   ! grep -Fq 'assertEquals(LIMIT, read(new byte[LIMIT], LIMIT, LIMIT).length());' "$RESPONSE_BODY_TEST" || \
   ! grep -Fq 'assertEquals(LIMIT + 1, streamedOversize.bytesRead);' "$RESPONSE_BODY_TEST" || \
   ! grep -Fq 'expectMalformedUtf8(new byte[] {(byte) 0xc3, 0x28});' "$RESPONSE_BODY_TEST" || \
   ! grep -Fq 'malformed UTF-8 response was accepted' "$RESPONSE_BODY_TEST"; then
  printf '%s\n' "Bounded response reader tests must cover exact and streaming overflow boundaries." >&2
  exit 1
fi
if grep -Fq 'new String(body, "UTF-8")' "$RESPONSE_BODY_READER"; then
  printf '%s\n' "Search JSON decoding must not replace malformed UTF-8." >&2
  exit 1
fi
if [ ! -f "$STRICT_UTF8_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$STRICT_UTF8_PLAN" || \
   ! grep -Fq "make check" "$STRICT_UTF8_PLAN" || \
   ! grep -Fq "mutations" "$STRICT_UTF8_PLAN"; then
  printf '%s\n' "Search strict UTF-8 plan must record completed verification." >&2
  exit 1
fi
for strict_utf8_doc in "$ROOT_DIR/AGENTS.md" "$README" "$SECURITY" \
  "$ROOT_DIR/VISION.md" "$ROOT_DIR/CHANGES.md"; do
  if ! grep -Fiq "reject malformed UTF-8 search JSON" "$strict_utf8_doc"; then
    printf '%s\n' "$strict_utf8_doc must document strict search JSON decoding." >&2
    exit 1
  fi
done
if ! grep -Fq '$(ROOT)scripts/test-bounded-response-body.sh' "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Canonical tests must execute the bounded response reader harness." >&2
  exit 1
fi
if [ ! -f "$RESPONSE_BODY_LIMIT_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$RESPONSE_BODY_LIMIT_PLAN" || \
   ! grep -Fq "Verification: Completed" "$RESPONSE_BODY_LIMIT_PLAN" || \
   ! grep -Fq "Ten focused hostile mutations" "$RESPONSE_BODY_LIMIT_PLAN" || \
   ! grep -Fq "make check" "$RESPONSE_BODY_LIMIT_PLAN"; then
  printf '%s\n' "Search response-body limit plan must record completed verification." >&2
  exit 1
fi
for response_body_doc in "$ROOT_DIR/AGENTS.md" "$README" "$SECURITY" \
  "$ROOT_DIR/VISION.md" "$ROOT_DIR/CHANGES.md"; do
  if ! tr '\n' ' ' < "$response_body_doc" | tr -s '[:space:]' ' ' | \
      grep -Fiq "64 KiB response-body limit"; then
    printf '%s\n' "$response_body_doc must document the 64 KiB response-body limit." >&2
    exit 1
  fi
done

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
  'MAX_SEARCH_QUERY_CHARACTERS = 200' \
  'String normalizedQuery = query == null ? "" : query.trim();' \
  'normalizedQuery.length() > MAX_SEARCH_QUERY_CHARACTERS' \
  "activeSearchRequest = new NetworkRequest()" \
  "protected void onPostExecute(JSONObject json)" \
  "if (activeSearchRequest != this || isFinishing() || isDestroyed())" \
  "displaySearchResult(json);" \
  "activeSearchRequest.execute(normalizedQuery);" \
  "private void displaySearchResult(JSONObject json)"; do
  if ! grep -Fq "$async_contract" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing asynchronous search contract: $async_contract" >&2
    exit 1
  fi
done

for query_length_doc in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "Search intents are trimmed and limited to 200 characters before URL encoding." "$ROOT_DIR/$query_length_doc"; then
    printf '%s\n' "$query_length_doc must document the search query-length boundary." >&2
    exit 1
  fi
done
for query_length_plan_contract in "Status: Completed" "make check" "hostile mutations"; do
  if ! grep -Fq "$query_length_plan_contract" "$QUERY_LENGTH_PLAN"; then
    printf '%s\n' "Search query-length plan must record completed verification: $query_length_plan_contract" >&2
    exit 1
  fi
done

for required_device_path in "$ROOT_DIR/DEVICE_VERIFICATION.md" "$DEVICE_VERIFICATION_PLAN"; do
  if [ ! -f "$required_device_path" ]; then
    printf '%s\n' "Required Android Search device verification file is missing: ${required_device_path#"$ROOT_DIR/"}" >&2
    exit 1
  fi
done

for device_contract in \
  'commit SHA and pull request' \
  'synthetic query' \
  'Valid search' \
  'Overlength query' \
  'Rapid repeated searches' \
  'Cancel active search' \
  'Offline request' \
  'Redirected JSON' \
  'Malformed UTF-8' \
  'Oversized JSON' \
  'Image redirect' \
  'Oversized image' \
  'Rotation during search' \
  'Do not convert `not run` into passing evidence.' \
  'device identifiers, response bodies, account names' \
  'every Android, backend, network, and UI row as unexecuted'; do
  if ! grep -Fq "$device_contract" "$ROOT_DIR/DEVICE_VERIFICATION.md"; then
    printf '%s\n' "Android Search device checklist must keep contract: $device_contract" >&2
    exit 1
  fi
done

if ! grep -Fq 'DEVICE_VERIFICATION.md' "$README" || \
   ! grep -Fq 'explicit unexecuted rows' "$README" || \
   ! grep -Fq 'Android Search device verification matrix' "$ROOT_DIR/VISION.md" || \
   ! grep -Fq 'every runtime row explicitly unexecuted' "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' 'Repository guidance must document the unexecuted Android Search device matrix.' >&2
  exit 1
fi

for device_plan_contract in \
  'Status: Completed' \
  'make check' \
  'hostile mutations' \
  'No Android SDK, emulator, backend fixture, controlled network, physical device, or live UI scenario was executed'; do
  if ! grep -Fq "$device_plan_contract" "$DEVICE_VERIFICATION_PLAN"; then
    printf '%s\n' "Android Search device plan must keep completion evidence: $device_plan_contract" >&2
    exit 1
  fi
done

for ownership_contract in \
  "private NetworkRequest activeSearchRequest;" \
  "private DownloadImageTask activeImageRequest;" \
  "cancelActiveRequests();" \
  "activeSearchRequest.cancelRequest();" \
  "activeImageRequest.cancelDownload();" \
  "if (activeImageRequest != this || isFinishing() || isDestroyed())" \
  "imageView.setImageDrawable(null);" \
  "protected void onPause()"; do
  if ! grep -Fq "$ownership_contract" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing search result ownership contract: $ownership_contract" >&2
    exit 1
  fi
done

for search_transport_cancellation_contract in \
  "private volatile HttpGet activeHttpGet;" \
  "public void cancelRequest()" \
  "request.abort();" \
  "cancel(true);" \
  "HttpGet publishedAfterCancellation = activeHttpGet;" \
  "activeHttpGet = httpget;" \
  "if (isCancelled())" \
  "if (activeHttpGet == httpget)"; do
  if ! grep -Fq "$search_transport_cancellation_contract" "$NETWORK_REQUEST"; then
    printf '%s\n' "Search request must keep active transport cancellation contract: $search_transport_cancellation_contract" >&2
    exit 1
  fi
done
for image_transport_cancellation_contract in \
  "private volatile HttpsURLConnection activeConnection;" \
  "void cancelDownload()" \
  "connection.disconnect();" \
  "HttpsURLConnection publishedAfterCancellation = activeConnection;" \
  "activeConnection = connection;" \
  "if (activeConnection == connection)"; do
  if ! grep -Fq "$image_transport_cancellation_contract" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Image request must keep active transport cancellation contract: $image_transport_cancellation_contract" >&2
    exit 1
  fi
done
SEARCH_CANCEL_SCOPE=$(sed -n \
  '/public void cancelRequest()/,/static String buildSearchUrl/p' \
  "$NETWORK_REQUEST" | tr -d '[:space:]')
if ! printf '%s\n' "$SEARCH_CANCEL_SCOPE" | grep -Fq \
    'HttpGetrequest=activeHttpGet;if(request!=null){request.abort();}cancel(true);HttpGetpublishedAfterCancellation=activeHttpGet;if(publishedAfterCancellation!=null&&publishedAfterCancellation!=request){publishedAfterCancellation.abort();}'; then
  printf '%s\n' "Search cancellation must abort owned and late-published requests around task cancellation." >&2
  exit 1
fi
IMAGE_CANCEL_SCOPE=$(sed -n \
  '/void cancelDownload()/,/protected void onPostExecute/p' \
  "$MAIN_ACTIVITY" | tr -d '[:space:]')
if ! printf '%s\n' "$IMAGE_CANCEL_SCOPE" | grep -Fq \
    'HttpsURLConnectionconnection=activeConnection;if(connection!=null){connection.disconnect();}cancel(true);HttpsURLConnectionpublishedAfterCancellation=activeConnection;if(publishedAfterCancellation!=null&&publishedAfterCancellation!=connection){publishedAfterCancellation.disconnect();}'; then
  printf '%s\n' "Image cancellation must disconnect owned and late-published transports around task cancellation." >&2
  exit 1
fi
search_abort_line=$(grep -nF 'request.abort();' "$NETWORK_REQUEST" | head -1 | cut -d: -f1)
search_cancel_line=$(grep -nF 'cancel(true);' "$NETWORK_REQUEST" | head -1 | cut -d: -f1)
image_disconnect_line=$(grep -nF 'connection.disconnect();' "$MAIN_ACTIVITY" | tail -2 | head -1 | cut -d: -f1)
image_cancel_line=$(grep -nF 'cancel(true);' "$MAIN_ACTIVITY" | head -1 | cut -d: -f1)
if [ -z "$search_abort_line" ] || [ -z "$search_cancel_line" ] || \
   [ "$search_abort_line" -ge "$search_cancel_line" ] || \
   [ -z "$image_disconnect_line" ] || [ -z "$image_cancel_line" ] || \
   [ "$image_disconnect_line" -ge "$image_cancel_line" ]; then
  printf '%s\n' "Active transports must close before AsyncTask cancellation." >&2
  exit 1
fi
for transport_cancellation_doc in "$README" "$SECURITY" "$ROOT_DIR/VISION.md" "$ROOT_DIR/CHANGES.md"; do
  if ! tr '\n' ' ' < "$transport_cancellation_doc" | tr -s '[:space:]' ' ' | \
      grep -Eiq 'abort(s| their)? (the )?active JSON|abort active JSON'; then
    printf '%s\n' "$transport_cancellation_doc must document active search transport cancellation." >&2
    exit 1
  fi
done
for transport_cancellation_plan_contract in "Status: Completed" "make check" "mutations"; do
  if ! grep -Fqi "$transport_cancellation_plan_contract" "$TRANSPORT_CANCELLATION_PLAN"; then
    printf '%s\n' "Active transport cancellation plan must record completed evidence: $transport_cancellation_plan_contract" >&2
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
  "ImageUrlPolicy.requireHttpsAuthority(urls[0].trim())" \
  "HttpsURLConnection connection = null;" \
  "connection = (HttpsURLConnection) imageUrl.openConnection(Proxy.NO_PROXY);" \
  "connection.setInstanceFollowRedirects(false);" \
  "connection.setConnectTimeout(IMAGE_DOWNLOAD_TIMEOUT_MILLIS);" \
  "connection.setReadTimeout(IMAGE_DOWNLOAD_TIMEOUT_MILLIS);" \
  "int responseCode = connection.getResponseCode();" \
  "if (responseCode < 200 || responseCode >= 300)" \
  "in = connection.getInputStream();" \
  "connection.disconnect();" \
  "Log.e(LOG_TAG, \"Unable to download search image\");"; do
  if ! grep -Fq "$pattern" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing image download guard: $pattern" >&2
    exit 1
  fi
done

for image_url_contract in \
  'static URL requireHttpsAuthority(String value) throws MalformedURLException' \
  '!"https".equalsIgnoreCase(imageUrl.getProtocol())' \
  'imageUrl.getHost() == null || imageUrl.getHost().length() == 0' \
  'imageUrl.getUserInfo() != null' \
  'imageUrl.getPort() != -1 && imageUrl.getPort() != 443' \
  'isLoopbackHost(imageUrl.getHost())' \
  'normalizedHost.endsWith(".localhost")' \
  'InetAddress.getByName(address).isLoopbackAddress()' \
  'parseIpv4Literal(normalizedHost)' \
  '(ipv4Address & 0xff000000L) == 0x7f000000L'; do
  if ! grep -Fq "$image_url_contract" "$IMAGE_URL_POLICY"; then
    printf '%s\n' "Missing image URL authority contract: $image_url_contract" >&2
    exit 1
  fi
done
if ! grep -Fq 'HTTPS://images.example.test:443/photo.png#preview' "$IMAGE_URL_POLICY_TEST" || \
   ! grep -Fq 'https://images.example.test:1/photo.png' "$IMAGE_URL_POLICY_TEST" || \
   ! grep -Fq 'https://images.example.test:80/photo.png' "$IMAGE_URL_POLICY_TEST" || \
   ! grep -Fq 'https://images.example.test:444/photo.png' "$IMAGE_URL_POLICY_TEST" || \
   ! grep -Fq 'https://images.example.test:8443/photo.png' "$IMAGE_URL_POLICY_TEST"; then
  printf '%s\n' "Search image URL policy port tests are incomplete." >&2
  exit 1
fi
for loopback_fixture in \
  'https://localhost/photo.png' \
  'https://LOCALHOST./photo.png' \
  'https://images.localhost/photo.png' \
  'https://127.0.0.1/photo.png' \
  'https://127.255.255.254/photo.png' \
  'https://127.1/photo.png' \
  'https://2130706433/photo.png' \
  'https://0177.0.0.1/photo.png' \
  'https://0x7f.0.0.1/photo.png' \
  'https://017700000001/photo.png' \
  'https://0x7f000001/photo.png' \
  'https://[::1]/photo.png' \
  'https://[0:0:0:0:0:0:0:1]/photo.png' \
  'https://[::ffff:127.0.0.1]/photo.png' \
  'https://[0:0:0:0:0:ffff:7f00:1]/photo.png' \
  'https://127.example.test/photo.png' \
  'https://images.localhost.example/photo.png' \
  'https://128.1/photo.png' \
  'https://2147483649/photo.png'; do
  if ! grep -Fq "$loopback_fixture" "$IMAGE_URL_POLICY_TEST"; then
    printf '%s\n' "Search image URL loopback fixture is missing: $loopback_fixture" >&2
    exit 1
  fi
done
if [ ! -x "$IMAGE_URL_POLICY_TEST" ] || \
   ! grep -Fq 'https:/photo.png' "$IMAGE_URL_POLICY_TEST" || \
   ! grep -Fq 'https://user@example.test/photo.png' "$IMAGE_URL_POLICY_TEST" || \
   ! grep -Fq 'https://user:password@example.test/photo.png' "$IMAGE_URL_POLICY_TEST" || \
   ! grep -Fq 'token=a%2Bb&expires=1' "$IMAGE_URL_POLICY_TEST"; then
  printf '%s\n' "Search image URL policy host tests are incomplete." >&2
  exit 1
fi
for image_url_plan_contract in "Status: Completed" "make check" "hostile mutations"; do
  if ! grep -Fq "$image_url_plan_contract" "$IMAGE_URL_AUTHORITY_PLAN"; then
    printf '%s\n' "Search image URL authority plan must record completed verification: $image_url_plan_contract" >&2
    exit 1
  fi
done
for image_port_plan_contract in "Status: Completed" "make check" "hostile mutations"; do
  if ! grep -Fq "$image_port_plan_contract" "$IMAGE_DEFAULT_PORT_PLAN"; then
    printf '%s\n' "Search image default-port plan must record completed verification: $image_port_plan_contract" >&2
    exit 1
  fi
done
for image_loopback_plan_contract in \
  "Status: Completed" \
  "isLoopbackHost" \
  "make check" \
  "hostile mutations"; do
  if ! grep -Fq "$image_loopback_plan_contract" "$IMAGE_LOOPBACK_PLAN"; then
    printf '%s\n' "Search image loopback plan must record completed verification: $image_loopback_plan_contract" >&2
    exit 1
  fi
done
for image_loopback_doc in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "Backend-provided image URLs cannot explicitly target loopback hosts before connection setup." "$ROOT_DIR/$image_loopback_doc"; then
    printf '%s\n' "$image_loopback_doc must document image URL loopback validation." >&2
    exit 1
  fi
done
for image_private_contract in \
  'isPrivateAddressLiteral(imageUrl.getHost())' \
  '(address & 0xff000000L) == 0x0a000000L' \
  '(address & 0xffc00000L) == 0x64400000L' \
  '(address & 0xffff0000L) == 0xa9fe0000L' \
  '(address & 0xfff00000L) == 0xac100000L' \
  '(address & 0xffff0000L) == 0xc0a80000L' \
  '(addressBytes[0] & 0xfe) == 0xfc' \
  'address.isLinkLocalAddress()' \
  'address.isAnyLocalAddress()'; do
  if ! grep -Fq "$image_private_contract" "$IMAGE_URL_POLICY"; then
    printf '%s\n' "Missing image private-literal contract: $image_private_contract" >&2
    exit 1
  fi
done
for image_private_fixture in \
  'https://10.0.0.1/photo.png' \
  'https://167772161/photo.png' \
  'https://169.254.1.1/photo.png' \
  'https://172.16.0.1/photo.png' \
  'https://192.168.1.1/photo.png' \
  'https://[::]/photo.png' \
  'https://[fc00::1]/photo.png' \
  'https://[fe80::1]/photo.png' \
  'https://[::ffff:10.0.0.1]/photo.png' \
  'https://8.8.8.8/photo.png' \
  'https://172.15.255.255/photo.png' \
  'https://172.32.0.0/photo.png' \
  'https://[2001:4860:4860::8888]/photo.png'; do
  if ! grep -Fq "$image_private_fixture" "$IMAGE_URL_POLICY_TEST"; then
    printf '%s\n' "Search image private-literal fixture is missing: $image_private_fixture" >&2
    exit 1
  fi
done
for image_shared_fixture in \
  'https://100.63.255.255/photo.png' \
  'https://100.128.0.0/photo.png' \
  'https://100.64.0.0/photo.png' \
  'https://100.127.255.255/photo.png' \
  'https://100.64.1/photo.png' \
  'https://1681915905/photo.png' \
  'https://0x64400001/photo.png' \
  'https://014420000001/photo.png'; do
  if ! grep -Fq "$image_shared_fixture" "$IMAGE_URL_POLICY_TEST"; then
    printf '%s\n' "Search image shared-address fixture is missing: $image_shared_fixture" >&2
    exit 1
  fi
done
for image_shared_plan_contract in \
  "Status: Completed" \
  "100.64.0.0/10" \
  "make check" \
  "mutations"; do
  if ! grep -Fq "$image_shared_plan_contract" "$IMAGE_SHARED_ADDRESS_PLAN"; then
    printf '%s\n' "Search image shared-address plan must record completed verification: $image_shared_plan_contract" >&2
    exit 1
  fi
done
for image_shared_doc in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "Backend-provided image URLs cannot explicitly target IPv4 shared address space before connection setup." "$ROOT_DIR/$image_shared_doc"; then
    printf '%s\n' "$image_shared_doc must document image URL shared-address validation." >&2
    exit 1
  fi
done
for image_special_use_contract in \
  'isProhibitedIpv4Address' \
  '(address & 0xffffff00L) == 0xc0000200L' \
  '(address & 0xffffff00L) == 0xc0586300L' \
  '(address & 0xfffe0000L) == 0xc6120000L' \
  '(address & 0xffffff00L) == 0xc6336400L' \
  '(address & 0xffffff00L) == 0xcb007100L' \
  '(address & 0xf0000000L) == 0xf0000000L' \
  '(address & 0xffffff00L) == 0xc0000000L' \
  'address != 0xc0000009L' \
  'address != 0xc000000aL'; do
  if ! grep -Fq "$image_special_use_contract" "$IMAGE_URL_POLICY"; then
    printf '%s\n' "Missing image special-use IPv4 contract: $image_special_use_contract" >&2
    exit 1
  fi
done
for image_special_use_fixture in \
  'https://192.0.0.9/photo.png' \
  'https://192.0.0.10/photo.png' \
  'https://192.0.0.11/photo.png' \
  'https://192.0.2.0/photo.png' \
  'https://192.88.99.255/photo.png' \
  'https://198.18.0.0/photo.png' \
  'https://198.19.255.255/photo.png' \
  'https://198.51.100.255/photo.png' \
  'https://203.0.113.255/photo.png' \
  'https://240.0.0.0/photo.png' \
  'https://255.255.255.255/photo.png' \
  'address(192, 0, 2, 1)' \
  'address(198, 18, 0, 1)' \
  'specialUseFactory'; do
  if ! grep -Fq "$image_special_use_fixture" "$IMAGE_URL_POLICY_TEST"; then
    printf '%s\n' "Search image special-use IPv4 fixture is missing: $image_special_use_fixture" >&2
    exit 1
  fi
done
for image_special_use_plan_contract in \
  'status: completed' \
  '192.0.0.0/24' \
  '198.18.0.0/15' \
  'make check' \
  'mutations' \
  '## Verification Results'; do
  if ! grep -Fq "$image_special_use_plan_contract" "$IMAGE_SPECIAL_USE_IPV4_PLAN"; then
    printf '%s\n' "Search image special-use IPv4 plan must record completed verification: $image_special_use_plan_contract" >&2
    exit 1
  fi
done
for image_special_use_doc in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "Backend-provided image URLs cannot target IANA special-use IPv4 protocol-assignment, documentation, deprecated relay, benchmarking, or reserved ranges." "$ROOT_DIR/$image_special_use_doc"; then
    printf '%s\n' "$image_special_use_doc must document image special-use IPv4 validation." >&2
    exit 1
  fi
done
for image_private_plan_contract in \
  "Status: Completed" \
  "isPrivateAddressLiteral" \
  "make check" \
  "hostile mutations"; do
  if ! grep -Fq "$image_private_plan_contract" "$IMAGE_PRIVATE_LITERAL_PLAN"; then
    printf '%s\n' "Search image private-literal plan must record completed verification: $image_private_plan_contract" >&2
    exit 1
  fi
done
for image_private_doc in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "Backend-provided image URLs cannot explicitly target private, link-local, or unspecified IP literals before connection setup." "$ROOT_DIR/$image_private_doc"; then
    printf '%s\n' "$image_private_doc must document image URL private-literal validation." >&2
    exit 1
  fi
done
for image_dns_contract in \
  'interface AddressResolver' \
  'InetAddress.getAllByName(host)' \
  'resolvedAddresses == null || resolvedAddresses.length == 0' \
  'if (isProhibitedAddress(address))' \
  'return authorizedAddresses.clone()' \
  'address.isLoopbackAddress()' \
  'address.isMulticastAddress()'; do
  if ! grep -Fq "$image_dns_contract" "$IMAGE_URL_POLICY"; then
    printf '%s\n' "Missing image DNS authorization contract: $image_dns_contract" >&2
    exit 1
  fi
done
for image_peer_contract in \
  'extends SSLSocketFactory' \
  'socket.getInetAddress()' \
  'ImageUrlPolicy.isProhibitedAddress(peerAddress)' \
  '!isAuthorized(peerAddress)' \
  'socket.getPort() != port' \
  'closeQuietly(socket);' \
  'delegate.createSocket(socket, hostname, port, autoClose)'; do
  if ! grep -Fq "$image_peer_contract" "$ADDRESS_PINNING_FACTORY"; then
    printf '%s\n' "Missing image connected-peer contract: $image_peer_contract" >&2
    exit 1
  fi
done
if [ "$(grep -Fc 'throw unsupportedPath();' "$ADDRESS_PINNING_FACTORY" || true)" -ne 5 ]; then
  printf '%s\n' "Search image TLS factory must fail closed on all alternate socket paths." >&2
  exit 1
fi
for image_transport_contract in \
  'ImageUrlPolicy.requirePublicAddresses(imageUrl.getHost())' \
  'connection.setSSLSocketFactory(new AddressPinningSSLSocketFactory(' \
  'connection.getSSLSocketFactory()' \
  'imageUrl.getHost()' \
  'authorizedAddresses));'; do
  if ! grep -Fq "$image_transport_contract" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing image DNS peer transport integration: $image_transport_contract" >&2
    exit 1
  fi
done
image_resolve_line=$(grep -nF 'ImageUrlPolicy.requirePublicAddresses(imageUrl.getHost())' "$MAIN_ACTIVITY" | cut -d: -f1)
image_open_line=$(grep -nF 'connection = (HttpsURLConnection) imageUrl.openConnection(Proxy.NO_PROXY);' "$MAIN_ACTIVITY" | cut -d: -f1)
image_factory_line=$(grep -nF 'connection.setSSLSocketFactory(new AddressPinningSSLSocketFactory(' "$MAIN_ACTIVITY" | cut -d: -f1)
image_response_line=$(grep -nF 'int responseCode = connection.getResponseCode();' "$MAIN_ACTIVITY" | cut -d: -f1)
if [ -z "$image_resolve_line" ] || [ -z "$image_open_line" ] || \
   [ -z "$image_factory_line" ] || [ -z "$image_response_line" ] || \
   [ "$image_resolve_line" -ge "$image_open_line" ] || \
   [ "$image_open_line" -ge "$image_factory_line" ] || \
   [ "$image_factory_line" -ge "$image_response_line" ]; then
  printf '%s\n' "Search image DNS authorization and peer binding must precede response access." >&2
  exit 1
fi
if grep -RqE 'HostnameVerifier|TrustManager|setHostnameVerifier' \
    "$ADDRESS_PINNING_FACTORY" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Search image peer binding must preserve platform TLS verification." >&2
  exit 1
fi
for image_dns_fixture in \
  'new FixedResolver(resolverAnswers)' \
  'new FailingResolver()' \
  'expectPeerRejected' \
  'expectAlternatePathsRejected' \
  'rejected connected peer must be closed' \
  'TLS delegation must preserve the original authority'; do
  if ! grep -Fq "$image_dns_fixture" "$IMAGE_URL_POLICY_TEST"; then
    printf '%s\n' "Search image DNS peer fixture is missing: $image_dns_fixture" >&2
    exit 1
  fi
done
for image_dns_plan_contract in \
  'Status: Completed' \
  'requirePublicAddresses' \
  'AddressPinningSSLSocketFactory' \
  'make check' \
  'mutations'; do
  if ! grep -Fq "$image_dns_plan_contract" "$IMAGE_DNS_PEER_PLAN"; then
    printf '%s\n' "Search image DNS peer plan must record completed verification: $image_dns_plan_contract" >&2
    exit 1
  fi
done
for image_dns_doc in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "Backend-provided image URL DNS answers must exclude prohibited address classes, and a direct HTTPS connection must match an authorized answer before TLS or HTTP data is sent." "$ROOT_DIR/$image_dns_doc"; then
    printf '%s\n' "$image_dns_doc must document image DNS peer binding." >&2
    exit 1
  fi
done
for image_port_doc in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "Backend-provided image URLs use only the default HTTPS port before connection setup." "$ROOT_DIR/$image_port_doc"; then
    printf '%s\n' "$image_port_doc must document image URL default-port validation." >&2
    exit 1
  fi
done
for image_url_doc in AGENTS.md README.md SECURITY.md VISION.md CHANGES.md; do
  if ! grep -Fq "Backend-provided image URLs require HTTPS, a non-empty host, and no user-info credentials before connection setup." "$ROOT_DIR/$image_url_doc"; then
    printf '%s\n' "$image_url_doc must document image URL authority validation." >&2
    exit 1
  fi
done

MAIN_ACTIVITY_COMPACT=$(tr -d '[:space:]' < "$MAIN_ACTIVITY")
if ! printf '%s\n' "$MAIN_ACTIVITY_COMPACT" | grep -Fq \
    'InetAddress[]authorizedAddresses=ImageUrlPolicy.requirePublicAddresses(imageUrl.getHost());connection=(HttpsURLConnection)imageUrl.openConnection(Proxy.NO_PROXY);intimagePort=imageUrl.getPort()==-1?imageUrl.getDefaultPort():imageUrl.getPort();connection.setSSLSocketFactory(newAddressPinningSSLSocketFactory(connection.getSSLSocketFactory(),imageUrl.getHost(),imagePort,authorizedAddresses));connection.setInstanceFollowRedirects(false);connection.setConnectTimeout(IMAGE_DOWNLOAD_TIMEOUT_MILLIS);connection.setReadTimeout(IMAGE_DOWNLOAD_TIMEOUT_MILLIS);activeConnection=connection;if(isCancelled()){connection.disconnect();returnnull;}intresponseCode=connection.getResponseCode();if(responseCode<200||responseCode>=300){thrownewIOException("Searchimagerequestfailed");}if(!ResponseMediaType.isImage(connection.getContentType())){thrownewIOException("Searchimagemediatypeisinvalid");}in=connection.getInputStream();'; then
  printf '%s\n' "Search image redirects and non-success responses must be rejected before reading bytes." >&2
  exit 1
fi

if ! printf '%s\n' "$MAIN_ACTIVITY_COMPACT" | grep -Fq \
    'if(!ResponseMediaType.isImage(connection.getContentType())){thrownewIOException("Searchimagemediatypeisinvalid");}in=connection.getInputStream();'; then
  printf '%s\n' "Search image media type must be validated before image stream acquisition." >&2
  exit 1
fi

for media_type_contract in \
  'return "application/json".equals(mediaType)' \
  'hasSubtype(mediaType, "application")' \
  'mediaType.length() > "application/+json".length()' \
  'mediaType.endsWith("+json")' \
  'return hasSubtype(normalize(value), "image");' \
  "String prefix = type + \"/\";" \
  'if (!isTokenCharacter(mediaType.charAt(i)))' \
  '"!#$%&'\''*+-.^_`|~".indexOf(value) >= 0;' \
  "int parameterStart = value.indexOf(';');" \
  'mediaType.trim().toLowerCase(Locale.US);'; do
  if ! grep -Fq "$media_type_contract" "$MEDIA_TYPE_READER"; then
    printf '%s\n' "Search response media-type classifier changed: $media_type_contract" >&2
    exit 1
  fi
done
if [ ! -x "$MEDIA_TYPE_TEST" ] || \
   ! grep -Fq 'application/problem+json' "$MEDIA_TYPE_TEST" || \
   ! grep -Fq 'application/+json' "$MEDIA_TYPE_TEST" || \
   ! grep -Fq 'application/problem()+json' "$MEDIA_TYPE_TEST" || \
   ! grep -Fq 'IMAGE/JPEG ; charset=binary' "$MEDIA_TYPE_TEST" || \
   ! grep -Fq 'image/png/extra' "$MEDIA_TYPE_TEST" || \
   ! grep -Fq 'image/@png' "$MEDIA_TYPE_TEST" || \
   ! grep -Fq 'application/octet-stream' "$MEDIA_TYPE_TEST"; then
  printf '%s\n' "Search response media-type host tests are incomplete." >&2
  exit 1
fi

if ! printf '%s\n' "$MAIN_ACTIVITY_COMPACT" | grep -Fq \
    'if(in!=null){try{in.close();}catch(IOExceptione){Log.e(LOG_TAG,"Unabletoclosesearchimagestream");}}if(connection!=null){if(activeConnection==connection){activeConnection=null;}connection.disconnect();}'; then
  printf '%s\n' "Search image connections must disconnect after stream cleanup." >&2
  exit 1
fi

if grep -Fq "URLConnection connection = imageUrl.openConnection();" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Search image downloads must not use an implicitly redirecting generic connection." >&2
  exit 1
fi

for image_body_contract in \
  "private static final int MAX_IMAGE_BODY_BYTES = 1024 * 1024;" \
  "private static final long MAX_IMAGE_PIXELS = 4_000_000L;" \
  "BoundedResponseBody.readBytes(" \
  "connection.getContentLength()," \
  "private static Bitmap decodeBoundedImage(byte[] imageBody) throws IOException" \
  "bounds.inJustDecodeBounds = true;" \
  "(long) bounds.outWidth * bounds.outHeight > MAX_IMAGE_PIXELS"; do
  if ! grep -Fq "$image_body_contract" "$MAIN_ACTIVITY"; then
    printf '%s\n' "Missing bounded image contract: $image_body_contract" >&2
    exit 1
  fi
done
if grep -Fq "BitmapFactory.decodeStream(in)" "$MAIN_ACTIVITY"; then
  printf '%s\n' "Search images must not be decoded from an unbounded response stream." >&2
  exit 1
fi
for byte_reader_contract in \
  "static byte[] readBytes(InputStream input, long contentLength, int maxBytes)" \
  "return output.toByteArray();"; do
  if ! grep -Fq "$byte_reader_contract" "$RESPONSE_BODY_READER"; then
    printf '%s\n' "Bounded response byte reader contract changed: $byte_reader_contract" >&2
    exit 1
  fi
done
if ! grep -Fq "BoundedResponseBody.readBytes(" "$RESPONSE_BODY_TEST" || \
   ! grep -Fq "expectByteIOException(new byte[LIMIT + 1], -1, LIMIT);" "$RESPONSE_BODY_TEST"; then
  printf '%s\n' "Bounded image bytes must retain exact-limit and overflow tests." >&2
  exit 1
fi

if [ ! -f "$IMAGE_BODY_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$IMAGE_BODY_PLAN" || \
   ! grep -Fq "## Verification Completed" "$IMAGE_BODY_PLAN" || \
   ! grep -Fq "make check" "$IMAGE_BODY_PLAN" || \
   ! grep -Fq "hostile mutations" "$IMAGE_BODY_PLAN"; then
  printf '%s\n' "Search image body-limit plan must record completed verification." >&2
  exit 1
fi

for image_body_doc in "$ROOT_DIR/AGENTS.md" "$README" "$SECURITY" "$ROOT_DIR/VISION.md" "$ROOT_DIR/CHANGES.md"; do
  if ! grep -Fq "Image downloads bound compressed bodies and decoded pixel dimensions before allocation." "$image_body_doc"; then
    printf '%s\n' "$image_body_doc must document bounded image allocation." >&2
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
  'override ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))' \
  'ANDROID_HOME ?=' \
  'ANDROID_SDK_ROOT ?=' \
  'GRADLE ?= $(ROOT)gradlew' \
  'ANDROID_SDK := $(if $(ANDROID_HOME),$(ANDROID_HOME),$(ANDROID_SDK_ROOT))'; do
  if ! grep -Fxq "$make_contract" "$ROOT_DIR/Makefile"; then
    printf '%s\n' "Makefile must keep contract: $make_contract" >&2
    exit 1
  fi
done

if [ "$(grep -Fc '$(ROOT)scripts/check-baseline.sh' "$ROOT_DIR/Makefile")" -ne 1 ] || \
   [ "$(grep -Fc '$(ROOT)scripts/test-bounded-response-body.sh' "$ROOT_DIR/Makefile")" -ne 1 ] || \
   [ "$(grep -Fc '$(ROOT)scripts/test-response-media-type.sh' "$ROOT_DIR/Makefile")" -ne 1 ]; then
  printf '%s\n' "Baseline and response tests must use the protected root." >&2
  exit 1
fi

if [ ! -f "$MEDIA_TYPE_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$MEDIA_TYPE_PLAN" || \
   ! grep -Fq "make check" "$MEDIA_TYPE_PLAN" || \
   ! grep -Fq "focused mutations" "$MEDIA_TYPE_PLAN"; then
  printf '%s\n' "Search response media-type plan must record completed verification." >&2
  exit 1
fi

for gradle_contract in \
  'cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) lint --no-daemon; \' \
  'cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) test --no-daemon; \' \
  'cd $(ROOT) && ANDROID_HOME="$(ANDROID_SDK)" ANDROID_SDK_ROOT="$(ANDROID_SDK)" $(GRADLE) assembleDebug --no-daemon; \' ; do
  if [ "$(grep -Fc "$gradle_contract" "$ROOT_DIR/Makefile")" -ne 1 ]; then
    printf '%s\n' "Makefile must keep one complete rooted Gradle contract: $gradle_contract" >&2
    exit 1
  fi
done

if ! grep -Fxq "Status: Completed" "$ROOT_DIR/docs/plans/2026-06-14-android-search-make-root-override-protection.md"; then
  printf '%s\n' "Android Search Make root protection plan must record completed status." >&2
  exit 1
fi

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

if [ ! -f "$IMAGE_REDIRECT_PLAN" ] || \
   ! grep -Fq "Status: Completed" "$IMAGE_REDIRECT_PLAN" || \
   ! grep -Fq "make check" "$IMAGE_REDIRECT_PLAN" || \
   ! grep -Fq "hostile mutations" "$IMAGE_REDIRECT_PLAN"; then
  printf '%s\n' "Search image redirect plan must record completed verification." >&2
  exit 1
fi

for image_redirect_doc in "$ROOT_DIR/AGENTS.md" "$README" "$SECURITY" \
    "$ROOT_DIR/VISION.md" "$ROOT_DIR/CHANGES.md"; do
  if ! grep -Fq "Image downloads reject redirects and non-success responses before decoding." "$image_redirect_doc"; then
    printf '%s\n' "$image_redirect_doc must document image redirect rejection." >&2
    exit 1
  fi
done

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
