# Cloudflared — Hardened Debian 13 (trixie-slim) Image

[![Daily Cloudflared image](https://github.com/dgcosenza/cloudflared-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/cloudflared-docker/actions/workflows/daily.yml)
[![Packaging License: MIT](https://img.shields.io/badge/packaging-MIT-blue.svg)](https://github.com/dgcosenza/cloudflared-docker/blob/main/LICENSE)
[![Upstream License: Apache-2.0](https://img.shields.io/badge/upstream-Apache--2.0-green.svg)](https://github.com/cloudflare/cloudflared/blob/master/LICENSE)
[![Signed with Cosign](https://img.shields.io/badge/signed-cosign%20OIDC-blueviolet.svg)](#supply-chain-verification)
[![SLSA Level 3](https://img.shields.io/badge/SLSA-Level%203-brightgreen.svg)](#supply-chain-verification)
[![Architectures](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-informational.svg)](#supported-architectures)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/dgcosenza/cloudflared-docker/badge)](https://scorecard.dev/viewer/?uri=github.com/dgcosenza/cloudflared-docker)
[![Docker Pulls](https://img.shields.io/docker/pulls/dgcosenza/cloudflared)](https://hub.docker.com/r/dgcosenza/cloudflared)
[![Docker Image Size](https://img.shields.io/docker/image-size/dgcosenza/cloudflared/latest)](https://hub.docker.com/r/dgcosenza/cloudflared)
[![Latest Release](https://img.shields.io/github/v/release/dgcosenza/cloudflared-docker?label=version)](https://github.com/dgcosenza/cloudflared-docker/releases)

A source-built, multi-arch, rootless container image for **Cloudflare Tunnel (`cloudflared`)** on **Debian 13 (`trixie-slim`)**, maintained by **Daniel G. Cosenza from FNX Labs**.

- **Docker Hub:** [`dgcosenza/cloudflared`](https://hub.docker.com/r/dgcosenza/cloudflared)
- **GitHub Container Registry (GHCR):** [`ghcr.io/dgcosenza/cloudflared`](https://github.com/dgcosenza/cloudflared-docker/pkgs/container/cloudflared) (identical signed multi-arch digest)
- **Source Repository:** [`dgcosenza/cloudflared-docker`](https://github.com/dgcosenza/cloudflared-docker)
- **Upstream Application:** [`cloudflare/cloudflared`](https://github.com/cloudflare/cloudflared) (`Apache-2.0`)

---

## Overview

`dgcosenza/cloudflared` compiles the official [`cloudflare/cloudflared`](https://github.com/cloudflare/cloudflared) release from source using the latest Go toolchain (`CGO_ENABLED=0`, `CONTAINER_BUILD=1`) and packages it into a minimal, fully upgraded **Debian 13 (`trixie-slim`)** runtime for both `linux/amd64` and `linux/arm64`:

- **Drop-in replacement for `cloudflare/cloudflared`:** Preserves UID/GID `65532:65532` (`nonroot`), `/home/nonroot`, `/etc/cloudflared`, `NO_AUTOUPDATE=true`, and the `cloudflared` CLI entrypoint (wrapped with `tini` as PID 1).
- **Rootless & read-only rootfs ready:** Verified under `--read-only --cap-drop ALL --security-opt no-new-privileges:true`.
- **Zero-dependency built-in healthcheck:** Ships `/usr/local/bin/cloudflared-healthcheck` (a tiny static Go binary) probing `http://127.0.0.1:2000/ready` by default — eliminating the need to bind-mount host `busybox`, `curl`, or `wget` just to check tunnel readiness.
- **Hardened supply chain:** Hadolint + Gitleaks preflight, native multi-arch smoke tests, Dive layer-efficiency gate (`>= 95%`), Syft SPDX + CycloneDX SBOMs, Trivy + Grype (SBOM) zero-fixable High/Critical gates, Cosign keyless OIDC signatures & SBOM attestations, SLSA Build L3 provenance, dual-registry publishing, and signed GitHub Releases.

---

## Current Versions

<!-- versions:start -->
| Component | Resolved Version |
| --- | --- |
| cloudflared | `2026.11.2` |
| Go toolchain | `1.27.4` |
| Base OS | `Debian 13.8 (trixie-slim)` |
| Architectures | `linux/amd64, linux/arm64` |
| Uncompressed size (per arch) | `amd64: 45.4 MB, arm64: 139.4 MB` |
| Last verified build (UTC) | `2026-11-26` |
| Published multi-arch digest | `dgcosenza/cloudflared@sha256:6e4eea1d6eefc7f078ab98d9c0404facf6a90ecb99ca8b828377d6d4e752a22d` |
| GHCR mirror | `ghcr.io/dgcosenza/cloudflared@sha256:6e4eea1d6eefc7f078ab98d9c0404facf6a90ecb99ca8b828377d6d4e752a22d` |
| Supply chain | Cosign OIDC signed + SPDX & CycloneDX SBOM attestations + SLSA Build L3 provenance |
| Security gate (Trivy + Grype on SBOM) | **0 fixable findings of any severity** (13 upstream-unfixed) |
<!-- versions:end -->

---

## Supported Tags & Tag Policy

Identical multi-arch OCI digests are published to **Docker Hub** (`dgcosenza/cloudflared`) and **GHCR** (`ghcr.io/dgcosenza/cloudflared`), accompanied by an automated signed [GitHub Release](https://github.com/dgcosenza/cloudflared-docker/releases):

| Tag | Policy | Description |
| --- | --- | --- |
| `<version>-<YYYYMMDD>` (e.g. `2026.11.2-20261125`) | **Immutable** | Date-stamped daily rebuild pinning the `cloudflared` release and UTC build date. |
| `sha-<short>` | **Immutable** | Packaging repository Git commit tag. |
| `<version>` (e.g. `2026.11.2`) | Moving | Latest verified Debian 13 security rebuild of that `cloudflared` release. |
| `latest` | Moving | Latest verified build tracking the newest official `cloudflared` release. |

**Production pinning:** Pin by immutable registry digest rather than an unpinned moving tag:

```yaml
image: dgcosenza/cloudflared:latest@sha256:<digest>
# or via GitHub Container Registry (identical digest):
image: ghcr.io/dgcosenza/cloudflared:latest@sha256:<digest>
```

---

## Supported Architectures

| Architecture | Status | Verification |
| --- | --- | --- |
| `linux/amd64` | **Published & natively tested** | Built, smoke-tested (`--read-only`, `--cap-drop ALL`), Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed on native x86_64 CI runners. |
| `linux/arm64` | **Published & natively tested** | Built, smoke-tested (`--read-only`, `--cap-drop ALL`), Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed on native ARM64 CI runners. |

---

## Quick Start

### `docker run` (hardened, rootless, read-only)

```bash
docker run -d \
  --name cloudflared \
  --restart unless-stopped \
  --read-only \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  --tmpfs /tmp:noexec,nosuid,size=16m \
  -e TZ=Etc/UTC \
  -e TUNNEL_TOKEN="replace-with-your-tunnel-token" \
  dgcosenza/cloudflared:latest \
  tunnel --protocol http2 --metrics 127.0.0.1:2000 run
```

### Hardened Docker Compose

See [`docker-compose.example.yml`](https://github.com/dgcosenza/cloudflared-docker/blob/main/docker-compose.example.yml):

```yaml
services:
  cloudflared:
    image: dgcosenza/cloudflared:latest
    container_name: cloudflared
    restart: unless-stopped
    read_only: true
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    tmpfs:
      - /tmp:noexec,nosuid,size=16m
    command: tunnel --protocol http2 --metrics 127.0.0.1:2000 run
    environment:
      - TZ=Etc/UTC
      - TUNNEL_TOKEN=${TUNNEL_TOKEN}
    volumes:
      - ./tunnel:/etc/cloudflared:ro
    healthcheck:
      test: ["CMD", "/usr/local/bin/cloudflared-healthcheck"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
```

---

## Configuration

### Environment Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `TUNNEL_TOKEN` | Yes* | *(unset)* | Cloudflare Tunnel token for remotely managed tunnels (`tunnel run`). Keep in a restricted `.env` file or secret store. |
| `NO_AUTOUPDATE` | No | `true` | Disables in-container self-updates (containers should be updated by pulling a new verified digest). |
| `TZ` | No | `Etc/UTC` | Container timezone (any valid IANA timezone). |
| `SSL_CERT_FILE` | No | `/etc/ssl/certs/ca-certificates.crt` | Path to the system CA certificate bundle. |
| `CLOUDFLARED_HEALTHCHECK_URL` | No | `http://127.0.0.1:2000/ready` | Endpoint probed by `/usr/local/bin/cloudflared-healthcheck`. Match `--metrics` if you change the metrics port. |

*\*Either `TUNNEL_TOKEN` or a credentials/config file mounted under `/etc/cloudflared` is required to run a tunnel.*

### Volumes, Ports, and UID/GID

| Path / Port | Mode / Owner | Purpose |
| --- | --- | --- |
| `/etc/cloudflared` | `65532:65532` (`nonroot`) | Optional mount for locally managed `config.yml` and tunnel credentials JSON (mount `:ro` when using `TUNNEL_TOKEN`). |
| `127.0.0.1:2000` (internal) | Container loopback | Metrics and `/ready` readiness endpoint when `--metrics 127.0.0.1:2000` is passed. |

The container runs as non-root **UID/GID `65532:65532`** (`nonroot`) and is verified with `read_only: true`, `cap_drop: [ALL]`, and `no-new-privileges:true`.

---

## Healthcheck

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD ["/usr/local/bin/cloudflared-healthcheck"]
```

`/usr/local/bin/cloudflared-healthcheck` sends an HTTP `GET` to `$CLOUDFLARED_HEALTHCHECK_URL` (default `http://127.0.0.1:2000/ready`, 5 s timeout) and exits `0` only on HTTP `200`. Enable `--metrics 127.0.0.1:2000` in your `command` so the readiness endpoint is active.

---

## Upgrading and Migrating from `cloudflare/cloudflared`

This image is a drop-in replacement for `cloudflare/cloudflared`:

1. Keep your existing `TUNNEL_TOKEN`, `command`, `/etc/cloudflared` volume, and `no-new-privileges:true`.
2. Replace `image: cloudflare/cloudflared:...` with `image: dgcosenza/cloudflared:latest@sha256:<digest>` (or `ghcr.io/dgcosenza/cloudflared:latest@sha256:<digest>`).
3. Optionally enable `read_only: true` and `cap_drop: [ALL]`, remove any host `/bin/busybox:/busybox:ro` workaround mount, and switch the healthcheck to `["CMD", "/usr/local/bin/cloudflared-healthcheck"]`.
4. Recreate the container (`docker compose up -d cloudflared`) and verify `docker inspect cloudflared --format '{{.State.Health.Status}}'` reports `healthy`.

---

## Supply-Chain Verification

Every published digest (multi-arch index and per-architecture manifests) on both Docker Hub and GHCR is keyless-signed with **Sigstore Cosign** (GitHub OIDC), attested with **SPDX** and **CycloneDX** SBOMs, and backed by **SLSA Build L3** provenance (`actions/attest-build-provenance`).

### Verify image signature with Cosign

```bash
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/cloudflared-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/cloudflared:latest

# Or against Docker Hub (identical digest):
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/cloudflared-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  dgcosenza/cloudflared:latest
```

### Verify SPDX / CycloneDX SBOM attestations

```bash
cosign verify-attestation \
  --type spdxjson \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/cloudflared-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/cloudflared@sha256:<arch-digest>
```

### Verify SLSA Build Provenance

```bash
gh attestation verify oci://ghcr.io/dgcosenza/cloudflared:latest --owner dgcosenza
```

---

## Security

- **Preflight gates:** Every push and PR runs **Hadolint** (blocking on warning+), **Gitleaks** secret scanning across git history, and **public-content/attribution** checks.
- **Vulnerability scan policy (all severities with a fix):** Every build generates **SPDX** and **CycloneDX** SBOMs with **Syft** per architecture, scans with **Trivy** (table, JSON, SARIF upload to GitHub Code Scanning, and blocking `--ignore-unfixed` gate) and **Grype** scanning the generated SPDX SBOM (`--only-fixed`, severity cutoff `negligible`, blocking gate), and enforces a **Dive** efficiency gate (`>= 95%`, `<= 5%` wasted space). Publication is blocked on any fixable finding of any severity.
- **Current status:** **0 fixable vulnerabilities of any severity** across Debian 13 OS packages and compiled Go modules. Any upstream-unfixed advisories (if present) are recorded in CI artifacts (`trivy-report-*`) and automatically cleared on daily rebuilds once fixes are published.
- **Dependency automation:** Renovate (`renovate.json`) pins base image digests and GitHub Action commit SHAs; Dependabot security alerts and OpenSSF Scorecard monitoring are enabled.
- See [`SECURITY.md`](https://github.com/dgcosenza/cloudflared-docker/blob/main/SECURITY.md) for reporting guidelines.

---

## Build Locally

```bash
git clone https://github.com/dgcosenza/cloudflared-docker.git
cd cloudflared-docker

docker buildx build \
  --platform linux/amd64 \
  --load \
  --build-arg BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --build-arg IMAGE_REVISION="$(git rev-parse HEAD)" \
  -t dgcosenza/cloudflared:local \
  .
```

| Build Arg | Default | Purpose |
| --- | --- | --- |
| `CLOUDFLARED_VERSION` | `2026.11.2` | Official `cloudflare/cloudflared` release tag (overridden daily by CI). |
| `GO_VERSION` | `1.27.4` | Go toolchain version label (overridden daily by CI). |
| `GO_BASE` | `golang:1.27.4-trixie@sha256:...` | Digest-pinned official Go builder image (refreshed daily by CI). |
| `DEBIAN_BASE` | `debian:trixie-slim@sha256:...` | Digest-pinned Debian 13 runtime base image (refreshed daily by CI). |
| `BUILD_DATE` | `unknown` | RFC 3339 UTC build timestamp. |
| `IMAGE_REVISION` | `""` | Packaging repository Git SHA. |
| `IMAGE_SOURCE` | `https://github.com/dgcosenza/cloudflared-docker` | Source URL for OCI labels. |

---

## Update Policy

[`.github/workflows/daily.yml`](https://github.com/dgcosenza/cloudflared-docker/blob/main/.github/workflows/daily.yml) runs automatically every day at **04:23 UTC**, on pushes to `main`, on pull requests (verification only, without pushing), and via `workflow_dispatch`. Every scheduled run executes a hardened automated pipeline:

1. **Preflight & upstream check:** Runs public-content checks, **Hadolint**, and **Gitleaks**; queries the latest official `cloudflare/cloudflared` release via the authenticated GitHub API, resolves the latest stable Go and `debian:trixie-slim` digests, diffs against `versions.json`, and emits `upstream-changes.md`.
2. **Multi-arch no-cache rebuild:** Builds natively on `linux/amd64` and `linux/arm64` runners with `--no-cache` on schedule, compiles `cloudflared` and `cloudflared-healthcheck` from source, and upgrades all Debian 13 packages (`apt-get update && apt-get -y upgrade`).
3. **Smoke, Dive & vulnerability gates:** Runs [`tests/smoke.sh`](https://github.com/dgcosenza/cloudflared-docker/blob/main/tests/smoke.sh) natively on both architectures (`--read-only --cap-drop ALL`), enforces the **Dive** efficiency gate (`>= 95%`), generates **Syft** SPDX + CycloneDX SBOMs per arch, and gates publication on **0 fixable findings of any severity** in both **Trivy** (SARIF + JSON + table) and **Grype** (scanning the SPDX SBOM).
4. **Dual-registry publish & supply-chain signing:** Assembles the multi-arch OCI manifest index on **GHCR** (`ghcr.io/dgcosenza/cloudflared`) and mirrors the identical digest to **Docker Hub** (`dgcosenza/cloudflared`) with tags `latest`, `<version>`, `<version>-<YYYYMMDD>`, and `sha-<short>`; signs every digest and attaches SPDX/CycloneDX SBOM attestations via **Cosign** keyless OIDC; emits **SLSA Build L3** provenance via `actions/attest-build-provenance`; and publishes a signed **GitHub Release** with checksums, Cosign bundle, and SBOMs.
5. **Automated documentation sync:** Commits updated `versions.json`, the README `Current Versions` block, and a dated `CHANGELOG.md` entry (upstream changes, resolved CVEs, sizes, and digest) via `github-actions[bot]` with `[skip ci]` when content changes, then syncs the Docker Hub repository overview and short description via `peter-evans/dockerhub-description`.
6. **Failure alerting:** If any job fails on `main` or a scheduled run, CI opens or updates a single GitHub issue labeled `ci-failure` with the failing job and run link, and automatically closes it on the next green run.

---

## Design Decisions

- **Debian 13 (`trixie-slim`) instead of distroless:** Provides daily Debian Security updates for CA certificates, `tzdata`, and `tini` alongside standard OCI package metadata while staying compact and scoring >95% efficiency in Dive.
- **Source build with patched Go toolchain:** Compiling `cloudflared` directly from official release tags with the latest Go `1.27.x` eliminates stale Go stdlib/module CVEs.
- **Static Go healthcheck binary:** Replaces external host `busybox` bind mounts with a self-contained, zero-dependency HTTP readiness probe inside the image.
- **Hadolint `DL3008` ignore:** Daily `--no-cache` security rebuilds intentionally pull the newest Debian 13 security updates via `apt-get` rather than pinning stale distro package versions.
- **Dive `highestUserWastedPercent: 0.18`:** Overall image efficiency remains strictly gated at `>= 95%` (measured ~97.8%). Because daily `apt-get -y upgrade` and `debconf` updates on `debian:trixie-slim` legitimately replace ~5 MB of base-layer files against a compact ~38 MB user layer (~13.5% of user bytes), `highestUserWastedPercent` is tuned to `0.18` rather than squashing away shared Debian base layers.

---

## License

This repository follows a clear packaging-vs-upstream license split:

- **Container packaging, healthcheck helper, CI workflows, scripts, and documentation (`packaging: MIT`):** Licensed under the [MIT License](https://github.com/dgcosenza/cloudflared-docker/blob/main/LICENSE) — copyright **Daniel G. Cosenza from FNX Labs**.
- **Bundled upstream software — Cloudflare Tunnel (`upstream: Apache-2.0`):** Copyright Cloudflare, Inc. and contributors — licensed under the [Apache License 2.0](https://github.com/cloudflare/cloudflared/blob/master/LICENSE).

Full third-party notices are maintained in [`THIRD-PARTY-NOTICES.md`](https://github.com/dgcosenza/cloudflared-docker/blob/main/THIRD-PARTY-NOTICES.md). Release history is maintained in [`CHANGELOG.md`](https://github.com/dgcosenza/cloudflared-docker/blob/main/CHANGELOG.md).
