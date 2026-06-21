# haos-addons

Craftama apps — Home Assistant add-ons.

| Add-on | Description |
| ------ | ----------- |
| [Grafana Alloy](./grafana_alloy) | Collect, process and export metrics & logs to Prometheus / Loki. |
| [Home Assistant Exporter](./home_assistant_exporter) | Prometheus exporter for HA device / entity / ZHA / ESPHome diagnostics. |
| [Salt Minion](./salt_minion) | SaltStack minion that connects Home Assistant to a Salt master. |

See [docs/configuration.md](./docs/configuration.md) for per-add-on options and configuration examples.

Add-on images are prebuilt by the `publish` workflow and pulled from `ghcr.io/craftama/<slug>/<arch>`
(set as each add-on's `image:`), so installs don't compile on-device. The GHCR packages must be public.

## Installation

### Automatic

1. Add the repository.

   [![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FCraftama%2Fhaos-apps)

### Manual

1. Open the Add-ons panel in Home Assistant by going to `Settings --> Add-ons --> Add-on Store`.
1. Click the menu icon in the top-right, then click "Repositories".
1. Add this URL `https://github.com/Craftama/haos-apps`
