#!/usr/bin/env bashio

# Persist the minion's PKI (keys) in the add-on data volume so the master does
# not have to re-accept the key after every restart or update.
mkdir -p /data/pki
if [ ! -L /etc/salt/pki ]; then
    rm -rf /etc/salt/pki
    ln -s /data/pki /etc/salt/pki
fi

# Optionally seed the minion key pair from configuration so keys can be managed
# from the add-on UI. If the master already trusts this key, acceptance is
# zero-touch; otherwise it is still pending until accepted on the master.
mkdir -p /etc/salt/pki/minion
if bashio::config.has_value 'minion_private_key'; then
    bashio::config 'minion_private_key' > /etc/salt/pki/minion/minion.pem
    chmod 400 /etc/salt/pki/minion/minion.pem
    bashio::log.info "Loaded minion private key from configuration"
fi
if bashio::config.has_value 'minion_public_key'; then
    bashio::config 'minion_public_key' > /etc/salt/pki/minion/minion.pub
    chmod 644 /etc/salt/pki/minion/minion.pub
fi

if bashio::config.is_empty 'master'; then
    bashio::exit.nok "The 'master' option is required (address of your Salt master)."
fi

MASTER="$(bashio::config 'master')"
MASTER_PORT="$(bashio::config 'master_port')"
PUBLISH_PORT="$(bashio::config 'publish_port')"
LOG_LEVEL="$(bashio::config 'log_level')"

if bashio::config.has_value 'minion_id'; then
    MINION_ID="$(bashio::config 'minion_id')"
else
    MINION_ID="$(hostname)"
fi

# master_port is the ZeroMQ ret port (4506); publish_port is the PUB port (4505).
cat > /etc/salt/minion <<EOF
master: ${MASTER}
master_port: ${MASTER_PORT}
publish_port: ${PUBLISH_PORT}
id: ${MINION_ID}
log_level: ${LOG_LEVEL}
pki_dir: /etc/salt/pki/minion
EOF

bashio::log.info "Configured Salt minion '${MINION_ID}' -> ${MASTER} (ret ${MASTER_PORT}, pub ${PUBLISH_PORT})"
