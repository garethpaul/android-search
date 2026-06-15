package gpj.androidsearch;

import java.net.InetAddress;
import java.net.MalformedURLException;
import java.net.UnknownHostException;
import java.net.URL;
import java.util.Locale;

final class ImageUrlPolicy {
    private ImageUrlPolicy() {
    }

    static URL requireHttpsAuthority(String value) throws MalformedURLException {
        URL imageUrl = new URL(value);
        if (!"https".equalsIgnoreCase(imageUrl.getProtocol())) {
            throw new MalformedURLException("Search image URLs must use HTTPS");
        }
        if (imageUrl.getHost() == null || imageUrl.getHost().length() == 0) {
            throw new MalformedURLException("Search image URLs must include a host");
        }
        if (imageUrl.getUserInfo() != null) {
            throw new MalformedURLException("Search image URLs must not include user info");
        }
        if (imageUrl.getPort() != -1 && imageUrl.getPort() != 443) {
            throw new MalformedURLException("Search image URLs must use the default HTTPS port");
        }
        if (isLoopbackHost(imageUrl.getHost())) {
            throw new MalformedURLException("Search image URLs must not target loopback hosts");
        }

        return imageUrl;
    }

    private static boolean isLoopbackHost(String host) {
        String normalizedHost = host.toLowerCase(Locale.US);
        if (normalizedHost.endsWith(".")) {
            normalizedHost = normalizedHost.substring(0, normalizedHost.length() - 1);
        }
        if ("localhost".equals(normalizedHost)
                || normalizedHost.endsWith(".localhost")) {
            return true;
        }

        if (normalizedHost.startsWith("[")
                && normalizedHost.endsWith("]")
                && normalizedHost.indexOf(':') >= 0) {
            String address = normalizedHost.substring(1, normalizedHost.length() - 1);
            try {
                return InetAddress.getByName(address).isLoopbackAddress();
            } catch (UnknownHostException ignored) {
                return false;
            }
        }

        long ipv4Address = parseIpv4Literal(normalizedHost);
        return ipv4Address >= 0 && (ipv4Address & 0xff000000L) == 0x7f000000L;
    }

    private static long parseIpv4Literal(String host) {
        String[] parts = host.split("\\.", -1);
        if (parts.length == 0 || parts.length > 4) {
            return -1;
        }

        long lastPartMaximum = (1L << (8 * (5 - parts.length))) - 1;
        long address = 0;
        for (int index = 0; index < parts.length - 1; index++) {
            long part = parseIpv4Part(parts[index], 255);
            if (part < 0) {
                return -1;
            }
            address = (address << 8) | part;
        }
        long lastPart = parseIpv4Part(parts[parts.length - 1], lastPartMaximum);
        if (lastPart < 0) {
            return -1;
        }
        return (address << (8 * (5 - parts.length))) | lastPart;
    }

    private static long parseIpv4Part(String value, long maximum) {
        if (value.length() == 0) {
            return -1;
        }

        int radix = 10;
        int start = 0;
        if (value.length() > 2 && value.charAt(0) == '0'
                && (value.charAt(1) == 'x' || value.charAt(1) == 'X')) {
            radix = 16;
            start = 2;
        } else if (value.length() > 1 && value.charAt(0) == '0') {
            radix = 8;
            start = 1;
        }
        if (start == value.length()) {
            return -1;
        }

        long result = 0;
        for (int index = start; index < value.length(); index++) {
            int digit = Character.digit(value.charAt(index), radix);
            if (digit < 0 || result > (maximum - digit) / radix) {
                return -1;
            }
            result = result * radix + digit;
        }
        return result;
    }
}
