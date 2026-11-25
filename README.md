# Cloudflared — Hardened Debian 13 (trixie-slim) Image

[![Daily Cloudflared image](https://github.com/dgcosenza/cloudflared-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/cloudflared-docker/actions/workflows/daily.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/dgcosenza/cloudflared)](https://hub.docker.com/r/dgcosenza/cloudflared)
[![Docker Image Size](https://img.shields.io/docker/image-size/dgcosenza/cloudflared/latest)](https://hub.docker.com/r/dgcosenza/cloudflared)

A source-built, non-root container image for **Cloudflare Tunnel (`cloudflared`)** on **Debian 13 (`trixie-slim`)**, maintained by **Daniel G. Cosenza from FNX Labs**.

- **Docker Hub:** [`dgcosenza/cloudflared`](https://hub.docker.com/r/dgcosenza/cloudflared)
- **Source Repository:** [`dgcosenza/cloudflared-docker`](https://github.com/dgcosenza/cloudflared-docker)
- **Upstream Application:** [`cloudflare/cloudflared`](https://github.com/cloudflare/cloudflared) (Apache License 2.0)
- **Packaging License:** MIT (see [`LICENSE`](https://github.com/dgcosenza/cloudflared-docker/blob/main/LICENSE) and [`THIRD-PARTY-NOTICES.md`](https://github.com/dgcosenza/cloudflared-docker/blob/main/THIRD-PARTY-NOTICES.md))

---

## Overview

`dgcosenza/cloudflared` compiles the official [`cloudflare/cloudflared`](https://github.com/cloudflare/cloudflared) release from source using the latest Go toolchain (`CGO_ENABLED=0`, `CONTAINER_BUILD=1`) and packages it into a minimal, fully upgraded **Debian 13 (`trixie-slim`)** runtime:

- **Drop-in replacement for `cloudflare/cloudflared`:** Preserves UID/GID `65532:65532` (`nonroot`), `/home/nonroot`, `/etc/cloudflared`, `NO_AUTOUPDATE=true`, and the `cloudflared` CLI entrypoint (wrapped with `tini` as PID 1).
- **Zero-dependency built-in healthcheck:** Ships `/usr/local/bin/cloudflared-healthcheck` (a tiny static Go binary) probing `http://127.0.0.1:2000/ready` by default — eliminating the need to bind-mount host `busybox`, `curl`, or `wget` just to check tunnel readiness.
- **Daily CVE-gated rebuilds:** Rebuilds daily with `--no-cache`, upgrades all Debian 13 packages and CA certificates, tracks the latest official `cloudflared` release and Go toolchain, and refuses publication on any fixable `CRITICAL` or `HIGH` finding in Trivy or Grype.

---

## Current Versions

<!-- versions:start -->
| Component | Resolved Version |
| --- | --- |
| cloudflared | `2026.11.2` |
| Go toolchain | `1.27.4` |
| Base OS | `Debian 13.8 (trixie-slim)` |
| Last verified build (UTC) | `2026-11-25` |
| Security gate (Trivy + Grype) | **0 fixable Critical/High** (13 upstream-unfixed) |
<!-- versions:end -->

---

## Supported Tags

| Tag | Policy | Description |
| --- | --- | --- |
| `<version>-<YYYYMMDD>` (e.g. `2026.11.2-20261124`) | **Immutable** | Date-stamped daily rebuild pinning the `cloudflared` release and UTC build date. |
| `sha-<short>` | **Immutable** | Packaging repository Git commit tag. |
| `<version>` (e.g. `2026.11.2`) | Moving | Latest verified Debian 13 security rebuild of that `cloudflared` release. |
| `latest` | Moving | Latest verified build tracking the newest official `cloudflared` release. |

**Production pinning:** Pin by registry digest rather than an unpinned moving tag:

```yaml
image: dgcosenza/cloudflared:latest@sha256:<digest>
```

---

## Supported Architectures

| Architecture | Status | Notes |
| --- | --- | --- |
| `linux/amd64` | **Published & tested** | Built, smoke-tested, scanned with Trivy and Grype, and published to Docker Hub (`dgcosenza/cloudflared`). |

---

## Quick Start

### `docker run` (token-managed tunnel)

```bash
docker run -d \
  --name cloudflared \
  --restart unless-stopped \
  --security-opt no-new-privileges:true \
  -e TZ=Etc/UTC \
  -e TUNNEL_TOKEN="replace-with-your-tunnel-token" \
  dgcosenza/cloudflared:latest \
  tunnel --protocol http2 --metrics 127.0.0.1:2000 run
```

### Docker Compose

See [`docker-compose.example.yml`](https://github.com/dgcosenza/cloudflared-docker/blob/main/docker-compose.example.yml):

```yaml
services:
  cloudflared:
    image: dgcosenza/cloudflared:latest
    container_name: cloudflared
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    command: tunnel --protocol http2 --metrics 127.0.0.1:2000 run
    environment:
      - TZ=Etc/UTC
      - TUNNEL_TOKEN=${TUNNEL_TOKEN}
    volumes:
      - ./tunnel:/etc/cloudflared
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
| `/etc/cloudflared` | `65532:65532` (`nonroot`) | Optional mount for locally managed `config.yml` and tunnel credentials JSON. |
| `127.0.0.1:2000` (internal) | Container loopback | Metrics and `/ready` readiness endpoint when `--metrics 127.0.0.1:2000` is passed. |

The container runs as non-root **UID/GID `65532:65532`** (`nonroot`) and is fully compatible with `security_opt: no-new-privileges:true`. No inbound ports need to be published on the host for standard outbound tunnels.

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
2. Replace `image: cloudflare/cloudflared:...` with `image: dgcosenza/cloudflared:latest@sha256:<digest>`.
3. Optionally remove any host `/bin/busybox:/busybox:ro` workaround mount and switch the healthcheck to `["CMD", "/usr/local/bin/cloudflared-healthcheck"]` (keeping the existing busybox mount also continues to work unchanged).
4. Recreate the container (`docker compose up -d cloudflared`) and verify `docker inspect cloudflared --format '{{.State.Health.Status}}'` reports `healthy`.

---

## Security

- **Vulnerability scan policy:** Every CI build runs **Trivy** (table, JSON, SARIF upload to GitHub Code Scanning, and blocking `--ignore-unfixed` gate) and **Grype** (`--only-fixed`, severity cutoff `high`, blocking gate), plus generates an **SPDX SBOM** (`sbom.spdx.json`) and build provenance artifact. Publication is blocked on any fixable `CRITICAL` or `HIGH` finding.
- **Current status:** **0 fixable Critical/High** vulnerabilities across Debian 13 OS packages and compiled Go modules. Any upstream-unfixed advisories (if present) are recorded in the `trivy-report` CI artifact and automatically cleared on daily rebuilds once fixes are published.
- **Non-root & minimal runtime:** Runs as `65532:65532` with `tini` as PID 1, no compilers, no `git`, and no `curl`/`wget` in the runtime layer.
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
| `GO_VERSION` | `1.27.4` | Official `golang:<ver>-trixie` builder image tag (overridden daily by CI). |
| `DEBIAN_BASE` | `debian:trixie-slim` | Base OS image. |
| `BUILD_DATE` | `unknown` | RFC 3339 UTC build timestamp. |
| `IMAGE_REVISION` | `""` | Packaging repository Git SHA. |
| `IMAGE_SOURCE` | `https://github.com/dgcosenza/cloudflared-docker` | Source URL for OCI labels. |

---

## Update Policy

[`.github/workflows/daily.yml`](https://github.com/dgcosenza/cloudflared-docker/blob/main/.github/workflows/daily.yml) runs automatically every day at **04:23 UTC**, on pushes to `main`, on pull requests (verification only, without pushing), and via `workflow_dispatch`. Every scheduled run executes a seven-step automated pipeline (gated by `.github/workflows/public-check.yml`):

1. **Upstream check:** Queries the latest official `cloudflare/cloudflared` release via the authenticated GitHub API, resolves the latest stable Go release on Debian 13 (`trixie`) and the `debian:trixie-slim` digest, diffs against `versions.json`, and emits `upstream-changes.md`.
2. **No-cache rebuild:** Rebuilds `linux/amd64` with `--no-cache` on schedule, compiles `cloudflared` and `cloudflared-healthcheck` from source, upgrades all Debian 13 packages (`apt-get update && apt-get -y upgrade`), and emits an **SPDX SBOM** (`sbom.spdx.json`) and build provenance artifact.
3. **Vulnerability fix and gate:** Runs **Trivy** (table, JSON, SARIF upload, blocking `--ignore-unfixed` gate) and **Grype** (blocking `--only-fixed` gate, severity cutoff `high`), diffs findings against the previous scan to record resolved CVEs, and retains reports for 90 days.
4. **Smoke test:** Runs [`tests/smoke.sh`](https://github.com/dgcosenza/cloudflared-docker/blob/main/tests/smoke.sh) to verify release version output, non-root UID/GID `65532`, `tini` as PID 1, `NO_AUTOUPDATE=true`, live metrics HTTP 200 via `cloudflared-healthcheck`, and a negative closed-port healthcheck test.
5. **Publish:** On non-PR builds when Docker Hub secrets are configured, pushes `latest`, `<version>`, `<version>-<YYYYMMDD>`, and `sha-<short>` tags to Docker Hub and records the immutable digest.
6. **Automated documentation sync:** Commits updated `versions.json`, the README `Current Versions` block, and a dated `CHANGELOG.md` entry (upstream changes, resolved CVEs, and digest) via `github-actions[bot]` with `[skip ci]` when content changes, then syncs the Docker Hub repository overview and short description via `peter-evans/dockerhub-description`.
7. **Failure alerting:** If any step fails on `main` or a scheduled run, CI opens or updates a single GitHub issue labeled `ci-failure` with the failing job and run link, and automatically closes it on the next green run.

---

## Design Decisions

- **Debian 13 (`trixie-slim`) instead of distroless:** Provides daily Debian Security updates for CA certificates, `tzdata`, and `tini` alongside predictable troubleshooting and standard OCI package metadata while staying compact (~60 MB).
- **Source build with patched Go toolchain:** Compiling `cloudflared` directly from official release tags with the latest Go `1.27.x` eliminates stale Go stdlib/module CVEs (such as `golang.org/x/net` vulnerabilities in older vendor-built images).
- **Static Go healthcheck binary:** Replaces external host `busybox` bind mounts with a self-contained, zero-dependency HTTP readiness probe inside the image.

---

## License and Credits

- **Container packaging, healthcheck helper, CI, and documentation:** [MIT License](https://github.com/dgcosenza/cloudflared-docker/blob/main/LICENSE) — maintained by **Daniel G. Cosenza from FNX Labs**.
- **Cloudflare Tunnel (`cloudflared`):** Copyright Cloudflare, Inc. — [Apache License 2.0](https://github.com/cloudflare/cloudflared/blob/master/LICENSE).
- Full third-party notices: [`THIRD-PARTY-NOTICES.md`](https://github.com/dgcosenza/cloudflared-docker/blob/main/THIRD-PARTY-NOTICES.md).
- Release history: [`CHANGELOG.md`](https://github.com/dgcosenza/cloudflared-docker/blob/main/CHANGELOG.md).
