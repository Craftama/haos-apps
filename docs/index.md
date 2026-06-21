# Craftama Home Assistant apps

Home Assistant OS apps by Craftama. Add the repository to Home Assistant, then install any of the
apps below.

[:material-home-plus: Add repository](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FCraftama%2Fhaos-apps){ .md-button }

Or add the URL manually under **Settings → Add-ons → Add-on Store → ⋮ → Repositories**:
`https://github.com/Craftama/haos-apps`

## Apps

| App | Description |
| --- | --- |
| [Grafana Alloy](grafana_alloy.md) | OpenTelemetry Collector distribution with programmable pipelines |
| [Home Assistant Exporter](home_assistant_exporter.md) | Home Assistant metrics exporter for Prometheus |
| [Salt Minion](salt_minion.md) | Salt automates the management and configuration of infrastructure and applications at scale |

## Images

Each app is prebuilt and published to `ghcr.io/craftama/<slug>/<arch>` (set as the app's
`image:`), so installs pull a prebuilt image instead of compiling on-device.
