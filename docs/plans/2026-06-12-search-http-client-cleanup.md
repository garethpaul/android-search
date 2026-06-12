# Android Search HTTP Client Cleanup

Status: Completed

## Context

Each search creates a legacy `DefaultHttpClient`, but the request task never
shuts down its connection manager. Repeated success, protocol, I/O, parse, or
cancellation paths can retain sockets and pooled resources beyond the request
lifetime.

## Changes

- Wrap request execution in a `try/finally` cleanup boundary.
- Shut down the HTTP connection manager for every created client.
- Preserve existing response parsing and user-facing fallback results.
- Extend the SDK-free baseline and README with the cleanup contract.
- Keep the change independent from the open explicit-failure-handling PR.

## Verification

- `make check`
- Static mutation that removes the connection-manager shutdown
- `git diff --check`

The Android SDK and remote backend are unavailable on this host, so live socket
cleanup still requires verification with a compatible Android toolchain.
