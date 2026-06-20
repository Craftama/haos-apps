# Grafana Alloy

[Grafana Alloy](https://grafana.com/docs/alloy) collects, processes and exports metrics and logs.
This add-on runs the **HassOS scenario** from
[`alloy-resources`](https://github.com/Craftama) — the same modular Alloy config used elsewhere in
the fleet, vendored into the image so it runs self-contained on Home Assistant OS.

## What it collects

The scenario (`/alloy-resources/scenarios/hassos`) wires these vendored modules:

**Metrics** → Prometheus `remote_write`
- `system/linux/metrics/unix` — node_exporter (host CPU/mem/disk/net)
- `system/linux/metrics/process` — process_exporter
- `system/docker/metrics` — cAdvisor (per-container metrics)

**Logs** → Loki `write`, through the shared pipeline (level detection → normalize → drop → label → log metrics)
- `system/linux/logs/journal` — systemd journal
- `system/docker/logs` — Docker container logs

The `modules/` tree is baked into the image at `/alloy-resources/modules`, so the scenario's
`import.file "/alloy-resources/modules/..."` paths resolve with no external mounts or network.

## Configuration

Options map directly to the environment variables the scenario reads:

| Config           | Env var                | Description                                              |
| ---------------- | ---------------------- | ------------------------------------------------------- |
| `metrics_url`    | `METRICS_PRIMARY_URL`  | Prometheus remote_write URL (Mimir / Grafana Cloud).    |
| `metrics_tenant` | `METRICS_PRIMARY_ORG`  | `X-Scope-OrgID` header sent with metrics.               |
| `logs_url`       | `LOGS_PRIMARY_URL`     | Loki push URL.                                           |
| `logs_tenant`    | `LOGS_PRIMARY_ORG`     | Loki `tenant_id`.                                        |
| `cluster_name`   | `CLUSTER_NAME`         | `cluster` external label (default `HomeAssistant`).     |
| `env`            | `ENV`                  | `env` external label.                                   |
| `region`         | `REGION`               | `region` external label.                                |

> The upstream HassOS scenario uses tenant headers, not basic auth. For an endpoint that requires
> credentials, extend the scenario's `remote_write` / `loki.write` blocks accordingly.

## Requirements / protection mode

- **Docker metrics & logs** need the Docker socket — the add-on sets `docker_api: true`. Disable
  **Protection mode** in the add-on panel, otherwise the Docker (cAdvisor + log) components stay
  unhealthy while the rest keep running.
- `journald`, `host_network` and `host_pid` are enabled so journal logs and host-level node metrics
  are visible.

## Installation

1. Add [repository](https://github.com/Craftama/haos-apps) to Home Assistant.
1. Install "Grafana Alloy", disable Protection mode, set `metrics_url` / `logs_url`, start it.
1. Open the Alloy UI at `http://<homeassistant_ip>:12345`.

## Todo

- [ ] Re-add an AppArmor profile covering `/alloy-resources`, the Docker socket and cAdvisor
- [ ] Wire optional basic-auth into the scenario's exporters
- [ ] Build and publish prebuilt images
