# Add-on configuration & examples

Configuration reference and worked examples for the add-ons in this repository. Each add-on is
configured from its **Configuration** tab in Home Assistant (the keys below map to `config.yaml`
options); the matching `bashio` reads happen in the add-on's `run.sh`.

- [Grafana Alloy](#grafana-alloy)
- [Home Assistant Exporter](#home-assistant-exporter)
- [Salt Minion](#salt-minion)

---

## Grafana Alloy

Runs the vendored [alloy-resources](https://github.com/Craftama) **HassOS scenario**: node/process
metrics, Docker (cAdvisor) metrics, journal + Docker logs through the shared log-processing pipeline.
The Alloy UI is at `http://<homeassistant_ip>:12345`.

### Options

| Key              | Env var               | Default          | Notes                                            |
| ---------------- | --------------------- | ---------------- | ------------------------------------------------ |
| `metrics_url`    | `METRICS_PRIMARY_URL` | —                | Prometheus `remote_write` URL.                   |
| `metrics_tenant` | `METRICS_PRIMARY_ORG` | —                | Sent as `X-Scope-OrgID` (multi-tenant Mimir).    |
| `logs_url`       | `LOGS_PRIMARY_URL`    | —                | Loki push URL.                                   |
| `logs_tenant`    | `LOGS_PRIMARY_ORG`    | —                | Loki `tenant_id`.                                |
| `cluster_name`   | `CLUSTER_NAME`        | `HomeAssistant`  | `cluster` external label on every series.        |
| `env`            | `ENV`                 | —                | `env` external label.                            |
| `region`         | `REGION`              | —                | `region` external label.                         |

> Disable **Protection mode** so the Docker (cAdvisor + log) components can reach the Docker socket
> (`docker_api: true`). The rest of the pipeline runs regardless.

### Example: local Mimir + Loki (multi-tenant)

```yaml
metrics_url: "http://mimir.lan:9009/api/v1/push"
metrics_tenant: "home"
logs_url: "http://loki.lan:3100/loki/api/v1/push"
logs_tenant: "home"
cluster_name: "house"
env: "prod"
region: "home-lab"
```

### Example: metrics only

```yaml
metrics_url: "http://prometheus.lan:9090/api/v1/write"
logs_url: ""        # leave empty to skip the logs pipeline target
cluster_name: "house"
```

---

## Home Assistant Exporter

Wrapper around [`cznewt/home-assistant-exporter`](https://github.com/cznewt/home-assistant-exporter).
Exposes device/entity/ZHA/ESPHome diagnostics as Prometheus metrics on
`http://<homeassistant_ip>:9878/metrics`. Talks to HA over the Supervisor websocket proxy by default
(`homeassistant_api: true`), so no manual token is required.

### Options

| Key          | Env var       | Default | Notes                                                          |
| ------------ | ------------- | ------- | -------------------------------------------------------------- |
| `hass_url`   | `HASS_URL`    | —       | Empty → `ws://supervisor/core/websocket` (the Supervisor proxy). |
| `hass_token` | `HASS_TOKEN`  | —       | Empty → the add-on's `SUPERVISOR_TOKEN`.                       |
| `debug`      | —             | `false` | Debug-level logging.                                           |

### Example: local instance (defaults)

```yaml
hass_url: ""        # uses the Supervisor proxy
hass_token: ""      # uses the add-on token
debug: false
```

### Example: remote instance with a long-lived token

```yaml
hass_url: "ws://homeassistant.lan:8123/api/websocket"
hass_token: "eyJhbGciOi...your-long-lived-token..."
```

### Scrape it from Grafana Alloy

```alloy
prometheus.scrape "home_assistant" {
	targets    = [{ __address__ = "homeassistant.lan:9878" }]
	forward_to = [prometheus.remote_write.default.receiver]
	job_name   = "home_assistant"
}
```

### Scrape it from Prometheus

```yaml
scrape_configs:
  - job_name: home_assistant
    static_configs:
      - targets: ["homeassistant.lan:9878"]
```

---

## Salt Minion

Runs a [SaltStack](https://saltproject.io/) minion that connects out to a Salt master. The minion's
keys persist in the add-on data volume (`/data/pki`), so the master accepts the key only once.

### Options

| Key            | Default | Notes                                                         |
| -------------- | ------- | ------------------------------------------------------------- |
| `master`       | —       | **Required.** Hostname/IP of the Salt master.                 |
| `minion_id`    | —       | Defaults to the container hostname.                           |
| `master_port`  | `4506`  | ZeroMQ request/return (ret) port — outbound from the minion.  |
| `publish_port` | `4505`  | ZeroMQ publish (pub) port — outbound from the minion.         |
| `log_level`    | `info`  | `garbage`/`trace`/`debug`/`info`/`warning`/`error`/`critical` |

Both ports are dialed **outbound** by the minion, so the add-on needs no inbound port mappings.

### Example

```yaml
master: "salt.lan"
minion_id: "homeassistant"
master_port: 4506
publish_port: 4505
log_level: "info"
```

### Accept the key on the master

```bash
salt-key -L                 # list pending keys
salt-key -a homeassistant   # accept this minion
salt 'homeassistant' test.ping
```

> On the HAOS appliance the minion can only manage its own container. See the add-on README for the
> host-access flags and the HA Supervised caveat.
