#!/usr/bin/env bash
# Safe launcher for lavish-axi: pinned version, telemetry off, hard egress gate.
# Never global-installs and never enables session hooks.
# Per-doc isolation: own state dir + own port, so concurrent sessions never share
# one server/state.json/port (lavish defaults to ~/.lavish-axi + :4387 globally).
set -euo pipefail

VER="0.1.31"
export LAVISH_AXI_TELEMETRY=0

cmd="${1:-}"; file="${2:-}"
[ -z "$cmd" ] || [ -z "$file" ] && { echo "usage: lavish-safe.sh {start|poll|stop} <file> [--agent-reply <msg>]" >&2; exit 2; }

abs="$(node -e 'console.log(require("path").resolve(process.argv[1]))' "$file" 2>/dev/null || printf '%s' "$file")"
key="$(printf '%s' "$abs" | LC_ALL=C shasum -a 256 | cut -c1-16)"
export LAVISH_AXI_STATE_DIR="${TMPDIR:-/tmp}/lavish-$key"
mkdir -p "$LAVISH_AXI_STATE_DIR"
portfile="$LAVISH_AXI_STATE_DIR/port"

pick_port() { node -e 'const s=require("net").createServer();s.listen(0,"127.0.0.1",()=>{const p=s.address().port;s.close(()=>console.log(p))})'; }

[ "$cmd" = "start" ] && [ ! -f "$portfile" ] && pick_port > "$portfile"
[ -f "$portfile" ] || { echo "no server for this doc (run start first)" >&2; exit 1; }
export LAVISH_AXI_PORT="$(cat "$portfile")"

server_pid() { pgrep -f "cli\.mjs server --port ${LAVISH_AXI_PORT}\$" | head -1; }

# Abort + kill if the server holds any non-loopback established connection.
verify_loopback() {
  local pid="$1"
  if lsof -nP -iTCP -a -p "$pid" 2>/dev/null | grep ESTABLISHED \
       | grep -vqE '127\.0\.0\.1|\[::1\]'; then
    echo "EGRESS DETECTED on pid $pid — killing and aborting. Do not trust this build." >&2
    lsof -nP -iTCP -a -p "$pid" 2>/dev/null | grep ESTABLISHED | grep -vE '127\.0\.0\.1|\[::1\]' >&2
    kill "$pid" 2>/dev/null || true
    exit 3
  fi
}

case "$cmd" in
  start)
    [ -f "$file" ] || { echo "no such file: $file" >&2; exit 2; }
    url="http://127.0.0.1:${LAVISH_AXI_PORT}/session/${key}"
    if [ -n "$(server_pid)" ]; then
      echo "already running pid=$(server_pid) port=$LAVISH_AXI_PORT (reusing, no new tab)"
      echo "url=$url"
      exit 0
    fi
    # LAVISH_AXI_NO_OPEN: lavish opens a browser itself; suppress it so only the wrapper opens one tab.
    LAVISH_AXI_NO_OPEN=1 LAVISH_AXI_IDLE_TIMEOUT_MS=3600000 npx -y "lavish-axi@$VER" "$file" >/dev/null 2>&1 &
    for _ in 1 2 3 4 5 6 7 8; do sleep 1; [ -n "$(server_pid)" ] && break; done
    pid="$(server_pid)"
    [ -z "$pid" ] && { echo "lavish did not start" >&2; exit 1; }
    sleep 3
    verify_loopback "$pid"
    echo "ok pid=$pid port=$LAVISH_AXI_PORT (telemetry off, loopback only, isolated state)"
    echo "url=$url"
    command -v open >/dev/null 2>&1 && open "$url" >/dev/null 2>&1 || true
    ;;
  poll)
    shift 2 || true
    npx -y "lavish-axi@$VER" poll "$file" "$@"
    ;;
  stop)
    pid="$(server_pid)"; [ -n "$pid" ] && kill "$pid" 2>/dev/null && echo "stopped $pid" || echo "not running"
    rm -f "$portfile"
    ;;
  *) echo "unknown cmd: $cmd" >&2; exit 2 ;;
esac
