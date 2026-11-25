#!/usr/bin/env bash
# Smoke test for dgcosenza/cloudflared: verifies non-root UID/GID 65532,
# tini PID 1, cloudflared version output, metrics HTTP probe, and negative healthcheck.
set -euo pipefail

IMAGE="${1:-dgcosenza/cloudflared:ci-candidate}"
NAME="cloudflared-ci-smoke-$$"

cleanup() {
  docker rm -f "$NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

# 1. Verify version output matches expected release format (not DEV)
VER_OUT="$(docker run --rm --security-opt no-new-privileges:true "$IMAGE" --version)"
echo "Version output: ${VER_OUT}"
printf '%s' "$VER_OUT" | grep -qE 'cloudflared version [0-9]{4}\.[0-9]+\.[0-9]+'

# 2. Verify non-root UID/GID 65532 and tini PID 1 with live proxy-dns + metrics server
docker run -d --name "$NAME" \
  --security-opt no-new-privileges:true \
  "$IMAGE" proxy-dns --address 127.0.0.1 --port 5053 --metrics 127.0.0.1:2000

UID_ACTUAL="$(docker exec "$NAME" id -u)"
GID_ACTUAL="$(docker exec "$NAME" id -g)"
test "$UID_ACTUAL" = "65532"
test "$GID_ACTUAL" = "65532"

PID1_COMM="$(docker exec "$NAME" cat /proc/1/comm)"
test "$PID1_COMM" = "tini"

# 3. Wait for metrics server to respond HTTP 200 using built-in healthcheck binary
READY=0
for _ in $(seq 1 20); do
  if docker exec -e CLOUDFLARED_HEALTHCHECK_URL="http://127.0.0.1:2000/metrics" "$NAME" /usr/local/bin/cloudflared-healthcheck; then
    READY=1
    break
  fi
  sleep 1
done
test "$READY" -eq 1

# 4. Negative test: healthcheck must fail against a closed port
if docker exec -e CLOUDFLARED_HEALTHCHECK_URL="http://127.0.0.1:59999/ready" "$NAME" /usr/local/bin/cloudflared-healthcheck 2>/dev/null; then
  echo "ERROR: healthcheck unexpectedly passed on closed port 59999" >&2
  exit 1
fi

# 5. Verify NO_AUTOUPDATE=true
NO_AUTO="$(docker exec "$NAME" printenv NO_AUTOUPDATE)"
test "$NO_AUTO" = "true"

echo "Smoke test passed (uid=${UID_ACTUAL}, gid=${GID_ACTUAL}, pid1=${PID1_COMM})."
