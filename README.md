# Craftama Home Assistant apps

| App | Description |
| ------ | ----------- |
| [Grafana Alloy](./grafana_alloy) | OpenTelemetry Collector distribution with programmable pipelines |
| [Home Assistant Exporter](./home_assistant_exporter) | Home Assistant metrics exporter for Prometheus |
| [Salt Minion](./salt_minion) | Salt automates the management and configuration of infrastructure and applications at scale |

📖 **Docs:** <https://craftama.github.io/haos-apps/> (per-app options & examples)

Each app installs from a prebuilt, multi-arch GHCR image (`ghcr.io/craftama/<slug>/<arch>`, built by
the `publish` workflow), so Home Assistant pulls a ready image instead of compiling it on-device. The
GHCR packages must be public for the pull to work.

## Installation

### Automatic

1. Add the repository.

   [![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FCraftama%2Fhaos-apps)

### Manual

1. Open the Add-ons panel in Home Assistant by going to `Settings --> Add-ons --> Add-on Store`.
1. Click the menu icon in the top-right, then click "Repositories".
1. Add this URL `https://github.com/Craftama/haos-apps`
