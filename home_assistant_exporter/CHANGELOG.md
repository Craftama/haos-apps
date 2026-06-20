# Changelog

## [0.0.4] - 2026-06-20

- Enable `host_network` so the exporter's `:9878` is exposed directly on the host (matches grafana_alloy)

## [0.0.3] - 2026-06-20

- Thin `FROM ghcr.io/cznewt/home-assistant-exporter` wrapper; the exporter image is now built and published from the upstream repo's own `docker/` build
- Removed the in-repo exporter image build and its publish workflow
- Translate options to `HASS_URL`/`HASS_TOKEN` without bashio (the upstream image is python:slim)
- Web port is now `9878` to match the upstream image

## [0.0.2] - 2026-06-20

- Consume the prebuilt `ghcr.io/craftama/home-assistant-exporter` image via `COPY --from` instead of cloning and building the exporter at add-on build time
- The exporter image (and its dependency fixes) now live in `images/home-assistant-exporter`, published by the `publish-exporter` workflow

## [0.0.1] - 2026-06-20

- Initial release
- Home Assistant OS wrapper around https://github.com/cznewt/home-assistant-exporter
- Connects to Home Assistant through the Supervisor websocket proxy by default; URL and token are overridable
