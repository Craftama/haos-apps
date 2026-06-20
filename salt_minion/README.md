# Salt Minion

Runs a [SaltStack](https://saltproject.io/) minion inside Home Assistant OS and connects it to
your Salt master, so the add-on can be managed as a Salt target.

> **Scope / host access:** by default the minion runs in the add-on's Docker container and can only
> manage that container. On the **HAOS appliance image** the host is immutable and Supervisor-managed,
> so a minion cannot meaningfully manage the host even with extra privileges. To manage the actual
> host OS, run a minion on the host directly (this is realistic only on **HA Supervised**, a Debian
> host you own). The container's reach *can* be widened with add-on flags — `host_network`,
> `host_pid`, `host_dbus`, `privileged`, `full_access`, and `map:` of HA directories — but these are
> security-sensitive and off by default here. See "Host access" below.

## Installation

1. Add [repository](https://github.com/Craftama/haos-apps) to Home Assistant.
1. Search for "Salt Minion" in the add-on store and install it.
1. Set at least the `master` option on the "Configuration" tab.
1. Start the add-on and check the `Logs`.
1. On the master, accept the new key:

   ```
   salt-key -L            # list pending keys
   salt-key -a <minion_id>
   ```

## Configuration

| Config         | Description                                                              | Default | Required |
| -------------- | ------------------------------------------------------------------------ | ------- | -------- |
| `master`       | Hostname or IP address of the Salt master.                               |         | Yes      |
| `minion_id`    | Identifier presented to the master. Defaults to the container hostname.  |         | No       |
| `master_port`  | ZeroMQ request/return (ret) port of the master.                          | `4506`  | No       |
| `publish_port` | ZeroMQ publish (pub) port the minion subscribes to.                      | `4505`  | No       |
| `log_level`    | Minion logging verbosity.                                                | `info`  | No       |

### Ports

Salt's ZeroMQ transport uses **two** ports, both opened **outbound** from the minion to the master
(so this add-on needs no inbound port mappings):

- **4505** (`publish_port`) — the minion subscribes to the master's publish bus for job broadcasts.
- **4506** (`master_port`) — the minion makes request/return calls (job returns, file server).

Minion keys are stored in the add-on data volume (`/data/pki`), so the master only needs to
accept the key once — it survives restarts and updates.

## Host access

This add-on intentionally ships with no host privileges. If you need the minion to see more of the
host, add the relevant flags to `config.yaml` (and disable Protection mode in the add-on panel):

- `host_network: true` — share the host network namespace.
- `host_pid: true` — see host processes.
- `host_dbus: true` — reach the host system D-Bus.
- `privileged: [SYS_ADMIN, ...]` — grant specific Linux capabilities.
- `map:` — mount HA directories (`homeassistant_config`, `share`, `addons`, `all_addon_configs`, ...).
- `full_access: true` — full hardware/host access (strongly discouraged; appliance host remains immutable).

On the HAOS appliance these still cannot give you a writable, generally manageable host OS. For real
host management, install `salt-minion` on the host itself on an HA Supervised setup.

## Todo

- [ ] Add an icon/logo
- [ ] Add an AppArmor profile
- [ ] Pin the installed `salt-minion` version
