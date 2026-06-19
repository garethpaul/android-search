package gpj.androidsearch;

import java.io.IOException;
import java.net.InetAddress;
import java.net.Socket;

import javax.net.ssl.SSLSocketFactory;

final class AddressPinningSSLSocketFactory extends SSLSocketFactory {
    private final SSLSocketFactory delegate;
    private final String hostname;
    private final int port;
    private final InetAddress[] authorizedAddresses;

    AddressPinningSSLSocketFactory(SSLSocketFactory delegate, String hostname, int port,
            InetAddress[] authorizedAddresses) {
        if (delegate == null || hostname == null || authorizedAddresses == null) {
            throw new IllegalArgumentException("TLS peer policy requires complete inputs");
        }
        this.delegate = delegate;
        this.hostname = hostname;
        this.port = port;
        this.authorizedAddresses = authorizedAddresses.clone();
    }

    @Override
    public String[] getDefaultCipherSuites() {
        return delegate.getDefaultCipherSuites();
    }

    @Override
    public String[] getSupportedCipherSuites() {
        return delegate.getSupportedCipherSuites();
    }

    @Override
    public Socket createSocket(Socket socket, String ignoredHost, int ignoredPort,
            boolean autoClose) throws IOException {
        InetAddress peerAddress = socket == null ? null : socket.getInetAddress();
        if (peerAddress == null
                || ImageUrlPolicy.isProhibitedAddress(peerAddress)
                || !isAuthorized(peerAddress)
                || socket.getPort() != port) {
            closeQuietly(socket);
            throw new IOException("Search image TLS peer is not authorized");
        }
        return delegate.createSocket(socket, hostname, port, autoClose);
    }

    @Override
    public Socket createSocket() throws IOException {
        throw unsupportedPath();
    }

    @Override
    public Socket createSocket(String host, int targetPort) throws IOException {
        throw unsupportedPath();
    }

    @Override
    public Socket createSocket(String host, int targetPort, InetAddress localAddress,
            int localPort) throws IOException {
        throw unsupportedPath();
    }

    @Override
    public Socket createSocket(InetAddress address, int targetPort) throws IOException {
        throw unsupportedPath();
    }

    @Override
    public Socket createSocket(InetAddress address, int targetPort, InetAddress localAddress,
            int localPort) throws IOException {
        throw unsupportedPath();
    }

    private boolean isAuthorized(InetAddress peerAddress) {
        for (InetAddress authorizedAddress : authorizedAddresses) {
            if (peerAddress.equals(authorizedAddress)) {
                return true;
            }
        }
        return false;
    }

    private static IOException unsupportedPath() {
        return new IOException("Search image TLS socket path is unsupported");
    }

    private static void closeQuietly(Socket socket) {
        if (socket == null) {
            return;
        }
        try {
            socket.close();
        } catch (IOException ignored) {
            // Preserve the authorization failure.
        }
    }
}
