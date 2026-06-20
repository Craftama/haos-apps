# Home Assistant Exporter

A Home Assistant OS add-on that packages the
[**cznewt/home-assistant-exporter**](https://github.com/cznewt/home-assistant-exporter)
Prometheus exporter. Unlike the built-in
[Prometheus integration](https://www.home-assistant.io/integrations/prometheus/) (entity
metrics only), this exporter correlates entities with **devices, areas, ZHA (Zigbee) and
ESPHome diagnostics** and does not require Service-Discovery-unfriendly token handling — it
talks to Home Assistant through the Supervisor websocket proxy.

> This add-on is a thin wrapper: it is `FROM ghcr.io/cznewt/home-assistant-exporter` (a prebuilt,
> multi-arch image built and published from the upstream repo's own `docker/` build) and only adds
> a small run script that maps the add-on options to the exporter's `HASS_URL` / `HASS_TOKEN` env.

### Metrics (provided by upstream)

```
hass_area_info{area_id, area_name}
hass_device_info{device_id, device_name, manufacturer, model, sw_version, hw_version, integration}
hass_device_available{device_id, device_name}
hass_device_last_activity{device_id, device_name}
hass_device_battery_remaining{device_id, device_name}
hass_zha_device_info{device_id, device_name, device_type, power_source}
hass_zha_device_lqi / hass_zha_device_rssi / hass_zha_mesh_lqi
hass_entity_info{entity_id, entity_name, area_id, device_id, device_name, class, unit}
hass_entity_value{entity_id}
hass_entity_last_change / hass_entity_last_update{entity_id}
```

## Installation

1. Add [repository](https://github.com/Craftama/haos-apps) to Home Assistant.
1. Search for "Home Assistant Exporter" in the add-on store and install it.
1. (Optional) adjust configuration. Defaults talk to the local instance via the Supervisor proxy.
1. Start the add-on and check the `Logs`.
1. Browse the metrics at `http://<homeassistant_ip>:9878/metrics`.

## Configuration

| Config       | Description                                                                                       | Default | Required |
| ------------ | ------------------------------------------------------------------------------------------------- | ------- | -------- |
| `hass_url`   | Websocket URL of the target HA. Empty = Supervisor proxy (`ws://supervisor/core/websocket`).      |         | No       |
| `hass_token` | Long-lived access token. Empty = the add-on's auto-provisioned Supervisor token.                  |         | No       |
| `debug`      | Enable debug-level logging.                                                                        | `false` | No       |

The image version is controlled upstream (the exporter repo's `VERSION` and its `docker-publish`
workflow). The add-on consumes it as the `build_from` base in `build.yaml` — pin a tag there to
freeze the exporter version.

### Grafana Alloy Config Example

```alloy
prometheus.scrape "home_assistant" {
	targets    = [{ __address__ = "<homeassistant_ip>:9878" }]
	forward_to = [prometheus.remote_write.default.receiver]
	job_name   = "home_assistant"
}
```

## Todo

- [ ] Add an icon/logo
- [ ] Make the `ghcr.io/cznewt/home-assistant-exporter` package public so add-on builds can pull it
