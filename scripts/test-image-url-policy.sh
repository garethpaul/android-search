#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/android-search-image-url.XXXXXX")
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

mkdir -p "$TMP_DIR/classes" "$TMP_DIR/gpj/androidsearch"
cp "$ROOT_DIR/app/src/main/java/gpj/androidsearch/ImageUrlPolicy.java" \
  "$TMP_DIR/gpj/androidsearch/ImageUrlPolicy.java"
cp "$ROOT_DIR/app/src/main/java/gpj/androidsearch/AddressPinningSSLSocketFactory.java" \
  "$TMP_DIR/gpj/androidsearch/AddressPinningSSLSocketFactory.java"

cat > "$TMP_DIR/gpj/androidsearch/ImageUrlPolicyTest.java" <<'EOF'
package gpj.androidsearch;

import java.io.IOException;
import java.net.InetAddress;
import java.net.MalformedURLException;
import java.net.Socket;
import java.net.UnknownHostException;
import java.net.URL;

import javax.net.ssl.SSLSocketFactory;

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
        expectAccepted("https://100.63.255.255/photo.png");
        expectAccepted("https://100.128.0.0/photo.png");
        expectAccepted("https://169.253.255.255/photo.png");
        expectAccepted("https://172.15.255.255/photo.png");
        expectAccepted("https://172.32.0.0/photo.png");
        expectAccepted("https://192.0.0.9/photo.png");
        expectAccepted("https://192.0.0.10/photo.png");
        expectAccepted("https://192.0.1.255/photo.png");
        expectAccepted("https://192.0.3.0/photo.png");
        expectAccepted("https://192.88.98.255/photo.png");
        expectAccepted("https://192.88.100.0/photo.png");
        expectAccepted("https://192.167.255.255/photo.png");
        expectAccepted("https://192.169.0.0/photo.png");
        expectAccepted("https://198.17.255.255/photo.png");
        expectAccepted("https://198.20.0.0/photo.png");
        expectAccepted("https://198.51.99.255/photo.png");
        expectAccepted("https://198.51.101.0/photo.png");
        expectAccepted("https://203.0.112.255/photo.png");
        expectAccepted("https://203.0.114.0/photo.png");
        expectAccepted("https://223.255.255.255/photo.png");
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
        expectRejected("https://100.64.0.0/photo.png");
        expectRejected("https://100.127.255.255/photo.png");
        expectRejected("https://100.64.1/photo.png");
        expectRejected("https://1681915905/photo.png");
        expectRejected("https://0x64400001/photo.png");
        expectRejected("https://014420000001/photo.png");
        expectRejected("https://169.254.1.1/photo.png");
        expectRejected("https://172.16.0.1/photo.png");
        expectRejected("https://172.31.255.255/photo.png");
        expectRejected("https://192.0.0.0/photo.png");
        expectRejected("https://192.0.0.8/photo.png");
        expectRejected("https://192.0.0.11/photo.png");
        expectRejected("https://192.0.0.255/photo.png");
        expectRejected("https://192.0.2.0/photo.png");
        expectRejected("https://192.0.2.255/photo.png");
        expectRejected("https://192.88.99.0/photo.png");
        expectRejected("https://192.88.99.255/photo.png");
        expectRejected("https://192.168.1.1/photo.png");
        expectRejected("https://198.18.0.0/photo.png");
        expectRejected("https://198.19.255.255/photo.png");
        expectRejected("https://198.51.100.0/photo.png");
        expectRejected("https://198.51.100.255/photo.png");
        expectRejected("https://203.0.113.0/photo.png");
        expectRejected("https://203.0.113.255/photo.png");
        expectRejected("https://240.0.0.0/photo.png");
        expectRejected("https://255.255.255.255/photo.png");
        expectRejected("https://[::]/photo.png");
        expectRejected("https://[fc00::1]/photo.png");
        expectRejected("https://[fdff:ffff::1]/photo.png");
        expectRejected("https://[fe80::1]/photo.png");
        expectRejected("https://[::ffff:10.0.0.1]/photo.png");

        testResolvedAddressPolicy();
        testConnectedPeerPolicy();

        System.out.println("Image URL policy tests passed.");
    }

    private static void testResolvedAddressPolicy() throws Exception {
        InetAddress publicV4 = address(8, 8, 8, 8);
        InetAddress publicV6 = InetAddress.getByAddress(new byte[] {
                0x20, 0x01, 0x48, 0x60, 0x48, 0x60, 0, 0,
                0, 0, 0, 0, 0, 0, (byte) 0x88, (byte) 0x88
        });
        InetAddress[] resolverAnswers = new InetAddress[] { publicV4, publicV6 };
        InetAddress[] authorized = ImageUrlPolicy.requirePublicAddresses(
                "images.example.test", new FixedResolver(resolverAnswers));
        resolverAnswers[0] = address(10, 0, 0, 1);
        if (!publicV4.equals(authorized[0]) || !publicV6.equals(authorized[1])) {
            throw new AssertionError("resolved address result must be defensively copied");
        }

        expectResolutionRejected(new InetAddress[] { publicV4, address(10, 0, 0, 1) });
        expectResolutionRejected(new InetAddress[] { address(127, 0, 0, 1) });
        expectResolutionRejected(new InetAddress[] { address(0, 0, 0, 0) });
        expectResolutionRejected(new InetAddress[] { address(169, 254, 1, 1) });
        expectResolutionRejected(new InetAddress[] { address(192, 168, 1, 1) });
        expectResolutionRejected(new InetAddress[] { address(100, 64, 0, 1) });
        expectResolutionRejected(new InetAddress[] { publicV4, address(192, 0, 2, 1) });
        expectResolutionRejected(new InetAddress[] { address(192, 0, 0, 8) });
        expectResolutionRejected(new InetAddress[] { address(192, 88, 99, 1) });
        expectResolutionRejected(new InetAddress[] { address(198, 18, 0, 1) });
        expectResolutionRejected(new InetAddress[] { address(198, 51, 100, 1) });
        expectResolutionRejected(new InetAddress[] { address(203, 0, 113, 1) });
        expectResolutionRejected(new InetAddress[] { address(240, 0, 0, 1) });
        expectResolutionRejected(new InetAddress[] { address(224, 0, 0, 1) });
        expectResolutionRejected(new InetAddress[] {
                InetAddress.getByAddress(new byte[] {
                        (byte) 0xfc, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 1
                })
        });
        expectResolutionRejected(new InetAddress[] {
                InetAddress.getByAddress(new byte[] {
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, (byte) 0xff, (byte) 0xff, 10, 0, 0, 1
                })
        });
        expectResolutionRejected(new InetAddress[0]);
        try {
            ImageUrlPolicy.requirePublicAddresses(
                    "images.example.test", new FailingResolver());
            throw new AssertionError("resolution failure must be rejected");
        } catch (UnknownHostException expected) {
            // Expected fail-closed resolution.
        }
    }

    private static void testConnectedPeerPolicy() throws Exception {
        InetAddress authorizedPeer = address(8, 8, 8, 8);
        InetAddress[] authorized = new InetAddress[] { authorizedPeer };
        RecordingSSLSocketFactory delegate = new RecordingSSLSocketFactory();
        AddressPinningSSLSocketFactory factory = new AddressPinningSSLSocketFactory(
                delegate, "images.example.test", 443, authorized);
        authorized[0] = address(9, 9, 9, 9);

        FakeConnectedSocket accepted = new FakeConnectedSocket(authorizedPeer, 443);
        Socket wrapped = factory.createSocket(accepted, "rebound.example.test", 8443, true);
        if (wrapped != delegate.returnedSocket
                || delegate.connectedSocket != accepted
                || !"images.example.test".equals(delegate.hostname)
                || delegate.port != 443
                || !delegate.autoClose) {
            throw new AssertionError("TLS delegation must preserve the original authority");
        }

        expectPeerRejected(factory, new FakeConnectedSocket(address(9, 9, 9, 9), 443));
        expectPeerRejected(factory, new FakeConnectedSocket(address(10, 0, 0, 1), 443));
        expectPeerRejected(factory, new FakeConnectedSocket(authorizedPeer, 8443));
        expectPeerRejected(factory, new FakeConnectedSocket(null, 443));

        InetAddress benchmarkingPeer = address(198, 18, 0, 1);
        AddressPinningSSLSocketFactory specialUseFactory =
                new AddressPinningSSLSocketFactory(
                        delegate,
                        "images.example.test",
                        443,
                        new InetAddress[] { benchmarkingPeer });
        expectPeerRejected(
                specialUseFactory, new FakeConnectedSocket(benchmarkingPeer, 443));
        expectAlternatePathsRejected(factory, authorizedPeer);
    }

    private static void expectResolutionRejected(InetAddress[] answers) throws Exception {
        try {
            ImageUrlPolicy.requirePublicAddresses(
                    "images.example.test", new FixedResolver(answers));
            throw new AssertionError("prohibited DNS answer must be rejected");
        } catch (UnknownHostException expected) {
            // Expected fail-closed resolution.
        }
    }

    private static void expectPeerRejected(AddressPinningSSLSocketFactory factory,
            FakeConnectedSocket socket) throws Exception {
        try {
            factory.createSocket(socket, "images.example.test", 443, true);
            throw new AssertionError("unauthorized connected peer must be rejected");
        } catch (IOException expected) {
            if (!socket.wasClosed) {
                throw new AssertionError("rejected connected peer must be closed");
            }
        }
    }

    private static void expectAlternatePathsRejected(
            final AddressPinningSSLSocketFactory factory, final InetAddress address)
            throws Exception {
        expectIoFailure(new SocketCall() {
            public void run() throws IOException {
                factory.createSocket();
            }
        });
        expectIoFailure(new SocketCall() {
            public void run() throws IOException {
                factory.createSocket("images.example.test", 443);
            }
        });
        expectIoFailure(new SocketCall() {
            public void run() throws IOException {
                factory.createSocket("images.example.test", 443, address, 0);
            }
        });
        expectIoFailure(new SocketCall() {
            public void run() throws IOException {
                factory.createSocket(address, 443);
            }
        });
        expectIoFailure(new SocketCall() {
            public void run() throws IOException {
                factory.createSocket(address, 443, address, 0);
            }
        });
    }

    private static void expectIoFailure(SocketCall call) throws Exception {
        try {
            call.run();
            throw new AssertionError("alternate TLS socket path must fail closed");
        } catch (IOException expected) {
            // Expected fail-closed path.
        }
    }

    private static InetAddress address(int first, int second, int third, int fourth)
            throws UnknownHostException {
        return InetAddress.getByAddress(new byte[] {
                (byte) first, (byte) second, (byte) third, (byte) fourth
        });
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

    private interface SocketCall {
        void run() throws IOException;
    }

    private static final class FixedResolver implements ImageUrlPolicy.AddressResolver {
        private final InetAddress[] answers;

        FixedResolver(InetAddress[] answers) {
            this.answers = answers;
        }

        public InetAddress[] resolve(String host) {
            return answers;
        }
    }

    private static final class FailingResolver implements ImageUrlPolicy.AddressResolver {
        public InetAddress[] resolve(String host) throws UnknownHostException {
            throw new UnknownHostException("fixture failure");
        }
    }

    private static final class FakeConnectedSocket extends Socket {
        private final InetAddress address;
        private final int port;
        private boolean wasClosed;

        FakeConnectedSocket(InetAddress address, int port) {
            this.address = address;
            this.port = port;
        }

        @Override
        public InetAddress getInetAddress() {
            return address;
        }

        @Override
        public int getPort() {
            return port;
        }

        @Override
        public synchronized void close() {
            wasClosed = true;
        }
    }

    private static final class RecordingSSLSocketFactory extends SSLSocketFactory {
        private final Socket returnedSocket = new Socket();
        private Socket connectedSocket;
        private String hostname;
        private int port;
        private boolean autoClose;

        @Override
        public String[] getDefaultCipherSuites() {
            return new String[] { "fixture" };
        }

        @Override
        public String[] getSupportedCipherSuites() {
            return new String[] { "fixture" };
        }

        @Override
        public Socket createSocket(Socket socket, String host, int targetPort,
                boolean close) {
            connectedSocket = socket;
            hostname = host;
            port = targetPort;
            autoClose = close;
            return returnedSocket;
        }

        @Override
        public Socket createSocket(String host, int targetPort) {
            throw new AssertionError("unexpected delegate overload");
        }

        @Override
        public Socket createSocket(String host, int targetPort, InetAddress localAddress,
                int localPort) {
            throw new AssertionError("unexpected delegate overload");
        }

        @Override
        public Socket createSocket(InetAddress address, int targetPort) {
            throw new AssertionError("unexpected delegate overload");
        }

        @Override
        public Socket createSocket(InetAddress address, int targetPort,
                InetAddress localAddress, int localPort) {
            throw new AssertionError("unexpected delegate overload");
        }
    }
}
EOF

javac -source 1.7 -target 1.7 -Xlint:all,-options -Werror \
  -d "$TMP_DIR/classes" \
  "$TMP_DIR/gpj/androidsearch/ImageUrlPolicy.java" \
  "$TMP_DIR/gpj/androidsearch/AddressPinningSSLSocketFactory.java" \
  "$TMP_DIR/gpj/androidsearch/ImageUrlPolicyTest.java"
java -cp "$TMP_DIR/classes" gpj.androidsearch.ImageUrlPolicyTest
