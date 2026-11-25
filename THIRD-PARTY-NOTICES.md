# Third-Party Notices

This container image packages open-source software maintained by third parties alongside Debian 13 container packaging by **Daniel G. Cosenza from FNX Labs**.

## Cloudflare Tunnel (`cloudflared`)
- **Project:** [`cloudflare/cloudflared`](https://github.com/cloudflare/cloudflared)
- **Copyright:** Cloudflare, Inc. and contributors
- **License:** Apache License 2.0 ([`LICENSE`](https://github.com/cloudflare/cloudflared/blob/master/LICENSE))

## Base Image & Runtime Components
- **Debian 13 (`trixie-slim`) packages (`ca-certificates`, `tzdata`, `tini`):** Distributed under their respective free software licenses recorded in `/usr/share/doc/*/copyright` inside the image.
- **Go standard library and module dependencies:** Distributed under their respective open-source licenses recorded in upstream `go.mod` / `go.sum`.
