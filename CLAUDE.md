# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A [Home Assistant add-on repository](https://developers.home-assistant.io/docs/add-ons/repository)
(remote: `github.com/Craftama/haos-apps`). `repository.yml` registers it with the HA Supervisor;
each top-level directory is one add-on. Add-ons here:

- **grafana_alloy** — runs Grafana Alloy; renders its `config.alloy` from add-on options.
- **home_assistant_exporter** — thin wrapper that clones & runs the upstream Prometheus exporter
  [`cznewt/home-assistant-exporter`](https://github.com/cznewt/home-assistant-exporter) at build time.
- **salt_minion** — runs a SaltStack minion against a configurable master.

## Conventions (follow these when adding/editing add-ons)

- **Slugs and folder names use underscores** (`grafana_alloy`, not `grafana-alloy`). The `slug:` in
  `config.yaml` must match the folder name.
- **Every functional change bumps `version:` in that add-on's `config.yaml` AND adds a `CHANGELOG.md`
  entry.** The Supervisor only offers an update when the version string changes.
- New options must be added in three places that must stay in sync: `config.yaml` `options:` (defaults)
  + `schema:` (validation) and `translations/en.yaml` (UI labels). Read them via `bashio::config`.

## Add-on architecture (shared pattern)

All add-ons build on `ghcr.io/hassio-addons/debian-base/{arch}:9.1.0` (set per-arch in `build.yaml`)
and **bypass the s6 init system**: the `Dockerfile` ends with `ENTRYPOINT []` + `CMD ["/run.sh"]`,
and `config.yaml` sets `init: false`. The s6 `cont-init.d` / `services.d` directories still exist but
are invoked **manually** by `run.sh` rather than by s6 — e.g. grafana_alloy and salt_minion do:

```
run.sh  ->  /etc/cont-init.d/<setup>.sh   (build config from options)
        ->  exec /etc/services.d/<svc>/run (exec the long-running process)
```

`run.sh` and the service scripts use the `bashio` shebang (`#!/usr/bin/env bashio`) so `bashio::config`,
`bashio::log.*`, `bashio::config.require`, etc. are available. Files under `rootfs/` are copied to the
image root (`COPY rootfs /`), so `rootfs/etc/services.d/foo/run` lands at `/etc/services.d/foo/run`.

Config generation is options-driven, not file-mounted:
- **grafana_alloy** — `alloy_setup.sh` exports shell vars from options and `envsubst`s
  `config.alloy.template` into `/etc/alloy/config.alloy` (unless `override_config` points at a user file).
- **salt_minion** — `salt_setup.sh` writes `/etc/salt/minion` from options and symlinks `/etc/salt/pki`
  to `/data/pki` so accepted keys survive restarts/updates (`/data` is the persistent add-on volume).

### Talking to Home Assistant

`home_assistant_exporter` sets `homeassistant_api: true`, which makes the Supervisor inject
`SUPERVISOR_TOKEN` and proxy the Core API. `run.sh` defaults the exporter to the proxy
(`ws://supervisor/core/websocket` + `SUPERVISOR_TOKEN`); both are overridable via options for pointing
at a remote instance. It is a **wrapper** — the exporter code is not vendored; the `Dockerfile`
`git clone`s `HAE_REF` (default `master`) and `pip install`s its `requirements.txt` into `/opt/venv`.

## Building / testing

There is no unit-test suite; add-ons are validated by building the image and running them in a HA
Supervisor. Two ways to build a single add-on locally:

```bash
# Plain docker build (host arch) — pass the base image the add-on expects:
docker build --build-arg BUILD_FROM=ghcr.io/hassio-addons/debian-base/amd64:9.1.0 \
  -t local/grafana_alloy ./grafana_alloy

# Official HA builder (handles arch matrix + labels; --test = build only, no push):
docker run --rm --privileged \
  -v /var/run/docker.sock:/var/run/docker.sock -v "$(pwd)":/data \
  ghcr.io/home-assistant/amd64-builder -t /data/grafana_alloy --amd64 --test
```

For an end-to-end run, open the repo in the VS Code **devcontainer** (`.devcontainer/devcontainer.json`)
and run the `Start Home Assistant` task (`.vscode/tasks.json`, command `supervisor_run`). The repo
mounts as a local add-on store; install the add-on from **Settings → Add-ons → Local add-ons**, then
check its Logs.

Note `home_assistant_exporter` clones from GitHub at build time, so its build requires network access.
