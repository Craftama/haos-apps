# Grafana Alloy

OpenTelemetry Collector distribution with programmable pipelines. This app runs the **HassOS
scenario** from [alloy-resources](https://github.com/cznewt/alloy-resources), vendored into the image
so it runs self-contained. The Alloy UI is at `http://<homeassistant_ip>:12345`.

## What it collects

The scenario is split into a **base** (the metric/log sinks + shared log pipeline) plus
**toggleable input pipelines**. `run.sh` assembles the active config from the enabled inputs.

| Toggle            | Default | Input                                                        |
| ----------------- | ------- | ------------------------------------------------------------ |
| `enable_unix`     | `true`  | node_exporter (unix) metrics.                                |
| `enable_process`  | `true`  | process_exporter metrics.                                    |
| `enable_docker`   | `true`  | cAdvisor metrics + Docker container logs.                    |
| `enable_journal`  | `true`  | systemd journal logs.                                        |
| `scrape_exporter` | `false` | Scrape the Home Assistant Exporter add-on at `:9878`.        |
| `scrape_core`     | `false` | Scrape HA core `/api/prometheus` (no auth, job `homeassistant`). |

## Options

Each option maps to the environment variable the scenario reads.

| Key              | Env var               | Default          | Notes                                         |
| ---------------- | --------------------- | ---------------- | --------------------------------------------- |
| `metrics_url`    | `METRICS_PRIMARY_URL` | —                | Prometheus `remote_write` URL.                |
| `metrics_tenant` | `METRICS_PRIMARY_ORG` | —                | Sent as `X-Scope-OrgID` (multi-tenant Mimir). |
| `logs_url`       | `LOGS_PRIMARY_URL`    | —                | Loki push URL.                                |
| `logs_tenant`    | `LOGS_PRIMARY_ORG`    | —                | Loki `tenant_id`.                             |
| `cluster_name`   | `CLUSTER_NAME`        | `HomeAssistant`  | `cluster` external label on every series.     |
| `env`            | `ENV`                 | —                | `env` external label.                         |
| `region`         | `REGION`              | —                | `region` external label.                      |
| `instance`       | `INSTANCE`            | —                | Override the `instance` label on all metrics (host name). |

!!! note "Protection mode"
    Disable **Protection mode** so the Docker (cAdvisor + log) components can reach the Docker socket
    (`docker_api: true`). The rest of the pipeline runs regardless.

## Examples

### Local Mimir + Loki (multi-tenant)

```yaml
metrics_url: "http://mimir.lan:9009/api/v1/push"
metrics_tenant: "home"
logs_url: "http://loki.lan:3100/loki/api/v1/push"
logs_tenant: "home"
cluster_name: "house"
env: "prod"
region: "home-lab"
```

### Metrics only

```yaml
metrics_url: "http://prometheus.lan:9090/api/v1/write"
logs_url: ""        # leave empty to skip the logs pipeline target
cluster_name: "house"
```
