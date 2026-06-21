# Home Assistant Exporter

Home Assistant metrics exporter for Prometheus. A thin wrapper around
[cznewt/home-assistant-exporter](https://github.com/cznewt/home-assistant-exporter) that correlates
entities with **devices, areas, ZHA (Zigbee) and ESPHome diagnostics**. It talks to Home Assistant
over the Supervisor websocket proxy by default (`homeassistant_api: true`), so no manual token is
required. Metrics are served at `http://<homeassistant_ip>:9878/metrics`.

## Options

| Key          | Env var      | Default | Notes                                                            |
| ------------ | ------------ | ------- | ---------------------------------------------------------------- |
| `hass_url`   | `HASS_URL`   | —       | Empty → `ws://supervisor/core/websocket` (the Supervisor proxy). |
| `hass_token` | `HASS_TOKEN` | —       | Empty → the app's `SUPERVISOR_TOKEN`.                         |
| `log_level`  | `LOG_LEVEL`  | `info`  | `debug` / `info` / `warning` / `error` / `critical`.            |

## Examples

### Local instance (defaults)

```yaml
hass_url: ""        # uses the Supervisor proxy
hass_token: ""      # uses the app token
log_level: "info"
```

### Remote instance with a long-lived token

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
