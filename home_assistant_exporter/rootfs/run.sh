#!/usr/bin/env sh
# Translate Home Assistant add-on options (/data/options.json) into the
# HASS_URL / HASS_TOKEN environment the upstream exporter reads, then exec it.
# The upstream image is python:slim (no bashio), so options are parsed with python.
set -e

eval "$(python3 - <<'PY'
import json, shlex
try:
    o = json.load(open("/data/options.json"))
except Exception:
    o = {}
url = o.get("hass_url") or "ws://supervisor/core/websocket"
token = o.get("hass_token") or ""
debug = str(o.get("debug", False)).strip().lower() in ("true", "1", "yes")
print("HASS_URL=" + shlex.quote(url))
print("OPT_TOKEN=" + shlex.quote(token))
print("DEBUG=" + ("1" if debug else "0"))
PY
)"

if [ -n "$OPT_TOKEN" ]; then
    HASS_TOKEN="$OPT_TOKEN"
else
    HASS_TOKEN="${SUPERVISOR_TOKEN}"
fi
export HASS_URL HASS_TOKEN

set --
[ "$DEBUG" = "1" ] && set -- --debug

echo "[home_assistant_exporter] starting on :9878 (hass_url=${HASS_URL})"
exec python -m home_assistant_exporter "$@"
