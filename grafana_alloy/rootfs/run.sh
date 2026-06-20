#!/usr/bin/env bashio
# ==============================================================================
# Runs Grafana Alloy with the vendored alloy-resources HassOS scenario.
# Add-on options are mapped to the environment variables the scenario reads
# (see /alloy-resources/scenarios/hassos/*.alloy).
# ==============================================================================

export METRICS_PRIMARY_URL="$(bashio::config 'metrics_url')"
export METRICS_PRIMARY_ORG="$(bashio::config 'metrics_tenant')"
export LOGS_PRIMARY_URL="$(bashio::config 'logs_url')"
export LOGS_PRIMARY_ORG="$(bashio::config 'logs_tenant')"
export CLUSTER_NAME="$(bashio::config 'cluster_name')"
export ENV="$(bashio::config 'env')"
export REGION="$(bashio::config 'region')"

if bashio::config.is_empty 'metrics_url' && bashio::config.is_empty 'logs_url'; then
    bashio::log.warning "Neither metrics_url nor logs_url is set — Alloy will run but export nowhere."
fi

bashio::log.info "Starting Grafana Alloy (HassOS scenario)"
bashio::log.info "  metrics -> ${METRICS_PRIMARY_URL:-<unset>} (tenant: ${METRICS_PRIMARY_ORG:-none})"
bashio::log.info "  logs    -> ${LOGS_PRIMARY_URL:-<unset>} (tenant: ${LOGS_PRIMARY_ORG:-none})"

exec /usr/local/bin/alloy run \
    --server.http.listen-addr=0.0.0.0:12345 \
    --disable-reporting \
    --storage.path=/data \
    /alloy-resources/scenarios/hassos
