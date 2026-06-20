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
| `minion_private_key` | PEM minion private key. If set, seeded into the PKI dir on start.   |         | No       |
| `minion_public_key`  | Minion public key. Paired with `minion_private_key`.               |         | No       |

### Ports

Salt's ZeroMQ transport uses **two** ports, both opened **outbound** from the minion to the master
(so this add-on needs no inbound port mappings):

- **4505** (`publish_port`) — the minion subscribes to the master's publish bus for job broadcasts.
- **4506** (`master_port`) — the minion makes request/return calls (job returns, file server).

### Keys

Minion keys are stored in the add-on data volume (`/data/pki`), so the master only needs to
accept the key once — it survives restarts and updates. To manage the key from the UI instead of
letting the minion auto-generate one, paste a PEM key pair into `minion_private_key` /
`minion_public_key` (best edited via the add-on's YAML config). If the master already trusts that
key, acceptance is zero-touch; otherwise accept it as usual with `salt-key -a <minion_id>`.

## Host access

To let the minion reach beyond its own container, the add-on enables host namespaces and a set of
privileged capabilities. **Disable Protection mode** in the add-on panel for these to take effect:

- `host_network` — host network namespace (host IP, network grains).
- `host_pid` — host PID namespace (see/signal host processes).
- `host_dbus` — host system D-Bus (e.g. systemd).
- `privileged: SYS_ADMIN, SYS_PTRACE, SYS_RAWIO, NET_ADMIN, DAC_READ_SEARCH` — capabilities for
  inspecting and entering host namespaces (e.g. `nsenter` into PID 1).

Even with these, on the **HAOS appliance** the system partition is read-only and Supervisor-managed,
so you still cannot treat it as a general, writable host. For full host management run `salt-minion`
directly on the host (realistic only on **HA Supervised**). Add `full_access: true` and/or
`map:` (HA directories) if you need still broader access.

## Todo

- [ ] Add an icon/logo
- [ ] Add an AppArmor profile
- [ ] Pin the installed `salt-minion` version
