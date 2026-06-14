#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/android-search-media-type.XXXXXX")
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

mkdir -p "$TMP_DIR/classes" "$TMP_DIR/gpj/androidsearch"
cp "$ROOT_DIR/app/src/main/java/gpj/androidsearch/ResponseMediaType.java" \
  "$TMP_DIR/gpj/androidsearch/ResponseMediaType.java"

cat > "$TMP_DIR/gpj/androidsearch/ResponseMediaTypeTest.java" <<'EOF'
package gpj.androidsearch;

public final class ResponseMediaTypeTest {
    public static void main(String[] args) {
        expectJson("application/json");
        expectJson(" Application/JSON ; charset=UTF-8 ");
        expectJson("application/problem+json");
        rejectJson(null);
        rejectJson("");
        rejectJson("text/json");
        rejectJson("application/jsonp");
        rejectJson("application/+json");
        rejectJson("application/ problem+json");
        rejectJson("application/problem()+json");
        rejectJson("image/json");

        expectImage("image/png");
        expectImage(" IMAGE/JPEG ; charset=binary ");
        expectImage("image/svg+xml");
        rejectImage(null);
        rejectImage("");
        rejectImage("application/octet-stream");
        rejectImage("application/json");
        rejectImage("imagery/png");
        rejectImage("image/");
        rejectImage("image/ png");
        rejectImage("image/png/extra");
        rejectImage("image/@png");

        System.out.println("Response media type tests passed.");
    }

    private static void expectJson(String value) {
        if (!ResponseMediaType.isJson(value)) {
            throw new AssertionError("expected JSON media type: " + value);
        }
    }

    private static void rejectJson(String value) {
        if (ResponseMediaType.isJson(value)) {
            throw new AssertionError("unexpected JSON media type: " + value);
        }
    }

    private static void expectImage(String value) {
        if (!ResponseMediaType.isImage(value)) {
            throw new AssertionError("expected image media type: " + value);
        }
    }

    private static void rejectImage(String value) {
        if (ResponseMediaType.isImage(value)) {
            throw new AssertionError("unexpected image media type: " + value);
        }
    }
}
EOF

javac -source 1.7 -target 1.7 -Xlint:all,-options -Werror \
  -d "$TMP_DIR/classes" \
  "$TMP_DIR/gpj/androidsearch/ResponseMediaType.java" \
  "$TMP_DIR/gpj/androidsearch/ResponseMediaTypeTest.java"
java -cp "$TMP_DIR/classes" gpj.androidsearch.ResponseMediaTypeTest
