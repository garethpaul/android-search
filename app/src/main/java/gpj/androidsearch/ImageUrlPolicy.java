package gpj.androidsearch;

import java.net.MalformedURLException;
import java.net.URL;

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

        return imageUrl;
    }
}
