#!/usr/bin/env bashio

cd /app || exit

# By default talk to Home Assistant through the Supervisor websocket proxy using
# the auto-provisioned token (homeassistant_api: true). Both can be overridden,
# e.g. to point at a remote instance with a long-lived token.
if bashio::config.has_value 'hass_url'; then
    HASS_URL="$(bashio::config 'hass_url')"
else
    HASS_URL="ws://supervisor/core/websocket"
fi

if bashio::config.has_value 'hass_token'; then
    HASS_TOKEN="$(bashio::config 'hass_token')"
else
    HASS_TOKEN="${SUPERVISOR_TOKEN}"
fi

export HASS_URL HASS_TOKEN PYTHONPATH=/app

args=(--web.listen-port 9145)
if bashio::config.true 'debug'; then
    args+=(--debug)
fi

bashio::log.info "Starting Home Assistant Exporter on :9145 (hass_url=${HASS_URL})"

exec /opt/venv/bin/python -m home_assistant_exporter "${args[@]}"
