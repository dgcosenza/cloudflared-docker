# syntax=docker/dockerfile:1.7

ARG GO_VERSION=1.27.4
ARG DEBIAN_BASE=debian:trixie-slim
ARG CLOUDFLARED_VERSION=2026.11.2

# ---- Stage 1: build cloudflared and healthcheck binary from official source ----
FROM golang:${GO_VERSION}-trixie AS builder

ARG CLOUDFLARED_VERSION
ARG BUILD_DATE=unknown

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y --no-install-recommends ca-certificates git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Fetch exact official release tag from cloudflare/cloudflared
RUN git clone --depth 1 --branch "${CLOUDFLARED_VERSION}" \
      https://github.com/cloudflare/cloudflared.git /src/cloudflared

WORKDIR /src/cloudflared

# Build static cloudflared binary with official container metrics runtime flags.
# GOTOOLCHAIN=local ensures the patched builder Go toolchain is always used.
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    GOTOOLCHAIN=local \
    GOFIPS140=off \
    CONTAINER_BUILD=1

RUN go mod download \
    && go build -trimpath -mod=readonly \
      -ldflags="-s -w -X 'main.Version=${CLOUDFLARED_VERSION}' -X 'main.BuildTime=${BUILD_DATE}' -X 'github.com/cloudflare/cloudflared/metrics.Runtime=virtual'" \
      -o /out/cloudflared \
      ./cmd/cloudflared

# Build tiny dependency-free HTTP healthcheck helper
COPY healthcheck/ /src/healthcheck/
WORKDIR /src/healthcheck
RUN go build -trimpath -ldflags="-s -w" -o /out/cloudflared-healthcheck ./main.go

# ---- Stage 2: hardened Debian 13 (trixie-slim) runtime ----
FROM ${DEBIAN_BASE} AS runtime

ARG CLOUDFLARED_VERSION
ARG GO_VERSION
ARG BUILD_DATE=unknown
ARG IMAGE_REVISION=""
ARG IMAGE_SOURCE="https://github.com/dgcosenza/cloudflared-docker"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y --no-install-recommends ca-certificates tini tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd --gid 65532 nonroot \
    && useradd --uid 65532 --gid 65532 --create-home --home-dir /home/nonroot \
       --shell /usr/sbin/nologin --comment 'Cloudflared non-root user' nonroot \
    && install -d -m 0750 -o 65532 -g 65532 /etc/cloudflared

COPY --from=builder --chown=0:0 /out/cloudflared /usr/local/bin/cloudflared
COPY --from=builder --chown=0:0 /out/cloudflared-healthcheck /usr/local/bin/cloudflared-healthcheck
RUN chmod 0755 /usr/local/bin/cloudflared /usr/local/bin/cloudflared-healthcheck

ENV NO_AUTOUPDATE=true \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    TZ=Etc/UTC

WORKDIR /home/nonroot
USER 65532:65532

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD ["/usr/local/bin/cloudflared-healthcheck"]

ENTRYPOINT ["/usr/bin/tini", "--", "cloudflared"]
CMD ["version"]

LABEL org.opencontainers.image.title="Cloudflared (Debian 13)" \
      org.opencontainers.image.description="Source-built Cloudflare Tunnel (cloudflared) container image on Debian 13 (trixie-slim), maintained by Daniel G. Cosenza from FNX Labs." \
      org.opencontainers.image.url="https://hub.docker.com/r/dgcosenza/cloudflared" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.documentation="${IMAGE_SOURCE}#readme" \
      org.opencontainers.image.version="${CLOUDFLARED_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.vendor="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.authors="Daniel G. Cosenza from FNX Labs" \
      org.opencontainers.image.base.name="debian:trixie-slim" \
      io.github.dgcosenza.cloudflared.upstream_repo="https://github.com/cloudflare/cloudflared" \
      io.github.dgcosenza.cloudflared.upstream_version="${CLOUDFLARED_VERSION}" \
      io.github.dgcosenza.cloudflared.go_version="${GO_VERSION}"
