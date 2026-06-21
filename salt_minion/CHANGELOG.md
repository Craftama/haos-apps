# Changelog

## [3008.1] - 2026-06-21

- Pin `salt-minion` (and `salt-common`) to `3008.1`; the add-on version now tracks the bundled Salt version
- Use the square Salt Project logomark as the add-on icon

## [0.0.4] - 2026-06-20

- Add `minion_private_key` / `minion_public_key` options so the minion key pair can be managed from the add-on UI; seeded into the PKI dir on start (zero-touch acceptance when the master already trusts the key)

## [0.0.3] - 2026-06-20

- Add host-access flags: `host_pid`, `host_dbus` and `privileged` (SYS_ADMIN, SYS_PTRACE, SYS_RAWIO, NET_ADMIN, DAC_READ_SEARCH) so the minion can inspect/enter host namespaces (requires Protection mode off)

## [0.0.2] - 2026-06-20

- Enable `host_network` so the minion uses the host's network namespace (host IP and network grains, clean outbound to the master)

## [0.0.1] - 2026-06-20

- Initial release
- Runs a SaltStack minion that connects to a configurable Salt master
- Persists minion keys in the add-on data volume across restarts and updates
