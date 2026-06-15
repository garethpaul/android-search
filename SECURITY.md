# Security Policy

Search intents are trimmed and limited to 200 characters before URL encoding.

## Supported Versions

The supported security scope for `android-search` is the current default branch, `master`. Older commits, tags, branches, forks, demos, and generated artifacts are not actively supported unless the repository explicitly marks them as maintained.

Project summary: Android Instant Search

## Reporting a Vulnerability

Please report suspected vulnerabilities through GitHub's private vulnerability reporting or by opening a draft GitHub Security Advisory for `garethpaul/android-search` when that option is available. If GitHub does not show a private reporting option for this repository, contact the repository owner through GitHub and avoid posting exploit details publicly until the issue can be assessed.

Do not open a public issue that includes exploit code, secrets, personal data, or detailed reproduction steps for an unpatched vulnerability.

## What to Include

Helpful reports include:

- Image downloads bound compressed bodies and decoded pixel dimensions before allocation.

- the affected file, endpoint, permission, dependency, or workflow
- a concise impact statement explaining what an attacker could do
- reproduction steps using test data and accounts you control
- the branch, commit SHA, platform version, device, runtime, or dependency versions used
- logs, screenshots, or proof-of-concept snippets that demonstrate impact without exposing private data

## Project Security Posture

- This repository appears to be an Android mobile application or sample. The active security scope is the code and documentation on the default branch.
- Review found external API integrations or credential-adjacent configuration; changes in those areas should receive security-focused review before merge.
- Review found network clients, sockets, web APIs, or service endpoints; changes in those areas should receive security-focused review before merge.
- Review found mobile permission or privacy-sensitive data handling; changes in those areas should receive security-focused review before merge.
- Android app-data backup should stay disabled by default for the sample.
- Review found file, document, data, or media parsing flows; changes in those areas should receive security-focused review before merge.
- Dependency manifests detected: build.gradle, gradle.properties. Dependency updates should preserve lockfiles when present and avoid introducing packages without a clear maintenance reason.
- Pinned, read-only GitHub Actions runs the guarded `make check` baseline;
  review workflow, Gradle, and checker changes as part of the supply-chain
  surface.
- The baseline pins and verifies the wrapper JAR and Gradle distribution checksums.
  An uncached bootstrap still depends on Gradle's HTTPS service.
- Hosted checkout credentials are not persisted. Self-protecting CODEOWNERS
  assigns CI controls and privacy-sensitive application source to the repository
  owner; repository rules should require that approval.
- `check.yml` remains the only approved workflow until another workflow
  receives an explicit least-privilege security contract.
- Generic search failure logs preserve network and image error categories
  without exception messages, stacks, query-bearing URLs, or response details.
- Image downloads reject redirects and non-success responses before decoding.
- Backend-provided image URLs require HTTPS, a non-empty host, and no user-info credentials before connection setup.
- Search JSON requests reject redirects before response validation.
- Search JSON responses require successful 2xx status before entity access.
- Unexpected runtime exceptions become generic search failures while fatal JVM
  errors remain visible to the Android platform instead of being swallowed.
- Search JSON uses a 64 KiB response-body limit for declared and streamed
  content before parsing, while retaining privacy-safe failure handling.
- Search clients reject malformed UTF-8 search JSON before JSON parsing.
- Search JSON and image downloads reject missing or mismatched declared media
  types before reading response bytes.
- Search cancellation aborts the active JSON request and disconnects the active
  image transport so superseded tasks do not retain network resources.

## Mobile Privacy Notes

If this project requests device permissions such as location, camera, microphone, contacts, Bluetooth, health data, or local storage access, reports should describe the permission involved and whether sensitive data can be accessed, persisted, or transmitted unexpectedly. Please avoid testing against real third-party user data or accounts you do not control.

## Dependency and Supply Chain Security

The generated Gradle 8.14.5 bootstrap retains the legacy Gradle 2.2.1 runtime
required by Android Gradle Plugin 1.2.3. Review all four wrapper files together;
the SDK-free baseline rejects drift from published wrapper and distribution hashes.

Dependency updates should come from trusted package managers and should keep lockfiles in sync when lockfiles exist. Do not commit credentials, private keys, tokens, generated secrets, or machine-local configuration. If a vulnerability depends on a compromised package, typosquatting risk, insecure transitive dependency, or unsafe build step, include the package name, affected version, and the path through which it is used.

## Safe Research Guidelines

Good-faith research is welcome when it stays within these boundaries:

- use only accounts, devices, data, and infrastructure that you own or have explicit permission to test
- avoid destructive actions, persistence, spam, phishing, social engineering, or denial-of-service testing
- minimize access to personal data and stop testing immediately if private data is exposed
- do not exfiltrate secrets or third-party data; report the minimum evidence needed to verify impact
- keep vulnerability details confidential until the maintainer has assessed the report

## Maintainer Response

The maintainer will review complete reports as availability allows, prioritize issues by exploitability and impact, and coordinate a fix or mitigation when the affected code is still maintained. For sample, archived, or educational repositories, the likely remediation may be documentation, dependency updates, or clearly marking unsupported code rather than a production-style patch release.
