# Salt Minion

Salt automates the management and configuration of infrastructure and applications at scale. This
app runs a [SaltStack](https://saltproject.io/) minion that connects out to a Salt master. The
minion keys persist in the app data volume (`/data/pki`), so the master accepts the key only once.

The app version tracks the bundled Salt version (e.g. `3008.1`; an app-only revision is
`3008.1.1`).

## Options

| Key                  | Default | Notes                                                            |
| -------------------- | ------- | ---------------------------------------------------------------- |
| `master`             | —       | **Required.** Hostname/IP of the Salt master.                    |
| `minion_id`          | —       | Defaults to the container hostname.                              |
| `master_port`        | `4506`  | ZeroMQ request/return (ret) port — outbound from the minion.     |
| `publish_port`       | `4505`  | ZeroMQ publish (pub) port — outbound from the minion.            |
| `log_level`          | `info`  | `garbage`/`trace`/`debug`/`info`/`warning`/`error`/`critical`    |
| `minion_private_key` | —       | PEM minion private key; seeded into the PKI dir on start.        |
| `minion_public_key`  | —       | Minion public key, paired with `minion_private_key`.             |

## Ports

Salt's ZeroMQ transport uses **two** ports, both dialed **outbound** by the minion (so the app
needs no inbound port mappings): `4505` (pub, the minion subscribes to job broadcasts) and `4506`
(ret, request/return calls).

## Keys

To manage the key from the UI instead of letting the minion auto-generate one, paste a PEM key pair
into `minion_private_key` / `minion_public_key` (best edited via the app's YAML config). If the
master already trusts that key, acceptance is zero-touch; otherwise accept it on the master:

```bash
salt-key -L                 # list pending keys
salt-key -a homeassistant   # accept this minion
salt 'homeassistant' test.ping
```

## Host access

The app enables host namespaces and privileged capabilities so the minion can reach beyond its own
container. **Disable Protection mode** for these to take effect:

- `host_network` — host network namespace (host IP, network grains).
- `host_pid` — host PID namespace (see/signal host processes).
- `host_dbus` — host system D-Bus (e.g. systemd).
- `privileged: SYS_ADMIN, SYS_PTRACE, SYS_RAWIO, NET_ADMIN, DAC_READ_SEARCH` — inspect/enter host namespaces.

!!! warning "HAOS appliance"
    Even with these, the HAOS system partition is read-only and Supervisor-managed, so it is not a
    freely writable host. For full host management run `salt-minion` directly on the host (realistic
    only on **HA Supervised**).

## Example

```yaml
master: "salt.lan"
minion_id: "homeassistant"
master_port: 4506
publish_port: 4505
log_level: "info"
```
