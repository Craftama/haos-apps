# Changelog

## [0.0.2] - 2026-06-20

- Enable `host_network` so the minion uses the host's network namespace (host IP and network grains, clean outbound to the master)

## [0.0.1] - 2026-06-20

- Initial release
- Runs a SaltStack minion that connects to a configurable Salt master
- Persists minion keys in the add-on data volume across restarts and updates
