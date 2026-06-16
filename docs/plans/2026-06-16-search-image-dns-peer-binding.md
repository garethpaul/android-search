# Search Image DNS Peer Binding

Status: Planned

## Problem

The image URL policy rejects loopback, private, link-local, unspecified, and
shared IP literals, but accepts DNS-style hosts without resolving them. A
backend-provided hostname can therefore resolve to a prohibited address. A
preflight DNS check alone is insufficient because the HTTPS stack resolves the
hostname again when connecting, leaving a DNS-rebinding gap between policy
validation and transport setup.

Android's API-21 HTTPS implementation creates the raw socket and then invokes
the connection's `SSLSocketFactory.createSocket(Socket, host, port, ...)` before
the TLS handshake. This provides a fail-closed seam to verify that the actual
connected peer belongs to the previously authorized DNS answer set while still
passing the original hostname to the platform TLS and certificate-verification
path.

## Priorities

1. P0: Reject DNS-style image hosts when any resolved address is prohibited.
2. P0: Reject the actual connected peer unless it is one of the authorized DNS
   answers.
3. P0: Preserve default TLS trust and hostname verification with the original
   URL hostname.
4. P1: Preserve existing HTTPS, authority, port, redirect, timeout, media-type,
   body-limit, cancellation, and image-decoding behavior.
5. P1: Add deterministic host-side tests and mutation-sensitive contracts.

## Requirements

1. Production DNS resolution must use `InetAddress.getAllByName` through an
   injectable package-local resolver seam.
2. Empty results, resolution failures, and any loopback, private, link-local,
   unspecified, multicast, IPv4 shared, or IPv6 unique-local answer must fail
   before image response processing.
3. The approved address set must be installed on the individual
   `HttpsURLConnection` before `getResponseCode` or stream access.
4. The socket factory's connected-socket overload must close and reject a peer
   that is prohibited or absent from the approved set before delegating to the
   platform TLS factory.
5. The delegated TLS wrapping call must retain the original hostname and port;
   no permissive hostname verifier or trust manager may be introduced.
6. Other socket-creation overloads must fail closed so a different runtime path
   cannot silently bypass peer verification.
7. DNS and peer-validation failures must remain inside the existing generic
   image-download failure boundary without logging hostnames or provider
   details.
8. Tests, maintained guidance, the portable checker, and this plan must retain
   the completed behavior and truthful verification evidence.

## Implementation Units

### U1: Resolved Address Authorization

**Files:** `app/src/main/java/gpj/androidsearch/ImageUrlPolicy.java`

Add an injectable resolver and a package-local method that returns a defensive
copy of the complete authorized answer set. Reuse the existing literal-address
classification and extend it only where required for resolved multicast and
loopback addresses.

### U2: Connected Peer Enforcement

**Files:** `app/src/main/java/gpj/androidsearch/AddressPinningSSLSocketFactory.java`

Wrap the connection's default `SSLSocketFactory`. Permit only the Android
connected-socket wrapping path after verifying the peer is both allowed and in
the authorized set. Delegate TLS wrapping with the original hostname so the
platform continues to perform normal SNI, trust-chain, and hostname checks.
Fail closed for alternate factory overloads.

### U3: Image Transport Integration

**Files:** `app/src/main/java/gpj/androidsearch/MainActivity.java`

Resolve and authorize the parsed image hostname, open the HTTPS connection,
install the peer-checking socket factory, then preserve the existing redirect,
timeout, cancellation, status, media-type, body, decode, and cleanup ordering.

### U4: Deterministic Regression Coverage

**Files:** `scripts/test-image-url-policy.sh`

Use fake DNS answers, connected sockets, and a recording TLS delegate to cover
public acceptance; mixed public/private rejection; empty and failed resolution;
loopback, multicast, shared, private, link-local, unspecified, and unique-local
answers; mismatched actual peers; socket closure on rejection; original-host
delegation; defensive answer copying; and fail-closed alternate overloads.

### U5: Contracts And Guidance

**Files:** `scripts/check-baseline.sh`, `AGENTS.md`, `README.md`, `SECURITY.md`,
`VISION.md`, `CHANGES.md`, and this plan.

Require the resolver seam, actual-peer enforcement, TLS-host preservation,
integration ordering, focused tests, maintained guidance, completed plan
status, and verification evidence.

## Test Scenarios

- A DNS host with only public IPv4/IPv6 answers is authorized.
- Mixed public and prohibited answers fail closed.
- Resolution failure and an empty answer set fail closed.
- The actual connected peer must exactly match one authorized answer.
- A mismatched or prohibited connected peer is closed before TLS delegation.
- The recording TLS delegate receives the original hostname, port, and
  `autoClose` value for an approved peer.
- Direct host/address/no-argument socket creation overloads fail closed.
- Existing numeric literal, URL authority, default-port, redirect, timeout,
  cancellation, response, and body-limit tests remain green.
- Repository and external-directory `make check` remain green with and without
  the Android SDK gate.

## Scope Boundaries

- Do not add a permissive `HostnameVerifier`, custom trust manager, certificate
  bypass, proxy bypass, host allowlist, or DNS cache.
- Do not change the search endpoint, response schema, accepted public image
  hosts, query behavior, dependencies, Android API levels, or build toolchain.
- Do not send HTTP or TLS application data to a peer before actual-address
  authorization.
- A TCP connection attempt may occur before Android exposes the connected peer
  to the socket factory; the policy must close a rejected peer before TLS or
  HTTP data is delegated.
- Live DNS, backend, CDN, emulator, and physical-device behavior remain outside
  deterministic local validation.

## Assumptions

- The maintained API-21 HTTPS path continues to invoke the per-connection
  connected-socket factory overload before TLS, as documented by the Android
  platform source used for this plan.
- Rejecting a DNS name when any answer is prohibited is preferable to selecting
  only its public answers because mixed answers can create nondeterministic
  routing and rebinding exposure.

## Verification

- Reproduce that a fake DNS hostname resolving to a private address currently
  passes the syntactic URL policy.
- Run the focused pure-Java resolver and peer-binding matrix.
- Run repository and external-directory `make check`, including SDK-backed
  lint, unit tests, and debug assembly when configured.
- Reject isolated mutations that remove mixed-answer rejection, actual-peer
  membership, peer closure, original-host TLS delegation, fail-closed overloads,
  integration ordering, guidance, or completed-plan evidence.
- Audit the exact diff, generated Android/Gradle artifacts, native/dependency
  drift, credentials, conflict markers, file modes, and whitespace before
  commit.

## References

- Android `HttpsURLConnection` documents per-instance `SSLSocketFactory` and
  default hostname verification behavior:
  https://developer.android.com/reference/javax/net/ssl/HttpsURLConnection
- Android platform HTTPS source wraps the connected raw socket with
  `createSocket(Socket, host, port, true)` before hostname verification:
  https://android.googlesource.com/platform/libcore/+/android-4.0.3_r1.1/luni/src/main/java/libcore/net/http/HttpConnection.java
