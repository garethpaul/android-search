package gpj.androidsearch;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;

final class BoundedResponseBody {
    private static final int BUFFER_SIZE = 4096;

    private BoundedResponseBody() {
    }

    static String read(InputStream input, long contentLength, int maxBytes)
            throws IOException {
        if (input == null) {
            throw new NullPointerException("input");
        }
        if (maxBytes <= 0) {
            throw new IllegalArgumentException("maxBytes must be positive");
        }
        if (contentLength > maxBytes) {
            throw new IOException("Search response exceeds limit");
        }

        ByteArrayOutputStream output = new ByteArrayOutputStream(
                Math.min(maxBytes, BUFFER_SIZE));
        byte[] buffer = new byte[BUFFER_SIZE];
        int total = 0;

        while (true) {
            int remaining = maxBytes - total;
            int requested = (int) Math.min(buffer.length, (long) remaining + 1L);
            int count = input.read(buffer, 0, requested);
            if (count == -1) {
                break;
            }
            if (count == 0) {
                int value = input.read();
                if (value == -1) {
                    break;
                }
                if (remaining == 0) {
                    throw new IOException("Search response exceeds limit");
                }
                output.write(value);
                total++;
                continue;
            }
            if (count > remaining) {
                throw new IOException("Search response exceeds limit");
            }

            output.write(buffer, 0, count);
            total += count;
        }

        try {
            return output.toString("UTF-8");
        } catch (UnsupportedEncodingException e) {
            throw new AssertionError(e);
        }
    }
}
