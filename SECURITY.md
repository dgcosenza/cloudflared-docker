# Security Policy

Maintained by **Daniel G. Cosenza from FNX Labs**.

## Supported Versions

Only the latest daily build of `dgcosenza/cloudflared` built from the latest official `cloudflare/cloudflared` release on Debian 13 (`trixie-slim`) is actively maintained and receives automated security rebuilds.

## Automated Vulnerability Scanning

Every build in GitHub Actions is compiled from official upstream source with a current Go toolchain and scanned with both **Trivy** and **Grype**, plus an **SPDX SBOM** artifact:

- **Hard gate:** Builds fail and refuse publication if either Trivy (`--ignore-unfixed`) or Grype (`--only-fixed --fail-on negligible`, all severities) detects any **fixable vulnerability of any severity** in OS packages or Go modules.
- **Daily rebuilds:** Scheduled daily builds run with `--no-cache`, apply `apt-get update && apt-get -y upgrade`, and resolve the latest official `cloudflared` release and Go toolchain.
- **Unfixed advisories:** Advisories without an upstream vendor fix are recorded in CI artifacts (`trivy-report`) and cleared automatically once Debian Security or upstream releases a fix.

## Reporting a Vulnerability

- **Container packaging or CI issues:** Open a private security advisory via GitHub Security Advisories on [`dgcosenza/cloudflared-docker`](https://github.com/dgcosenza/cloudflared-docker/security/advisories/new).
- **Upstream `cloudflared` issues:** Report via Cloudflare's security program at [`cloudflare/cloudflared`](https://github.com/cloudflare/cloudflared/security/policy).
