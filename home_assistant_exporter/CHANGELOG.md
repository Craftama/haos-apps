# Changelog

## [0.0.2] - 2026-06-20

- Consume the prebuilt `ghcr.io/craftama/home-assistant-exporter` image via `COPY --from` instead of cloning and building the exporter at add-on build time
- The exporter image (and its dependency fixes) now live in `images/home-assistant-exporter`, published by the `publish-exporter` workflow

## [0.0.1] - 2026-06-20

- Initial release
- Home Assistant OS wrapper around https://github.com/cznewt/home-assistant-exporter
- Connects to Home Assistant through the Supervisor websocket proxy by default; URL and token are overridable
