#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/android-search-response.XXXXXX")
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

mkdir -p "$TMP_DIR/classes" "$TMP_DIR/gpj/androidsearch"
cp "$ROOT_DIR/app/src/main/java/gpj/androidsearch/BoundedResponseBody.java" \
  "$TMP_DIR/gpj/androidsearch/BoundedResponseBody.java"

cat > "$TMP_DIR/gpj/androidsearch/BoundedResponseBodyTest.java" <<'EOF'
package gpj.androidsearch;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;

public final class BoundedResponseBodyTest {
    private static final int LIMIT = 64 * 1024;

    public static void main(String[] args) throws Exception {
        assertEquals("", read(new byte[0], 0, LIMIT));
        assertEquals(LIMIT, read(new byte[LIMIT], LIMIT, LIMIT).length());
        assertEquals(LIMIT,
                BoundedResponseBody.readBytes(
                        new ByteArrayInputStream(new byte[LIMIT]),
                        LIMIT,
                        LIMIT).length);
        assertEquals("\u20ac", read(new byte[] {
                (byte) 0xe2, (byte) 0x82, (byte) 0xac
        }, -1, LIMIT));
        expectMalformedUtf8(new byte[] {(byte) 0xc3, 0x28});

        expectIOException(new byte[LIMIT + 1], LIMIT + 1, LIMIT);
        expectIOException(new byte[LIMIT + 1], -1, LIMIT);
        expectIOException(new byte[LIMIT + 1], 1, LIMIT);
        expectByteIOException(new byte[LIMIT + 1], -1, LIMIT);
        expectIllegalLimit(0);
        expectIllegalLimit(-1);

        CountingInputStream declaredOversize = new CountingInputStream(new byte[1]);
        try {
            BoundedResponseBody.read(declaredOversize, LIMIT + 1, LIMIT);
            throw new AssertionError("declared oversized response was accepted");
        } catch (IOException expected) {
            assertEquals(0, declaredOversize.bytesRead);
        }

        CountingInputStream streamedOversize = new CountingInputStream(new byte[LIMIT + 100]);
        try {
            BoundedResponseBody.read(streamedOversize, -1, LIMIT);
            throw new AssertionError("streamed oversized response was accepted");
        } catch (IOException expected) {
            assertEquals(LIMIT + 1, streamedOversize.bytesRead);
        }

        System.out.println("Bounded response body tests passed.");
    }

    private static String read(byte[] value, long declaredLength, int maxBytes)
            throws IOException {
        return BoundedResponseBody.read(
                new ByteArrayInputStream(value), declaredLength, maxBytes);
    }

    private static void expectIOException(byte[] value, long declaredLength,
            int maxBytes) throws Exception {
        try {
            read(value, declaredLength, maxBytes);
            throw new AssertionError("oversized response was accepted");
        } catch (IOException expected) {
            // Expected.
        }
    }

    private static void expectIllegalLimit(int maxBytes) throws Exception {
        try {
            read(new byte[0], 0, maxBytes);
            throw new AssertionError("invalid limit was accepted");
        } catch (IllegalArgumentException expected) {
            // Expected.
        }
    }

    private static void expectMalformedUtf8(byte[] value) throws Exception {
        try {
            read(value, value.length, LIMIT);
            throw new AssertionError("malformed UTF-8 response was accepted");
        } catch (IOException expected) {
            // Expected.
        }
    }

    private static void expectByteIOException(byte[] value, long declaredLength,
            int maxBytes) throws Exception {
        try {
            BoundedResponseBody.readBytes(
                    new ByteArrayInputStream(value), declaredLength, maxBytes);
            throw new AssertionError("oversized byte response was accepted");
        } catch (IOException expected) {
            // Expected.
        }
    }

    private static void assertEquals(Object expected, Object actual) {
        if (!expected.equals(actual)) {
            throw new AssertionError("expected " + expected + " but got " + actual);
        }
    }

    private static void assertEquals(int expected, int actual) {
        if (expected != actual) {
            throw new AssertionError("expected " + expected + " but got " + actual);
        }
    }

    private static final class CountingInputStream extends InputStream {
        private final ByteArrayInputStream delegate;
        int bytesRead;

        CountingInputStream(byte[] value) {
            delegate = new ByteArrayInputStream(value);
        }

        @Override
        public int read() {
            int value = delegate.read();
            if (value != -1) {
                bytesRead++;
            }
            return value;
        }

        @Override
        public int read(byte[] buffer, int offset, int length) {
            int count = delegate.read(buffer, offset, length);
            if (count > 0) {
                bytesRead += count;
            }
            return count;
        }
    }
}
EOF

javac -source 1.7 -target 1.7 -Xlint:all,-options -Werror \
  -d "$TMP_DIR/classes" \
  "$TMP_DIR/gpj/androidsearch/BoundedResponseBody.java" \
  "$TMP_DIR/gpj/androidsearch/BoundedResponseBodyTest.java"
java -cp "$TMP_DIR/classes" gpj.androidsearch.BoundedResponseBodyTest
