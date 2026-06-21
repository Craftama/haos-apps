#!/usr/bin/env bashio
# ==============================================================================
# Runs Grafana Alloy with the vendored alloy-resources HassOS scenario.
# Add-on options are mapped to the environment variables the scenario reads
# (see /alloy-resources/scenarios/hassos/*.alloy).
# ==============================================================================

# Trim leading/trailing whitespace so a stray space in an option (e.g. " http://...")
# does not produce an invalid URL/value.
trim() { local v="$1"; v="${v#"${v%%[![:space:]]*}"}"; v="${v%"${v##*[![:space:]]}"}"; printf '%s' "$v"; }

export METRICS_PRIMARY_URL="$(trim "$(bashio::config 'metrics_url')")"
export METRICS_PRIMARY_ORG="$(trim "$(bashio::config 'metrics_tenant')")"
export LOGS_PRIMARY_URL="$(trim "$(bashio::config 'logs_url')")"
export LOGS_PRIMARY_ORG="$(trim "$(bashio::config 'logs_tenant')")"
export CLUSTER_NAME="$(trim "$(bashio::config 'cluster_name')")"
export ENV="$(trim "$(bashio::config 'env')")"
export REGION="$(trim "$(bashio::config 'region')")"
export INSTANCE="$(trim "$(bashio::config 'instance')")"

if bashio::config.is_empty 'metrics_url' && bashio::config.is_empty 'logs_url'; then
    bashio::log.warning "Neither metrics_url nor logs_url is set — Alloy will run but export nowhere."
fi

# Assemble the active config from the enabled input pipelines (Alloy loads a
# directory, so "enabled" = copied into the working dir). base is always present.
readonly SRC=/alloy-resources/scenarios/hassos
readonly INPUTS=/alloy-resources/inputs
readonly WORK=/etc/alloy/config.d
mkdir -p "${WORK}"
rm -f "${WORK}"/*.alloy

cp "${SRC}/hassos-base.alloy" "${WORK}/"
bashio::config.true 'enable_unix'     && cp "${SRC}/hassos-metrics-unix.alloy" "${WORK}/"
bashio::config.true 'enable_process'  && cp "${SRC}/hassos-metrics-process.alloy" "${WORK}/"
bashio::config.true 'enable_journal'  && cp "${SRC}/hassos-logs-journal.alloy" "${WORK}/"
if bashio::config.true 'enable_docker'; then
    cp "${SRC}/hassos-metrics-docker.alloy" "${WORK}/"
    cp "${SRC}/hassos-logs-docker.alloy" "${WORK}/"
fi
bashio::config.true 'scrape_exporter' && cp "${INPUTS}/metrics-exporter.alloy" "${WORK}/"
bashio::config.true 'scrape_core'     && cp "${INPUTS}/metrics-core.alloy" "${WORK}/"

bashio::log.info "Starting Grafana Alloy (HassOS scenario)"
bashio::log.info "  metrics -> ${METRICS_PRIMARY_URL:-<unset>} (tenant: ${METRICS_PRIMARY_ORG:-none})"
bashio::log.info "  logs    -> ${LOGS_PRIMARY_URL:-<unset>} (tenant: ${LOGS_PRIMARY_ORG:-none})"
bashio::log.info "  inputs  -> $(cd "${WORK}" && echo *.alloy)"

exec /usr/local/bin/alloy run \
    --server.http.listen-addr=0.0.0.0:12345 \
    --disable-reporting \
    --storage.path=/data \
    "${WORK}"
