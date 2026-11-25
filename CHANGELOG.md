# Changelog

All notable changes to the `dgcosenza/cloudflared` Debian 13 container packaging and CI workflows are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Maintained by **Daniel G. Cosenza from FNX Labs**.

---
<!-- changelog:auto -->

## [2026.11.2] — 2026-11-25

### Automated Daily Build
- Verified components: cloudflared `2026.11.2`, Go toolchain `1.27.4`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64, linux/arm64` (native smoke tests + Dive efficiency gate).
- Upstream status: no new upstream release since previous build; refreshed base OS and dependencies.
- Vulnerability gate: **0 fixable Critical/High** in Trivy and Grype (SBOM scan) (13 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/cloudflared@sha256:cf17dcdb30bc9eced733cc54cf43b5614b491fad9f23b9aba5873bbad8f3d8b1` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
---

## [2026.11.2] — 2026-11-24

### Added
- Initial source-built **Debian 13 (`trixie-slim`)** image for Cloudflare Tunnel (`cloudflared` `2026.11.2`), compiled with Go `1.27.4` (`CGO_ENABLED=0`, `CONTAINER_BUILD=1`).
- Built-in static Go healthcheck binary (`/usr/local/bin/cloudflared-healthcheck`) probing `http://127.0.0.1:2000/ready` by default, removing the need for external `busybox`/`curl` mounts.
- Non-root UID/GID `65532:65532` runtime with `tini` as PID 1, `NO_AUTOUPDATE=true`, and full drop-in compatibility with `cloudflare/cloudflared`.
- Seven-step automated daily CI pipeline (`.github/workflows/daily.yml`) with Trivy and Grype fixable Critical/High blocking gates, Syft SPDX SBOM, smoke test (`tests/smoke.sh`), automated docs/Hub sync, and `ci-failure` issue alerting.
