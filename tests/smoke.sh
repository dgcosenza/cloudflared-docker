#!/usr/bin/env bash
# Smoke test for dgcosenza/cloudflared: verifies release version output,
# non-root UID/GID 65532, tini as PID 1, NO_AUTOUPDATE=true, CA bundle,
# and positive + negative HTTP healthcheck tests for cloudflared-healthcheck.
set -euo pipefail

IMAGE="${1:-dgcosenza/cloudflared:ci-candidate}"
NAME="cloudflared-ci-smoke-$$"
SRV_PID=""

cleanup() {
  [ -n "$SRV_PID" ] && kill "$SRV_PID" >/dev/null 2>&1 || true
  docker rm -f "$NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

# 1. Verify version output matches official release format (not DEV)
VER_OUT="$(docker run --rm --security-opt no-new-privileges:true "$IMAGE" --version)"
echo "Version output: ${VER_OUT}"
printf '%s' "$VER_OUT" | grep -qE 'cloudflared version [0-9]{4}\.[0-9]+\.[0-9]+'

# 2. Verify tunnel CLI subcommand works cleanly
docker run --rm --security-opt no-new-privileges:true "$IMAGE" tunnel --help >/dev/null

# 3. Verify non-root UID/GID 65532, tini PID 1, NO_AUTOUPDATE=true, and CA bundle
CHECK_OUT="$(docker run --rm --security-opt no-new-privileges:true \
  --entrypoint /usr/bin/tini "$IMAGE" -- /bin/sh -c '
    printf "uid=%s gid=%s pid1=%s noauto=%s ca=%s\n" \
      "$(id -u)" "$(id -g)" "$(cat /proc/1/comm)" "${NO_AUTOUPDATE:-}" "$(test -r /etc/ssl/certs/ca-certificates.crt && echo ok || echo missing)"
  ')"
echo "Runtime check: ${CHECK_OUT}"
printf '%s' "$CHECK_OUT" | grep -q 'uid=65532 gid=65532 pid1=tini noauto=true ca=ok'

# 4. Start a deterministic local HTTP responder on host loopback to verify
#    /usr/local/bin/cloudflared-healthcheck on 200 (pass), 503 (fail), and closed port (fail)
python3 - <<'PY' &
import http.server
import socketserver

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/ready":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"ok\n")
        else:
            self.send_response(503)
            self.end_headers()
            self.wfile.write(b"not ready\n")
    def log_message(self, format, *args):
        pass

socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("127.0.0.1", 18200), Handler) as httpd:
    httpd.serve_forever()
PY
SRV_PID=$!

for _ in $(seq 1 20); do
  if curl -fsS http://127.0.0.1:18200/ready >/dev/null 2>&1; then
    break
  fi
  sleep 0.25
done

# Positive test: HTTP 200 on /ready must exit 0
docker run --rm --network host --security-opt no-new-privileges:true \
  -e CLOUDFLARED_HEALTHCHECK_URL="http://127.0.0.1:18200/ready" \
  --entrypoint /usr/local/bin/cloudflared-healthcheck "$IMAGE"

# Negative test 1: HTTP 503 must fail non-zero
if docker run --rm --network host --security-opt no-new-privileges:true \
  -e CLOUDFLARED_HEALTHCHECK_URL="http://127.0.0.1:18200/notready" \
  --entrypoint /usr/local/bin/cloudflared-healthcheck "$IMAGE" 2>/dev/null; then
  echo "ERROR: healthcheck unexpectedly passed on HTTP 503" >&2
  exit 1
fi

# Negative test 2: closed port must fail non-zero
if docker run --rm --network host --security-opt no-new-privileges:true \
  -e CLOUDFLARED_HEALTHCHECK_URL="http://127.0.0.1:59999/ready" \
  --entrypoint /usr/local/bin/cloudflared-healthcheck "$IMAGE" 2>/dev/null; then
  echo "ERROR: healthcheck unexpectedly passed on closed port 59999" >&2
  exit 1
fi

echo "Smoke test passed (uid=65532, gid=65532, pid1=tini, healthcheck positive+negative ok)."
