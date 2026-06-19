package gpj.androidsearch;

import java.util.Locale;

final class ResponseMediaType {
    private ResponseMediaType() {
    }

    static boolean isJson(String value) {
        String mediaType = normalize(value);
        return "application/json".equals(mediaType)
                || (hasSubtype(mediaType, "application")
                && mediaType.length() > "application/+json".length()
                && mediaType.endsWith("+json"));
    }

    static boolean isImage(String value) {
        return hasSubtype(normalize(value), "image");
    }

    private static boolean hasSubtype(String mediaType, String type) {
        String prefix = type + "/";
        if (!mediaType.startsWith(prefix) || mediaType.length() == prefix.length()) {
            return false;
        }

        for (int i = prefix.length(); i < mediaType.length(); i++) {
            if (!isTokenCharacter(mediaType.charAt(i))) {
                return false;
            }
        }
        return true;
    }

    private static boolean isTokenCharacter(char value) {
        return value >= 'a' && value <= 'z'
                || value >= '0' && value <= '9'
                || "!#$%&'*+-.^_`|~".indexOf(value) >= 0;
    }

    private static String normalize(String value) {
        if (value == null) {
            return "";
        }

        int parameterStart = value.indexOf(';');
        String mediaType = parameterStart >= 0
                ? value.substring(0, parameterStart)
                : value;
        return mediaType.trim().toLowerCase(Locale.US);
    }
}
