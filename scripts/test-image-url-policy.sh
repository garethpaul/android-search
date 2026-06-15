#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/android-search-image-url.XXXXXX")
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

mkdir -p "$TMP_DIR/classes" "$TMP_DIR/gpj/androidsearch"
cp "$ROOT_DIR/app/src/main/java/gpj/androidsearch/ImageUrlPolicy.java" \
  "$TMP_DIR/gpj/androidsearch/ImageUrlPolicy.java"

cat > "$TMP_DIR/gpj/androidsearch/ImageUrlPolicyTest.java" <<'EOF'
package gpj.androidsearch;

import java.net.MalformedURLException;
import java.net.URL;

public final class ImageUrlPolicyTest {
    public static void main(String[] args) throws Exception {
        expectAccepted("https://images.example.test/photo.png");
        expectAccepted("HTTPS://images.example.test:443/photo.png#preview");
        expectAccepted("https://images.example.test/photo.png?token=a%2Bb&expires=1");
        expectAccepted("https://127.example.test/photo.png");
        expectAccepted("https://images.localhost.example/photo.png");
        expectAccepted("https://128.1/photo.png");
        expectAccepted("https://2147483649/photo.png");
        expectAccepted("https://8.8.8.8/photo.png");
        expectAccepted("https://9.255.255.255/photo.png");
        expectAccepted("https://11.0.0.1/photo.png");
        expectAccepted("https://169.253.255.255/photo.png");
        expectAccepted("https://172.15.255.255/photo.png");
        expectAccepted("https://172.32.0.0/photo.png");
        expectAccepted("https://192.167.255.255/photo.png");
        expectAccepted("https://192.169.0.0/photo.png");
        expectAccepted("https://[2001:4860:4860::8888]/photo.png");

        expectRejected("http://images.example.test/photo.png");
        expectRejected("https:/photo.png");
        expectRejected("https://user@example.test/photo.png");
        expectRejected("https://user:password@example.test/photo.png");
        expectRejected("https://images.example.test:1/photo.png");
        expectRejected("https://images.example.test:80/photo.png");
        expectRejected("https://images.example.test:444/photo.png");
        expectRejected("https://images.example.test:8443/photo.png");
        expectRejected("https://localhost/photo.png");
        expectRejected("https://LOCALHOST./photo.png");
        expectRejected("https://images.localhost/photo.png");
        expectRejected("https://127.0.0.1/photo.png");
        expectRejected("https://127.255.255.254/photo.png");
        expectRejected("https://127.1/photo.png");
        expectRejected("https://2130706433/photo.png");
        expectRejected("https://0177.0.0.1/photo.png");
        expectRejected("https://0x7f.0.0.1/photo.png");
        expectRejected("https://017700000001/photo.png");
        expectRejected("https://0x7f000001/photo.png");
        expectRejected("https://[::1]/photo.png");
        expectRejected("https://[0:0:0:0:0:0:0:1]/photo.png");
        expectRejected("https://[::ffff:127.0.0.1]/photo.png");
        expectRejected("https://[0:0:0:0:0:ffff:7f00:1]/photo.png");
        expectRejected("https://0.0.0.0/photo.png");
        expectRejected("https://10.0.0.1/photo.png");
        expectRejected("https://167772161/photo.png");
        expectRejected("https://012.0.0.1/photo.png");
        expectRejected("https://0x0a000001/photo.png");
        expectRejected("https://169.254.1.1/photo.png");
        expectRejected("https://172.16.0.1/photo.png");
        expectRejected("https://172.31.255.255/photo.png");
        expectRejected("https://192.168.1.1/photo.png");
        expectRejected("https://[::]/photo.png");
        expectRejected("https://[fc00::1]/photo.png");
        expectRejected("https://[fdff:ffff::1]/photo.png");
        expectRejected("https://[fe80::1]/photo.png");
        expectRejected("https://[::ffff:10.0.0.1]/photo.png");

        System.out.println("Image URL policy tests passed.");
    }

    private static void expectAccepted(String value) throws Exception {
        URL parsed = ImageUrlPolicy.requireHttpsAuthority(value);
        if (!"https".equalsIgnoreCase(parsed.getProtocol())
                || parsed.getHost().length() == 0) {
            throw new AssertionError("unexpected parsed image URL: " + value);
        }
    }

    private static void expectRejected(String value) throws Exception {
        try {
            ImageUrlPolicy.requireHttpsAuthority(value);
            throw new AssertionError("unexpected accepted image URL: " + value);
        } catch (MalformedURLException expected) {
            // Expected boundary rejection.
        }
    }
}
EOF

javac -source 1.7 -target 1.7 -Xlint:all,-options -Werror \
  -d "$TMP_DIR/classes" \
  "$TMP_DIR/gpj/androidsearch/ImageUrlPolicy.java" \
  "$TMP_DIR/gpj/androidsearch/ImageUrlPolicyTest.java"
java -cp "$TMP_DIR/classes" gpj.androidsearch.ImageUrlPolicyTest
