package gpj.androidsearch;

import java.net.InetAddress;
import java.net.MalformedURLException;
import java.net.UnknownHostException;
import java.net.URL;
import java.util.Locale;

final class ImageUrlPolicy {
    interface AddressResolver {
        InetAddress[] resolve(String host) throws UnknownHostException;
    }

    private static final AddressResolver SYSTEM_ADDRESS_RESOLVER = new AddressResolver() {
        @Override
        public InetAddress[] resolve(String host) throws UnknownHostException {
            return InetAddress.getAllByName(host);
        }
    };

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
        if (isPrivateAddressLiteral(imageUrl.getHost())) {
            throw new MalformedURLException("Search image URLs must not target private address literals");
        }

        return imageUrl;
    }

    static InetAddress[] requirePublicAddresses(String host) throws UnknownHostException {
        return requirePublicAddresses(host, SYSTEM_ADDRESS_RESOLVER);
    }

    static InetAddress[] requirePublicAddresses(String host, AddressResolver resolver)
            throws UnknownHostException {
        InetAddress[] resolvedAddresses = resolver.resolve(host);
        if (resolvedAddresses == null || resolvedAddresses.length == 0) {
            throw new UnknownHostException("Search image host resolved without addresses");
        }

        InetAddress[] authorizedAddresses = resolvedAddresses.clone();
        for (InetAddress address : authorizedAddresses) {
            if (isProhibitedAddress(address)) {
                throw new UnknownHostException("Search image host resolved to a prohibited address");
            }
        }
        return authorizedAddresses.clone();
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

    private static boolean isPrivateAddressLiteral(String host) {
        String normalizedHost = host.toLowerCase(Locale.US);
        if (normalizedHost.endsWith(".")) {
            normalizedHost = normalizedHost.substring(0, normalizedHost.length() - 1);
        }

        if (normalizedHost.startsWith("[")
                && normalizedHost.endsWith("]")
                && normalizedHost.indexOf(':') >= 0) {
            String address = normalizedHost.substring(1, normalizedHost.length() - 1);
            try {
                return isProhibitedAddress(InetAddress.getByName(address));
            } catch (UnknownHostException ignored) {
                return false;
            }
        }

        long ipv4Address = parseIpv4Literal(normalizedHost);
        return ipv4Address >= 0 && isPrivateIpv4Address(ipv4Address);
    }

    static boolean isProhibitedAddress(InetAddress address) {
        if (address == null
                || address.isAnyLocalAddress()
                || address.isLoopbackAddress()
                || address.isLinkLocalAddress()
                || address.isSiteLocalAddress()
                || address.isMulticastAddress()) {
            return true;
        }

        byte[] addressBytes = address.getAddress();
        if (addressBytes.length == 4) {
            return isPrivateIpv4Address(ipv4Address(addressBytes, 0));
        }
        if (addressBytes.length == 16 && isIpv4MappedAddress(addressBytes)) {
            return isPrivateIpv4Address(ipv4Address(addressBytes, 12));
        }

        return addressBytes.length == 16 && (addressBytes[0] & 0xfe) == 0xfc;
    }

    private static boolean isIpv4MappedAddress(byte[] addressBytes) {
        for (int index = 0; index < 10; index++) {
            if (addressBytes[index] != 0) {
                return false;
            }
        }
        return addressBytes[10] == (byte) 0xff && addressBytes[11] == (byte) 0xff;
    }

    private static long ipv4Address(byte[] addressBytes, int offset) {
        long ipv4Address = 0;
        for (int index = offset; index < offset + 4; index++) {
            ipv4Address = (ipv4Address << 8) | (addressBytes[index] & 0xff);
        }
        return ipv4Address;
    }

    private static boolean isPrivateIpv4Address(long address) {
        return (address & 0xff000000L) == 0x00000000L
                || (address & 0xff000000L) == 0x0a000000L
                || (address & 0xffc00000L) == 0x64400000L
                || (address & 0xffff0000L) == 0xa9fe0000L
                || (address & 0xfff00000L) == 0xac100000L
                || (address & 0xffff0000L) == 0xc0a80000L;
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
